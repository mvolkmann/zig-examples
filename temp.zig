const std = @import("std");

pub fn main() void {
    var Foo = struct {
        x: i8,
    };

    var foo = Foo{ .x = 1 };

    std.info.print("{}\n", .{foo.x});
}
