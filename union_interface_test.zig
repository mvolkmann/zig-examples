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

const Shape = union(enum) {
    circle: Circle,
    rectangle: Rectangle,
    square: Square,

    // Think of this as an interface method.
    // We can call this method on any member of
    // the containing union that has an "area" method.
    pub fn area(self: Shape) f32 {
        switch (self) {
            // "inline" is needed here because the actual types
            // passed as self differ (Circle, Rectangle, and Square).
            // We only have an "else" branch because
            // we want to handle call values in the same way.
            inline else => |case| return case.area(),
        }
    }
};

test "union interface" {
    const shapes = [_]Shape{
        Shape{ .circle = Circle{ .radius = 2 } },
        Shape{ .rectangle = Rectangle{ .width = 2, .height = 3 } },
        Shape{ .square = Square{ .size = 2 } },
    };

    const expected = [_]f32{ 12.5663709, 6, 4 };
    for (shapes, 0..) |shape, index| {
        try expectEqual(shape.area(), expected[index]);
    }
}
