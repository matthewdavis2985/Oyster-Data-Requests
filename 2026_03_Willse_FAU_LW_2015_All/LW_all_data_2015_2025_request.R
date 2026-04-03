## R code for compiling data requests:
#
## Data requested: LW dermo, CI, repro, survey density, WQ
# 2015-2025
#
## Set up ----
folder_name <- "2026_03_Wilse_FAU_LW_2015_All"
EstuaryCode <- c("LW")
start_date <- as.Date("2015-01-01")
end_date <- as.Date("2025-12-31")
Database <- "Oysters_26-03-31"
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
  "hsdb", "SurveyQuadrat",
  "dbo", "SurveyQuadrat",
  "hsdb", "Dermo",
  "dbo", "Dermo",
  "hsdb", "Repro",
  "dbo", "Repro",
  "hsdb", "ConditionIndex",
  "dbo", "ConditionIndex",
  "dbo", "DataDictionary"
)

metadata <- get_metadata(con, tables)

dboDataDictionary <- tbl(con,in_schema("dbo", "DataDictionary")) %>%
  dplyr::select(SortOrder, SchemaName, TableName, ColumnName, DataType, Definition) %>%
  collect()

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

hsdbDermo <- tbl(con,in_schema("hsdb", "Dermo")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22),
    SampleNumber = substring(OysterID, 10, 11)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date) %>%
  collect()

dboDermo <- tbl(con,in_schema("dbo", "Dermo")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22),
    SampleNumber = substring(OysterID, 10, 11)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      DataStatus == "Proofed") %>%
  collect()

hsdbRepro <- tbl(con,in_schema("hsdb", "Repro")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22),
    SampleNumber = substring(OysterID, 10, 11)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date) %>%
  collect()

dboRepro <- tbl(con,in_schema("dbo", "Repro")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22),
    SampleNumber = substring(OysterID, 10, 11)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      DataStatus == "Proofed") %>%
  collect()

hsdbCondition <- tbl(con,in_schema("hsdb", "ConditionIndex")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22),
    SampleNumber = substring(OysterID, 10, 11)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date) %>%
  collect()

dboCondition <- tbl(con,in_schema("dbo", "ConditionIndex")) %>% 
  mutate(
    TripDate = as.Date(substring(SampleEventID, 8, 15)),
    FixedLocationID = substring(SampleEventID, 19, 22),
    SampleNumber = substring(OysterID, 10, 11)) %>%
  filter(
    substring(SampleEventID,1,2) %in% EstuaryCode & 
      TripDate >= start_date & 
      TripDate <= end_date & 
      DataStatus == "Proofed") %>%
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

Trip_meta <- dboDataDictionary %>% 
  filter(TableName == "TripInfo" & ColumnName %in% Trip_columns) %>% 
  arrange(SortOrder) %>%
  dplyr::select(-c("SortOrder", "SchemaName")) %>%
  distinct()
#
## SampleEvent
SE_columns <- c("SampleEventID", "TripID", "FixedLocationID", "TripDate", "Comments")

hsdbSampleEvent_sub <- hsdbSampleEvent %>% subset_columns(SE_columns)
dboSampleEvent_sub  <- dboSampleEvent  %>% subset_columns(SE_columns)

SampleEvent <- bind_rows(hsdbSampleEvent_sub, dboSampleEvent_sub)
rm(hsdbSampleEvent, dboSampleEvent, hsdbSampleEvent_sub, dboSampleEvent_sub)

Event_meta <- dboDataDictionary %>% 
  filter(TableName == "SampleEvent" & ColumnName %in% SE_columns) %>%
  arrange(SortOrder) %>%
  dplyr::select(-c("SortOrder", "SchemaName")) %>%
  distinct()
#
## SampleEvent Water Quality
SEWQ_columns <- c("SampleEventWQID", "SampleEventID", "TripDate", "FixedLocationID", "Temperature", "Salinity", "DissolvedOxygen", "pH", "Depth", "SampleDepth", "Secchi", "CollectionTime", "YSICalibration", "Comments")

hsdbSampleEventWQ_sub <- hsdbSampleEventWQ %>% subset_columns(SEWQ_columns)
dboSampleEventWQ_sub  <- dboSampleEventWQ  %>% subset_columns(SEWQ_columns)

SampleEventWQ <- bind_rows(hsdbSampleEventWQ_sub, dboSampleEventWQ_sub)
rm(hsdbSampleEventWQ, dboSampleEventWQ, hsdbSampleEventWQ_sub, dboSampleEventWQ_sub)

WQ_meta <- dboDataDictionary %>% 
  filter(TableName == "SampleEventWQ" & ColumnName %in% SEWQ_columns) %>%
  arrange(SortOrder) %>%
  dplyr::select(-c("SortOrder", "SchemaName")) %>%
  distinct()
#
#
## Survey counts
Srvy_columns <- c("QuadratID", "SampleEventID", "TripDate", "FixedLocationID", "QuadratNumber", "NumLive", "NumDead", "Comments")

hsdbSurveyQuadrat_sub <- hsdbSurveyQuadrat %>% subset_columns(Srvy_columns)
dboSurveyQuadrat_sub  <- dboSurveyQuadrat  %>% subset_columns(Srvy_columns) 

SurveyQuads <- bind_rows(hsdbSurveyQuadrat_sub, dboSurveyQuadrat_sub)
rm(hsdbSurveyQuadrat, dboSurveyQuadrat, hsdbSurveyQuadrat_sub, dboSurveyQuadrat_sub)

Survey_meta <- dboDataDictionary %>% 
  filter(TableName == "SurveyQuadrat" & ColumnName %in% Srvy_columns) %>%
  arrange(SortOrder) %>%
  dplyr::select(-c("SortOrder", "SchemaName")) %>%
  distinct()
#
#
#
## Dermo
Dermo_columns <- c("OysterID", "SampleEventID", "TripDate", "FixedLocationID", "SampleNumber", 
                   "ShellHeight", "ShellLength", "ShellWidth", "TotalWeight", "ShellWetWeight", "DermoMantle", "DermoGill", 
                   "Comments")

hsdbDermo_sub <- hsdbDermo %>% subset_columns(Dermo_columns)
dboDermo_sub  <- dboDermo  %>% subset_columns(Dermo_columns) 

Dermo_t <- bind_rows(hsdbDermo_sub, dboDermo_sub)
rm(hsdbDermo, dboDermo, hsdbDermo_sub, dboDermo_sub)

Dermo_meta <- dboDataDictionary %>% 
  filter(TableName == "Dermo" & ColumnName %in% Dermo_columns) %>%
  arrange(SortOrder) %>%
  dplyr::select(-c("SortOrder", "SchemaName")) %>%
  distinct()
#
#
#
## Repro
Repro_columns <- c("OysterID", "SampleEventID", "TripDate", "FixedLocationID", "SampleNumber", 
                   "Sex", "ReproStage", "Parasite", "BadSlide",
                   "Comments")

hsdbRepro_sub <- hsdbRepro %>% subset_columns(Repro_columns)
dboRepro_sub  <- dboRepro  %>% subset_columns(Repro_columns) 

Repro_t <- bind_rows(hsdbRepro_sub, dboRepro_sub)
rm(hsdbRepro, dboRepro, hsdbRepro_sub, dboRepro_sub)

Repro_meta <- dboDataDictionary %>% 
  filter(TableName == "Repro" & ColumnName %in% Repro_columns) %>%
  arrange(SortOrder) %>%
  dplyr::select(-c("SortOrder", "SchemaName")) %>%
  distinct()
#
#
#
## Condition index
CI_columns <- c("OysterID", "SampleEventID", "TripDate", "FixedLocationID", "SampleNumber", 
                "ShellHeight", "ShellLength", "ShellWidth", "TotalWeight", 
                "TarePanWeight", "TissueWetWeight", "ShellWetWeight", "TissueDryWeight", "ShellDryWeight", 
                "Comments")

hsdbCI_sub <- hsdbCondition %>% subset_columns(CI_columns)
dboCI_sub  <- dboCondition  %>% subset_columns(CI_columns) 

CI_t <- bind_rows(hsdbCI_sub, dboCI_sub)
rm(hsdbCondition, dboCondition, hsdbCI_sub, dboCI_sub)

CI_meta <- dboDataDictionary %>% 
  filter(TableName == "ConditionIndex" & ColumnName %in% CI_columns) %>%
  arrange(SortOrder) %>%
  dplyr::select(-c("SortOrder", "SchemaName")) %>%
  distinct()
#
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
      TripDate %in% SurveyQuads$TripDate) %>%
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
# Survey counts
Counts <- SurveyQuads  %>%
  left_join(
    dboFixedLocations %>% dplyr::select(Estuary, SectionName, StationNumber, FixedLocationID)) %>%
  dplyr::select(Estuary, 
                SectionName, 
                StationNumber, 
                TripDate,
                QuadratNumber,
                NumLive,
                NumDead,
                Comments) %>%
  arrange(TripDate, 
          SectionName,
          StationNumber, 
          QuadratNumber)
Counts <- Counts %>% 
  dplyr::mutate(Comments = case_when(
    substr(TripDate, 1, 4) %in% c("2005", "2006", "2007") ~ "CAUTION - 1 m2 quadrat used",
    TRUE ~ Comments  # keep existing value for all other rows
  ))
#
# Dermo
Dermo <- Dermo_t %>%
  left_join(
    dboFixedLocations %>% dplyr::select(Estuary, SectionName, StationNumber, FixedLocationID)) %>%
  dplyr::select(Estuary,
                SectionName, 
                StationNumber, 
                TripDate, 
                SampleNumber,
                ShellHeight:DermoGill,
                Comments) %>%
  arrange(TripDate,
          SectionName, 
          StationNumber,
          SampleNumber)
#
# Repro
Repro <- Repro_t %>%
  left_join(
    dboFixedLocations %>% dplyr::select(Estuary, SectionName, StationNumber, FixedLocationID)) %>%
  dplyr::select(Estuary,
                SectionName, 
                StationNumber, 
                TripDate, 
                SampleNumber,
                Sex:BadSlide,
                Comments) %>%
  arrange(TripDate,
          SectionName, 
          StationNumber,
          SampleNumber)
#
# Condition
ConditionIndex <- CI_t %>%
  left_join(
    dboFixedLocations %>% dplyr::select(Estuary, SectionName, StationNumber, FixedLocationID)) %>%
  dplyr::select(Estuary,
                SectionName, 
                StationNumber, 
                TripDate, 
                SampleNumber,
                ShellHeight:ShellDryWeight,
                Comments) %>%
  arrange(TripDate,
          SectionName, 
          StationNumber,
          SampleNumber)
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
  
  EXCEL_MAX_ROWS <- 1048576
  
  # Create workbook
  wb <- createWorkbook()
  
  # Styles
  title_style  <- createStyle(textDecoration = "bold")
  header_style <- createStyle(textDecoration = "bold")
  note_style   <- createStyle(textDecoration = "italic", wrapText = TRUE, valign = "top")
  
  sheet_index <- 1
  current_sheet <- sheet_name
  addWorksheet(wb, current_sheet)
  
  start_row <- 1
  max_cols  <- 1  # track widest table for auto-fit
  sheets_used <- current_sheet
  
  new_sheet <- function() {
    sheet_index <<- sheet_index + 1
    current_sheet <<- paste0(sheet_name, "_", sheet_index)
    addWorksheet(wb, current_sheet)
    sheets_used <<- c(sheets_used, current_sheet)
    start_row <<- 1
  }
  
  for(name in names(datalist)) {
    
    df <- datalist[[name]]
    n_rows <- nrow(df)
    n_cols <- ncol(df)
    max_cols <- max(max_cols, n_cols)
    
    
    # Estimate rows needed (title + header + data + spacing)
    notes <- character(0)
    if (!is.null(Data_comments)) {
      notes <- Data_comments %>%
        filter(
          gsub("\\s+", "", tolower(DataTable)) ==
            gsub("\\s+", "", tolower(name))
        ) %>%
        pull(Comment)
    }
    
    rows_needed <- 1 + 1 + n_rows + 1 +
      if (length(notes) > 0) length(notes) + 2 else 0 +
      space
    
    if (start_row + rows_needed > EXCEL_MAX_ROWS) {
      new_sheet()
    }
    
    # write table title (bold)
    writeData(
      wb,
      sheet = current_sheet,
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
      sheet = current_sheet,
      x = df,
      startRow = start_row,
      startCol = 1,
      withFilter = FALSE
    )
    
    # bold column headers
    addStyle(
      wb,
      sheet = current_sheet,
      style = header_style,
      rows = start_row,
      cols = 1:n_cols,
      gridExpand = TRUE,
      stack = TRUE
    )
    
    start_row <- start_row + n_rows + 1
    
    # Add notes (if present)
    if (length(notes) > 0) {
      
      writeData(
        wb,
        current_sheet,
        x = "Notes:",
        startRow = start_row,
        startCol = 1
      )
      addStyle(wb, current_sheet, title_style, start_row, 1)
      start_row <- start_row + 1
      
      for (note in notes) {
        
        if (start_row >= EXCEL_MAX_ROWS) {
          new_sheet()
        }
        
        writeData(
          wb,
          current_sheet,
          x = note,
          startRow = start_row,
          startCol = 1
        )
        
        mergeCells(
          wb,
          sheet = current_sheet,
          cols = 1:max(3, max_cols),
          rows = start_row
        )
        
        addStyle(
          wb,
          current_sheet,
          note_style,
          start_row,
          1:max_cols,
          gridExpand = TRUE
        )
        
        setRowHeights(
          wb,
          sheet = current_sheet,
          rows = start_row,
          heights = "auto"
        )
        
        start_row <- start_row + 1
      }
      
      start_row <- start_row + space
    }
    
    start_row <- start_row + space
  }
  
  # ---- Column widths on all sheets ----
  for (s in sheets_used) {
    setColWidths(wb, s, cols = 1, widths = 22)
    if (max_cols > 1) {
      setColWidths(wb, s, cols = 2:max_cols, widths = "auto")
    }
  }
  
  saveWorkbook(wb, file = file_path, overwrite = TRUE)
}
add_tables_to_workbook <- function(wb, datalist, sheet_prefix = "Table", with_filter = TRUE) {
  # wb: an existing openxlsx workbook object
  # datalist: named or unnamed list of data.frames
  # sheet_prefix: used if datalist is unnamed
  # with_filter: add Excel filters to headers
  
  EXCEL_MAX_ROWS <- 1048576
  HEADER_ROWS    <- 1
  DATA_ROWS_MAX  <- EXCEL_MAX_ROWS - HEADER_ROWS
  
  # Counter for unnamed sheets
  counter <- 1
  
  for(name in names(datalist)) {
    df <- datalist[[name]]
    n <- nrow(df)
    
    # Determine sheet name
    base_name <- if(!is.null(name) && nzchar(name)) {
      name
    } else {
      paste0(sheet_prefix, "_", counter)
    }
    
    # Make sure sheet name is unique (Excel allows max 31 chars)
    base_name <- substr(base_name, 1, 31)
    # Number of chunks needed
    n_chunks <- ceiling(n / DATA_ROWS_MAX)
    
    for (i in seq_len(n_chunks)) {
      
      start <- (i - 1) * DATA_ROWS_MAX + 1
      end   <- min(i * DATA_ROWS_MAX, n)
      
      df_chunk <- df[start:end, , drop = FALSE]
      
      sheet_name <- if (n_chunks == 1) {
        base_name
      } else {
        substr(paste0(base_name, "_", i), 1, 31)
      }
      
      # Ensure uniqueness in workbook
      original_name <- sheet_name
      suffix <- 1
      while(sheet_name %in% names(wb)) {
        sheet_name <- substr(
          paste0(original_name, "_", suffix),
          1,
          31
        )
        suffix <- suffix + 1
      }
      
      addWorksheet(wb, sheet_name)
      
      writeData(
        wb,
        sheet = sheet_name,
        x = df_chunk,
        withFilter = with_filter
      )
    }
    
    counter <- counter + 1
  }
  
  return(wb)
}

# Name tables to include with data desired:
datatables <- list(
  "Locations" = Metadata_base %>% 
    dplyr::filter(Tab == "FixedLocations") %>%
    dplyr::select(-Column),
  "Sample Event" = bind_rows(
    Metadata_base %>% 
      dplyr::filter((Tab == "FixedLocations" | Tab == "SampleEvent") & DatabaseColumn %in% colnames(SampleEvent_df)) %>%
      dplyr::select(-Column) %>%
      dplyr::mutate(Tab = "SampleEvent") %>%
      distinct(),
    Event_meta %>%
      filter(ColumnName %in% colnames(SampleEvent_df) & !(ColumnName %in% Metadata_base$DatabaseColumn)) %>%
      dplyr::select(-DataType) %>%
      transmute(
        Tab = TableName,
        DatabaseColumn = ColumnName,
        Description = Definition
      )),
  "Sample Water Quality" = bind_rows(
    Metadata_base %>% 
      dplyr::filter(Tab == "SampleEventWQ") %>%
      dplyr::select(-Column),
    WQ_meta %>%
      filter(ColumnName %in% colnames(SE_WQ) & !(ColumnName %in% Metadata_base$DatabaseColumn)) %>%
      dplyr::select(-DataType) %>%
      transmute(
        Tab = TableName,
        DatabaseColumn = ColumnName,
        Description = Definition
      )),
    "Survey Quadrat" = bind_rows(
      Metadata_base %>% 
        dplyr::filter(Tab == "SurveyQuadrat" & DatabaseColumn %in% colnames(Counts)) %>%
        dplyr::select(-Column),
      Survey_meta %>%
        filter(ColumnName %in% colnames(Counts) & !(ColumnName %in% Metadata_base$DatabaseColumn)) %>%
        dplyr::select(-DataType) %>%
        transmute(
          Tab = TableName,
          DatabaseColumn = ColumnName,
          Description = Definition
        )),
  "Dermo" = bind_rows(
    Metadata_base %>% 
      dplyr::filter(Tab == "Dermo" & DatabaseColumn %in% colnames(Dermo)) %>%
      dplyr::select(-Column),
    Dermo_meta %>%
      filter(ColumnName %in% colnames(Dermo) & !(ColumnName %in% Metadata_base$DatabaseColumn)) %>%
      dplyr::select(-DataType) %>%
      transmute(
        Tab = TableName,
        DatabaseColumn = ColumnName,
        Description = Definition
      )),
  "Repro" = bind_rows(
    Metadata_base %>% 
      dplyr::filter(Tab == "Repro" & DatabaseColumn %in% colnames(Repro)) %>%
      dplyr::select(-Column),
    Repro_meta %>%
      filter(ColumnName %in% colnames(Repro) & !(ColumnName %in% Metadata_base$DatabaseColumn)) %>%
      dplyr::select(-DataType) %>%
      transmute(
        Tab = TableName,
        DatabaseColumn = ColumnName,
        Description = Definition
      )),
  "Condition Index" = bind_rows(
    Metadata_base %>% 
      dplyr::filter(Tab == "ConditionIndex" & DatabaseColumn %in% colnames(ConditionIndex)) %>%
      dplyr::select(-Column),
    CI_meta %>%
      filter(ColumnName %in% colnames(ConditionIndex) & !(ColumnName %in% Metadata_base$DatabaseColumn)) %>%
      dplyr::select(-DataType) %>%
      transmute(
        Tab = TableName,
        DatabaseColumn = ColumnName,
        Description = Definition
      ))
)

#
# Write meta to Excel
write_metadata_to_excel(datatables, 
                        paste0(folder_name,"/LakeWorth_Data_2015_2025.xlsx"), 
                        space = 2,
                        Data_comments = Data_comments %>% dplyr::select(-Filter))
#
# New datatables to add
datatables2 <- list(
  "Locations" = FixedLocations,
  "SampleEvent" = SampleEvent_df,
  "WaterQuality" = SE_WQ,
  "SurveyCounts" = Counts,
  "Dermo" = Dermo,
  "Repro" = Repro,
  "Condition Index" = ConditionIndex
)
#
wb <- loadWorkbook(paste0(folder_name,"/LakeWorth_Data_2015_2025.xlsx"))
wb <- add_tables_to_workbook(wb, datatables2)
saveWorkbook(wb,
             file = paste0(folder_name, "/LakeWorth_Data_2015_2025.xlsx"),
             overwrite = TRUE)
