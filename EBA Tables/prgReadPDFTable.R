# **********************************************
#
# prgReadPDFTable.R
# -----------------
# Read EBA 2018 stress test tables
# and create baseline and adverse scenarios
#
# Notes:
#
# 1. Run prgBuDATraining.R first to create training scenarios
# 2. Program will read the training scenarios to fill 2017Q4 data
# 

# Load libraries ----
rm(list=ls())
cat("\014")

library(tabulizer)  # use to read pdf tables
library(xlsx)       # use to create testing files

setwd("D:/Github Projects/EBA")

# internal directories

table_dir = "./EBA Tables/"
test_dir = "./Testing/"
internal_dir = "./Internal Macros/"


# Information about tables, variables, countries and ctry codes ----

list_tables = c(
  "EBA_GDP.pdf",
  "EBA_UEMP.pdf",
  "EBA_CPI.pdf",
  "EBA_RPP.pdf",
  "EBA_LTRates.pdf",
  "EBA_STOCK.pdf",
  "EBA_SWAPS.pdf",
  "EBA_OIL.pdf"
)

list_var = c(
  "GDP", "UEMP", "CPI", "RPP", "LTRates", 
  "STOCK", "SWAPS", "OIL"
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


# Read PDF tables  ----

for (the_var in list_var){
  idx = which(list_var == the_var)
  file_name = paste(table_dir,list_tables[idx], sep="")
  assign(the_var,extract_tables(file_name))
  if (idx!=8){
    assign(the_var, get(the_var)[[1]])
  } else {
    assign("EURUSD", get(the_var)[[1]])
    assign("OIL", get(the_var)[[2]])
  }
}

# Create baseline and adverse scenarios ----

## Preliminary information for data frames

year = c('2017',rep('2018',4), rep('2019',4), rep('2020',4))
qtr  = c(4,rep(seq(1,4,1),3))
col_names = c("year","quarter","GDP","UEMP","CPI", "LTRate",
              "EURUSD","WTI","RPP")
oil_adv = as.numeric(strsplit(OIL[3,2]," ")[[1]])

for (ctry in ctry_names){

  ctry_bse = paste("bse_",ctry,sep="")
  ctry_adv = paste("adv_",ctry,sep="")
  
  # Extract base and adverse scenarios
  idx = which(GDP[,1]==ctry)
  gdp_bse = as.numeric(strsplit(GDP[idx,2]," ")[[1]])
  gdp_adv = as.numeric(strsplit(GDP[idx,4]," ")[[1]])
  
  idx = which(UEMP[,1]==ctry)
  emp_bse = as.numeric(strsplit(UEMP[idx,2]," ")[[1]])
  emp_adv = as.numeric(strsplit(UEMP[idx,4]," ")[[1]])
  
  idx = which(CPI[,1]==ctry)
  cpi_bse = as.numeric(strsplit(CPI[idx,2]," ")[[1]])
  cpi_adv = as.numeric(strsplit(CPI[idx,4]," ")[[1]])
  
  idx = which(LTRates[,1]==ctry)
  ltr_cur = as.numeric(strsplit(LTRates[idx,2]," ")[[1]])
  ltr_bse = as.numeric(strsplit(LTRates[idx,3]," ")[[1]])
  ltr_adv = as.numeric(strsplit(LTRates[idx,5]," ")[[1]])
  
  idx = which(RPP[,1]==ctry)
  rpp_bse = as.numeric(strsplit(RPP[idx,2]," ")[[1]])
  rpp_adv = as.numeric(strsplit(RPP[idx,4]," ")[[1]])

  # create data frame for each scenario
  gdp = array(NA, dim=c(13,1))
  emp = array(NA, dim=c(13,1))
  cpi = array(NA, dim=c(13,1))
  ltr = array(NA, dim=c(13,1))
  eur = array(NA, dim=c(13,1))    
  wti = array(NA, dim=c(13,1))
  rpp = array(NA, dim=c(13,1))
  
  idx_ann = seq(2,13,4)+3
  
  gdp[idx_ann] = gdp_bse
  emp[idx_ann] = emp_bse - emp_bse[1]   # change in unemployment
  cpi[idx_ann] = cpi_bse
  ltr[idx_ann] = ltr_bse - ltr_cur      # change in rates
  eur[idx_ann] = c(0.0,0.0,0.0)         # no change in EUR USD
  wti[idx_ann] = c(0.0,0.0,0.0)
  rpp[idx_ann] = rpp_bse              
  
  df_base = data.frame(year,qtr, gdp, emp, cpi, ltr, eur, wti, rpp)
  colnames(df_base) = col_names
  
  assign(ctry_bse,df_base)
  
  gdp = array(NA, dim=c(13,1))
  emp = array(NA, dim=c(13,1))
  cpi = array(NA, dim=c(13,1))
  ltr = array(NA, dim=c(13,1))
  eur = array(NA, dim=c(13,1))    
  wti = array(NA, dim=c(13,1))
  rpp = array(NA, dim=c(13,1))
  
  idx_ann = seq(2,13,4)+3
  
  gdp[idx_ann] = gdp_adv
  emp[idx_ann] = emp_adv - emp_bse[1]   # change in unemployment
  cpi[idx_ann] = cpi_adv
  ltr[idx_ann] = ltr_adv - ltr_cur      # change in rates
  eur[idx_ann] = c(0.0,0.0,0.0)         # no change in EUR USD
  wti[idx_ann] = oil_adv
  rpp[idx_ann] = rpp_adv              
  
  df_base = data.frame(year,qtr, gdp, emp, cpi, ltr, eur, wti, rpp)
  colnames(df_base) = col_names
  
  assign(ctry_adv,df_base)
  
}

# Create user-based macro scenarios ----

## header in Test sheets
header= c(
  'Austria',
  '',
  'This frequency provides the information whether the testing macro-economic scenarios used are reported on a quarterly basis or a yearly basis.',
  'The value "0" means "Quarterly"; and the value "-1" means "Yearly".',
  'If it is on a yearly basis, the projection data should be reported in Quarter 4 while blank need be reported in Quarter 1,2,3',
  'Please keep the title of the macros same as in training file.',
  'Please do not annualize the QoQ growth rates.', 
  'Frequency'
)

# Frequency = annual
freq_data = array(rep(-1,7), dim=c(1,7))

if (!file.exists(test_dir)){
  dir.create(test_dir)
}

for (ctry in ctry_names){
  idx = which(ctry_names == ctry)
  code= ctry_codes[idx]
  header[1] = ctry
  filename = paste(test_dir,"macro_",code,"_test.xlsx","")
  filename = gsub(" ","",filename)
  wb = createWorkbook(type="xlsx")

  Test1 = createSheet(wb, sheetName="Test 1") 
  addDataFrame(header, Test1, startRow=1,startColumn=1,
               row.names=FALSE, col.names=FALSE)
  addDataFrame(freq_data, Test1, startRow=8, startColumn=3,
               row.names=FALSE, col.names=FALSE)
  bse_name = paste("bse_",ctry,sep="")
  scenario= get(bse_name)
  addDataFrame(scenario, Test1, startRow=10, startColumn=1, 
               row.names=FALSE)
  
  
  Test2 = createSheet(wb, sheetName="Test 2")
  addDataFrame(header, Test2, startRow=1,startColumn=1,
               row.names=FALSE, col.names=FALSE)
  addDataFrame(freq_data, Test2, startRow=8, startColumn=3,
               row.names=FALSE, col.names=FALSE)
  adv_name = paste("adv_",ctry,sep="")
  scenario= get(adv_name)
  addDataFrame(scenario, Test2, startRow=10, startColumn=1, 
               row.names=FALSE)
  
    saveWorkbook(wb, filename)
}

# Stock and interest rates projections----

swap_cur = as.numeric(SWAPS[8,3])
swap_bse = as.numeric(strsplit(SWAPS[8,4]," ")[[1]]) 
swap_adv = as.numeric(strsplit(SWAPS[8,6]," ")[[1]]) 



#----


