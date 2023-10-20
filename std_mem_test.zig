const std = @import("std");
const print = std.debug.print;
const allocator = std.testing.allocator;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

test "std.mem" {
    const s = "foo^bar^baz";
    const numbers = [_]u32{ 21, 19, 42, 7, 13 };

    try expectEqual(std.mem.count(u8, s, "^"), 2);
    try expect(std.mem.endsWith(u8, s, "baz"));
    try expect(std.mem.eql(u8, s, "foo^bar^baz"));
    try expectEqual(std.mem.indexOf(u8, s, "^"), 3);
    try expect(std.mem.startsWith(u8, s, "foo"));

    try expectEqual(std.mem.indexOfMax(u32, &numbers), 2);
    try expectEqual(std.mem.indexOfMin(u32, &numbers), 3);
    try expectEqual(std.mem.indexOfMinMax(u32, &numbers), .{ .index_min = 3, .index_max = 2 });
    try expectEqual(std.mem.indexOfScalar(u32, &numbers, 19), 1);

    const strings = [_][]const u8{ "foo", "bar", "baz" };
    const joined = try std.mem.join(allocator, "^", &strings);
    defer allocator.free(joined);
    try expectEqualStrings(joined, "foo^bar^baz");

    try expectEqual(std.mem.lastIndexOf(u8, s, "^"), 7);
    try expectEqual(std.mem.lastIndexOfScalar(u32, &numbers, 7), 3);

    try expect(std.mem.lessThan(u8, "bar", "foo"));
    try expect(!std.mem.lessThan(u8, "foo", "bar"));
    // There is no greaterThan function.

    try expectEqual(std.mem.max(u32, &numbers), 42);
    try expectEqual(std.mem.min(u32, &numbers), 7);
    try expectEqual(std.mem.minMax(u32, &numbers), .{ .min = 7, .max = 42 });

    // Will get "out of bounds for array" if not long enough.
    var buffer: [30]u8 = undefined;
    const times = std.mem.replace(u8, s, "^", "-", &buffer);
    try expectEqual(times, 2);
    const expected = "foo-bar-baz";
    try expectEqualStrings(buffer[0..expected.len], expected);
}
