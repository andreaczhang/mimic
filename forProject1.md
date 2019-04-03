> Disclaimer: I don't know whether I can use mimic data for project 1. But at least by understanding what info mimic data has, we can probably find a way to use it. 



### We need data to illustrate: 

- interpretability via **variable selection** in the first stage
- doesn't compromise the **prediction** via the second stage
- as a consequence, **intervention** made possbile



### <span style = 'color: palevioletred'>Thoughts </span>

- if we redefine the outcome: instead of using a prevalence-based prediction outcome, we use **length of stay** (or something else, but in any case: **individual based**) as outcome
  - this is feasible because there are sufficient number of patient with longer length of stay
  - however it is unspecial: it is not making use of time lags. 
- another thing might be the sparsity of the data. well, not sure what we can do about it. 
- However: if I align the end point of outcome, leave a window of (for example) 24 hours, one outcome is alive and one is dead. we make intervention for data before the cutpoint. If their outcome can change from dead to alive, then it works. 



### Examine: 

I want to know whether I can use patients with longer length of stay. 

- import large data (partial) to db, since this has to be done sooner or later. 

- find how much info we have on patient with long stay
- some basic statistics on this 



