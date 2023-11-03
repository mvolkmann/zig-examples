const std = @import("std");
const m1 = @import("module1.zig");
const m2 = @import("module2.zig");

pub fn main() !void {
    m1.first();
    m2.second();
}

test {
    std.testing.refAllDecls(@This());
}
