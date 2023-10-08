const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn double(n: i8) i8 {
    return n * 2;
}

// This syntax for defining functions is not supported.
// const triple = fn(n: i8) i8 {
//     return n * 3;
// }

test "functions" {
    try expectEqual(double(2), 4);
    // try expectEqual(triple(2), 6);
}
