const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    var b: bool = undefined;
    print("{}\n", .{b}); // prints false
    b = true;
    print("{}\n", .{b}); // prints true
    b = undefined;
    print("{}\n", .{b}); // prints false

    var x: u8 = undefined;
    print("{}\n", .{x}); // prints 170
    x = 19;
    print("{}\n", .{x}); // prints 19
    x = undefined;
    print("{}\n", .{x}); // prints 170

    var y: u32 = undefined;
    print("{}\n", .{y}); // prints 2863311530

    var z: f32 = undefined;
    print("{}\n", .{z}); // prints -3.03164882e-13

    // var s: []u8 = undefined;
    // print("{s}\n", .{s}); // panics with "reached unreachable code"

    // Cannot test whether a value is undefined like this.
    // if (b == undefined) print("b is undefined\n", .{});
}
