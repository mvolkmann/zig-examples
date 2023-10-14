const std = @import("std");
const print = std.debug.print;

// The "unreachable" statement causes a panic.
// pub fn main() void {
//     const value = 1;
//     if (value == 1) {
//         unreachable;
//     }
// }

const EvalError = error{ Negative, TooHigh };

fn double(n: i8) EvalError!i8 {
    if (n < 0) return EvalError.Negative;
    if (n > 100) return EvalError.TooHigh;
    return n * 2;
}

// fn double(n: i32) !i32 {
//     if (n < 0) return error.Negative;
//     if (n > 100) return error.TooHigh;
//     return n * 2;
// }

// Returning any error from main causes a panic.
pub fn main() !void {
    var result = try double(4);
    print("result = {d}\n", .{result});
    result = try double(-1);
    print("result = {d}\n", .{result});
    result = try double(101);
    print("result = {d}\n", .{result});
}
