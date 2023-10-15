const std = @import("std");
const print = std.debug.print;
const trait = std.meta.trait;
const expectEqual = std.testing.expectEqual;

test "tuple" {
    // Casting the integer and float literal values
    // to specific types is optional.
    // The compiler will know the element types in this tuple
    // and can use them in the "inline for" loop below.
    // This is important because the types passed to
    // "trait.isZigString" must be known at compile-time.
    const tuple = .{ true, @as(u8, 19), @as(f32, 3.14), 'A', "hello" };

    try expectEqual(tuple.len, 5);
    try expectEqual(tuple[0], true);
    try expectEqual(tuple[1], 19);
    try expectEqual(tuple[2], 3.14);
    try expectEqual(tuple[3], 'A');
    try expectEqual(tuple[4], "hello");
    try expectEqual(tuple.@"4", "hello"); // alternate way to index

    // This loop must be "inline".
    inline for (tuple) |value| {
        const T = @TypeOf(value);
        print("type of {any} is {}\n", .{ value, T });
        // comptime must be used here because the argument
        // to isZigString must be comptime-known.
        if (comptime trait.isZigString(T)) {
            print("value is {s}\n", .{value});
        } else {
            print("value is {any}\n", .{value});
        }
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
