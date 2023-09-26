const std = @import("std");
const print = std.debug.print;
const sqrt = std.math.sqrt;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// TODO: Is there an efficiency gain from this
// TODO: more complex way to get the square function?
// fn createSquareFn(comptime T: type) fn (T) T {
//     // For why a struct is created and then only one field is returned, see
//     // https://github.com/ziglang/zig/issues/1717#issuecomment-1627790251.
//     return struct {
//         fn f(n: T) T {
//             return std.math.pow(T, n, 2);
//         }
//     }.f; // returns the f field of the struct
// }

// const square = createSquareFn(f32);

fn square(n: f32) f32 {
    return std.math.pow(f32, n, 2);
}

const Point = struct {
    x: f32 = 1,
    y: f32 = 2,

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
    const p0 = Point{};
    print("p0 = {}\n", .{p0});

    const py = Point{ .y = 19 };
    print("py = {}\n", .{py});

    const p1 = Point{ .x = 3, .y = 4 };
    try expect(p1.distanceToOrigin() == 5);

    const p2 = Point{ .x = 6, .y = 8 };
    try expect(p1.distanceTo(p2) == 5);
    try expect(Point.distanceTo(p1, p2) == 5);

    // This iterates over all the fields of the Point struct,
    // prints the name, the type, and the value in the p1 instance.
    print("\n", .{});
    // TODO: Why does this only work with "inline"?
    inline for (std.meta.fields(@TypeOf(p1))) |field| {
        print("found field {s} with type {s}\n", .{ field.name, @typeName(field.type) });
        print("value in p1 is {}\n", .{@as(field.type, @field(p1, field.name))});
    }
}

test "anonymous struct" {
    const not_used = 5;
    _ = not_used;

    const instance = .{
        .key1 = true, // type is bool
        .key2 = 19, // type is comptime_int
        .key3 = 'x', // type is comptime_int (value is 120)
        .key4 = "text", // type is *const [4:0]u8; 0 is the alignment
    };

    try expectEqual(bool, @TypeOf(instance.key1));
    try expectEqual(true, instance.key1);

    try expectEqual(comptime_int, @TypeOf(instance.key2));
    try expectEqual(19, instance.key2);

    try expectEqual(comptime_int, @TypeOf(instance.key3));
    try expectEqual('x', instance.key3);

    try expectEqual(*const [4:0]u8, @TypeOf(instance.key4));
    try expectEqual("text", instance.key4);
}
