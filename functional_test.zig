const std = @import("std");
const expectEqual = std.testing.expectEqual;
const String = []const u8;

const Fruit = struct {
    name: String,
    color: String,
    price: f32, // per pound
};

fn add(a: u8, b: u8) u8 {
    return a + b;
}

fn getPrice(fruit: Fruit) f32 {
    return fruit.price;
}

fn isRed(fruit: Fruit) bool {
    return std.mem.eql(fruit.color, "red");
}

fn Collection(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        list: std.ArrayList(T),

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, items: []const T) !Self {
            var list = try std.ArrayList(T).initCapacity(allocator, items.len);
            try list.appendSlice(items);
            return Self{ .allocator = allocator, .list = list };
        }

        pub fn filter(self: Self, function: fn (self.T) bool) !Self {
            var list = try std.ArrayList(self.T).initCapacity(self.allocator, self.list.len);
            for (self.list.items) |item| {
                if (function(item)) {
                    list.appendAssumeCapacity(item);
                }
            }
            return Self{ .T = self.T, .allocator = self.allocator, .list = list };
        }

        pub fn map(
            self: Self,
            comptime OutT: type,
            function: fn (self.T) OutT,
        ) !Self {
            var list = try std.ArrayList(OutT).initCapacity(self.allocator, self.list.len);
            for (self.list.items) |item| {
                try list.append(function(item));
            }
            return Self{ .T = self.T, .allocator = self.allocator, .list = list };
        }

        pub fn reduce(
            self: Self,
            OutT: type,
            function: fn (OutT, self.T) OutT,
            initial: OutT,
        ) OutT {
            var result = initial;
            for (self.list.items) |item| {
                result = function(result, item);
            }
            return result;
        }
    };
}

test Collection {
    const fruits = [_]Fruit{
        .{ .name = "apple", .color = "red", .price = 1.5 },
        .{ .name = "banana", .color = "yellow", .price = 0.25 },
        .{ .name = "orange", .color = "orange", .price = 0.75 },
        .{ .name = "cherry", .color = "red", .price = 3.0 },
    };

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    const FruitCollection = Collection(Fruit);
    const coll = FruitCollection.init(arena.allocator(), &fruits);
    defer arena.deinit();

    const redTotal = coll
        .filter(isRed)
        .map(f32, getPrice)
        .reduce(add, 0.0);

    try expectEqual(redTotal, 4.5);
}
