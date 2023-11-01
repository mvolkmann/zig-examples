const std = @import("std");
const print = std.debug.print;
const String = []const u8;

pub fn main() !void {
    var config = .{ .safety = true, .verbose_log = true };
    var gpa = std.heap.GeneralPurposeAllocator(config){};
    defer {
        // The defer method must be called on the gpa instance
        // in order for memory leaks to be detected.
        // check is a enum with the values "ok" and "leak"
        const check = gpa.deinit();
        print("leak? {}\n", .{check == .leak});
    }
    // This is a shorter way to call deinit which ignores the return value.
    // defer _ = gpa.deinit();

    var allocator = gpa.allocator();
    var list = std.ArrayList(String).init(allocator);
    // defer list.deinit(); // purposely leaking memory
    try list.append("red");
    print("len = {}\n", .{list.items.len});
}
