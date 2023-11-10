const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "shlExact" {
    const i: u8 = 16;
    // bits are 00010000
    try expectEqual(32, @shlExact(i, 1));
}

test "shrExact" {
    const i: u8 = 16;
    // bits are 00010000
    try expectEqual(8, @shrExact(i, 1));
}
