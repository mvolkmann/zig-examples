const std = @import("std");
const print = std.debug.print;

// Calls to this function will be inlined.
inline fn max(a: f32, b: f32) f32 {
    return if (a > b) a else b;
}

var rand_impl = std.rand.DefaultPrng.init(42);
fn randomInt() i32 {
    return rand_impl.random().int(i32);
}

pub fn main() !void {
    print("{}\n", .{max(5, 19)});

    // The array or slice iterated over by a for loop
    // must be compile-time known.
    // const scores = [_]u8{ 19, 21, 17 };
    // const scores = [_]i64{std.time.timestamp()};
    const scores = [_]i32{ randomInt(), randomInt() };
    inline for (scores) |score| {
        print("score = {}\n", .{score});
    }

    // Variables used in the condition of an "inline while" must be "comptime".
    comptime var i: u8 = 0;
    inline while (i < 3) {
        print("i = {}\n", .{i});
        i += 1;
    }
}
