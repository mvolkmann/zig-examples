const std = @import("std");
const String = []const u8;
const print = std.debug.print;

fn log(text: String) void {
    print("{s}\n", .{text});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // can't be const
    var la = std.heap.loggingAllocator(gpa.allocator()); // can't be const
    const allocator = la.allocator();

    var list = std.ArrayList(String).init(allocator);
    // var list = try std.ArrayList(String).initCapacity(allocator, 500);
    defer list.deinit();

    log("appending red");
    try list.append("red"); // allocates 128 bytes
    log("appending orange");
    try list.append("orange");
    log("appending yellow");
    try list.append("yellow");
    log("appending green");
    try list.append("green");
    log("appending blue");
    try list.append("blue");
    log("appending purple");
    try list.append("purple");
    log("appending white");
    try list.append("white");
    log("appending gray");
    try list.append("gray");
    log("appending black");
    try list.append("black"); // allocs 320 bytes & deallocs previous 128 bytes
    log("appending brown");
    try list.append("brown");

    for (list.items) |color| {
        log(color);
    }

    log("end of main"); // frees 320 bytes
}
