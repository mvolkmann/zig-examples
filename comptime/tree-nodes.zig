const std = @import("std");
const print = std.debug.print;
const stdout = std.io.getStdOut();
const sow = stdout.writer();

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

        pub fn depthFirstPrint(self: *Self, indent: u8) !void {
            const specifier = if (T == []const u8) "s" else "";
            for (0..indent) |_| {
                try sow.print("  ", .{});
            }
            // format must be comptime!
            const format = "- {" ++ specifier ++ "}\n";
            try sow.print(format, .{self.value});

            if (self.left) |left| {
                try left.depthFirstPrint(indent + 1);
            }
            if (self.right) |right| {
                try right.depthFirstPrint(indent + 1);
            }
        }
    };
}

fn treeOfStrings() !void {
    const Node = makeNode([]const u8);
    var node1 = Node.init("one");
    var node2 = Node.init("two");
    node1.left = &node2;
    var node3 = Node.init("three");
    node1.right = &node3;
    var node4 = Node.init("four");
    node2.left = &node4;
    try node1.depthFirstPrint(0);
}

fn treeOfU8() !void {
    const Node = makeNode(u8);
    var node1 = Node.init(1);
    var node2 = Node.init(2);
    node1.left = &node2;
    var node3 = Node.init(3);
    node1.right = &node3;
    var node4 = Node.init(4);
    node2.left = &node4;
    try node1.depthFirstPrint(0);
}

// TODO: Create a tree where values are a custom struct type.

pub fn main() !void {
    try treeOfU8();
    try treeOfStrings();
}
