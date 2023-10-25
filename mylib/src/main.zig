//! This modules implements math functions.

const std = @import("std");
const testing = std.testing;

// This adds two integer.
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

// This tests the add function.
test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
