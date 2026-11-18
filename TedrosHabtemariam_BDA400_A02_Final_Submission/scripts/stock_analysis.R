# BDA400 Assignment 2 — Preliminary Stage
# Student: Tedros Habtemariam
# Run from the assignment folder (repository/Assignment_2).
# Requires quantmod and TTR; install with install.packages(c('quantmod','TTR')).

read_portfolio <- function(path = 'portfolio.txt') {
  if (!file.exists(path)) stop('Portfolio file not found: ', path)
  symbols <- unique(toupper(trimws(readLines(path, warn = FALSE))))
  symbols <- symbols[nzchar(symbols) & !grepl('^#', symbols)]
  if (!length(symbols)) stop('No stock symbols in portfolio file')
  if (any(!grepl('^[A-Z0-9.^-]+$', symbols))) stop('Invalid ticker symbol')
  symbols
}

load_stock_data <- function(portfolio_path = 'portfolio.txt',
                            from = as.Date('2025-01-01'),
                            to = Sys.Date()) {
  if (!requireNamespace('quantmod', quietly = TRUE)) stop('Install quantmod first')
  symbols <- read_portfolio(portfolio_path)
  stocks <- list()
  for (symbol in symbols) {
    message('Fetching ', symbol, ' from Yahoo Finance ...')
    raw <- tryCatch(quantmod::getSymbols(symbol, src = 'yahoo', from = from,
                                         to = to + 1, auto.assign = FALSE),
                    error = function(e) {warning(symbol, ': ', conditionMessage(e)); NULL})
    if (is.null(raw) || NROW(raw) == 0L) next
    df <- data.frame(Date = as.Date(zoo::index(raw)), Symbol = symbol,
                     Open = as.numeric(quantmod::Op(raw)),
                     High = as.numeric(quantmod::Hi(raw)),
                     Low = as.numeric(quantmod::Lo(raw)),
                     Close = as.numeric(quantmod::Cl(raw)),
                     Volume = as.numeric(quantmod::Vo(raw)))
    df <- df[order(df$Date), , drop = FALSE]
    rownames(df) <- NULL
    stocks[[symbol]] <- df
  }
  if (!length(stocks)) stop('No stock data loaded. Check internet, symbols and dates.')
  stocks
}

numeric_mode <- function(x, digits = 2L) {
  x <- round(x[is.finite(x)], digits = digits)
  if (!length(x)) return(NA_real_)
  counts <- table(x)
  if (max(counts) == 1L) return(NA_real_) # no repeated value; no unique mode
  as.numeric(names(counts)[which.max(counts)])
}

calculate_statistics <- function(stock_df, window = 20L) {
  if (!requireNamespace('TTR', quietly = TRUE)) stop('Install TTR first')
  if (!is.data.frame(stock_df) || !all(c('Date','Symbol','Close') %in% names(stock_df)))
    stop('Expected a stock data frame with Date, Symbol and Close')
  if (length(window) != 1L || is.na(window) || window < 1 || window != as.integer(window))
    stop('window must be a positive integer')
  close <- as.numeric(stock_df$Close)
  valid <- close[is.finite(close)]
  if (!length(valid)) stop('No valid closing prices')
  # Moving average is calculated for each row; first window-1 values are NA.
  moving_average <- as.numeric(TTR::SMA(close, n = as.integer(window)))
  data.frame(Symbol = stock_df$Symbol[1], Observations = length(valid),
             Mean = mean(valid), Mode_2dp = numeric_mode(valid),
             Median = median(valid), Standard_Deviation = if(length(valid)>1) sd(valid) else NA_real_,
             Latest_Close = tail(valid,1), Latest_Moving_Average = tail(moving_average,1),
             Moving_Average_Window = as.integer(window))
}

show_stock_data <- function(stocks, n = 6L) {
  for (symbol in names(stocks)) {
    cat('\n===== ', symbol, ' =====\n', sep='')
    print(utils::head(stocks[[symbol]], n))
    cat('Rows:', nrow(stocks[[symbol]]), '\n')
  }
  invisible(stocks)
}

plot_stock <- function(stock_df, window = 20L, output_dir = 'outputs') {
  if (!requireNamespace('TTR', quietly = TRUE)) stop('Install TTR first')
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  symbol <- stock_df$Symbol[1]
  avg <- as.numeric(TTR::SMA(stock_df$Close, n = as.integer(window)))
  filename <- file.path(output_dir, paste0(symbol, '_close_sma.png'))
  png(filename, width = 1200, height = 650, res = 120)
  tryCatch({
    plot(stock_df$Date, stock_df$Close, type = 'l', col = '#17365D', lwd = 2,
         xlab = 'Date', ylab = 'Price (USD)', main = paste(symbol, 'Closing Price and', window, 'Day SMA'))
    lines(stock_df$Date, avg, col = '#D97706', lwd = 2)
    legend('topleft', legend = c('Closing price', paste(window, 'day SMA')),
           col = c('#17365D','#D97706'), lty = 1, lwd = 2, bty = 'n')
    grid()
  }, finally = dev.off())
  filename
}

run_analysis <- function(from = as.Date('2025-01-01'), to = Sys.Date(), window = 20L) {
  stocks <- load_stock_data(from = from, to = to)
  show_stock_data(stocks)
  dir.create('outputs', showWarnings = FALSE)
  summary <- do.call(rbind, lapply(stocks, calculate_statistics, window = window))
  rownames(summary) <- NULL
  print(summary)
  write.csv(summary, 'outputs/stock_statistics.csv', row.names = FALSE, na = '')
  for (symbol in names(stocks)) {
    write.csv(stocks[[symbol]], file.path('outputs', paste0(symbol, '_prices.csv')), row.names = FALSE)
    print(plot_stock(stocks[[symbol]], window = window))
  }
  message('Analysis complete: see outputs/ for CSV files and charts.')
  invisible(list(stocks = stocks, summary = summary))
}
