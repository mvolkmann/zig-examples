const std = @import("std");
const print = std.debug.print;

const Dog = struct { name: []const u8, breed: []const u8, age: u8 };

pub fn main() void {
    var dog = Dog{ .name = "Comet", .breed = "whippet", .age = 3 };
    const dogPtr = &dog;
    print("name = {s}\n", .{dog.name});
    print("name = {s}\n", .{dogPtr.*.name});

    // Pointers can only be used to modify a struct property
    // if the struct instance is not const.
    dogPtr.*.name = "Oscar";
    print("name = {s}\n", .{dog.name});

    var number: u8 = 1;
    print("number = {d}\n", .{number}); // 1

    // Shorthand operators can be used to
    // modify the value referenced by a pointer.
    const numberPtr = &number;
    numberPtr.* += 1;
    print("number = {d}\n", .{number}); // 2
}
