const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;

// Squares any kind of number, returning the same type.
// Calls with a non-number do not compile
// because the "*" cannot be applied to them.
fn square(x: anytype) @TypeOf(x) {
    return x * x;
}

test "function return type inference" {
    const n: i8 = 2;
    try expectEqual(square(n), 4);

    const x: f32 = 3.1;
    try expectApproxEqAbs(square(x), 9.61, 0.001);
}
