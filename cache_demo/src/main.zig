const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const math = @import("math.zig");

// pkg is a struct instance whose fields
// are the pub values in my_package.zig.
const pkg = @import("my_package.zig");

pub fn main() !void {
    print("gretzky = {}\n", .{pkg.gretzky});

    const value = 3;
    const result = pkg.double(value);
    print("result = {}\n", .{result});
}

test "main" {
    try expectEqual(math.add(1, 2), 3);
}
