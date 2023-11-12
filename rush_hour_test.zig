const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
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
    move: ?String, // The first state doesn't have a move value.
    cars: CarMap, // keys are letters and values are Car structs
    board: Board,
    previous_state: ?*State,
};

const PendingStatesList = std.SinglyLinkedList(*State);
const PendingStatesNode = PendingStatesList.Node;

// Use this allocator to check for memory leaks.
const testAlloc = std.testing.allocator;

// Use this allocator to avoid checking for memory leaks.
// var gpa = std.heap.GeneralPurposeAllocator(.{}){};
// const testAlloc = gpa.allocator();

// These objects describe states that still need to be evaluated
// and will not necessarily be part of the solutions.
// This is key to implementing a breadth-first search.
// Each test that relies on pending_states must
// create a new, empty SinglyLinkedList.
var pending_states = PendingStatesList{};

// NEED addHorizontalMoves function.
// NEED addVerticalMoves function.
// NEED addMoves function.

fn addPendingState(
    allocator: Allocator,
    board: Board,
    cars: CarMap,
    move: ?String,
) !void {
    var statePtr = try allocator.create(State);
    statePtr.board = board;
    statePtr.cars = cars;
    statePtr.move = move;

    var node_ptr = try allocator.create(PendingStatesNode);
    node_ptr.data = statePtr;
    pending_states.prepend(node_ptr);
}

test addPendingState {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    pending_states = PendingStatesList{};

    var puzzle = try getPuzzle(allocator);
    defer puzzle.deinit();

    const board = try getBoard(allocator, puzzle);

    // Add a move.
    var move1 = try createMove(allocator, 'A', "right", 2);
    try addPendingState(allocator, board, puzzle, move1);

    // Add another move.
    var move2 = try createMove(allocator, 'B', "down", 3);
    try addPendingState(allocator, board, puzzle, move2);

    try expectEqual(pending_states.len(), 2);

    // Test the first state in the list.
    var node = pending_states.first orelse unreachable;
    var statePtr = node.data;
    try expectEqual(statePtr.board, board);
    try expectEqual(statePtr.cars, puzzle);
    try expectEqual(statePtr.move, move2);

    // Test the next state in the list.
    node = node.next orelse unreachable;
    statePtr = node.data;
    try expectEqual(statePtr.board, board);
    try expectEqual(statePtr.cars, puzzle);
    try expectEqual(statePtr.move, move1);
    try expectEqual(node.next, null);
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

// This makes a deep copy of a board.
fn copyBoard(board: Board) !Board {
    var copy: Board = board;
    return copy;
}

test copyBoard {
    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    const board = try getBoard(testAlloc, puzzle);
    const copy = try copyBoard(board);
    try expect(&copy != &board);
    try expect(&copy[0] != &board[0]);
    try expectEqualSlices(u8, &board[0], &copy[0]);
    try expectEqualSlices(Row, &board, &copy);
}

fn createMove(
    allocator: Allocator,
    letter: u8,
    direction: String,
    distance: u8,
) !String {
    // TODO: Describe allocPrint in blog.
    return try std.fmt.allocPrint(
        allocator,
        "{c} {s} {d}",
        .{ letter, direction, distance },
    );
}

test createMove {
    const move = try createMove(testAlloc, 'A', "left", 3);
    defer testAlloc.free(move);
    try expectEqualStrings("A left 3", move);
}

// This creates a 2D array of car letters for a given puzzle.
fn getBoard(allocator: Allocator, cars: CarMap) !Board {
    if (cars.get('X') == null) {
        @panic("Puzzle is missing car X!");
    }

    // Create an empty board.
    var board: Board = .{.{SPACE} ** SIZE} ** SIZE;

    const letters = try getLetters(allocator, cars);
    defer testAlloc.free(letters);

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
    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    const board = try getBoard(testAlloc, puzzle);
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

fn getLetters(allocator: Allocator, cars: CarMap) ![]u8 {
    var letters = std.ArrayList(u8).init(allocator);
    defer letters.deinit();

    var iter = cars.keyIterator();
    while (iter.next()) |key| {
        try letters.append(key.*);
    }

    return testAlloc.dupe(u8, letters.items);
}

test getLetters {
    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    const letters = try getLetters(testAlloc, puzzle);
    defer testAlloc.free(letters);
    try expectEqualStrings("RPXACQOB", letters);
}

fn getPuzzle(allocator: Allocator) !CarMap {
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
    var puzzle = try getPuzzle(testAlloc);
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
    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    const board = try getBoard(testAlloc, puzzle);
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
        testAlloc,
        "Car {c} overlaps car {c}!",
        .{ letter, existing },
    );
    @panic(message);
}

fn printBoard(writer: anytype, board: Board) !void {
    println(writer, BORDER);
    for (board) |row| {
        try printString(writer, "|");
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

    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    const board = try getBoard(testAlloc, puzzle);
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

// Prints the solution moves by walking backwards from the final state.
fn printMoves(writer: anytype) !void {
    var moves = std.ArrayList(String).init(testAlloc);
    defer moves.deinit();

    var node_ptr: ?*const PendingStatesNode = pending_states.first;
    while (node_ptr != null) {
        if (node_ptr) |node| {
            const state = node.data;
            // The first state doesn't have a "move" property.
            if (state.move) |move| {
                try moves.append(move);
            }
            node_ptr = node.next;
        } else {
            unreachable;
        }
    }

    // The moves are in reverse order, so print them from the last to the first.
    const items = moves.items;
    var i = items.len;
    while (i > 0) {
        i -= 1;
        try printString(writer, items[i]);
        try printString(writer, "\n");
    }
}

test printMoves {
    pending_states = PendingStatesList{};

    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    const board = try getBoard(testAlloc, puzzle);

    // Add a move.
    var move1 = try createMove(testAlloc, 'A', "right", 2);
    defer testAlloc.free(move1);
    try addPendingState(testAlloc, board, puzzle, move1);

    // Add another move.
    var move2 = try createMove(testAlloc, 'B', "down", 3);
    defer testAlloc.free(move2);
    try addPendingState(testAlloc, board, puzzle, move2);

    // Print all the moves in reverse order.
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var writer = fbs.writer();
    try printMoves(writer);

    try expectEqualStrings("A right 2\nB down 3\n", fbs.getWritten());
}

fn printString(writer: anytype, string: String) !void {
    try writer.print("{s}", .{string});
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
    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    var board = try getBoard(testAlloc, puzzle);

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
    var puzzle = try getPuzzle(testAlloc);
    defer puzzle.deinit();

    var board = try getBoard(testAlloc, puzzle);

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
