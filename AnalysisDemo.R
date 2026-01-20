# This helps me find games I should study more closely.

source("wrangle_games.R")

library(lubridate)
library(ggpmisc)
library(cowplot)

gdat <- games %>% 
  filter(Variant == "Standard") %>% 
  mutate(Format = case_when(str_detect(Event, "Blitz") ~ "Blitz",
                             str_detect(Event, "Rapid") ~ "Rapid",
                             TRUE ~ "Other")) %>% 
  filter(Format != "Other") %>% 
  mutate(Side = if_else(White == "cubicinfinity", "Playing as white", "Playing as black"),
         Win = if_else(Result == "1/2-1/2", 0.5, as.numeric(if_else(White == "cubicinfinity", Result == "1-0", Result == "0-1"))),
         Rating = if_else(White == "cubicinfinity", WhiteElo, BlackElo),
         OpponentRating = if_else(White == "cubicinfinity", BlackElo, WhiteElo),
         Time = ymd_hms(paste(UTCDate, UTCTime))) %>% 
  select(Time, Format, Side, Rating, OpponentRating, ECO, Win, Termination)

eco_plot_data <- gdat %>% 
  group_by(Side, ECO) %>% 
  summarize(AvgResult = mean(Win)*2 - 1,
            count = n()) %>% 
  ungroup()

eco_plot <- eco_plot_data %>% 
  ggplot(aes(x = fct_reorder(ECO, count, .desc = TRUE), y = AvgResult, fill = log(count))) +
  geom_bar(stat = "identity") + 
  geom_text(aes(y = AvgResult + case_when(AvgResult > 0 ~ 0.05, 
                                          AvgResult < 0 ~ -0.05, 
                                          TRUE ~ 0), 
                label = ECO),
            size = 2.5) +
  facet_wrap(~fct_rev(Side), ncol = 1) +
  scale_y_continuous(labels = function(y){ y / 2 + 0.5 }) +
  scale_fill_viridis_c(direction = -1, 
                       option = "inferno",
                       labels = function(x){ round(exp(x), 1) },
                       breaks = seq(0, log(max(eco_plot_data$count)), length.out = 4) %>% 
                         exp() %>% 
                         round() %>% 
                         log()) +
  theme_gray() +
  theme(panel.grid.major.x = element_line(size = 0.1),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        legend.position = "bottom",
        legend.margin = margin(-5,0,0,0),
        legend.key.width = unit(30, "points"),
        plot.title = element_text(hjust = 0.5, margin = margin(0,0,12.5,0)),
        plot.title.position = "plot") +
  labs(y = "Average Result", 
       title = "Standard Rapid and Blitz Chess Games for 'cubicinfinity'",
       fill = "Number of games")

eco <- read_csv("data/eco_lookup.csv") %>% 
  filter(eco %in% (gdat %>% 
                     distinct(ECO) %>% 
                     unlist() %>% 
                     unname()))

colnames(eco) <- c("ECO", "Name", "Description")
 
eco_table_1 <- ggplot() +
  theme_void() +
  annotate(geom = "table",
           x = 0,
           y = 0,
           label = list(eco[1:16,]),
           size = 2.41)
eco_table_2 <- ggplot() +
  theme_void() +
  annotate(geom = "table",
           x = 0,
           y = 0,
           label = list(eco[17:32,]),
           size = 2.41)
eco_table_3 <- ggplot() +
  theme_void() +
  annotate(geom = "table",
           x = 0,
           y = 0,
           label = list(eco[33:48,]),
           size = 2.41)
eco_table_4 <- ggplot() +
  theme_void() +
  annotate(geom = "table",
           x = 0,
           y = 0,
           label = list(eco[49:64,]),
           size = 2.41)
eco_table_5 <- ggplot() +
  theme_void() +
  annotate(geom = "table",
           x = 0,
           y = 0,
           label = list(eco[65:78,]),
           size = 2.41)

eco_grid <- plot_grid(
  eco_table_1, eco_table_2, eco_table_3, eco_table_4, eco_table_5, 
  ncol = 5,
  rel_widths = c(1.02, 1.03, 0.95, 1.04, 1.20))

# Full-screen this one. # I've saved it as `ECO_plot.png`
plot_grid(eco_plot, eco_grid, ncol = 1, rel_heights = c(1, 0.48))


