const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Dog = struct { name: []const u8, breed: []const u8, age: u8 };

test "pointers" {
    var dog = Dog{ .name = "Comet", .breed = "whippet", .age = 3 };
    const dogPtr = &dog; // single-item pointer
    try expectEqual(dog.name, "Comet");
    try expectEqual(dogPtr.*.name, "Comet");

    // Pointers can only be used to modify a struct property
    // if the struct instance is not const.
    dogPtr.*.name = "Oscar";
    try expectEqual(dog.name, "Oscar");

    var number: u8 = 1;

    // Shorthand operators can be used to
    // modify the value referenced by a pointer.
    const numberPtr = &number;
    numberPtr.* += 1;
    try expectEqual(number, 2);

    // Create an array of Dog instances.
    var dogs = [_]Dog{
        .{ .name = "Comet", .breed = "whippet", .age = 3 },
        .{ .name = "Oscar", .breed = "whippet", .age = 7 },
    };
    // Iterate over the dogs and increment their age.
    // &dogs gives a many-item pointer.
    for (&dogs) |*d| {
        // d.*.age += 1; // works
        d.age += 1; // also works and is shorter.
    }
    try expectEqual(dogs[0].age, 4);
    try expectEqual(dogs[1].age, 8);
}
