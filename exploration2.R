library(tidyverse)
library(reshape2)

# find a quick way to display the graphs 
dat49 <- readRDS('resultsPatientDF.RData')

length(dat49)

# how many hours in ICU? 
nHoursIn <- rep(0, 49)
for (i in 1:49){
  nHoursIn[i] <- nrow(dat49[[i]])
}



# ================ still use 10006 as example 
p10006 <- dat49[[1]]
head(p10006)

plottable <- p10006[, c(3, 5:ncol(p10006))]
head(plottable)
meltplottable <- melt(plottable, id = 'hours_in')
head(meltplottable)


# separate the time series into more reasonable scaling groups 
variableGroup1 <- c('heartrate', 'respiratoryrate', 'diastolicnbp', 
                    'systolicnbp', 'meannbp', 'temperature')
variableGroup2 <- setdiff(colnames(plottable)[-1], variableGroup1)  # -1 for time


variables1 <- plottable[, variableGroup1] %>% cbind(plottable[1], .)  # add back time 
variables2 <- plottable[, variableGroup2] %>% cbind(plottable[1], .)

melt1 <- melt(variables1, id = 'hours_in')

ggplot(melt1, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point() + 
  geom_line()


melt2 <- melt(variables2, id = 'hours_in')

ggplot(melt2, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point()+ 
  geom_line()
# p10006 has too few hours 
# try one with longer hours 


# ================ still use 10006 as example 
p10011 <- dat49[[3]]

plottable <- p10011[, c(3, 5:ncol(p10011))]
# head(plottable)
meltplottable <- melt(plottable, id = 'hours_in')
# head(meltplottable)


# separate the time series into more reasonable scaling groups 
variableGroup1 <- c('heartrate', 'respiratoryrate', 'diastolicnbp', 
                    'systolicnbp', 'meannbp', 'temperature')
variableGroup2 <- setdiff(colnames(plottable)[-1], variableGroup1)  # -1 for time


variables1 <- plottable[, variableGroup1] %>% cbind(plottable[1], .)  # add back time 
variables2 <- plottable[, variableGroup2] %>% cbind(plottable[1], .)

melt1 <- melt(variables1, id = 'hours_in')

ggplot(melt1, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point() + 
  geom_line()


melt2 <- melt(variables2, id = 'hours_in')

ggplot(melt2, aes(hours_in, value, 
                  colour = variable, group = variable)) + 
  geom_point()+ 
  geom_line()









