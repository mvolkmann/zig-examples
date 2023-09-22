const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    for (5..7) |value| {
        print("{}\n", .{value});
    }
    for (5...7) |value| {
        print("{}\n", .{value});
    }
}
