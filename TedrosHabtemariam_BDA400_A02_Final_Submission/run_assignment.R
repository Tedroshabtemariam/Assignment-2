# Open the assignment folder in RStudio, then run this script.
# Install packages once if necessary:
# install.packages(c('quantmod', 'TTR'))
source('scripts/stock_analysis.R')
result <- run_analysis(from = as.Date('2025-01-01'), to = Sys.Date(), window = 20L)
