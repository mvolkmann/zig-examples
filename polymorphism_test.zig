const std = @import("std");
const print = std.debug.print;
const trait = std.meta.trait;
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

fn anyArea(shape: anytype) f32 {
    // This comptime block isn't necessary, but it provides documentation
    // about the expectations on the shape type.
    comptime {
        if (!trait.isPtrTo(.Struct)(@TypeOf(shape))) {
            @compileError("shape must be a pointer to a struct");
        }
        if (!trait.hasFn("area")(@TypeOf(shape.*))) {
            @compileError("shape must have an area method");
        }
    }
    return shape.area();
}

test "polymorphism with anytype" {
    const r = Rectangle{ .width = 2, .height = 3 };
    try expectEqual(r.area(), 6.0);
    try expectEqual(anyArea(&r), 6.0);

    const shapes = .{
        Circle{ .radius = 2 },
        Rectangle{ .width = 2, .height = 3 },
        Square{ .size = 2 },
    };

    const expected = [_]f32{ 12.5663706, 6.0, 4.0 };

    inline for (shapes, 0..) |shape, index| {
        try expectEqual(anyArea(&shape), expected[index]);
    }

    // This demonstrates the error "shape must be a pointer to a struct".
    // const area = anyArea(Square{ .size = 2 });
    // try expectEqual(area, 4);
}

const Shape = union(enum) {
    circle: Circle,
    rectangle: Rectangle,
    square: Square,
};

fn shapeArea(shape: *const Shape) f32 {
    return switch (shape.*) {
        .circle => |c| c.area(),
        .rectangle => |r| r.area(),
        .square => |s| s.area(),
    };
}

test "polymorphism with union" {
    const shapes = [_]Shape{
        .{ .circle = Circle{ .radius = 2 } },
        .{ .rectangle = Rectangle{ .width = 2, .height = 3 } },
        .{ .square = Square{ .size = 2 } },
    };

    const expected = [_]f32{ 12.5663706, 6.0, 4.0 };

    for (shapes, 0..) |shape, index| {
        try expectEqual(shapeArea(&shape), expected[index]);
    }
}
