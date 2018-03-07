# ********************************************
# prgBuDATraining.R
#
# Prepares training files for EBA stress test
# Files saved as User_macro_XX.csv
# Stil need to provide the data type
#
# Author: Jorge A. Chan-Lau
# Date: March 6, 2018
# ********************************************

# Clean memory and console
rm(list=ls())
cat("\014")

# Load tidyverse library

library(tidyverse)
library(readxl)


# Macro financial data stored in EBA Data.xlsx

filename = "EBA Data.xlsx"
sheets = c('GDP', "UEMP", "CPI", "LTRate","Other")

for (this_sheet in sheets){
  sheet_name = paste("Data_", this_sheet, sep="")
  df_name = paste("df_", this_sheet, sep="")
  aux_df = read_excel(filename,sheet_name)
  colnames(aux_df)[1] = "date"
  assign(df_name,aux_df)
}

# Residential property prices data, annual data

filename = "rppA.xlsx"
sheet = "data_RPP"

df_RPPa = read_excel(filename,sheet)

filename = "rppQ.xlsx"
sheet = "data_RPPQ"
df_RPPq = read_excel(filename,sheet)

# country codes for BuDA user-specified macro training files
# number of countries = 14, excluding EU and Eurozone
# last two countries 

ctry_codes = c(
  "23", # Austria
  "25", # Belgium
  "DK", # Denmark
  "36", # Finland
  "37", # France
  "38", # Germany
  "40", # Greece
  "45", # Ireland
  "47", # Italy
  "64", # Netherlands
  "70", # Portugal
  "79", # Spain
  "SE", # Sweden
  "89"  # United Kingdom
  )

ctry_names = c(
  "Austria",
  "Belgium",
  "Denmark",
  "Finland",
  "France",
  "Germany",
  "Greece",
  "Ireland",
  "Italy",
  "Netherlands",
  "Portugal",
  "Spain",
  "Sweden",
  "United Kingdom"
)

name_prefix = "User_macro_"
nctry = length(ctry_codes)

# The for loop:
# . merges the different data frames in this order
#   GDP, UEMP, CPI, LTRates
# . creates the csv files


# get header from generic file and modify 

header_from_file = "User_macro_9.csv"
header_csv = readLines(header_from_file, n=13)
header_csv[8]="Frequency, ,0,1,1,1,1,1,-1"
header_csv[12]="Macro Type, ,-1,-1,-1,-1,-1,-1,-1"

# Create directory for trainin gfiles
train_dir = "Training"
main_dir = getwd()

if (file.exists(train_dir)){
  setwd(file.path(main_dir,train_dir))
} else {
  dir.create(file.path(main_dir,train_dir))
  setwd(file.path(main_dir,train_dir))
}

for (ctry in ctry_names){
  # Select variables, using annual residential property prices
  year  = select(df_GDP, Year)
  month = select(df_GDP, Month)
  GDP   = select(df_GDP, ctry)
  UEMP  = select(df_UEMP, ctry)
  CPI   = select(df_CPI, ctry)
  LTRate= select(df_LTRate, ctry)
  RPP   = select(df_RPPa, ctry)
  
  the_df= data.frame(year, month, GDP, UEMP, CPI, LTRate, select(df_Other, EURUSD, WTI), RPP)
  colnames(the_df) = c("year", "month", "GDP", "UEMP", "CPI", "LTRate", "EURUSD", "WTI", "RPP")
  idx = which(ctry_names == ctry)  # index to select ctry_codes
  df_name = paste(name_prefix,ctry_codes[idx],sep="")
  assign(df_name, the_df)
  csv_name = paste(name_prefix, ctry_codes[idx],".csv", sep="")
  
  # Write header to file
  header_csv[1] = ctry # assign country name
  write(header_csv, csv_name)
  write_csv(the_df, csv_name, na=" ", append=TRUE, col_names=TRUE)
}
setwd(main_dir)

  


