const std = @import("std");
const print = std.debug.print;

// Creates and writes a file in the current working directory.
fn writeFile() !void {
    const dir = std.fs.cwd();
    const file = try dir.createFile("data.txt", .{});
    defer file.close();

    try file.writeAll("Hello, World!");
}

// Reads a file in the current working directory.
fn readFile() !void {
    const dir = std.fs.cwd();
    const file = try dir.openFile("data.txt", .{});
    defer file.close();

    var buffer: [100]u8 = undefined;
    const length = try file.readAll(&buffer);
    print("read {} bytes\n", .{length}); // 13
    const content = buffer[0..length];
    print("{s}\n", .{content}); // Hello, World!
}

pub fn main() !void {
    try writeFile();
    try readFile();
}
