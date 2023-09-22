const std = @import("std");
const print = std.debug.print;

// The value of the first argument to print must be known at compile time.
fn log(comptime text: []const u8) void {
    print(text ++ "\n", .{});
}

pub fn main() !void {
    // prng is short for pseudo random number generator.
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        // try can only be used inside a function.
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    // Generate a random integer from 1 to 3.
    const value = prng.random().intRangeAtMost(u8, 1, 3);
    print("value = {}\n", .{value});

    if (value == 1) {
        log("one");
    } else if (value == 2) {
        log("two");
    } else {
        log("other");
    }
}
