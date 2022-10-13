fen_move <- function(fen, move) {
  # Parse FEN
  parsed_fen <- str_match(fen, "([^ ]+) ([wb]) ([KQkq]+) ([a-h-][1-8]?) (\\d+) (\\d+)( \\+(\\d+)\\+(\\d+))?")
  
  position <- parsed_fen[2]
  turn <- parsed_fen[3]
  castle_rights <- parsed_fen[4]
  en_passant_target <- parsed_fen[5]
  halfmove_clock <- parsed_fen[6] # for 50 move rule
  move_number <- as_numeric(parsed_fen[7])
  # needed for Three Check variant
  white_checks <- as_numeric(parsed_fen[9]) # FOR white, not against white
  black_checks <- as_numeric(parsed_fen[10]) # FOR black, not against black
  
  
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
  if (str_detect(move, "O-O[+#]?")) {
    halfmove_clock <- halfmove_clock + 1
    rfile <- 0
    if (turn == "w") {
      castle_rights <- str_remove(castle_rights, "[KQ]")
      home_rank = str_extract(position, "[^/]*$")
      kfile <- str_locate(home_rank, "K")[1]
      for (i in (kfile+1):8) {
        if (substr(home_rank, i, i) == "R"){
          rfile <- i
          break
        }
      }
      substr(home_rank, rfile, rfile) <- "1"
      substr(home_rank, kfile, kfile) <- "1"
      substr(home_rank, 6, 6) <- "R"
      substr(home_rank, 7, 7) <- "K"
      position <- str_replace(position, "[^/]*$", home_rank)
    } else {
      castle_rights <- str_remove(castle_rights, "[kq]")
      home_rank = str_extract(position, "^[^/]*")
      kfile <- str_locate(home_rank, "k")[1]
      for (i in (kfile+1):8) {
        if (substr(home_rank, i, i) == "r"){
          rfile <- i
          break
        }
      }
      substr(home_rank, rfile, rfile) <- "1"
      substr(home_rank, kfile, kfile) <- "1"
      substr(home_rank, 6, 6) <- "r"
      substr(home_rank, 7, 7) <- "k"
      position <- str_replace(position, "^[^/]*", home_rank)
    }
    
    # A-SIDE CASTLE
  } else if (str_detect(move, "O-O-O[+#]?")) {
    halfmove_clock <- halfmove_clock + 1
    rfile <- 0
    if (turn == "w") {
      castle_rights <- str_remove(castle_rights, "[KQ]")
      home_rank = str_extract(position, "[^/]*$")
      kfile <- str_locate(home_rank, "K")[1]
      for (i in (kfile-1):1) {
        if (substr(home_rank, i, i) == "R"){
          rfile <- i
          break
        }
      }
      substr(home_rank, rfile, rfile) <- "1"
      substr(home_rank, kfile, kfile) <- "1"
      substr(home_rank, 4, 4) <- "R"
      substr(home_rank, 3, 3) <- "K"
      position <- str_replace(position, "[^/]*$", home_rank)
    } else {
      castle_rights <- str_remove(castle_rights, "[kq]")
      home_rank = str_extract(position, "^[^/]*")
      kfile <- str_locate(home_rank, "k")[1]
      for (i in (kfile-1):1) {
        if (substr(home_rank, i, i) == "r"){
          rfile <- i
          break
        }
      }
      substr(home_rank, rfile, rfile) <- "1"
      substr(home_rank, kfile, kfile) <- "1"
      substr(home_rank, 4, 4) <- "r"
      substr(home_rank, 3, 3) <- "k"
      position <- str_replace(position, "^[^/]*", home_rank)
    }
    
    # OTHER MOVES
  } else {
    # [piece?, file?, rank?, capture?, ch_place?, target, promotion, check(mate)?]
    move_parts <- str_match(move, "([RNBQKrnbqk]?)([a-h]?)([1-8]?)(x?)(@?)([a-h][1-8])(=[RNBQK])?([+#]?)?")
    
    position_2d <- position %>% 
      str_split("\\/") %>% 
      unlist() %>% 
      str_split("")
    
    piece <- if_else(! is.na(move_parts[2]), 
                     move_parts[2], 
                     if_else(turn == "w", "P", "p"))
    
    
    capture <- ! is.na(move_parts[5])
    target <- unlist(str_split(move_parts[7], ""))
    target[1] <- charToRaw(target[1]) - 60
    target[2] <- as_numeric(target[2])
    
    if (! is.na(move_parts[6])) {
      # crazyhouse place
      # just change at target
      
    } else {
      
      file <- charToRaw(move_parts[3]) - 60
      rank <- (8:1)[as_numeric(move_parts[4])]
      
      # Find Source
      # Simply pick first valid source because PGN disambiguates for us.
      if (! is.na(file) && ! is.na(rank)) {
        # source already given
        source_file <- file
        source_rank <- rank
        
      } else if (! is.na(file)) {
        source_file <- file
        # determine source rank
        
        if (piece %in% c("p","P")) {
          # handle pawn moves
          pawn_direction <- if_else(piece == "P", -1, 1)
          source_rank <- target[2] - pawn_direction
          
          if (position_2d[[source_rank]][source_file] != piece) {
            # double move
            source_rank <- target[2] - pawn_direction*2
            # Add en passant flag
            en_passant_target <- paste0(target[1], target[2])
          }
        }
        
        

        
      } else if (! is.na(rank)) {
        source_rank <- rank
        
        # determine source file
        
        if (piece %in% c("p","P")) {
          # handle pawn moves
          pawn_direction <- if_else(piece == "P", -1, 1)
          if (rank == target[2] - pawn_direction*2) {
            source_file <- target[1]
            # Add en passant flag
            en_passant_target <- paste0(target[1], target[2])
          } else if (capture) {
            if (target[1] == 1) {
              source_file <- 2
            } else if (position_2d[[source_rank]][target[1] - 1] == piece) {
              source_file <- target[1] - 1
            } else {
              source_file <- target[1] + 1
            }
            # detect en passant capture
            if (position_2d[[target[2]]][target[1]] == "1") {
              # remove lower pawn.
              position_2d[[target[2] - pawn_direction]][target[1]] <- "1"
            }
          } else {
            source_file <- target[1]
          }
        }
        
        
      } else {
        # determine source both rank and file
        
        if (piece %in% c("p","P")) {
          # handle pawn moves
          pawn_direction <- if_else(piece == "P", -1, 1)
          source_rank <- target[2] - pawn_direction
          if (capture) {
            if (target[1] == 1) {
              source_file <- 2
            } else if (position_2d[[source_rank]][target[1] - 1] == piece) {
              source_file <- target[1] - 1
            } else {
              source_file <- target[1] + 1
            }
            # detect en passant capture
            if (position_2d[[target[2]]][target[1]] == "1") {
              # remove lower pawn.
              position_2d[[target[2] - pawn_direction]][target[1]] <- "1"
            }
          } else {
            source_file <- target[1]
            if (position_2d[[source_rank]][target[1]] != piece) {
              # double move
              source_rank <- target[2] - pawn_direction*2
              # Add en passant flag
              en_passant_target <- paste0(target[1], target[2])
            }
          }
        }
        
        
        
      }
      
      
      source <- c(source_file, source_rank)
      
      if (! is.na(move_parts[8])) {
        # This is a promotion. Update piece now.
        piece <- substr(move_parts[8], 2, 2)
      }
      
      
    }
    
    
  }
  
  # CONCATENATE EMPTY SPACES
  position <- str_replace_all(position, c("11111111"="8",
                                          "1111111"="7",
                                          "111111"="6",
                                          "11111"="5",
                                          "1111"="4",
                                          "111"="3",
                                          "11"="2"))
  
  if (turn == "w") {
    turn <- "b"
  } else {
    turn <- "w"
    move_number <- move_number + 1
  }
  
  # Update check counts for Three Check variant
  if (!is.na(white_checks) && str_detect(move, "[+]$")) {
    if (turn == "w") {
      white_checks = white_checks + 1
    } else {
      black_checks = black_checks + 1
    }
  }
  
  fen <- paste(position, turn, castle_rights, en_passant_target, halfmove_clock, 
               move_number) %>% 
    paste0(if_else(!is.na(white_checks), 
                   paste0(" +", white_checks, "+", black_checks), 
                   ""))
  return(fen)
}

fen_move("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "O-O")
fen_move("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "O-O-O")
fen_move("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "")
fen_move("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "Nf6")
