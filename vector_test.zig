const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "vectors" {
    // The benefit is most apparent when the length is large.
    // The length cannot be inferred using _.
    const MyVec = @Vector(3, f32);
    const v1 = MyVec{ 1.2, 2.3, 3.4 };
    const v2 = MyVec{ 9.8, 8.7, 7.6 };
    const v3 = v1 + v2;
    try expectEqual(v3[0], 1.2 + 9.8);
    try expectEqual(v3[1], 2.3 + 8.7);
    try expectEqual(v3[2], 3.4 + 7.6);

    // The @splat function creates a vector
    // where all elements have the same value.
    // The result must be assigned to a vector type
    // from which its length and element type are inferred.
    const n = 2;
    const twos: MyVec = @splat(n);
    const doubled = v1 * twos;
    try expectEqual(doubled[0], 1.2 * n);
    try expectEqual(doubled[1], 2.3 * n);
    try expectEqual(doubled[2], 3.4 * n);

    // The @reduce function performs a given operation on
    // all the elements of a vector and returns a single value.
    try expectEqual(@reduce(.Add, v1), 1.2 + 2.3 + 3.4);
    try expectEqual(@reduce(.Mul, v1), 1.2 * 2.3 * 3.4);
    try expectEqual(@reduce(.Min, v1), 1.2);
    try expectEqual(@reduce(.Max, v1), 3.4);
}
