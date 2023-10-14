const std = @import("std");
// mod is a struct instance whose fields
// are the pub values in my_module.zig.
const mod = @import("my_module.zig");

pub fn main() !void {
    std.debug.print("gretzky = {}\n", .{mod.gretzky});

w   const value = 3;
    const result = mod.double(value);
    std.debug.print("result = {}\n", .{result});
}
