## R code for compiling data requests:
#
## Data requested: LW SRVY and WQ
# Live counts, dead counts
#
## Set up ----
folder_name <- "2026_01_Fisher UFL LW Survey"
EstuaryCode <- c("LW")
start_date <- as.Date("2005-01-01")
end_date <- as.Date("2025-12-31")
Database <- "Oysters_25-12-22"
Server <- "localhost\\ERICALOCALSQL"

#
## packages
if (!require("pacman")) {install.packages("pacman")}
pacman::p_load(tidyverse,
               odbc,
               DBI, 
               dbplyr, 
               lubridate)
#
# 
## Database connection ----
con <- dbConnect(odbc(),
                 Driver = "SQL Server", 
                 Server = Server,
                 Database = Database,
                 Authentication = "ActiveDirectoryIntegrated")

dboFixedLocations <- tbl(con,in_schema("dbo", "FixedLocations")) %>% 
  filter(Estuary %in% EstuaryCode)%>%
  collect() 

hsdbTripInfo <- tbl(con,in_schema("hsdb", "TripInfo")) %>%
  filter(substring(TripID,1,2) %in% EstuaryCode & 
           TripDate >= start_date & 
           TripDate <= end_date & 
           substring(TripID,3,6) == "SRVY") %>%
  collect() 

dboTripInfo <- tbl(con,in_schema("dbo", "TripInfo")) %>%
  filter(substring(TripID,1,2) %in% EstuaryCode & 
           TripDate >= start_date & 
           TripDate <= end_date & 
           substring(TripID,3,6) == "SRVY" & 
           DataStatus == "Proofed") %>%
  collect() 

hsdbSampleEvent <- tbl(con,in_schema("hsdb", "SampleEvent")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      substring(SampleEventID,3,6) == "SRVY") %>%
  collect() 

dboSampleEvent <- tbl(con,in_schema("dbo", "SampleEvent")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      substring(SampleEventID,3,6) == "SRVY" & 
      DataStatus == "Proofed") %>%
  collect() 

hsdbSampleEventWQ <- tbl(con,in_schema("hsdb", "SampleEventWQ")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventWQID, 8, 15)),
    FixedLocationID = substring(SampleEventWQID, 19, 22)) %>%
  filter(
    substring(SampleEventWQID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      substring(SampleEventWQID,3,6) == "SRVY") %>%
  collect() 

dboSampleEventWQ <- tbl(con,in_schema("dbo", "SampleEventWQ")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventWQID, 8, 15)),
    FixedLocationID = substring(SampleEventWQID, 19, 22)) %>%
  filter(
    substring(SampleEventWQID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      substring(SampleEventWQID,3,6) == "SRVY" & 
      DataStatus == "Proofed")  %>%
  collect() 

hsdbSurveyQuadrat <- tbl(con,in_schema("hsdb", "SurveyQuadrat")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(QuadratID, 19, 22)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      substring(SampleEventID,3,6) == "SRVY") %>%
  collect() 

dboSurveyQuadrat <- tbl(con,in_schema("dbo", "SurveyQuadrat")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(QuadratID, 19, 22)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      substring(SampleEventID,3,6) == "SRVY" & 
      DataStatus == "Proofed")  %>%
  collect()

DBI::dbDisconnect(con)
#
#
#
## Data cleaning for output ----
#
# Function to subset to desired columns:
subset_columns <- function(df, cols) {
  df %>%
    mutate(across(setdiff(cols, names(.)), ~ NA)) %>%  # add missing
    select(all_of(cols))
}
#
## Trip info
Trip_columns <- c("TripID", "TripDate", "Comments", "DataStatus", "DateProofed", "DateCompleted")
 
hsdbTripInfo_sub <- hsdbTripInfo %>% subset_columns(Trip_columns)
dboTripInfo_sub  <- dboTripInfo  %>% subset_columns(Trip_columns)

TripInfo <- bind_rows(hsdbTripInfo_sub, dboTripInfo_sub)
rm(hsdbTripInfo, dboTripInfo, hsdbTripInfo_sub, dboTripInfo_sub)
#
#
## SampleEvent
SE_columns <- c("SampleEventID", "TripID", "FixedLocationID", "TripDate", "Comments", "DataStatus", "DateProofed", "DateCompleted")

hsdbSampleEvent_sub <- hsdbSampleEvent %>% subset_columns(SE_columns)
dboSampleEvent_sub  <- dboSampleEvent  %>% subset_columns(SE_columns)

SampleEvent <- bind_rows(hsdbSampleEvent_sub, dboSampleEvent_sub)
rm(hsdbSampleEvent, dboSampleEvent, hsdbSampleEvent_sub, dboSampleEvent_sub)
#
#
## SampleEvent Water Quality
SEWQ_columns <- c("SampleEventWQID", "SampleEventID", "TripDate", "FixedLocationID", "Temperature", "Salinity", "DissolvedOxygen", "pH", "Depth", "SampleDepth", "Secchi", "CollectionTime", "YSICalibration", "DataStatus", "DateProofed", "DateCompleted")

hsdbSampleEventWQ_sub <- hsdbSampleEventWQ %>% subset_columns(SEWQ_columns)
dboSampleEventWQ_sub  <- dboSampleEventWQ  %>% subset_columns(SEWQ_columns)

SampleEventWQ <- bind_rows(hsdbSampleEventWQ_sub, dboSampleEventWQ_sub)
rm(hsdbSampleEventWQ, dboSampleEventWQ, hsdbSampleEventWQ_sub, dboSampleEventWQ_sub)
#
#
## Survey counts
Srvy_columns <- c("QuadratID", "SampleEventID", "TripDate", "FixedLocationID", "QuadratNumber", "NumLive", "NumDead", "Comments", "DataStatus", "DateProofed", "DateCompleted")

hsdbSurveyQuadrat_sub <- hsdbSurveyQuadrat %>% subset_columns(Srvy_columns)
dboSurveyQuadrat_sub  <- dboSurveyQuadrat  %>% subset_columns(Srvy_columns)

SurveyQuads <- bind_rows(hsdbSampleEventWQ_sub, dboSampleEventWQ_sub)
rm(hsdbSurveyQuadrat, dboSurveyQuadrat, hsdbSurveyQuadrat_sub, dboSurveyQuadrat_sub)
