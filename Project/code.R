# ==============================================================================
# MBA 753: Causal Inference Project
# Final RDD Execution Script: Conditional Cash Transfers on Maternal/Infant Health
# ==============================================================================

# Install required packages (uncomment if not installed)
# install.packages(c("tidyverse", "rdrobust"))

library(tidyverse)
library(rdrobust)

# ------------------------------------------------------------------------------
# 1. LOAD THE DATA
# ------------------------------------------------------------------------------
# Update file paths to match your local directory structure exactly
ds2_hh <- read_delim("/home/manan/MBA753/Project/ICPSR_36151-V6/ICPSR_36151/DS0002/36151-0002-Data.tsv", delim = "\t")
ds3_women <- read_delim("/home/manan/MBA753/Project/ICPSR_36151-V6(2)/ICPSR_36151/DS0003/36151-0003-Data.tsv", delim = "\t")

# ------------------------------------------------------------------------------
# 2. MERGE DATASETS
# ------------------------------------------------------------------------------
# Left join household economics/demographics to the women's health records
merged_data <- ds3_women %>%
  left_join(ds2_hh, by = c("STATEID", "DISTID", "PSUID", "HHID", "HHSPLITID"))

# ------------------------------------------------------------------------------
# 3. DATA CLEANING & VARIABLE CREATION
# ------------------------------------------------------------------------------
# Setting the annual per-capita poverty line threshold (INR 5,400)
poverty_threshold_pc <- 5400 

analysis_df <- merged_data %>%
  mutate(
    EW7Y = as.numeric(EW7Y),
    INCOME = as.numeric(INCOME.y),
    NPERSONS = as.numeric(NPERSONS.y),
    LB18 = as.numeric(LB18),
    LB1B = as.numeric(LB1B),
    RO5 = as.numeric(RO5),
    EW15A = as.numeric(EW15A)
  ) %>%
  # Filter for post-2005 births (matching the JSY national policy rollout window)
  filter(EW7Y >= 5 | EW7Y >= 2005) %>%
  mutate(
    IncomePC = INCOME / NPERSONS,
    Running_Var = IncomePC - poverty_threshold_pc,
    Treatment = ifelse(Running_Var <= 0, 1, 0), # 1 = Below Poverty Line (Treated)
    Inst_Delivery = ifelse(LB18 %in% c(1, 2), 1, 0),
    Mortality = ifelse(LB1B == 2, 1, 0)
  ) %>%
  filter(!is.na(Running_Var))

cat("Final analysis sample size:", nrow(analysis_df), "observations\n")

# ------------------------------------------------------------------------------
# 4. DESCRIPTIVE STATISTICS (For Section 3: Data)
# ------------------------------------------------------------------------------
cat("\n================ DESCRIPTIVE STATISTICS ================\n")
desc_stats <- analysis_df %>%
  group_by(Treatment) %>%
  summarise(
    Count = n(),
    Mean_Income_PC = mean(IncomePC, na.rm = TRUE),
    Pct_Inst_Delivery = mean(Inst_Delivery, na.rm = TRUE) * 100,
    Pct_Mortality = mean(Mortality, na.rm = TRUE) * 100
  )
print(desc_stats)

# ------------------------------------------------------------------------------
# 5. ASSUMPTION TESTING (For Section 4: Method)
# ------------------------------------------------------------------------------
cat("\n================ ASSUMPTION TESTS ================\n")
# Test 1: Mother's Age Continuity
rdd_age <- rdrobust(y = analysis_df$RO5, x = analysis_df$Running_Var, c = 0)
summary(rdd_age)

# Test 2: Mother's Education Continuity
rdd_edu <- rdrobust(y = analysis_df$EW15A, x = analysis_df$Running_Var, c = 0)
summary(rdd_edu)

# ------------------------------------------------------------------------------
# 6. RDD MODELS & RESULTS (For Section 5: Results)
# ------------------------------------------------------------------------------
cat("\n================ RDD MODEL 1: INSTITUTIONAL DELIVERY ================\n")
rdd_delivery <- rdrobust(y = analysis_df$Inst_Delivery, x = analysis_df$Running_Var, c = 0)
summary(rdd_delivery)

cat("\n================ RDD MODEL 2: INFANT MORTALITY ================\n")
rdd_mortality <- rdrobust(y = analysis_df$Mortality, x = analysis_df$Running_Var, c = 0)
summary(rdd_mortality)

# ------------------------------------------------------------------------------
# 7. PRESENTATION VISUALIZATIONS (For Section 3 & 5 Figures)[cite: 1]
# ------------------------------------------------------------------------------
# Plot 1: Institutional Delivery Discontinuity
rdplot(y = analysis_df$Inst_Delivery, x = analysis_df$Running_Var, c = 0,
       x.label = "Per Capita Income (Centered at Poverty Threshold)",
       y.label = "Probability of Institutional Delivery",
       title = "RDD: Impact of Poverty Status on Institutional Delivery")

# Plot 2: Infant Mortality Discontinuity
rdplot(y = analysis_df$Mortality, x = analysis_df$Running_Var, c = 0,
       x.label = "Per Capita Income (Centered at Poverty Threshold)",
       y.label = "Infant Mortality Indicator",
       title = "RDD: Impact of Poverty Status on Infant Mortality")