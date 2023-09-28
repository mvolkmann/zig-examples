const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

// TODO: Turn this into a test like hashmap_demo.zig and demonstrate more methods.
pub fn main() !void {
    var list = std.ArrayList(i32).init(allocator);
    // ArrayList fields are items, capacity, and allocator.
    // ArrasyList methods are append, appendSlice, clone, deinit,
    // getLast, getLastOrNull, init, insert, insertSlice, orderedRemove,
    // pop, popOrNull, replaceRange, writer, and many more.
    defer list.deinit();
    try list.append(19);
    try list.append(21);

    // This loop outputs 19 and 21.
    for (list.items) |value| {
        print("{}\n", .{value});
    }
}
