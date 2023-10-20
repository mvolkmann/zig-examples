const std = @import("std");
const expectEqual = std.testing.expectEqual;
const print = std.debug.print;
const allocator = std.testing.allocator;

const Place = struct {
    lat: f32,
    long: f32,
};

test "json" {
    const place1 = Place{
        .lat = 51.997664,
        .long = -0.740687,
    };

    // Convert a struct to a JSON string.
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    try std.json.stringify(place1, .{}, fbs.writer());
    const json = buffer[0..fbs.pos];
    print("JSON is {s}\n", .{json});

    // Parse the JSON string to recreate the struct.
    const parsed = try std.json.parseFromSlice(Place, allocator, json, .{});
    defer parsed.deinit();
    const place2 = parsed.value;

    try expectEqual(place1, place2);
}
