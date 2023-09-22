const std = @import("std");

pub fn main() void {
    const value = 1;
    if (value == 1) {
        unreachable;
    }
}
