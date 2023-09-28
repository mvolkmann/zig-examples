const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

test "Set" {
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
    while (iter.next()) |entry| {
        print("{s}\n", .{entry.*});
    }

    try expect(set.contains("Gretzky"));

    set.remove("Gretzky");
    try expect(!set.contains("Gretzky"));
}
