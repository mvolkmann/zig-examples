const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn double(n: ?i32) i32 {
    const value = n orelse return 0;
    return value * 2;
}

test "orelse" {
    var maybeNumber: ?i32 = null;
    var number = maybeNumber orelse 0;
    try expectEqual(number, 0);

    maybeNumber = 42;
    number = maybeNumber orelse 0;
    try expectEqual(number, 42);

    try expectEqual(double(2), 4);
    try expectEqual(double(null), 0);
}
