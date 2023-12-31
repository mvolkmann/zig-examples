const std = @import("std");
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

const Wrong = struct {
    top_speed: f32, // not expected type of u32
};

// The first argument must be a struct with
// a top_speed field that is an integer.
fn travelHours(thing: anytype, distance: u32) f32 {
    // The compiler will verify that "thing" has a "top_speed" field
    // that is an integer because it is used that way here.
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
        travelHours(cheetah, distance),
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
        travelHours(ferrari, distance),
        0.0995,
        tolerance,
    );

    // This results in a compile error which is good because
    // the first argument is struct whose top_speed field is not an integer.
    // const wrong = Wrong{ .top_speed = 1.0 };
    // _ = travelHours(wrong, distance);

    // This results in a compile error which is good because
    // the first argument is not a struct with a "top_speed" field.
    // _ = travelHours("wrong", distance);
}
