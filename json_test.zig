const std = @import("std");
const print = std.debug.print;
const my_allocator = std.testing.allocator;
const expectEqual = std.testing.expectEqual;
const String = []const u8;

const Place = struct {
    lat: f32,
    long: f32,
};

// T cannot contain any comptime fields, so
// anonymous structs with numeric values won't work.
fn fromJSON(T: anytype, allocator: std.mem.Allocator, json: String) !T {
    const parsed = try std.json.parseFromSlice(T, allocator, json, .{});
    defer parsed.deinit();
    return parsed.value;
}

fn toJSON(allocator: std.mem.Allocator, value: anytype) !String {
    // The ArrayList that will grow as needed.
    var out = std.ArrayList(u8).init(allocator); // cannot be const
    defer out.deinit();
    try std.json.stringify(value, .{}, out.writer());
    return try out.toOwnedSlice(); // empties the ArrayList
}

test "json" {
    const place1 = Place{
        .lat = 51.997664,
        .long = -0.740687,
    };

    const json = try toJSON(my_allocator, place1);
    defer my_allocator.free(json);

    const place2 = try fromJSON(Place, my_allocator, json);
    try expectEqual(place1, place2);
}
