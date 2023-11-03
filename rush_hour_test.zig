const std = @import("std");
const print = std.debug.print;
const bufPrint = std.fmt.bufPrint;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

const EXIT_ROW = 2;
const MAX_CARS = 16;
const SIZE = 6; // # of rows and columns on board
const BORDER = "+" ++ ("-" ** (SIZE * 2 + 1)) ++ "+";
const SPACE = ' ';

const stdout = std.io.getStdOut();
const sow = stdout.writer();

const String = []const u8;
const Board = ArrayList(String);

const Car = struct {
    row: ?u8 = undefined,
    column: ?u8 = undefined,
    currentRow: ?u8 = undefined,
    currentColumn: ?u8 = undefined,
};

const CarMap = std.AutoHashMap(u8, Car);

var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // can't be const
const allocator = gpa.allocator();

// This makes a deep copy of a board.
fn copyBoard(board: Board) !Board {
    var copy: [SIZE]String = undefined;
    for (board.items, 0..) |row, index| {
        copy[index] = try allocator.dupe(u8, row);
    }
    return copy;
}

test copyBoard {
    const puzzle = try getPuzzle();
    const board = try getBoard(puzzle);
    const copy = try copyBoard(board);
    try expectEqual(board, copy);
}

fn getPuzzle() !CarMap {
    var puzzle = CarMap.init(allocator);
    // defer puzzle.deinit();

    // Can these puts be performed at compile-time?
    try puzzle.put('A', .{ .row = 0, .currentColumn = 0 });
    try puzzle.put('B', .{ .column = 0, .currentRow = 4 });
    try puzzle.put('C', .{ .row = 4, .currentColumn = 4 });
    try puzzle.put('O', .{ .column = 5, .currentRow = 0 });
    try puzzle.put('P', .{ .column = 0, .currentRow = 1 });
    try puzzle.put('Q', .{ .column = 3, .currentRow = 1 });
    try puzzle.put('R', .{ .row = 5, .currentColumn = 2 });
    try puzzle.put('X', .{ .row = EXIT_ROW, .currentColumn = 1 });

    return puzzle;
}

fn carLength(letter: u8) u8 {
    return if (contains("OPQR", letter)) 3 else 2;
}

test carLength {
    try expectEqual(carLength('A'), 2);
    try expectEqual(carLength('P'), 3);
}

fn contains(string: String, char: u8) bool {
    for (string) |item| {
        if (item == char) return true;
    }
    return false;
}

test contains {
    try expect(contains("Hello", 'e'));
    try expect(!contains("Hello", 'x'));
}

fn createMove(letter: u8, direction: String, distance: u8) !String {
    // TODO: Describe allocPrint in blog.
    return try std.fmt.allocPrint(
        allocator,
        "{c} {s} {d}",
        .{ letter, direction, distance },
    );
}

test createMove {
    const move = try createMove('A', "left", 3);
    try expectEqualStrings("A left 3", move);
}

// This creates a 2D array of car letters for a given puzzle.
fn getBoard(cars: CarMap) !Board {
    if (cars.get('X') == null) {
        @panic("Puzzle is missing car X!");
    }

    var board = try Board.initCapacity(allocator, SIZE);
    //TODO: Caller will need to deinit this.

    // Create an empty board.
    for (0..SIZE) |_| {
        const boardRow = [_]u8{SPACE} ** SIZE;
        try board.append(&boardRow);
    }

    // Add cars to the board.
    const letters = try getLetters(cars);
    for (letters) |letter| {
        if (cars.get(letter)) |car| {
            const length = carLength(letter);

            if (isHorizontal(car)) {
                if (car.currentColumn) |start| {
                    const end = start + length;
                    if (car.row) |row| {
                        var boardRow = board.items[row];
                        var newBoardRow = try allocator.dupe(u8, boardRow);
                        for (start..end) |column| {
                            // Check if another car already occupies this cell.
                            // If so then there is a error in the puzzle description.
                            const existing = boardRow[column];
                            if (existing != SPACE) {
                                var buffer: [20]u8 = undefined;
                                const message = bufPrint(
                                    &buffer,
                                    "Car {} overlaps car {}",
                                    .{ letter, existing },
                                ) catch @panic("bufPrint failed");
                                @panic(message);
                            }

                            newBoardRow[column] = letter;
                        }
                        board.items[row] = newBoardRow;
                    }
                }
            } else if (car.currentRow) |start| { // should always be defined
                // The car is vertical.
                const column = car.column orelse 0; // should always be defined
                const end = start + length;
                for (start..end) |row| {
                    const boardRow = board.items[row];

                    // Check if another car already occupies this cell.
                    // If so then there is a error in the puzzle description.
                    const existing = boardRow[column];
                    if (existing != SPACE) {
                        const temp1 = [_]u8{letter};
                        const temp2 = [_]u8{existing};
                        @panic("Car " ++ temp1 ++ " overlaps car " ++ temp2 ++ "!");
                    }

                    //TODO: Is this the best way to update one character in a string inside an ArrayList?
                    var newBoardRow = try allocator.dupe(u8, boardRow);
                    newBoardRow[column] = letter;
                    board.items[row] = newBoardRow;
                }
            }
        }
    }

    return board;
}

test getBoard {
    const puzzle = try getPuzzle();
    const board = try getBoard(puzzle);
    const expected = [_]String{
        "AA   O",
        "P  Q O",
        "PXXQ O",
        "P  Q  ",
        "B   CC",
        "B RRR ",
    };

    for (board.items, 0..) |row, index| {
        try expectEqualStrings(expected[index], row);
    }
}

fn getLetters(cars: CarMap) ![]u8 {
    var letters = std.ArrayList(u8).init(allocator);
    defer letters.deinit();

    var iter = cars.keyIterator();
    while (iter.next()) |key| {
        try letters.append(key.*);
    }

    return allocator.dupe(u8, letters.items);
}

test getLetters {
    const puzzle = try getPuzzle();
    const letters = try getLetters(puzzle);
    try expectEqualStrings("RPXACQOB", letters);
}

inline fn isHorizontal(car: Car) bool {
    return car.row != undefined;
}

test isHorizontal {
    var car = Car{ .row = 4, .currentColumn = 4 };
    try expect(isHorizontal(car));
    car = Car{ .column = 3, .currentRow = 1 };
    try expect(!isHorizontal(car));
}

fn printBoard(writer: anytype, board: Board) !void {
    println(writer, BORDER);
    for (board.items, 0..) |row, index| {
        _ = index;
        // var buffer: [16]u8 = undefined;
        // defer allocator.free(buffer);
        // var fbs = std.io.fixedBufferStream(&buffer);
        // const writer = fbs.writer();
        // _ = try writer.write("| ");
        // // for (row) |letter| {
        // //     try writer.print("{} ", .{letter});
        // // }
        // if (index != EXIT_ROW) {
        //     _ = try writer.write("|");
        // }
        // printString(fbs.getWritten());
        printString(writer, "|");
        for (row) |letter| {
            try writer.print(" {c}", .{letter});
        }
        println(writer, " |");
    }
    println(writer, BORDER);
}

test printBoard {
    var buffer: [200]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var writer = fbs.writer();

    const puzzle = try getPuzzle();
    const board = try getBoard(puzzle);
    try printBoard(writer, board);

    const actual = fbs.getWritten();
    const expected =
        \\+-------------+
        \\| A A       O |
        \\| P     Q   O |
        \\| P X X Q   O |
        \\| P     Q     |
        \\| B       C C |
        \\| B   R R R   |
        \\+-------------+
        \\
    ;
    try expectEqualStrings(expected, actual);
}

fn printChar(writer: anytype, char: u8) void {
    // This ignores errors.
    writer.print("{c} ", .{char}) catch {};
}

fn printString(writer: anytype, string: String) void {
    // This ignores errors.
    writer.print("{s}", .{string}) catch {};
}

fn println(writer: anytype, string: String) void {
    // This ignores errors.
    writer.print("{s}\n", .{string}) catch {};
}
