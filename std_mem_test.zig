const std = @import("std");
const print = std.debug.print;
const allocator = std.testing.allocator;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const String = []const u8;

const Dog = struct {
    name: String,
    breed: String,
};

test "std.mem" {
    const s = "foo^bar^baz";

    // Using var instead of const so it can be sorted.
    var numbers = [_]u32{ 21, 19, 42, 7, 13 };

    try expectEqual(std.mem.count(u8, s, "^"), 2);
    try expect(std.mem.endsWith(u8, s, "baz"));
    try expect(std.mem.eql(u8, s, "foo^bar^baz"));
    try expectEqual(std.mem.indexOf(u8, s, "^"), 3);
    try expect(std.mem.startsWith(u8, s, "foo"));

    try expectEqual(std.mem.indexOfMax(u32, &numbers), 2);
    try expectEqual(std.mem.indexOfMin(u32, &numbers), 3);
    try expectEqual(std.mem.indexOfMinMax(u32, &numbers), .{ .index_min = 3, .index_max = 2 });
    try expectEqual(std.mem.indexOfScalar(u32, &numbers, 19), 1);

    const strings = [_]String{ "foo", "bar", "baz" };
    const joined = try std.mem.join(allocator, "^", &strings);
    defer allocator.free(joined);
    try expectEqualStrings(joined, "foo^bar^baz");

    try expectEqual(std.mem.lastIndexOf(u8, s, "^"), 7);
    try expectEqual(std.mem.lastIndexOfScalar(u32, &numbers, 7), 3);

    try expect(std.mem.lessThan(u8, "bar", "foo"));
    try expect(!std.mem.lessThan(u8, "foo", "bar"));
    // There is no greaterThan function.

    try expectEqual(std.mem.max(u32, &numbers), 42);
    try expectEqual(std.mem.min(u32, &numbers), 7);
    try expectEqual(std.mem.minMax(u32, &numbers), .{ .min = 7, .max = 42 });

    // Will get "out of bounds for array" if not long enough.
    var buffer: [30]u8 = undefined;
    const times = std.mem.replace(u8, s, "^", "-", &buffer);
    try expectEqual(times, 2);
    const expectedReplacement = "foo-bar-baz";
    try expectEqualStrings(buffer[0..expectedReplacement.len], expectedReplacement);

    std.mem.replaceScalar(u32, &numbers, 42, 0);
    const expectedNumbers = [_]u32{ 21, 19, 0, 7, 13 };
    try expectEqual(numbers, expectedNumbers);

    std.mem.sort(u32, &numbers, {}, lessThanU32);
    try expectEqual(numbers, .{ 0, 7, 13, 19, 21 });

    var dogs = [_]Dog{
        .{ .name = "Oscar", .breed = "German Shorthaired Pointer" },
        .{ .name = "Comet", .breed = "Whippet" },
        .{ .name = "Ramsay", .breed = "Native American Indian Dog" },
    };
    std.mem.sort(Dog, &dogs, {}, stringField(Dog, "name").lessThan);
    try expectEqualStrings(dogs[0].name, "Comet");
    try expectEqualStrings(dogs[1].name, "Oscar");
    try expectEqualStrings(dogs[2].name, "Ramsay");

    const expectedPieces = [_]String{ "foo", "bar", "baz" };
    var iter = std.mem.splitScalar(u8, s, '^');
    var index: u8 = 0;
    while (iter.next()) |color| {
        try expectEqualStrings(expectedPieces[index], color);
        index += 1;
    }

    var words = [_]String{ "foo", "bar", "baz" };
    std.mem.swap(String, &words[0], &words[2]);
    try expectEqualStrings(words[0], "baz");
    try expectEqualStrings(words[2], "foo");

    const padded = "  foo bar  ";
    try expectEqualStrings(std.mem.trim(u8, padded, " "), "foo bar");
    try expectEqualStrings(std.mem.trimLeft(u8, padded, " "), "foo bar  ");
    try expectEqualStrings(std.mem.trimRight(u8, padded, " "), "  foo bar");

    // TODO: Add more examples of functions past the last one tested above.
}

fn isNumber(v: anytype) bool {
    return std.meta.trait.isNumber(@TypeOf(v));
}

fn isString(v: anytype) bool {
    return std.meta.trait.isZigString(@TypeOf(v));
}

fn lessThanU32(_: void, lhs: u32, rhs: u32) bool {
    return lhs < rhs;
}

// This can be used to sort Struct instances on a given string field.
fn stringField(comptime T: type, comptime field: String) type {
    return struct {
        fn lessThan(
            _: void,
            lhs: T,
            rhs: T,
        ) bool {
            const left = @field(lhs, field);
            const right = @field(rhs, field);
            return std.mem.lessThan(u8, left, right);
        }
    };
}
