const std = @import("std");
const print = std.debug.print;

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

pub fn main() !void {
    const dog = Dog{ .name = "Comet", .breed = "whippet", .age = 3 };
    print("{}\n", .{dog});
}
