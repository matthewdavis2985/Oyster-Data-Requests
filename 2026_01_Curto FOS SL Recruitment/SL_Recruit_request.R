## R code for compiling data requests:
#
## Data requested: SL RCRT and WQ
#
## Set up ----
folder_name <- "2026_01_Curto FOS SL Recruitment"
file_name <-"SL_Recruit_WQ_2020_2025.xlsx"
EstuaryCode <- c("SL")
start_date <- as.Date("2020-01-01")
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
               lubridate,
               openxlsx)
#
get_metadata <- function(con, tables = NULL) {
  
  # ---- column structure & types ----
  cols <- tbl(con, in_schema("INFORMATION_SCHEMA", "COLUMNS")) %>%
    select(
      TABLE_SCHEMA,
      TABLE_NAME,
      COLUMN_NAME,
      DATA_TYPE,
      ORDINAL_POSITION
    )
  
  # ---- column descriptions (SQL Server specific) ----
  descriptions <- tbl(con, in_schema("sys", "columns")) %>%
    rename(COLUMN_NAME = name) %>%
    inner_join(
      tbl(con, in_schema("sys", "tables")) %>%
        rename(TABLE_NAME = name),
      by = "object_id"
    ) %>%
    inner_join(
      tbl(con, in_schema("sys", "schemas")) %>%
        rename(TABLE_SCHEMA = name),
      by = "schema_id"
    ) %>%
    left_join(
      tbl(con, in_schema("sys", "extended_properties")) %>%
        filter(name == "MS_Description"),
      by = c(
        "object_id" = "major_id",
        "column_id" = "minor_id"
      )
    ) %>%
    select(
      TABLE_SCHEMA,
      TABLE_NAME,
      COLUMN_NAME,
      DESCRIPTION = value
    )
  
  # ---- optionally limit to specific tables ----
  if (!is.null(tables)) {
    tables <- tables %>%
      select(TABLE_SCHEMA, TABLE_NAME)
    
    tables_sql <- copy_to(con, tables, overwrite = TRUE)
    
    cols <- cols %>%
      inner_join(
        tables_sql,
        by = c("TABLE_SCHEMA", "TABLE_NAME")
      )
    
    descriptions <- descriptions %>%
      inner_join(
        tables_sql,
        by = c("TABLE_SCHEMA", "TABLE_NAME")
      )
  }
  
  # ---- combine & return ----
  cols %>%
    left_join(
      descriptions,
      by = c("TABLE_SCHEMA", "TABLE_NAME", "COLUMN_NAME")
    ) %>%
    arrange(TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION) %>%
    select(
      TABLE_SCHEMA,
      TABLE_NAME,
      COLUMN_NAME,
      DATA_TYPE,
      DESCRIPTION
    ) %>%
    collect()
}
# 
## Database connection ----
con <- dbConnect(odbc(),
                 Driver = "SQL Server", 
                 Server = Server,
                 Database = Database,
                 Authentication = "ActiveDirectoryIntegrated")

tables <- tibble::tribble(
  ~TABLE_SCHEMA, ~TABLE_NAME,
  "dbo", "FixedLocations",
  "dbo",  "TripInfo",
  "hsdb", "SampleEvent",
  "dbo", "SampleEvent",
  "hsdb", "SampleEventWQ",
  "dbo", "SampleEventWQ",
  "hsdb", "Recruitment",
  "dbo", "Recruitment"
)

metadata <- get_metadata(con, tables)

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
      TripDate <= end_date) %>%
  collect() 

dboSampleEventWQ <- tbl(con,in_schema("dbo", "SampleEventWQ")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventWQID, 8, 15)),
    FixedLocationID = substring(SampleEventWQID, 19, 22)) %>%
  filter(
    substring(SampleEventWQID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      DataStatus == "Proofed")  %>%
  collect() 

hsdbRecruitment <- tbl(con,in_schema("hsdb", "Recruitment")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(ShellID, 19, 22)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date) %>%
  collect() 

dboRecruitment <- tbl(con,in_schema("dbo", "Recruitment")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(ShellID, 19, 22)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date &  
      DataStatus == "Proofed")  %>%
  collect()

DBI::dbDisconnect(con)
#
#
#
## Data combination and selection ----
#
# Function to subset to desired columns:
subset_columns <- function(df, cols) {
  df %>%
    mutate(across(setdiff(cols, names(.)), ~ NA)) %>%  # add missing
    select(all_of(cols))
}
#
## Trip info
Trip_columns <- c("TripID", "TripDate", "Comments")

hsdbTripInfo_sub <- hsdbTripInfo %>% subset_columns(Trip_columns)
dboTripInfo_sub  <- dboTripInfo  %>% subset_columns(Trip_columns)

TripInfo <- bind_rows(hsdbTripInfo_sub, dboTripInfo_sub)
rm(hsdbTripInfo, dboTripInfo, hsdbTripInfo_sub, dboTripInfo_sub)

Trip_meta <- metadata %>%
  filter(TABLE_NAME == "TripInfo" & COLUMN_NAME %in% Trip_columns) %>%
  dplyr::select(-TABLE_SCHEMA)
#
## SampleEvent
SE_columns <- c("SampleEventID", "TripID", "FixedLocationID", "TripDate", "Comments")

hsdbSampleEvent_sub <- hsdbSampleEvent %>% subset_columns(SE_columns)
dboSampleEvent_sub  <- dboSampleEvent  %>% subset_columns(SE_columns)

SampleEvent <- bind_rows(hsdbSampleEvent_sub, dboSampleEvent_sub)
rm(hsdbSampleEvent, dboSampleEvent, hsdbSampleEvent_sub, dboSampleEvent_sub)

Event_meta <- metadata %>%
  filter(TABLE_NAME == "SampleEvent" & COLUMN_NAME %in% SE_columns) %>%
  dplyr::select(-TABLE_SCHEMA) %>%
  distinct()
#
## SampleEvent Water Quality
SEWQ_columns <- c("SampleEventWQID", "SampleEventID", "TripDate", "FixedLocationID", "Temperature", "Salinity", "DissolvedOxygen", "pH", "Depth", "SampleDepth", "Secchi", "CollectionTime", "YSICalibration", "Comments")

hsdbSampleEventWQ_sub <- hsdbSampleEventWQ %>% subset_columns(SEWQ_columns)
dboSampleEventWQ_sub  <- dboSampleEventWQ  %>% subset_columns(SEWQ_columns)

SampleEventWQ <- bind_rows(hsdbSampleEventWQ_sub, dboSampleEventWQ_sub)
rm(hsdbSampleEventWQ, dboSampleEventWQ, hsdbSampleEventWQ_sub, dboSampleEventWQ_sub)

WQ_meta <- metadata %>%
  filter(TABLE_NAME == "SampleEventWQ" & COLUMN_NAME %in% SEWQ_columns) %>%
  dplyr::select(-TABLE_SCHEMA) %>%
  distinct()
#
#
## Recruitment
Rcrt_columns <- c("ShellID", "SampleEventID", "TripDate", "DeployedDate", "FixedLocationID",  "ShellReplicate", "ShellPosition", "NumTop", "NumBottom", "Comments")

hsdbRecruitment_sub <- hsdbRecruitment %>% subset_columns(Rcrt_columns)
dboRecruitment_sub  <- dboRecruitment  %>% subset_columns(Rcrt_columns)

Recruitment <- bind_rows(hsdbRecruitment_sub, dboRecruitment_sub)
rm(hsdbRecruitment, dboRecruitment, hsdbRecruitment_sub, dboRecruitment_sub)

Rcrt_meta <- metadata %>%
  filter(TABLE_NAME == "Recruitment" & COLUMN_NAME %in% Rcrt_columns) %>%
  dplyr::select(-TABLE_SCHEMA) %>%
  distinct()
#
#
#
## Data cleaning for output ----
#
# Station information 
FixedLocations <- dboFixedLocations %>%
  dplyr::select(Estuary, 
                SectionName, 
                StationNumber, 
                StartDate, 
                EndDate, 
                FixedLocationID,
                LatitudeDec,
                LongitudeDec)
#
# Sampling dates
SampleEvent_df <- SampleEvent %>% 
  left_join(
    dboFixedLocations %>% dplyr::select(Estuary, SectionName, StationNumber, FixedLocationID)) %>%
  dplyr::select(Estuary, 
                SectionName, 
                StationNumber, 
                TripDate, 
                Comments) %>%
  arrange(TripDate,
          SectionName,
          StationNumber)
#
# Water quality 
SE_WQ <- SampleEventWQ %>%
  left_join(
    dboFixedLocations %>% dplyr::select(Estuary, SectionName, StationNumber, FixedLocationID)) %>%
  dplyr::filter(
    (is.na(Comments) |
       !stringr::str_detect(
         stringr::str_to_lower(Comments),
         "same as|wq same|same wq")) &
      TripDate %in% Recruitment$TripDate) %>%
  dplyr::select(Estuary,
                SectionName, 
                StationNumber, 
                TripDate, 
                CollectionTime, 
                Depth, 
                SampleDepth, 
                Secchi, 
                Temperature, 
                Salinity, 
                DissolvedOxygen, 
                pH,
                YSICalibration, 
                Comments) %>%
  arrange(TripDate,
          SectionName, 
          StationNumber)
#
# Recruitment
Spat <- Recruitment  %>%
  left_join(
    dboFixedLocations %>% dplyr::select(Estuary, SectionName, StationNumber, FixedLocationID)) %>%
  dplyr::select(Estuary, 
                SectionName, 
                StationNumber, 
                TripDate,
                DeployedDate,
                ShellReplicate,
                ShellPosition,
                NumTop,
                NumBottom,
                Comments) %>%
  arrange(TripDate, 
          SectionName,
          StationNumber, 
          ShellReplicate,
          ShellPosition)
#
#
## Compile metadata ---- 
#
Metadata_base <- read.csv("Column_names_meta.csv")
Data_comments <- read.csv("Data_comments.csv") %>% 
  dplyr::filter(Filter == "CERP" | is.na(Filter))

# Functions to write data to Excel workbook ----
write_metadata_to_excel <- function(datalist, file_path, sheet_name = "Metadata", space = 2, Data_comments = NULL) {
  # datalist: named list of data frames
  # file_path: where to save the Excel file
  # space: number of empty rows between tables
  
  # Create workbook
  wb <- createWorkbook()
  addWorksheet(wb, sheet_name)
  
  # Styles
  title_style  <- createStyle(textDecoration = "bold")
  header_style <- createStyle(textDecoration = "bold")
  note_style   <- createStyle(textDecoration = "italic", wrapText = TRUE, valign = "top")
  
  start_row <- 1
  max_cols  <- 1  # track widest table for auto-fit
  
  for(name in names(datalist)) {
    
    df <- datalist[[name]]
    n_cols <- ncol(df)
    max_cols <- max(max_cols, n_cols)
    
    # write table title (bold)
    writeData(
      wb,
      sheet = sheet_name,
      x = name,
      startRow = start_row,
      startCol = 1
    )
    
    addStyle(
      wb,
      sheet = sheet_name,
      style = title_style,
      rows = start_row,
      cols = 1,
      gridExpand = TRUE,
      stack = TRUE
    )
    
    start_row <- start_row + 1
    
    # write table data
    writeData(
      wb,
      sheet = sheet_name,
      x = df,
      startRow = start_row,
      startCol = 1,
      withFilter = FALSE
    )
    
    # bold column headers
    addStyle(
      wb,
      sheet = sheet_name,
      style = header_style,
      rows = start_row,
      cols = 1:n_cols,
      gridExpand = TRUE,
      stack = TRUE
    )
    
    start_row <- start_row + nrow(df) + 1
    
    # Add notes (if present)
    if (!is.null(Data_comments)) {
      
      notes <- Data_comments %>%
        filter(
          gsub("\\s+", "", tolower(DataTable)) ==
            gsub("\\s+", "", tolower(name))
        ) %>%
        dplyr::pull(Comment)
      
      if (length(notes) > 0) {
        
        writeData(
          wb,
          sheet_name,
          x = "Notes:",
          startRow = start_row,
          startCol = 1
        )
        
        addStyle(wb, sheet_name, title_style, start_row, 1)
        
        start_row <- start_row + 1
        
        for (note in notes) {
          writeData(
            wb,
            sheet_name,
            x = note,
            startRow = start_row,
            startCol = 1
          )
          
          mergeCells(
            wb,
            sheet = sheet_name,
            cols = 1:3,
            rows = start_row
          )
          
          addStyle(
            wb,
            sheet_name,
            note_style,
            start_row,
            1:max_cols,
            gridExpand = TRUE
          )
          
          setRowHeights(
            wb,
            sheet = sheet_name,
            rows = start_row,
            heights = "auto"
          )
          
          start_row <- start_row + 1
        }
        
        start_row <- start_row + space
      }
    }
    
    start_row <- start_row + space
  }
  
  # set column widths
  setColWidths(
    wb,
    sheet = sheet_name,
    cols = 1,
    widths = 22
  )
  
  if (max_cols > 1) {
    setColWidths(
      wb,
      sheet = sheet_name,
      cols = 2:max_cols,
      widths = "auto"
    )
  }
  
  # Save workbook
  saveWorkbook(wb, file = file_path, overwrite = TRUE)
}
add_tables_to_workbook <- function(wb, datalist, sheet_prefix = "Table", with_filter = TRUE) {
  # wb: an existing openxlsx workbook object
  # datalist: named or unnamed list of data.frames
  # sheet_prefix: used if datalist is unnamed
  # with_filter: add Excel filters to headers
  
  # Counter for unnamed sheets
  counter <- 1
  
  for(name in names(datalist)) {
    df <- datalist[[name]]
    
    # Determine sheet name
    sheet_name <- if(!is.null(name) && nzchar(name)) {
      name
    } else {
      paste0(sheet_prefix, "_", counter)
    }
    
    # Make sure sheet name is unique (Excel allows max 31 chars)
    sheet_name <- substr(sheet_name, 1, 31)
    while(sheet_name %in% names(wb)) {
      counter <- counter + 1
      sheet_name <- substr(paste0(sheet_prefix, "_", counter), 1, 31)
    }
    
    # Add worksheet and write data
    addWorksheet(wb, sheet_name)
    writeData(wb, sheet = sheet_name, x = df, withFilter = FALSE)
    
    counter <- counter + 1
  }
  
  return(wb)
}

# Name tables to include with data desired:
datatables <- list(
  "Locations" = Metadata_base %>% 
    dplyr::filter(Tab == "FixedLocations") %>%
    dplyr::select(-Column),
  "Sample Event" = Metadata_base %>% 
    dplyr::filter((Tab == "FixedLocations" | Tab == "SampleEvent") & DatabaseColumn %in% colnames(SampleEvent_df)) %>%
    dplyr::select(-Column) %>%
    dplyr::mutate(Tab = "SampleEvent") %>%
    distinct(),
  "Sample Water Quality" = Metadata_base %>% 
    dplyr::filter(Tab == "SampleEventWQ") %>%
    dplyr::select(-Column),
  "Recruitment" = Metadata_base %>% 
    dplyr::filter(Tab == "Recruitment" & DatabaseColumn %in% colnames(Spat)) %>%
    dplyr::select(-Column) 
)

#
# Write meta to Excel
write_metadata_to_excel(datatables, 
                        paste0(folder_name,"/", file_name), 
                        space = 2,
                        Data_comments = Data_comments %>% dplyr::select(-Filter))

# New datatables to add
datatables2 <- list(
  "Locations" = FixedLocations,
  "SampleEvent" = SampleEvent_df,
  "WaterQuality" = SE_WQ,
  "Recruitment" = Spat
)
#
wb <- loadWorkbook(paste0(folder_name,"/", file_name))
wb <- add_tables_to_workbook(wb, datatables2)
saveWorkbook(wb,
             file = paste0(folder_name, "/", file_name),
             overwrite = TRUE)

