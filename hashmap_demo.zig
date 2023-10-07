const std = @import("std");
const print = std.debug.print;
const allocator = std.testing.allocator;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const String = []const u8;

test "AutoHashMap" {
    var map = std.AutoHashMap(u8, String).init(allocator);
    defer map.deinit();

    try map.put(99, "Gretzky");
    try map.put(4, "Orr");
    try map.put(19, "Ratelle");
    try expect(map.count() == 3);

    // Iterate over the map entries.
    print("\n", .{});
    var iter = map.iterator();
    while (iter.next()) |entry| {
        print("{s} number is {d}.\n", .{ entry.value_ptr.*, entry.key_ptr.* });
    }

    // Iterate over the map keys.
    var iter2 = map.keyIterator();
    while (iter2.next()) |key| {
        const number = key.*;
        if (map.get(number)) |name| {
            print("{s} number is {d}.\n", .{ name, number });
        }
    }

    try expect(map.contains(99));

    // The `get` method returns an optional value.
    var name = map.get(99) orelse "";
    try expectEqualStrings("Gretzky", name);

    const removed = map.remove(99);
    try expect(removed);
    // try expect(map.get(99) == null);
    try expectEqual(@as(?[]const u8, null), map.get(99));
}

test "ComptimeStringMap" {
    // Create an array of tuples.
    const list = .{
        .{ "Gretzky", 99 },
        .{ "Orr", 4 },
        .{ "Ratelle", 19 },
    };
    try expect(list.len == 3);

    // Create a compile-time map of string keys to u8 values.
    // Since an immutable map with a fixed size is being created,
    // there is no need to deinit it.
    const map = std.ComptimeStringMap(u8, list);

    for (map.kvs) |kv| {
        print("{s} number is {d}.\n", .{ kv.key, kv.value });
    }

    try expect(map.has("Gretzky"));
    try expect(map.has("Orr"));
    try expect(map.has("Ratelle"));

    try expectEqual(@as(u8, 99), map.get("Gretzky").?);
    try expectEqual(@as(u8, 4), map.get("Orr").?);
    try expectEqual(@as(u8, 19), map.get("Ratelle").?);
}

test "StringHashMap" {
    var map = std.StringHashMap(u8).init(allocator);
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
