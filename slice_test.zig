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

    // This slice is mutable.
    var slice2 = array[2..4];
    // The slice and array share memory,
    // so modifying one also modifies the other.
    slice2[0] = 30;
    try expectEqual(array[2], 30);
    array[3] = 40;
    try expectEqual(slice2[1], 40);

    // array[7] = 0; // error: index 7 outside array of length 5
    // slice[8] = 0; // error: index 8 outside array of length 2
}
