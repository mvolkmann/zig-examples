const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;

test "bufPrint" {
    var buffer: [20]u8 = undefined;
    const result = try std.fmt.bufPrint(
        &buffer,
        "{d} {s} {d}",
        .{ 'A', "Hello", 19 },
    );
    try expectEqualStrings("65 Hello 19", result);
}

test "fixedBufferStream" {
    var buffer: [20]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var writer = fbs.writer();
    _ = try writer.write("one"); // returns # of bytes written
    try writer.print("-{s}", .{"two"});
    try writer.print("-{s}", .{"three"});
    try expectEqualStrings("one-two-three", fbs.getWritten());
}
