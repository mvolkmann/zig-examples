const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "@call" {
    const args = .{ 2, 3 };

    // The first argument to @call is a CallModifier.
    // Supported values are `auto` (most common), `always_inline`,
    // `always_tail`, `async_kw`, `compile_time`, `never_inline`,
    // `never_tail`, and `no_async`.
    const result = @call(.auto, add, args);

    try expectEqual(result, 5);
}
