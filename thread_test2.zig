const std = @import("std");
const print = std.debug.print;
const Thread = std.Thread;

fn process(i: u8) !void {
    print("i = {}\n", .{i});
}

test "threads with join" {
    var i: u8 = 0;
    while (i < 3) : (i += 1) {
        const thread = try Thread.spawn(.{}, process, .{i});
        thread.join();
    }
}
