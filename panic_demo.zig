const std = @import("std");

// The "unreachable" statement causes a panic.
// pub fn main() void {
//     const value = 1;
//     if (value == 1) {
//         unreachable;
//     }
// }

// Returning any error from main causes a panic.
pub fn main() !void {
    const value = 1;
    if (value == 1) {
        return error.InvalidInput;
    }
}
