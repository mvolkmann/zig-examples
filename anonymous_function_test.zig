const std = @import("std");
const tAlloc = std.testing.allocator;
const expectEqualSlices = std.testing.expectEqualSlices;

fn map(
    comptime InT: type,
    comptime OutT: type,
    allocator: std.mem.Allocator,
    data: []const InT,
    function: fn (InT) OutT,
) ![]OutT {
    var list = try std.ArrayList(OutT).initCapacity(allocator, data.len);
    defer list.deinit();
    for (data) |item| {
        try list.append(function(item));
    }
    return try list.toOwnedSlice();
}

test "anonymous function" {
    const T = u32;
    const numbers = [_]T{ 1, 2, 3 };

    // Using in anonymous functions in Zig are somewhat tedious
    // because the must be wrapped in a struct and the extracted from it.
    // It's probably best to make it a named function outside and struct
    // and just use that.
    const result = try map(T, T, tAlloc, &numbers, struct {
        fn double(n: T) T {
            return n * 2;
        }
    }.double);
    defer tAlloc.free(result);
    const expected = [_]T{ 2, 4, 6 };
    try expectEqualSlices(T, result, &expected);
}
