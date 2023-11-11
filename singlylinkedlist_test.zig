const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

const DataType = u32;
const NumberList = std.SinglyLinkedList(DataType);
const Node = NumberList.Node;

test "SinglyLinkedList basic" {
    var list = NumberList{};

    // node1 holds a struct on the stack.
    var node1 = Node{ .data = 1 };
    list.prepend(&node1);

    // If we were to reuse node1 here,
    // it would replace the struct on the stack,
    // destroying the previous value.
    var node2 = Node{ .data = 2 };
    list.prepend(&node2);

    var node = list.first orelse unreachable;
    try expectEqual(node.data, 2);

    node = node.next orelse unreachable;
    try expectEqual(node.data, 1);

    try expectEqual(node.next, null);
}

test "SinglyLinkedList advanced" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Create a linked list from values in an array.
    var list = NumberList{};
    const numbers = [_]DataType{ 10, 20, 30 };
    for (numbers) |number| {
        var node_ptr = try allocator.create(Node);
        node_ptr.data = number;
        list.prepend(node_ptr);
    }

    try expectEqual(list.len(), numbers.len);

    // Verify the linked list contents.
    var iter = list.first;
    var i: usize = numbers.len;
    while (iter) |node_ptr| {
        i -= 1;
        try expectEqual(node_ptr.data, numbers[i]);
        iter = node_ptr.next;
    }
}
