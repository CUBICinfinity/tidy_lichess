library(tidyverse)

pgn <- read_lines("lichess_cubicinfinity_2022-09-21.pgn")

fen <- read_lines("FEN_2022-09-21.txt")


games <- tibble
colnames(games) <- 
  c("Event",
    "Site",
    "Date",
    "White",
    "Black",
    "Result",
    "UTCDate",
    "UTCTime",
    "WhiteElo",
    "BlackElo",
    "WhiteRatingDiff",
    "BlackRatingDiff",
    "Variant",
    "TimeControl",
    "ECO",
    "Termination")
open_game <- FALSE
values <- c()
for (line in pgn) {
  if (str_detect(line, "^\\[")) {
    open_game <- TRUE
    values <- append(values, str_extract(line, '(?<=")[^"]+'))
  }
  else if (open_game == TRUE) {
    games %>% 
      add_row(as_tibble(values))
    open_game <- FALSE
    values <- c()
  }
}
