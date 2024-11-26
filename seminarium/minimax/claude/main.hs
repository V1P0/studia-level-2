{-# LANGUAGE MultiWayIf #-}

module TicTacToeGame where

import Data.Maybe (fromMaybe, isNothing)
import Data.List (intercalate, maximumBy, minimumBy)
import Data.Ord (comparing)
import System.IO (hFlush, stdout)

-- Player and State Types
data Player = X | O deriving (Show, Eq)
data TicTacToeState = TicTacToeState 
    { board :: [[Maybe Player]]
    , currentPlayer :: Player
    , moveHistory :: [TicTacToeState]  -- Add move history
    } deriving (Show, Eq)

-- Game State Typeclass
class GameState a where
    generateMoves :: a -> [a]
    evaluateState :: a -> Int
    isGameOver :: a -> Bool

-- Implement GameState for Tic-Tac-Toe
instance GameState TicTacToeState where
    generateMoves state = 
        [makeMove state row col | 
            row <- [0..2], 
            col <- [0..2], 
            isNothing (board state !! row !! col)]
    
    evaluateState state
        | hasWon X state = 10
        | hasWon O state = -10
        | otherwise = 0
    
    isGameOver state = 
        hasWon X state || hasWon O state || isBoardFull state

-- Move Generation with History Tracking
makeMove :: TicTacToeState -> Int -> Int -> TicTacToeState
makeMove state row col = 
    TicTacToeState 
        { board = updateBoard (board state) row col (currentPlayer state)
        , currentPlayer = switchPlayer (currentPlayer state)
        , moveHistory = state : moveHistory state  -- Prepend current state to history
        }

-- Board Update Utilities
updateBoard :: [[Maybe Player]] -> Int -> Int -> Player -> [[Maybe Player]]
updateBoard currentBoard row col player = 
    [ [if r == row && c == col 
       then Just player 
       else currentBoard !! r !! c 
      | c <- [0..2]] 
    | r <- [0..2]]

switchPlayer :: Player -> Player
switchPlayer X = O
switchPlayer O = X

-- Win Condition Checks
hasWon :: Player -> TicTacToeState -> Bool
hasWon player state = 
    let b = board state
        rows = any (all (== Just player)) b
        cols = any (all (== Just player)) (transpose b)
        diag1 = and [b !! i !! i == Just player | i <- [0..2]]
        diag2 = and [b !! i !! (2-i) == Just player | i <- [0..2]]
    in rows || cols || diag1 || diag2

isBoardFull :: TicTacToeState -> Bool
isBoardFull state = 
    all (all (/= Nothing)) (board state)

-- Utility Functions
transpose :: [[a]] -> [[a]]
transpose [] = []
transpose ([] : _) = []
transpose x = map head x : transpose (map tail x)

-- Pretty Printing
prettyPrintBoard :: TicTacToeState -> String
prettyPrintBoard state = 
    let renderCell Nothing  = "-"
        renderCell (Just X) = "X"
        renderCell (Just O) = "O"
        
        boardRows = map (intercalate " | " . map renderCell) (board state)
        separator = replicate 9 '-'
    in 
        unlines (boardRows ++ [separator, "Current Player: " ++ show (currentPlayer state)])

-- Minimax Algorithm with Depth Tracking
minimax :: (GameState a) 
        => Int           -- Maximum search depth
        -> Bool          -- Is maximizing player
        -> a             -- Current game state
        -> (a, Int)      -- Returns best move and its score
minimax depth isMaximizingPlayer state
    | depth == 0 || isGameOver state = (state, evaluateState state)
    | isMaximizingPlayer = maximizeMove depth state
    | otherwise = minimizeMove depth state

-- Maximize and Minimize Moves
maximizeMove :: (GameState a) => Int -> a -> (a, Int)
maximizeMove depth state = 
    let possibleMoves = generateMoves state
        scoredMoves = map (minimax (depth - 1) False) possibleMoves
    in maximumBy (comparing snd) scoredMoves

minimizeMove :: (GameState a) => Int -> a -> (a, Int)
minimizeMove depth state = 
    let possibleMoves = generateMoves state
        scoredMoves = map (minimax (depth - 1) True) possibleMoves
    in minimumBy (comparing snd) scoredMoves

-- Initial Board Setup
initialBoard :: TicTacToeState
initialBoard = TicTacToeState 
    { board = replicate 3 (replicate 3 Nothing)
    , currentPlayer = X 
    , moveHistory = []  -- Empty history
    }

-- Game Loop with History Printing
playGame :: Int -> TicTacToeState -> IO ()
playGame depth state = do
    -- Print current board
    putStrLn "\n--- Current Board ---"
    putStrLn $ prettyPrintBoard state
    
    -- Check if game is over
    if isGameOver state 
    then do
        putStrLn "Game Over!"
        if | hasWon X state -> putStrLn "X wins!"
           | hasWon O state -> putStrLn "O wins!"
           | otherwise -> putStrLn "It's a draw!"
        
        -- Optionally print move history
        putStrLn "\n--- Move History ---"
        mapM_ (putStrLn . prettyPrintBoard) (reverse $ moveHistory state)
    else do
        -- AI move for current player
        let (bestMove, score) = minimax depth (currentPlayer state == X) state
        
        putStrLn $ "AI Move for " ++ show (currentPlayer state)
        putStrLn $ "Move Score: " ++ show score ++ "\n"
        
        -- Continue game with new state
        playGame depth bestMove

-- Main function to start the game
main :: IO ()
main = do
    putStrLn "Starting Tic-Tac-Toe with Minimax AI"
    -- Adjust search depth as needed
    playGame 9 initialBoard  -- Reduced depth to 3 for faster demonstration