const std = @import("std");
const expect = std.testing.expect;

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test add {
    try expect(add(1, 2) == 3); // passes
}

test "add works" {
    try expect(add(1, 2) == 3); // passes
    try expect(add(2, 3) == 50); // fails
}
