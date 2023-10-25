const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn double(slice: []u8) void {
    for (slice) |*element| {
        element.* *= 2;
    }
}

test "pass by reference" {
    var arr = [_]u8{ 1, 2, 3 };
    double(&arr); // must use &
    const expected = [_]u8{ 2, 4, 6 };
    try expectEqual(arr, expected);
}

test "pass by value" {
    // var arr = [_]u8{ 1, 2, 3 };
    // double(arr); // doesn't compile
}
