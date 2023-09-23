const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    var value: i32 = undefined;
    print("{}\n", .{value + 1});

    const limit = 5;
    // const limit = @as(i8, 5);
    print("{d} is a {s}\n", .{ limit, @typeName(@TypeOf(limit)) });
}
