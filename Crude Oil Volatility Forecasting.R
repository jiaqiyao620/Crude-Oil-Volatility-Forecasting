##import pakages
rm(list=ls())
install.packages('Quandl')
install.packages('rugarch')
install.packages('tseries')
install.packages("httpuv")
library(Quandl)
library(rugarch)
library(stringr)
library(tseries)
library(xts) 

get_ret <- function(commodity_name)
{
  tic_name = NULL
  start_date = NULL
  end_date = NULL
  if (tolower(commodity_name) == 'wti'){
    tic_name = 'CHRIS/CME_CL1'
    start_date="2008-01-02"
    end_date="2017-07-20"
  } else if (tolower(commodity_name) == 'brent'){
    tic_name = "CHRIS/ICE_B1"
    start_date = "2007-11-02"
    end_date = "2017-11-08"
  } else if (tolower(commodity_name) == 'gas'){
    tic_name = "CHRIS/CME_NG1"
    start_date="2007-11-02"
    end_date="2017-11-08"
  } else 
    print('Error')
  daily <- Quandl(tic_name, api_key='TPywx-DUcfEE4VMynwHR', type='raw', collapse='daily', order = 'asc', start_date=start_date,end_date=end_date)
  date <- daily[,1]
  date <- as.Date(date)
  date <- tail(date, -1)
  ret <- diff(log(daily$Settle))
  rets <- xts(ret, order.by = date)
  return(rets)
}


get_hvt <- function(commodity_name)
{
  hvt <- read.csv(paste(tolower(commodity_name), 'hvt.csv', sep='_'), header = TRUE)
  hvt <- hvt[,2]
  return(hvt)
}

long_col <- function(vec, n){
  longer_vec <- vector()
  for( i in c(1:length(vec))){
    longer_vec[(i * n - (n - 1)) : (i * n)] <- vec[i]
  }
  return(longer_vec)
}

descript_data <- function(commodity_name)
{
  data <- get_ret(commodity_name = commodity_name)
  return <- as.numeric(unlist(data[1]))
  mean_return=mean(return)
  st_dev = sd(return)
  qqnorm(return)
  qqline(return)
  adf.test(return, alternative='stationary')
  acf(return)
  pacf(return)
  print(paste(paste('Mean return of', commodity_name, sep=' '), paste(':', mean_return, sep=' '), sep=' '))
  print(paste(paste('Standard deviation of', commodity_name, sep=' '), paste(':', st_dev, sep=' '), sep=' '))
}


foreca <- function(commodity_name, model_name)
{
  model_name <- paste(tolower(str_sub(model_name, 1, -6)), toupper(str_sub(model_name, -5, -1)), sep='')
  return <- get_ret(commodity_name = commodity_name)
  hvt <- get_hvt(commodity_name)
  
  T = length(return)
  optimal_window = NULL
  optimal_refit = NULL
  min_mse = Inf
  opt_forc = NULL
  forecast_length = c(100, 200, 300, 500, 1000)
  refit_length = c(5, 10, 20, 50)
  
  #dealing with the dataframe
  long_forecast <- long_col(forecast_length, length(refit_length))
  long_refit <- rep(refit_length, length(forecast_length))
  df <- data.frame(long_forecast, long_refit)
  mse <- c()
  aic <- c()
  sic <- c()
  
  model = ugarchspec(variance.model = list(model=model_name), mean.model = list(armaOrder=c(1,1)), distribution.model = 'norm')
  fit2 = ugarchfit(data=return, spec=model)
  plot(fit2, which='all')
  
  for(i in c(1:length(forecast_length))){
    for (j in c(1:length(refit_length))){
      print(paste(paste('Now fitting: forecast length =', forecast_length[i]), paste('refit_length =', refit_length[j]), sep = ', '))
      rollforc = ugarchroll(spec=model, data=return, n.ahead = 1, forecast.length = forecast_length[i], refit.every = refit_length[j], refit.window = c('recursive'), solver = 'hybrid', keep.coef = TRUE)
      sigmapred = as.data.frame(rollforc@forecast$density$Sigma)
      error = mean((hvt[(T-forecast_length[i]):(T-1)]- sigmapred)^2)
      
      mse[(i - 1) * length(refit_length) + j] <- error
      aic[(i - 1) * length(refit_length) + j] <- infocriteria(fit2)[1]
      sic[(i - 1) * length(refit_length) + j] <- infocriteria(fit2)[3]
      
      if (error <= min_mse){
        min_mse = error
        optimal_window = forecast_length[i]
        optimal_refit = refit_length[j]
        opt_forc = rollforc}
    } }
  
  df <- cbind(df, mse, aic, sic)
  colnames(df) <- c('forecast length', 'refit length', 'MSE', 'AIC', 'SIC')
  
  report_roll(opt_forc)
  write.csv(df, paste(paste(commodity_name, model_name, sep = '_'), '.csv', sep = ''))
  print(df)
  
  return(list(df, opt_forc))
}

report_roll <- function(roll)
{
  plot(roll, which='all')
  return(report(roll, type='VaR', VaR.alpha = 0.01, conf.level=0.95))
  
}



