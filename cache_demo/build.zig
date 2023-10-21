const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    //std.debug.print("b = {}\n", .{b});

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "cache-demo",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // The first argument is the step name and the second is the
    // description that appears when `zig build --list-steps` is entered.
    const step1 = b.step("step1", "first step");
    step1.makeFn = myStep1;

    const step2 = b.step("step2", "second step");
    step2.makeFn = myStep2;
    // Can optionally depend on and number of other steps.
    step2.dependOn(step1);

    const step3 = b.step("step3", "third step");
    step3.makeFn = myStep3;
    step3.dependOn(step1);
    step3.dependOn(step2);
}

const print = std.debug.print;

// The first parameter is "self" and second is "progress",
// but use "_" if unused.
// The fields in a std.build.Step struct instance include
// name, dependencies, dependents, state, and more.
// The std.Progress.Node struct instance doesn't seem very useful.
fn myStep1(step: *std.build.Step, _: *std.Progress.Node) !void {
    print("in {s}\n", .{step.name});

    // To pass command-line arguments,
    // enter "zig build step1 -- arg1 arg2 etc`.
    // To access the command-line arguments ...
    if (step.owner.args) |args| {
        for (args) |arg| {
            print("arg = {s}\n", .{arg});
        }
    }

    // Print the name of each step field.
    // const fieldNames = std.meta.fieldNames(std.build.Step);
    // for (fieldNames) |fieldName| {
    //     print("step field = {s}\n", .{fieldName});
    // }

    // Print the name of each progress field.
    // const fieldNames = std.meta.fieldNames(std.Progress.Node);
    // for (fieldNames) |fieldName| {
    //     print("progress field = {s}\n", .{fieldName});
    // }
}

fn myStep2(step: *std.build.Step, _: *std.Progress.Node) !void {
    print("in {s}\n", .{step.name});
}

fn myStep3(step: *std.build.Step, _: *std.Progress.Node) !void {
    print("in {s}\n", .{step.name});
}
