const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

test "tuple" {
    // Casting the integer and float literal values
    // to specific types is optional.
    const tuple = .{ true, @as(u8, 19), @as(f32, 3.14), 'A', "hello" };
    try expectEqual(tuple.len, 5);
    try expectEqual(tuple[0], true);
    try expectEqual(tuple[1], 19);
    try expectEqual(tuple[2], 3.14);
    try expectEqual(tuple[3], 'A');
    try expectEqual(tuple[4], "hello");
    try expectEqual(tuple.@"4", "hello"); // alternate way to index

    inline for (tuple) |value| {
        const T = @TypeOf(value);
        print("The type of {any} is {}.\n", .{ value, T });
        print("typeInfo is {}.\n", .{@typeInfo(T)});
    }

    // Destructuring can be used to get the elements of a tuple,
    // but all the elements must be matched.
    const e1, const e2, const e3, const e4, const e5 = tuple;
    _ = e3;
    _ = e4;
    _ = e5;
    try expectEqual(e1, true);
    try expectEqual(e2, 19);
}
