const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "arrays" {
    const dice_rolls = [_]u8{ 4, 2, 5, 1, 2 };
    try expectEqual(dice_rolls.len, 5);

    for (dice_rolls, 0..) |roll, index| {
        try expectEqual(roll, dice_rolls[index]);
    }

    const subset = dice_rolls[2..4];
    print("{s}\n", .{&subset});
}
