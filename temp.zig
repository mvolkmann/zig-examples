const std = @import("std");
const print = std.debug.print;

fn getIndex() u8 {
    return 8;
}

pub fn main() !void {
    // const score: u32 = 10;
    // std.debug.print("{}\n", score);

    var dice_rolls = [_]u8{0} ** 5;
    dice_rolls[2] = 6;
    std.debug.print("{any}\n", .{dice_rolls});

    var array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[2..4];
    _ = slice;

    // prng is short for pseudo random number generator.
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        // try can only be used inside a function.
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    // Generate a random integer from 0 to 10.
    const index = prng.random().intRangeAtMost(u8, 0, 10);

    print("index = {}\n", .{index});
    array[index] = 0; // error: index 7 outside array of length 5
    // slice[index] = 0; // error: index 8 outside array of length 2
}
