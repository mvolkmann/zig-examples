const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "cast" {
    var n1: u32 = 123;
    var n2 = @as(u8, @intCast(n1)); // works
    try expectEqual(n1, n2);

    // var n3 = @as(u8, n1); // does not work because bits can be truncated
    // try expectEqual(n1, n3);
}

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
