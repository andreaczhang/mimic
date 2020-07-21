'''BASE EXCLUSION CRITERIA'''

# ------------------ first load data saved (demo first) ---------------- #
import pandas as pd
import numpy as np

datapath = '/Users/andrea/Documents/Data/mimicJcode/'
co = pd.read_csv(datapath + 'demo_cohort.csv')

# column names
list(co)
co.inclusion_not_crf.astype(bool)

# convert the inclusion flags to boolean
for c in co.columns:
    if c[0:10] == 'inclusion_':    # the first 10 characters
        co[c] = co[c].astype(bool)

# load the other tables
df = pd.read_csv(datapath + 'demo_df_data.csv')
df_static = pd.read_csv(datapath + 'demo_df_static_data.csv')
df_censor = pd.read_csv(datapath + 'demo_df_censor.csv')
df_death = pd.read_csv(datapath + 'demo_df_death.csv')

print (df.shape)    # it is 56 now, not 54 (probably because need to drop subject id)



# ---------------- reproduce the extraction --------------- #


# print out the exclusions *SEQUENTIALLY* - i.e. if already excluded, don't re-print
print('Cohort - initial size: {} ICU stays'.format(co.shape[0]))
co.shape[0]
idxRem = np.zeros(co.shape[0],dtype=bool)

for c in co.columns:
    if c[0:len('exclusion_')]=='exclusion_':  # the first characters being exclusion
        N_REM = np.sum( (co[c].values==1) )
        print('  {:5g} ({:2.2f}%) - {}'.format(N_REM,N_REM*100.0/co.shape[0], c))
        idxRem[co[c].values==1] = True

# summarize all exclusions
N_REM = np.sum( idxRem )
print('  {:5g} ({:2.2f}%) - {}'.format(N_REM,N_REM*100.0/co.shape[0], 'all exclusions'))
print('')
print('Final cohort size: {} ICU stays ({:2.2f}%).'.format(co.shape[0] - np.sum(idxRem), (1-np.mean(idxRem))*100.0))
co = co.loc[~idxRem,:]

# 6 are removed

# 1. mortality stats for base cohort
# out of 130 patients, how many are died according to different criteria
for c in co.columns:
    if c[0:len('death_')]=='death_':
        N_ALL = co.shape[0]
        N = co.set_index('icustay_id').loc[:,c].sum()
        print('{:40s}{:5g} of {:5g} died ({:2.2f}%).'.format(c, N, N_ALL, N*100.0/N_ALL))



# 2. mortaliyt in MIMIC2 paients staying >= 24h
# useful to understand the function of inclFcn

co.loc[co['inclusion_only_mimicii']]   ##### make sure this one is bool!
co.inclusion_only_mimicii

inclFcn = lambda x: x.loc[x['inclusion_only_mimicii']&x['inclusion_stay_ge_24hr'],'icustay_id']

# mortality stats for base cohort
for c in co.columns:
    if c[0:len('death_')]=='death_':
        N_ALL = inclFcn(co).shape[0]
        N = co.set_index('icustay_id').loc[inclFcn(co),c].sum()
        print('{:40s}{:5g} of {:5g} died ({:2.2f}%).'.format(c, N, N_ALL, N*100.0/N_ALL))




# ----------------- exclusion criteria ------------------ #

# first we can define the different windows: there aren't that many!
df_tmp=co.copy().set_index('icustay_id')

# admission+12 hours
time_12hr = df_tmp.copy()
time_12hr['windowtime'] = 12
time_12hr = time_12hr['windowtime'].to_dict()

# admission+24 hours
time_24hr = df_tmp.copy()
time_24hr['windowtime'] = 24
time_24hr = time_24hr['windowtime'].to_dict()

# admission+48 hours
time_48hr = df_tmp.copy()
time_48hr['windowtime'] = 48
time_48hr = time_48hr['windowtime'].to_dict()

# admission+72 hours
time_72hr = df_tmp.copy()
time_72hr['windowtime'] = 72
time_72hr = time_72hr['windowtime'].to_dict()

# admission+96 hours
time_96hr = df_tmp.copy()
time_96hr['windowtime'] = 96
time_96hr = time_96hr['windowtime'].to_dict()

# entire stay
time_all = df_tmp.copy()
time_all = time_all['dischtime_hours'].apply(np.ceil).astype(int).to_dict()

# 12 hours before the patient died/discharged
time_predeath = df_tmp.copy()
time_predeath['windowtime'] = time_predeath['dischtime_hours']
idx = time_predeath['deathtime_hours']<time_predeath['dischtime_hours']
time_predeath.loc[idx,'windowtime'] = time_predeath.loc[idx,'deathtime_hours']
# move from discharge/death time to 12 hours beforehand
time_predeath['windowtime'] = time_predeath['windowtime']-12
time_predeath = time_predeath['windowtime'].apply(np.ceil).astype(int).to_dict()







