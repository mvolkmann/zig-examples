const std = @import("std");
const sqrt = std.math.sqrt;

fn square(n: f32) f32 {
    return std.math.pow(f32, n, 2);
}

pub const Point = struct {
    // This is a constant because it is "pub const".
    pub const dimensions = 2;

    x: f32 = 1, // default value
    y: f32 = 2, // default value

    const Self = @This(); // reference to containing struct

    // Defining an init function is optional.
    pub fn init(x: f32, y: f32) Self {
        return Self{ .x = x, .y = y };
    }

    // This is a method because it is "pub" and
    // takes an instance of the struct as its first argument.
    pub fn distanceToOrigin(self: Self) f32 {
        return sqrt(square(self.x) + square(self.y));
    }

    pub fn distanceTo(self: Self, other: Self) f32 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        return sqrt(square(dx) + square(dy));
    }

    // This function is called on the struct name instead of an instance
    // because its first parameter is not an instance.
    // Invoke this with Point.identify("I am a");
    // to print "I am a Point."
    pub fn identify(prefix: []const u8) void {
        std.debug.print("{s} Point.\n", .{prefix});
    }

    // Taking pointer to struct enables modification.
    pub fn translate(pt: *Self, dx: f32, dy: f32) void {
        pt.x += dx;
        pt.y += dy;
    }
};
