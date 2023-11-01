const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    // This cannot be called at the top-level.
    // From the official docs, "To prevent accidentally leaving compile log
    // statements in a codebase, a compilation error is added to the build,
    // pointing to the compile log statement.
    // This error prevents code from being generated,
    // but does not otherwise interfere with analysis."
    // The output begins with cast syntax which is ugly!
    // For a string it would be "@as(*const [n:0]u8, ".
    @compileLog("some text", 7);

    print("This was printed at run-time.", .{});
}
