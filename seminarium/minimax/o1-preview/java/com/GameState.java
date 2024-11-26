import java.util.List;

public abstract class GameState {
    protected int currentPlayer;

    public GameState(int currentPlayer) {
        this.currentPlayer = currentPlayer;
    }

    public int getCurrentPlayer() {
        return currentPlayer;
    }

    // Generates possible next states from the current state
    public abstract List<GameState> getPossibleStates();

    // Checks if the game has reached a terminal state
    public abstract boolean isTerminal();

    // Evaluates the game state and returns a heuristic value
    public abstract int evaluate();

    // Displays the game state
    public abstract void display();
}

