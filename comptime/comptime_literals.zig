const std = @import("std");
const print = std.debug.print;

const my_int = 19;
const my_float = 3.14;

pub fn main() !void {
    print("my_int type is {}\n", .{@TypeOf(my_int)}); // comptime_int
    print("my_float type is {}\n", .{@TypeOf(my_float)}); // comptime_float
}
