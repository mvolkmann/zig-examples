const std = @import("std");
const bufPrint = std.fmt.bufPrint;
const expectEqualStrings = std.testing.expectEqualStrings;

test "bufPrint" {
    var buffer: [20]u8 = undefined;
    const result = try bufPrint(&buffer, "{d} {s} {d}", .{ 'A', "Hello", 19 });
    try expectEqualStrings("65 Hello 19", result);
}
