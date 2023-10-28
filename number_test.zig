const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "underscores" {
    const n = 1_234.567_89;
    try expectEqual(n, 1234.56789);
}
