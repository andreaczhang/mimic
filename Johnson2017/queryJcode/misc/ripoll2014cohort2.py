# example params used to extract patient data
# element 1: dictionary specifying end time of window for each patient
# element 2: size of window
# element 3: extra hours added to make it easier to get data on labs (and allows us to get labs pre-ICU)
# e.g. [time_24hr, 8, 24] is
#   (1) window ends at admission+24hr
#   (2) window is 8 hours long
#   (3) lab window is 8+24=32 hours long
from collections import OrderedDict

def inclFcn(x, inclusions):
    return x.loc[x[inclusions].all(axis=1),'icustay_id']

'''
# this one is used more than once, so we define it here
hugExclFcnMIMIC3 = lambda x: x.loc[x['inclusion_over_18']&x['inclusion_hug2009_obs']&x['inclusion_hug2009_not_nsicu_csicu']&x['inclusion_first_admission']&x['inclusion_full_code']&x['inclusion_not_brain_death']&x['inclusion_not_crf'],'icustay_id'].values
hugExclFcn = lambda x: np.intersect1d(hugExclFcnMIMIC3(x),x.loc[x['inclusion_only_mimicii'],'icustay_id'].values)


# physionet2012 subset - not exact but close
def physChallExclFcn(x):
    out = x.loc[x['inclusion_only_mimicii']&x['inclusion_over_18']&x['inclusion_stay_ge_48hr']&x['inclusion_has_saps'],'icustay_id'].values
    out = np.sort(out)
    out = out[0:4000]
    return out
 '''


# caballero2015 is a random subsample - then limits to 18yrs, resulting in 11648
def caballeroExclFcn(x):
    out = x.loc[x['inclusion_only_mimicii']&x['inclusion_over_18'],'icustay_id'].values
    out = np.sort(out)
    out = out[0:11648]
    return out

np.random.seed(546345)
W_extra = 24

##### at the moment I only have 2.
##### I want a better definition of the sepsis cohort.
##### Temporarily removed x['inclusion_has_saps']&
exclusions = OrderedDict([
['caballero2015dynamically_b',  
    [[time_48hr, 48, W_extra], caballeroExclFcn, 'hospital_expire_flag']],
['ripoll2014sepsis',            
    [[time_24hr, 24, W_extra], lambda x: x.loc[x['inclusion_only_mimicii']&x['inclusion_over_18']&x['inclusion_not_explicit_sepsis'],'icustay_id'].values, 'hospital_expire_flag']],
])

param = exclusions['caballero2015dynamically_b'][0][0]
np.asarray(param.values())


# co['inclusion_over_18']
# --------- some summary stat ---------- #

repro_stats = pd.DataFrame(None, columns=['N_Repro', 'Y_Repro'])

N = co.shape[0]

for current_study in exclusions:
    params, iid_keep, y_outcome_label = exclusions[current_study]

    # iid_keep is currently a function - apply it to co to get ICUSTAY_IDs to keep for this study
    iid_keep = iid_keep(co)

    N_STUDY = iid_keep.shape[0]
    Y_STUDY = co.set_index('icustay_id').loc[iid_keep, y_outcome_label].mean() * 100.0

    # print size of cohort in study
    print('{:5g} ({:5.2f}%) - Mortality = {:5.2f}% - {}'.format(
        N_STUDY, N_STUDY * 100.0 / N, Y_STUDY,
        current_study)
    )

    repro_stats.loc[current_study] = [N_STUDY, Y_STUDY]




