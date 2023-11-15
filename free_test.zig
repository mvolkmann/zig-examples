const std = @import("std");
const Allocator = std.mem.Allocator;

const String = []const u8;

const State = struct {
    move: ?String,

    pub fn deinit(self: *State, allocator: std.mem.Allocator) void {
        if (self.move) |move| allocator.free(move);
    }
};

fn createMove(
    allocator: Allocator,
    letter: u8,
    direction: String,
) !String {
    return try std.fmt.allocPrint(
        allocator,
        "{c} {s}",
        .{ letter, direction },
    );
}

test "State deinit" {
    const allocator = std.testing.allocator;
    const move = try createMove(allocator, 'A', "right");

    var state_ptr = try allocator.create(State);
    state_ptr.move = move;

    defer {
        state_ptr.deinit(allocator);
        allocator.destroy(state_ptr);
    }
}
