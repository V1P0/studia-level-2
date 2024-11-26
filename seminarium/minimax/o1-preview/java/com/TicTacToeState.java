import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class TicTacToeState extends GameState {
    private int[][] board; // 0 = empty, 1 = player1, -1 = player2

    public TicTacToeState(int currentPlayer, int[][] board) {
        super(currentPlayer);
        this.board = board;
    }

    @Override
    public List<GameState> getPossibleStates() {
        List<GameState> states = new ArrayList<>();
        // Generate all possible moves
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (board[i][j] == 0) {
                    int[][] newBoard = copyBoard();
                    newBoard[i][j] = currentPlayer;
                    states.add(new TicTacToeState(-currentPlayer, newBoard));
                }
            }
        }
        return states;
    }

    @Override
    public boolean isTerminal() {
        return checkWin(1) || checkWin(-1) || isBoardFull();
    }

    @Override
    public int evaluate() {
        if (checkWin(1)) return 10;
        if (checkWin(-1)) return -10;
        return 0; // Draw or non-terminal
    }

    @Override
    public void display() {
        for (int[] row : board) {
            for (int cell : row) {
                char symbol = ' ';
                if (cell == 1) symbol = 'X';
                if (cell == -1) symbol = 'O';
                System.out.print("|" + symbol);
            }
            System.out.println("|");
        }
        System.out.println();
    }

    private boolean checkWin(int player) {
        // Rows
        for (int i = 0; i < 3; i++) {
            if (board[i][0] == player && board[i][1] == player && board[i][2] == player) {
                return true;
            }
        }
        // Columns
        for (int i = 0; i < 3; i++) {
            if (board[0][i] == player && board[1][i] == player && board[2][i] == player) {
                return true;
            }
        }
        // Diagonals
        if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
            return true;
        }
        if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
            return true;
        }
        return false;
    }

    private boolean isBoardFull() {
        // Check if the board is full
        for (int[] row : board) {
            for (int cell : row) {
                if (cell == 0) return false;
            }
        }
        return true;
    }

    private int[][] copyBoard() {
        int[][] newBoard = new int[3][3];
        for (int i = 0; i < 3; i++) {
            newBoard[i] = Arrays.copyOf(board[i], 3);
        }
        return newBoard;
    }
}

