if (! require(tidyverse)) {
  stop("`library(tidyverse)` is required!")
}


# helper function
is_void <- function(x) {
  return (is.na(x) || x == "" || length(x) == 0)
}

# How to fix absolute pin bug:
#   when piece/pawn moves, and if variant prevents, look for king along same diagonal or file.
#   if so, follow line from king, skipping source, until a piece/pawn is detected. 
#   if unfriendly piece attacking, look for another valid source piece/pawn
detect_pin <- function(position_2d, rank, file, turn, variant = "") {
  if (variant %in% c("Antichess")) {
    return(FALSE)
  }
  king_found <- FALSE
  pin_found <- FALSE
  # look up for king
  if (rank > 1) {
    for (u in 1:(rank - 1)) {
      if (position_2d[[u]][file] != "1") {
        if (position_2d[[u]][file] == if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (rank < 8) {
            # look down for attack
            for (d in (rank + 1):8) {
              if (position_2d[[d]][file] != "1") {
                if (position_2d[[d]][file] %in% if_else(turn == "w",
                                                        c("q", "r"),
                                                        c("Q", "R"))) {
                  pin_found <- TRUE
                }
              break
              }
            }
          }
        }
      break
      }
    }
  }
  # look down for king
  if (! king_found && rank < 8) {
    for (d in (rank + 1):8) {
      if (position_2d[[d]][file] != "1") {
        if (position_2d[[d]][file] == if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (rank > 1) {
            # look up for attack
            for (u in 1:(rank - 1)) {
              if (position_2d[[u]][file] != "1") {
                if (position_2d[[u]][file] %in% if_else(turn == "w",
                                                        c("q", "r"),
                                                        c("Q", "R"))) {
                  pin_found <- TRUE
                }
                break
              }
            }
          }
        }
        break
      }
    }   
  }
  # look left for king
  if (! king_found && file > 1) {
    for (l in 1:(file - 1)) {
      if (position_2d[[rank]][l] != "1") {
        if (position_2d[[rank]][l] == if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (file < 8) {
            # look right for attack
            for (r in (file + 1):8) {
              if (position_2d[[rank]][r] != "1") {
                if (position_2d[[rank]][r] %in% if_else(turn == "w",
                                                        c("q", "r"),
                                                        c("Q", "R"))) {
                  pin_found <- TRUE
                }
                break
              }
            }
          }
        }
        break
      }
    }   
  }
  # look right for king
  if (! king_found && file < 8) {
    for (r in (file + 1):8) {
      if (position_2d[[rank]][r] != "1") {
        if (position_2d[[rank]][r] == if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (file > 1) {
            # look left for attack
            for (l in 1:(file - 1)) {
              if (position_2d[[rank]][l] != "1") {
                if (position_2d[[rank]][l] %in% if_else(turn == "w",
                                                        c("q", "r"),
                                                        c("Q", "R"))) {
                  pin_found <- TRUE
                }
                break
              }
            }
          }
        }
        break
      }
    }   
  }
  # prep vars for diagonals
  if (! king_found) {
    ul_space <- min(c(file - 1, rank - 1))
    dr_space <- min(c(8 - file, 8 - rank))
    dl_space <- min(c(file - 1, 8 - rank))
    ur_space <- min(c(8 - file, rank - 1))
    
    ul_squares <- cbind((file:(file - ul_space))[-1], 
                        (rank:(rank - ul_space))[-1])
    dr_squares <- cbind((file:(file + dr_space))[-1], 
                        (rank:(rank + dr_space))[-1])
    dl_squares <- cbind((file:(file - dl_space))[-1], 
                        (rank:(rank + dl_space))[-1])
    ur_squares <- cbind((file:(file + ur_space))[-1], 
                        (rank:(rank - ur_space))[-1])
  }
  # look up-left for king
  if (! king_found && ul_space > 0) {
    for (ul in seq(ul_space)) {
      if (position_2d[[(ul_squares[ul,2])]][(ul_squares[ul,1])] != "1") {
        if (position_2d[[(ul_squares[ul,2])]][(ul_squares[ul,1])]
            != if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (dr > 0) {
            for (dr in seq(dr_space)) {
              if (position_2d[[dr_squares[dr,2]]][dr_squares[dr,1]] != "1") {
                if (position_2d[[dr_squares[dr,2]]][dr_squares[dr,1]] 
                    %in% if_else(turn == "w", c("q", "b"), c("Q", "B"))) {
                  found_pin <- TRUE
                }
                break
              }
            }
          }
        }
        break
      }
    }
  }
  # look down-right for king
  if (! king_found && dr_space > 0) {
    for (dr in seq(dr_space)) {
      if (position_2d[[(dr_squares[dr,2])]][(dr_squares[dr,1])] != "1") {
        if (position_2d[[(dr_squares[dr,2])]][(dr_squares[dr,1])]
            != if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (ul > 0) {
            for (ul in seq(ul_space)) {
              if (position_2d[[ul_squares[ul,2]]][ul_squares[ul,1]] != "1") {
                if (position_2d[[ul_squares[ul,2]]][ul_squares[ul,1]] 
                    %in% if_else(turn == "w", c("q", "b"), c("Q", "B"))) {
                  found_pin <- TRUE
                }
                break
              }
            }
          }
        }
        break
      }
    }
  }
  # look down-left for king
  if (! king_found && dl_space > 0) {
    for (dl in seq(dl_space)) {
      if (position_2d[[(dl_squares[dl,2])]][(dl_squares[dl,1])] != "1") {
        if (position_2d[[(dl_squares[dl,2])]][(dl_squares[dl,1])]
            != if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (ur > 0) {
            for (ur in seq(ur_space)) {
              if (position_2d[[ur_squares[ur,2]]][ur_squares[ur,1]] != "1") {
                if (position_2d[[ur_squares[ur,2]]][ur_squares[ur,1]] 
                    %in% if_else(turn == "w", c("q", "b"), c("Q", "B"))) {
                  found_pin <- TRUE
                }
                break
              }
            }
          }
        }
        break
      }
    }
  }
  # look up-right for king
  if (! king_found && ur_space > 0) {
    for (ur in seq(ur_space)) {
      if (position_2d[[(ur_squares[ur,2])]][(ur_squares[ur,1])] != "1") {
        if (position_2d[[(ur_squares[ur,2])]][(ur_squares[ur,1])]
            != if_else(turn == "w", "K", "k")) {
          king_found <- TRUE
          if (dl > 0) {
            for (dl in seq(dl_space)) {
              if (position_2d[[dl_squares[dl,2]]][dl_squares[dl,1]] != "1") {
                if (position_2d[[dl_squares[dl,2]]][dl_squares[dl,1]] 
                    %in% if_else(turn == "w", c("q", "b"), c("Q", "B"))) {
                  found_pin <- TRUE
                }
                break
              }
            }
          }
        }
        break
      }
    }
  }
 
  if (pin_found) {
    return(TRUE)
  } 
  return(FALSE)
}


###
# TODO: Fix: THERE ARE STILL SOME BUGS IN THIS CODE
# TODO: Add more error handling.
#
# `fen_move(fen, move)` gets the next FEN position in chess, 
# given the current `fen` position and the algebraic `move`
#
# https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation
# https://en.wikipedia.org/wiki/Algebraic_notation_(chess)
#
# Usage example (performs an A-side castle): 
# fen_move("rn1q1rk1/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/R3K2R w KQ - 4 8", "O-O-O")
# 
# The purpose of this function is for reconstructing games from PGN notation. 
# It does not check the legality of a move: Instead, it attempts to find the 
# referenced piece and move it to the target location regardless of the 
# consequences.
###

fen_move <- function(fen, move, variant = "") {
  if (is_void(fen) || is_void(move)) {
    stop("Missing inputs!")
  }
  
  # Parse FEN
  parsed_fen <- str_match(fen, "([^ ]+) ([wb]) ([KQkq-]+) ([a-h-][1-8]?) (\\d+) (\\d+)( \\+(\\d+)\\+(\\d+))?")
  
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
    # [piece?, file?, rank?, capture?, ch_place?, target, promotion, check(mate)?]
    move_parts <- str_match(move, "([RNBQK]?)([a-h]?)([1-8]?)(x?)(@?)([a-h][1-8])(=[RNBQK])?([+#]?)?")
    
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
    
    capture <- move_parts[5] != ""
    target <- unlist(str_split(move_parts[7], ""))
    target_file <- as.numeric(charToRaw(target[1])) - 96
    if (length(target_file) == 0) {
      # this shouldn't happen. I guess this is temporary precaution
      target_file <- NA
    }
    # We're reversing the order to match the way I've constructed position_2d
    target_rank <- (8:1)[as.numeric(target[2])] 
    
    if (! is_void(move_parts[6])) {
      # Crazyhouse place: Just change at target
      position_2d[[target_rank]][target_file] <- piece
      
    } else {
      file <- as.numeric(charToRaw(move_parts[3])) - 96
      if (length(file) == 0) {
        file <- NA
      }
      # reversed order here as well
      rank <- (8:1)[as.numeric(move_parts[4])] 
      
      if (capture || piece %in% c("p", "P")) {
        halfmove_clock <- 0
      } else {
        halfmove_clock <- halfmove_clock + 1
      }
      
      
      # Find Source 
      # source = location piece moved from
      # target = location piece moved to
      
      # Simply pick first valid source because PGN disambiguates for us.
      
      if (! is.na(file) && ! is.na(rank)) {
        # source already given
        source_file <- file
        source_rank <- rank
        
      } else if (! is.na(file)) {
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
          
          if (target_file != source_file) {
            source_rank <- target_rank
          } else {
            # look up
            for (r in (target_rank:1)[-1]) {
              if (position_2d[[r]][target_file] != "1") {
                if (position_2d[[r]][target_file] == piece
                    && ! detect_pin(position_2d, r, target_file, turn, variant)) {
                  source_rank <- r
                  source_file <- target_file
                }
                break
              }
            }
            if (source_rank == 0) { # not found
              # look down
              for (r in (target_rank:8)[-1]) {
                if (position_2d[[r]][target_file] != "1") {
                  if (position_2d[[r]][target_file] == piece
                      && ! detect_pin(position_2d, r, target_file, turn, variant)) {
                    source_rank <- r
                    source_file <- target_file
                  }
                  break
                }
              }
            }
          }
        }
        
        else if (piece %in% c("b", "B")) {
          # Handle bishop moves
          distance <- abs(source_file - target_file)
          direction <- if_else(source_file < target_file, -1, 1)
          if (0 < target_rank + distance*direction && target_rank + distance*direction < 9) {
            valid <- TRUE
            if (distance > 1) {
              # Check for obstructions
              for (d in (0:(distance - 1))[-1] * direction) {
                if (position_2d[[target_rank + d]][target_file + d] != "1") {
                  valid <- FALSE
                  break
                }
              }
            }
            if (valid == TRUE &&
                position_2d[[target_rank + distance * direction]][source_file] == piece) {
              source_rank <- target_rank + distance * direction
            }
          } 
          if (source_rank == 0) {
            # assume other angle is correct
            source_rank <- target_rank - distance * direction
          }
        }
        
        else if (piece %in% c("q", "Q")) {
          # Handle queen moves
          
          if (target_file == source_file) {
            # check along file
            # look up
            for (r in (target_rank:1)[-1]) {
              if (position_2d[[r]][target_file] != "1") {
                if (position_2d[[r]][target_file] == piece) {
                  source_rank <- r
                }
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
                for (f in source_file + seq(distance - 1) * direction * -1) {
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
                    source_rank <- target_rank + distance * direction
                  }
                } else {
                  source_rank <- target_rank + distance * direction
                }
              }
            }
            if (source_rank == 0) { # rank < 9 (assumed)
              source_rank <- target_rank - distance * direction
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
          if (source_rank != target_rank) {
            source_file <- target_file
          } else {
            # look left
            for (f in (target_file:1)[-1]) {
              if (position_2d[[target_rank]][f] != "1") {
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
                if (position_2d[[target_rank]][f] != "1") {
                  if (position_2d[[target_rank]][f] == piece) {
                    source_rank <- target_rank
                    source_file <- f
                  }
                  break
                }
              }
            }
          }
        }
        
        else if (piece %in% c("b", "B")) {
          # Handle bishop moves
          distance <- abs(source_rank - target_rank)
          direction <- if_else(source_rank < target_rank, -1, 1)
          if (0 < target_file + distance*direction && target_file + distance*direction < 9) {
            valid <- TRUE
            if (distance > 1) {
              # Check for obstructions
              for (d in (0:(distance - 1))[-1] * direction) {
                if (position_2d[[target_rank + d]][target_file + d] != "1") {
                  valid <- FALSE
                }
              }
            }
            if (valid == TRUE &&
                position_2d[[source_rank]][target_file + distance * direction] == piece) {
              source_file <- target_file + distance * direction
            }
          } 
          if (source_file == 0) {
            # assume other angle is correct
            source_file <- target_file - distance * direction
          }
        }
        
        else if (piece %in% c("q", "Q")) {
          # Handle queen moves
          
          if (target_rank == source_rank) {
            # check along file
            # look up
            for (f in (target_file:1)[-1]) {
              if (position_2d[[target_rank]][f] != "1") {
                if (position_2d[[target_rank]][f] == piece) {
                  source_rank <- f
                }
                break
              }
            }
            if (source_rank == 0) {
              # look down
              for (f in (target_file:8)[-1]) {
                if (position_2d[[target_rank]][f] != "1") {
                  if (position_2d[[target_rank]][f] == piece) {
                    source_rank <- f
                  }
                  break
                }
              }
            }
          } else {
            # check three points, but also for obstructions
            distance <- abs(source_rank - target_rank)
            direction <- if_else(source_rank < target_rank, -1, 1)
            # vertical
            if (position_2d[[source_rank]][target_file] == piece) {
              if (distance > 1) {
                valid = TRUE
                for (r in source_rank + seq(distance - 1) * direction * -1) {
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
            # diagonal
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
                    source_file <- target_file + distance * direction
                  }
                } else {
                  source_file <- target_file + distance * direction
                }
              }
            }
            # other diagonal
            if (source_file == 0) { # rank < 9 (assumed)
              source_file <- target_file - distance * direction
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
            if (position_2d[[target_rank]][f] != "1") {
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
              if (position_2d[[target_rank]][f] != "1") {
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
              if (position_2d[[r]][target_file] != "1") {
                if (position_2d[[r]][target_file] == piece) {
                  source_rank <- r
                  source_file <- target_file
                }
                break
              }
            }
          }
          if (source_file == 0) { # still not found
            # look down
            for (r in (target_rank:8)[-1]) {
              if (position_2d[[r]][target_file] != "1") {
                if (position_2d[[r]][target_file] == piece) {
                  source_rank <- r
                  source_file <- target_file
                }
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
            if (dl_space > 0) {
              spaces <- cbind((target_file:(target_file-dl_space))[-1], 
                              (target_rank:(target_rank+dl_space))[-1])
              for (s in seq(dl_space)) {
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
            # look up-right
            if (ur_space > 0) {
              spaces <- cbind((target_file:(target_file+ur_space))[-1], 
                              (target_rank:(target_rank-ur_space))[-1])
              for (s in seq(ur_space)) {
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
        }
        
        else if (piece %in% c("q", "Q")) {
          # Handle queen moves
          
          # Check along diagonals
          ul_space <- min(c(target_file - 1, target_rank - 1))
          dr_space <- min(c(8 - target_file, 8 - target_rank))
          dl_space <- min(c(target_file - 1, 8 - target_rank))
          ur_space <- min(c(8 - target_file, target_rank - 1))
          # look up-left
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
            if (dl_space > 0) {
              spaces <- cbind((target_file:(target_file-dl_space))[-1], 
                              (target_rank:(target_rank+dl_space))[-1])
              for (s in seq(dl_space)) {
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
            # look up-right
            if (ur_space > 0) {
              spaces <- cbind((target_file:(target_file+ur_space))[-1], 
                              (target_rank:(target_rank-ur_space))[-1])
              for (s in seq(ur_space)) {
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
          # Check orthogonally
          if (source_file == 0) {
            # look left
            for (f in (target_file:1)[-1]) {
              if (position_2d[[target_rank]][f] != "1") {
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
              if (position_2d[[target_rank]][f] != "1") {
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
              if (position_2d[[r]][target_file] != "1") {
                if (position_2d[[r]][target_file] == piece) {
                  source_rank <- r
                  source_file <- target_file
                }
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
          for (f in f_deviations) {
            for (r in r_deviations) {
              if (abs(f - target_file) + abs(r - target_rank) != 3) {
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
      
      if (source_file == 0 || source_rank == 0) {
        stop("Could not find matching piece. Make sure the move is correct.")
      }
      
      position_2d[[source_rank]][source_file] <- "1"
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
      white_checks <- white_checks + 1
    } else {
      black_checks <- black_checks + 1
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

