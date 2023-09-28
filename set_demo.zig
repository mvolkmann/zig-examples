const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

test "BufSet" {
    const allocator = std.testing.allocator;
    var set = std.BufSet.init(allocator);
    defer set.deinit();

    try set.insert("Gretzky");
    try set.insert("Orr");
    try set.insert("Ratelle");
    try expect(set.count() == 3);

    // Iterate over the set keys.
    print("\n", .{});
    var iter = set.iterator();
    while (iter.next()) |key| {
        print("{s}\n", .{key.*});
    }

    try expect(set.contains("Gretzky"));

    set.remove("Gretzky");
    try expect(!set.contains("Gretzky"));
}

test "EnumSet" {
    const Color = enum { red, orange, yellow, green, blue, purple, white, black };

    // This does not use an allocator and does not have a `deinit` method.
    var set = std.EnumSet(Color).initEmpty();

    // To begin with all enum values in the set ...
    // var set = std.EnumSet(Color).initFull();

    // To begin with a subset of the enum values in the set ...
    // var set = std.EnumSet(Color).initMany(&[_]Color{ .orange, .yellow });

    // To begin with one of the enum values in the set ...
    // var set = std.EnumSet(Color).initOne(.orange);

    set.insert(.orange);
    set.insert(.yellow);
    set.insert(.black);
    try expect(set.count() == 3);

    // Iterate over the set keys.
    print("\n", .{});
    var iter = set.iterator();
    while (iter.next()) |key| {
        print("{}\n", .{key});
    }

    try expect(set.contains(.yellow));

    set.remove(.yellow);
    try expect(!set.contains(.yellow));

    // There are many more methods on `EnumSet` instances.
}
