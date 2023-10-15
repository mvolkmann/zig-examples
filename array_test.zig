const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;

test "arrays" {
    // Create a mutable array so it can be modified later.
    var dice_rolls = [_]u8{ 4, 2, 6, 1, 2 };
    try expectEqual(dice_rolls.len, 5);

    // Use a for loop to iterate over the items in an array or slice.
    // A for loop can iterate over multiple arrays at the same time.
    // This is being used to iterate over the array elements AND their indices.
    for (dice_rolls, 0..) |roll, index| {
        try expectEqual(roll, dice_rolls[index]);
    }

    // Copy an array.
    const copy: [5]u8 = dice_rolls;
    try expectEqual(copy[0], dice_rolls[0]);
    try expect(&copy != &dice_rolls);

    // Get a slice of an array.
    const subset = dice_rolls[2..4];
    var expected_subset = [_]u8{ 6, 1 };
    try expectEqualSlices(u8, &expected_subset, subset);

    // Modify array items in-place.
    for (&dice_rolls) |*roll| {
        roll.* += 1;
        if (roll.* > 6) roll.* = 1;
    }
    // print("{any}\n", .{dice_rolls});
    const expected_modifications = [_]u8{ 5, 3, 1, 2, 3 };
    try expectEqualSlices(u8, &expected_modifications, &dice_rolls);

    // Concatenate two arrays.
    const more_rolls = [_]u8{ 1, 2, 3 };
    const combined_rolls = dice_rolls ++ more_rolls;
    const expected_combined = [_]u8{ 5, 3, 1, 2, 3, 1, 2, 3 };
    try expectEqualSlices(u8, &expected_combined, &combined_rolls);

    // Arrays have a fixed length that cannot be changed.
    // For a dynamically-sized array, use std.ArrayList.
}
