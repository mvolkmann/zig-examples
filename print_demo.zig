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

// This sets the default logging level.
pub const std_options = struct {
    // Set this to .info, .debug, .warn, or .err.
    pub const log_level = .warn;
};

// This sets the logging leve for each app-specific scope.
// THIS IS NOT WORKING!
pub const scope_levels = [_]std.log.ScopeLevel{
    .{ .scope = .default, .level = .warn },
    .{ .scope = .my_project, .level = .err },
};

// THIS IS NOT WORKING!
pub const options_override = struct {
    const log_scope_levels = [_]std.log.ScopeLevel{
        .{ .scope = .default, .level = .warn },
        .{ .scope = .my_project, .level = .err },
    };
};

pub fn main() !void {
    const dog = Dog{ .name = "Comet", .breed = "whippet", .age = 3 };
    print("{}\n", .{dog});

    // Use this instead of std.log to scope the log messages.
    // This could be used to filter log output to a specific part of an application.
    const log = std.log.scoped(.my_project);

    // Does std.options.log_scope_levels specify which logging levels are enabled?
    log.info("{} + {} = {}", .{ 1, 2, 1 + 2 });
    log.debug("{} + {} = {}", .{ 1, 2, 1 + 2 });
    log.warn("{} + {} = {}", .{ 1, 2, 1 + 2 });
    log.err("{} + {} = {}", .{ 1, 2, 1 + 2 });
}
