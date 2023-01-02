# Logistic Function
logistic <- function(x) {
  return(1 / (1 + exp(-x)))
}

# Returns a material score for the position according to the piece values.
# score > 0 : for white, score < 0 : for black
#
# `fen` : 
#     Required FEN position
# `values` :
#     Preset name or a named list of piece and feature values.
#
material_score <- function(fen, values = "traditional") {
  # PRESETS
  # See https://lichess.org/@/ubdip/blog/finding-the-value-of-pieces/PByOBlNB
  # and https://lichess.org/@/ubdip/blog/comments-on-piece-values/Ps9kghhO
  # for the source and explanation of ubdip_*
  values <- case_when(
    # extra `list` wrapper used to keep values of same size for `case_when`
    values == "traditional" ~ list(list(
      pawn = 1, knight = 3, bishop = 3, rook = 5, queen = 9
      )),
    # Warning: There seems to be a sample bias towards endgames.
    values == "ubdip_chess" ~ list(list(
      move = 0.01, pawn = 1, knight = 3.16, bishop = 3.28, rook = 4.93, queen = 9.82
      )),
    # Warning: I think this treats droppable pieces and pieces already on the board equally.
    values == "ubdip_crazyhouse" ~ list(list(
      move = 0.07, pawn = 1, knight = 1.69, bishop = 1.73, rook = 3.05, queen = 3.94
      )),
    values == "ubdip_atomic" ~ list(list(
      move = 0.05, pawn = 1, knight = 1.53, bishop = 1.92, rook = 2.72, q = 5.57
      )),
    values == "ubdip_badfish" ~ list(list(
      pawn = 1, knight = 1.83, bishop = 2.18, rook = 3.56, queen = 5.09
      )),
    # These avoid the above mentioned sample bias
    values == "ubdip_midgame" ~ list(list(
      pawn = 1, knight = 2.89, bishop = 2.97, rook = 4.01, queen = 9.76
      )),
    values == "ubdip_endgame" ~ list(list(
      pawn = 1, knight = 2.9, bishop = 2.99, rook = 4.65, queen = 9.29
      )),
    values == "ubdip_commoner_midgame" ~ list(list(
      queen = 9.77, rook = 4.57, commoner = 3.12, bishop = 3.2, knight = 3.08, pawn = 1
      )),
    values == "ubdip_commoner_endgame" ~ list(list(
      queen = 9.13, rook = 4.61, commoner = 3.19, bishop = 2.94, knight = 2.80, pawn = 1
      )),
    # These are probably the most useful presets.
    values == "ubdip_bpair_midgame" ~ list(list(
      queen = 9.97, rook = 4.02, bishop = 2.92, knight = 2.87, pawn = 1, bishop_pair = 0.46
      )),
    values == "ubdip_bpair_endgame" ~ list(list(
      queen = 9.29, rook = 4.65, bishop = 2.92, knight = 2.89, pawn = 1, bishop_pair = 0.63
      )),
    # A standardized variation of the last two (sum() == 21)
    # Warning: Will slightly dillute conversion to win probability (evaluation)
    # Unstandardized score can be recovered by multiplying by 
    # 1.002857 and 1.018095, respectively
    values == "comparable_midgame" ~ list(list(
      queen = 9.7621083, rook = 4.0085470, bishop = 2.9116809, 
      knight = 2.8618234, pawn = 0.9971510, bishop_pair = 0.4586895
      )),
    values == "comparable_endgame" ~ list(list(
      queen = 9.1248831, rook = 4.5673527, bishop = 2.8681010, 
      knight = 2.8386342, pawn = 0.9822264, bishop_pair = 0.6188026
      )),
    TRUE ~ list(values)
    )[[1]]
  
  pawn <- if_else(is.null(values$pawn), 0, values$pawn)
  knight <- if_else(is.null(values$knight), 0, values$knight)
  bishop <- if_else(is.null(values$bishop), 0, values$bishop)
  rook <- if_else(is.null(values$rook), 0, values$rook)
  queen <- if_else(is.null(values$queen), 0, values$queen)
  commoner <- if_else(is.null(values$commoner), 0, values$commoner)
  bishop_pair <- if_else(is.null(values$bishop_pair), 0, values$bishop_pair)
  move <- if_else(is.null(values$move), 0, values$move)
  
  score <- 0
  white_bcount <- 0
  black_bcount <- 0
  for (char in unlist(str_split(str_extract(fen, "[^ ]*"), ""))) {
    score <- score + case_when(
      char == "P" ~ pawn,
      char == "p" ~ -pawn,
      char == "N" ~ knight,
      char == "n" ~ -knight,
      char == "B" ~ bishop,
      char == "b" ~ -bishop,
      char == "R" ~ rook,
      char == "r" ~ -rook,
      char == "Q" ~ queen,
      char == "q" ~ -queen,
      # alternative: char %in% c("K", "C") ~ commoner,
      # char %in% c("k", "c") ~ -commoner,
      char == "C" ~ commoner,
      char == "c" ~ -commoner,
      TRUE ~ 0
    )
    if (char == "B") {
      white_bcount <- white_bcount + 1
    } else if (char == "b") {
      black_bcount <- black_bcount + 1
    }
  }
  # This is over-simplified since opposite color bishops are better than duplicates.
  if (white_bcount > 1) {
    score <- score + bishop_pair
  }
  if (black_bcount > 1) {
    score <- score - bishop_pair
  }
  if (str_extract(fen, "(?<= ).") == "w") {
    score <- score + move
  } else {
    score <- score - move
  }
  
  return(score)
}
