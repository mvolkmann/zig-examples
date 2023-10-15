const std = @import("std");
const base_allocator = std.testing.allocator;
const expectEqual = std.testing.expectEqual;

test "ArenaAllocator" {
    var arena = std.heap.ArenaAllocator.init(base_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var list1 = std.ArrayList([]const u8).init(allocator); // no need to deinit
    try list1.append("one");
    try list1.append("two");
    try list1.append("three");
    try expectEqual(list1.items.len, 3);

    var list2 = std.ArrayList(u8).init(allocator); // no need to deinit
    try list2.append(7);
    try list2.append(13);
    try expectEqual(list2.items.len, 2);

    // No memory is leaked even though we didn't deinit the lists.
}
