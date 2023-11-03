const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const expectStringEndsWith = std.testing.expectStringEndsWith;
const expectStringStartsWith = std.testing.expectStringStartsWith;

const String = []const u8;

test "basic" {
    // s is a pointer to the string.
    const s = "Hello, world!";
    const T = @TypeOf(s);
    // 13 is the length and 0 is the sentinel (terminator) value.
    try expectEqualStrings(@typeName(T), "*const [13:0]u8");
}

test "chars" {
    const name = [_]u8{ 'M', 'a', 'r', 'k' };
    try expectEqualStrings(&name, "Mark");
}

test "multiline" {
    const singleLine = "Out of memory.\nWe wish to hold the whole sky,\nBut we never will.";
    const multiline =
        \\Out of memory.
        \\We wish to hold the whole sky,
        \\But we never will.
    ;
    try expectEqualStrings(singleLine, multiline);
}

test "starts and ends with" {
    const s = "abcde";
    try expect(std.mem.startsWith(u8, s, "ab"));
    try expectStringStartsWith(s, "ab");
    try expect(std.mem.endsWith(u8, s, "de"));
    try expectStringEndsWith(s, "de");
}

test "bufPrint" {
    var buffer: [20]u8 = undefined;
    const result = try std.fmt.bufPrint(
        &buffer,
        "{d} {s} {d}",
        .{ 'A', "Hello", 19 },
    );
    try expectEqualStrings("65 Hello 19", result);
}

test "fixedBufferStream" {
    var buffer: [20]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var writer = fbs.writer();
    _ = try writer.write("one"); // returns # of bytes written
    try writer.print("-{s}", .{"two"});
    try writer.print("-{s}", .{"three"});
    try expectEqualStrings("one-two-three", fbs.getWritten());
}

test "split" {
    const expected = [_]String{ "red", "green", "", "", "blue" };

    const colors1 = "red,green,,,blue";
    // This returns an iterator that provides values obtained by
    // splitting on a single delimiter that is a single value.
    var iter1 = std.mem.splitScalar(u8, colors1, ',');
    var index: u8 = 0;
    while (iter1.next()) |color| {
        try expectEqualStrings(expected[index], color);
        index += 1;
    }

    const colors2 = "red;-)green;-);-);-)blue";
    // This returns an iterator that provides values obtained by
    // splitting on a single delimiter that is a sequence of values.
    var iter2 = std.mem.splitSequence(u8, colors2, ";-)");
    index = 0;
    while (iter2.next()) |color| {
        try expectEqualStrings(expected[index], color);
        index += 1;
    }

    var colors3 = "red,green,; blue";
    // This returns an iterator that provides values obtained by
    // splitting on any one of the given delimiters.
    var iter3 = std.mem.splitAny(u8, colors3, ",; ");
    index = 0;
    while (iter3.next()) |color| {
        try expectEqualStrings(expected[index], color);
        index += 1;
    }
}

test "tokenize" {
    const expected = [_]String{ "red", "green", "blue" };

    const colors1 = "red,green,,,blue";
    // This returns an iterator that provides values obtained by
    // splitting on a single delimiter that is a single value.
    var iter1 = std.mem.tokenizeScalar(u8, colors1, ',');
    var index: u8 = 0;
    while (iter1.next()) |color| {
        try expectEqualStrings(expected[index], color);
        index += 1;
    }

    const colors2 = "red;-)green;-);-);-)blue";
    // This returns an iterator that provides values obtained by
    // splitting on a single delimiter that is a sequence of values.
    var iter2 = std.mem.tokenizeSequence(u8, colors2, ";-)");
    index = 0;
    while (iter2.next()) |color| {
        try expectEqualStrings(expected[index], color);
        index += 1;
    }

    var colors3 = "red,green,; ,; blue";
    // This returns an iterator that provides values obtained by
    // splitting on any one of the given delimiters.
    var iter3 = std.mem.tokenizeAny(u8, colors3, ",; ");
    index = 0;
    while (iter3.next()) |color| {
        try expectEqualStrings(expected[index], color);
        index += 1;
    }
}

test "iterate over characters" {
    const text = "Hello";
    for (text, 0..) |letter, index| {
        try expectEqual(text[index], letter);
    }
}
