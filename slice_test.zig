const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "slice" {
    var array = [_]u8{ 1, 2, 3, 4, 5 };
    try expectEqual(array.len, 5);

    // This slice is immutable.
    const slice = array[2..4];
    try expectEqual(slice.len, 2);
    try expectEqual(slice[0], array[2]);
    try expectEqual(slice[1], array[3]);

    // This slice is mutable because it was
    // created from a pointer to an array.
    const arrayPtr = &array;
    var slice2 = arrayPtr[2..4];
    // The slice and array share memory,
    // so modifying one also modifies the other.
    slice2[0] = 30;
    try expectEqual(array[2], 30);
    array[3] = 40;
    try expectEqual(array[3], 40);
}
