const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const numbers = [_]u8{ 10, 20, 30, 40, 50 };
    // This loop outputs all the numbers.
    for (numbers) |number| {
        print("{}\n", .{number});
    }

    // Create a slice from an inclusive index to an exclusive index.
    const slice = numbers[1..4];
    // This loop outputs 20, 30, 40
    // which are the numbers at index 1, 2, and 3.
    for (slice) |number| {
        print("{}\n", .{number});
    }

    // Iterate over a range of numbers where
    // the first is included and the last is not.
    // This loop outputs 10, 11, 12, 13, 14, but not 15.
    for (10..15) |number| {
        print("{}\n", .{number});
    }

    const letters = "ABCDE";
    // This loop outputs the ASCII code of each letter
    // followed by the number at the same index.
    // The letters and numbers arrays must have the same length.
    for (letters, numbers) |letter, number| {
        print("{} - {}\n", .{ letter, number });
    }

    // An open-ended range starting from zero can be iterated over
    // to output the index of each value in the numbers array.
    for (0.., numbers) |index, number| {
        print("{} - {}\n", .{ index, number });
    }

    var mutable = [_]u8{ 1, 2, 3 };
    // Iterate over a mutable array by value
    // so the items can be mutated.
    for (&mutable) |*item| {
        item.* *= 2; // doubles
    }
    const expected = [_]u8{ 2, 4, 6 };
    // If this fails, the output is "error: TestExpectedEqual"
    // followed by a stack trace.
    // It does not indicate which items are not equal.
    try std.testing.expectEqualSlices(u8, &mutable, &expected);

    // result is "triple" if the range starts a 1
    // and "not found" if the range starts at 0.
    const result = for (1..10) |value| {
        if (value == 3) break "triple";
    } else "not found";
    print("result = {s}\n", .{result});
}
