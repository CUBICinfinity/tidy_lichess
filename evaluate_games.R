# This is a variation of wrangle_games.R, which processes all moves from each 
# game and adds a computer evaluation.
#
# We are not going to limit processing with number_of_turns. 
# We'll also build the data in long format.
#
#
# Target data format:
# Site, Variant, Side, MoveId, Move, FEN, Eval, EvalNorm, EvalDiff
#
# Site: Unique ID for the game (URL)
# Variant: Game variation
# Side: Self playing as black or white
# MoveId: The number of halfmoves made until this position. Starts at 0 if opening position is included.
# Move: The last move that was played (algebraic notation)
# FEN: The current position
# Eval: Strength of the position for white, according to engine, text format
# EvalNum: Calculated from Eval as a single number. Mate in X = max(10000 - log(X) * 1000, 400) CentiPawns, Mate delivered = +/- Inf
# EvalNorm: Sigmoid normalization [-1, 1] of EvalNum
# EvalDiff: Change in EvalNorm from previous position

library(tidyverse)
library(stockfish)
library(parallel)

source("fen_move.R")
source("engine_evaluate.R")

username <- "cubicinfinity"

### Run this only once
# file_destination <- paste0("data/lichess_cubicinfinity_", Sys.Date(), ".pgn")
# link <- paste0("https://lichess.org/api/games/user/", username)
# download.file(link, file_destination)
###

# Change the filename as needed
pgn <- read_lines("data/lichess_cubicinfinity_2022-12-28.pgn")

# Arrange PGN meta into tibble of games
games <- tibble()
open_game <- FALSE
names <- c()
values <- c()
for (line in pgn) {
  if (str_detect(line, "^\\[")) {
    open_game <- TRUE
    names <- append(names, str_extract(line, "(?<=\\[)\\w+"))
    values <- append(values, str_extract(line, '(?<=")[^"]+'))
  }
  else if (open_game == TRUE) {
    values <- t(values)
    colnames(values) <- names
    games <- games %>% 
      bind_rows(as_tibble(values))
    open_game <- FALSE
    names <- c()
    values <- c()
  }
}

# Extract PGN moves
moves <- c()
for (line in pgn) {
  if (str_detect(line, "^\\d")) {
    moves <- append(moves, line)
  }
}
games$PGN <- moves

# At this point, we have the main dataset with one game on each row.
write_csv(games, "data/games.csv")
# Next, we'll get the long dataset containing every position.

games <- read_csv("data/games.csv")

games <- games %>% 
  mutate(Side = if_else(White == username, "w", "b"),
         Start = if_else(is.na(FEN), "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", FEN)) %>% 
  select(Site, Variant, Start, Side, PGN) %>% 
  # Limiting to normal chess. Fairy Stockfish may be used for other variants.
  # Why Chess960 is not included: https://chess.stackexchange.com/q/41246/30060
  filter(Variant %in% c("Standard", "From Position"))


# Individual process for a game
# `engine$ucinewgame()` isn't necessary and has been left unused, but might be desirable.
analyze_game <- function(game, engine_file, depth, cores) {
  engine <- fish$new(engine_file)
  engine$setoption(paste("threads", cores))
  
  moves <- str_remove_all(game$PGN, "\\d+\\.+ ") %>% 
    str_remove(" [^ ]*$") %>% 
    str_split(" ") %>% 
    .[[1]]
  pos <- game$Start
  positions <- character()
  scores <- character()
  
  if (game$Variant == "From Position") {
    score <- eval_redundant(engine, engine_file, pos, game$Side, depth = depth, cores = cores)
    first_row <- tibble(Site = game$Site,
                        Variant = game$Variant,
                        Side = game$Side,
                        MoveId = 0,
                        Move = "",
                        FEN = pos,
                        Eval = score)
  }
  
  for (i in 1:length(moves)) {
    move <- moves[i]
    pos <- fen_move(pos, move)
    if (str_detect(move, "#$")) {
      # Stop now to avoid analyzing a game that has already ended.
      scores <- append(scores, 
                       if_else(str_extract(pos, "(?<= )[bw](?= )") == game$Side, 
                               "game lost", 
                               "game won"))
    } else {
      positions <- append(positions, pos)
      scores <- append(scores, eval_redundant(engine, engine_file, pos, 
                                              game$Side, depth = depth))
    }
  }
  
  analyzed_game <- tibble(Site = game$Site,
                          Variant = game$Variant,
                          Side = game$Side,
                          MoveId = 1:length(moves),
                          Move = moves,
                          FEN = positions,
                          Eval = scores)
  
  if (game$Variant == "From Position") {
    anazlyzed_game <- add_row(analyzed_game, first_row, .before = 1)
  }
  
  return(analyzed_game)
}


# With over 800 games, this takes about 60 hours on my CPU.
#
# I looked into running Stockfish on the GPU, thinking perhaps some work can 
# be done on the CPU and some on the GPU; but Stockfish isn't built to be  
# processed with the GPU and rewriting it to do so is not a simple task.
# Almost certainly, evaluating a single game is best done on the CPU.
#
# There are still other things to be done to reduce computation. Need to test 
# supporting `ucinewgame` as this might help Stockfish think about the next move.
engine_file <- "engines/stockfish_15.1_win64/stockfish-windows-2022-x86-64-avx2.exe"
options(mc.cores = detectCores()-4)
positions <- mclapply(split(games, games$Site), 
                      function(x) { 
                        analyze_game(x, engine_file, depth = 35, cores = detectCores())
                        }) %>% 
  bind_rows()

write_csv(positions, "data/positions.csv")

