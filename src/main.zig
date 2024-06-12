// Tic Tac Toe implementation in Zig
// the three functions are:
// 1. `make_move` - to make a move
// 2. `undo_move` - to undo a move
// 3. 'all_legal_moves' - to get all legal moves

const std = @import("std");

const Bitboard = u16;

const GameStatus = enum {
    InProgress,
    Draw,
    XWins,
    OWins,
};

const Turn = enum {
    XTurn,
    OTurn,
};

const Player = enum {
    X,
    O,
};

const Move = enum(u8) {
    One,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Occupied,
};

fn move_to_bitboard(move: Move) Bitboard {
    switch (move) {
        Move.One => return 0b100_000_000,
        Move.Two => return 0b010_000_000,
        Move.Three => return 0b001_000_000,
        Move.Four => return 0b000_100_000,
        Move.Five => return 0b000_010_000,
        Move.Six => return 0b000_001_000,
        Move.Seven => return 0b000_000_100,
        Move.Eight => return 0b000_000_010,
        Move.Nine => return 0b000_000_001,
        Move.Occupied => return 0,
    }
}

const GameState = struct {
    x_bitboard: Bitboard,
    o_bitboard: Bitboard,
    game_status: GameStatus,
    move_history: [9]Move,
    move_count: u8,
    turn: Turn,
};

const number_of_positions = 9;
const last_bit_checker = 0b000_000_001;

fn all_legal_moves(game_state: *GameState) [number_of_positions]Move {
    var legal_moves = [number_of_positions]Move{ Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied };
    var legal_moves_count: usize = 0;

    if (game_state.game_status != GameStatus.InProgress) {
        return legal_moves;
    }

    var all_occupied_bitboard = game_state.x_bitboard | game_state.o_bitboard;

    for (0..number_of_positions) |i| {
        const result = all_occupied_bitboard & last_bit_checker;
        if (result == 0) {
            legal_moves[legal_moves_count] = @enumFromInt(8 - i);
            legal_moves_count += 1;
        }
        all_occupied_bitboard >>= 1;
    }

    return legal_moves;
}

fn make_move(game_state: *GameState, move: Move) void {
    if (game_state.game_status != GameStatus.InProgress) {
        return;
    }

    const legal_moves = all_legal_moves(game_state);
    var is_move_legal = false;

    for (legal_moves) |legal_move| {
        if (legal_move == move) {
            is_move_legal = true;
            break;
        }
    }

    if (!is_move_legal) {
        return;
    }

    const bitboard = move_to_bitboard(move);

    if (game_state.turn == Turn.XTurn) {
        game_state.x_bitboard |= bitboard;
        game_state.turn = Turn.OTurn;
    } else {
        game_state.o_bitboard |= bitboard;
        game_state.turn = Turn.XTurn;
    }

    game_state.move_history[game_state.move_count] = move;

    game_state.move_count += 1;

    if (detect_win_condition(game_state.x_bitboard)) {
        game_state.game_status = GameStatus.XWins;
    } else if (detect_win_condition(game_state.o_bitboard)) {
        game_state.game_status = GameStatus.OWins;
    } else if (detect_full_board_condition(game_state.x_bitboard | game_state.o_bitboard)) {
        game_state.game_status = GameStatus.Draw;
    }
}

fn unmake_move(game_state: *GameState) void {
    if (game_state.move_count == 0) {
        return;
    }

    game_state.move_count -= 1;

    const move = game_state.move_history[game_state.move_count];
    const bitboard = move_to_bitboard(move);

    if (game_state.turn == Turn.XTurn) {
        game_state.o_bitboard &= ~bitboard;
        game_state.turn = Turn.OTurn;
    } else {
        game_state.x_bitboard &= ~bitboard;
        game_state.turn = Turn.XTurn;
    }

    game_state.game_status = GameStatus.InProgress;

    game_state.move_history[game_state.move_count] = Move.Occupied;
}

const win_condition_1 = 0b111_000_000;
const win_condition_2 = 0b000_111_000;
const win_condition_3 = 0b000_000_111;
const win_condition_4 = 0b100_100_100;
const win_condition_5 = 0b010_010_010;
const win_condition_6 = 0b001_001_001;
const win_condition_7 = 0b100_010_001;
const win_condition_8 = 0b001_010_100;

fn detect_win_condition(bitboard: Bitboard) bool {
    const test_1 = if ((bitboard & win_condition_1) == win_condition_1) true else false;
    const test_2 = if ((bitboard & win_condition_2) == win_condition_2) true else false;
    const test_3 = if ((bitboard & win_condition_3) == win_condition_3) true else false;
    const test_4 = if ((bitboard & win_condition_4) == win_condition_4) true else false;
    const test_5 = if ((bitboard & win_condition_5) == win_condition_5) true else false;
    const test_6 = if ((bitboard & win_condition_6) == win_condition_6) true else false;
    const test_7 = if ((bitboard & win_condition_7) == win_condition_7) true else false;
    const test_8 = if ((bitboard & win_condition_8) == win_condition_8) true else false;
    return (test_1 or test_2 or test_3 or test_4 or test_5 or test_6 or test_7 or test_8);
}

fn detect_full_board_condition(bitboard: Bitboard) bool {
    return (bitboard == 0b111_111_111);
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "all_legal_moves_after_first_move_one_occupied" {
    var game_state = GameState{
        .x_bitboard = 0b100_000_000,
        .o_bitboard = 0b000_000_000,
        .game_status = GameStatus.InProgress,
        .move_history = undefined,
        .move_count = 1,
        .turn = Turn.OTurn,
    };

    const legal_moves = all_legal_moves(&game_state);

    const expected_legal_moves = [_]Move{
        Move.Nine,
        Move.Eight,
        Move.Seven,
        Move.Six,
        Move.Five,
        Move.Four,
        Move.Three,
        Move.Two,
        Move.Occupied,
    };

    try std.testing.expectEqual(legal_moves, expected_legal_moves);
}

test "all_legal_moves_initial_position" {
    var game_state = GameState{
        .x_bitboard = 0,
        .o_bitboard = 0,
        .game_status = GameStatus.InProgress,
        .move_history = undefined,
        .move_count = 0,
        .turn = Turn.XTurn,
    };

    const legal_moves = all_legal_moves(&game_state);

    const expected_legal_moves = [_]Move{
        Move.Nine,
        Move.Eight,
        Move.Seven,
        Move.Six,
        Move.Five,
        Move.Four,
        Move.Three,
        Move.Two,
        Move.One,
    };

    try std.testing.expectEqual(legal_moves, expected_legal_moves);
}

test "make_move_x_wins" {
    var game_state = GameState{
        .x_bitboard = 0b110000000,
        .o_bitboard = 0b000000110,
        .game_status = GameStatus.InProgress,
        .move_history = [9]Move{ Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 0,
        .turn = Turn.XTurn,
    };

    make_move(&game_state, Move.Three);

    const expected_game_state = GameState{
        .x_bitboard = 0b111000000,
        .o_bitboard = 0b000000110,
        .game_status = GameStatus.XWins,
        .move_history = [9]Move{ Move.Three, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 1,
        .turn = Turn.OTurn,
    };

    try std.testing.expectEqual(game_state, expected_game_state);
}

test "make_move_initial_position" {
    var game_state = GameState{
        .x_bitboard = 0,
        .o_bitboard = 0,
        .game_status = GameStatus.InProgress,
        .move_history = [9]Move{ Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 0,
        .turn = Turn.XTurn,
    };

    make_move(&game_state, Move.One);

    const expected_game_state = GameState{
        .x_bitboard = 0b100_000_000,
        .o_bitboard = 0,
        .game_status = GameStatus.InProgress,
        .move_history = [9]Move{ Move.One, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 1,
        .turn = Turn.OTurn,
    };

    try std.testing.expectEqual(game_state, expected_game_state);
}

test "unmake x's first move" {
    var game_state = GameState{
        .x_bitboard = 0b100_000_000,
        .o_bitboard = 0,
        .game_status = GameStatus.InProgress,
        .move_history = [9]Move{ Move.One, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 1,
        .turn = Turn.OTurn,
    };

    unmake_move(&game_state);

    const result = GameState{
        .x_bitboard = 0,
        .o_bitboard = 0,
        .game_status = GameStatus.InProgress,
        .move_history = [9]Move{ Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 0,
        .turn = Turn.XTurn,
    };

    try std.testing.expectEqual(game_state, result);
}

test "try unmaking move of initial postion" {
    var game_state = GameState{
        .x_bitboard = 0,
        .o_bitboard = 0,
        .game_status = GameStatus.InProgress,
        .move_history = [9]Move{ Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 0,
        .turn = Turn.XTurn,
    };

    unmake_move(&game_state);

    const result = GameState{
        .x_bitboard = 0,
        .o_bitboard = 0,
        .game_status = GameStatus.InProgress,
        .move_history = [9]Move{ Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied, Move.Occupied },
        .move_count = 0,
        .turn = Turn.XTurn,
    };

    try std.testing.expectEqual(game_state, result);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
