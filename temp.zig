const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const MyVec = @Vector(3, f32);
    const v1 = MyVec{ 1.2, 2.3, 3.4 };

    print("{}\n", .{@exp(v1)});
    print("{}\n", .{@exp2(3.0)});
    print("{}\n", .{@log(4.0)});
}
