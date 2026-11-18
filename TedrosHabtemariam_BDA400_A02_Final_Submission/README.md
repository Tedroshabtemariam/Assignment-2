# BDA400 Assignment 2 — Technical Analysis using R: Preliminary Stage
**Student:** Tedros Habtemariam  
**Course:** BDA400 — Data Science Tools and Techniques

## Purpose
Fetch daily stock prices from Yahoo Finance for each ticker in `portfolio.txt`, display the resulting stock data frames, calculate descriptive statistics and a 20-day simple moving average, and export tables and charts.

## Folder layout
- `portfolio.txt` — one ticker per line (AAPL, MSFT, GOOGL are sample choices).
- `scripts/stock_analysis.R` — reusable importing, statistics, and visualization functions.
- `run_assignment.R` — run the complete workflow.
- `outputs/` — generated CSVs and PNG charts after a successful local run.
- `evidence/` — add genuine screenshots taken during the practical steps.
- `TedrosHabtemariam_BDA400_A02_Report.docx` — Word report and screenshot placeholders.

## How to run
1. Install R and RStudio and open RStudio.
2. Create/open the `TechnicalAnalysis` GitHub repository and keep this folder inside an `Assignment_2` subdirectory.
3. Set the RStudio working directory to this `Assignment_2` folder.
4. Install required packages once: `install.packages(c('quantmod','TTR'))`.
5. Run: `source('run_assignment.R')`.
6. Check the Console, `outputs/stock_statistics.csv`, individual `*_prices.csv` files, and `*_close_sma.png` charts.
7. Capture screenshots of installation/setup, packages, code execution, outputs and GitHub. Insert them into the Word report.
8. Upload the completed assignment folder and report to GitHub; add the verified repository URL to the report and LMS cover page.

## Calculation notes
Mean, median, and sample standard deviation (`sd`) use valid daily closing prices. The mode uses closing prices rounded to 2 decimals; if every rounded price is unique, the mode is reported as NA (no unique mode). SMA uses a trailing 20-observation window; early values are NA until enough observations exist. Results depend on the date range and latest available Yahoo Finance prices.

