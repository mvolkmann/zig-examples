const std = @import("std");
const expectEqual = std.testing.expectEqual;
const print = std.debug.print;

fn report(wrapper: ?i8) void {
    if (wrapper) |value| {
        print("value = {}\n", .{value});
    } else {
        print("value is null\n", .{});
    }
}

pub fn main() void {
    var wrapper: ?i8 = null;
    report(wrapper);
    wrapper = 19;
    report(wrapper);
}

test "choose" {
    const Car = struct {
        row: ?u8 = undefined,
        column: ?u8 = undefined,
        currentRow: ?u8 = undefined,
        currentColumn: ?u8 = undefined,
    };

    var car1 = Car{ .row = 2, .currentColumn = 3 };
    const current1 = car1.currentRow orelse car1.currentColumn;
    try expectEqual(@as(?u8, 3), current1);

    var car2 = Car{ .column = 2, .currentRow = 3 };
    const current2 = car2.currentRow orelse car2.currentColumn;
    try expectEqual(@as(?u8, 3), current2);
}
