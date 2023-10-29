const std = @import("std");

// Build and run this with "zig build" and "zig build -Doptimize=ReleaseFast"
// to demonstrate that bounds checking is NOT performed
// when run-time safety checks are off.
pub fn main() !void {
    var numbers = [_]u8{ 1, 2, 3};

    const timestamp = std.time.microTimestamp();
    std.debug.print("timestamp = {d}\n", .{timestamp});

    const index = @mod(timestamp, 10);
    std.debug.print("index = {d}\n", .{index});

    numbers[@intCast(index)] = 0;
    std.debug.print("numbers = {any}\n", .{numbers});
}
