const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;

const Dog = struct {
    name: []const u8,
    age: u8,
};

test "fixedBufferStream" {
    const dogs = [_]Dog{
        .{ .name = "Rex", .age = 5 },
        .{ .name = "Fido", .age = 3 },
    };

    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    const stream = fbs.writer();

    for (dogs) |dog| {
        try stream.print("{s} ", .{dog.name});
    }

    try expectEqualStrings("Rex Fido ", &buffer);
}
