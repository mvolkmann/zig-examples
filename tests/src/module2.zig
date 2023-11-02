const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

pub fn second() void {
    print("in second\n", .{});
}

test "second" {
    expectEqual(2, 2);
}
