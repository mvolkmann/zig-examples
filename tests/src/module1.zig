const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

pub fn first() void {
    print("in first\n", .{});
}

test "first" {
    try expectEqual(1, 1);
}
