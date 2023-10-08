const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "add works" {
    try expect(add(1, 2) == 3); // passes
    // try expect(add(2, 3) == 50); // fails
}

test "casting" {
    var a: i8 = 0;
    try expectEqual(0, a);
    // try expectEqual(@as(i8, 0), a);
}
