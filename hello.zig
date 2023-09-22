const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    // s for string, d for decimal
    print("Hello {s}! {d}\n", .{ "Zig", 2023 });
}
