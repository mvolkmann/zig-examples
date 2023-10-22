const std = @import("std");
const print = std.debug.print;
const expectEqual = std.testing.expectEqual;
const String = []const u8;

const Fruit = struct {
    name: String,
    color: String,
    price: f32, // per pound
};

fn add(a: f32, b: f32) f32 {
    return a + b;
}

fn getPrice(fruit: Fruit) f32 {
    return fruit.price;
}

fn isRed(fruit: Fruit) bool {
    return std.mem.eql(u8, fruit.color, "red");
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

        pub fn filter(self: Self, comptime function: fn (T) bool) Self {
            var length = self.list.items.len;
            var list = std.ArrayList(T).initCapacity(self.allocator, length) catch @panic("filter failed");
            for (self.list.items) |item| {
                if (function(item)) {
                    list.appendAssumeCapacity(item);
                }
            }
            return Self{ .allocator = self.allocator, .list = list };
        }

        pub fn map(
            self: Self,
            comptime ItemT: type,
            comptime CollT: type,
            function: fn (T) ItemT,
        ) CollT {
            var length = self.list.items.len;
            var list = std.ArrayList(ItemT).initCapacity(self.allocator, length) catch @panic("map failed");
            for (self.list.items) |item| {
                list.append(function(item)) catch @panic("map failed to append");
            }
            return CollT{ .allocator = self.allocator, .list = list };
        }

        pub fn reduce(
            self: Self,
            comptime OutT: type,
            comptime function: fn (OutT, T) OutT,
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

const fruits = [_]Fruit{
    .{ .name = "apple", .color = "red", .price = 1.5 },
    .{ .name = "banana", .color = "yellow", .price = 0.25 },
    .{ .name = "orange", .color = "orange", .price = 0.75 },
    .{ .name = "cherry", .color = "red", .price = 3.0 },
};

test Collection {
    const FruitCollection = Collection(Fruit);
    const PriceCollection = Collection(f32);

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    const coll = try FruitCollection.init(arena.allocator(), &fruits);
    defer arena.deinit();

    const redTotal = coll
        .filter(isRed)
        .map(f32, PriceCollection, getPrice)
        .reduce(f32, add, 0.0);
    try expectEqual(redTotal, 4.5);
}

test "using for loop" {
    var redTotal: f32 = 0.0;
    for (fruits) |fruit| {
        if (std.mem.eql(u8, fruit.color, "red")) {
            redTotal += fruit.price;
        }
    }
    try expectEqual(redTotal, 4.5);
}
