const std = @import("std");

pub fn main() !void {
    // This gives OutOfMemory error when the buffer is less than 130 bytes.
    var buffer: [130]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var list = std.ArrayList([]const u8).init(allocator);
    try list.append("one");
    try list.append("two");
    try list.append("three");
}