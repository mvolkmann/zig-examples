const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn touchdown(score_ptr: *u8, extraPoint: bool) !void {
    const current = score_ptr.*;
    score_ptr.* += 6;
    try expectEqual(score_ptr.*, current + 6);
    if (extraPoint) score_ptr.* += 1;
}

test "primitive pointers" {
    var score: u8 = 3;
    // Only need try here because touchdown uses expectEqual.
    try touchdown(&score, true);
    try expectEqual(score, 10);
}

const Dog = struct { name: []const u8, breed: []const u8, age: u8 };

test "struct pointers" {
    var dog = Dog{ .name = "Comet", .breed = "whippet", .age = 3 };
    const dog_ptr = &dog; // single-item pointer
    try expectEqual(dog.name, "Comet");
    try expectEqual(dog_ptr.*.name, "Comet");
    try expectEqual(dog_ptr.name, "Comet"); // automatic dereferencing

    // Pointers can only be used to modify a struct property
    // if the struct instance is not const.
    dog_ptr.*.name = "Oscar";
    try expectEqual(dog.name, "Oscar");

    // Create an array of Dog instances.
    var dogs = [_]Dog{
        .{ .name = "Comet", .breed = "whippet", .age = 3 },
        .{ .name = "Oscar", .breed = "whippet", .age = 7 },
    };
    // Iterate over the dogs and increment their age.
    // &dogs gives a many-item pointer.
    for (&dogs) |*d| {
        // d.*.age += 1; // This works.
        d.age += 1; // But this also works and is shorter.
        // In C we could use "d->age++;",
        // but Zig only uses ++ to concatenate arrays.
    }
    try expectEqual(dogs[0].age, 4);
    try expectEqual(dogs[1].age, 8);
}
