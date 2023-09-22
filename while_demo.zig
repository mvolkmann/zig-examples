const std = @import("std");
const print = std.debug.print;

var counter: u8 = 0;
fn nextCounter() ?u8 {
    counter += 2;
    if (counter > 6) return null;
    return counter;
}

const FetchError = error{TooBig};
var count: u8 = 0;
fn fetchCount() FetchError!u8 {
    count += 2;
    return if (count > 6) FetchError.TooBig else count;
}

pub fn main() !void {
    var value: u8 = 0;

    // This loop outputs 1, 2, 3.
    while (true) {
        value += 1;
        print("{}\n", .{value});
        if (value == 3) break;
    }

    value = 0;
    // This loop outputs 1, 2, 4, 5.
    while (value < 5) {
        value += 1;
        if (value == 3) continue;

        print("{}\n", .{value});
    }

    value = 1;
    // This loop outputs 1, 2, 3.
    while (value <= 3) : (value += 1) {
        print("{}\n", .{value});
    }

    // This loop terminates when the nextCounter function returns null.
    // It outputs 2, 4, 6.
    while (nextCounter()) |c| {
        print("{}\n", .{c});
    }

    value = 0;
    // result is "triple" if value starts a 1
    // and "not found" if value starts at 0.
    const result = while (value < 10) {
        if (value == 3) break "triple";
        value += 2;
    } else "not found";
    print("result = {s}\n", .{result});

    // This loop terminates when the fetchCount function returns an error.
    // It outputs 2, 4, 6 followed by "error.TooBig".
    while (fetchCount()) |c| {
        print("{}\n", .{c});
    } else |err| {
        print("err = {}\n", .{err});
    }
}
