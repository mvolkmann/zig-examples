const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

var top_level: u8 = 1;

test "variables" {
    // This shows that using a variable whose value is undefined
    // will not result in an error and will given unexpected results.
    var value: i32 = undefined;
    try expectEqual(value + 1, -1431655765);

    const limit = 5;
    try expectEqual(@TypeOf(limit), comptime_int);
    try expectEqualStrings(@typeName(@TypeOf(limit)), "comptime_int");
}

fn increment() void {
    top_level += 1;
}

test "top-level variable" {
    increment();
    increment();
    try expectEqual(top_level, 3);
}
