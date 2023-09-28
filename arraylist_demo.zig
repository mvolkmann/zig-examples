const std = @import("std");
const print = std.debug.print;
const allocator = std.testing.allocator;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const String = []const u8;

test "ArrayList" {
    var list = std.ArrayList(String).init(allocator);
    defer list.deinit();

    try list.append("red");
    try list.appendSlice(&[_]String{ "green", "blue" });
    try expect(list.items.len == 3);

    // Iterate over the list entries.
    print("\n", .{});
    for (list.items) |value| {
        print("{s}\n", .{value});
    }

    // There is no method to test if an ArrayList` contains a given value.
    // It's more efficient to use a `BufSet` when that is needed.

    try expectEqual(@as(?String, "blue"), list.getLastOrNull());

    try expectEqual(@as(?String, "blue"), list.popOrNull());
    try expect(list.items.len == 2);

    try list.insert(1, "pink");
    try expect(list.items.len == 3);
    // Also see the replaceRange method.

    const removed = list.orderedRemove(1);
    try expectEqual(@as(String, "pink"), removed);
    try expect(list.items.len == 2);

    try list.appendNTimes("black", 2);
    try expect(list.items.len == 4); // length was 2
    try expectEqual(@as(String, "black"), list.getLast());

    list.clearAndFree();
    try expect(list.items.len == 0);
}
