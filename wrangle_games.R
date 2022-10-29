library(tidyverse)



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

