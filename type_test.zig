const std = @import("std");
const expectEqual = std.testing.expectEqual;
const String = []const u8;

fn getParamType(comptime p: anytype) type {
    return @TypeOf(p);
    // const info = @typeInfo(p);
}

const Dog = struct {
    name: String,
    age: u8,
};

test "tuple" {
    const n: u16 = 2;
    try expectEqual(getParamType(n), u16);

    const dog = Dog{ .name = "Comet", .age = 3 };
    try expectEqual(getParamType(dog), Dog);
}
