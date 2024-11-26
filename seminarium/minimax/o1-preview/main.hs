module TicTacToeGame where

import Data.Function (on)
import Data.List (maximumBy, minimumBy)
import Control.Applicative ((<|>))
import Data.List (transpose)
import Data.Maybe (isJust, fromMaybe, fromJust)
import Control.Monad (forM_)
import Data.List (intersperse)

-- Define the player types
data Player = X | O deriving (Eq, Show)

-- Define the cell states
data Cell = Empty | Filled Player deriving (Eq)

-- Show instance for Cell for display purposes
instance Show Cell where
    show Empty        = " "
    show (Filled X)   = "X"
    show (Filled O)   = "O"

-- Define the board as a list of lists
type Board = [[Cell]]

-- Define the game state
data GameState = GameState {
    board :: Board,
    currentPlayer :: Player
} deriving (Eq, Show)

-- Initial empty board
initialBoard :: Board
initialBoard = replicate 3 (replicate 3 Empty)

-- Initial game state
initialState :: GameState
initialState = GameState initialBoard X

-- Switch the player
switchPlayer :: Player -> Player
switchPlayer X = O
switchPlayer O = X

-- Check if the board is full
isBoardFull :: Board -> Bool
isBoardFull = all (all (/= Empty))

-- Get the winner, if any
getWinner :: Board -> Maybe Player
getWinner b =
    let lines = rows ++ columns ++ diagonals
        rows = b
        columns = transpose b
        diagonals = [ [b !! i !! i | i <- [0..2]],
                      [b !! i !! (2 - i) | i <- [0..2]] ]
        checkLine [Filled p, Filled p', Filled p'']
            | p == p' && p' == p'' = Just p
        checkLine _ = Nothing
    in foldl (\acc line -> acc <|> checkLine line) Nothing lines

-- Generate all possible moves from the current state
possibleMoves :: GameState -> [GameState]
possibleMoves (GameState b p) =
    [ GameState (replace2D i j (Filled p) b) (switchPlayer p)
    | i <- [0..2], j <- [0..2], b !! i !! j == Empty ]

-- Helper function to replace an element in a 2D list
replace2D :: Int -> Int -> a -> [[a]] -> [[a]]
replace2D i j val b =
    take i b ++
    [take j (b !! i) ++ [val] ++ drop (j + 1) (b !! i)] ++
    drop (i + 1) b

-- Evaluation function
evaluate :: GameState -> Int
evaluate gs =
    case getWinner (board gs) of
        Just X -> 1
        Just O -> -1
        Nothing -> 0

-- Minimax function
minimax :: GameState -> Int
minimax gs
    | isJust winner = evaluate gs
    | isBoardFull (board gs) = 0
    | currentPlayer gs == X = maximum $ map minimax (possibleMoves gs)
    | otherwise             = minimum $ map minimax (possibleMoves gs)
  where
    winner = getWinner (board gs)

-- Find the best move for the current player
bestMove :: GameState -> GameState
bestMove gs@(GameState _ p)
    | p == X    = maximumBy (compare `on` minimax) moves
    | otherwise = minimumBy (compare `on` minimax) moves
  where
    moves = possibleMoves gs


-- Display the board
displayBoard :: Board -> IO ()
displayBoard b = do
    forM_ b $ \row -> do
        putStrLn $ " " ++ (intersperse '|' $ concatMap show row)
        putStrLn "---+---+---"
    putStrLn ""

-- Main game loop
gameLoop :: GameState -> IO ()
gameLoop gs@(GameState b p) = do
    displayBoard b
    if isJust (getWinner b)
        then putStrLn $ "Player " ++ show (fromJust (getWinner b)) ++ " wins!"
    else if isBoardFull b
        then putStrLn "It's a draw!"
    else do
        let gs' = bestMove gs
        gameLoop gs'

main :: IO ()
main = gameLoop initialState
