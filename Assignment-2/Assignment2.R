# Load necessary libraries
library(dplyr)
library(lubridate)
library(stargazer)

# Assuming df is already loaded
# Reload the raw data (replace with your actual filename)
df <- read.csv("MBA753/Assignment-2/petrol.csv") 

# Print the first 10 raw date entries
head(df$date, 10)
event_date <- as.Date("2017-06-16")

# ---------------------------------------------------------
# UPDATED DATA PREPARATION
# ---------------------------------------------------------
df <- df %>%
  mutate(
    # Tests multiple formats automatically and converts to Date class
    date = as.Date(parse_date_time(date, orders = c("dmy", "ymd", "mdy", "Ymd", "Y-m-d H:M:S"))), 
    
    Time = as.numeric(date - min(date, na.rm = TRUE)), 
    
    PostEvent = ifelse(date >= event_date, 1, 0), 
    
    TimeAfterEvent = ifelse(date >= event_date, as.numeric(date - event_date), 0),
    
    state = as.factor(state)
  )

# ---------------------------------------------------------
# Q1. EVENT STUDY ANALYSIS (OVERALL)
# ---------------------------------------------------------
# Note: Using 'rate' instead of 'Price'
model_q1 <- lm(rate ~ Time + PostEvent + TimeAfterEvent, data = df)
summary(model_q1)

# ---------------------------------------------------------
# Q2. EVENT STUDY MODEL WITH STATE COVARIATES
# ---------------------------------------------------------
# Note: Using 'state' instead of 'State'
model_q2 <- lm(rate ~ Time + PostEvent + TimeAfterEvent + state, data = df)
summary(model_q2)

# ---------------------------------------------------------
# Q3. INDEPENDENT MODELS FOR KARNATAKA AND MAHARASHTRA
# ---------------------------------------------------------
df_karnataka <- df %>% filter(state == "Karnataka")
df_maharashtra <- df %>% filter(state == "Maharashtra")

model_karnataka <- lm(rate ~ Time + PostEvent + TimeAfterEvent, data = df_karnataka)
model_maharashtra <- lm(rate ~ Time + PostEvent + TimeAfterEvent, data = df_maharashtra)

stargazer(model_karnataka, model_maharashtra, 
          type = "text", 
          column.labels = c("Karnataka", "Maharashtra"),
          title = "Comparison of Policy Impact by State")