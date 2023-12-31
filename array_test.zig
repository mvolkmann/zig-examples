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
    try expectEqual(@TypeOf(dice_rolls.len), usize);

    // Use a for loop to iterate over the items in an array or slice.
    // A for loop can iterate over multiple arrays at the same time.
    // This is being used to iterate over
    // the array elements AND their indices.
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
    assert(std.mem.eql(u8, &expected_subset, subset));

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

test "multi-dimensional array" {
    var matrix = [3][3]f64{
        [_]f64{ 1.0, 2.0, 3.0 },
        [_]f64{ 4.0, 5.0, 6.0 },
        [_]f64{ 7.0, 8.0, 9.0 },
    };

    const row_index = 1;
    const column_index = 2;
    try expectEqual(matrix[row_index][column_index], 6.0);
    matrix[row_index][column_index] = 42.0;
    try expectEqual(matrix[row_index][column_index], 42.0);

    for (matrix) |row| {
        print("\n", .{});
        for (row) |value| {
            print("{} ", .{value});
        }
    }

    // Initialize a two-dimensional array to all zeroes.
    var m2 = std.mem.zeroes([3][3]u8);
    try expectEqual(m2[0][0], 0);
    m2[1][2] = 19;
    try expectEqual(m2[1][2], 19);
    var row = &m2[1]; // note need to get a pointer
    row[2] = 20;
    try expectEqual(m2[1][2], 20);
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

fn set1D(arr: []u8, index: usize, value: u8) void {
    arr[index] = value;
}

test set1D {
    var numbers = [_]u8{ 1, 2, 3 };
    set1D(&numbers, 1, 4);
    try expectEqual(numbers[1], 4);
}

// Note the need for the type of arr to be anytype rather than [][]u8.
fn set2D(arr: anytype, row: usize, col: usize, value: u8) void {
    arr[row][col] = value;

    // This also works. Note the need to get a pointer to the row slice.
    // var arr_row = &arr[row];
    // arr_row[col] = value;
}

test set2D {
    var matrix = [3][3]u8{
        [_]u8{ 1, 2, 3 },
        [_]u8{ 4, 5, 6 },
        [_]u8{ 7, 8, 9 },
    };
    const row = 1;
    const col = 1;
    const val = 10;
    set2D(&matrix, row, col, val);
    try expectEqual(matrix[row][col], val);
}
