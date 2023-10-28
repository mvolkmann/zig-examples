const builtin = @import("builtin");
const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn report() void {
    print("in test? {}\n", .{std.builtin.is_test});
}

pub fn main() void {
    report();
}

test "add works" {
    report();
    try expectEqual(add(1, 2), 3); // passes
}
