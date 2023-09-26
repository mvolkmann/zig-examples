const std = @import("std");
const print = std.debug.print;

fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

fn maxInt(a: u32, b: u32) u32 {
    return max(u32, a, b);
}

pub fn main() !void {
    const result = maxInt(19, 7);
    print("result = {}\n", .{result});
}
