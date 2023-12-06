const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const Point = @import("Point.zig").Point;

pub fn main() !void {
    std.debug.print("Run this as a test.", .{});
}

test "Point struct" {
    try expectEqual(Point.dimensions, 2); // constant value

    var p1 = Point{}; // uses default values for x and y
    try expectEqual(p1.x, 1);
    try expectEqual(p1.y, 2);

    const p2 = Point{ .y = 3 }; // uses default value for x
    try expectEqual(p2.x, 1);
    try expectEqual(p2.y, 3);

    const p3 = Point{ .x = 3, .y = 4 };
    // Two ways to call a method.
    try expectEqual(p3.distanceToOrigin(), 5);
    try expectEqual(Point.distanceToOrigin(p3), 5);

    const p4 = Point.init(6, 8);
    try expectEqual(p3.distanceTo(p4), 5);
    try expectEqual(Point.distanceTo(p3, p4), 5);

    // This iterates over all the fields of the Point struct,
    // prints the name, the type, and the value in the p1 instance.
    print("\n", .{});
    // This must be inline because the types of the values
    // returned by std.meta.fields are not all the same.
    inline for (std.meta.fields(@TypeOf(p1))) |field| {
        print("found field {s} with type {s}\n", .{ field.name, @typeName(field.type) });
        print("value in p1 is {}\n", .{@as(field.type, @field(p1, field.name))});
    }

    // Passing a pointer so the struct instance can be modified.
    p1.translate(2, 3);
    try expectEqual(p1.x, 3);
    try expectEqual(p1.y, 5);
}
