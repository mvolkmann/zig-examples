const std = @import("std");
const print = std.debug.print;
const String = []const u8;

// The "expectEqual" function has the following signature:
// fn expectEqual(expected: anytype, actual: @TypeOf(expected)) !void
// So the second argument is cast to the type of the first.
// If the expected value is a literal value,
// it must be cast with "@as" if it is the first argument,
// but not if it is the second.
const expectEqual = std.testing.expectEqual;

const expectEqualStrings = std.testing.expectEqualStrings;

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
    // try expectEqual(@as(i8, 4), try double(2)); // requires cast
    try expectEqual(try double(2), 4); // does not require cast

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

fn safeDouble(n: i8) i8 {
    return double(n) catch |err| {
        print("safeDouble caught {}\n", .{err});
        if (err == EvalError.Negative) return 0;
        if (err == EvalError.TooHigh) return 100;
        return 0;
    };
}

test "catch" {
    try expectEqual(safeDouble(2), 4);
    try expectEqual(safeDouble(-1), 0);
    try expectEqual(safeDouble(101), 100);
}

// This function differs from "double" in that in uses "errdefer".
// Defer expressions cannot use the "return" keyword,
// but they can execute code that typically performs some kind of cleanup.
fn doubleErrdefer(n: i8) EvalError!i8 {
    errdefer print("double returned an error for {d}\n", .{n});
    return double(n);
}

test "errdefer" {
    try expectEqual(doubleErrdefer(2), 4);

    // This prints "double returned an error for -1".
    try expectEqual(doubleErrdefer(-1), EvalError.Negative);

    // This prints "double returned an error for 101".
    try expectEqual(doubleErrdefer(101), EvalError.TooHigh);
}

const ErrorData = struct {
    value: i32,
    message: String,
};

fn process(number: i32, error_out: *ErrorData) EvalError!i32 {
    if (number < 0) {
        error_out.value = number;
        error_out.message = "negative";
        return EvalError.Negative;
    }
    if (number > 100) {
        error_out.value = number;
        error_out.message = "too high";
        return EvalError.TooHigh;
    }

    return number * 2;
}

test "negative error" {
    var error_data: ErrorData = undefined;
    _ = process(-1, &error_data) catch {
        try expectEqual(error_data.value, -1);
        try expectEqualStrings(error_data.message, "negative");
        return;
    };
    unreachable;
}

test "too high error" {
    var error_data: ErrorData = undefined;
    _ = process(101, &error_data) catch {
        try expectEqual(error_data.value, 101);
        try expectEqualStrings(error_data.message, "too high");
        return;
    };
    unreachable;
}

test "success" {
    var error_data: ErrorData = undefined;
    const result = process(2, &error_data) catch {
        unreachable;
    };
    try expectEqual(result, 4);
}
