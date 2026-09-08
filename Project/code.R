# install.packages(c("tidyverse", "rdrobust"))

library(tidyverse)
library(rdrobust)

ds2_hh <- read_delim("/home/manan/MBA753/Project/ICPSR_36151-V6/ICPSR_36151/DS0002/36151-0002-Data.tsv", delim = "\t")
ds3_women <- read_delim("/home/manan/MBA753/Project/ICPSR_36151-V6(2)/ICPSR_36151/DS0003/36151-0003-Data.tsv", delim = "\t")

# Left join household economics/demographics to the women's health records
merged_data <- ds3_women %>%
  left_join(ds2_hh, by = c("STATEID", "DISTID", "PSUID", "HHID", "HHSPLITID"))

# ------------------------------------------------------------------------------
# 3. SURGICAL DATA CLEANING (HPS + CASTE TARGETING)
# ------------------------------------------------------------------------------
poverty_threshold_pc <- 5400 

# Official Census STATEID codes for the 10 JSY "Low Performing States"
lps_states <- c(1, 5, 8, 9, 10, 18, 20, 21, 22, 23)

analysis_df <- merged_data %>%
  mutate(
    EW7Y = as.numeric(EW7Y),
    INCOME = as.numeric(INCOME.y),
    NPERSONS = as.numeric(NPERSONS.y),
    LB18 = as.numeric(LB18),
    LB1B = as.numeric(LB1B),
    RO5 = as.numeric(RO5),
    EW15A = as.numeric(EW15A),
    STATEID = as.numeric(STATEID),
    ID13 = as.numeric(ID13.y)
  ) %>%
  # Filter 1: Post-2005 births (Policy Rollout window)
  filter(EW7Y >= 5 | EW7Y >= 2005) %>%
  
  # Filter 2: Keep ONLY High Performing States (Exclude LPS)
  filter(!STATEID %in% lps_states) %>%
  
  # Filter 3: The Caste Filter (Exclude SC and ST to isolate the income rule)
  filter(!ID13 %in% c(4, 5)) %>%
  
  # Filter 4: The Age Filter (Strict JSY policy rule: Mother must be 19+)
  filter(RO5 >= 19) %>%
  mutate(
    IncomePC = INCOME / NPERSONS,
    Running_Var = IncomePC - poverty_threshold_pc,
    Treatment = ifelse(Running_Var <= 0, 1, 0),
    Inst_Delivery = ifelse(LB18 %in% c(1, 2), 1, 0),
    Mortality = ifelse(LB1B == 2, 1, 0)
  ) %>%
  filter(!is.na(Running_Var))

cat("Surgical sample size (HPS + Non-SC/ST):", nrow(analysis_df), "observations\n")
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
# 7. REVISED PRESENTATION VISUALIZATIONS 
# ------------------------------------------------------------------------------
# Plot 1: Institutional Delivery Discontinuity (Zoomed In)
rdplot(y = analysis_df$Inst_Delivery, x = analysis_df$Running_Var, c = 0,
       p=1,
       x.lim = c(-5400, 10000),  # Zooms in to a relevant bandwidth (e.g., 20k above the line)
       y.lim = c(0, 1),          # Forces the Y-axis to stay within valid probability bounds
       x.label = "Per Capita Income (Centered at Poverty Threshold)",
       y.label = "Probability of Institutional Delivery",
       title = "RDD: Impact of Poverty Status on Institutional Delivery")

# Plot 2: Infant Mortality Discontinuity (Zoomed In)
rdplot(y = analysis_df$Mortality, x = analysis_df$Running_Var, c = 0,
       p=1,
       x.lim = c(-5400, 10000),  
       y.lim = c(0, 0.15),       # Mortality rates are usually low, zooming in helps visibility
       x.label = "Per Capita Income (Centered at Poverty Threshold)",
       y.label = "Infant Mortality Probability",
       title = "RDD: Impact of Poverty Status on Infant Mortality")
