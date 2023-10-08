const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;

test "union" {
    const Identifier = union {
        name: []const u8,
        number: i32,
    };
    const id1 = Identifier{ .name = "top secret" };
    const id2 = Identifier{ .number = 1234 };
    try expectEqual(id1.name, "top secret");
    try expectEqual(id2.number, 1234);
}

test "tagged union" {
    const IdentifierTag = enum { name, number };
    const Identifier = union(IdentifierTag) {
        name: []const u8,
        number: i32,
    };

    const id1 = Identifier{ .number = 1234 };
    const id2 = Identifier{ .name = "top secret" };
    const ids = [_]Identifier{ id1, id2 };

    for (ids) |id| {
        switch (id) {
            .name => print("got Identifier named \"{s}\"\n", .{id.name}),
            .number => print("got Identifier #{d}\n", .{id.number}),
        }
    }
}
