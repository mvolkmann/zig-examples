const std = @import("std");
const base_allocator = std.testing.allocator;
const expectEqual = std.testing.expectEqual;

const String = []const u8;

const Animal = struct {
    name: String,
    top_speed: u32, // miles per hour
};

const Car = struct {
    make: String,
    model: String,
    year: u16,
    top_speed: u32, // miles per hour
};

fn travelTime(thing: anytype, distance: u32) u32 {
    return distance / thing.top_speed;
}

test "anytype" {
    const cheetah = Animal{
        .name = "cheetah",
        .top_speed = 75,
    };

    const ferrari = Car{
        .make = "Ferrari",
        .model = "F40",
        .year = 1992,
        .top_speed = 201,
    };

    try expectEqual(travelTime(cheetah, 20), 1);
    try expectEqual(travelTime(ferrari, 20), 1);
}
