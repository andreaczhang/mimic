# since 10006 has very short los, now select 10011
library(ggplot2)

q5 <- "
SELECT subject_id, events.itemid, charttime, label, value, valuenum, valueuom
FROM chartevents AS events
INNER JOIN d_items AS itemscode
ON events.itemid = itemscode.itemid
WHERE subject_id = 10011
ORDER BY events.itemid, charttime;
"
q5.res <- dbGetQuery(con, q5); q5.res
head(q5.res)
dim(q5.res)

temp <- q5.res[which(q5.res$itemid == 677), ]
hr <- q5.res[which(q5.res$itemid == 211), ]
respr <- q5.res[which(q5.res$itemid == 618), ]

tab.new <- (rbind(temp, hr, respr))[, c(3, 4, 6)]
ggplot(tab.new, aes(x = charttime, y = valuenum, 
                    group = label, colour = label)) + 
  geom_line()  # geom_line()








