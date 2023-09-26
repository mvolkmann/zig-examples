const std = @import("std");
const print = std.debug.print;

fn makeNode(comptime T: type) type {
    return struct {
        const Self = @This();

        left: ?*Self,
        right: ?*Self,
        value: T,

        fn init(value: T) Self {
            return Self{
                .left = null,
                .right = null,
                .value = value,
            };
        }

        pub fn depthFirstPrint(self: *Self) void {
            std.debug.print("{}\n", .{self.value});
            if (self.left) |left| {
                left.depthFirstPrint();
            }
            if (self.right) |right| {
                right.depthFirstPrint();
            }
        }
    };
}

const Node = makeNode(u8);
// const Node = makeNode(*const []u8);

pub fn main() !void {
    var node1 = Node.init(1);
    // var node1 = Node.init("one");

    var node2 = Node.init(2);
    // var node2 = Node.init("two");
    node1.left = &node2;

    var node3 = Node.init(3);
    // var node3 = Node.init("three");
    node1.right = &node3;

    var node4 = Node.init(4);
    // var node4 = Node.init("four");
    node2.left = &node4;

    node1.depthFirstPrint();
}
