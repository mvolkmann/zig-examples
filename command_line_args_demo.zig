// To run this, enter something like
// zig run commmand_line_args_demo.zig -- foo bar
// arg 0 will be the path to the executable,
// arg 1 will be "foo", and arg 2 will be "bar".
const std = @import("std");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

fn getCmdLineArgs(list: anytype) !void {
    var iter = std.process.args();
    while (iter.next()) |arg| {
        try list.append(arg);
    }
}

pub fn main() !void {
    // It's inconvenient to access commmand-line arguments using an iterator.
    // This copies them into an ArrayList.
    var args = std.ArrayList([]const u8).init(allocator);
    defer args.deinit();
    try getCmdLineArgs(&args);

    print("arg count is {d}\n", .{args.items.len});
    print("second arg is {s}\n", .{args.items[1]});
    for (args.items) |arg| {
        print("{s}\n", .{arg});
    }
}
