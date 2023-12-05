const std = @import("std");
const print = std.debug.print;
const String = []const u8;

// The value of the first argument to print must be known at compile time.
fn log(comptime text: String) void {
    // print(text ++ "\n", .{});
    print("{s}\n", .{text});
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
    const value = prng.random().intRangeAtMost(u8, 1, 10);
    print("value = {}\n", .{value});

    switch (value) {
        1 => log("one"),

        // Double-dot ranges have an exclusive upper bound.
        // Triple-dot ranges have an inclusive upper bound.
        2...5 => { // braces are only required for multiple statements
            log("two to five");
        },

        6, 8, 10 => {
            log("six, eight, or ten");
        },

        else => log("other"),
    }

    // This demonstrates using a switch as an expression.
    const result = switch (value) {
        0 => "none",
        1 => "single",
        2 => "couple",
        3 => "few",
        else => "many",
    };
    print("result = {s}\n", .{result});

    // This demonstrates switching on an enum.
    const Color = enum { red, green, blue };
    // var favorite = Color.blue;
    var favorite: Color = .blue;
    switch (favorite) {
        .red => log("hot"),
        .green => log("warm"),
        .blue => log("cold"),
    }

    switch (getItemCount()) {
        0 => log("You have no items.\n"),
        1...7 => |count| print(
            "You have {} items and can use the express lane.\n",
            .{count},
        ),
        // 3...9 => print("overlapping\n", .{}), // not allowed
        else => |count| print(
            "You have {} items and cannot use the express lane.\n",
            .{count},
        ),
    }

    // A left-side value of switch branch can come from a function call.
    const game = "blackjack";
    const score = 21;
    switch (score) {
        highestScore(game) => log("You have the highest score."),
        else => print("Your score is {}.\n", .{score}),
    }
}

fn highestScore(game: String) u32 {
    if (std.mem.eql(u8, game, "bowling")) return 300;
    if (std.mem.eql(u8, game, "blackjack")) return 21;
    return 0; // unknown
}

fn getItemCount() u32 {
    return 8;
}
