const std = @import("std");
const print = std.debug.print;
const String = []const u8;

const Rank = enum(u8) {
    Ace = 1,
    Two = 2,
    Three = 3,
    Four = 4,
    Five = 5,
    Six = 6,
    Seven = 7,
    Eight = 8,
    Nine = 9,
    Ten = 10,
    Jack = 11,
    Queen = 12,
    King = 13,
};

const Suit = enum(u8) {
    Spades = 0,
    Hearts = 1,
    Clubs = 2,
    Diamonds = 3,
};

const Card = struct {
    suit: Suit,
    rank: Rank,
};

const deck_size: u8 = 52;
var deck: [deck_size]Card = undefined;
var next_card_index: u8 = 0;
const suits = [_]String{ "♠", "♥", "♣", "♦" };

fn fillDeck() !void {
    var card_index: u8 = 0;
    for (1..14) |rank_number| {
        const rank: Rank = @enumFromInt(rank_number);
        for (0..4) |suit_number| {
            const suit: Suit = @enumFromInt(suit_number);
            deck[card_index] = Card{ .rank = rank, .suit = suit };
            card_index += 1;
        }
    }

    // Shuffle the deck.
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed)); // can't call at comptime
    var prng = std.rand.DefaultPrng.init(seed);
    prng.random().shuffle(Card, &deck);
}

fn deal() ?Card {
    if (next_card_index >= deck_size) return null;
    const card = deck[next_card_index];
    next_card_index += 1;
    return card;
}

fn play() String {
    var score: u8 = 0;
    return while (deal()) |card| {
        printCard(card);
        const value = @intFromEnum(card.rank);
        score += if (value == 1 and score + 11 <= 21) 11 else if (value >= 10) 10 else value;
        if (score == 21) break "blackjack";
        if (score > 21) break "bust";
        if (score >= 17) break "stick";
    } else "out of cards";
}

fn printCard(card: Card) void {
    const suit_string = suits[@intFromEnum(card.suit)];
    const rank_value = @intFromEnum(card.rank);
    if (rank_value >= 2 and rank_value <= 10) {
        print("{d}", .{rank_value});
    } else {
        print("{c}", .{@tagName(card.rank)[0]});
    }
    print("{s} ", .{suit_string});
}

pub fn main() !void {
    try fillDeck();
    while (true) {
        const decision = play();
        print("{s}\n", .{decision});
        if (std.mem.eql(u8, decision, "out of cards")) break;
    }
}
