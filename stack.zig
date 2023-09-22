// This is based on the Primeagen video at
// https://mail.google.com/mail/u/1/#inbox/FMfcgzGtxKTrvDGcQqMwWmMdwdrVsbrR

const std = @import("std");
const log = std.debug.print;
const Allocator = std.mem.Allocator; // memory allocator interface
const expect = std.testing.expect;

// This creates a struct that represents
// a stack whose values are a given type.
fn Stack(comptime T: type) type {
    return struct {
        const Node = struct { value: T, next: ?*Node };

        // Gets the type of the struct we are inside.
        const Self = @This();

        length: usize,
        head: ?*Node, // optional pointer
        allocator: Allocator, // passed to init below

        pub fn init(allocator: Allocator) Self {
            return .{ .length = 0, .head = null, .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
            while (self.length > 0) _ = self.pop();
            self.* = undefined;
        }

        pub fn push(self: *Self, value: T) !void {
            var node = try self.allocator.create(Node);
            node.value = value;
            node.next = self.head;
            self.length += 1;
            self.head = node;
        }

        pub fn pop(self: *Self) ?T {
            if (self.head) |unwrapped| {
                defer self.allocator.destroy(unwrapped);
                self.length -= 1;
                self.head = unwrapped.next;
                return unwrapped.value;
            }
            return null;
        }

        pub fn print(self: *Self) void {
            log("\nStack length is {}.\n", .{self.length});
            var node = self.head;
            while (node) |unwrapped| {
                log("=> {}\n", .{unwrapped.value});
                node = unwrapped.next;
            }
        }
    };
}

test "stack" {
    const IntStack = Stack(i32);
    var stack = IntStack.init(std.testing.allocator);
    defer stack.deinit();

    try stack.push(19);
    try expect(stack.length == 1);

    try stack.push(20);
    try expect(stack.length == 2);

    stack.print(); // output is suppressed in tests

    var value = stack.pop();
    try expect(stack.length == 1);
    try expect(value == 20);

    value = stack.pop();
    try expect(stack.length == 0);
    try expect(value == 19);

    value = stack.pop();
    try expect(stack.length == 0);
    try expect(value == null);
}
