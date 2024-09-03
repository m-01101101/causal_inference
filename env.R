getwd()

install.packages("renv")
renv::init()
# renv::init(force = TRUE)

install.packages(c("tidyverse", "haven", "broom", "estimatr", "ggplot2", "lfe", "AER", "sandwich", "lmtest", "stargazer",))

library(tidyverse)  # For data manipulation and visualization
library(haven)      # For reading various data formats
library(broom)      # For tidying model outputs
library(estimatr)   # For robust statistical estimators
library(ggplot2)    # For creating graphs
library(lfe)        # For fixed effects regression
library(AER)        # For instrumental variables regression
library(sandwich)   # For robust standard errors
library(lmtest)     # For hypothesis tests
library(stargazer)  # For creating regression tables


# setwd("/path/to/mixtape/directory")

renv::snapshot()

