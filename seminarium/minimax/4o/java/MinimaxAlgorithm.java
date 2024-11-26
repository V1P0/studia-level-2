import java.util.ArrayList;
import java.util.List;

public class MinimaxAlgorithm {
    // Define the main state variables for the Minimax algorithm
    public static final int MAX_DEPTH = 9;
    
    public static void main(String[] args) {
        GameBoard board = new TicTacToeBoard(); // Create an instance of a Tic Tac Toe game
        MinimaxPlayer player1 = new MinimaxPlayer();
        MinimaxPlayer player2 = new MinimaxPlayer();
        
        while (!board.isGameOver()) {
            System.out.println("Current Board State:");
            ((TicTacToeBoard) board).printBoard();
            
            int bestMove;
            if (((TicTacToeBoard) board).isHumanTurn()) {
                bestMove = player1.findBestMove(board);
                System.out.println("Player 1 (AI) chooses move: " + bestMove);
            } else {
                bestMove = player2.findBestMove(board);
                System.out.println("Player 2 (AI) chooses move: " + bestMove);
            }
            board = ((TicTacToeBoard) board).makeMove(bestMove);
        }
        
        System.out.println("Game Over!");
        ((TicTacToeBoard) board).printBoard();
    }
}

abstract class GameBoard {
    // Represents the game state. Can be implemented for various games like Tic Tac Toe or Chess
    public abstract boolean isGameOver();
    public abstract int evaluate();
    public abstract List<GameBoard> getPossibleMoves();
}

class TicTacToeBoard extends GameBoard {
    private int[][] board;
    private boolean isHumanTurn;
    
    public TicTacToeBoard() {
        board = new int[3][3]; // Initialize a 3x3 board for Tic Tac Toe with 0s (empty cells)
        isHumanTurn = true; // Player 1 starts first
    }
    
    public boolean isHumanTurn() {
        return isHumanTurn;
    }
    
    public GameBoard makeMove(int move) {
        int row = move / 3;
        int col = move % 3;
        if (board[row][col] == 0) {
            board[row][col] = isHumanTurn ? 1 : 2;
            isHumanTurn = !isHumanTurn;
        }
        return this;
    }
    
    public TicTacToeBoard makeMove(int row, int col) {
        if (board[row][col] == 0) {
            board[row][col] = isHumanTurn ? 1 : 2;
            isHumanTurn = !isHumanTurn;
        }
        return this;
    }
    
    @Override
    public boolean isGameOver() {
        // Implement logic to check if the game is over
        for (int i = 0; i < 3; i++) {
            if (board[i][0] != 0 && board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
                return true;
            }
            if (board[0][i] != 0 && board[0][i] == board[1][i] && board[1][i] == board[2][i]) {
                return true;
            }
        }
        if (board[0][0] != 0 && board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
            return true;
        }
        if (board[0][2] != 0 && board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
            return true;
        }
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (board[i][j] == 0) {
                    return false;
                }
            }
        }
        return true;
    }
    
    @Override
    public int evaluate() {
        // Implement logic to evaluate the board (1 for win, -1 for loss, 0 for draw)
        for (int i = 0; i < 3; i++) {
            // Check rows for win
            if (board[i][0] != 0 && board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
                return (board[i][0] == 1) ? 1 : -1;
            }
            // Check columns for win
            if (board[0][i] != 0 && board[0][i] == board[1][i] && board[1][i] == board[2][i]) {
                return (board[0][i] == 1) ? 1 : -1;
            }
        }
        // Check diagonals for win
        if (board[0][0] != 0 && board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
            return (board[0][0] == 1) ? 1 : -1;
        }
        if (board[0][2] != 0 && board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
            return (board[0][2] == 1) ? 1 : -1;
        }
        // If no winner, return 0 for draw or ongoing game
        return 0;
    }
    
    @Override
    public List<GameBoard> getPossibleMoves() {
        List<GameBoard> possibleMoves = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (board[i][j] == 0) {
                    TicTacToeBoard newBoard = new TicTacToeBoard();
                    newBoard.board = copyBoard();
                    newBoard.isHumanTurn = !this.isHumanTurn;
                    newBoard.makeMove(i, j);
                    possibleMoves.add(newBoard);
                }
            }
        }
        return possibleMoves;
    }
    
    private int[][] copyBoard() {
        int[][] newBoard = new int[3][3];
        for (int i = 0; i < 3; i++) {
            System.arraycopy(board[i], 0, newBoard[i], 0, 3);
        }
        return newBoard;
    }
    
    public void printBoard() {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                int value = board[i][j];
                String symbol = (value == 0) ? "-" : (value == 1) ? "X" : "O";
                System.out.print(symbol + " ");
            }
            System.out.println();
        }
    }
}

class MinimaxPlayer {
    public int findBestMove(GameBoard board) {
        int bestValue = Integer.MIN_VALUE;
        int bestMove = -1;
        List<GameBoard> moves = board.getPossibleMoves();
        
        for (int i = 0; i < moves.size(); i++) {
            GameBoard move = moves.get(i);
            int moveValue = minimax(move, 0, false);
            if (moveValue > bestValue) {
                bestValue = moveValue;
                bestMove = i;
            }
        }
        return bestMove;
    }
    
    private int minimax(GameBoard board, int depth, boolean isMaximizingPlayer) {
        if (depth == MinimaxAlgorithm.MAX_DEPTH || board.isGameOver()) {
            return board.evaluate();
        }
        
        if (isMaximizingPlayer) {
            int bestValue = Integer.MIN_VALUE;
            for (GameBoard child : board.getPossibleMoves()) {
                bestValue = Math.max(bestValue, minimax(child, depth + 1, false));
            }
            return bestValue;
        } else {
            int bestValue = Integer.MAX_VALUE;
            for (GameBoard child : board.getPossibleMoves()) {
                bestValue = Math.min(bestValue, minimax(child, depth + 1, true));
            }
            return bestValue;
        }
    }
}

class HumanPlayer {
    public TicTacToeBoard makeMove(TicTacToeBoard board, int row, int col) {
        return board.makeMove(row, col);
    }
}