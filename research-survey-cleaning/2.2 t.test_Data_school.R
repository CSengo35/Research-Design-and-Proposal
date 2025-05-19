# Clear the environment ---------------------------------------------------
rm(list = ls())


# loading packages --------------------------------------------------------



pkg <- "pacman"


for (x in "pacman") {
  if (!is.element(x, installed.packages()[, 1]))
  {
    install.packages(x, repos = "https://cloud.r-project.org/")
  } else {
    print(paste(x, " library already installed"))
  }
}

pacman::p_load(
  "openxlsx",
  "haven",
  "readxl",
  "dplyr",
  "tidyr",
  "foreign",
  "dplyr",
  "purrr",
  "stringi",
  "forcats",
  "labelled",
  "openxlsx",
  "devtools",
  "janitor",
  "hms",
  "data.table",
  "lubridate",
  "purrr",
  "httr"
) 


# The average score nationally is 75. We would like to know if the average score of our class is significantly different from that of the national--------

#Ho:mean score = 75
#H1:mean score != 75

setwd("C:/Users/ckarani/OneDrive - GeoPoll/Desktop/Christine Karani/Christine/Learning/Predictive Analysis")

dt <- readxl::read_xlsx("../Predictive Analysis/Data_school.xlsx")

maths_score <- as.numeric(dt$Maths)

t.test(maths_score, mu=75)


sci_score <- as.numeric(dt$Science)
t.test(sci_score, mu=75)



