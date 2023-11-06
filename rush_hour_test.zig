const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqualStrings = std.testing.expectEqualStrings;

const SIZE = 6; // # of rows and columns on board
const BORDER = "+" ++ ("-" ** (SIZE * 2 + 1)) ++ "+";
const EXIT_ROW = 2;
const MAX_CARS = 16;
const SPACE = ' ';

const stdout = std.io.getStdOut();
const sow = stdout.writer();

const String = []const u8;
const Row = [SIZE]u8;
const Board = [SIZE]Row;

const Car = struct {
    row: ?u8 = undefined,
    column: ?u8 = undefined,
    current_row: ?u8 = undefined,
    current_column: ?u8 = undefined,
};

const CarMap = std.AutoHashMap(u8, Car);

const State = struct {
    move: ?String,
    cars: CarMap, // keys are letters and values are Car structs
    board: Board,
    previous_state: ?*State,
};

// Need to use std.testing.allocator to detect memory leaks.
// var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // can't be const
// const allocator = gpa.allocator();
const allocator = std.testing.allocator;

// NEED addHorizontalMoves function.
// NEED addVerticalMoves function.
// NEED addMoves function.
// NEED addPendingState function.

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

// This makes a deep copy of a board.
fn copyBoard(board: Board) !Board {
    var copy: Board = board;
    return copy;
}

test copyBoard {
    var puzzle = try getPuzzle();
    defer puzzle.deinit();

    const board = try getBoard(puzzle);
    const copy = try copyBoard(board);
    try expect(&copy != &board);
    try expect(&copy[0] != &board[0]);
    try expectEqualSlices(u8, &board[0], &copy[0]);
    try expectEqualSlices(Row, &board, &copy);
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
    defer allocator.free(move);
    try expectEqualStrings("A left 3", move);
}

// This creates a 2D array of car letters for a given puzzle.
fn getBoard(cars: CarMap) !Board {
    if (cars.get('X') == null) {
        @panic("Puzzle is missing car X!");
    }

    // Create an empty board.
    var board: Board = .{.{SPACE} ** SIZE} ** SIZE;

    const letters = try getLetters(cars);
    defer allocator.free(letters);

    // Add cars to the board.
    for (letters) |letter| {
        if (cars.get(letter)) |car| {
            const length = carLength(letter);

            if (isHorizontal(car)) {
                if (car.current_column) |start| {
                    const end = start + length;
                    if (car.row) |row| {
                        var board_row = &board[row];
                        for (start..end) |column| {
                            // Check if another car already occupies this cell.
                            // If so then there is a error in the puzzle description.
                            const existing = board_row[column];
                            if (existing != SPACE) {
                                try overlapPanic(letter, existing);
                            }

                            board_row[column] = letter;
                        }
                    }
                }
            } else if (car.current_row) |start| { // should always be defined
                // The car is vertical.
                const column = car.column orelse 0; // should always be defined
                const end = start + length;
                for (start..end) |row| {
                    var board_row = &board[row];

                    // Check if another car already occupies this cell.
                    // If so then there is a error in the puzzle description.
                    const existing = board_row[column];
                    if (existing != SPACE) {
                        try overlapPanic(letter, existing);
                    }

                    board_row[column] = letter;
                }
            }
        }
    }

    return board;
}

test getBoard {
    var puzzle = try getPuzzle();
    defer puzzle.deinit();

    const board = try getBoard(puzzle);
    const expected = [_]String{
        "AA   O",
        "P  Q O",
        "PXXQ O",
        "P  Q  ",
        "B   CC",
        "B RRR ",
    };

    for (board, 0..) |row, index| {
        try expectEqualStrings(expected[index], &row);
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
    var puzzle = try getPuzzle();
    defer puzzle.deinit();

    const letters = try getLetters(puzzle);
    defer allocator.free(letters);
    try expectEqualStrings("RPXACQOB", letters);
}

fn getPuzzle() !CarMap {
    var puzzle = CarMap.init(allocator);

    // Can these puts be performed at compile-time?
    try puzzle.put('A', .{ .row = 0, .current_column = 0 });
    try puzzle.put('B', .{ .column = 0, .current_row = 4 });
    try puzzle.put('C', .{ .row = 4, .current_column = 4 });
    try puzzle.put('O', .{ .column = 5, .current_row = 0 });
    try puzzle.put('P', .{ .column = 0, .current_row = 1 });
    try puzzle.put('Q', .{ .column = 3, .current_row = 1 });
    try puzzle.put('R', .{ .row = 5, .current_column = 2 });
    try puzzle.put('X', .{ .row = EXIT_ROW, .current_column = 1 });

    return puzzle;
}

// This returns a string that uniquely describes a board state,
// but only for the current puzzle.
// We only need the current row or column for each car
// as a string of numbers from 0 to 5.
fn getStateId(cars: CarMap) String {
    var positions: [MAX_CARS]u8 = undefined;
    // This assumes that the order of the cars returned never changes.
    var iter = cars.valueIterator();
    var i: u8 = 0;
    while (iter.next()) |car| {
        const number = car.current_row orelse car.current_column orelse 0;
        positions[i] = number + 48; // converts to ASCII
        i += 1;
    }
    return positions[0..i];
}

test getStateId {
    var puzzle = try getPuzzle();
    defer puzzle.deinit();

    const stateId = getStateId(puzzle);
    try expectEqualStrings("21104104", stateId);
}

// The goal is reached when there are no cars blocking the X car from the exit.
fn isGoalReached(board: Board, cars: CarMap) bool {
    // Get the column after the end of the X car.
    // This assumes the X car length is 2.
    if (cars.get('X')) |car| {
        if (car.current_column) |current_column| {
            const start_column = current_column + 2;
            const exit_row = board[EXIT_ROW];

            // Check for cars blocking the exit.
            for (start_column..SIZE) |column| {
                if (exit_row[column] != SPACE) return false;
            }
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

test isGoalReached {
    var puzzle = try getPuzzle();
    defer puzzle.deinit();

    const board = try getBoard(puzzle);
    try expect(!isGoalReached(board, puzzle));

    //TODO: Add a test where the goal IS reached.
}

inline fn isHorizontal(car: Car) bool {
    return car.row != undefined;
}

test isHorizontal {
    var car = Car{ .row = 4, .current_column = 4 };
    try expect(isHorizontal(car));
    car = Car{ .column = 3, .current_row = 1 };
    try expect(!isHorizontal(car));
}

fn overlapPanic(letter: u8, existing: u8) !void {
    const message = try std.fmt.allocPrint(
        allocator,
        "Car {c} overlaps car {c}!",
        .{ letter, existing },
    );
    @panic(message);
}

fn printBoard(writer: anytype, board: Board) !void {
    println(writer, BORDER);
    for (board) |row| {
        printString(writer, "|");
        for (row) |letter| {
            const char = if (letter == 0) SPACE else letter;
            try writer.print(" {c}", .{char});
        }
        println(writer, " |");
    }
    println(writer, BORDER);
}

test printBoard {
    var buffer: [200]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var writer = fbs.writer();

    var puzzle = try getPuzzle();
    defer puzzle.deinit();

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

// NEED printMoves function.

fn printString(writer: anytype, string: String) void {
    // This ignores errors.
    writer.print("{s}", .{string}) catch {};
}

fn println(writer: anytype, string: String) void {
    // This ignores errors.
    writer.print("{s}\n", .{string}) catch {};
}

// This sets the board letter used in a range of rows for a given column.
fn setColumn(board: anytype, column: u8, start_row: u8, length: u8, letter: u8) void {
    for (start_row..start_row + length) |row| {
        board[row][column] = letter;
    }
}

test setColumn {
    var puzzle = try getPuzzle();
    defer puzzle.deinit();

    var board = try getBoard(puzzle);

    const column = 3;
    const start_row = 1;
    const length = 2;
    const letter = 'A';
    setColumn(&board, column, start_row, length, letter);
    try expectEqual(board[start_row][column], letter);
    try expectEqual(board[start_row + 1][column], letter);
}

fn setRow(board: anytype, row: u8, start_column: u8, length: u8, letter: u8) void {
    var board_row = &board[row];
    for (start_column..start_column + length) |column| {
        board_row[column] = letter;
    }
}

test setRow {
    var puzzle = try getPuzzle();
    defer puzzle.deinit();

    var board = try getBoard(puzzle);

    const row = 3;
    const start_column = 1;
    const length = 2;
    const letter = 'A';
    setRow(&board, row, start_column, length, letter);
    try expectEqual(board[row][start_column], letter);
    try expectEqual(board[row][start_column + 1], letter);
}

// NEED solve function.

// NEED main function.
