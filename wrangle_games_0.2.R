library(tidyverse)

###
username <- "cubicinfinity"
file_destination <- "data/lichess_cubicinfinity_2022-10-19.pgn"
link <- paste0("https://lichess.org/api/games/user/", username)
download.file(link, file_destination)
###

source("fen_move.R")

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

# Convert PGN moves to FEN
  # start with initial position (use FEN if from position game)
    # split empty spaces and add to space
    # identify space moved from and replace with blank (unless crazyhouse @)
    # concatenate and fill empty spaces
    # update turn (b|w)
    # update castling ability
    # update en passant target
    # update halfmove, or simply add a space if ignoring
    # update move number
for (i in 1:nrow(games)) {
  if (is.na(games[i,]$FEN)) {
    position <- "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  } else {
    position <- games[i,]$FEN
  }
  
  game_moves <- games[i,]$PGN %>% 
    # Remove the result from the PGN
    str_remove(" ?((1\\/2)|0|1)-((1\\/2)|0|1)$") %>% 
    # Get just the moves themselves
    str_remove_all("\\d+\\.+ ") %>% 
    str_split(" ")
  
  for (move in game_moves) {
    position <- fen_move(position, move)
  }
}



# Arrange first K FEN moves into tibble
K <- 7
game_positions <- tibble()
positions <- c()
number <- 0
for (line in fen) {
  new_number <- as.numeric(str_extract(line, '\\d+(?=")'))
  if (new_number < number || new_number >= K+1) {
    if (length(positions) > 0) {
      new_row <- as_tibble(t(positions))
      colnames(new_row) <- paste0("p", 1:length(positions))
      game_positions <- game_positions %>% 
        bind_rows(new_row)
    }
    positions <- c()
  }
  if (new_number < K+1) {
    positions <- 
      append(positions, str_extract(line, '[^"]+(?=  )'))
  }
  number <- new_number
}

View(game_positions)
