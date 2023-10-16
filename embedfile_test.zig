const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;

test "embedFile" {
    const data = @embedFile("./file_io/data.txt");
    try expectEqualStrings(data, "Hello, World!");
}
