const std = @import("std");
const print = std.debug.print; // writes to stderr

const Dog = struct {
    name: []const u8,
    breed: []const u8,
    age: u8,

    const Self = @This();
    pub fn format(
        value: Self,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) std.os.WriteError!void {
        return writer.print(
            "{s} is a {d} year old {s}.",
            .{ value.name, value.age, value.breed },
        );
    }
};

pub const std_options = struct {
    // This sets the default logging level.
    // Set to .info, .debug, .warn, or .err.
    pub const log_level = .warn;

    // This sets scope-specific logging levels.
    pub const log_scope_levels = &[_]std.log.ScopeLevel{
        // Can have one line like this for each scope.
        .{ .scope = .my_library, .level = .info },
    };
};

pub fn main() !void {
    const dog = Dog{ .name = "Comet", .breed = "whippet", .age = 3 };
    print("{}\n", .{dog});

    // Use this instead of std.log to scope the log messages.
    // This can be used to filter log output to a specific part of an application.
    const log = std.log.scoped(.my_library);

    // Does std.options.log_scope_levels specify which logging levels are enabled?
    log.info("{} + {} = {}", .{ 1, 2, 1 + 2 });
    log.debug("{} + {} = {}", .{ 1, 2, 1 + 2 });
    log.warn("{} + {} = {}", .{ 1, 2, 1 + 2 });
    log.err("{} + {} = {}", .{ 1, 2, 1 + 2 });

    const stdout = std.io.getStdOut();
    const sow = stdout.writer();
    try sow.print("Hello, {s}!\n", .{"world"});
}
