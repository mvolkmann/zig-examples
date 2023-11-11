const std = @import("std");
const expectEqual = std.testing.expectEqual;

const DataType = u32;
const NumberList = std.DoublyLinkedList(DataType);
const Node = NumberList.Node;

test "DoublyLinkedList basic" {
    var list = NumberList{};

    // node1 holds a struct on the stack.
    var node1 = Node{ .data = 1 };
    list.append(&node1);

    // If we were to reuse node1 here,
    // it would replace the struct on the stack,
    // destroying the previous value.
    var node2 = Node{ .data = 2 };
    list.append(&node2);

    try expectEqual(list.len, 2);
    try expectEqual(list.first.?.data, 1);
    try expectEqual(list.last.?.data, 2);

    var node = list.first orelse unreachable;
    try expectEqual(node.data, 1);

    node = node.next orelse unreachable;
    try expectEqual(node.data, 2);

    try expectEqual(node.next, null);
}

test "DoublyLinkedList advanced" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Create a linked list from values in an array.
    var list = NumberList{};
    const numbers = [_]DataType{ 10, 20, 30 };
    for (numbers) |number| {
        var node_ptr = try allocator.create(Node);
        node_ptr.data = number;
        list.append(node_ptr);
    }

    try expectEqual(list.len, numbers.len);

    // Verify the linked list contents from the beginning.
    var iter = list.first;
    var i: usize = 0;
    while (iter) |node_ptr| {
        try expectEqual(node_ptr.data, numbers[i]);
        iter = node_ptr.next;
        i += 1;
    }

    // Verify the linked list contents from the end.
    iter = list.last;
    i = numbers.len;
    while (iter) |node_ptr| {
        i -= 1;
        try expectEqual(node_ptr.data, numbers[i]);
        iter = node_ptr.prev;
    }
}
