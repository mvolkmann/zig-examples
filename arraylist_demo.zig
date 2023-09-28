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

    // ArrasyList methods are append, appendSlice, clone, deinit,
    // getLast, getLastOrNull, init, insert, insertSlice, orderedRemove,
    // pop, popOrNull, replaceRange, writer, and many more.

    try list.append("red");
    try list.appendSlice(&[_]String{ "green", "blue" });
    try expect(list.items.len == 3);
    try expectEqual(@as(?String, "blue"), list.getLastOrNull());

    // Iterate over the list entries.
    print("\n", .{});
    for (list.items) |value| {
        print("{s}\n", .{value});
    }

    try expectEqual(@as(?String, "blue"), list.pop());
    try expect(list.items.len == 2);

    // try expect(list.contains("green"));

    // const removed = list.remove("green");
    // try expect(removed);
    // try expect(!list.contains("green"));

    try list.appendNTimes("clear", 2);
    try expect(list.items.len == 4); // length was 2
    try expectEqual(@as(String, "clear"), list.getLast());

    list.clearAndFree();
    try expect(list.items.len == 0);
}
