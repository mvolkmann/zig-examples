const std = @import("std");
const print = std.debug.print;
const base_allocator = std.testing.allocator;
const expectEqual = std.testing.expectEqual;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;

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

const Bad = struct {
    top_speed: f32, // not expected type of u32
};

fn travelTime(thing: anytype, distance: u32) !f32 {
    // We could use @TypeOf(thing) and functions like
    // std.meta.trait.hasField and std.meta.trait.isIntegral
    // to verify that "thing" meets our criteria.
    // However, there is no need to do that because the compiler will
    // verify that "thing" has a "top_speed" field that is an integer
    // just because it is used that way here.
    const s: f32 = @floatFromInt(thing.top_speed);

    // We can't eliminate the local variable d because
    // @floatFromInt requires that we specify the result type.
    const d: f32 = @floatFromInt(distance);

    return d / s;
}

test "anytype" {
    const cheetah = Animal{
        .name = "cheetah",
        .top_speed = 75,
    };
    const distance = 20; // miles
    const tolerance = 0.001;
    try expectApproxEqAbs(
        try travelTime(cheetah, distance),
        0.2667,
        tolerance,
    );

    const ferrari = Car{
        .make = "Ferrari",
        .model = "F40",
        .year = 1992,
        .top_speed = 201,
    };
    try expectApproxEqAbs(
        try travelTime(ferrari, distance),
        0.0995,
        tolerance,
    );

    // The travelTime function requires its first argument
    // to be a struct with a top_speed field that is an integer.

    // This results in a compile error which is good because
    // the first argument is struct whose top_speed field is not an integer.
    // const bad = Bad{ .top_speed = 1.0 };
    // _ = try travelTime(bad, distance);

    // This results in a compile error which is good because
    // the first argument is not a struct with a "top_speed" field.
    // _ = try travelTime("wrong", distance);
}
