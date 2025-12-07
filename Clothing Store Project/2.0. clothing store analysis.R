# Clear the environment ---------------------------------------------------
rm(list = ls())


# loading packages --------------------------------------------------------

#install.packages(c("tidyverse", "lubridate", "janitor", "scales", "arules","tibble"))

library(tidyverse)
library(lubridate)
library(janitor)
library(scales)
#library(arules)
library(tibble)


setwd("../Sales Project and Analysis/")

dt <- readxl::read_xlsx("../Sales Project and Analysis/1.0 clothing_store_data.xlsx", sheet = "clothing_store",  .name_repair = make.unique)

glimpse(dt)


# ensuring the types are correct ------------------------------------------

dt <- dt %>%
  mutate(
    transaction_date = ymd(transaction_date),
    stockout_flag = as.factor(stockout_flag),
    promotion_type = as.factor(promotion_type),
    channel = as.factor(channel),
    customer_segment = as.factor(customer_segment),
    product_category = as.factor(product_category),
    customer_gender = as.factor(customer_gender),
    customer_city = as.factor(customer_city),
    store_id = as.factor(store_id)
  )


# Sales performance and trend analysis ------------------------------------
#Daily Sales

daily_sales <- dt %>%
  group_by(transaction_date) %>%
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
    total_units = sum(quantity_sold, na.rm = TRUE),
    n_transactions = n_distinct(transaction_id)
  )

#plot daily sales

ggplot(daily_sales,aes(x = transaction_date,y = total_sales)) +
  geom_line() +
  labs(
    title = "Daily Sales Over Time",
    x = "Date",
    y = "Sales Amount"
  )

ggsave("cloth-sales_plot.png", width = 7, height = 5, dpi = 300)


#monthly sales
 
monthly_sales <- dt %>%
  mutate( month = floor_date(transaction_date,"month")) %>%
  group_by(month) %>%
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
    total_margin = sum(gross_margin, na.rm = TRUE),
    total_units = sum(quantity_sold, na.rm = TRUE)
  ) %>%
  arrange(month) %>%
  mutate(
    sales_lag = lag(total_sales),
    sales_growth_pct = (total_sales - sales_lag)/sales_lag *100,
    mthlysales_pct = (total_sales/sum(total_sales)) *100
  )


monthly_sales

ggplot(monthly_sales, aes( x = month, y = total_sales)) +
  geom_line() +
  labs(
    title = "Monthly sales Trend",
    x = "Month",
    y = "Total Sales"
  )


ggsave("monthly_sales.png", width = 7, height = 5, dpi = 300 )

ggplot(monthly_sales, aes(x = month, y = mthlysales_pct, fill = month)) +
  geom_col() +
  labs(
    title = "Total Sales",
    x = "Month",
    y = "Total Sales"
  ) +
  theme_bw() +
  theme(axis.text.x = (element_text(angle = 45, hjust = 1)))

writexl::write_xlsx(monthly_sales, "monthly_sales.xlsx")

# Are sales affected by promotion/holidays --------------------------------

dt_period <- dt %>%
  mutate(
    month = floor_date(transaction_date,"month")) %>%
      group_by(month, promotion_type) %>%
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
  
  )%>% 
  arrange(month) %>% 
   mutate(
      sales_lag = lag(total_sales),
      sales_growth_pct = (total_sales - sales_lag)/sales_lag *100
    )
    
 dt_promo <- dt %>%
   group_by(promotion_type ) %>%
   summarise(
     total_sales = sum(sales_amount, na.rm = TRUE),
     total_units = sum(quantity_sold, na.rm = TRUE)
   ) %>% arrange(desc(promotion_type))

  


# Product Performance -----------------------------------------------------
#Top Products by sales and Margin

product_perf <- dt %>%
  group_by(product_id, product_name, product_category) %>% 
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
    total_units = sum(quantity_sold, na.rm = TRUE),
    total_margin = sum(gross_margin, na.rm = TRUE),
    avg_discount = mean(discount_pct, na.rm = TRUE),
    .groups = "drop"
  ) %>% arrange(desc(total_sales)) %>%
   mutate(
     sales_share = (total_sales/sum(total_sales))*100,
     margin_share = (total_margin/sum(total_margin))*100
       )

product_perf


writexl::write_xlsx(product_perf,"product_perf.xlsx")

#category level performance

category_perf <- dt %>%
  group_by(product_category) %>%
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
    total_units = sum(quantity_sold, na.rm = TRUE),
    total_margin = sum(gross_margin, na.rm = TRUE),
    avg_unit_price = mean(unit_price, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_sales))

category_perf


ggplot(category_perf, aes(x = reorder(product_category, -total_sales), y = total_sales)) +
  geom_col() +
  labs(
    title = "Sales by Product Category",
      x = "Category",
      y = "Total Sales"
    
  )

ggsave("category_perf.png", width = 7, height = 5, dpi = 300)



# Customer Behavior Analysis ------------------------------------------------------
# age group by category

age_prodcat <- dt %>%
  mutate(
    age_group = case_when(
      customer_age >= 18 & customer_age <= 24 ~ "18 - 24",
      customer_age >= 25 & customer_age <= 34 ~ "25 - 34",
      customer_age >=35 ~ "35+",
      TRUE ~ NA_character_
    )
  ) %>%
  group_by(age_group) %>%
  summarise(
    total_transactions = n_distinct(transaction_id),
    total_units = sum(quantity_sold, na.rm = TRUE),
    total_sales_value = sum(sales_amount, na.rm = TRUE),
    avg_basket_value = mean(sales_amount, na.rm = TRUE),
    .groups = "drop"
    
  ) %>%
  arrange(desc(total_sales_value))

age_prodcat

ggplot(age_prodcat, aes(x = age_group, y = total_sales_value)) +
  geom_col() +
  labs(
    title = "Total Sales by Agegroup",
    x = "Age Group",
    y = "Total Sales Value"
  )

#which products are  preferred by each agegroup

agegroup_product_pref <- dt %>%
  mutate(age_group = case_when(
    customer_age >= 18 & customer_age <= 24 ~ "18 - 24",
    customer_age >=25 & customer_age <= 34 ~ "25 - 34",
    customer_age >= 35 ~ "35+",
    TRUE ~ NA_character_
  )
           ) %>%
  group_by(age_group, product_category, product_name) %>%
  summarise(
    n_transactions = n_distinct(transaction_id),
    total_units = sum(quantity_sold, na.rm = TRUE),
    total_sales_value = sum(sales_amount, na.rm = TRUE),
    .groups = "drop"
  ) %>% group_by(age_group) %>%
  slice_max(order_by = total_units, n=5)
  
  
agegroup_product_pref

  
  # ggplot(agegroup_product_pref, aes(x = product_category, y = total_units, fill = age_group)) +
  #   geom_col() +
  #   labs(
  #     title = "Product Category By Age Group",
  #     x = "Product Category",
  #     y = "Total Units"
  #   )
  
  
  
  ggplot(agegroup_product_pref, aes(x = product_category, y = total_units, fill = product_category)) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~ age_group, scales = "free_x") +
    labs(
      title = "Top Product Categories by Age Group",
      x = "Product Category",
      y = "Total Units"
    ) +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

ggsave("agegroup_product_pref.png", width = 7, height = 5, dpi = 300)

#sales share of the different customer segment

segment_by_category1  <- dt %>%
  mutate(
    customer_segment = as.factor(customer_segment)
  ) %>% group_by(customer_segment) %>%
  summarise(
    total_units = sum(quantity_sold, na.rm = TRUE),
    total_sales = sum(sales_amount, na.rm = TRUE),
    avg_unit_price = mean(unit_price, na.rm = TRUE),
    avg_cost = mean(unit_cost, na.rm = TRUE),
    n_transactions = n_distinct(transaction_id),
    .groups = "drop"
  ) %>% arrange(customer_segment,desc(total_units)) %>%
  mutate(
    sales_share = (total_sales/sum(total_sales)*100)
  )

segment_by_category1

writexl::write_xlsx(segment_by_category1,"segment_by_category1.xlsx")

segment_by_category2 <- dt %>%
  mutate(
    customer_segment = as.factor(customer_segment),
    customer_city = as.factor(customer_city)
  ) %>%
  group_by(customer_city,customer_segment) %>%
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
    total_units = sum(quantity_sold, na.rm = TRUE)
  ) %>% arrange(desc(customer_city))
  
segment_by_category2

writexl::write_xlsx(segment_by_category2,"segment_by_category2.xlsx")



# we want to check Customer Segment Influence by Product Category,Size, and Unit Cost --------

segment_by_category  <- dt %>%
  mutate(
    customer_segment = as.factor(customer_segment)
  ) %>% group_by(customer_segment, product_category, size) %>%
  summarise(
    total_units = sum(quantity_sold, na.rm = TRUE),
    total_sales = sum(quantity_sold, na.rm = TRUE),
    avg_unit_price = mean(unit_price, na.rm = TRUE),
    avg_cost = mean(unit_cost, na.rm = TRUE),
    n_transactions = n_distinct(transaction_id),
    .groups = "drop"
  ) %>% arrange(customer_segment,desc(total_units))
  
segment_by_category




ggplot(segment_by_category, aes(x=product_category, y = total_units, fill = product_category)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~customer_segment, scales = "free_x") +
  labs(
    title = "Top Product Category by Customer Segment",
    x = "Product Category",
    y = "Total Units"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("segment_by_category.png", width = 7, height = 5, dpi = 300)





# we want to determine sales in different locations ------------

data_location <- dt %>%
  mutate(customer_city = as.factor(customer_city)) %>%
  group_by(customer_city) %>%
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
    total_units = sum(quantity_sold, na.rm = TRUE),
    n_transactions = n_distinct(transaction_id),
    .groups = "drop"
  ) %>% arrange(customer_city,desc(total_sales)) %>%
  mutate(
    sales_perc = (total_sales/sum(total_sales)) * 100
  )


ggplot(data_location, aes(x = customer_city, y = sales_perc)) +
  geom_col() +
  labs(
    title = "Customer City by Total Sales",
    x = "Cutomer City",
    y = "Total Sales"
      
  )
writexl::write_xlsx(data_location,"data_location.xlsx")  
  
ggsave("data_location.png", width = 7, height = 5, dpi = 300)



# Most preferred products in each location --------------------------------

dt_prod_location <- dt %>%
  mutate(customer_city = as.factor(customer_city)) %>%
  group_by(customer_city,product_category) %>%
  summarise(
    total_sales = sum(sales_amount, na.rm = TRUE),
    total_units = sum(quantity_sold, na.rm = TRUE),
    n_transactions = n_distinct(transaction_id),
    .groups = "drop"
  ) %>%
  mutate(
    sales_share = (total_sales/sum(total_sales))*100
  ) %>%
  arrange(customer_city, desc(total_sales))

  writexl::write_xlsx(dt_prod_location,"dt_prod_location.xlsx")

ggplot(dt_prod_location, aes(x = product_category, y = sales_share, fill = product_category)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~customer_city, scales = "free_x") +
  labs(
    title = "Product Category by Sales in every customer city",
    x = "Product Category",
    y = "Sales Share Amount"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


ggsave("dt_prod_location.png", width = 7, height = 5, dpi = 300)
















