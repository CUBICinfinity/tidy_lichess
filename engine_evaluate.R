if (! require(stockfish)) {
  stop("`library(stockfish)` is required!")
}
if (! require(tidyverse)) {
  stop("`library(tidyverse)` is required!")
}

# On my 6 core, 12 thread processor, depth 35 is about the point before it 
# starts to take a long time to think about the position. You may prefer to 
# decrease or increase it according to the capabilities of your setup. But 
# honestly, 35 moves is already quite advanced compared to humans for most 
# positions.
#
# Verbose is just for testing.
evaluate <- function(engine, fen, side = "w", depth = 35, verbose = FALSE) {
  engine$position(fen)
  
  if (verbose) {
    eval <- engine$run(paste("go depth", depth)) %>%
      .[length(.) - 1]
    message(fen)
    message(eval)
    score <- eval %>% str_extract("(?<=score ).+(?= nodes)")
    message(score)
  } else {
    score <- engine$run(paste("go depth", depth)) %>% 
      .[length(.) - 1] %>% 
      str_extract("(?<=score ).+(?= nodes)")
  }
  
  if ((side %in% c("b", "black") && str_detect(fen, " w ")) ||
      (side %in% c("w", "white") && str_detect(fen, " b ")) ) {
    score <- str_replace(score, "(\\d+)", "-\\1") %>% # negate
      str_replace("--", "") # remove double negative
  }
  return(score)
}


# By default, fish$run will stop gracefully after a certain amount of time,
# even if the operation was not complete. This can result in a stopping point 
# that does not contain a score at the expected location. This function will 
# simply request a new run. Evaluation progress is not lost.
#
# If this must be done more than 5 times, something has likely gone wrong with 
# the engine, so the engine will be recreated.
#
# Early stopping means the full depth may never be reached. 
# `force_depth = TRUE`, not yet implemented, will keep running until depth is achieved.
#
# Opportunity: Figure out how to properly control the stopping.
eval_redundant <- function(engine, 
                           engine_file, 
                           position, 
                           side = "w", 
                           depth = 35, 
                           cores = 2 # ,
                           # force_depth = FALSE
                           ) {
  score <- evaluate(engine, position, side = side, depth = depth)
  tries <- 1
  restarts <- 0
  while (length(score) == 0 || is.na(score)) {
    if (tries > 5) {
      if (restarts > 3) {
        score <- "Unresolved Engine Failure"
        break
      }
      # restart engine.
      engine <- fish$new(engine_file)
      if (! is.null(cores)) {
        engine$setoption(paste("threads", cores))
      }
      tries <- 0
      restarts <- restarts + 1
    }
    score <- evaluate(engine, position, side = side)
    tries <- tries + 1
  }
  return(score)
}
