const std = @import("std");
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
    try expectEqual(@as(i8, 4), try double(2));

    try expectError(EvalError.Negative, double(-1));

    try expectError(EvalError.TooHigh, double(101));

    // "catch" provides a value to use if *any* error is returned.
    var result = double(-1) catch @as(i8, 0);
    try expectEqual(@as(i8, 0), result);

    result = double(101) catch @as(i8, 100);
    try expectEqual(@as(i8, 100), result);

    // We can test for specific errors.
    var maybeError = double(-1);
    try expectEqual(@as(EvalError!i8, EvalError.Negative), maybeError);
    maybeError = double(101);
    try expectEqual(@as(EvalError!i8, EvalError.TooHigh), maybeError);
}

// This function differs from "double" in that in uses "errdefer"
// to provide a value to use there is an attempt to return any error.
fn doubleErrdefer(n: i8) i8 {
    errdefer 0;
    return double(n);
}

test "errdefer" {
    try expectEqual(@as(i8, 4), doubleErrdefer(2));
    try expectError(@as(i8, 0), doubleErrdefer(-1));
    try expectError(@as(i8, 0), doubleErrdefer(101));
}
