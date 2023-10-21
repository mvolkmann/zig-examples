const std = @import("std");
const String = []const u8;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    const result = try std.ChildProcess.exec(.{
        .allocator = allocator,
        // .argv = &[_]String{ "echo", "Hello, World!" },
        .argv = &[_]String{"date"},
    });
    std.debug.print("{s}\n", .{result.stdout});
}
