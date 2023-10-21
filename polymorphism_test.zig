const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Circle = struct {
    radius: f32 = 0,
    pub fn area(self: @This()) f32 {
        return std.math.pi * self.radius * self.radius;
    }
};

const Rectangle = struct {
    width: f32 = 0,
    height: f32 = 0,
    pub fn area(self: @This()) f32 {
        return self.width * self.height;
    }
};

const Square = struct {
    size: f32 = 0,
    pub fn area(self: @This()) f32 {
        return self.size * self.size;
    }
};

fn area(shape: anytype) f32 {
    return shape.*.area();
}

test "polymorphism" {
    const r = Rectangle{ .width = 2, .height = 3 };
    try expectEqual(r.area(), 6.0);
    try expectEqual(area(&r), 6.0);

    const shapes = .{
        Circle{ .radius = 2 },
        Rectangle{ .width = 2, .height = 3 },
        Square{ .size = 2 },
    };

    const expected = [_]f32{ 12.5663706, 6.0, 4.0 };

    // Must be inline to iterate over a tuple.
    inline for (shapes, 0..) |shape, index| {
        try expectEqual(area(&shape), expected[index]);
    }
}
