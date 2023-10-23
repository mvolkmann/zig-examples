const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const String = []const u8;

// This demonstrates having parameters with type "anytype".
fn getParamType(comptime p: anytype) type {
    return @TypeOf(p);
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

    inline for (std.meta.fields(Dog)) |field| {
        print("\nfound field \"{s}\" with type {s}\n", .{ field.name, @typeName(field.type) });
        print("value in dog is {any}\n", .{@as(field.type, @field(dog, field.name))});
    }

    const info = @typeInfo(Dog);
    if (info == .Struct) {
        const fields = std.meta.fields(Dog);
        inline for (fields) |field| {
            print("field \"{s}\" is a {}.\n", .{ field.name, field.type });
        }
    }
}
