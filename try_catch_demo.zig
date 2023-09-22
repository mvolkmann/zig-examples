const std = @import("std");
const print = std.debug.print;

const DemoError = error{Demo};
fn demo(good: bool) DemoError!u8 {
    return if (good) 19 else DemoError.Demo;
}

// Only need ! in return type if errors are not caught.
pub fn main() !void {
    // Not catching possible errors.
    var result = try demo(true);
    print("result = {}\n", .{result});

    // Catching possible errors.
    // result = demo(false) catch |err| {
    result = demo(false) catch |err| {
        print("err = {}\n", .{err});
        return;
    };
    print("result = {}\n", .{result});
}
