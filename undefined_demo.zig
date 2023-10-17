const std = @import("std");

pub fn main() void {
    var b: bool = undefined;
    std.debug.print("{}\n", .{b}); // prints false
    b = true;
    std.debug.print("{}\n", .{b}); // prints true
    b = undefined;
    std.debug.print("{}\n", .{b}); // prints false

    var x: u8 = undefined;
    std.debug.print("{}\n", .{x}); // prints 170
    x = 19;
    std.debug.print("{}\n", .{x}); // prints 19
    x = undefined;
    std.debug.print("{}\n", .{x}); // prints 170

    var y: u32 = undefined;
    std.debug.print("{}\n", .{y}); // prints 2863311530

    var z: f32 = undefined;
    std.debug.print("{}\n", .{z}); // prints -3.03164882e-13

    // var s: []u8 = undefined;
    // std.debug.print("{s}\n", .{s}); // panics with "reached unreachable code"
}
