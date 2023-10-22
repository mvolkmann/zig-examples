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

    const ids = [_]Identifier{
        Identifier{ .number = 1234 },
        Identifier{ .name = "top secret" },
    };

    for (ids) |id| {
        switch (id) {
            .name => |name| {
                try expectEqual(name, "top secret");
            },
            .number => |number| try expectEqual(number, 1234),
        }
    }

    try expectEqual(std.meta.activeTag(ids[0]), IdentifierTag.number);
    try expectEqual(std.meta.activeTag(ids[1]), IdentifierTag.name);
}

test "inferred enum union" {
    const Identifier = union(enum) {
        name: []const u8,
        number: i32,
    };

    const ids = [_]Identifier{
        .{ .number = 1234 },
        .{ .name = "top secret" },
    };

    for (ids) |id| {
        switch (id) {
            .name => |name| {
                try expectEqual(name, "top secret");
            },
            .number => |number| try expectEqual(number, 1234),
        }
    }
}
