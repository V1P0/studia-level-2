import java.util.ArrayList;
import java.util.List;

// Abstract base class for game states
abstract class GameState {
    // Abstract methods to be implemented by specific game implementations
    public abstract List<GameState> generatePossibleMoves();
    public abstract int evaluateState();
    public abstract boolean isGameOver();
}

// Interface for players to enforce strategy implementation
interface Player {
    GameState makeMove(GameState currentState);
}

// Minimax algorithm implementation using strategy pattern
class MiniMaxAlgorithm {
    private int maxDepth;
    
    // Encapsulated state for algorithm configuration
    public MiniMaxAlgorithm(int maxSearchDepth) {
        this.maxDepth = maxSearchDepth;
    }
    
    // Core Minimax algorithm with polymorphic state evaluation
    public GameState getBestMove(GameState currentState, boolean isMaximizingPlayer) {
        return minimax(currentState, maxDepth, isMaximizingPlayer).state;
    }
    
    // Recursive Minimax implementation with alpha-beta pruning
    private MiniMaxResult minimax(GameState state, int depth, boolean isMaximizingPlayer) {
        // Base cases: game over or max depth reached
        if (depth == 0 || state.isGameOver()) {
            return new MiniMaxResult(state, state.evaluateState());
        }
        
        List<GameState> possibleMoves = state.generatePossibleMoves();
        
        if (isMaximizingPlayer) {
            return getMaxMove(possibleMoves, depth);
        } else {
            return getMinMove(possibleMoves, depth);
        }
    }
    
    // Maximizing player strategy
    private MiniMaxResult getMaxMove(List<GameState> moves, int depth) {
        MiniMaxResult bestResult = new MiniMaxResult(null, Integer.MIN_VALUE);
        
        for (GameState move : moves) {
            MiniMaxResult result = minimax(move, depth - 1, false);
            if (result.score > bestResult.score) {
                bestResult = new MiniMaxResult(move, result.score);
            }
        }
        
        return bestResult;
    }
    
    // Minimizing player strategy
    private MiniMaxResult getMinMove(List<GameState> moves, int depth) {
        MiniMaxResult bestResult = new MiniMaxResult(null, Integer.MAX_VALUE);
        
        for (GameState move : moves) {
            MiniMaxResult result = minimax(move, depth - 1, true);
            if (result.score < bestResult.score) {
                bestResult = new MiniMaxResult(move, result.score);
            }
        }
        
        return bestResult;
    }
    
    // Inner class to hold move and score
    private static class MiniMaxResult {
        GameState state;
        int score;
        
        MiniMaxResult(GameState state, int score) {
            this.state = state;
            this.score = score;
        }
    }
}

// Example Concrete Implementation: Tic-Tac-Toe
class TicTacToeState extends GameState {
    private char[][] board;
    private char currentPlayer;
    
    // Constructor and board initialization
    public TicTacToeState(char[][] board, char currentPlayer) {
        this.board = new char[3][3];
        for (int i = 0; i < 3; i++) {
            this.board[i] = board[i].clone();
        }
        this.currentPlayer = currentPlayer;
    }
    
    @Override
    public List<GameState> generatePossibleMoves() {
        List<GameState> moves = new ArrayList<>();
        
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (board[i][j] == '\0') {
                    char[][] newBoard = new char[3][3];
                    for (int x = 0; x < 3; x++) {
                        newBoard[x] = board[x].clone();
                    }
                    
                    newBoard[i][j] = currentPlayer;
                    char nextPlayer = (currentPlayer == 'X') ? 'O' : 'X';
                    moves.add(new TicTacToeState(newBoard, nextPlayer));
                }
            }
        }
        
        return moves;
    }
    
    @Override
    public int evaluateState() {
        // Simplified evaluation: check winning conditions
        if (checkWin('X')) return 10;
        if (checkWin('O')) return -10;
        return 0;
    }
    
    @Override
    public boolean isGameOver() {
        return checkWin('X') || checkWin('O') || isBoardFull();
    }
    
    private boolean checkWin(char player) {
        // Check rows, columns, and diagonals
        for (int i = 0; i < 3; i++) {
            if ((board[i][0] == player && board[i][1] == player && board[i][2] == player) ||
                (board[0][i] == player && board[1][i] == player && board[2][i] == player)) {
                return true;
            }
        }
        
        return (board[0][0] == player && board[1][1] == player && board[2][2] == player) ||
               (board[0][2] == player && board[1][1] == player && board[2][0] == player);
    }
    
    private boolean isBoardFull() {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (board[i][j] == '\0') return false;
            }
        }
        return true;
    }
    
    // Additional method to print the board (for demonstration)
    public void printBoard() {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                System.out.print(board[i][j] == '\0' ? "- " : board[i][j] + " ");
            }
            System.out.println();
        }
    }
}

// Example usage of the Minimax algorithm
public class Main {
    public static void main(String[] args) {
        // Initialize a Tic-Tac-Toe board
        char[][] initialBoard = new char[3][3];
        
        // Create initial game state
        TicTacToeState initialState = new TicTacToeState(initialBoard, 'X');
        
        // Create Minimax algorithm with max depth of 9
        MiniMaxAlgorithm minimax = new MiniMaxAlgorithm(9);
        var player = true;
        // Get best move for X player
        while (!initialState.isGameOver()) {
            GameState bestMove = minimax.getBestMove(initialState, player);
            initialState = (TicTacToeState) bestMove;
            initialState.printBoard();
            System.out.println("------");
            player = !player;
        }
        
    }
}