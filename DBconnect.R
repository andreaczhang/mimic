library(RPostgreSQL)
library(readr)    # read file 

# ============== connect to DB
pw <- {
  "andrea"
}

drv <- dbDriver("PostgreSQL")      # loads the PostgreSQL driver

# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, 
                 dbname = "mimicbig",    # not demo anymore! the real thing! 
                 host = "localhost", 
                 port = 5432,
                 user = "chizhang", 
                 password = pw)

# removes the password
rm(pw) 

# check whether table exists 
# dbExistsTable(con, "admissions")  

# ============== close the connection 
# dbDisconnect(con)
# dbUnloadDriver(drv)
