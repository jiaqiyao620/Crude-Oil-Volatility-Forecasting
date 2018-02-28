# Crude-Oil-Volatility-Forecasting

We utilize several different volatility models, such as GARCH, EGARCH and GJR-GARCH models, to analyze the volatility characteristics of active WTI crude oil futures, Brent oil futures and Natural Gas futures markets. 
We used past ten-year data from the three markets to fit these models separately. 
As a result, the best statistically fitting model for both WTI market Brent markets and for natural gas market are EGARCH and GARCH (1,1), respectively.Then, we calibrate the forecast length and refit length in rolling forecast method to find the best prediction power model in both markets. Finally, we use VaR to backtest the best models we have.
