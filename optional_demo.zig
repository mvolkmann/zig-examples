const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const String = []const u8;

test "optional" {
    var a: i8 = 0; // not optional
    // Placing "?" before a type makes it optional.
    // Only optional variables can be set to "null".
    var b: ?i8 = null;

    //TODO: Why does Zig require casting the 0 and null values here?
    try expectEqual(@as(i8, 0), a);
    try expectEqual(@as(?i8, null), b);

    a = 1;
    b = 2;
    try expectEqual(@as(i8, 1), a);
    try expectEqual(@as(?i8, 2), b);

    // This form of "if" statement can only be used with optional values.
    // If non-null, the unwrapped value is placed in value.
    if (b) |value| {
        try expectEqual(@as(i8, 2), value);
    } else {
        unreachable; // verifies that b is non-null
    }

    // The orelse operator unwraps the value if non-null
    // and uses the value that follows if null.
    // This is why the cast here is to i8 instead of ?i8.
    try expectEqual(@as(i8, 2), b orelse 0);

    // "b.?" is equivalent to "b orelse unreachable".
    // It unwraps the value which is why the cast here is to i8 instead of ?i8.
    try expectEqual(@as(i8, 2), b.?);

    b = null;
    try expectEqual(@as(?i8, null), b);
    try expectEqual(@as(i8, 0), b orelse 0);
    // _ = b.?; // results in "panic: attempt to use null value"

    if (b) |_| { // not using the unwrapped value
        unreachable; // verifies that b is null
    } else {
        try expectEqual(@as(?i8, null), b);
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

    try expectEqual(@as(?String, "Comet"), dog1.name);
    try expectEqual(@as(?String, "Whippet"), dog1.breed);

    try expectEqual(@as(?String, "Oscar"), dog2.name);
    try expectEqual(@as(?String, null), dog2.breed);

    try expectEqual(@as(?String, null), dog3.name);
    try expectEqual(@as(?String, "Beagle"), dog3.breed);

    try expectEqual(@as(?String, null), dog4.name);
    try expectEqual(@as(?String, null), dog4.breed);

    //TODO: Why is the cast to String necessary here?
    try expectEqual(@as(String, "Comet"), present(dog1));
    try expectEqual(@as(String, "Oscar"), present(dog2));
    try expectEqual(@as(String, "Beagle"), present(dog3));
    try expectEqual(@as(String, "unknown"), present(dog4));

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
