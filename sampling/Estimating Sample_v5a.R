# Clear the environment
rm(list = ls())

# Load the libraries
library(readxl)
library(dplyr)
library(writexl)




file_path <-
  "C:/Users/ckarani/Geopoll Dropbox/Account Management - ops/UNDP AI/6. Sample/CAPI/Working"


# Load the Excel data (assuming sheet name is "LLG_Data")
llg_data <- read_excel("Census Data_PNG.xlsx", sheet = "LLG_Data")

# Step 2: Exclude Provinces with security risks (AROB, Hela,Southern Highlands and Enga)
llg_data <- llg_data %>%
  filter(!province %in% c("Autonomus Region of Bougainville", "Hela", "Enga","Southern Highlands"))



# Step 3: Exclude LLGs with remoteness
llg_data <- llg_data %>%
  filter(!llg %in% c("Karimui", "Lumusa", "Tabibuga", "Kotte", "Selepet", "Nanima Kariba", 
                     "Siassi", "Nayudo", "West Wapei", "Goodenough Island", "Kiriwina", 
                     "Tapini", "Lelemadih/Bupichupeu", "Nigoherm", "Pobuma", "Upper asaro", 
                     "Lamari", "Kup"))



# View the structure of the loaded data
head(llg_data)


# Step 3: Select specific provinces from each region
selected_provinces <- c(
  "Eastern Highlands Province",  # Replace with actual province names
  "Chimbu Province", 
  "Western Highlands Province", 
  "Morobe Province", 
  "East Sepik Province", 
  "East New Britain Province", 
  "West New Britain Province", 
  "Milne Bay Province", 
  "National Capital District"
)


# Filter the dataset to include only the selected provinces
llg_data <- llg_data %>%
  filter(province %in% selected_provinces)

#  Define the total number of households and their distribution by region
total_households <- 1000
household_counts <- c(
  Highlands = round(total_households * 0.39),           # 39%
  Momase = round(total_households * 0.26),               # 26%
  New_Guinea_Islands = round(total_households * 0.15),   # 15%
  Southern = round(total_households * 0.20)               # 20%
)


# Step 5: Sample LLGs (SSUs) based on the selected provinces
llgs_sampled <- data.frame()

for (province in selected_provinces) {
  region_data <- llg_data %>% filter(province == !!province)
  
  if (nrow(region_data) > 0) {
    # Sample LLGs based on available data
    sampled_llgs <- region_data %>%
      sample_n(size = 12, replace = TRUE)  # Sample a fixed number of LLGs
    llgs_sampled <- bind_rows(llgs_sampled, sampled_llgs)
  }
}

# Ensure we have unique LLGs
llgs_sampled <- llgs_sampled %>%
  distinct(llg, .keep_all = TRUE)


# Step 6: Sample households from each sampled LLG according to the region proportions
households_sampled <- data.frame()

for (region in names(household_counts)) {
  region_llgs <- llgs_sampled %>%
    filter(province %in% selected_provinces)  # Adjust filtering based on your structure
  
  num_households_region <- household_counts[region]
  
  if (nrow(region_llgs) > 0 && num_households_region > 0) {
    # Sample households from the LLGs within the region
    sampled_households <- region_llgs %>%
      group_by(province, llg) %>%
      do(data.frame(household_id = 1:num_households_region)) %>%
      ungroup()
    
    households_sampled <- bind_rows(households_sampled, sampled_households)
  }
}


# Ensure the total households is exactly 1000
if (nrow(households_sampled) < total_households) {
  additional_needed <- total_households - nrow(households_sampled)
  additional_households <- households_sampled %>%
    sample_n(additional_needed, replace = TRUE)
  
  households_sampled <- bind_rows(households_sampled, additional_households)
} else if (nrow(households_sampled) > total_households) {
  households_sampled <- households_sampled %>%
    sample_n(total_households, replace = FALSE)
}

# Check the total number of households sampled
num_households_sampled <- nrow(households_sampled)
print(num_households_sampled)  # Should be 1000




# Calculate the number of rural (86%) and urban (14%) households
num_rural <- round(num_households_sampled * 0.88)
num_urban <- num_households_sampled - num_rural

# Assign rural/urban status to the households
households_sampled$rural_urban <- sample(c(rep("Rural", num_rural), 
                                           rep("Urban", num_urban)),
                                         num_households_sampled, replace = FALSE)

# View the rural/urban classification distribution
table(households_sampled$rural_urban)

# Write the final sample to an Excel file
writexl::write_xlsx(households_sampled, "households_sampled_v1a.xlsx")










































# Step 4: Sample LLGs (SSUs) based on the selected provinces
total_llgs <- 84
llgs_sampled <- data.frame()

while (nrow(llgs_sampled) < total_llgs) {
  new_sample <- llg_data %>%
    sample_n(size = total_llgs - nrow(llgs_sampled), weight = population, replace = TRUE)
  
  llgs_sampled <- bind_rows(llgs_sampled, new_sample)
  
  # Ensure we keep only unique LLGs
  llgs_sampled <- llgs_sampled %>%
    distinct(llg, .keep_all = TRUE)
}



# Trim to exactly 84 LLGs if necessary
llgs_sampled <- llgs_sampled %>%
  head(total_llgs)

# View the sampled LLGs
head(llgs_sampled)


# Step 5: Sample households from each sampled LLG
total_households <- 1000
households_sampled <- llgs_sampled %>%
  group_by(province, llg) %>%
  do(data.frame(household_id = 1:12)) %>%
  ungroup()

# Ensure total households equals 1000
num_households_sampled <- nrow(households_sampled)

if (num_households_sampled < total_households) {
  additional_needed <- total_households - num_households_sampled
  additional_households <- households_sampled %>%
    sample_n(additional_needed, replace = TRUE)
  
  households_sampled <- bind_rows(households_sampled, additional_households)
}


# If we have more than 1000 households, randomly sample down to 1000
if (num_households_sampled > total_households) {
  households_sampled <- households_sampled %>%
    sample_n(total_households, replace = FALSE)
}




# Check the total number of households sampled
num_households_sampled <- nrow(households_sampled)
print(num_households_sampled)  # Should be 1000

# Calculate the number of rural (86%) and urban (14%) households
num_rural <- round(num_households_sampled * 0.88)
num_urban <- num_households_sampled - num_rural

# Assign rural/urban status to the households
households_sampled$rural_urban <- sample(c(rep("Rural", num_rural), 
                                           rep("Urban", num_urban)),
                                         num_households_sampled, replace = FALSE)

# View the rural/urban classification distribution
table(households_sampled$rural_urban)

# Write the final sample to an Excel file
writexl::write_xlsx(households_sampled, "households_sampled_20241031.xlsx")


