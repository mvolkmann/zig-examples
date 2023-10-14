const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

pub fn main() !void {
    var a = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    var b: []u8 = a[0..];
    var c: [5]u8 = a;

    a[0] = 'B';
    print("{s} {s} {s}\n", .{ a, b, c });
}
