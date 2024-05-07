-- Data request for Jacob Howell (NOAA) May 2024
-- Providing Location for Apalachicola Bay Surveys (current only) 

----------------------------------------------------------------------------------------
-- Select requested Location data into a single table 
----------------------------------------------------------------------------------------

-- Select Location data from dbo.FixedLocations

SELECT
FixedLocationID,
EstuaryLongName,
StationNumber,
LatitudeDec,
LongitudeDec
FROM dbo.FixedLocations
WHERE Estuary = 'AB' and EndDate = '2099-12-31' and Recruitment = 'Y'
ORDER BY StationNumber