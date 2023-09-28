const std = @import("std");
const panic = std.debug.panic;
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "HashMap" {
    const allocator = std.testing.allocator;

    // std.HashMap is a low-level implementaton that
    // requires supplying a hashing function.

    // std.AutoHashMap provides a good hashing function for most key types.
    // The first argument is the key type and the second is the value type.
    // When the key type is `[]const u8`, the folowing error is triggered:
    // "std.auto_hash.autoHash does not allow slices here ([]const u8)
    // because the intent is unclear. Consider using std.StringHashMap
    // for hashing the contents of []const u8."
    // var map = std.AutoHashMap([]const u8, u8).init(allocator);

    // std.StringHashMap provides a good hashing function for string keys.
    // The argument is the value type.
    var map = std.StringHashMap(u8).init(allocator);

    // A HashMap can be used as a Set where the value are {}.

    defer map.deinit();

    try map.put("Gretzky", 99);
    try map.put("Orr", 4);
    try map.put("Ratelle", 19);
    try expect(map.count() == 3);

    // Iterate over the map entries.
    print("\n", .{});
    var iter = map.iterator();
    while (iter.next()) |entry| {
        print("{s} number is {d}.\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    // Iterate over the map keys.
    var iter2 = map.keyIterator();
    while (iter2.next()) |key| {
        print("{s} number is {any}.\n", .{ key.*, map.get(key.*) });
    }

    try expect(map.contains("Gretzky"));

    // The `get` method returns an optional value.
    try expectEqual(@as(?u8, 99), map.get("Gretzky"));

    const removed = map.remove("Gretzky");
    try expect(removed);
    try expectEqual(@as(?u8, null), map.get("Gretzky"));
}
