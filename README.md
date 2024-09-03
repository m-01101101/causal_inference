# Causal Impact Analysis for BP Oil Spill

This project analyzes the impact of the BP oil spill on BP's stock prices using causal impact analysis and Bayesian structural time series models.

## Setup

1. Clone this repository
2. Open the project in RStudio
3. Run `renv::restore()` to install the required packages
4. Download the BP and NASDAQ stock data CSV files and place them in the `data/causal_impact/` directory
5. Run the `causal_impact_analysis.R` script

## Project Structure

- `causal_impact_analysis.R`: Main analysis script
- `R/functions.R`: Helper functions for the analysis
- `data/causal_impact/`: Directory for storing input data files
- `renv/`: renv configuration and lock files

## Dependencies

This project uses `renv` for package management. The required packages are:

- tidyverse
- lubridate
- zoo
- CausalImpact
- bsts

To install the required packages, run `renv::restore()` in the R console.
