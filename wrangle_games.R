library(tidyverse)

pgn <- read_lines("lichess_cubicinfinity_2022-09-21.pgn")

# Problem with converting crazyhouse: fen <- read_lines("FEN_2022-09-21.txt")

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
    start <- "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  } else {
    start <- games[i,]$FEN
  }
  
  # Parse FEN start 
  # I already wrote this, but in the future I should use multiple capture groups
  # use str_match
  position <- str_extract(start, "^[^ ]+")
  turn <- str_extract(start, "(?<= )(w|b)(?= )")
  castle_rights <- str_extract(start, "(?<=(b|w) )[^ ]+")
  en_passant_targets <- start %>% 
    str_extract("(?<=(b|w) )[^ ]+ [^ ]+") %>% 
    str-extract("[^ ]+$")
  halfmove_clock <- str_extract(start, "(?<= )\\d+(?= )")
  move_number <- str_match(start, " \\d+ (\\d+)")[2]
  # needed for Three Check variant
  checks <- str_match(start, "(\\+\\d+)(\\+\\d+)")
  white_checks <- str_extract(checks[2], "\\d+") # FOR white, not against white
  black_checks <- str_extract(checks[3], "\\d+") # FOR black, not against black
  
  game_moves <- games[i,]$PGN %>% 
    # Remove the result from the PGN
    str_remove(" ?((1\\/2)|0|1)-((1\\/2)|0|1)$") %>% 
    # Get just the moves themselves
    str_remove_all("\\d+\\.+ ") %>% 
    str_split(" ")
  
  for (move in game_moves) {
    # SPLIT EMPTY SPACES
    position <- str_replace_all(position, c("2"="11",
                                            "3"="111",
                                            "4"="1111",
                                            "5"="11111",
                                            "6"="111111",
                                            "7"="1111111",
                                            "8"="11111111"))
    
    # Castling logic supports 960
    # Assumes castling is valid
    # H-SIDE CASTLE 
    if (move == "O-O") {
      rfile <- 0
      if (turn == "w") {
        home_rank = str_extract(position, "[^/]*$")
        kfile <- str_locate(home_rank, "K")
        for (i in (kfile+1):8) {
          if (home_rank[i] == "R"){
            rfile <- i
            break
          }
        }
        home_rank[rfile] <- 1
        home_rank[kfile] <- 1
        home_rank[6] <- "R"
        home_rank[7] <- "K"
        position <- str_replace(position, "[^/]*$", home_rank)
      } else {
        home_rank = str_extract(position, "^[^/]*")
        kfile <- str_locate(home_rank, "k")
        for (i in (kfile+1):8) {
          if (home_rank[i] == "r"){
            rfile <- i
            break
          }
        }
        home_rank[rfile] <- 1
        home_rank[kfile] <- 1
        home_rank[6] <- "r"
        home_rank[7] <- "k"
        position <- str_replace(position, "^[^/]*", home_rank)
      }
    
    # A-SIDE CASTLE
    } else if (move == "O-O-O") {
      rfile <- 0
      if (turn == "w") {
        home_rank = str_extract(position, "[^/]*$")
        kfile <- str_locate(home_rank, "K")
        for (i in (kfile-1):1) {
          if (home_rank[i] == "R"){
            rfile <- i
            break
          }
        }
        home_rank[rfile] <- 1
        home_rank[kfile] <- 1
        home_rank[4] <- "R"
        home_rank[3] <- "K"
        position <- str_replace(position, "[^/]*$", home_rank)
      } else {
        home_rank = str_extract(position, "^[^/]*")
        kfile <- str_locate(home_rank, "k")
        for (i in (kfile-1):1) {
          if (home_rank[i] == "r"){
            rfile <- i
            break
          }
        }
        home_rank[rfile] <- 1
        home_rank[kfile] <- 1
        home_rank[4] <- "r"
        home_rank[3] <- "k"
        position <- str_replace(position, "^[^/]*", home_rank)
      }
    
    # OTHER MOVES
    } else {
      # [piece?, file?, rank?, ch_place?, target]
      move_parts <- str_match(move, "([RNBQK]?)([a-h]?)([1-8]?)x?(@?)([a-h][1-8])[+#]?")
      # pass for now
    }
    
    # CONCATENATE EMPTY SPACES
    position <- str_replace_all(position, c("11111111"="8",
                                            "1111111"="7",
                                            "111111"="6",
                                            "11111"="5",
                                            "1111"="4",
                                            "111"="3",
                                            "11"="2"))
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
