install.packages('tidyverse')

# first attempt to connect to db
install.packages('RPostgreSQL')
library(RPostgreSQL)

# ================ 1. connection

# create a connection
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
  "andrea"
}


drv <- dbDriver("PostgreSQL")      # loads the PostgreSQL driver
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, 
                 dbname = "demo",
                 host = "localhost", 
                 port = 5432,
                 user = "chizhang", 
                 password = pw)
rm(pw) # removes the password

# check tables 
dbExistsTable(con, "admissions")  # this works
# TRUE


# ================ 2. load data 
que <- 'SELECT subject_id FROM admissions'  # this could also work

dfsports <- dbGetQuery(con, 
                       que)

class(dfsports) # it's a dataframe





# ================ 3. close connection
dbDisconnect(con)
dbUnloadDriver(drv)




