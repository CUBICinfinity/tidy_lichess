library(tidyverse)
library(stockfish)
library(parallel)


### Run this only once
# username <- "cubicinfinity"
# file_destination <- "data/lichess_cubicinfinity_2022-10-19.pgn"
# link <- paste0("https://lichess.org/api/games/user/", username)
# download.file(link, file_destination)
###

source("fen_move.R")

# Select number of moves to add to tibble. These are half-moves, not full-moves.
number_of_turns <- 8

pgn <- read_lines("data/lichess_cubicinfinity_2022-10-19.pgn")

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

# The data may be pivoted longer later if desired.
for (i in 1:number_of_turns) {
  eval(parse(text = paste0("games$turn_", i, " <- ''")))
}

# Convert PGN moves to FEN
for (i in 1:nrow(games)) {
  if (is.na(games$FEN[i])) {
    position <- "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  } else {
    position <- games$FEN[i]
  }
  
  game_moves <- games$PGN[i] %>% 
    # Remove the result from the PGN
    str_remove(" ?((1\\/2)|0|1)-((1\\/2)|0|1)$") %>% 
    # Get just the moves themselves
    str_remove_all("\\d+\\.+ ") %>% 
    str_split(" ") %>% 
    unlist()
  
  for (t in 1:number_of_turns) {
    if (t > length(game_moves)) {
      break
    }
    position <- fen_move(position, game_moves[t], games$Variant[i])
    games[i, length(games) - (number_of_turns - t)] <- position
  }
}


# Get Stockfish evaluations

col_index <- length(games)
# Initialize more columns for eval at each position
for (i in 1:number_of_turns) {
  eval(parse(text = paste0("games$turn_", i, "_eval", " <- ''")))
}

engine <- fish$new("engines/stockfish_15.1_win64/stockfish-windows-2022-x86-64-avx2.exe")

# test case
engine$position("rnb1kbnr/pp2pp1p/1qp3p1/3p4/4P3/2NB1N2/PPPP1PPP/R1BQK2R w KQkq - 2 5")
(eval <- engine$run("eval") %>% 
  .[length(.) - 1] %>% 
  str_extract("-?\\d+\\.\\d+"))

evaluate <- function(engine, fen, side = "w", depth = 30) {
  engine$position(fen)
  eval <- engine$run(paste("go depth", depth)) %>% 
    .[length(.) - 1] %>% 
    str_extract("(?<=score ).+(?= nodes)")
  if ((side %in% c("b", "black") && str_detect(fen, " w ")) ||
      (side %in% c("w", "white") && str_detect(fen, " b ")) ) {
    eval <- str_replace(eval, "(\\d+)", "-\\1")
  } 
  return(eval)
}

engine$setoption(paste("threads", detectCores() - 1))

# Equal position
pos = "rnbqkbnr/pp2pp1p/2p3p1/3p4/4P3/2NB4/PPPP1PPP/R1BQK1NR w KQkq - 0 4"
evaluate(engine, pos, "w")
# Play a bad move
pos = "rnbqkbnr/pp2pp1p/2p3p1/3N4/4P3/3B4/PPPP1PPP/R1BQK1NR b KQkq - 0 4"
evaluate(engine, pos, "w")


# There may not be a way to reduce the initial output
# (https://stackoverflow.com/questions/74904491/how-to-retrieve-stockfish-evaluation-score-with-nnue-by-itself-using-the-stockfi)

test_func <- function (engine, command) {
  return(utils::tail(engine$run(command, infinite), 1))
}


for (i in 1:nrow(games)) {
  if (games$Variant[i] != "Standard") {
    next
  }
  for (t in 1:number_of_turns) {
    # Set position 
    engine$position(games[i, col_index - (number_of_turns - t)])
  }
  
}

