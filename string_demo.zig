const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const String = @import("./zig-string.zig").String;

test "strings" {
    const allocator = std.testing.allocator;

    var myString = String.init(allocator);
    defer myString.deinit();

    // Use functions provided
    try myString.concat("abc");
    _ = myString.pop();
    assert(myString.cmp("ab"));
    try myString.concat("cde");

    assert(myString.cmp("abcde"));
    assert(myString.len() == 5);

    // TODO: This is not working!
    // const mySubstr = myString.substr(1, 3);
    // print("mySubstr = {any}\n", .{mySubstr});

    myString.toUppercase(); // modifies in place
    assert(myString.cmp("ABCDE"));

    myString.toLowercase(); // modifies in place
    assert(myString.cmp("abcde"));

    var copy = try myString.clone();
    defer copy.deinit();
    copy.reverse(); // modifies in place
    assert(copy.cmp("edcba"));

    assert(!myString.isEmpty());
    myString.clear();
    assert(myString.isEmpty());

    var santa = try String.init_with_contents(allocator, "Ho");
    defer santa.deinit();
    assert(santa.cmp("Ho"));
    try santa.repeat(2); // will have 3 occurrences after this
    assert(santa.cmp("HoHoHo"));

    // TODO: Why must this be var and not const?
    var colors = try String.init_with_contents(allocator, "red,green,blue");
    defer colors.deinit();
    // Splits into []u8 slices.
    if (colors.split(",", 0)) |c1| {
        assert(std.mem.eql(u8, c1, "red"));
        if (colors.split(",", 4)) |c2| {
            assert(std.mem.eql(u8, c2, "green"));
        }
    }
    // Splits into String slices.
    // if (colors.splitToString(",", 0)) |c1| {
    //     assert(c1.cmp("red"));
    //     if (colors.split(",", 4)) |c2| {
    //         assert(c2.cmp("green"));
    //     }
    // }
}
