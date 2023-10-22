const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "orelse" {
    var maybeNumber: ?i32 = null;
    var number = maybeNumber orelse 0;
    try expectEqual(number, 0);

    maybeNumber = 42;
    number = maybeNumber orelse 0;
    try expectEqual(number, 42);
}
