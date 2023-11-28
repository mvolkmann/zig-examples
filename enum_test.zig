const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// A type must be specified for an enum
// in order to override its default ordinal values.
const Color = enum(u8) {
    red, // defaults to 0
    yellow, // assigned 1
    blue = 7, // overrides default of 2
    green, // assigned 8

    const favorite = Color.yellow;

    // pub fn isPrimary(self: Color) bool {
    //     return self == Color.red or self == Color.yellow or self == Color.blue;
    // }

    const Self = @This();
    pub fn isPrimary(self: Self) bool {
        return self == Self.red or self == Self.yellow or self == Self.blue;
    }
};

const Sport = enum(i32) {
    baseball = 10,
    basketball = 20,
    football = 30,
    hockey = 40,
    soccer = 50,
};

test "enum" {
    const c = Color.green;
    print("c = {}\n", .{c}); // enum_demo.main.Color.green

    try expectEqual(@intFromEnum(c), 8);
    const color: Color = @enumFromInt(8);
    try expectEqual(color, Color.green);
    try expectEqual(Color.yellow, Color.favorite);
    try expect(!c.isPrimary());
    try expect(!Color.isPrimary(c));
    try expect(Color.yellow.isPrimary());

    print("hockey = {}\n", .{@intFromEnum(Sport.hockey)});
}
