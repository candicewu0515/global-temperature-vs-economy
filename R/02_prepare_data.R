# 02_prepare_data.R
# Clean and merge the raw downloads into the tidy tables used downstream.

suppressMessages({
  library(dplyr)
  library(readr)
  library(jsonlite)
})

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

# ---- NASA GISTEMP global annual anomaly --------------------------------------
# The file ships with a one-line header; "***" marks missing months.
# "J-D" is the January-December annual mean (baseline 1951-1980).
# We re-baseline to 1961-1990 to match the baseline used in the paper.
gistemp <- read.csv("data/raw/GLB.Ts+dSST.csv", skip = 1, na.strings = c("***"))
gistemp$temp <- as.numeric(as.character(gistemp$J.D))
base_61_90  <- mean(gistemp$temp[gistemp$Year >= 1961 & gistemp$Year <= 1990],
                    na.rm = TRUE)
temperature <- gistemp %>%
  transmute(year = Year,
            anomaly = temp - base_61_90) %>%
  filter(!is.na(anomaly))

# ---- Our World in Data CO2 / GDP / population --------------------------------
owid <- read_csv("data/raw/owid-co2-data.csv", show_col_types = FALSE)

keep <- c("country", "year", "iso_code", "population", "gdp",
          "co2", "co2_per_capita",
          "coal_co2", "oil_co2", "gas_co2", "cement_co2", "flaring_co2")
owid <- owid[, keep]

# ---- World Bank GDP per capita (current US$) --------------------------------
# Annual world GDP per capita -- the "global GDP per capita" series of the paper.
wb_world <- fromJSON("data/raw/wb_gdp_percapita_world.json")[[2]] %>%
  transmute(year = as.integer(date), gdp_per_capita = value) %>%
  filter(!is.na(gdp_per_capita))

# Per-country GDP per capita, all years. Drops World Bank aggregate rows, which
# carry region/income-group codes rather than a real ISO-3 country code.
wb_c <- fromJSON("data/raw/wb_gdp_percapita_countries.json")[[2]]
gdp_countries <- data.frame(
  country        = wb_c$country$value,
  iso3           = wb_c$countryiso3code,
  year           = as.integer(wb_c$date),
  gdp_per_capita = wb_c$value,
  stringsAsFactors = FALSE
) %>%
  filter(!is.na(gdp_per_capita), iso3 != "")

# Global series: temperature + World CO2 (OWID) + World GDP per capita (WB).
# Total GDP is reconstructed as (GDP per capita x population) for the
# multiple-regression model (Fig 10), which uses total GDP and total CO2.
world <- owid %>%
  filter(country == "World") %>%
  select(year, co2, co2_per_capita, population) %>%
  inner_join(temperature, by = "year") %>%
  left_join(wb_world, by = "year") %>%
  mutate(gdp = gdp_per_capita * population)

# Cross-country table for 2015: GDP per capita (WB) + CO2 per capita (OWID),
# used for the cross-country log-log regression (Fig 12).
co2pc_2015 <- owid %>%
  filter(year == 2015, !is.na(iso_code), iso_code != "") %>%
  select(iso3 = iso_code, co2_per_capita)
cross_2015 <- gdp_countries %>%
  filter(year == 2015) %>%
  inner_join(co2pc_2015, by = "iso3") %>%
  filter(co2_per_capita > 0, gdp_per_capita > 0)

write_csv(temperature,   "data/processed/temperature_global.csv")
write_csv(owid,          "data/processed/owid_clean.csv")
write_csv(world,         "data/processed/world_series.csv")
write_csv(gdp_countries, "data/processed/gdp_percapita_countries.csv")
write_csv(cross_2015,    "data/processed/cross_country_2015.csv")

message("prepared: temperature_global.csv, owid_clean.csv, world_series.csv, ",
        "gdp_percapita_countries.csv, cross_country_2015.csv")
