# Crude-Oil-Volatility-Forecasting

I utilized several different volatility models, such as GARCH, EGARCH and GJR-GARCH models, to analyze the volatility characteristics of active WTI crude oil futures, Brent oil futures and Natural Gas futures markets. 
I used past ten-year data from the three markets to fit these models separately. 
As a result, the best statistically fitting model for both WTI market Brent markets and for natural gas market are EGARCH and GARCH (1,1), respectively.Then, I calibrated the hyperparameters such as forecast length and refit length using rolling forecast method, hoping to find out the model with highest predicting power in both markets. Finally, I used VaR to backtest the best models and explore extra explanatory variables by probing furthur into the portion of market volatility that could not be explained by these models by .

To read more detailed report about this project, please visit this [Google Drive link](https://drive.google.com/openid=1zYf3yc7hDIGDjnfpB4788iJsoogBAQlA).
