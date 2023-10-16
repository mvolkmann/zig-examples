const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;

const data = @embedFile("./file_io/data.txt");

test "embedFile" {
    try expectEqualStrings(data, "Hello, World!");
}
