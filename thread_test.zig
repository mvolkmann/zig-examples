const std = @import("std");
const expectEqual = std.testing.expectEqual;
const print = std.debug.print;
const Thread = std.Thread;
const String = []const u8;

// Each thread has its own instance of this variable.
threadlocal var x: i32 = 1;

var cpu_count: usize = 0;

fn process1(i: u8) !void {
    // std.time.sleep(@as(u64, std.time.ns_per_s * @as(u64, cpu_count - i)));

    print("process: i = {}\n", .{i});
    // print("process: running in thread {}\n", .{ currentThread.getName() });

    try expectEqual(x, 1);
    // Can call thread.yield() to suspend this thread
    // and allow another thread to run.
    x += 1;
    try expectEqual(x, 2);
}

fn process2(i: u8, wg: ?*Thread.WaitGroup) !void {
    std.time.sleep(@as(u64, std.time.ns_per_s * @as(u64, cpu_count - i)));

    print("process: i = {}\n", .{i});
    // print("process: running in thread {}\n", .{ currentThread.getName() });

    try expectEqual(x, 1);
    // Can call thread.yield() to suspend this thread
    // and allow another thread to run.
    x += 1;
    try expectEqual(x, 2);

    if (wg) |group| group.finish(); // decrements WaitGroup counter
}

// See issue #17774 at https://github.com/ziglang/zig/issues/17774.
// test "threads with join" {
//     cpu_count = try Thread.getCpuCount();
//     // print("\nCPU count = {}\n", .{cpu_count});

//     var i: u8 = 0;
//     while (i < cpu_count - 1) : (i += 1) {
//         print("i = {}\n", .{i});
//         // The first argument to spawn is a SpawnConfig object
//         // that can have stack_size (defaults to 16MB)
//         // and allocator (defaults to null) fields.
//         // The second argument is the function to run in the thread.
//         // The third argument is a tuple of arguments to pass to the function.
//         const thread = try Thread.spawn(.{}, process1, .{i});

//         // var buffer: [10]u8 = undefined;
//         // const name = try std.fmt.bufPrint(&buffer, "t{}", .{i});
//         // print("name = {s}\n", .{name});
//         // try thread.setName(name);

//         // Must either call join or detach on each thread.
//         thread.join(); // waits for thread to end
//     }

//     // try process(0, "main"); // runs in main thread

//     print("all threads finished\n", .{});
// }

test "threads with WaitGroup" {
    cpu_count = try Thread.getCpuCount();
    // print("\nCPU count = {}\n", .{cpu_count});

    var wg: Thread.WaitGroup = .{};

    var i: u8 = 0;
    while (i < cpu_count - 1) : (i += 1) {
        wg.start(); // increment WaitGroup counter
        const thread = try Thread.spawn(.{}, process2, .{ i, &wg });

        // var buffer: [10]u8 = undefined;
        // const name = try std.fmt.bufPrint(&buffer, "t{}", .{i});
        // print("name = {s}\n", .{name});
        // try thread.setName(name); // gives error.Unsupported

        // Must either call join or detach on each thread.
        thread.detach(); // use with WaitGroup
    }

    wg.wait(); // waits for WaitGroup counter to return to zero
    // wg.reset(); // needed?
    print("all threads finished\n", .{});
}
