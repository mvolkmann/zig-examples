const std = @import("std");
const print = std.debug.print;

fn test_array_bounds(index: usize) !void {
    const dice_rolls = [_]u8{ 4, 2, 6, 1, 2 };
    // Performs bounds checking at compile-time and run-time.
    const roll = dice_rolls[index];
    print("array roll = {d}\n", .{roll});
}

fn test_slice_bounds(index: usize) !void {
    const dice_rolls = [_]u8{ 4, 2, 6, 1, 2 };
    const slice = dice_rolls[2..4];
    // Performs bounds checking at compile-time and run-time.
    const roll = slice[index];
    print("slice roll = {d}\n", .{roll});
}

pub fn main() !void {
    // prng is short for pseudo random number generator.
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        // try can only be used inside a function.
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    // Generate a random integer from 0 to 6.
    const index = prng.random().intRangeAtMost(u8, 0, 6);
    print("index = {d}\n", .{index});

    try test_array_bounds(index);
    try test_slice_bounds(index);
}
