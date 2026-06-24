# 03_figures.R
# Reproduce the figures of the paper from the processed tables.
# Output is written to figures/.

suppressMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(ggplot2)
})

dir.create("figures", showWarnings = FALSE, recursive = TRUE)

temperature <- read_csv("data/processed/temperature_global.csv", show_col_types = FALSE)
owid        <- read_csv("data/processed/owid_clean.csv",        show_col_types = FALSE)
world       <- read_csv("data/processed/world_series.csv",      show_col_types = FALSE)
gdp_ctry    <- read_csv("data/processed/gdp_percapita_countries.csv", show_col_types = FALSE)
cross_2015  <- read_csv("data/processed/cross_country_2015.csv", show_col_types = FALSE)
gdp_2016    <- gdp_ctry %>% filter(year == 2016)

theme_set(theme_minimal(base_size = 12))

# ---- Figure 1: global temperature anomaly (red above / blue below baseline) --
fig1 <- ggplot(temperature, aes(year, anomaly, fill = anomaly > 0)) +
  geom_col(width = 0.9, show.legend = FALSE) +
  scale_fill_manual(values = c("FALSE" = "#3B7DD8", "TRUE" = "#C0392B")) +
  labs(x = "Year", y = "Global Temperature (°C)",
       title = "Average global temperature anomaly relative to 1961-1990") +
  geom_hline(yintercept = 0, colour = "grey30", linewidth = 0.3)
ggsave("figures/fig1_temperature_anomaly.png", fig1, width = 8, height = 4.5, dpi = 150)

# ---- Figure 3: global CO2 emissions by source, stacked area (1990-2018) ------
sources <- owid %>%
  filter(country == "World", year >= 1990, year <= 2018) %>%
  transmute(year,
            Coal = coal_co2, Oil = oil_co2, `Natural gas` = gas_co2,
            Other = cement_co2 + flaring_co2) %>%
  pivot_longer(-year, names_to = "Group", values_to = "co2")
sources$Group <- factor(sources$Group, levels = c("Other", "Oil", "Natural gas", "Coal"))
fig3 <- ggplot(sources, aes(year, co2, fill = Group)) +
  geom_area() +
  scale_fill_brewer(palette = "Blues", direction = -1) +
  labs(x = "Year", y = "CO2 emission (million t)",
       title = "Energy used for releasing CO2 (1990-2018)")
ggsave("figures/fig3_co2_by_source.png", fig3, width = 8, height = 4.5, dpi = 150)

# ---- Figure 4: top 10 entities by CO2 per capita (2016) ----------------------
top_pc <- owid %>%
  filter(year == 2016, !is.na(co2_per_capita), population > 1e6) %>%
  arrange(desc(co2_per_capita)) %>%
  slice_head(n = 10)
fig4 <- ggplot(top_pc, aes(reorder(country, co2_per_capita), co2_per_capita)) +
  geom_col(fill = "#C9A66B") +
  coord_flip() +
  labs(x = NULL, y = "CO2 emissions (metric tons per capita)",
       title = "Top 10 by CO2 per capita (2016)")
ggsave("figures/fig4_top10_co2_percapita.png", fig4, width = 8, height = 4.5, dpi = 150)

# ---- Figure 5: annual CO2 emissions by world region, stacked area ------------
regions <- c("United States", "Canada", "South America", "Europe",
             "Africa", "Russia", "India", "China", "Oceania")
reg <- owid %>%
  filter(country %in% regions, year >= 1880, !is.na(co2))
fig5 <- ggplot(reg, aes(year, co2, fill = country)) +
  geom_area() +
  labs(x = "Year", y = "Annual CO2 Emission (million t)", fill = NULL,
       title = "Annual total CO2 emissions by world region")
ggsave("figures/fig5_co2_by_region.png", fig5, width = 8, height = 4.5, dpi = 150)

# ---- Figure 6: GDP per capita choropleth (2016) -- optional, needs `maps` ----
if (requireNamespace("maps", quietly = TRUE)) {
  world_map <- ggplot2::map_data("world")
  # light-touch name harmonisation between World Bank and the maps package
  recode <- c("United States" = "USA", "United Kingdom" = "UK",
              "Russian Federation" = "Russia", "Korea, Rep." = "South Korea",
              "Egypt, Arab Rep." = "Egypt", "Iran, Islamic Rep." = "Iran",
              "Congo, Dem. Rep." = "Democratic Republic of the Congo")
  gdp16 <- gdp_2016
  gdp16$region <- ifelse(gdp16$country %in% names(recode),
                         recode[gdp16$country], gdp16$country)
  mp <- left_join(world_map, gdp16, by = "region")
  fig6 <- ggplot(mp, aes(long, lat, group = group, fill = gdp_per_capita)) +
    geom_polygon(colour = "grey80", linewidth = 0.05) +
    scale_fill_continuous(low = "#E5E0F7", high = "#1A1A8C", na.value = "grey85",
                          name = "GDP per capita\n(US dollars)") +
    labs(title = "GDP per capita, 2016") +
    theme_void()
  ggsave("figures/fig6_gdp_percapita_map.png", fig6, width = 9, height = 5, dpi = 150)
} else {
  message("skipping Figure 6 (choropleth): install the 'maps' package to enable it.")
}

# ---- Figure 7: top 10 entities by GDP per capita (2016) ----------------------
top_gdp <- gdp_2016 %>%
  filter(!is.na(gdp_per_capita)) %>%
  arrange(desc(gdp_per_capita)) %>%
  slice_head(n = 10)
fig7 <- ggplot(top_gdp, aes(reorder(country, gdp_per_capita), gdp_per_capita)) +
  geom_col(fill = "#E8836B") +
  coord_flip() +
  labs(x = NULL, y = "GDP per capita (U.S. dollar)",
       title = "Top 10 by GDP per capita (2016)")
ggsave("figures/fig7_top10_gdp_percapita.png", fig7, width = 8, height = 4.5, dpi = 150)

# ---- Figure 8: temperature vs global GDP per capita, with regression ---------
d8 <- world %>% filter(year >= 1980, year <= 2019)
fig8 <- ggplot(d8, aes(gdp_per_capita, anomaly)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x, colour = "#2C5D9B") +
  labs(x = "Global GDP per capita (US dollars)",
       y = "Departure from average temperature (°C)",
       title = "Global GDP per capita vs temperature (1980-2019)")
ggsave("figures/fig8_temp_vs_gdp.png", fig8, width = 7, height = 5, dpi = 150)

# ---- Figure 11: global CO2 per capita vs GDP per capita (time series, 1990-2018)
d11 <- world %>% filter(year >= 1990, year <= 2018,
                        !is.na(co2_per_capita), !is.na(gdp_per_capita))
fig11 <- ggplot(d11, aes(gdp_per_capita, co2_per_capita)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x, colour = "#2C5D9B") +
  labs(x = "Global GDP per capita (U.S. dollars)",
       y = "Global CO2 emissions (metric tons per capita)",
       title = "Global GDP per capita vs CO2 emissions (1990-2018)")
ggsave("figures/fig11_co2_vs_gdp.png", fig11, width = 7, height = 5, dpi = 150)

# ---- Figure 12: cross-country log-log of CO2 per capita vs GDP per capita (2015)
fig12 <- ggplot(cross_2015, aes(log(gdp_per_capita), log(co2_per_capita))) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", formula = y ~ x, colour = "#2C5D9B") +
  labs(x = "log(GDP per capita, US dollars)",
       y = "log(CO2 emission per capita, t)",
       title = "Cross-country log-log relationship (2015)")
ggsave("figures/fig12_loglog_crosscountry.png", fig12, width = 7, height = 5, dpi = 150)

message("figures written to figures/")
