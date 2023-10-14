const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "labeled block" {
    const s1 = blk: {
        const ms = std.time.milliTimestamp();
        const s = @divFloor(ms + 500, 1000);
        break :blk s;
    };

    // Often labeled blocks can be replaced by a single expression.
    const s2 = @divFloor(std.time.milliTimestamp() + 500, 1000);

    try expectEqual(s1, s2);
}
