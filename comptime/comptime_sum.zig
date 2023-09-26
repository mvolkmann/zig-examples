const std = @import("std");
const print = std.debug.print;

// []u32 is a slice which is a pointer type already.
fn sum(numbers: []const u32) u32 {
    var _sum: u32 = 0;
    for (numbers) |number| {
        _sum += number;
    }
    return _sum;
}

const scores = [_]u32{ 10, 20, 30, 40, 50 };

// This is executed at compile-time.
const total = sum(&scores);

pub fn main() !void {
    // Since total is computed at compile-time, the generated
    // binary doesn't compute it and only has to print 150.
    print("total = {d}\n", .{total});
}
