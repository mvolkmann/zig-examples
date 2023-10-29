const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "comptime sizes" {
    const i = 7;
    try expectEqual(comptime_int, @TypeOf(i));
    // try expectEqual(8, @sizeOf(@TypeOf(i))); // fails

    const f = 3.14;
    try expectEqual(comptime_float, @TypeOf(f));
    // try expectEqual(8, @sizeOf(@TypeOf(f))); // fails
}

test "underscores" {
    const n = 1_234.567_89;
    try expectEqual(n, 1234.56789);
}
