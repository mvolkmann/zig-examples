const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const String = []const u8;

test "optional" {
    var a: i8 = 0; // not optional
    // Placing "?" before a type makes it optional.
    // Only optional variables can be set to "null".
    var b: ?i8 = null;

    try expectEqual(a, 0);
    try expectEqual(b, null);

    a = 1;
    b = 2;
    try expectEqual(a, 1);
    try expectEqual(b, 2);

    // This form of "if" statement can only be used with optional values.
    // If non-null, the unwrapped value is placed in value.
    if (b) |value| {
        try expectEqual(value, 2);
    } else {
        unreachable; // verifies that b is non-null
    }

    // The orelse operator unwraps the value if non-null
    // and uses the value that follows if null.
    // This is why the cast here is to i8 instead of ?i8.
    try expectEqual(b orelse 0, 2);

    // "b.?" is equivalent to "b orelse unreachable".
    // It unwraps the value which is why the cast here is to i8 instead of ?i8.
    try expectEqual(b.?, 2);

    b = null;
    try expectEqual(b, null);
    try expectEqual(b orelse 0, 0);
    // _ = b.?; // results in "panic: attempt to use null value"

    if (b) |_| { // not using the unwrapped value
        unreachable; // verifies that b is null
    } else {
        try expectEqual(b, null);
    }
}

// This is a struct with optional fields.
const Dog = struct {
    name: ?String = null,
    breed: ?String = null,
};

// This demonstrates using the orelse operator
// which unwraps the value if non-null
// and uses the value that follows if null.
fn present(dog: Dog) String {
    return dog.name orelse dog.breed orelse "unknown";
}

test "struct with optional fields" {
    const dog1 = Dog{ .name = "Comet", .breed = "Whippet" };
    const dog2 = Dog{ .name = "Oscar" };
    const dog3 = Dog{ .breed = "Beagle" };
    const dog4 = Dog{};
    const dogs = [_]Dog{ dog1, dog2, dog3, dog4 };

    try expectEqual(dog1.name, "Comet");
    try expectEqual(dog1.breed, "Whippet");

    try expectEqual(dog2.name, "Oscar");
    try expectEqual(dog2.breed, null);

    try expectEqual(dog3.name, null);
    try expectEqual(dog3.breed, "Beagle");

    try expectEqual(dog4.name, null);
    try expectEqual(dog4.breed, null);

    try expectEqual(present(dog1), "Comet");
    try expectEqual(present(dog2), "Oscar");
    try expectEqual(present(dog3), "Beagle");
    try expectEqual(present(dog4), "unknown");

    // The output from this loop should be:
    // name = Comet
    // breed = Whippet
    // present = Comet
    // name = Oscar
    // present = Oscar
    // breed = Beagle
    // present = Beagle
    // present = unknown
    for (dogs) |dog| {
        if (dog.name) |name| print("name = {s}\n", .{name});
        if (dog.breed) |breed| print("breed = {s}\n", .{breed});
        print("present = {s}\n", .{present(dog)});
    }
}
