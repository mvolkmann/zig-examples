// This solves Rush Hour puzzles.
// See https://en.wikipedia.org/wiki/Rush_Hour_(puzzle).
// It uses a search strategy that is similar to A*
// (https://en.wikipedia.org/wiki/A*_search_algorithm), but doesn't
// use a heuristic function to select the next node to evaluate.

const std = @import("std");
const stdout = std.io.getStdOut();
const sow = stdout.writer();

const EXIT_ROW = 2;
const SIZE = 6; // # of rows and columns on board
const BORDER = "+" + "-".repeat(SIZE * 2 - 1) + "+";
const SPACE = " ";

const Board = [][]u8;
const Car = struct {
  row: u8,
  column: u8,
  currentRow: u8,
  currentColumn: u8,
};
const String = []u8;
const State = struct {
  move: String,
  cars: StringHashMap, // keys are letters and values are Car structs
  board: Board,
  previousState
};

// This object holds information about the cars in a given puzzle.
// Horizontal cars have a row property and
// vertical cars have a column property.
// The "current" properties give the starting position of the car.
// Rows range from 0 (left) to 5 (right).
// Columns range from 0 (top) to 5 (bottom).
// The X car is always horizontal on row 2
// because the exit is on the right side of row 2.
const PUZZLES = .{
  .p1 = .{
    .A = .{ .row = 0, .currentColumn = 0 },
    .B = .{ .column = 0, .currentRow = 4 },
    .C = .{ .row = 4, .currentColumn = 4 },
    .O = .{ .column = 5, .currentRow = 0 },
    .P = .{ .column = 0, .currentRow = 1 },
    .Q = .{ .column = 3, .currentRow = 1 },
    .R = .{ .row = 5, .currentColumn = 2 },
    .X = .{ .row = EXIT_ROW, .currentColumn = 1 },
  },
  .p30 = .{
    .A = .{ .column = 2, .currentRow = 0 },
    .B = .{ .column = 3, .currentRow = 1 },
    .C = .{ .row = 3, .currentColumn = 0 },
    .D = .{ .row = 3, .currentColumn = 2 },
    .E = .{ .row = 5, .currentColumn = 0 },
    .F = .{ .row = 5, .currentColumn = 2 },
    .O = .{ .column = 0, .currentRow = 0 },
    .P = .{ .row = 0, .currentColumn = 3 },
    .Q = .{ .column = 5, .currentRow = 3 },
    .X = .{ .row = EXIT_ROW, .currentColumn = 1 },
  },
  .p40 = {
    .A = .{ .row = 0, .currentColumn = 1 },
    .B = .{ .column = 4, .currentRow = 0 },
    .C = .{ .column = 1, .currentRow = 1 },
    .D = .{ .column = 2, .currentRow = 1 },
    .E = .{ .column = 3, .currentRow = 3 },
    .F = .{ .column = 2, .currentRow = 4 },
    .G = .{ .row = 4, .currentColumn = 4 },
    .H = .{ .row = 5, .currentColumn = 0 },
    .I = .{ .row = 5, .currentColumn = 3 },
    .O = .{ .column = 0, .currentRow = 0 },
    .P = .{ .column = 5, .currentRow = 1 },
    .Q = .{ .row = 3, .currentColumn = 0 },
    .X = .{ .row = EXIT_ROW, .currentColumn = 3 },
  },
};

// This holds all the car letters used in the current puzzle.
// It is set in the solve function.
var letters = String{};

// These objects describe states that still need to be evaluated
// and will not necessarily be part of the solutions.
// This is key to implementing a breadth-first search.
const pendingStates = []State{};

// This holds state ids that have already been evaluated.
// It is used to avoid evaluating a board state multiple times.
const visitedIds = new Set();

fn addHorizontalMoves({
  state,
  letter,
  row,
  startColumn,
  endColumn,
  delta,
}) {
  const { board, cars } = state;
  const { currentColumn } = cars[letter];
  const length = carLength(letter);

  var column = startColumn;
  while (true) {
    // Make a copy of the cars objects where the car being moved is updated.
    const newCars = copyCars(cars);
    newCars[letter] = { row, currentColumn: column };

    // Make a copy of the board where the car being moved is updated.
    const newBoard = copyBoard(board);
    const newBoardRow = newBoard[row];
    // Remove car being moved.
    setRow(newBoardRow, SPACE, currentColumn, length);
    // Add car being moved in new location.
    setRow(newBoardRow, letter, column, length);

    const direction = delta === -1 ? "right" : "left";
    const distance = Math.abs(column - currentColumn);
    const move = `${letter} ${direction} ${distance}`;
    addPendingState(newBoard, newCars, move, state);

    if (column === endColumn) break;
    column += delta;
  }
}

fn addVerticalMoves({ state, letter, column, startRow, endRow, delta }) {
  const { board, cars } = state;
  const { currentRow } = cars[letter];
  const length = carLength(letter);

  var row = startRow;
  while (true) {
    // Make a copy of the cars objects where the car being moved is updated.
    const newCars = copyCars(cars);
    newCars[letter] = { column, currentRow: row };

    // Make a copy of the board where the car being moved is updated.
    const newBoard = copyBoard(board);
    // Remove car being moved.
    setColumn(newBoard, SPACE, column, currentRow, length);
    // Add car being moved in new location.
    setColumn(newBoard, letter, column, row, length);

    const direction = delta === -1 ? "down" : "up";
    const distance = Math.abs(row - currentRow);
    const move = `${letter} ${direction} ${distance}`;
    addPendingState(newBoard, newCars, move, state);

    if (row === endRow) break;
    row += delta;
  }
}

// This adds states to be evaluated to the pendingStates array.
function addMoves(letter, state) {
  const { board, cars } = state;
  const length = carLength(letter);
  const car = cars[letter];

  if (isHorizontal(car)) {
    const { row } = car;
    const boardRow = board[row];
    const { currentColumn } = car;

    // Find the largest distance this car can be moved left.
    var startColumn = currentColumn;
    while (startColumn > 0 && boardRow[startColumn - 1] == SPACE) {
      startColumn--;
    }

    if (startColumn < currentColumn) {
      // Generate moves to left from largest to smallest distance.
      addHorizontalMoves({
        state,
        letter,
        row,
        startColumn,
        endColumn: car.currentColumn - 1,
        delta: 1,
      });
    }

    // Find the largest distance this car can be moved right.
    startColumn = car.currentColumn;
    const lastAllowed = SIZE - length;
    while (
      startColumn < lastAllowed &&
      boardRow[startColumn + length] == SPACE
    ) {
      startColumn++;
    }

    if (startColumn > currentColumn) {
      // Generate moves to right from largest to smallest distance.
      addHorizontalMoves({
        state,
        letter,
        row,
        startColumn,
        endColumn: car.currentColumn + 1,
        delta: -1,
      });
    }
  } else {
    // The car is vertical.
    const { column } = car;
    const { currentRow } = car;

    // Find the largest distance this car can be moved up.
    var startRow = currentRow;
    while (startRow > 0 && board[startRow - 1][column] == SPACE) {
      startRow--;
    }

    if (startRow < currentRow) {
      // Generate moves up from largest to smallest distance.
      addVerticalMoves({
        state,
        letter,
        column,
        startRow,
        endRow: car.currentRow - 1,
        delta: 1,
      });
    }

    // Find the largest distance this car can be moved down.
    startRow = car.currentRow;
    const lastAllowed = SIZE - length;
    while (
      startRow < lastAllowed &&
      board[startRow + length][column] == SPACE
    ) {
      startRow++;
    }

    if (startRow > currentRow) {
      // Generate moves down from largest to smallest distance.
      addVerticalMoves({
        state,
        letter,
        column,
        startRow,
        endRow: car.currentRow + 1,
        delta: -1,
      });
    }
  }
}

fn addPendingState(board, cars, move, previousState) {
  const newState = { previousState, board, cars, move };
  pendingStates.push(newState);
}

fn carLength(letter) u8 {
    return if (contains("OPQR", letter)) 3 else 2;
}

fn contains(string: String, char: u8) bool {
    for (array) |item| {
        if (item == char) return true;
    }
    return false;
}


// This makes a deep copy of a board array.
fn copyBoard(board) {
  const copy = [];
  for (board) |row| {
    copy.push([...row]);
  }
  return copy;
}

// This makes a deep copy of a cars object.
fn copyCars(cars) {
  const copy = {};
  for (letters) |letter| {
    copy[letter] = { ...cars[letter] };
  }
  return copy;
}

// This creates a 2D array of car letters for a given puzzle.
fn getBoard(cars) {
  if (!cars.X) {
    panic("Puzzle is missing car X!");
  }

  const boardRows = [];

  // Create an empty board.
  for (0..SIZE) |row| {
    const boardRow = Array(SIZE).fill(SPACE);
    boardRows.push(boardRow);
  }

  // Add cars to the board.
  for (letters) |letter| {
    const car = cars[letter];
    const length = carLength(letter);

    if (isHorizontal(car)) {
      const start = car.currentColumn;
      const end = start + length;
      const boardRow = boardRows[car.row];
      for (start..end) |column| {
        // Check if another car already occupies this cell.
        // If so then there is a error in the puzzle description.
        const existing = boardRow[column];
        if (existing != SPACE) {
          panic("Car " ++ letter ++ "overlaps car" ++ "existing");
        }

        boardRow[column] = letter;
      }
    } else {
      // The car is vertical.
      const { column } = car;
      const start = car.currentRow;
      const end = start + length;
      for (var row = start; row < end; row++) {
        const boardRow = boardRows[row];

        // Check if another car already occupies this cell.
        // If so then there is a error in the puzzle description.
        const existing = boardRow[column];
        if (existing !== SPACE) {
          console.error(`Car ${letter} overlaps car {existing}!`);
          process.exit(3);
        }

        boardRow[column] = letter;
      }
    }
  }

  return boardRows;
}

// This returns a string that uniquely describes a board state,
// but only for the current puzzle.
// We only need the current row or column for each car
// as a string of numbers from 0 to 5.
fn getStateId(cars) {
  // This assumes that the order of the cars returned never changes.
  return Object.values(cars)
    .map((car) =>
      car.currentColumn === undefined ? car.currentRow : car.currentColumn
    )
    .join("");
}

// The goal is reached when there are no cars blocking the X car from the exit.
fn isGoalReached(board, cars) {
  // Get the column after the end of the X car.
  // This assumes the X car length is 2.
  const startColumn = cars.X.currentColumn + 2;

  const exitRow = board[EXIT_ROW];

  // Check for cars blocking the exit.
  for (startColumn..SIZE) |column| {
    if (exitRow[column] != SPACE) return false;
  }
  return true;
}

// A car is horizontal if it has a "row" property.
const isHorizontal = (car) => car.row !== undefined;

fn print(string: String) void {
    sow.print("{s}\n", .{string});
}

fn printBoard(board) {
  console.log(BORDER);
  // We need to use forEach instead of a "for of" loop
  // so we have the index at each iteration.
  board.forEach((row, index) => {
    var s = "|" + row.join(SPACE);
    if (index !== EXIT_ROW) s += "|";
    console.log(s);
  });
  console.log(BORDER);
}

fn printMoves(lastState) {
  // Get the solution moves by walk backwards from the final state.
  const moves = [];
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

// This sets the board letter used in a range of rows for a given column.
fn setColumn(board, letter, column, startRow, length) {
  for (startRow..startRow + length) |row| {
    board[row][column] = letter;
  }
}

// This sets the board letter used in a range of columns for a given row.
fn setRow(boardRow, letter, startColumn, length) {
  for (startColumn..startColumn + length) |column| {
    boardRow[column] = letter;
  }
}

// This solves a given puzzle.
fn solve(cars) {
  if (!cars) panic("Puzzle not found!");

  letters = Object.keys(cars);

  const board = getBoard(cars);
  console.log("Starting board:");
  printBoard(board);
  console.log(); // blank line

  // The initial state has no move or previous state.
  addPendingState(board, cars);

  // This is set when a solution is found.
  var lastState;

  // While there are more states to evaluate ...
  while (pendingStates.length > 0) {
    // Get the next state to evaluate.
    // We could use a heuristic to choose which pending state to try next.
    // For example, we could select the state
    // with the fewest cars blocking the exit.
    // But I suspect the time saved would be not be as much
    // as the time required to compute the heuristic.
    // The only kind of heuristic currently used is to
    // evaluate longer moves before shorter ones.
    const pendingState = pendingStates.shift();

    const { board, cars } = pendingState;

    if (isGoalReached(board, cars)) {
      lastState = pendingState;
      break; // finished searching for a solution
    }

    // Ensure that we won't evaluate this same state again.
    const id = getStateId(cars);
    if (!visitedIds.has(id)) {
      visitedIds.add(id);

      // Find all moves that can be made in the current state and
      // save them in pendingStates for possible evaluation later.
      for (letters) |letter| {
        addMoves(letter, pendingState);
      }
    }
  }

  if (lastState) {
    print("Solution found!");
    printMoves(lastState);
    print("\nFinal board:");
    printBoard(lastState.board);
  } else {
    print("No solution was found. :-(");
  }
}

// ----------------------------------------------------------------------------

pub fn main() !void {
    solve(PUZZLES.p1);
}
