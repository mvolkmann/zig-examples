const std = @import("std");
const print = std.debug.print;
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
    print("list.items = {any}\n", .{list.items});
    return try list.toOwnedSlice();
}

test "anonymous function" {
    const T = u32;
    const numbers = [_]T{ 1, 2, 3 };
    const result = try map(T, T, tAlloc, &numbers, struct {
        fn double(n: T) T {
            return n * 2;
        }
    }.double);
    tAlloc.free(result);
    const expected = [_]T{ 2, 4, 6 };
    _ = expected;
    print("result = {any}\n", .{result});
    //try expectEqualSlices(T, result, &expected);
}
