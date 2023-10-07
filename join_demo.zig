const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;
const allocator = std.testing.allocator;

test "join" {
    const colors = .{ "red", "green", "blue" };
    const joined = try std.mem.join(allocator, "-", &colors);
    defer allocator.free(joined);
    try expectEqualStrings("red-green-blue", joined);
}
