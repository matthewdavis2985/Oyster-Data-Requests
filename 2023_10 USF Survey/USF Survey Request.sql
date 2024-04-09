-- Data request for Chris Stallings (USF) October 2023
-- Providing Location and Survey data for Apalachicola Bay 2015-01-01 to 2023-09-30 

----------------------------------------------------------------------------------------
-- Select requested Quadrat data and join into a single, flat table 
----------------------------------------------------------------------------------------

-- Select survey data from hsdb schema
SELECT
	QuadratID,
	TripInfo.TripDate AS 'Date',
	REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay') Estuary,
	REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec AS 'Latitude (Decimal degrees)',
	SampleEvent.LongitudeDec AS 'Longitude (Decimal degrees)',
	SurveyQuadrat.NumLive AS 'Oysters / quadrat',
	SurveyQuadrat.NumDrills AS 'Drills / quadrat'

FROM 
	hsdb.TripInfo
	
JOIN 
	hsdb.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
JOIN
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
JOIN
	hsdb.SurveyQuadrat
	ON
	SampleEvent.SampleEventID=SurveyQuadrat.SampleEventID

WHERE
	TripInfo.TripID like 'AB%' 

UNION

-- Select survey data from dbo schema 

SELECT
	QuadratID,
	TripInfo.TripDate AS 'Date',
	REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay') Estuary,
	REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec AS 'Latitude (Decimal degrees)',
	SampleEvent.LongitudeDec AS 'Longitude (Decimal degrees)',
	SurveyQuadrat.NumLive AS 'Oysters / quadrat',
	SurveyQuadrat.NumDrills AS 'Drills / quadrat'

FROM 
	dbo.TripInfo
	
JOIN 
	dbo.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
JOIN
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
JOIN
	dbo.SurveyQuadrat
	ON
	SampleEvent.SampleEventID=SurveyQuadrat.SampleEventID

WHERE
	TripInfo.TripID like 'AB%' 

ORDER BY
	Estuary, 
	TripDate,
	FixedLocationID;

	----------------------------------------------------------------------------------------
-- Select requested Survey Shell Height data and join into a single, flat table 
----------------------------------------------------------------------------------------

-- Select Survey Shell Height data from hsdb schema
SELECT
	SurveySH.QuadratID,
	TripInfo.TripDate AS 'Date',
	REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay') Estuary,
	REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec AS 'Latitude (Decimal degrees)',
	SampleEvent.LongitudeDec AS 'Longitude (Decimal degrees)',
	SurveySH.ShellHeight AS 'Shell Height (mm)'

FROM 
	hsdb.TripInfo
	
JOIN 
	hsdb.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
JOIN
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
JOIN
	hsdb.SurveyQuadrat
	ON
	SampleEvent.SampleEventID=SurveyQuadrat.SampleEventID
JOIN
	hsdb.SurveySH
	ON
	SurveyQuadrat.QuadratID=SurveySH.QuadratID

WHERE
	TripInfo.TripID like 'AB%' 

UNION

-- Select survey data from dbo schema 

SELECT
	SurveySH.QuadratID,
	TripInfo.TripDate AS 'Date',
	REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay') Estuary,
	REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec AS 'Latitude (Decimal degrees)',
	SampleEvent.LongitudeDec AS 'Longitude (Decimal degrees)',
	SurveySH.ShellHeight AS 'Shell Height (mm)'

FROM 
	dbo.TripInfo
	
JOIN 
	dbo.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
JOIN
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
JOIN
	dbo.SurveyQuadrat
	ON
	SampleEvent.SampleEventID=SurveyQuadrat.SampleEventID
JOIN
	dbo.SurveySH
	ON
	SurveyQuadrat.QuadratID=SurveySH.QuadratID

WHERE
	TripInfo.TripID like 'AB%' 

ORDER BY
	Estuary, 
	TripDate,
	FixedLocationID,
	QuadratID;

----------------------------------------------------------------------------------------
-- Select Recruitment Drill Number data and join into a single, flat table 
----------------------------------------------------------------------------------------

-- Select Recruitment Drill Number data from hsdb schema
SELECT
	SampleEvent.SampleEventID,
	TripInfo.TripDate AS 'Date',
	REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay') Estuary,
	REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	FixedLocations.LatitudeDec AS 'Latitude (Decimal degrees)',
	FixedLocations.LongitudeDec AS 'Longitude (Decimal degrees)',
	SampleEvent.NumDrills AS 'Total Number of Drills'

FROM 
	hsdb.TripInfo
	
JOIN 
	hsdb.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
JOIN
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID

WHERE
	TripInfo.TripID like 'ABRCRT%' 

UNION

-- Select Recruitment Drill Number data from dbo schema 

SELECT
	SampleEvent.SampleEventID,
	TripInfo.TripDate AS 'Date',
	REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay') Estuary,
	REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	FixedLocations.LatitudeDec AS 'Latitude (Decimal degrees)',
	FixedLocations.LongitudeDec AS 'Longitude (Decimal degrees)',
	SampleEvent.NumDrills AS 'Total Number of Drills'

FROM 
	dbo.TripInfo
	
JOIN 
	dbo.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
JOIN
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID

WHERE
	TripInfo.TripID like 'ABRCRT%' 

ORDER BY
	Estuary, 
	TripDate,
	FixedLocationID,
	SampleEventID;