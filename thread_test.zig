const std = @import("std");
const expectEqual = std.testing.expectEqual;
const print = std.debug.print;
const Thread = std.Thread;
const String = []const u8;

// Each thread has its own instance of this variable.
threadlocal var x: i32 = 1;

fn process(i: u8, message: String) !void {
    // print("process: running in thread {}\n", .{ currentThread.getName() });
    print("process: i = {}, message = {s}\n", .{ i, message });
    try expectEqual(x, 1);
    // Can call thread.yield() to suspend this thread
    // and allow another thread to run.
    x += 1;
    try expectEqual(x, 2);
}

test "thread local storage" {
    print("CPU count = {}\n", .{Thread.getCpuCount()});
    const threadCount = 3;
    var threads: [threadCount]Thread = undefined;

    var group = Thread.WaitGroup;

    var i: u8 = 0;
    while (i < threadCount) : (i += 1) {
        // The first argument to spawn is a SpawnConfig object
        // that can have stack_size (defaults to 16MB)
        // and allocator (defaults to null) fields.
        // The second argument is the function to run in the thread.
        // The third argument is a tuple of arguments to pass to the function.
        const thread = try Thread.spawn(.{}, process, .{ i + 1, "thread" });
        thread.setName("t" ++ @as(String, i));
        group.add(thread);

        // How can you add a Thread to a WaitGroup
        // so you can wait for the whole group to finish?
        // Must either call join or detach on each thread.
        thread.join(); // waits for thread to end

        threads[i] = thread;
    }

    try process(0, "main"); // runs in main thread
}
