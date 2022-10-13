position_2d <- position %>% 
  str_split("\\/") %>% 
  unlist() %>% 
  str_split("")


p <- ""
for (l in position_2d) {
  p <- paste0(p, paste(l, collapse = ""), "/")
}
p <- str_remove(p, ".$")
p
