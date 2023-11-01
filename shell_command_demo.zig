const std = @import("std");
const print = std.debug.print;
const String = []const u8;

pub fn main() !void {
    var config = .{
        .enable_memory_limit = true,
    };
    var gpa = std.heap.GeneralPurposeAllocator(config){};
    gpa.requested_memory_limit = 1600; // get error: OutOfMemory with 1500
    print("requested_memory_limit = {}\n", .{gpa.requested_memory_limit});

    var allocator = gpa.allocator();
    const result = try std.ChildProcess.run(.{
        .allocator = allocator,
        // .argv = &[_]String{ "echo", "Hello, World!" },
        .argv = &[_]String{"date"},
    });
    print("{s}\n", .{result.stdout});
}
