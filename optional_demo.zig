const std = @import("std");
const expectEqual = std.testing.expectEqual;
const print = std.debug.print;
const String = []const u8;

fn report(wrapper: ?i8) void {
    if (wrapper) |value| {
        print("value = {}\n", .{value});
    } else {
        print("value is null\n", .{});
    }
}

pub fn main() void {
    var wrapper: ?i8 = null;
    report(wrapper);
    wrapper = 19;
    report(wrapper);
}

test "optional" {
    var a: i8 = 0;
    var b: ?i8 = null;
    try expectEqual(@as(i8, 0), a);
    try expectEqual(@as(?i8, null), b);

    a = 1;
    b = 2;
    try expectEqual(@as(i8, 1), a);
    try expectEqual(@as(?i8, 2), b);

    // The orelse operator unwraps the value if non-null
    // and uses the value that follows if null.
    // This is why the cast here is to i8 instead of ?i8.
    try expectEqual(@as(i8, 2), b orelse 0);

    // "b.?" is equivalent to "b orelse unreachable".
    // It unwraps the value which is why the cast here is to i8 instead of ?i8.
    try expectEqual(@as(i8, 2), b.?);

    b = null;
    try expectEqual(@as(?i8, null), b);
    try expectEqual(@as(i8, 0), b orelse 0);
    // _ = b.?; // results in "panic: attempt to use null value"
}

test "dogs" {
    const Dog = struct {
        name: ?String = undefined,
        breed: ?String = undefined,
    };

    const dog1 = Dog{ .name = "Comet", .breed = "Whippet" };
    const dog2 = Dog{ .name = "Oscar" };
    const dog3 = Dog{ .breed = "Beagle" };
    const dog4 = Dog{};
    const dogs = [_]Dog{ dog1, dog2, dog3, dog4 };

    for (dogs) |dog| {
        if (dog.name) |name| print("name = {s}\n", .{name});
        if (dog.breed) |breed| print("breed = {s}\n", .{breed});

        const present1 = dog.name orelse dog.breed orelse "unknown";
        print("present1 = {s}\n", .{present1});

        // const present2 = dog.name ?? dog.breed ?? "unknown";
        // print("present2 = {s}\n", .{present2});
    }
}

test "choose" {
    const Car = struct {
        row: ?u8 = undefined,
        column: ?u8 = undefined,
        currentRow: ?u8 = undefined,
        currentColumn: ?u8 = undefined,
    };

    var car1 = Car{ .row = 2, .currentColumn = 3 };
    const current1 = car1.currentRow orelse car1.currentColumn;
    try expectEqual(@as(?u8, 3), current1);

    var car2 = Car{ .column = 2, .currentRow = 3 };
    const current2 = car2.currentRow orelse car2.currentColumn;
    try expectEqual(@as(?u8, 3), current2);
}
