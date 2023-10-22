const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const tAlloc = std.testing.allocator;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;
const String = []const u8;

test "arrays" {
    // Create a mutable array so it can be modified later.
    var dice_rolls = [_]u8{ 4, 2, 6, 1, 2 };
    try expectEqual(dice_rolls.len, 5);

    // Use a for loop to iterate over the items in an array or slice.
    // A for loop can iterate over multiple arrays at the same time.
    // This is being used to iterate over the array elements AND their indices.
    for (dice_rolls, 0..) |roll, index| {
        try expectEqual(roll, dice_rolls[index]);
    }

    // Copy an array.
    const copy: [5]u8 = dice_rolls;
    try expectEqual(copy[0], dice_rolls[0]);
    try expect(&copy != &dice_rolls);

    // Get a slice of an array.
    const subset = dice_rolls[2..4];
    var expected_subset = [_]u8{ 6, 1 };
    try expectEqualSlices(u8, &expected_subset, subset);

    // Modify array items in-place.
    for (&dice_rolls) |*roll| {
        roll.* += 1;
        if (roll.* > 6) roll.* = 1;
    }
    // print("{any}\n", .{dice_rolls});
    const expected_modifications = [_]u8{ 5, 3, 1, 2, 3 };
    try expectEqualSlices(u8, &expected_modifications, &dice_rolls);

    // Concatenate two arrays.
    const more_rolls = [_]u8{ 1, 2, 3 };
    const combined_rolls = dice_rolls ++ more_rolls;
    const expected_combined = [_]u8{ 5, 3, 1, 2, 3, 1, 2, 3 };
    try expectEqualSlices(u8, &expected_combined, &combined_rolls);

    // Arrays have a fixed length that cannot be changed.
    // For a dynamically-sized array, use std.ArrayList.
}

fn double(n: u8) u8 {
    return n * 2;
}

fn filter(
    comptime T: type,
    allocator: std.mem.Allocator,
    function: fn (T) bool,
    data: []const T,
) ![]T {
    var list = try std.ArrayList(T).initCapacity(allocator, data.len);
    defer list.deinit();
    for (data) |in| {
        if (function(in)) {
            // We can call this instead of "append"
            // because we know the list already has enough space.
            list.appendAssumeCapacity(in);
        }
    }
    return try list.toOwnedSlice();
}

fn isOdd(n: u8) bool {
    return n % 2 == 1;
}

// Note that there are three implementations of the map function here,
// each with different characteristics.

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

fn mapExplicit(
    comptime InT: type,
    comptime OutT: type,
    dataIn: []const InT,
    dataOut: []OutT,
    function: fn (InT) OutT,
) void {
    assert(dataOut.len >= dataIn.len);
    for (dataIn, dataOut) |in, *out| {
        out.* = function(in);
    }
}

fn mapInferred(
    function: anytype,
    dataIn: []const @typeInfo(@TypeOf(function)).Fn.params[0].type.?,
    dataOut: []@typeInfo(@TypeOf(function)).Fn.return_type.?,
) void {
    assert(dataOut.len >= dataIn.len);
    for (dataIn, dataOut) |in, *out| {
        out.* = function(in);
    }
}

fn reduce(
    comptime InT: type,
    comptime OutT: type,
    data: []const InT,
    function: fn (OutT, InT) OutT,
    initial: OutT,
) !OutT {
    var result = initial;
    for (data) |item| {
        result = function(result, item);
    }
    return result;
}

// TODO: Implement a reduce function.

test filter {
    const alloc = std.testing.allocator;
    const numbers = [_]u8{ 1, 2, 3 };
    const results = try filter(u8, alloc, isOdd, &numbers);
    defer alloc.free(results);
    const expected = [_]u8{ 1, 3 };
    try expectEqualSlices(u8, results, &expected);
}

test mapExplicit {
    const numbers = [_]u8{ 1, 2, 3 };
    var results: [numbers.len]u8 = undefined;
    mapExplicit(u8, u8, &numbers, &results, double);
    for (results, 0..) |result, index| {
        try expectEqual(numbers[index] * 2, result);
    }
}

test mapInferred {
    const numbers = [_]u8{ 1, 2, 3 };
    var results: [numbers.len]u8 = undefined;
    mapInferred(double, &numbers, &results);
    for (results, 0..) |result, index| {
        try expectEqual(numbers[index] * 2, result);
    }
}

fn add(a: u8, b: u8) u8 {
    return a + b;
}

test reduce {
    const numbers = [_]u8{ 1, 2, 3 };
    const sum = reduce(u8, u8, &numbers, add, 0);
    try expectEqual(sum, 6);
}
