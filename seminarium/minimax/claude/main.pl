% Minimax AI vs AI Tic-Tac-Toe Implementation

% Game State Representation
% Board is represented as a list of lists
% Players are represented as x and o

% Initial game state
initial_board([
    [' ', ' ', ' '],
    [' ', ' ', ' '],
    [' ', ' ', ' ']
]).

% Win conditions
win(Board, Player) :-
    % Rows
    member(Row, Board),
    Row = [Player, Player, Player].

win(Board, Player) :-
    % Columns
    nth0(ColIndex, [0, 1, 2], _),
    column(Board, ColIndex, Column),
    Column = [Player, Player, Player].

win(Board, Player) :-
    % Diagonals
    diagonal1(Board, [Player, Player, Player]);
    diagonal2(Board, [Player, Player, Player]).

% Extract a column from the board
column(Board, ColIndex, Column) :-
    maplist(nth0(ColIndex), Board, Column).

% First diagonal (top-left to bottom-right)
diagonal1(Board, [A, B, C]) :-
    nth0(0, Board, FirstRow),
    nth0(0, FirstRow, A),
    nth0(1, Board, SecondRow),
    nth0(1, SecondRow, B),
    nth0(2, Board, ThirdRow),
    nth0(2, ThirdRow, C).

% Second diagonal (top-right to bottom-left)
diagonal2(Board, [A, B, C]) :-
    nth0(0, Board, FirstRow),
    nth0(2, FirstRow, A),
    nth0(1, Board, SecondRow),
    nth0(1, SecondRow, B),
    nth0(2, Board, ThirdRow),
    nth0(0, ThirdRow, C).

% Check if the board is full (draw)
board_full(Board) :-
    \+ (member(Row, Board), member(' ', Row)).

% Generate possible moves
possible_moves(Board, Player, NewBoards) :-
    findall(NewBoard, 
        (
            nth0(RowIndex, Board, Row),
            nth0(ColIndex, Row, ' '),
            replace_in_board(Board, RowIndex, ColIndex, Player, NewBoard)
        ), 
        NewBoards).

% Replace a cell in the board
replace_in_board(Board, RowIndex, ColIndex, Player, NewBoard) :-
    replace_nth0(Board, RowIndex, OldRow, NewBoard),
    replace_nth0(OldRow, ColIndex, ' ', Player, NewRow),
    replace_nth0(Board, RowIndex, OldRow, NewRow, NewBoard).

% Utility predicate for replacing nth element
replace_nth0([H|T], 0, H, [X|T], X).
replace_nth0([H|T], N, H, [H|R], X) :-
    N > 0,
    N1 is N - 1,
    replace_nth0(T, N1, H, R, X).

% Evaluate board state
evaluate(Board, Score) :-
    (win(Board, x) -> Score = 10
    ; win(Board, o) -> Score = -10
    ; board_full(Board) -> Score = 0
    ; Score = 0).

% Minimax algorithm with alpha-beta pruning
minimax(Board, Depth, Player, AlphaBeta, Score, BestMove) :-
    % Base case: terminal state or depth reached
    (Depth =< 0 ; win(Board, _) ; board_full(Board)),
    !,
    evaluate(Board, Score),
    BestMove = Board.

% Maximizing player
minimax(Board, Depth, x, AlphaBeta, Score, BestMove) :-
    possible_moves(Board, x, PossibleMoves),
    best_move(PossibleMoves, Depth, o, AlphaBeta, -1000, Score, BestMove).

% Minimizing player
minimax(Board, Depth, o, AlphaBeta, Score, BestMove) :-
    possible_moves(Board, o, PossibleMoves),
    best_move(PossibleMoves, Depth, x, AlphaBeta, 1000, Score, BestMove).

% Find best move recursively
best_move([], _, _, _, BestScore, BestScore, _).
best_move([Move|Moves], Depth, NextPlayer, AlphaBeta, CurrentBest, BestScore, BestMove) :-
    Depth1 is Depth - 1,
    minimax(Move, Depth1, NextPlayer, AlphaBeta, MoveScore, _),
    
    % Maximizing player wants max score
    (NextPlayer = x, MoveScore > CurrentBest ->
        NewBest = MoveScore,
        NewBestMove = Move
    
    % Minimizing player wants min score
    ; NextPlayer = o, MoveScore < CurrentBest ->
        NewBest = MoveScore,
        NewBestMove = Move
    
    % No improvement
    ; NewBest = CurrentBest,
        NewBestMove = BestMove
    ),
    
    best_move(Moves, Depth, NextPlayer, AlphaBeta, NewBest, BestScore, NewBestMove).

% Pretty print board
print_board([]).
print_board([Row|Rows]) :-
    print_row(Row),
    nl,
    print_board(Rows).

print_row([]).
print_row([Cell|Cells]) :-
    write(Cell),
    write(' '),
    print_row(Cells).

% Game play predicate for AI vs AI
play_ai_game(Board, Player, Depth, MoveCount) :-
    % Check game over conditions
    (win(Board, x) -> 
        write('X wins!'), nl,
        print_board(Board)
    ; win(Board, o) -> 
        write('O wins!'), nl,
        print_board(Board)
    ; board_full(Board) -> 
        write('Draw!'), nl,
        print_board(Board)
    
    % Continue game if not over
    ; 
        % Print current board state
        write('Move '), write(MoveCount), write(' - Player '), write(Player), nl,
        print_board(Board),
        nl,
        
        % Find best move using Minimax
        minimax(Board, Depth, Player, _, _, BestMove),
        
        % Determine next player
        (Player = x -> NextPlayer = o ; NextPlayer = x),
        
        % Recursive call with next move
        NextMoveCount is MoveCount + 1,
        play_ai_game(BestMove, NextPlayer, Depth, NextMoveCount)
    ).

% Main predicate to start AI vs AI game
ai_vs_ai :-
    % Initial setup
    initial_board(InitialBoard),
    write('Starting AI vs AI Tic-Tac-Toe'), nl,
    write('Depth 4 Minimax'), nl, nl,
    
    % Start game with X as first player, depth 4
    play_ai_game(InitialBoard, x, 4, 1).

% Query to run the game
% ?- ai_vs_ai.