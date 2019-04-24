# examine the subject_id range for partitioning 
library(tidyverse)

IDrange <- 'SELECT MIN(subject_id), MAX(subject_id) FROM admissions'
IDunique <- 'SELECT DISTINCT subject_id FROM admissions'

IDs <- dbGetQuery(con, statement = IDunique)  

summary(IDs)

head(IDs)
hist(IDs$subject_id, breaks = 30)

# produce 50 intervals 
qs <- quantile(IDs$subject_id, probs = seq(0, 1, 0.02), names = T) %>% floor()



