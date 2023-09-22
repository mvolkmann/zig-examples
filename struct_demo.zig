const std = @import("std");
const print = std.debug.print;
const sqrt = std.math.sqrt;
const expect = std.testing.expect;

fn createSquareFn(comptime T: type) fn (T) T {
    // For why a struct is created and then only one field is returned, see
    // https://github.com/ziglang/zig/issues/1717#issuecomment-1627790251.
    return struct {
        fn f(n: T) T {
            return std.math.pow(T, n, 2);
        }
    }.f; // returns the f field of the struct
}

const square = createSquareFn(f32);

const Point = struct {
    x: f32,
    y: f32,

    pub fn distanceToOrigin(self: Point) f32 {
        return sqrt(square(self.x) + square(self.y));
    }

    pub fn distanceTo(self: Point, other: Point) f32 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        return sqrt(square(dx) + square(dy));
    }
};

test "Point struct" {
    const p1 = Point{ .x = 3, .y = 4 };
    try expect(p1.distanceToOrigin() == 5);

    const p2 = Point{ .x = 6, .y = 8 };
    try expect(p1.distanceTo(p2) == 5);
    try expect(Point.distanceTo(p1, p2) == 5);
}
