const std = @import("std");
const print = std.debug.print;

// []u32 is a slice which is a pointer type already.
fn sum(numbers: []const u32) u32 {
    // @setEvalBranchQuota(2000);
    var _sum: u32 = 0;
    for (numbers) |number| {
        _sum += number;
    }
    return _sum;
}

// If size >= 1000 and we don't pass a larger value
// to @setEvalBranchQuota, we get the error
// "evaluation exceeded 1000 backwards branches".
const size = 1000;
const scores: [size]u32 = .{1} ** size;

// TODO: Try to initialize like this:
// var scores: [1000]u32 = undefined;
// for (&scores, 0..) |*item, index| {
//   item.* = index % 10;
// }

// This is executed at compile-time.
const total = sum(&scores);

pub fn main() !void {
    // Since total is computed at compile-time, the generated
    // binary doesn't compute it and only has to print the total.
    print("total = {d}\n", .{total});
}
