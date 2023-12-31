// This solves Rush Hour puzzles.
// See https://en.wikipedia.org/wiki/Rush_Hour_(puzzle).
// It uses a search strategy that is similar to A*
// (https://en.wikipedia.org/wiki/A*_search_algorithm), but doesn't
// use a heuristic function to select the next node to evaluate.

const std = @import("std");
const print = std.debug.print;
const bufPrint = std.fmt.bufPrint;
const math = std.math;
const expectEqualStrings = std.testing.expectEqualStrings;

var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // can't be const
const allocator = gpa.allocator();

const stdout = std.io.getStdOut();
const sow = stdout.writer();

const CarMap = std.AutoArrayHashMap(u8, Car);

const EXIT_ROW = 2;
const MAX_CARS = 16;
const SIZE = 6; // # of rows and columns on board
const BORDER = "+" ++ ("-" ** (SIZE * 2 - 1)) ++ "+";
const SPACE = ' ';

const String = []const u8;
const Board = []String;
const Car = struct {
    row: ?u8 = undefined,
    column: ?u8 = undefined,
    currentRow: ?u8 = undefined,
    currentColumn: ?u8 = undefined,
};
const State = struct {
    move: ?String,
    cars: CarMap, // keys are letters and values are Car structs
    board: Board,
    previousState: ?*State,
};

// This holds all the car letters used in the current puzzle.
// It is set in the solve function.
var letters: String = "";

// These objects describe states that still need to be evaluated
// and will not necessarily be part of the solutions.
// This is key to implementing a breadth-first search.
var pendingStates = std.ArrayList(State).init(allocator);

fn addHorizontalMoves(
    state: State,
    letter: u8,
    row: u8,
    startColumn: u8,
    endColumn: u8,
    delta: i8,
) void {
    const board = state.board;
    const cars = state.cars;
    const currentColumn = cars.get(letter).currentColumn;
    const length = carLength(letter);

    var column = startColumn;
    while (true) {
        // Make a copy of the cars objects where the car being moved is updated.
        const newCars = cars.clone();
        newCars[letter] = .{ .row = state.row, .currentColumn = column };

        // Make a copy of the board where the car being moved is updated.
        const newBoard = copyBoard(board);
        const newBoardRow = newBoard[row];
        // Remove car being moved.
        setRow(newBoardRow, SPACE, currentColumn, length);
        // Add car being moved in new location.
        setRow(newBoardRow, letter, column, length);

        const direction = if (delta == -1) "right" else "left";
        const distance = math.absInt(column - currentColumn);
        var move = createMove(letter, direction, distance);
        addPendingState(newBoard, newCars, move, state);

        if (column == endColumn) break;
        column += delta;
    }
}

fn addVerticalMoves(
    state: State,
    letter: u8,
    column: u8,
    startRow: u8,
    endRow: u8,
    delta: i8,
) void {
    const board = state.board;
    const cars = state.cars;
    const currentRow = cars.get(letter).currentRow;
    const length = carLength(letter);

    var row = startRow;
    while (true) {
        // Make a copy of the cars objects where the car being moved is updated.
        const newCars = cars.clone();
        newCars[letter] = .{ .column = column, .currentRow = row };

        // Make a copy of the board where the car being moved is updated.
        const newBoard = copyBoard(board);
        // Remove car being moved.
        setColumn(newBoard, SPACE, column, currentRow, length);
        // Add car being moved in new location.
        setColumn(newBoard, letter, column, row, length);

        const direction = if (delta == -1) "down" else "up";
        const distance = math.abs(row - currentRow);
        const move = createMove(letter, direction, distance);
        addPendingState(newBoard, newCars, move, state);

        if (row == endRow) break;
        row += delta;
    }
}

// This adds states to be evaluated to the pendingStates array.
fn addMoves(letter: u8, state: State) void {
    const board = state.board;
    const cars = state.cars;
    const length = carLength(letter);
    const car = cars.get(letter);

    if (isHorizontal(car)) {
        const row = car.row;
        const boardRow = board[row];
        const currentColumn = car.currentColumn;

        // Find the largest distance this car can be moved left.
        var startColumn = currentColumn;
        while (startColumn > 0 and boardRow[startColumn - 1] == SPACE) {
            startColumn -= 1;
        }

        if (startColumn < currentColumn) {
            // Generate moves to left from largest to smallest distance.
            const endColumn = car.currentColumn - 1;
            const delta = 1;
            addHorizontalMoves(
                state,
                letter,
                row,
                startColumn,
                endColumn,
                delta,
            );
        }

        // Find the largest distance this car can be moved right.
        startColumn = car.currentColumn;
        const lastAllowed = SIZE - length;
        while (startColumn < lastAllowed and
            boardRow[startColumn + length] == SPACE)
        {
            startColumn += 1;
        }

        if (startColumn > currentColumn) {
            // Generate moves to right from largest to smallest distance.
            const endColumn = car.currentColumn + 1;
            const delta = -1;
            addHorizontalMoves(
                state,
                letter,
                row,
                startColumn,
                endColumn,
                delta,
            );
        }
    } else {
        // The car is vertical.
        const column = car.columne;
        const currentRow = car.currentRow;

        // Find the largest distance this car can be moved up.
        var startRow = currentRow;
        while (startRow > 0 and board[startRow - 1][column] == SPACE) {
            startRow -= 1;
        }

        if (startRow < currentRow) {
            // Generate moves up from largest to smallest distance.
            const endRow = car.currentRow - 1;
            const delta = 1;
            addVerticalMoves(state, letter, column, startRow, endRow, delta);
        }

        // Find the largest distance this car can be moved down.
        startRow = car.currentRow;
        const lastAllowed = SIZE - length;
        while (startRow < lastAllowed and
            board[startRow + length][column] == SPACE)
        {
            startRow += 1;
        }

        if (startRow > currentRow) {
            // Generate moves down from largest to smallest distance.
            const endRow = car.currentRow + 1;
            const delta = -1;
            addVerticalMoves(state, letter, column, startRow, endRow, delta);
        }
    }
}

fn addPendingState(
    board: Board,
    cars: CarMap,
    move: ?String,
    previousState: ?State,
) void {
    pendingStates.append(.{
        .board = board,
        .cars = cars,
        .move = move,
        .previousState = previousState,
    });
}

fn carLength(letter: u8) u8 {
    return if (contains("OPQR", letter)) 3 else 2;
}

fn contains(string: String, char: u8) bool {
    for (string) |item| {
        if (item == char) return true;
    }
    return false;
}

// This makes a deep copy of a board.
fn copyBoard(board: Board) Board {
    const copy = [6]String{};
    for (board, 0..) |row, index| {
        copy[index] = row;
    }
    return copy;
}

fn createMove(letter: u8, direction: String, distance: u8) !String {
    var buffer: [20]u8 = undefined;
    const result = try bufPrint(&buffer, "{c} {s} {d}", .{ letter, direction, distance });
    return allocator.dupe(u8, result);
}

// This creates a 2D array of car letters for a given puzzle.
fn getBoard(cars: CarMap) Board {
    if (cars.get('X') == null) {
        @panic("Puzzle is missing car X!");
    }

    var boardRows = std.ArrayList(String).init(allocator);
    //TODO: Caller will need to deinit this.

    // Create an empty board.
    for (0..SIZE) |row| {
        const boardRow = [_]u8{SPACE} ** SIZE;
        boardRows.items[row] = &boardRow;
    }

    // Add cars to the board.
    for (letters) |letter| {
        if (cars.get(letter)) |car| {
            const length = carLength(letter);

            if (isHorizontal(car)) {
                if (car.currentColumn) |start| {
                    const end = start + length;
                    if (car.row) |row| {
                        var boardRow = boardRows.items[row];
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

                            boardRow[column] = letter;
                        }
                    }
                }
            } else {
                // The car is vertical.
                const column = car.column;
                const start = car.currentRow;
                const end = start + length;
                for (start..end) |row| {
                    const boardRow = boardRows.items[row];

                    // Check if another car already occupies this cell.
                    // If so then there is a error in the puzzle description.
                    const existing = boardRow[column];
                    if (existing != SPACE) {
                        @panic("Car " ++ letter ++ " overlaps car " ++ existing ++ "!");
                    }

                    boardRow[column] = letter;
                }
            }
        }
    }

    return boardRows;
}

// This returns a string that uniquely describes a board state,
// but only for the current puzzle.
// We only need the current row or column for each car
// as a string of numbers from 0 to 5.
fn getStateId(cars: CarMap) String {
    var positionsArray: [MAX_CARS]String = undefined;
    var positionsSlice = positionsArray[0..cars.count()];
    // This assumes that the order of the cars returned never changes.
    for (cars.values(), 0..) |car, i| {
        positionsSlice[i] = car.currentRow orelse car.currentColumn;
    }
    const joined = try std.mem.join(allocator, "", positionsSlice);
    defer allocator.free(joined);
    return joined;
}

// The goal is reached when there are no cars blocking the X car from the exit.
fn isGoalReached(board: Board, cars: CarMap) bool {
    // Get the column after the end of the X car.
    // This assumes the X car length is 2.
    if (cars.get('X')) |car| {
        if (car.currentColumn) |currentColumn| {
            const startColumn = currentColumn + 2;
            const exitRow = board[EXIT_ROW];

            // Check for cars blocking the exit.
            for (startColumn..SIZE) |column| {
                if (exitRow[column] != SPACE) return false;
            }
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

// A car is horizontal if it has a "row" property.
inline fn isHorizontal(car: Car) bool {
    return car.row != undefined;
}

fn printBoard(board: Board) !void {
    printStdOut(BORDER);
    for (board, 0..) |row, index| {
        var buffer: [16]u8 = undefined;
        defer allocator.free(buffer);
        var fbs = std.io.fixedBufferStream(&buffer);
        const writer = fbs.writer();
        _ = try writer.write("| ");
        for (row) |letter| {
            try writer.print("{} ", .{letter});
        }
        if (index != EXIT_ROW) {
            _ = try writer.write("|");
        }
        print(fbs.getWritten());
    }
    printStdOut(BORDER);
}

fn printMoves(lastState: State) void {
    // Get the solution moves by walk backwards from the final state.
    var moves = std.ArrayList(String).init(allocator);
    defer moves.deinit();
    var state = lastState;
    // This first state doesn't have a "move" property.
    while (state.move) {
        moves.push(state.move);
        state = state.previousState;
    }

    // The moves are in reverse order, so print them from the last to the first.
    var i = moves.length - 1;
    while (i >= 0) : (i -= 1) {
        print(moves[i]);
    }
}

fn printStdOut(string: String) void {
    // This ignores errors.
    sow.print("{s}\n", .{string}) catch {};
}

// This sets the board letter used in a range of rows for a given column.
fn setColumn(board: Board, letter: u8, column: u8, startRow: u8, length: u8) void {
    for (startRow..startRow + length) |row| {
        board[row][column] = letter;
    }
}

// This sets the board letter used in a range of columns for a given row.
fn setRow(boardRow: String, letter: u8, startColumn: u8, length: u8) void {
    for (startColumn..startColumn + length) |column| {
        boardRow[column] = letter;
    }
}

// This solves a given puzzle.
fn solve(cars: CarMap) !void {
    // This holds state ids that have already been evaluated.
    // It is used to avoid evaluating a board state multiple times.
    var visitedIds = std.BufSet.init(allocator);
    defer visitedIds.deinit();

    const board = getBoard(cars);
    print("Starting board:");
    try printBoard(board);
    print(""); // blank line

    // The initial state has no move or previous state.
    addPendingState(board, cars, null, null);

    // This is set when a solution is found.
    var lastState: ?State = null;

    // While there are more states to evaluate ...
    while (pendingStates.items.len > 0) {
        // Get the next state to evaluate.
        // We could use a heuristic to choose which pending state to try next.
        // For example, we could select the state
        // with the fewest cars blocking the exit.
        // But I suspect the time saved would be not be as much
        // as the time required to compute the heuristic.
        // The only kind of heuristic currently used is to
        // evaluate longer moves before shorter ones.
        var pendingState = pendingStates.pop();

        const pendingBoard = pendingState.board;
        var pendingCars = pendingState.cars;

        if (isGoalReached(pendingBoard, pendingCars)) {
            lastState = pendingState;
            break; // finished searching for a solution
        }

        // Ensure that we won't evaluate this same state again.
        const id = getStateId(pendingCars);
        if (!visitedIds.contains(id)) {
            try visitedIds.insert(id);

            // Find all moves that can be made in the current state and
            // save them in pendingStates for possible evaluation later.
            const iter = pendingCars.keyIterator();
            for (iter.next()) |letter| {
                addMoves(letter, pendingState);
            }
        }
    }

    if (lastState) |solution| {
        print("Solution found!");
        printMoves(solution);
        print("\nFinal board:");
        printBoard(solution.board);
    } else {
        print("No solution was found. :-(");
    }
}

// ----------------------------------------------------------------------------

pub fn main() !void {
    // These hash maps hold information about the cars in a given puzzle.
    // Horizontal cars have a row property and
    // vertical cars have a column property.
    // The "current" properties give the starting position of the car.
    // Rows range from 0 (left) to 5 (right).
    // Columns range from 0 (top) to 5 (bottom).
    // The X car is always horizontal on row 2
    // because the exit is on the right side of row 2.
    var puzzle1 = CarMap.init(allocator);
    defer puzzle1.deinit();
    // Can these puts be performed at compile-time?
    try puzzle1.put('A', .{ .row = 0, .currentColumn = 0 });
    try puzzle1.put('B', .{ .column = 0, .currentRow = 4 });
    try puzzle1.put('C', .{ .row = 4, .currentColumn = 4 });
    try puzzle1.put('O', .{ .column = 5, .currentRow = 0 });
    try puzzle1.put('P', .{ .column = 0, .currentRow = 1 });
    try puzzle1.put('Q', .{ .column = 3, .currentRow = 1 });
    try puzzle1.put('R', .{ .row = 5, .currentColumn = 2 });
    try puzzle1.put('X', .{ .row = EXIT_ROW, .currentColumn = 1 });

    // const puzzle30 = CarMap(Car, .{
    //     .{ "A", .{ .column = 2, .currentRow = 0 } },
    //     .{ "B", .{ .column = 3, .currentRow = 1 } },
    //     .{ "C", .{ .row = 3, .currentColumn = 0 } },
    //     .{ "D", .{ .row = 3, .currentColumn = 2 } },
    //     .{ "E", .{ .row = 5, .currentColumn = 0 } },
    //     .{ "F", .{ .row = 5, .currentColumn = 2 } },
    //     .{ "O", .{ .column = 0, .currentRow = 0 } },
    //     .{ "P", .{ .row = 0, .currentColumn = 3 } },
    //     .{ "Q", .{ .column = 5, .currentRow = 3 } },
    //     .{ "X", .{ .row = EXIT_ROW, .currentColumn = 1 } },
    // });
    // const puzzle40 = CarMap(Car, .{
    //     .{ "A", .{ .row = 0, .currentColumn = 1 } },
    //     .{ "B", .{ .column = 4, .currentRow = 0 } },
    //     .{ "C", .{ .column = 1, .currentRow = 1 } },
    //     .{ "D", .{ .column = 2, .currentRow = 1 } },
    //     .{ "E", .{ .column = 3, .currentRow = 3 } },
    //     .{ "F", .{ .column = 2, .currentRow = 4 } },
    //     .{ "G", .{ .row = 4, .currentColumn = 4 } },
    //     .{ "H", .{ .row = 5, .currentColumn = 0 } },
    //     .{ "I", .{ .row = 5, .currentColumn = 3 } },
    //     .{ "O", .{ .column = 0, .currentRow = 0 } },
    //     .{ "P", .{ .column = 5, .currentRow = 1 } },
    //     .{ "Q", .{ .row = 3, .currentColumn = 0 } },
    //     .{ "X", .{ .row = EXIT_ROW, .currentColumn = 3 } },
    // });

    defer pendingStates.deinit();

    try solve(puzzle1);
}
