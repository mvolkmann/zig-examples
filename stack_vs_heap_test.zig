const std = @import("std");
const String = []const u8;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const Dog = struct {
    const Self = @This();

    name: String,
    age: u8,

    pub fn init(name: String, age: u8) Self {
        return Self{ .name = name, .age = age };
    }

    pub fn initHeap(
        allocator: std.mem.Allocator,
        name: String,
        age: u8,
    ) !*Self {
        const dog_ptr = try allocator.create(Self);
        dog_ptr.* = .{ .name = name, .age = age };
        return dog_ptr;
    }
};

test "stack allocation" {
    const dog1 = Dog{ .name = "Comet", .age = 3 };
    const dog2 = Dog.init("Comet", 3);
    try expectEqualStrings(dog1.name, dog2.name);
    try expectEqual(dog1.age, dog2.age);
}

test "heap allocation" {
    const allocator = std.testing.allocator;

    // To allocate an array of objects instead of just one, use alloc method.
    const dog1 = try allocator.create(Dog);
    // To free an array of objects instead of just one, use free method.
    defer allocator.destroy(dog1);

    // dog1.name = "Comet";
    // dog1.age = 3;
    dog1.* = .{ .name = "Comet", .age = 3 };

    const dog2 = try Dog.initHeap(allocator, "Comet", 3);
    defer allocator.destroy(dog2);

    try expectEqualStrings(dog1.name, dog2.name);
    try expectEqual(dog1.age, dog2.age);
}
