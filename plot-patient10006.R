library(scales)
require(ggplot2)
# after querying from the 'patient10006.r'

# try to visualise body temperature from chartevents, itemid 677
head(q5.res)

temp <- q5.res[which(q5.res$itemid == 677), ]
# plot(temp$charttime, temp$valuenum, type = 'l', 
#      xlim = c('2164-10-23 22:00:00', '2164-10-25 10:00:00'))

# temp$charttime <- as.Date( temp$charttime, '%m/%d/%Y')

ggplot( data = temp, aes( charttime, valuenum )) + 
  geom_line()
lims <- as.POSIXct(strptime(c("2164-10-23 16:00", "2164-10-25 16:00"), 
                            format = "%Y-%m-%d %H:%m"))
ggplot( data = temp, aes( charttime, valuenum )) + 
  geom_line() +
  scale_x_datetime(labels = date_format("%H:%m"), 
                   breaks = date_breaks("2 hours"), 
                   limits = lims) +
  theme_linedraw()



# I hate dealing with DateTime format. 

# ================ how about adding one more series? 


hr <- q5.res[which(q5.res$itemid == 211), ]

respr <- q5.res[which(q5.res$itemid == 618), ]
### this should be easy to do with purrr.



# try to do it in the same table, with 3 columns. 
tab.new <- (rbind(temp, hr, respr))[, c(3, 4, 6)]
ggplot(tab.new, aes(x = charttime, y = valuenum, 
                    group = label, colour = label)) + 
  geom_point()  # geom_line()

# ok this is do-able. 







