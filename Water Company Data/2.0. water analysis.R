# Clear the environment ---------------------------------------------------
rm(list = ls())


# loading packages --------------------------------------------------------

#install.packages(c("tidyverse", "lubridate", "janitor", "scales", "arules","tibble"))

#install.packages("forecast")

library(tidyverse)
library(lubridate)
library(janitor)
library(scales)
library(forecast)
library(tibble)


setwd("../Water Company Analysis/")

dt <- readxl::read_xlsx("../Water Company Analysis/1.0 Budalangi_water_synthetic_2024.xlsx", sheet = "budalangi_water_synthetic_2024",  .name_repair = make.unique)

glimpse(dt)

# Aggregate to customer level

cust_feat <- dt %>%
  group_by(customer_id, customer_type, zone, connection_type, meter_size) %>%
  summarise(
    avg_monthly_volume = mean(billed_volume_m3, na.rm = TRUE),
    sd_monthly_volume = sd(billed_volume_m3, na.rm = TRUE),
    avg_bill = mean(total_bill_kes, na.rm = TRUE),
    avg_amount_paid = mean(amount_paid_kes, na.rm = TRUE),
    pay_ratio = avg_amount_paid / avg_bill,
    avg_payment_delay = mean(payment_delay_days, na.rm = TRUE),
    arrears_rate = mean(has_arrears_flag, na.rm = TRUE),
    disconnection_rate = mean(is_disconnected, na.rm = TRUE),
    complaints_rate = mean(complaints_count, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    volume_cv = sd_monthly_volume / if_else(avg_monthly_volume == 0, 1, avg_monthly_volume)
  )

numeric_cols <- c(
  "avg_monthly_volume", "volume_cv", "avg_bill",
  "pay_ratio", "avg_payment_delay",
  "arrears_rate", "disconnection_rate", "complaints_rate"
)

cust_numeric <- cust_feat %>%
  select(all_of(numeric_cols)) %>%
  replace_na(list(
    avg_payment_delay = 0,
    volume_cv = 0
  ))

cust_scaled <- scale(cust_numeric)

set.seed(123)

k <- 3 

km <- kmeans(cust_scaled, centers = k, nstart = 25)

cust_feat <- cust_feat %>%
  mutate(cluster = factor(km$cluster))

#cluster profile
cluster_profile <- cust_feat %>%
  group_by(cluster) %>%
  summarise(across(all_of(numeric_cols), mean, na.rm = TRUE))

writexl::write_xlsx(cluster_profile,"cluster_profile.xlsx")



# Diagnostic Analysis (why is it happening currently?) -----------------------------------------------------
#cluster vs customer type

customer_type <- cust_feat %>%
  count(cluster, customer_type) %>%
  group_by(cluster) %>%
  mutate( pct = n/sum(n) * 100) %>%
  arrange(cluster, desc(pct))

writexl::write_xlsx(customer_type,"cust_feat.xlsx")

#cluster vs zone

zone_data <-cust_feat %>%
  count(cluster, zone) %>%
  group_by(cluster) %>%
  mutate(pct = n/sum(n) * 100) %>%
  arrange(cluster,desc(pct))

writexl::write_xlsx(zone_data,"zone_data.xlsx")


#Billing behavior diagnostic

cust_feat %>%
  group_by(cluster) %>%
  summarise(
    avg_delay = mean(avg_payment_delay),
    arrears_rate = mean(arrears_rate),
    disconnection_rate = mean(disconnection_rate),
    pay_ratio = mean(pay_ratio),
    .groups = "drop"
  )

ggplot(cust_feat, aes(x = cluster, y= avg_payment_delay, fill = cluster)) +
  geom_boxplot() +
  labs( title = "Cluster By Average Payment Delay",
        x = "Cluster",
        y = "Average Payment Delay (Days)" )
  

#Service issues as Root Causes

cust_feat %>%
  group_by(cluster) %>%
  summarise(
    avg_complaints = mean(complaints_rate),
    high_complaint_share = mean(complaints_rate > 0.1),
    .groups = "drop"
  )
  

diagnostic_summary <- cluster_profile %>%
  mutate(
    risk_label = case_when(
      arrears_rate > 0.4 & disconnection_rate > 0.2 ~ "High Risk",
      arrears_rate > 0.2 ~ "Medium Risk",
      TRUE ~ "Low Risk"
    )
  )



# Predictive Modelling ----------------------------------------------------

#predict risks such as
#1. Arrears
#2. Disconnection
#3. late payment



dt_mod <- dt %>%
  mutate(
    billing_month = ym(billing_month),
    late_pay = if_else(is.na(payment_delay_days), 0L, if_else(payment_delay_days > 10, 1L, 0L))
  ) %>%
  left_join(
    cust_feat %>% select(customer_id, cluster),
    by = "customer_id"
  ) %>%
  arrange(customer_id, billing_month) %>%
  group_by(customer_id) %>%
  mutate(
    lag_paid = lag(is_paid, 1),
    lag_arrears = lag(has_arrears_flag, 1),
    lag_volume = lag(billed_volume_m3, 1),
    lag_pay_ratio = lag(amount_paid_kes / total_bill_kes, 1)
  ) %>%
  ungroup() %>%
  mutate(
    pay_ratio = amount_paid_kes / total_bill_kes
  )

#using time based split

train <- dt_mod %>%
  filter(billing_month <= ym("2024-09"))

text <- dt_mod %>%
  filter(billing_month >= ym("2024-10"))
  
  
#predict arrears

arrears_model <- glm(
  has_arrears_flag ~ cluster + customer_type + zone + connection_type +
    billed_volume_m3 + total_bill_kes + pay_ratio + late_pay +
    lag_paid + lag_arrears + lag_volume + lag_pay_ratio,
  data = train,
  family = binomial()
  
)

summary(arrears_model)





