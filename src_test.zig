const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

fn demo() !std.builtin.SourceLocation {
    // @src must be called inside a function.
    return @src();
}

test "@src" {
    const src = try demo();
    try expectEqualStrings(src.file, "src_test.zig");
    try expectEqualStrings(src.fn_name, "demo");
    try expectEqual(@as(u32, 7), src.line);
    try expectEqual(@as(u32, 12), src.column); // start of @src
}
