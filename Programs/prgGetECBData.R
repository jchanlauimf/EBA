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
  'NL', # Netherlands
  'PT', # Portugal
  'SE'  # Sweden
)

##  Quarterly data ----

# country data starts at different dates

beg_dates = c(
  "1999-Q1", #'1999-Q1', # Austria
  "1999-Q1",#'2005-Q1', # Belgium
  "1999-Q1",#'2003-Q1', # Germany
  "1999-Q1",#'2005-Q1', # Denmark
  "1999-Q1",#'2000-Q1', # Spain
  "1999-Q1",#'2005-Q1', # Finland
  "1999-Q1",#'2006-Q2', # France    
  "1999-Q1",#'2005-Q1', # United Kingomd
  "1999-Q1",#'2005-Q1', # Greece
  "1999-Q1",#'2000-Q1', # Euro area 19
  "1999-Q1",#'2000-Q1', # Ireland 
  "1999-Q1",#'2000-Q1', # Italy
  "1999-Q1",#'2000-Q1', # Netherlands
  "1999-Q1",#'2000-Q1', # Portugal
  "1999-Q1"#'2005-Q1'  # Sweden
)

# ---------------------------------------------
# Codes for quarterly series of property prices

#   RPP.Q.*.N.TD.00.3.00 (AT,IE,ES,GB) 
#   RPP.Q.*.N.ED.00.2.00(BE,SI) 
#   RPP.Q.*.N.EF.LC.1.00(BG,HR,PL,RO) 
#   RPP.Q.*.N.TD.00.2.00(CY,IT,LT,MT) 
#   RPP.Q.*.N.EF.00.1.00(CZ) 
#   RPP.Q.*.N.TH.00.1.00(DK) 
#   RPP.Q.*.N.TF.00.1.00(EE,LU) 
#   RPP.Q.*.N.ED.00.3.00(FI,NL) 
#   RPP.Q.*.N.ED.00.1.00(FR,SE) 
#   RPP.Q.*.N.TD.00.5.00(DE) 
#   RPP.Q.*.N.TF.00.3.00(GR) 
#   RPP.Q.*.N.ED.CC.1.00 (HU) 
#   RPP.Q.*.N.TD.00.1.00(LV,SK) 
#   RPP.Q.*.N.TD.00.4.00 (PT)


series_code = c(
  '.N.TD.00.3.00', # Austria
  '.N.ED.00.2.00', # Belgium  2 in excel file
  '.N.TD.00.5.00', # Germany
  '.N.TH.00.1.00', # Denmark  1
  '.N.TD.00.3.00', # Spain
  '.N.TD.00.4.00', # Finland
  '.N.ED.00.1.00', # France    
  '.N.TD.00.4.00', # United Kingdom
  '.N.TF.00.3.00', # Greece
  '.N.TD.00.3.00', # Euro area 19
  '.N.TD.00.3.00', # Ireland 
  '.N.TD.00.2.00', # Italy  2
  '.N.ED.00.1.00', # Netherlands      
  '.N.TD.00.5.00', # Portugal
  '.N.ED.00.1.00'  # Sweden  
)

# Prepare keys for ecb package

key_beg = "RPP.Q."

# Retrieve individual data frames

for (ctry in codes){
  data_name = paste("RPP",ctry,sep="_")
  key = paste(key_beg, ctry,series_code[which(codes==ctry)],sep="")
  filter = list(startPeriod = beg_dates[which(codes==ctry)], endPeriod="2017-Q4")
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

key = "CPP.Q.I8.N.TH.TVAL.TP.3.INX"
filter = list(startPeriod="2000-Q1", endPeriod="2017-Q3")
CPP = get_data(key,filter)
all_data$CPP = CPP[,10]

# Retrieve and merge individual data frames

## Annual data ----

key_beg = "RPP.A."
key_end =".N.TD.00.4.00"
filter_ann = list(startPeriod ="1999", endPeriod="2016")

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

# Save the files

library(xlsx)

# Calculate quarterly growth rate
rpp_q = as.matrix(all_data[,2:dim(all_data)[2]])
rpp_grow = 100*rpp_q[2:dim(rpp_q)[1],]/rpp_q[1:dim(rpp_q)[1]-1,]-100
rpp_grow = rbind(rep(NA, dim(rpp_grow)[2]), rpp_grow)
rpp_grow = data.frame(all_data$dates, rpp_grow)
colnames(rpp_grow)[1] = "dates"

date_q = lapply(rpp_grow[1], 
                function(x) as.Date(as.yearqtr(gsub("-","",x)), frac=1))

year_v = rep(seq(2000,2017,1), each=12)
meses  = rep(seq(1,12,1),length(seq(2000,2017,1)))
date_m = mapply(function(x,y) 
  as.Date(as.yearmon(paste(x,y,sep="-")), frac=1), x=year_v, y=meses)
date_m = as.Date(date_m)
df_month = data.frame(date_m)
colnames(df_month)[1]="date"

df_qtr_lvl = data.frame(date_q, all_data[,2:dim(all_data)[2]])
df_qtr_grw = data.frame(date_q, rpp_grow[,2:dim(rpp_grow)[2]])
colnames(df_qtr_lvl)[1]="date"
colnames(df_qtr_grw)[1]="date"

data_month_lvl = merge(x=df_month, y=df_qtr_lvl, by.y="date", all.x=T)
data_month_grw = merge(x=df_month, y=df_qtr_grw, by.y="date", all.x=T)

filename="rpp.xlsx"
wb = createWorkbook(type="xlsx")
level = createSheet(wb, sheetName="Level")
grwth = createSheet(wb, sheetName="Growth")
level_m = createSheet(wb, sheetName="Level_m")
grwth_m = createSheet(wb, sheetName="Growth_m")

addDataFrame(all_data, level, startRow=1, row.names=FALSE)
addDataFrame(rpp_grow, grwth, startRow=1, row.names=FALSE)
addDataFrame(data_month_lvl, level_m, startRow=1, row.names=FALSE)
addDataFrame(data_month_grw, grwth_m, startRow=1, row.names=FALSE)

saveWorkbook(wb, filename)  

# create dates







 