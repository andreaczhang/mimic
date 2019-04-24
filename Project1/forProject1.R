# we want to examine length of stay
# after connected to mimicbig 

que <- 'SELECT los FROM icustays ORDER BY subject_id'  

lengthofstay <- dbGetQuery(conbig, 
                           que)

head(lengthofstay)
hist(lengthofstay$los)
nrow(lengthofstay)   # 61532

summary(lengthofstay)  
# what if I choose below 5

losbelow5 <- lengthofstay[which(lengthofstay <= 5), ]
length(losbelow5)    # 47657
hist(losbelow5)

# maybe below 10 is also reasonable

losbelow10 <- lengthofstay[which(lengthofstay <= 10), ]
length(losbelow10)    # 54751

54751/61532   # 89% of all 

hist(losbelow10)

# how about 20? 
hist(lengthofstay[which(lengthofstay <= 20), ])
length(lengthofstay[which(lengthofstay <= 20), ])/61532    # over 95.5%


# ----- observe the tail 
# above 10
losabove10 <- lengthofstay[which(lengthofstay > 10), ]
hist(losabove10)      # 

# alternatively, between 2 and 20

losbetween2to20 <- lengthofstay[which(lengthofstay <= 20 & lengthofstay >=2), ]
hist(losbetween2to20)
length(losbetween2to20)/61532    # 48.1 


