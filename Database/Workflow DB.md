# Workflow DB

(after creating DB but not yet with data )



## Demo with trial data 

In terminal, 

```bash
andrea$ psql postgres
```

In postico, 

```sql
CREATE TABLE fav_sports3 (

   name char(20),
   age integer,
   sport char(20),
   gender char(20)
);
```

### Issue with importing csv privilege

In postico, I need to be a superuser to `COPY` data from csv. The database demo is owned by user chizhang, which is not a superuser. 

#### Solution 1: Use command line

```bash
postgres=# \connect demo
demo=# \copy fav_sports3 FROM '/Users/andrea/Documents/PhdProjects/Project-Paper2/Database/trialdata.csv' DELIMITER ',' CSV HEADER;
```

Note the difference `\copy`. But my code are all written using `COPY` as SQL. This method doesn't work for a lot of files. At least I don't know a fast way. 

#### Solution 2: change user privilege

```bash
postgres=# ALTER USER chizhang WITH SUPERUSER;
\du
```

Now user chizhang has the superuser privilege so can copy csv files using the ready SQL scripts.

```sql
COPY fav_sports3 FROM '/Users/andrea/Documents/PhdProjects/Project-Paper2/Database/trialdata.csv' DELIMITER ',' CSV HEADER;
```

After finished, change back.

```bash
postgres=# ALTER USER chizhang WITH NOSUPERUSER;
```



#### Solution 3: import via postico

But need to create table first. 



then in Postico, do the usual SQL stuff. 

```sql
SELECT * FROM fav_sports;
```



## MIMIC data (demo)

1. Set to superuser

2. load query via postico
3. execute statements
4. revoke superuser



### Check consistency



## MIMIC data (large)

Download from https://physionet.org/works/MIMICIIIClinicalDatabase/files/

```bash
wget --user YOURUSERNAME --ask-password -A csv.gz -m -p -E -k -K -np -nd https://physionet.org/works/MIMICIIIClinicalDatabase/files/
```

The compressed files are at `/andrea/`but need to be put to `/andrea/Documents/Data/MIMICdata`. 









