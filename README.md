# Modeling Cardiometabolic Multimorbidity Over Time: Integrating Subject-Specific and Population-Averaged Ordinal Approaches

# Study Design & Objective

Modeled ordinal multimorbidity burden (0–3: diabetes, hypertension, high cholesterol) across 3 visits.

Applied mixed-effects, GEE, and Bayesian partial proportional odds (PPO) models.

Captured both subject-specific and population-averaged effects, with focus on time-varying, threshold-specific, and non-linear associations.

# Step 1: Descriptive & Temporal Trends

Assessed baseline characteristics: 63.9% female; 25.6% with depressive symptoms; 62.1% physically active.

Documented comorbidity progression: Diabetes: 19.9% → 36.7%; Hypertension: 29.9% → 40.8%; Cholesterol: 43.6% → 47.9%.

Tracked multimorbidity transitions: Full burden peaked at Visit 2 (13.9%), declined by Visit 3 (7.5%). Participants with no condition dropped from 39.5% to 19.9%.

# Step 2: Exploratory Variable Distributions

BMI: Right-skewed; modal ~30 kg/m²; excluded extreme outlier (>70) for model stability. Age: Mean = 53.5; slightly right-skewed. HEI-2010 diet score: Normally distributed; mean = 60.6.

Within-person variability observed for BMI, ICC = 0.92; within-SD = 2.73 → modeled as time-varying.

# Step 3: Correlation & Collinearity Analysis

BMI & Obesity: Highly collinear (r = 0.75–0.77 cross-sectionally; r = 0.90 longitudinally) → Only BMI retained in models.

BMI & HEI-2010: Weak inverse correlation at later visits (r ≈ –0.085). Age & HEI-2010: Modest positive association (ρ ≈ 0.15).

Binary predictors: Smoking & Alcohol: Strong early correlation (χ² = 46.0; p < 0.0001); declined over time. Depression correlated with both smoking and alcohol (r ≈ 0.27–0.30). Sex correlated with physical activity and alcohol use (r ≈ 0.15–0.29).

Informed feature selection; time-varying dynamics prioritized.

# Step 4: Cross-Sectional Ordinal Logistic Models (Visits 1–3)

Tested proportional odds (PO) assumption using Brant test and visual diagnostics. Violations noted for age, sex, education, alcohol (especially at Visits 1–2).

Used partial proportional odds logistic models: Age, sex, and depression: associated with higher burden. Alcohol protective only at early visits. BMI showed U-shaped effects; protective at low thresholds, risk at high thresholds.

# Step 5: Longitudinal Mixed Effects (GLMM with Random Intercepts)

Included random intercepts → improved model fit (AIC: 14,339 → 13,661).

Without interactions: Female sex (OR = 1.77), alcohol (OR = 1.23) increased burden. Age (OR = 0.92), BMI (OR = 0.92), depression (OR = 0.73) were protective.

With visit interactions: Sex effect attenuated by Visit 3 (interaction OR = 0.51). Age and BMI effects reversed from protective to risk at Visit 3 (interaction ORs = 1.07, 1.05).

Random intercept variance increased (2.19 → 2.48), reflecting more captured heterogeneity.

# Step 6: Bayesian Partial Proportional Odds Mixed Model (brms)

Allowed threshold-specific effects using cs() function. 

Included subject-level random intercept (SD = 1.51; CrI: 1.42–1.62).

Model Fit Assessment and Diagnostics

Leave-One-Out Cross-Validation (LOO): Used loo() function to assess model’s out-of-sample predictive accuracy.

Expected log predictive density (ELPD) = –6497.1 (SE = 46.9); effective number of parameters (p_loo) ≈ 1247, indicating well-regularized model complexity.

Pareto-smoothed importance sampling (PSIS) diagnostics: 99.97% of observations had Pareto k ≤ 0.7, indicating no influential observations compromising LOO reliability.

WAIC (Widely Applicable Information Criterion): Reported WAIC and associated effective parameter estimates, which aligned with LOO findings and further supported good predictive accuracy.

MCMC Convergence Diagnostics: Gelman-Rubin statistics (R̂) = 1.00 for all parameters (Table 22), confirming convergence. Effective sample sizes (ESS) > 700 for all fixed and random effects.

Posterior Distributions and Trace Plots: Examined posterior densities and trace plots for all parameters to ensure well-mixed chains and unimodal distributions (Figures 9 & 10). Included threshold-specific and proportional fixed effects, as well as random intercept SD. All chains showed no signs of divergence or poor mixing.

Posterior Predictive Checks: Conducted posterior predictive checks to evaluate model’s ability to reproduce observed ordinal outcome distribution (Figure 11). Compared observed outcome density with simulated draws from posterior predictive distribution. Overlay plot showed tight alignment between observed and predicted values, confirming adequate fit to marginal outcome structure.

Key inferences: BMI: Monotonically increasing effect (OR = 1.08 → 1.11 across thresholds). Female sex: Protective at low burden (OR = 0.46), attenuated at high burden (OR = 0.68). Age: Weak positive association (OR ≈ 1.08); consistent with clinical aging risk. Depression: Risk at low burden (OR = 1.58), null at high burden (OR = 1.08). Alcohol & education: Protective at high thresholds. Smoking, diet, physical activity: Not significant.

# Step 7: Generalized Estimating Equations (GEE) for Population-Averaged Effects

Cumulative logit GEE model assuming PO: Age (OR = 1.06), BMI (OR = 1.063): consistent population-level risk. Female sex protective (OR = 0.649); depression increased risk (OR = 1.283). Alcohol use protective (OR = 0.831).

Visit × Covariate interactions: Sex effect reversed by Visit 3 (interaction OR = 1.662). BMI and age effects attenuated at Visit 3 (interaction ORs = 0.953 and 0.951). Time-varying trends confirmed by Type 3 score tests (p < 0.0001 for age, sex, BMI).

# Clinical & Modeling Conclusions

Identified BMI, age, sex, depression, and education as consistent risk factors.

Highlighted importance of: Threshold-specific modeling, non-proportional effects, time-varying covariates, subject-specific vs. marginal inference

Provided interpretable insights for personalized risk stratification and population-level prevention.
