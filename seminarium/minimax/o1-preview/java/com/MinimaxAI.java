public class MinimaxAI {
    public int minimax(GameState state, int depth, boolean maximizingPlayer) {
        if (state.isTerminal() || depth == 0) {
            return state.evaluate();
        }

        if (maximizingPlayer) {
            int maxEval = Integer.MIN_VALUE;
            for (GameState child : state.getPossibleStates()) {
                int eval = minimax(child, depth - 1, false);
                maxEval = Math.max(maxEval, eval);
            }
            return maxEval;
        } else {
            int minEval = Integer.MAX_VALUE;
            for (GameState child : state.getPossibleStates()) {
                int eval = minimax(child, depth - 1, true);
                minEval = Math.min(minEval, eval);
            }
            return minEval;
        }
    }

    public GameState findBestMove(GameState state, int depth, boolean maximizingPlayer) {
        int bestValue = Integer.MIN_VALUE;
        GameState bestMove = null;

        for (GameState child : state.getPossibleStates()) {
            int moveValue = minimax(child, depth - 1, maximizingPlayer);
            if (moveValue > bestValue) {
                bestValue = moveValue;
                bestMove = child;
            }
        }
        return bestMove;
    }
}
