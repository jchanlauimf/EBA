# EBA
### March 2018
---
## Contents

Repository stores data, programs, and results for bottom-up analysis of the default risk of European banks under the baseline and adverse scenarios of the 2018 EU-wide stress tests designed by the European Banking Authority (EBA).

Banks analyzed are headquartered in the following countries:

 |Country (code)      |                |                |                     |
 |:------------------:|:--------------:|:--------------:|:-------------------:|
 |Austria (23)        | Belgium (25)   | Finland (36)   | France (37)         |         
 |Germany (38)        | Greece (40)    | Ireland (45)   | Italy (47)          |          
 |The Netherlands (64)| Portugal (70)  | Spain (89)     | United Kingdom (89) | 

### Analytical Engine

- The default analysis was performed using the `Matlab`-based tool *BuDA: A Bottom-Up Default Analysis Framework, version 2.0, Octover 2010, 2017 release*, developed by J.-C. Duan, W. Miao, J.A. Chan-Lau, and the Credit Research Initiative Team of the National University of Singapore.

- Data, scripts, and programs used the following software:
  - `Matlab` 2017b
  - `R` version 3.4.3
  - `RStudio` version 1.1.423
  - `LibreOffice Calc` version 6.0.1.1 (x64)
  - `Microsoft Office 365` version 1708

### Data files

- `EBA Data.xlsx`
   Main data file. Retrieves macroeconomic and financial time series from Thomson-Reuters. The main series used in the analysis are national time series of the following variables, except for the 3-month EURIBOR rate:

      - Real GDP (quarterly)
      - Unemployment (monthly)
      - CPI (quarterly)
      - Long term interest rates (10-year government bonds, monthly)
      - EURUSD (monthly)
      - Oil prices (WTI, monthly)
      - Stock price returns (National stock index)
      - 3-month EURIBOR rate

- `rpp.xlsx`
   Residential property prices, quarterly series. Data retrieved from the European Central Bank (ECB) Statistical Data Warehouse (SDW); and file produced using the `R` script `prgGetECBData.R`.

- *EBA Tables* directory
   This directory contains separate Acrobat files describing baseline and adverse scenarios assumptions for each country. Data retrieved using the `R` script `prgReadPDFTable.R`.

- *Testing* directory
   The directory stores the user-supplied macro scenario `xlsx` files needed to run BuDA. Files prepared using the `R` script `prgReadPDFTable.R`.

- *Training* directory
   The directory contains the `CSV`files used to train the *BuDA* models for each country. Files prepared using the `R` script `prgBuDATraining.R`.

- *Internal Macros* directory
   The internal macros directory contains the `xlsx` files with the scenario projections for stock index returns and the 3-month EURIBOR rate. Files prepared using the `R` script `prgReadPDFTable.R`.

### Program files

Programs should be run sequentially:

- `prgGetECBData.R`
   Uses routines in CRAN package `ecb` to retrieve residential property prices directly from the ECB SWD and creates the `rpp.xlsx` file. Access to the SWD may be intermittent and retrieving the data may require running the script several times.

- `prgBuDATraining.R`
   Prepares the training files using data from the files `EBA Data.xlsx`  and `rpp.xlsx`, and stores them in the training directory.

- `prgReadPDFTable.R`
   Scrapes scenario information from PDF document, *Adverse macro-financial scenario for the 2018 EU-wide banking sector stress test*, European Systemic Risk Board (ESRB), January 16, 2018. Once it reads the data, it combines it with data from the testing scenarios to create the user-based macro scenarios and the internal macro-scenarios. The scenarios are stored in the *Testing* and *Internal Macros* directories respectively.

