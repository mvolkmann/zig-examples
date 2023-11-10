const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "clz" {
    const i: u8 = 16;
    // bits are 00010000
    try expectEqual(3, @clz(i));
}

test "ctz" {
    const i: u8 = 16;
    // bits are 00010000
    try expectEqual(4, @ctz(i));
}

test "popcount" {
    const i: u8 = 16;
    // bits are 00010000
    try expectEqual(1, @popCount(i));
}
