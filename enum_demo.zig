const std = @import("std");
const print = std.debug.print;

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

pub fn main() void {
    const c = Color.green;
    print("c = {}\n", .{c}); // enum_demo.main.Color.green
    print("c = {}\n", .{@intFromEnum(c)}); // 8
    print("green primary? {}\n", .{c.isPrimary()}); // false
    print("green primary? {}\n", .{Color.isPrimary(c)}); // false
    print("yellow primary? {}\n", .{Color.yellow.isPrimary()}); // true
}
