const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "vector" {
    // The benefit is most apparent when the length is large.
    // The length cannot be inferred using _.
    const v1 = @Vector(3, f32){ 1.2, 2.3, 3.4 };
    const v2 = @Vector(3, f32){ 9.8, 8.7, 7.6 };
    const v3 = v1 + v2;
    try expectEqual(v3[0], 1.2 + 9.8);
    try expectEqual(v3[1], 2.3 + 8.7);
    try expectEqual(v3[2], 3.4 + 7.6);
}
