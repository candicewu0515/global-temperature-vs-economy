# 01_download_data.R
# Download the public datasets used in the paper.
# All sources are open. Files are cached under data/raw/ so the rest of the
# pipeline runs offline once this has been executed.

dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)

sources <- list(
  # CO2 emissions (Global Carbon Project) + GDP (Maddison) + population,
  # bundled and maintained by Our World in Data.
  owid = list(
    url  = "https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv",
    dest = "data/raw/owid-co2-data.csv"
  ),
  # Global land-ocean surface temperature, NASA GISTEMP v4.
  gistemp = list(
    url  = "https://data.giss.nasa.gov/gistemp/tabledata_v4/GLB.Ts+dSST.csv",
    dest = "data/raw/GLB.Ts+dSST.csv"
  ),
  # World annual GDP per capita (current US$), World Bank indicator
  # NY.GDP.PCAP.CD -- the annual "global GDP per capita" series of the paper.
  wb_gdp_world = list(
    url  = paste0("https://api.worldbank.org/v2/country/WLD/indicator/",
                  "NY.GDP.PCAP.CD?format=json&per_page=400"),
    dest = "data/raw/wb_gdp_percapita_world.json"
  ),
  # Per-country GDP per capita, all years (current US$) -- used for the
  # cross-sectional figures (top-10 ranking, choropleth map, cross-country
  # log-log regression).
  wb_gdp_countries = list(
    url  = paste0("https://api.worldbank.org/v2/country/all/indicator/",
                  "NY.GDP.PCAP.CD?format=json&per_page=20000"),
    dest = "data/raw/wb_gdp_percapita_countries.json"
  )
)

for (s in sources) {
  if (file.exists(s$dest)) {
    message("already present: ", s$dest)
    next
  }
  message("downloading: ", s$url)
  ok <- tryCatch({
    download.file(s$url, s$dest, quiet = TRUE)
    TRUE
  }, error = function(e) FALSE)
  if (!ok || !file.exists(s$dest))
    stop("download failed for ", s$url,
         " -- check your network connection and retry.")
}

message("data download complete.")
