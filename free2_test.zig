const std = @import("std");

const State = struct {
    scores: [3]u32,

    pub fn deinit(self: *State, allocator: std.mem.Allocator) void {
        // There is no need to do this when scores is an array.
        allocator.free(self.scores);
    }
};

test "State deinit" {
    const allocator = std.testing.allocator;
    var state_ptr = try allocator.create(State);
    state_ptr.scores = [3]u32{ 1, 2, 3 };

    defer {
        // state_ptr.deinit(allocator);
        allocator.destroy(state_ptr);
    }
}
