# relative castling rules

# Instead of the normal fixed destination castling, the rook always moves to 
# beside the king and the king hops over the rook. 
# (I made this before realizing that it was an incorrect replication of 
# Chess 960 rules and archived it.)
# As with the other solution, this assumes that castling is valid.

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
    home_rank[kfile+1] <- "R"
    home_rank[kfile+2] <- "K"
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
    home_rank[kfile+1] <- "r"
    home_rank[kfile+2] <- "k"
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
    home_rank[kfile-1] <- "R"
    home_rank[kfile-2] <- "K"
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
    home_rank[kfile-1] <- "r"
    home_rank[kfile-2] <- "k"
    position <- str_replace(position, "^[^/]*", home_rank)
  }
}