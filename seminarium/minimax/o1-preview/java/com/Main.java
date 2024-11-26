import java.util.List;

public class Main {
    public static void main(String[] args) {
        int[][] initialBoard = new int[3][3]; // Empty board
        GameState currentState = new TicTacToeState(1, initialBoard);

        MinimaxAI ai = new MinimaxAI();

        // AI plays as player 1
        while (!currentState.isTerminal()) {
            currentState.display();
            if (currentState.getCurrentPlayer() == 1) {
                // AI's turn
                currentState = ai.findBestMove(currentState, 9, true);
            } else {
                currentState = ai.findBestMove(currentState, 9, false);
            }
        }
        currentState.display();
        System.out.println("Game Over");
    }
}
