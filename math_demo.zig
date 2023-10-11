const std = @import("std");
const print = std.debug.print;
const divExact = std.math.divExact;
const expectEqual = std.testing.expectEqual;

test "@divExact" {
    try expectEqual(@divExact(10, 0), 5);
}

pub fn main() !void {
    // const result = @divExact(10, 0);
    // const result = @divFloor(10, 0) catch 0;
    // const result = @divTrunc(10, 0);
    const numerator: i8 = 5;
    const denominator: i8 = 0;

    // This shows four approaches to handling errors.
    // It assumes that std.math.divExact can return multiple kinds of errors
    // which is probably can't.

    // const result = divExact(i8, numerator, denominator) catch |err| blk: {
    //     print("err = {}\n", .{err});
    //     break :blk 0;
    // };

    // const result = divExact(i8, numerator, denominator) catch |err|
    //     if (err == error.DivisionByZero) @as(i8, 0) else return err;

    // const result = divExact(i8, numerator, denominator) catch |err| blk: {
    //     break :blk if (err == error.DivisionByZero) @as(i8, 0) else return err;
    // };

    const result = divExact(i8, numerator, denominator) catch |err| switch (err) {
        error.DivisionByZero => @as(i8, 0),
        else => return err,
    };

    print("result = {d}\n", .{result});
}
