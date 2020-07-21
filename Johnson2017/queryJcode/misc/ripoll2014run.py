# code for running the ripoll 2014 reproduction study

from sklearn.linear_model import LogisticRegression


# pick the study to run the example on
current_study = 'ripoll2014sepsis'

models = OrderedDict([
   #  ['xgb', xgb.XGBClassifier(max_depth=3, n_estimators=300, learning_rate=0.05)],
    # ['lasso', LassoCV(cv=5,fit_intercept=True,normalize=True,max_iter=10000)],
    # ['rf', RandomForestClassifier()],
    ['logreg', LogisticRegression(fit_intercept=True)]
])



params = exclusions[current_study][0] # i dont remember what this is for

# df, time_dict, W=24, W_extra=24
df_data = get_design_matrix(df, params[0], W=params[1], W_extra=params[2])  # mp.

df = df
time_dict = params[0]  # a list of 24

# these are just a list of feature names
var_min, var_max, var_first, var_last, var_sum, var_first_early, var_last_early, var_static = vars_of_interest()

var_min
var_max
var_first_early

######
len(time_dict)
tmp = np.asarray(time_dict.items()).astype(int)
N = tmp.shape[0]
##### alternatively, just use 24 for tmp
tmp = np.repeat(24, 130)
######
tmp.shape


M = W + W_extra
# create a vector of [0,...,M] to represent the hours we need to subtract for each icustay_id
hr = np.linspace(0, M, M + 1, dtype=int)  # 0 to 48
hr = np.reshape(hr, [1, M + 1])  # same, but becomes array([[...]])
hr = np.tile(hr, [N, 1])      # becomes 130 rows of 0 to 48, replicates
hr = np.reshape(hr, [N * (M + 1), ], order='F')  # rep 0, 130 ... rep 48, 130 (total 6370)

# duplicate tmp to M+1, as we will be creating T+1 rows for each icustay_id
tmp = np.tile(tmp, [M + 1, 1]) ##### not sure this is correct











