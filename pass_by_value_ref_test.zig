const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const String = []const u8;

const Dog = struct {
    name: String,
    age: u8,
};

fn haveBirthday1(dog: *Dog) void {
    dog.age += 1;
}

fn haveBirthday2(dog: Dog) !void {
    // Cannot modify dog because it is a const copy.
    // dog.age += 1; // gives error: cannot assign to constant
    try expectEqual(dog.age, 3);
}

fn double(slice: []u8) void {
    for (slice) |*element| {
        element.* *= 2;
    }
}

test "pass by reference" {
    var dog = Dog{ .name = "Comet", .age = 3 };
    haveBirthday1(&dog); // passes a pointer
    try expectEqual(dog.age, 4); // modified

    var arr = [_]u8{ 1, 2, 3 };
    double(&arr); // must use &
    const expected = [_]u8{ 2, 4, 6 };
    try expectEqual(arr, expected);
}

test "pass by value" {
    var dog = Dog{ .name = "Comet", .age = 3 };
    try haveBirthday2(dog); // passes a const copy
    try expectEqual(dog.age, 3); // not modified
}
