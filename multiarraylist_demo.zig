const std = @import("std");
const allocator = std.testing.allocator;
const expectEqual = std.testing.expectEqual;

const Range = struct {
    min: f32,
    max: f32,
    current: f32,
};

test "MultiArrayList" {
    // Unlike "ArrayList" instances, "MultiArrayList" instances
    // do not store an allocator in order to optimize memory used.
    // This is why an allocator must be passed
    // to methods like "append" and "insert".
    var list = std.MultiArrayList(Range){};
    defer list.deinit(allocator);

    // Optionally set the total capacity before appending elements
    // to avoid having to allocate memory multiple times.
    try list.ensureTotalCapacity(allocator, 10);

    const r1 = Range{ .min = 0, .max = 100, .current = 50 };
    try list.append(allocator, r1);

    try list.append(allocator, Range{ .min = 10, .max = 50, .current = 25 });

    // Insert an element at a specific index, zero in this case.
    try list.insert(allocator, 0, Range{ .min = 1000, .max = 9999, .current = 1234 });

    try expectEqual(list.len, 3);

    // After the insert, r1 was moved to index 1.
    try expectEqual(list.get(1), r1);

    // The "items" method gets a slice of the values for a given field.
    const currents: []f32 = list.items(.current);

    const vector: @Vector(3, f32) = currents[0..3].*;
    const sum = @reduce(.Add, vector);
    try expectEqual(sum, 1309.0);
}
