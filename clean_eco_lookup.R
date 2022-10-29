# arrange eco list from https://www.chessgames.com/chessecohelp.html

eco <- read_csv("data/eco_messy.csv", col_names = c("eco", "description"))

moves <- eco %>% 
  filter(is.na(eco)) %>% 
  "$"(description)

eco %>% 
  filter(! is.na(eco)) %>% 
  mutate(moves = moves) %>% 
  write_csv("data/eco_lookup.csv")
