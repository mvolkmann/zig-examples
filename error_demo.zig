const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const expectError = std.testing.expectError;

const EvalError = error{ Negative, TooHigh };

fn double(n: i8) EvalError!i8 {
    if (n < 0) return EvalError.Negative;
    if (n > 100) return EvalError.TooHigh;
    return n * 2;
}

test "error handling" {
    // The "try" before the call to "double"
    // causes any error returned by "double" to be returned,
    // which would cause this test to fail.
    // "try someFn();" is equivalent to "someFn() catch |err| return err;"
    // If a literal value is used for the expected value,
    // it must be cast with "@as" if it is the first argument,
    // but not if it is the second.
    // try expectEqual(@as(i8, 4), try double(2));
    try expectEqual(try double(2), 4);

    try expectError(EvalError.Negative, double(-1));

    try expectError(EvalError.TooHigh, double(101));

    // "catch" provides a value to use if *any* error is returned.
    var result = double(-1) catch @as(i8, 0);
    try expectEqual(result, 0);

    result = double(101) catch @as(i8, 100);
    try expectEqual(result, 100);

    // We can test for specific errors.
    try expectEqual(double(-1), EvalError.Negative);
    try expectEqual(double(101), EvalError.TooHigh);
}

// This function differs from "double" in that in uses "errdefer"
// to provide a value to use there is an attempt to return any error.
// Defer expressions cannot use the "return" keyword.
fn doubleErrdefer(n: i8) EvalError!i8 {
    errdefer print("double returned an error for {d}\n", .{n});
    return double(n);
}

test "errdefer" {
    try expectEqual(doubleErrdefer(2), 4);
    try expectEqual(doubleErrdefer(-1), EvalError.Negative);
    try expectEqual(doubleErrdefer(101), EvalError.TooHigh);
}
