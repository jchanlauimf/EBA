# prgGetECBData.R
#
# Retrieves data from ECB statistical data warehouse
#
# March 5, 2018

rm(list=ls())
cat("\014")

library(ecb)


# Residential Property Prices Europe ----

## Common codes  ----

codes = c(
  'AT', # Austria
  'BE', # Belgium
  'DE', # Germany
  'DK', # Denmark
  'ES', # Spain
  'FI', # Finland
  'FR', # France
  'GB', # United Kingdom
  'GR', # Greece
  'I8', # Euro area 19
  'IE', # Ireland
  'IT', # Italy
  'PT', # Portugal
  'SE'  # Sweden
)

##  Quarterly data ----

# country data starts at different dates

beg_dates = c(
  '2000-Q1', # Austria
  '2005-Q1', # Belgium
  '2003-Q1', # Germany
  '2005-Q1', # Denmark
  '2000-Q1', # Spain
  '2005-Q1', # Finland
  '2006-Q2', # France    
  '2005-Q1', # United Kingomd
  '2005-Q1', # Greece
  '2000-Q1', # Euro area 19
  '2000-Q1', # Ireland 
  '2000-Q1', # Italy
  '2000-Q1', # Portugal
  '2005-Q1'  # Sweden
)

series_code = c(
  '3', # Austria
  '4', # Belgium
  '4', # Germany
  '4', # Denmark
  '3', # Spain
  '4', # Finland
  '4', # France    
  '4', # United Kingomd
  '4', # Greece
  '3', # Euro area 19
  '3', # Ireland 
  '2', # Italy
  '5', # Portugal
  '4'  # Sweden  
)


# Prepare keys for ecb package

key_beg = "RPP.Q."
key_mid =".N.TD.00."
key_end =".00"

# Retrieve individual data frames

for (ctry in codes){
  data_name = paste("RPP",ctry,sep="_")
  key = paste(key_beg, ctry, key_mid, series_code[which(codes==ctry)], key_end, sep="")
  filter = list(startPeriod = beg_dates[which(codes==ctry)], endPeriod="2017-Q3")
  aux = get_data(key,filter)
  aux = aux[,8:9]
  colnames(aux) = c("date","value")
  assign(data_name,aux)
  if (which(codes == ctry) == 1) {
    all_data = get(data_name)}
  else{
    all_data = merge(all_data, aux, by ="date", all.x = TRUE)
  }
}
colnames(all_data) = c("dates", codes)


# Retrieve and merge individual data frames

## Annual data ----

key_beg = "RPP.A."
key_end =".N.TD.00.4.00"
filter_ann = list(startPeriod ="2000", endPeriod="2016")

for (ctry in codes){
  data_name = paste("RPP",ctry,"ann",sep="_")
  if (ctry=="I8"){
    key = "RPP.A.I8.N.TD.00.3.00"
    } else {
    key = paste(key_beg, ctry, key_end, sep="")  
    }
  aux = get_data(key,filter_ann)
  aux = aux[,8:9]
  colnames(aux) = c("date","value")
  assign(data_name,aux)
  if (which(codes == ctry) == 1) {
    all_data_ann = aux}
  else{
    all_data_ann = merge(all_data_ann, aux, by ="date", all.x = TRUE)
  }  
}
colnames(all_data_ann) = c("date", codes)
 