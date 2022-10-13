# library(tidyverse)

is_void <- function(x) {
  return (is.na(x) || x == "" || length(x) == 0)
}

# need to add error handling

fen_move <- function(fen, move) {
  # Parse FEN
  parsed_fen <- str_match(fen, "([^ ]+) ([wb]) ([KQkq-]+) ([a-h-][1-8]?) (\\d+) (\\d+)( \\+(\\d+)\\+(\\d+))?")
  print(parsed_fen)
  
  position <- parsed_fen[2]
  turn <- parsed_fen[3]
  castle_rights <- parsed_fen[4]
  en_passant_target <- parsed_fen[5]
  halfmove_clock <- as.numeric(parsed_fen[6]) # for 50 move rule
  move_number <- as.numeric(parsed_fen[7])
  # needed for Three Check variant
  white_checks <- as.numeric(parsed_fen[9]) # FOR white, not against white
  black_checks <- as.numeric(parsed_fen[10]) # FOR black, not against black
  
  
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
  if (str_detect(move, "(?<!-)O-O[+#]?$")) {
    halfmove_clock <- halfmove_clock + 1
    rfile <- 0
    if (turn == "w") {
      castle_rights <- str_remove_all(castle_rights, "[KQ]")
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
      castle_rights <- str_remove_all(castle_rights, "[kq]")
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
      castle_rights <- str_remove_all(castle_rights, "[KQ]")
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
      castle_rights <- str_remove_all(castle_rights, "[kq]")
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
    print("normal kind of move")
    # [piece?, file?, rank?, capture?, ch_place?, target, promotion, check(mate)?]
    move_parts <- str_match(move, "([RNBQKrnbqk]?)([a-h]?)([1-8]?)(x?)(@?)([a-h][1-8])(=[RNBQK])?([+#]?)?")
    print(move_parts)
    
    print(paste("position=", position))
    position_2d <- position %>% 
      str_split("\\/") %>% 
      unlist() %>% 
      str_split("")
    
    piece <- if_else(turn == "w",
                     case_when(
                       move_parts[2] == "" ~ "P",
                       move_parts[2] == "R" ~ "R",
                       move_parts[2] == "N" ~ "N",
                       move_parts[2] == "B" ~ "B",
                       move_parts[2] == "Q" ~ "Q",
                       move_parts[2] == "K" ~ "K"),
                     case_when(
                       move_parts[2] == "" ~ "p",
                       move_parts[2] == "R" ~ "r",
                       move_parts[2] == "N" ~ "n",
                       move_parts[2] == "B" ~ "b",
                       move_parts[2] == "Q" ~ "q",
                       move_parts[2] == "K" ~ "k"))
    
    print(paste("piece is", piece))
    
    capture <- move_parts[5] != ""
    target <- unlist(str_split(move_parts[7], ""))
    print(paste("target =",target))
    target_file <- as.numeric(charToRaw(target[1])) - 96
    if (length(target_file) == 0) {
      # this shouldn't happen. I guess this is temporary caution
      target_file <- NA
    }
    target_rank <- (8:1)[as.numeric(target[2])] # We're reversing the order to match the way I've constructed position_2d
    
    if (! is_void(move_parts[6])) {
      print("crazyhouse placement")
      # crazyhouse place. just change at target
      position_2d[[target_rank]][target_file] <- piece
      
    } else {
      
      print(paste("moving to", target_file, target_rank))
      
      file <- as.numeric(charToRaw(move_parts[3])) - 96
      if (length(file) == 0) {
        file <- NA
      }
      rank <- (8:1)[as.numeric(move_parts[4])] # reversed order here as well
      
      if (capture || piece %in% c("p", "P")) {
        halfmove_clock <- 0
      } else {
        halfmove_clock <- halfmove_clock + 1
      }
      
      # Find Source
      # Simply pick first valid source because PGN disambiguates for us.
      if (! is.na(file) && ! is.na(rank)) {
        print("source given")
        # source already given
        source_file <- file
        source_rank <- rank
        
      } else if (! is.na(file)) {
        print("source file given")
        source_file <- file
        source_rank <- 0
        # determine source rank
        
        if (piece %in% c("p","P")) {
          # handle pawn moves
          pawn_direction <- if_else(piece == "P", -1, 1)
          source_rank <- target_rank - pawn_direction
          
          if (position_2d[[source_rank]][source_file] != piece) {
            # double move
            source_rank <- target_rank - pawn_direction*2
            if ((target_file - 1 > 0 
                  && position_2d[[target_rank]][target_file - 1] == if_else(turn == "w", "p", "P"))
                || (target_file + 1 < 9
                    && position_2d[[target_rank]][target_file + 1] == if_else(turn == "w", "p", "P"))) {
              # Add en passant flag
              en_passant_target <- 
                paste0(c("a","b","c","d","e","f","g","h")[target_file], 
                       (8:1)[target_rank + if_else(turn == "w", 1, -1)])
            }
          }
        }
        
        else if (piece %in% c("r", "R")) {
          # Handle rook moves
          
          # look up
          for (r in (target_rank:1)[-1]) {
            if (position_2d[[r]][target_file] == piece) {
              source_rank <- r
              source_file <- target_file
              break
            }
          }
          if (source_rank == 0) { # not found
            # look down
            for (r in (target_rank:8)[-1]) {
              if (position_2d[[r]][target_file] == piece) {
                source_rank <- r
                source_file <- target_file
                break
              }
            }
          }
        }
        
        else if (piece %in% c("b", "B")) {
          # Handle bishop moves
          distance <- abs(source_file - target_file)
          if (target_rank + distance < 9) {
            if (distance > 1) {
              # Check for obstructions
              valid <- TRUE
              for (d in (0:(distance - 1))[-1]) {
                if (position_2d[[target_rank + d]][source_file + d] != "1") {
                  valid <- FALSE
                }
              }
            }
            if (valid == TRUE &&
                position_2d[[target_rank + distance]][target_file] == piece) {
              source_rank <- target_rank + distance
            }
          } else {
            # assume other direction is correct
            source_rank <- target_rank - distance
          }
        }
        
        else if (piece %in% c("q", "Q")) {
          # Handle queen moves
          
          if (target_file == source_file) {
            # check along file
            # look up
            for (r in (target_rank:1)[-1]) {
              if (position_2d[[r]][target_file] == piece) {
                source_rank <- r
                break
              }
            }
            if (source_rank == 0) {
              # look down
              for (r in (target_rank:8)[-1]) {
                if (position_2d[[r]][target_file] == piece) {
                  source_rank <- r
                  break
                }
              }
            }
          } else {
            # check three points, but also for obstructions
            distance <- abs(source_file - target_file)
            direction <- if_else(source_file < target_file, -1, 1)
            # horizontal
            if (position_2d[[target_rank]][source_file] == piece) {
              if (distance > 1) {
                valid = TRUE
                for (f in source_file + seq(distance - 1) * direction) {
                  if (position_2d[[target_rank]][f] != "1") {
                    valid = FALSE
                    break
                  }
                }
                if (valid) {
                  source_rank <- target_rank
                }
              } else {
                source_rank <- target_rank
              }
            }
            if (source_rank == 0 && target_rank - distance > 0) {
              if (position_2d[[target_rank + distance * direction]][source_file] == piece) {
                if (distance > 1) {
                  valid = TRUE
                  for (d in seq(distance - 1)) {
                    if (position_2d[[target_rank + d * direction]][target_file + d * direction] != "1") {
                      valid = FALSE
                      break
                    }
                  }
                  if (valid) {
                    source_rank <- target_rank - distance
                  }
                } else {
                  source_rank <- target_rank - distance
                }
              }
            }
            if (source_rank == 0) { # rank < 9 (assumed)
              source_rank <- target_rank + distance
            }
          }
        }
        
        else if (piece %in% c("n", "N")) {
          # Handle knight moves
          if (abs(source_file - target_file) == 1) {
            if (target_rank - 2 > 0 && 
                position_2d[[target_rank - 2]][source_file] == piece) {
              source_rank <- target_rank - 2
            } else {
              source_rank <- target_rank + 2
            }
          } else {
            if (target_rank - 1 > 0 && 
                position_2d[[target_rank - 1]][source_file] == piece) {
              source_rank <- target_rank - 1
            } else {
              source_rank <- target_rank + 1
            }
          }
        }
        
        else if (piece %in% c("k", "K")) {
          # Handle king moves
          if (target_rank - 1 > 0 && 
              position_2d[[target_rank - 1]][source_file] == piece) {
            source_rank <- target_rank - 1
          } else if (position_2d[[target_rank]][source_file] == piece) {
            source_rank <- target_rank
          } else {
            source_rank <- target_rank + 1
          }
        }
        
        
        
      } else if (! is.na(rank)) {
        print("source rank given")
        source_rank <- rank
        source_file <- 0
        
        # determine source file
        
        if (piece %in% c("p","P")) {
          # handle pawn moves
          pawn_direction <- if_else(piece == "P", -1, 1)
          if (rank == target_rank - pawn_direction*2) {
            source_file <- target_file
            if ((target_file - 1 > 0 
                 && position_2d[[target_rank]][target_file - 1] == if_else(turn == "w", "p", "P"))
                || (target_file + 1 < 9
                    && position_2d[[target_rank]][target_file + 1] == if_else(turn == "w", "p", "P"))) {
              # Add en passant flag
              en_passant_target <- 
                paste0(c("a","b","c","d","e","f","g","h")[target_file], 
                       (8:1)[[target_rank + if_else(turn == "w", 1, -1)]])
            }
          } else if (capture) {
            if (target_file == 1) {
              source_file <- 2
            } else if (position_2d[[source_rank]][target_file - 1] == piece) {
              source_file <- target_file - 1
            } else {
              source_file <- target_file + 1
            }
            # detect en passant capture
            if (position_2d[[target_rank]][target_file] == "1") {
              # remove lower pawn.
              position_2d[[target_rank - pawn_direction]][target_file] <- "1"
            }
          } else {
            source_file <- target_file
          }
        }
        
        else if (piece %in% c("r", "R")) {
          # Handle rook moves
          
          # look left
          for (f in (target_file:1)[-1]) {
            if (position_2d[[target_rank]][f] != 1) {
              if (position_2d[[target_rank]][f] == piece) {
                source_rank <- target_rank
                source_file <- f
              }
              break
            }
          }
          if (source_file == 0) { # not found
            # look right
            for (f in (target_file:8)[-1]) {
              if (position_2d[[target_rank]][f] != 1) {
                if (position_2d[[target_rank]][f] == piece) {
                  source_rank <- target_rank
                  source_file <- f
                }
                break
              }
            }
          }
        }
        
        else if (piece %in% c("b", "B")) {
          # Handle bishop moves
          distance <- abs(source_rank - target_rank)
          if (target_file + distance < 9) {
            if (distance > 1) {
              # Check for obstructions
              valid <- TRUE
              for (d in (0:(distance - 1))[-1]) {
                if (position_2d[[target_rank - d]][source_file + d] != "1") {
                  valid <- FALSE
                }
              }
            }
            if (valid == TRUE &&
                position_2d[[target_rank - distance]][target_file] == piece) {
              source_file <- target_file + distance
            }
          } else {
            # assume other direction is correct
            source_file <- target_file - distance
          }
        }
        
        else if (piece %in% c("q", "Q")) {
          # Handle queen moves
          
          if (target_rank == source_rank) {
            # check along file
            # look up
            for (f in (target_file:1)[-1]) {
              if (position_2d[[target_rank]][f] == piece) {
                source_rank <- f
                break
              }
            }
            if (source_rank == 0) {
              # look down
              for (f in (target_file:8)[-1]) {
                if (position_2d[[target_rank]][f] == piece) {
                  source_rank <- f
                  break
                }
              }
            }
          } else {
            # check three points, but also for obstructions
            distance <- abs(source_rank - target_rank)
            direction <- if_else(source_rank < target_rank, -1, 1)
            # horizontal
            if (position_2d[[source_rank]][target_file] == piece) {
              if (distance > 1) {
                valid = TRUE
                for (r in source_file + seq(distance - 1) * direction) {
                  if (position_2d[[r]][target_file] != "1") {
                    valid = FALSE
                    break
                  }
                }
                if (valid) {
                  source_file <- target_file
                }
              } else {
                source_file <- target_file
              }
            }
            if (source_file == 0 && target_file - distance > 0) {
              if (position_2d[[source_rank]][target_file + distance * direction] == piece) {
                if (distance > 1) {
                  valid = TRUE
                  for (d in seq(distance - 1)) {
                    if (position_2d[[target_rank + d * direction]][target_file + d * direction] != "1") {
                      valid = FALSE
                      break
                    }
                  }
                  if (valid) {
                    source_file <- target_file - distance
                  }
                } else {
                  source_file <- target_file - distance
                }
              }
            }
            if (source_file == 0) { # rank < 9 (assumed)
              source_file <- target_file + distance
            }
          }
        }
        
        else if (piece %in% c("n", "N")) {
          # Handle knight moves
          if (abs(source_rank - target_rank) == 1) {
            if (target_file - 2 > 0 && 
                position_2d[[source_rank]][target_file - 2] == piece) {
              source_file <- target_file - 2
            } else {
              source_file <- target_file + 2
            }
          } else {
            if (target_file - 1 > 0 && 
                position_2d[[source_rank]][target_file - 1] == piece) {
              source_file <- target_file - 1
            } else {
              source_file <- target_file + 1
            }
          }
        }
        
        else if (piece %in% c("k", "K")) {
          # Handle king moves
          if (target_file - 1 > 0 && 
              position_2d[[source_rank]][target_file - 1] == piece) {
            source_file <- target_file - 1
          } else if (position_2d[[source_rank]][target_file] == piece) {
            source_file <- target_file
          } else {
            source_file <- target_file + 1
          }
        }
        
        
      } else {
        print("source not given")
        # determine source both rank and file
        source_file <- 0
        source_rank <- 0
        
        if (piece %in% c("p","P")) {
          # handle pawn moves
          pawn_direction <- if_else(piece == "P", -1, 1)
          source_rank <- target_rank - pawn_direction
          if (capture) {
            if (target_file == 1) {
              source_file <- 2
            } else if (position_2d[[source_rank]][target_file - 1] == piece) {
              source_file <- target_file - 1
            } else {
              source_file <- target_file + 1
            }
            # detect en passant capture
            if (position_2d[[target_rank]][target_file] == "1") {
              # remove lower pawn.
              position_2d[[target_rank - pawn_direction]][target_file] <- "1"
            }
          } else {
            source_file <- target_file
            if (position_2d[[source_rank]][target_file] != piece) {
              # double move
              source_rank <- target_rank - pawn_direction*2
              if ((target_file - 1 > 0 
                   && position_2d[[target_rank]][target_file - 1] == if_else(turn == "w", "p", "P"))
                  || (target_file + 1 < 9
                      && position_2d[[target_rank]][target_file + 1] == if_else(turn == "w", "p", "P"))) {
                # Add en passant flag
                en_passant_target <- 
                  paste0(c("a","b","c","d","e","f","g","h")[target_file], 
                         (8:1)[[target_rank + if_else(turn == "w", 1, -1)]])
              }
            }
          }
        }
        
        else if (piece %in% c("r", "R")) {
          # Handle rook moves
          # look left
          for (f in (target_file:1)[-1]) {
            if (position_2d[[target_rank]][f] != 1) {
              if (position_2d[[target_rank]][f] == piece) {
                source_rank <- target_rank
                source_file <- f
              }
              break
            }
          }
          if (source_file == 0) { # not found
            # look right
            for (f in (target_file:8)[-1]) {
              if (position_2d[[target_rank]][f] != 1) {
                if (position_2d[[target_rank]][f] == piece) {
                  source_rank <- target_rank
                  source_file <- f
                }
                break
              }
            }
          }
          if (source_file == 0) { # still not found
            # look up
            for (r in (target_rank:1)[-1]) {
              if (position_2d[[r]][target_file] == piece) {
                source_rank <- r
                source_file <- target_file
                break
              }
            }
          }
          if (source_file == 0) { # still not found
            # look down
            for (r in (target_rank:8)[-1]) {
              if (position_2d[[r]][target_file] == piece) {
                source_rank <- r
                source_file <- target_file
                break
              }
            }
          }
        }
        
        else if (piece %in% c("b", "B")) {
          # Handle bishop moves
          ul_space <- min(c(target_file - 1, target_rank - 1))
          dr_space <- min(c(8 - target_file, 8 - target_rank))
          dl_space <- min(c(target_file - 1, 8 - target_rank))
          ur_space <- min(c(8 - target_file, target_rank - 1))
          # look up-left
          print("looking up-left")
          if (ul_space > 0) {
            #print(paste("ul space is", ul_space))
            spaces <- cbind((target_file:(target_file-ul_space))[-1], 
                            (target_rank:(target_rank-ul_space))[-1])
            #print(spaces)
            #print(position_2d)
            for (s in seq(ul_space)) {
              #print(paste("spaces[s,2] =", spaces[s,2], "spaces[s,1] =", spaces[s,1]))
              if (position_2d[[(spaces[s,2])]][(spaces[s,1])] != "1") {
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] == piece) {
                  source_rank <- spaces[s,2]
                  source_file <- spaces[s,1]
                }
                break
              }
            }
          }
          if (source_file == 0) {
            # look down-right
            print("looking down-right")
            if (dr_space > 0) {
              spaces <- cbind((target_file:(target_file+dr_space))[-1], 
                              (target_rank:(target_rank+dr_space))[-1])
              for (s in seq(dr_space)) {
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] != "1") {
                  if (position_2d[[spaces[s,2]]][spaces[s,1]] == piece) {
                    source_rank <- spaces[s,2]
                    source_file <- spaces[s,1]
                  }
                  break
                }
              }
            }
          }
          if (source_file == 0) {
            # look down-left
            print("looking down-left")
            print(paste("dl_space is", dl_space))
            if (dl_space > 0) {
              print((target_file:(target_file-dl_space))[-1])
              print((target_rank:(target_rank+dl_space))[-1])
              spaces <- cbind((target_file:(target_file-dl_space))[-1], 
                              (target_rank:(target_rank+dl_space))[-1])
              print("spaces =")
              print(spaces)
              for (s in seq(dl_space)) {
                print(paste("s =", s))
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] == piece) {
                  if (position_2d[[spaces[s,2]]][spaces[s,1]] == piece) {
                    source_rank <- spaces[s,2]
                    source_file <- spaces[s,1]
                  }
                  break
                }
              }
            }
          }
          if (source_file == 0) {
            # look up-right
            print("looking up-right")
            if (ur_space > 0) {
              spaces <- cbind((target_file:(target_file+ur_space))[-1], 
                              (target_rank:(target_rank-ur_space))[-1])
              for (s in seq(ur_space)) {
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] == piece) {
                  if (position_2d[[spaces[s,2]]][spaces[s,1]] == piece) {
                    source_rank <- spaces[s,2]
                    source_file <- spaces[s,1]
                  }
                  break
                }
              }
            }
          }
        }
        
        else if (piece %in% c("q", "Q")) {
          # Handle queen moves
          
          # Check along diagonals
          ul_space <- min(c(target_file - 1, target_rank - 1))
          dr_space <- min(c(8 - target_file, 8 - target_rank))
          dl_space <- min(c(target_file - 1, 8 - target_rank))
          ur_space <- min(c(8 - target_file, target_rank - 1))
          # look up-left
          print("looking up-left")
          if (ul_space > 0) {
            spaces <- cbind((target_file:(target_file-ul_space))[-1], 
                            (target_rank:(target_rank-ul_space))[-1])
            for (s in seq(ul_space)) {
              if (position_2d[[(spaces[s,2])]][(spaces[s,1])] != "1") {
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] == piece) {
                  source_rank <- spaces[s,2]
                  source_file <- spaces[s,1]
                }
                break
              }
            }
          }
          if (source_file == 0) {
            # look down-right
            print("looking down-right")
            if (dr_space > 0) {
              spaces <- cbind((target_file:(target_file+dr_space))[-1], 
                              (target_rank:(target_rank+dr_space))[-1])
              for (s in seq(dr_space)) {
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] != "1") {
                  if (position_2d[[spaces[s,2]]][spaces[s,1]] == piece) {
                    source_rank <- spaces[s,2]
                    source_file <- spaces[s,1]
                  }
                  break
                }
              }
            }
          }
          if (source_file == 0) {
            # look down-left
            print("looking down-left")
            if (dl_space > 0) {
              spaces <- cbind((target_file:(target_file-dl_space))[-1], 
                              (target_rank:(target_rank+dl_space))[-1])
              for (s in seq(dl_space)) {
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] == piece) {
                  if (position_2d[[spaces[s,2]]][spaces[s,1]] == piece) {
                    source_rank <- spaces[s,2]
                    source_file <- spaces[s,1]
                  }
                  break
                }
              }
            }
          }
          if (source_file == 0) {
            # look up-right
            print("looking up-right")
            if (ur_space > 0) {
              spaces <- cbind((target_file:(target_file+ur_space))[-1], 
                              (target_rank:(target_rank-ur_space))[-1])
              for (s in seq(ur_space)) {
                if (position_2d[[(spaces[s,2])]][(spaces[s,1])] == piece) {
                  if (position_2d[[spaces[s,2]]][spaces[s,1]] == piece) {
                    source_rank <- spaces[s,2]
                    source_file <- spaces[s,1]
                  }
                  break
                }
              }
            }
          }
          # Check orthogonally
          if (source_file == 0) {
            # look left
            for (f in (target_file:1)[-1]) {
              if (position_2d[[target_rank]][f] != 1) {
                if (position_2d[[target_rank]][f] == piece) {
                  source_rank <- target_rank
                  source_file <- f
                }
                break
              }
            }
          }
          if (source_file == 0) {
            # look right
            for (f in (target_file:8)[-1]) {
              if (position_2d[[target_rank]][f] != 1) {
                if (position_2d[[target_rank]][f] == piece) {
                  source_rank <- target_rank
                  source_file <- f
                }
                break
              }
            }
          }
          if (source_file == 0) {
            # look up
            for (r in (target_rank:1)[-1]) {
              if (position_2d[[r]][target_file] == piece) {
                source_rank <- r
                source_file <- target_file
                break
              }
            }
          }
          if (source_file == 0) {
            # look down
            for (r in (target_rank:8)[-1]) {
              if (position_2d[[r]][target_file] == piece) {
                source_rank <- r
                source_file <- target_file
                break
              }
            }
          }
        }
        
        else if (piece %in% c("n", "N")) {
          # Handle knight moves
          f_deviations <- target_file + c(-2,-1,1,2)
          f_deviations <- f_deviations[f_deviations < 9 & f_deviations > 0]
          r_deviations <- target_rank + c(-2,-1,1,2)
          r_deviations <- r_deviations[r_deviations < 9 & r_deviations > 0]
          print("f_dev=")
          print(f_deviations)
          print("r_dev=")
          print(r_deviations)
          for (f in f_deviations) {
            for (r in r_deviations) {
              print(paste("r,f =", r, ",", f))
              if (abs(f - target_file) + abs(r - target_rank) != 3) {
                print("skip that")
                next
              }
              if (position_2d[[r]][f] == piece) {
                print("found piece")
                source_file <- f
                source_rank <- r
                break
              }
            }
            if (source_file != 0) {
              print("breaking")
              break
            }
          }
        }
        
        else if (piece %in% c("k", "K")) {
          # Handle king moves
          # I'm not worried about looking for checks because if there is more 
          # than one king of the same color I'll assume the king can be captured.
          f_deviations <- target_file + c(-1,0,1)
          f_deviations <- f_deviations[f_deviations < 9 & f_deviations > 0]
          r_deviations <- target_rank + c(-1,0,1)
          r_deviations <- r_deviations[r_deviations < 9 & r_deviations > 0]
          for (f in f_deviations) {
            for (r in r_deviations) {
              if (f == 0 && r == 0) {
                next
              }
              if (position_2d[[r]][f] == piece) {
                source_file <- f
                source_rank <- r
                break
              }
            }
            if (source_file != 0) {
              break
            }
          }
        }
        
        
      }
      
      if (! is_void(move_parts[8])) {
        # This is a promotion. Update piece now.
        piece <- substr(move_parts[8], 2, 2)
      }
      
      print(paste("source=", source_file, source_rank, "target=", target_file, target_rank))
      if (source_file == 0 || source_rank == 0) {
        print("Could not find matching piece. Make sure the move is correct.")
        return()
      }
      
      position_2d[[source_rank]][source_file] <- 1
      position_2d[[target_rank]][target_file] <- piece
    }
    
    p <- ""
    for (l in position_2d) {
      p <- paste0(p, paste(l, collapse = ""), "/")
    }
    position <- str_remove(p, ".$")
  }
  
  # CONCATENATE EMPTY SPACES
  # evaluates in provided order
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
  
  if (castle_rights == "") {
    castle_rights <- "-"
  }
  
  fen <- paste(position, turn, castle_rights, en_passant_target, halfmove_clock, 
               move_number) %>% 
    paste0(if_else(!is.na(white_checks), 
                   paste0(" +", white_checks, "+", black_checks), 
                   ""))
  return(fen)
}

