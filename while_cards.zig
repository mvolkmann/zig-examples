const std = @import("std");
const print = std.debug.print;
const String = []const u8;

var card_count: u8 = 52;
const cards = [_]String{ "", "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King" };

fn randomCard() !u8 {
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed)); // can't call at comptime
    var prng = std.rand.DefaultPrng.init(seed);
    return prng.random().intRangeAtMost(u8, 1, 13);
}

fn deal() !?u8 {
    if (card_count == 0) return null;
    var value = try randomCard();
    const card = cards[value];
    print("dealt {s}.\n", .{card});
    card_count -= 1;
    return value;
}

pub fn main() !void {
    var hand: u8 = 0;
    const decision = while (try deal()) |value| {
        hand += if (value == 1 and hand + 11 <= 21) 11 else value;
        if (hand == 21) break "blackjack";
        if (hand > 21) break "bust";
        if (hand >= 17) break "stick";
    } else "out of cards";
    print("decision = {s}\n", .{decision});
}
