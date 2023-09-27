const std = @import("std");
const print = std.debug.print;
const stdout = std.io.getStdOut();
const sow = stdout.writer();

const Dog = struct {
    name: []const u8,
    breed: []const u8,
    age: u8,

    const Self = @This();
    pub fn format(
        value: Self,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) std.os.WriteError!void {
        return writer.print(
            "{s} is a {d} year old {s}.",
            .{ value.name, value.age, value.breed },
        );
    }
};

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

        pub fn depthFirstPrint(self: *Self, indent: u8) void {
            // Ignoring errors for simplicity.
            sow.writeByteNTimes(' ', indent * 2) catch {};

            // format must be compile-time known.
            const specifier = if (T == []const u8) "s" else "";
            const format = "- {" ++ specifier ++ "}\n";
            // Ignoring errors for simplicity.
            sow.print(format, .{self.value}) catch {};

            if (self.left) |left| left.depthFirstPrint(indent + 1);
            if (self.right) |right| right.depthFirstPrint(indent + 1);
        }
    };
}

fn treeOfDogs() void {
    const Node = makeNode(Dog);
    var node1 = Node.init(Dog{
        .name = "Maisey",
        .breed = "Treeing Walker Coonhound",
        .age = 3,
    });
    var node2 = Node.init(Dog{
        .name = "Ramsay",
        .breed = "Native American Indian Dog",
        .age = 3,
    });
    node1.left = &node2;
    var node3 = Node.init(Dog{
        .name = "Oscar",
        .breed = "German Short-haired Pointer",
        .age = 3,
    });
    node1.right = &node3;
    var node4 = Node.init(Dog{
        .name = "Comet",
        .breed = "Whippet",
        .age = 3,
    });
    node2.left = &node4;
    node1.depthFirstPrint(0);
}

fn treeOfStrings() void {
    const Node = makeNode([]const u8);
    var node1 = Node.init("one");
    var node2 = Node.init("two");
    node1.left = &node2;
    var node3 = Node.init("three");
    node1.right = &node3;
    var node4 = Node.init("four");
    node2.left = &node4;
    node1.depthFirstPrint(0);
}

fn treeOfU8() void {
    const Node = makeNode(u8);
    var node1 = Node.init(1);
    var node2 = Node.init(2);
    node1.left = &node2;
    var node3 = Node.init(3);
    node1.right = &node3;
    var node4 = Node.init(4);
    node2.left = &node4;
    node1.depthFirstPrint(0);
}

// TODO: Create a tree where values are a custom struct type.

pub fn main() !void {
    treeOfU8();
    treeOfStrings();
    treeOfDogs();
}
