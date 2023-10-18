const std = @import("std");
const expectEqual = std.testing.expectEqual;

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "add works" {
    try expectEqual(add(1, 2), 5); // passes
}
