const std = @import("std");
const m1 = @import("module1.zig");

pub fn main() !void {
    m1.first();
}

test {
    std.testing.refAllDecls(@This());
}
