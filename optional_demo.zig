const std = @import("std");
const print = std.debug.print;

fn report(wrapper: ?i8) void {
    if (wrapper) |value| {
        print("value = {}\n", .{value});
    } else {
        print("value is null\n", .{});
    }
}

pub fn main() void {
    var wrapper: ?i8 = null;
    report(wrapper);
    wrapper = 19;
    report(wrapper);
}
