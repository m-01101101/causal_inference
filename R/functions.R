# Helper functions for the causal impact analysis

load_and_prepare_data <- function(bp_file, nasdaq_file) {
  bp <- read_csv(bp_file)
  nasdaq <- read_csv(nasdaq_file)
  
  stocks <- nasdaq %>% 
    select(Date, Open) %>% 
    rename(NASDAQ = Open) %>% 
    merge(bp %>% select(Date, Open), by = 'Date') %>% 
    rename(BP = Open,
           date = Date)
  
  return(stocks)
}

plot_stock_prices <- function(stocks, oilSpillDate) {
  stocks %>% 
    gather(stock, price, NASDAQ, BP) %>% 
    ggplot(aes(date, price, colour = stock)) +
    geom_vline(xintercept = oilSpillDate, linetype = 'dashed') +
    geom_line() +
    guides(colour = guide_legend(title = NULL)) +
    labs(
      title = 'NASDAQ and BP daily open prices',
      subtitle = 'Oil spill date indicated in dashed line',
      x = '',
      y = 'Price in USD'
    )
}

# Add more functions as needed