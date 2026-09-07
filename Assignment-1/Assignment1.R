library(car)      # Kept for calculating VIF (Multicollinearity)

df <- read.csv("/home/manan/MBA753/Assignment-1/UNHDD.csv", skip = 1)

# Ensure variables are treated as numeric
df$gni       <- as.numeric(df$gni)
df$pop_15_64 <- as.numeric(df$pop_15_64)
df$gii       <- as.numeric(df$gii)
df$hdi       <- as.numeric(df$hdi)
df$life      <- as.numeric(df$life)

# ============================================================
# Q1 – Base Regression Model
# ============================================================
m1 <- lm(gni ~ hdi + gii + life + pop_15_64, data = df)
cat("========== Q1: Model Summary ==========\n")
print(summary(m1))

# ---- Q1b: Model Diagnostics (Visual Methods) ----
cat("\n--- Q1b: Generating Visual Diagnostic Plots ---\n")
# Arrange the 4 default diagnostic plots in a 2x2 grid
par(mfrow = c(2, 2)) 
plot(m1)
par(mfrow = c(1, 1)) # Reset plot layout to default

cat("\n--- Q1b: Multicollinearity (VIF) ---\n")
vif_m1 <- vif(m1)
print(vif_m1)

# ============================================================
# Q2 – Categorical Predictor (HDI Groups)
# ============================================================
df$hdi_group <- factor(df$hdi_group, levels = c("Low", "Medium", "High", "Very high"))

cat("\n========== Q2a: HDI Group Categories ==========\n")
print(table(df$hdi_group))

m2 <- lm(gni ~ hdi_group + gii + life + pop_15_64, data = df)
cat("\n========== Q2b: Model Summary (ref = Low) ==========\n")
print(summary(m2))

df$hdi_group_vh <- relevel(df$hdi_group, ref = "Very high")
m2c <- lm(gni ~ hdi_group_vh + gii + life + pop_15_64, data = df)
cat("\n========== Q2c: Model Summary (ref = Very high) ==========\n")
print(summary(m2c))

# ============================================================
# Q3 – Add interaction term: hdi_group × GII
#       (starting from the model in Q2 with ref = Low)
# ============================================================

# Ensure the reference level is set back to 'Low' for Q3
df$hdi_group <- relevel(df$hdi_group, ref = "Low")

m3 <- lm(gni ~ hdi_group * gii + life + pop_15_64, data = df)
cat("\n========== Q3: Interaction Model Summary ==========\n")
print(summary(m3))

# ---- Q3a: Is the interaction significant? (F-test via ANOVA) ----
cat("\n--- Q3a: ANOVA comparing m2 vs m3 (interaction significance) ---\n")
print(anova(m2, m3))

# ---- Q3c: Model Diagnostics for m3 ----
cat("\n--- Q3c: Generating Visual Diagnostic Plots for Interaction Model ---\n")
# Arrange the 4 default diagnostic plots in a 2x2 grid
par(mfrow = c(2, 2))
plot(m3)
par(mfrow = c(1, 1)) # Reset plot layout to default

cat("\n--- Q3c: Multicollinearity (Generalised VIF) ---\n")
# Generalized VIF accounts for the structure of interaction terms
gvif_m3 <- vif(m3)
print(gvif_m3)
