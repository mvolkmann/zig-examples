const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "vectors" {
    // The benefit of using vectors is most apparent when
    // the length is large and SIMD operations are performed on it.

    // The length of a new vector cannot be inferred using _.
    const MyVec = @Vector(3, f32);
    const v1 = MyVec{ 1.2, 2.3, 3.4 };

    // Elements can be accessed just like with arrays and slices.
    try expectEqual(v1[0], 1.2);
    try expectEqual(v1[1], 2.3);
    try expectEqual(v1[2], 3.4);

    // Can create a vector from an array or slice with assignment.
    const arr1 = [_]f32{ 1.2, 2.3, 3.4 };
    const vFromArr: @Vector(3, f32) = arr1;

    // Can create an array from a vector with assignment.
    const arr2: [3]f32 = vFromArr;
    try expectEqual(arr1, arr2);

    // To iterate over vector elements,
    // create an array from it and iterate over the array.

    // Can add two vectors.
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

test "has SIMD" {
    // Typically code logic doesn't depend on CPU-specific features.
    // @Vector is CPU independent outside of the
    // number of elements that can be processed simultaneously.
    const target = try std.zig.system.NativeTargetInfo.detect(.{});
    const cpu = target.target.cpu;
    // This assumes that the target is an ARM processor
    // such as Apple's M processors.
    // Apple calls their SIMD feature Neon.
    try expect(std.Target.arm.featureSetHas(cpu.features, .neon));
}