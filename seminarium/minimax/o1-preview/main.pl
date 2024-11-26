% tictactoe.pl

% Define the players
player(x).
player(o).

% Define opponents
opponent(x, o).
opponent(o, x).

% Initial empty board
initial_board([e, e, e,
               e, e, e,
               e, e, e]).

% Display the board
display_board([A,B,C,D,E,F,G,H,I]) :-
    format('~w | ~w | ~w~n', [A,B,C]),
    write('---------'), nl,
    format('~w | ~w | ~w~n', [D,E,F]),
    write('---------'), nl,
    format('~w | ~w | ~w~n~n', [G,H,I]).

% Winning combinations
winning_combination(Board, Player) :-
    (Board = [Player, Player, Player, _, _, _, _, _, _]);
    (Board = [_, _, _, Player, Player, Player, _, _, _]);
    (Board = [_, _, _, _, _, _, Player, Player, Player]);
    (Board = [Player, _, _, Player, _, _, Player, _, _]);
    (Board = [_, Player, _, _, Player, _, _, Player, _]);
    (Board = [_, _, Player, _, _, Player, _, _, Player]);
    (Board = [Player, _, _, _, Player, _, _, _, Player]);
    (Board = [_, _, Player, _, Player, _, Player, _, _]).

% Check if a player has won
winner(Board, Player) :-
    player(Player),
    winning_combination(Board, Player).

% Check for a draw
draw(Board) :-
    \+ member(e, Board),
    \+ winner(Board, x),
    \+ winner(Board, o).

% Generate all possible moves for a player
possible_moves(Board, Player, Moves) :-
    findall(NewBoard, move(Board, Player, NewBoard), Moves).

% Define a move
move(Board, Player, NewBoard) :-
    nth0(Index, Board, e),
    replace(Board, Index, Player, NewBoard).

% Replace an element at a specific index
replace(Board, Index, Player, NewBoard) :-
    nth0(Index, Board, _, Rest),
    nth0(Index, NewBoard, Player, Rest).

% Minimax algorithm
minimax(Board, Player, BestNextBoard, Val) :-
    (
        winner(Board, x) ->
        Val = 1;
        winner(Board, o) ->
        Val = -1;
        draw(Board) ->
        Val = 0;
        possible_moves(Board, Player, Moves),
        evaluate_and_choose(Moves, Player, BestNextBoard, Val)
    ).

% Evaluate all possible moves and choose the best one
evaluate_and_choose([Board], Player, Board, Val) :-
    opponent(Player, Opponent),
    minimax(Board, Opponent, _, Val1),
    Val is -Val1.

evaluate_and_choose([Board1|Boards], Player, BestBoard, BestVal) :-
    opponent(Player, Opponent),
    minimax(Board1, Opponent, _, Val1),
    Val is -Val1,
    evaluate_and_choose(Boards, Player, Board2, Val2),
    (
        Val >= Val2 ->
        BestBoard = Board1,
        BestVal = Val;
        BestBoard = Board2,
        BestVal = Val2
    ).

% AI plays as Player
ai_move(Board, Player, BestBoard) :-
    minimax(Board, Player, BestBoard, _).

% Game loop where both players are AI
play(Board, Player) :-
    display_board(Board),
    (
        winner(Board, Winner) ->
        format('Player ~w wins!~n', [Winner]);
        draw(Board) ->
        write('The game is a draw.~n');
        (
            ai_move(Board, Player, NewBoard),
            opponent(Player, Opponent),
            play(NewBoard, Opponent)
        )
    ).