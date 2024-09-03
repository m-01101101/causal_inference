# Causal Impact Analysis for BP Oil Spill
# Based on: http://www.batisengul.co.uk/post/causal-impact-and-bayesian-structural-time-series/

# Install and load required packages
install.packages(c("tidyverse", "lubridate", "zoo", "CausalImpact", "bsts", "kaggler"))
library(tidyverse)
library(lubridate)
library(zoo)
library(CausalImpact)
library(bsts)
library(kaggler)

# Set up Kaggle credentials
Sys.setenv(KAGGLE_USERNAME = Sys.getenv("KAGGLE_USERNAME"))
Sys.setenv(KAGGLE_KEY = Sys.getenv("KAGGLE_KEY"))

# Verify credentials are set
if (Sys.getenv("KAGGLE_USERNAME") == "" || Sys.getenv("KAGGLE_KEY") == "") {
  stop("Kaggle credentials not found. Please set KAGGLE_USERNAME and KAGGLE_KEY in .Renviron file.")
}

# Download NASDAQ dataset from Kaggle
kgl_auth() # Make sure you have your Kaggle API credentials set up
kgl_datasets_download_all("svaningelgem/nasdaq-daily-stock-prices")
unzip("nasdaq-daily-stock-prices.zip", exdir = "data/causal_impact")

# Load and prepare NASDAQ (QQQ) data
nasdaq <- read_csv('data/causal_impact/nasdaq_daily_stock_prices.csv') %>%
  filter(Symbol == "QQQ") %>%
  select(Date, Open) %>%
  rename(NASDAQ = Open)

# Load BP data (you'll need to provide this separately)
bp <- read_csv('data/causal_impact/bp_stocks.csv')

# Merge and prepare data
stocks <- nasdaq %>% 
  merge(bp %>% select(Date, Open), by = 'Date') %>% 
  rename(BP = Open,
         date = Date)

oilSpillDate <- ymd('2010-04-20')

# Plot NASDAQ and BP stock prices
plot_stock_prices(stocks, oilSpillDate)

# Simple linear regression approach
fittedLM <- lm(BP ~ NASDAQ, data = stocks %>% filter(date < oilSpillDate))
predictLM <- predict(fittedLM, newdata = stocks %>% filter(date == oilSpillDate), interval = 'confidence')

stocks %>% 
  mutate(`BP predicted` = ifelse(date < oilSpillDate, NA,  predictLM[1]),
         low = ifelse(date < oilSpillDate, NA,  predictLM[2]),
         high = ifelse(date < oilSpillDate, NA,  predictLM[3])) %>% 
  gather(stock, price, BP, NASDAQ, `BP predicted`) %>% 
  ggplot(aes(date, price, colour = stock)) +
  geom_vline(xintercept = oilSpillDate, linetype = 'dashed') +
  geom_ribbon(aes(ymin = low, ymax = high), alpha = .2, colour = 'gray') +
  geom_line() +
  guides(colour = guide_legend(title = NULL)) +
  labs(
    title = 'NASDAQ and BP daily open prices',
    subtitle = 'Oil spill date indicated in dashed line',
    x = '',
    y = 'Price in USD'
  )

# Causal Impact Analysis
stocks.zoo <- stocks[,c(1,3,2)] %>% 
  read.zoo()
times <- seq(start(stocks.zoo), end(stocks.zoo), by = 'day')
stocks.zoo <- merge(stocks.zoo, zoo(,times), all = TRUE) %>% na.locf()

impact <- CausalImpact(data = stocks.zoo, 
                       pre.period = c(first(stocks$date), oilSpillDate-1),
                       post.period = c(oilSpillDate, last(stocks$date)))

summary(impact)
plot(impact)

# Custom BSTS model
stocks.bsts <- stocks.zoo
postPeriod <- which(time(stocks.zoo) == oilSpillDate) : nrow(stocks.zoo)
stocks.bsts[postPeriod, 1] <- NA 

ss <- AddLocalLevel(list(), stocks.zoo[,1]) %>% 
  AddSeasonal(stocks.zoo[,1], nseasons= 7)

bsts <- bsts(BP ~ NASDAQ, state.specification = ss, 
             data = stocks.bsts, niter = 1000)

# You can add further analysis or visualization of the BSTS model results here