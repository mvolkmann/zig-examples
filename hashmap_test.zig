const std = @import("std");
const print = std.debug.print;
const allocator = std.testing.allocator;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const String = []const u8;

const Dog = struct {
    name: String,
    breed: String,
};

test "AutoArrayHashMap" {
    var map = std.AutoArrayHashMap(u8, String).init(allocator);
    defer map.deinit();

    try map.put(99, "Gretzky");
    try map.put(4, "Orr");
    try map.put(19, "Ratelle");
    try expectEqual(map.count(), 3);

    // Iterate over the map entries.
    print("\n", .{});
    var iter = map.iterator();
    while (iter.next()) |entry| {
        print("{s} number is {d}.\n", .{ entry.value_ptr.*, entry.key_ptr.* });
    }

    try expect(map.contains(99));

    // The `get` method returns an optional value.
    var name = map.get(99) orelse "";
    try expectEqualStrings("Gretzky", name);

    const removed = map.orderedRemove(99); // returns bool
    try expect(removed);
    try expectEqual(@as(?String, null), map.get(99));
}

test "AutoHashMap" {
    var map = std.AutoHashMap(u8, String).init(allocator);
    defer map.deinit();

    try map.put(99, "Gretzky");
    try map.put(4, "Orr");
    try map.put(19, "Ratelle");
    try expectEqual(map.count(), 3);

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

    const removed = map.remove(99); // returns bool
    try expect(removed);
    try expectEqual(@as(?String, null), map.get(99));
}

test "BufMap" {
    var map = std.BufMap.init(allocator);
    defer map.deinit();

    try map.put("Comet", "whippet");
    try map.put("Oscar", "german shorthaired pointer");
    try expectEqual(map.count(), 2);
    try expectEqualStrings(map.get("Comet").?, "whippet");
    try expectEqualStrings(map.get("Oscar").?, "german shorthaired pointer");
}

test "ComptimeStringMap" {
    // Create an array of tuples.
    const list = .{
        .{ "Gretzky", 99 },
        .{ "Orr", 4 },
        .{ "Ratelle", 19 },
    };
    try expectEqual(list.len, 3);

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

test "StringArrayHashMap" {
    const dogs = [_]Dog{
        .{ .name = "Comet", .breed = "whippet" },
        .{ .name = "Oscar", .breed = "german shorthaired pointer" },
    };

    // The keys are strings and the values are Dogs.
    var map = std.StringArrayHashMap(Dog).init(allocator);
    defer map.deinit();

    for (dogs) |dog| {
        try map.put(dog.name, dog);
    }

    try expectEqualStrings(map.get("Comet").?.breed, "whippet");
    try expectEqualStrings(map.get("Oscar").?.breed, "german shorthaired pointer");
}

test "StringHashMap" {
    // The keys are strings and the values are unsigned integers.
    var map = std.StringHashMap(u8).init(allocator);
    defer map.deinit();

    try map.put("Gretzky", 99);
    try map.put("Orr", 4);
    try map.put("Ratelle", 19);
    try expectEqual(map.count(), 3);

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

    const removed = map.remove("Gretzky"); // returns bool
    try expect(removed);
    try expectEqual(@as(?u8, null), map.get("Gretzky"));
}

const StringToU8Map = std.StringHashMap(u8);
fn getMap() !StringToU8Map {
    var map = StringToU8Map.init(allocator);

    try map.put("Gretzky", 99);
    try map.put("Orr", 4);
    try map.put("Ratelle", 19);
    return map;
}

test "HashMap deinit" {
    // Approach #1: mutable map
    // var map = try getMap();
    // defer map.deinit(); // map cannot be const

    // Approach #2: immutable map
    const map = try getMap();
    defer {
        var mutable = map;
        mutable.deinit();
    }

    try expectEqual(map.count(), 3);
}
