# helpers for test running the ripoll comparison study

def vars_of_interest():
    # we extract the min/max for these covariates
    var_min = ['heartrate', 'sysbp', 'diasbp', 'meanbp',
                'resprate', 'tempc', 'spo2']
    var_max = var_min
    var_min.append('gcs')
    #var_max.extend(['rrt','vasopressor','vent'])

    # we extract the first/last value for these covariates
    var_first = ['heartrate', 'sysbp', 'diasbp', 'meanbp',
                'resprate', 'tempc', 'spo2']

    var_last = var_first
    var_last.extend(['gcsmotor','gcsverbal','gcseyes','endotrachflag','gcs'])

    var_first_early = ['bg_po2', 'bg_pco2', #'bg_so2'
            #'bg_fio2_chartevents', 'bg_aado2_calc',
            #'bg_fio2', 'bg_aado2',
            'bg_pao2fio2ratio', 'bg_ph', 'bg_baseexcess', #'bg_bicarbonate',
            'bg_totalco2', #'bg_hematocrit', 'bg_hemoglobin',
            'bg_carboxyhemoglobin', 'bg_methemoglobin',
            #'bg_chloride', 'bg_calcium', 'bg_temperature',
            #'bg_potassium', 'bg_sodium', 'bg_lactate',
            #'bg_glucose',
            # 'bg_tidalvolume', 'bg_intubated', 'bg_ventilationrate', 'bg_ventilator',
            # 'bg_peep', 'bg_o2flow', 'bg_requiredo2',
            # begin lab values
            'aniongap', 'albumin', 'bands', 'bicarbonate', 'bilirubin', 'creatinine',
            'chloride', 'glucose', 'hematocrit', 'hemoglobin', 'lactate', 'platelet',
            'potassium', 'ptt', 'inr', 'sodium', 'bun', 'wbc']

    var_last_early = var_first_early
    # fourth set of variables
    # we have special rules for these...
    var_sum = ['urineoutput']

    var_static = [u'is_male', u'emergency_admission', u'age',
               # services
               u'service_any_noncard_surg',
               u'service_any_card_surg',
               u'service_cmed',
               u'service_traum',
               u'service_nmed',
               # ethnicities
               u'race_black',u'race_hispanic',u'race_asian',u'race_other',
               # demographics
               u'height', u'weight', u'bmi']

    return var_min, var_max, var_first, var_last, var_sum, var_first_early, var_last_early, var_static


def get_design_matrix(df, time_dict, W=8, W_extra=24):
    # W_extra is the number of extra hours to look backward for labs
    # e.g. if W_extra=24 we look back an extra 24 hours for lab values

    # timing info for icustay_id < 200100:
    #   5 loops, best of 3: 877 ms per loop

    # timing info for all icustay_id:
    #   5 loops, best of 3: 1.48 s per loop

    # get the hardcoded variable names
    var_min, var_max, var_first, var_last, var_sum, var_first_early, var_last_early, var_static = vars_of_interest()

    tmp = np.asarray(time_dict.items()).astype(int)
    N = tmp.shape[0]

    M = W+W_extra
    # create a vector of [0,...,M] to represent the hours we need to subtract for each icustay_id
    hr = np.linspace(0,M,M+1,dtype=int)
    hr = np.reshape(hr,[1,M+1])
    hr = np.tile(hr,[N,1])
    hr = np.reshape(hr, [N*(M+1),], order='F')

    # duplicate tmp to M+1, as we will be creating T+1 rows for each icustay_id
    tmp = np.tile(tmp,[M+1,1])

    tmp_early_flag = np.copy(tmp[:,1])

    # adding hr to tmp[:,1] gives us what we want: integers in the range [Tn-T, Tn]
    tmp = np.column_stack([tmp[:,0], tmp[:,1]-hr, hr>W])

    # create dataframe with tmp
    df_time = pd.DataFrame(data=tmp, index=None, columns=['icustay_id','hr','early_flag'])
    df_time.sort_values(['icustay_id','hr'],inplace=True)

    # merge df_time with df to filter down to a subset of rows
    df = df.merge(df_time, left_on=['icustay_id','hr'], right_on=['icustay_id','hr'],how='inner')

    # apply functions to groups of vars
    df_first_early  = df.groupby('icustay_id')[var_first_early].first()
    df_last_early   = df.groupby('icustay_id')[var_last_early].last()


    # slice down df_time by removing early times
    # isolate only have data from [t - W, t - W + 1, ..., t]
    df = df.loc[df['early_flag']==0,:]

    df_first = df.groupby('icustay_id')[var_first].first()
    df_last  = df.groupby('icustay_id')[var_last].last()
    df_min = df.groupby('icustay_id')[var_min].min()
    df_max = df.groupby('icustay_id')[var_max].max()
    df_sum = df.groupby('icustay_id')[var_sum].sum()

    # update the column names
    df_first.columns = [x + '_first' for x in df_first.columns]
    df_last.columns = [x + '_last' for x in df_last.columns]
    df_first_early.columns = [x + '_first_early' for x in df_first_early.columns]
    df_last_early.columns = [x + '_last_early' for x in df_last_early.columns]
    df_min.columns = [x + '_min' for x in df_min.columns]
    df_max.columns = [x + '_max' for x in df_max.columns]
    df_sum.columns = [x + '_sum' for x in df_sum.columns]

    # now combine all the arrays together
    df_data = pd.concat([df_first, df_first_early, df_last, df_last_early, df_min, df_max, df_sum], axis=1)

    return df_data







