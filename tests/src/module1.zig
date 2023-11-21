const std = @import("std");
const m2 = @import("sub/module2.zig");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

pub fn first() void {
    print("in first\n", .{});
    m2.second();
}

test "first" {
    try expectEqual(1, 1);
}
