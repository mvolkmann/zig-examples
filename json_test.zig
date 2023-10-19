const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;
const print = std.debug.print;

const Place = struct {
    lat: f32,
    long: f32,
};

test "join" {
    // Convert a struct to a JSON string.
    const x = Place{
        .lat = 51.997664,
        .long = -0.740687,
    };
    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var json = std.ArrayList(u8).init(fba.allocator());
    try std.json.stringify(x, .{}, json.writer());

    print("JSON is {s}\n", .{json.items});

    // See std.json.WriteStream to write JSON to a stream.

    // Parse the JSON string to recreate the struct.

    // try expectEqualStrings("red-green-blue", joined);
}
