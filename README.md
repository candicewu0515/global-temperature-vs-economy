# The Change of Global Temperature Affected by Global Economy

Reproducible analysis code for the paper:

> Yuqing Fan, Wu Xia, Linxi Zhang. **The Change of Global Temperature Affected by
> Global Economy.** *Highlights in Science, Engineering and Technology*, Vol. 48
> (2023), pp. 17–36 (ESETEP 2023).
> DOI: [10.54097/hset.v48i.8228](https://doi.org/10.54097/hset.v48i.8228) ·
> [Article page](https://drpress.org/ojs/index.php/HSET/article/view/8228)

The article is published open access under CC BY-NC 4.0. The code in this
repository is released separately under the MIT License.

The study examines the statistical relationship between the global economy
(GDP, GDP per capita) and the climate (global temperature anomaly, CO₂
emissions), using descriptive figures and linear / multiple regression.

This repository rebuilds the full analysis **from public data**. The original
project used datasets from NASA, the Hadley Centre, the Global Carbon Project,
the World Bank and Worldometer; here those sources are pulled programmatically
so the pipeline runs end to end with a single command.

## Data sources (all public, downloaded automatically)

| Dataset | Variable | Source |
|---|---|---|
| NASA GISTEMP v4 (`GLB.Ts+dSST`) | Global temperature anomaly | data.giss.nasa.gov |
| Our World in Data CO₂ (Global Carbon Project) | CO₂ emissions, by source & region, per capita | github.com/owid/co2-data |
| World Bank `NY.GDP.PCAP.CD` | GDP per capita (world & per country) | api.worldbank.org |

Temperature is re-baselined to the **1961–1990** mean to match the baseline used
in the paper. "Global GDP per capita" is the World Bank world series
(current US$), whose 1980–2019 range (≈2.6k → 11k) matches the paper's Fig. 8 axis.

## How to run

```bash
Rscript run_all.R
```

This downloads the data (cached under `data/`), writes figures to `figures/`,
and a regression summary to `results/regression_summary.txt`. The individual
steps can also be run in order:

```
R/01_download_data.R   # fetch public datasets -> data/raw/
R/02_prepare_data.R    # clean & merge          -> data/processed/
R/03_figures.R         # figures                -> figures/
R/04_regressions.R     # regression models      -> results/
```

**Requirements:** R (≥ 4.0) with `ggplot2`, `dplyr`, `tidyr`, `readr`,
`jsonlite`. Figure 6 (the GDP-per-capita choropleth) additionally needs the
`maps` package; it is skipped with a message if `maps` is not installed.

## What maps to the paper

| Output | Paper |
|---|---|
| `figures/fig1_temperature_anomaly.png` | Fig. 1 — global temperature anomaly |
| `figures/fig3_co2_by_source.png` | Fig. 3 — CO₂ by energy source (1990–2018) |
| `figures/fig4_top10_co2_percapita.png` | Fig. 4 — top-10 CO₂ per capita (2016) |
| `figures/fig5_co2_by_region.png` | Fig. 5 — annual CO₂ by world region |
| `figures/fig6_gdp_percapita_map.png` | Fig. 6 — GDP per capita choropleth (2016) |
| `figures/fig7_top10_gdp_percapita.png` | Fig. 7 — top-10 GDP per capita (2016) |
| `figures/fig8_temp_vs_gdp.png` | Fig. 8 — temperature vs GDP per capita |
| `figures/fig11_co2_vs_gdp.png` | Fig. 11 — CO₂ vs GDP per capita (1990–2018) |
| `figures/fig12_loglog_crosscountry.png` | Fig. 12 — cross-country log-log (2015) |
| `results/regression_summary.txt` | Figs. 8–12 — regression tables |

## Reproduction of the key results

The regression models reproduce the paper's conclusions closely. Small numeric
differences are expected because the public datasets have been revised since
2023 (World Bank GDP revisions, GISTEMP vs. HadCRUT4 baseline, CO₂ data
vintage).

| Model | This repo | Paper |
|---|---|---|
| Temp ~ GDP per capita (1980–2019, n=40) | β=7.2e-05, R²=0.79 | β=6.6e-05, R²=0.76 |
| Temp ~ CO₂ | β=3.1e-05, R²=0.87 | β=3.5e-05, R²=0.88 |
| Temp ~ GDP + CO₂ | R²=0.91 | R²=0.90 |
| CO₂ per capita ~ GDP per capita (1990–2018) | R²=0.91 | R²=0.92 |
| Cross-country log-log (2015) | R²=0.76 | R²=0.86 |

**Finding (unchanged):** richer economies emit more CO₂; global temperature is
positively and significantly associated with both GDP per capita and CO₂
emissions. GDP and CO₂ are strongly collinear, so they are not jointly
significant in the multiple model even though each is highly significant alone.

**AIC variable selection (paper's discussion).** Because neither term is
individually significant in the joint `Temp ~ GDP + CO₂` model, `04_regressions.R`
runs backward elimination by AIC (`step()`). Dropping either predictor *raises*
the AIC, so AIC keeps **both** variables — reproducing the paper's conclusion
that the relationship is retained on the strength of the AIC test rather than the
(collinearity-deflated) p-values. Only AIC is used; the paper does not use BIC.

## Citation

> Fan, Y., Xia, W., & Zhang, L. (2023). The Change of Global Temperature
> Affected by Global Economy. *Highlights in Science, Engineering and
> Technology*, 48, 17–36. https://doi.org/10.54097/hset.v48i.8228

```bibtex
@article{fan2023temperature,
  title   = {The Change of Global Temperature Affected by Global Economy},
  author  = {Fan, Yuqing and Xia, Wu and Zhang, Linxi},
  journal = {Highlights in Science, Engineering and Technology},
  volume  = {48},
  pages   = {17--36},
  year    = {2023},
  doi     = {10.54097/hset.v48i.8228},
  url     = {https://drpress.org/ojs/index.php/HSET/article/view/8228}
}
```

## Notes

- `data/` and the publisher PDF are git-ignored. Run `run_all.R` to regenerate
  everything from source.
- The paper's analyses were originally done in R; this is a clean,
  fully-scripted reconstruction of that workflow.
