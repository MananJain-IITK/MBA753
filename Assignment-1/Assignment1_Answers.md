# MBA 753: Causal Inference Models — Assignment 1
## Dataset: UNHDD (UN Human Development Data, 2019)

---

# Question 1 — Linear Regression: GNI ~ HDI + GII + Life Expectancy + Population (15–64)

**Model fitted:**
```
gni ~ hdi + gii + life + pop_15_64
```

**Model Output Summary:**

| Term        | Estimate    | Std. Error | t-value | p-value      | Significance |
|-------------|-------------|------------|---------|--------------|--------------|
| (Intercept) | 4,862.53    | 20,848.36  | 0.233   | 0.81588      |              |
| hdi         | 85,517.64   | 19,756.44  | 4.329   | 2.66e-05     | ***          |
| gii         | −37,769.14  | 12,106.08  | −3.120  | 0.00215      | **           |
| life        | −458.83     | 311.85     | −1.471  | 0.14321      |              |
| pop_15_64   | −6.57       | 8.24       | −0.797  | 0.42660      |              |

- **Residual Standard Error:** 11,430 (on 157 df)
- **Multiple R²:** 0.6837 — the model explains **68.4%** of the variation in GNI
- **Adjusted R²:** 0.6757
- **F-statistic:** 84.85 (4 and 157 df), **p-value < 2.2e-16** (model is overall highly significant)
- **Note:** 27 observations dropped due to missing values in `gii` or `pop_15_64`

---

## Q1a — Which Effects Are Significant?

Two predictors are statistically significant at conventional significance levels:

| Predictor | p-value    | Significance Level |
|-----------|------------|-------------------|
| `hdi`     | 2.66e-05   | *** (α = 0.001)   |
| `gii`     | 0.00215    | ** (α = 0.01)     |

- **`life`** (p = 0.143) and **`pop_15_64`** (p = 0.427) are **not** statistically significant at any conventional threshold (α = 0.05, 0.01, or 0.001).

---

## Q1b — Model Diagnostics

Five key OLS assumptions were tested. Results are summarised below:

### 1. Linearity

**Method:** Residuals vs. Fitted plot (`plot(m1, which=1)`)

**Result:** The residual plot shows a mild curve (non-random pattern) at higher fitted values, suggesting some departure from linearity — particularly for high-GNI countries. This is a moderate concern; a log-transformation of GNI could improve linearity.

---

### 2. Normality of Residuals

**Method:** Shapiro-Wilk test + Normal Q-Q plot (`plot(m1, which=2)`)

**Result:**

| Test         | Statistic | p-value    |
|--------------|-----------|------------|
| Shapiro-Wilk | W = 0.8878 | 9.974e-10 |

**Interpretation:** p-value ≈ 9.97e-10 << 0.05 → **Reject H₀** (normality). Residuals are **not normally distributed**. The Q-Q plot shows heavy right-tailed deviation, driven by high-GNI outliers (e.g., Luxembourg, Norway, Singapore). This violates the OLS normality assumption for small samples, though the large sample size provides some robustness via the CLT.

---

### 3. Homoscedasticity (Constant Variance)

**Method:** Breusch-Pagan test + Scale-Location plot (`plot(m1, which=3)`)

**Result:**

| Test            | Statistic | df | p-value |
|-----------------|-----------|----|---------|
| Breusch-Pagan   | BP = 8.669 | 4 | 0.0699  |

**Interpretation:** p-value = 0.070 > 0.05 → **Fail to reject H₀**. There is **no statistically significant evidence of heteroscedasticity** at α = 0.05 (borderline at α = 0.10). The assumption of homoscedasticity is **tentatively met**, though the visual plot shows slight spread increase at higher fitted values.

---

### 4. Independence of Errors

**Method:** Durbin-Watson test

**Result:**

| Test            | DW Statistic | p-value |
|-----------------|--------------|---------|
| Durbin-Watson   | 1.4949       | 0.00044 |

**Interpretation:** p-value = 0.00044 << 0.05 → **Reject H₀**. There is **evidence of positive autocorrelation** in residuals (DW < 2 indicates positive autocorrelation). This is expected in cross-sectional country data ordered by HDI rank — the ordering of the data introduces serial dependence. This is a limitation of the model.

---

### 5. Multicollinearity

**Method:** Variance Inflation Factor (VIF)

| Predictor   | VIF    |
|-------------|--------|
| `hdi`       | 10.658 |
| `gii`       | 6.586  |
| `life`      | 6.363  |
| `pop_15_64` | 1.005  |

**Interpretation:** **`hdi`** has a VIF > 10, indicating **severe multicollinearity** with other predictors (notably `life` and `gii`). VIFs > 5 for `gii` and `life` also raise concern. This means coefficients (especially for `life`) may be unstable and their individual significance tests are unreliable. This explains why `life` — a conceptually important predictor — is not significant despite having a strong bivariate relationship with GNI.

---

## Q1c — Interpretation of Regression Coefficients

All coefficients represent **partial effects** — the expected change in GNI (in 2017 PPP $) for a one-unit increase in the predictor, **holding all other predictors constant**.

### Intercept (4,862.53)
The predicted GNI when HDI = 0, GII = 0, life expectancy = 0, and population age 15–64 = 0. This is **not meaningful** in practical terms (no country can have zero values for all predictors).

### HDI (β = +85,517.64, p < 0.001) ✅ Significant
- Holding GII, life expectancy, and working-age population constant, a **one-unit increase in HDI** (e.g., from 0 to 1, which covers the full scale) is associated with a **$85,518 increase in GNI per capita**.
- Since HDI ranges from ~0.39 to 0.96 in this data (a range of 0.57), the practical effect translates to roughly **$48,745** across the full HDI range, ceteris paribus.
- **Direction is as expected**: higher human development → higher income. However, given the high VIF (10.66), this estimate is sensitive to collinearity with `life` and `gii`.

### GII (β = −37,769.14, p < 0.01) ✅ Significant
- A **one-unit increase in the Gender Inequality Index** (GII ranges from 0 = perfect equality to 1 = maximum inequality) is associated with a **$37,769 decrease in GNI per capita**, holding other variables constant.
- **Direction is as expected**: greater gender inequality is associated with lower national income, consistent with theory that gender equity promotes economic productivity.

### Life Expectancy (β = −458.83, p = 0.143) ❌ Not Significant
- Holding other variables constant, each additional year of life expectancy is associated with a $459 **decrease** in GNI. However, this effect is **not statistically significant** and the **negative sign is counter-intuitive** (one would expect a positive relationship).
- This likely reflects **suppression/collinearity**: life expectancy is highly correlated with HDI (since HDI is partly constructed from life expectancy), and once HDI is controlled for, the residual effect of life expectancy reverses.

### Population age 15–64 (β = −6.57, p = 0.427) ❌ Not Significant
- Each additional million people in the working-age (15–64) population is associated with a **$6.57 decrease** in GNI per capita — a negligible and statistically insignificant effect. Large countries (e.g., India, China) have large working-age populations but relatively low GNI per capita, which may drive this weak negative association.

---

# Question 2 — Replace HDI with HDI Groups (Categorical)

## Q2a — How Many Categories of HDI Group Are Present?

There are **4 categories** of HDI group in the dataset:

| HDI Group  | Number of Countries |
|------------|---------------------|
| Low        | 33                  |
| Medium     | 37                  |
| High       | 53                  |
| Very high  | 66                  |

The reference category (baseline) is set to **"Low"** as specified.

---

## Q2b — Interpretation of Regression Coefficients (Reference = Low)

**Model fitted:**
```
gni ~ hdi_group + gii + life + pop_15_64   (ref = "Low")
```

**Model Output:**

| Term              | Estimate    | Std. Error | t-value | p-value   | Sig. |
|-------------------|-------------|------------|---------|-----------|------|
| (Intercept)       | −5,428.60   | 19,733.10  | −0.275  | 0.78360   |      |
| hdi_groupMedium   | −3,306.54   | 3,199.46   | −1.033  | 0.30300   |      |
| hdi_groupHigh     | −3,446.71   | 3,860.35   | −0.893  | 0.37332   |      |
| hdi_groupVery high| 15,578.24   | 5,214.29   | 2.988   | 0.00327   | **   |
| gii               | −34,979.61  | 10,477.44  | −3.339  | 0.00105   | **   |
| life              | 461.67      | 254.55     | 1.814   | 0.07167   | .    |
| pop_15_64         | −0.011      | 7.664      | −0.001  | 0.99886   |      |

- **Multiple R²:** 0.7362 (73.6%) — improved from Q1's 68.4%
- **Adjusted R²:** 0.726
- **F-statistic:** 72.09 (6 and 155 df), p < 2.2e-16

### Interpretation of HDI Group Coefficients:

The **intercept** now represents the predicted GNI for a country in the **Low HDI group** with GII = 0, life expectancy = 0, and pop_15_64 = 0 (not practically interpretable).

**Compared to Low HDI countries (reference):**

- **Medium HDI (β = −3,306.54, p = 0.303):** Countries in the Medium HDI group are predicted to have GNI **$3,307 lower** than Low HDI countries, holding other predictors constant. This is **counter-intuitive and not significant** — likely because the GII variable absorbs much of the variation, and there is within-group heterogeneity.

- **High HDI (β = −3,446.71, p = 0.373):** Countries in the High HDI group are predicted to have GNI **$3,447 lower** than Low HDI countries. Again, **counter-intuitive and not significant**. This suggests that when life expectancy and GII are controlled for, the High category does not differ significantly from Low in terms of GNI per capita — possibly due to multicollinearity between GII and HDI group.

- **Very High HDI (β = +15,578.24, p = 0.003) ✅ Significant:** Countries in the Very High HDI group are predicted to have GNI **$15,578 higher** than Low HDI countries, holding other variables constant. This is the only HDI group coefficient that is statistically significant, confirming a meaningful income premium for the top HDI tier.

### Are these results in tune with Q1?

**Partially.** In Q1, HDI (continuous) was highly significant and positively associated with GNI. The Q2 results are broadly consistent at the extremes — Very High HDI is associated with significantly higher GNI — but the lack of significance and counter-intuitive signs for Medium and High groups reveal that the **linear representation of HDI in Q1 was masking within-group variation**. The categorical specification improves R² (73.6% vs 68.4%) but reveals that the GNI gradient is not monotonically increasing across HDI groups once other covariates are controlled. The dominance of the **Very High** group is the primary driver of the positive HDI-GNI relationship.

---

## Q2c — Reference Category Changed to "Very High"

**Model fitted:**
```
gni ~ hdi_group + gii + life + pop_15_64   (ref = "Very high")
```

**Model Output:**

| Term                   | Estimate    | Std. Error | t-value | p-value    | Sig. |
|------------------------|-------------|------------|---------|------------|------|
| (Intercept)            | 10,149.65   | 21,094.45  | 0.481   | 0.63109    |      |
| hdi_group_vhLow        | −15,578.24  | 5,214.29   | −2.988  | 0.00327    | **   |
| hdi_group_vhMedium     | −18,884.78  | 4,001.81   | −4.719  | 5.26e-06   | ***  |
| hdi_group_vhHigh       | −19,024.95  | 2,828.80   | −6.725  | 3.18e-10   | ***  |
| gii                    | −34,979.61  | 10,477.44  | −3.339  | 0.00105    | **   |
| life                   | 461.67      | 254.55     | 1.814   | 0.07167    | .    |
| pop_15_64              | −0.011      | 7.664      | −0.001  | 0.99886    |      |

- **R², Adjusted R², F-statistic, RSE:** **Identical to Q2b** (only the reference changes; the overall model fit is unchanged)

### Interpretation of HDI Group Coefficients (Relative to Very High):

All three lower HDI groups now have **negative and statistically significant** coefficients, confirming they all have lower GNI per capita compared to Very High HDI countries.

- **Low vs. Very High (β = −15,578.24, p = 0.003):** Low HDI countries are predicted to have GNI **$15,578 lower** than Very High HDI countries, ceteris paribus.
- **Medium vs. Very High (β = −18,884.78, p < 0.001):** Medium HDI countries are predicted to have GNI **$18,885 lower** — a surprisingly larger deficit than Low HDI countries.
- **High vs. Very High (β = −19,024.95, p < 0.001):** High HDI countries are predicted to have GNI **$19,025 lower** than Very High HDI countries.

### Key Conclusions:

1. **The Very High HDI group commands a substantial GNI premium** — all other groups are significantly poorer in per capita terms, after controlling for GII, life expectancy, and working-age population size.
2. **The Medium and High groups are not significantly different from each other** in terms of GNI gap relative to Very High (their coefficients are similar: ~−18,885 vs ~−19,025). This suggests GNI does **not follow a smooth monotonic gradient** across HDI tiers.
3. **The apparent reversal seen in Q2b** (Medium and High having negative signs vs. Low as reference) now makes economic sense: Medium and High countries actually have lower per-capita GNI than would be expected given their GII and life expectancy values. The Very High tier represents a genuinely distinct economic category.
4. The **overall model fit (R² = 73.6%) and significance of GII remain unchanged** regardless of reference category — confirming these are equivalent parametrizations of the same model.

---

# Question 3 — Add Interaction Term: HDI Group × GII

**Model fitted:**
```
gni ~ hdi_group * gii + life + pop_15_64   (ref = "Low")
```

## Q3a — Is the Interaction Significant?

**ANOVA F-test comparing m2 (additive) vs. m3 (with interaction):**

| Model | Df | RSS          | ΔDf | ΔSum Sq    | F     | p-value    |
|-------|-----|--------------|-----|------------|-------|------------|
| m2    | 155 | 1.7104e+10   |     |            |       |            |
| m3    | 152 | 1.4751e+10   | 3   | 2,352,108,000 | 8.079 | **4.986e-05** |

**Yes, the interaction is jointly significant** (F = 8.079, p = 4.99e-05, α = 0.001). Adding the three interaction terms (HDI_group × GII) significantly improves model fit.

Looking at individual interaction terms in the full model summary:

| Interaction Term          | Estimate    | p-value  | Sig. |
|---------------------------|-------------|----------|------|
| hdi_groupMedium:gii       | +425.07     | 0.99012  |      |
| hdi_groupHigh:gii         | −9,984.25   | 0.73794  |      |
| **hdi_groupVery high:gii**| **−89,872.61** | **0.00171** | **  |

Only the **Very high × GII** interaction is individually significant; the others are not.

---

## Q3b — Interpreting the Interaction Effects

In the interaction model, the coefficients are interpreted as follows:

**Baseline (Low HDI group):** The effect of GII on GNI for Low HDI countries is captured by the main `gii` coefficient:
- **gii (β = +7,443.69, p = 0.771):** For **Low HDI countries**, each 1-unit increase in GII is associated with a $7,444 *increase* in GNI — not significant, suggesting GII has little independent linear relationship with GNI within the Low tier.

**Differential GII effects by HDI group (interaction terms):**

- **Medium HDI × GII (β = +425.07, p = 0.990):** The slope of GII for Medium HDI countries is essentially the same as for Low HDI countries (+7,444 + 425 ≈ +7,869). The difference is negligible and non-significant.

- **High HDI × GII (β = −9,984.25, p = 0.738):** The GII slope for High HDI countries is approximately +7,444 − 9,984 ≈ **−2,540** — directionally negative but not significant.

- **Very High HDI × GII (β = −89,872.61, p = 0.002) ✅ Significant:** The GII slope for Very High HDI countries is +7,444 − 89,873 ≈ **−82,429** per unit increase in GII. This means: for **Very High HDI countries**, a one-unit increase in the Gender Inequality Index is associated with an **$82,429 decrease in GNI per capita**, holding life expectancy and population constant.

**Summary of GII effects by group:**

| HDI Group | Effective GII Slope (approx.) | Interpretation |
|-----------|-------------------------------|----------------|
| Low       | +7,444 (n.s.)                 | No clear relationship |
| Medium    | +7,869 (n.s.)                 | No clear relationship |
| High      | −2,540 (n.s.)                 | Slight negative trend (not significant) |
| Very High | **−82,429** (p=0.002)         | **Strong negative effect of gender inequality** |

**Key insight:** The damaging effect of gender inequality on income is most severe and statistically detectable in **Very High HDI countries**. This makes economic sense: in advanced economies, gender barriers represent a significant foregone output — women are highly educated and capable of high-productivity work, so inequality is particularly costly. In low-HDI countries, gender inequality is conflated with broader structural underdevelopment, making its marginal effect less isolable.

---

## Q3c — Model Diagnostics for Interaction Model

### 1. Linearity

**Method:** Residuals vs. Fitted plot (`plot(m3, which=1)`)

**Result:** Similar mild non-linearity as in m1/m2, particularly at high fitted values. The interaction terms help capture some non-linearity, but a log transformation of GNI would likely help further.

---

### 2. Normality of Residuals

**Method:** Shapiro-Wilk test + Q-Q plot

| Test         | Statistic  | p-value     |
|--------------|------------|-------------|
| Shapiro-Wilk | W = 0.8297 | 1.852e-12   |

**Result:** p-value ≈ 1.85e-12 << 0.05 → **Reject H₀**. Residuals are **severely non-normal** — worse than in m1 (W = 0.888 vs. 0.830). The interaction model has amplified the non-normality, likely because the Very High HDI × GII interaction creates large residuals for outlier countries. Heavy right skew persists.

---

### 3. Homoscedasticity

**Method:** Breusch-Pagan test + Scale-Location plot

| Test          | Statistic  | df | p-value |
|---------------|------------|----|---------|
| Breusch-Pagan | BP = 21.786 | 9 | 0.0096  |

**Result:** p-value = 0.0096 < 0.05 → **Reject H₀**. There is now **significant heteroscedasticity** in the interaction model (was borderline in m1 at p = 0.070). The variance of residuals is not constant across fitted values — the interaction model appears to inflate variance for certain HDI groups. This violates the OLS assumption of homoscedasticity and may affect standard error estimates and inference.

---

### 4. Independence of Errors

**Method:** Durbin-Watson test

| Test          | DW Statistic | p-value |
|---------------|--------------|---------|
| Durbin-Watson | 2.1449       | 0.7227  |

**Result:** p-value = 0.723 > 0.05 → **Fail to reject H₀**. No significant autocorrelation detected. The DW statistic near 2.0 is ideal. This is a notable **improvement over m1** (DW = 1.495, p = 0.0004), suggesting the interaction terms have absorbed the structured variation that was causing serial correlation.

---

### 5. Multicollinearity

**Method:** Generalised VIF (GVIF, appropriate for interaction models)

| Term              | GVIF      | Df | GVIF^(1/2Df) |
|-------------------|-----------|----|---------------|
| hdi_group         | 19,946.37 | 3  | 5.208         |
| gii               | 39.53     | 1  | 6.287         |
| life              | 5.29      | 1  | 2.300         |
| pop_15_64         | 1.06      | 1  | 1.029         |
| hdi_group:gii     | 5,923.59  | 3  | 4.254         |

**Result:** Severe multicollinearity is present between `hdi_group`, `gii`, and their interaction (GVIF >> 10). This is expected in any model with interaction terms, since the interaction terms are mathematically derived from the main effects. The standard errors of individual interaction coefficients are inflated, making it hard to identify which specific interaction terms are significant — but the joint F-test (Q3a) is robust to this.

---

## Q3d — Conclusions about the Regression Model

1. **The interaction model provides a statistically and substantively better fit.** R² improves from 73.6% (additive) to 77.3% (interaction), and the joint F-test confirms the interaction terms are highly significant (p < 0.001).

2. **The key finding is that gender inequality has a dramatically different effect on GNI depending on development level.** In Very High HDI countries, higher gender inequality is associated with substantially lower GNI per capita (slope ≈ −82,429 per unit GII). For Low, Medium, and High HDI countries, the effect is negligible or statistically undetectable — suggesting that in less developed economies, gender inequality is intertwined with broader structural factors that make its independent effect harder to isolate.

3. **The interaction model has diagnostic weaknesses:**
   - **Normality is violated** (Shapiro-Wilk W = 0.830, p ≈ 0): The distribution of GNI is right-skewed (a few very high-income countries drive large residuals). This suggests a **log-transformation of GNI** should be considered.
   - **Heteroscedasticity is present** (BP = 21.79, p = 0.0096): Residual variance is non-constant. Robust standard errors (e.g., HC3) or a transformed dependent variable would improve inference.
   - **Multicollinearity is severe** in the interaction terms, though the joint interaction test is still valid.
   - **Autocorrelation is resolved** by the interaction model (DW ≈ 2.14, p = 0.72), which is a genuine improvement.

4. **Overall, the model highlights the complementary role of gender equity and human development in explaining cross-national income differences.** Policy implications suggest that reducing gender inequality yields the greatest economic returns in already highly developed countries, where the structural conditions for women's economic participation are in place but inequality still acts as a binding constraint.

---

*R code for all analyses is in `Assignment1.R`.*
