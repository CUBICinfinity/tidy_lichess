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


evaluate <- function(engine, fen, side = "w", depth = 35, verbose = TRUE) {
  engine$position(fen)
  
  if (verbose) {
    eval <- engine$run(paste("go depth", depth)) %>%
      .[length(.) - 1]
    print(fen)
    print(eval)
    eval <- eval %>% str_extract("(?<=score ).+(?= nodes)")
    print(eval)
  } else {
    eval <- engine$run(paste("go depth", depth)) %>%
      .[length(.) - 1] %>%
      str_extract("(?<=score ).+(?= nodes)")
  }
  
  if ((side %in% c("b", "black") && str_detect(fen, " w ")) ||
      (side %in% c("w", "white") && str_detect(fen, " b ")) ) {
    eval <- str_replace(eval, "(\\d+)", "-\\1") %>% 
      str_replace("--", "") # remove double negative
  }
  return(eval)
}


engine <- fish$new("engines/stockfish_15.1_win64/stockfish-windows-2022-x86-64-avx2.exe")
engine$setoption(paste("threads", detectCores() - 1))
engine$ucinewgame()
# engine$setoption(paste("threads", 1))


for (i in 1:nrow(games)) {
  if (games$Variant[i] != "Standard") {
    # Need Fairy Stockfish for this
    next
  }
  Sys.sleep(1) # out of paranoia
  side <- if_else(games$White[i] == "cubicinfinity", "w", "b")
  for (t in 1:number_of_turns) {
    # Set position 
    position <- games[i, col_index - (number_of_turns - t)][[1]]
    tries <- 0
    while (length(score) == 0 || is.na(score)) {
      if (tries > 5) {
        # engine failure. restart engine.
        engine <- fish$new("engines/stockfish_15.1_win64/stockfish-windows-2022-x86-64-avx2.exe")
        engine$setoption(paste("threads", detectCores() - 1))
        engine$ucinewgame()
        Sys.sleep(1) # out of paranoia
        tries <- 0
      }
      score <- evaluate(engine, position, side = side)
      tries <- tries + 1
    }
    games[i, col_index + t] <- score
  }
  engine$ucinewgame()
}

