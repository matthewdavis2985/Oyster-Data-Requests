-- Data request for Jen Weaver (Research Planning, Inc.) August 2023
-- Including Christine Boring and Jeffrey Dahlin (Research Planning, Inc.)
-- Providing density data to update FWRI Environmental Sensitivity Index atlas
-- Providing Location and Survey data for Apalachicola Bay 2015-01-01 to 2023-07-30 
-- Providing Location and Survey data for St Andrew Bay 2015-01-01 to 2023-07-30 

----------------------------------------------------------------------------------------
-- Select requested data and join into a single, flat table 
----------------------------------------------------------------------------------------

-- Select survey data from hsdb schema
SELECT
	TripInfo.TripDate AS 'Date',
	REPLACE(REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay'), 'SA', 'St Andrew Bay') Estuary,
	REPLACE(REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'N', 'North'), 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec AS 'Latitude (Decimal degrees)',
	SampleEvent.LongitudeDec AS 'Longitude (Decimal degrees)',
	AVG(SurveyQuadrat.NumLive * 4) AS 'Oysters / m2'

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
	TripInfo.TripID like 'AB%' or
	TripInfo.TripID like 'SA%' 

GROUP BY
	TripInfo.TripDate,
	FixedLocations.Estuary,
	FixedLocations.SectionName,
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec,
	SampleEvent.LongitudeDec,
	SurveyQuadrat.SampleEventID

UNION

-- Select survey data from dbo schema 

SELECT
	TripInfo.TripDate AS 'Date',
	REPLACE(REPLACE(
		FixedLocations.Estuary, 'AB', 'Apalachicola Bay'), 'SA', 'St Andrew Bay') Estuary,
	REPLACE(REPLACE(REPLACE(REPLACE(
		FixedLocations.SectionName, 'N', 'North'), 'E', 'East'), 'C', 'Central'), 'W', 'West') 'Estuary section',
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec AS 'Latitude (Decimal degrees)',
	SampleEvent.LongitudeDec * -1 AS 'Longitude (Decimal degrees)', -- Data was entered without a negative
	AVG(SurveyQuadrat.NumLive * 4) AS 'Oysters / m2'

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
	TripInfo.TripID like 'AB%' or
	TripInfo.TripID like 'SA%' 

GROUP BY
	TripInfo.TripDate,
	FixedLocations.Estuary,
	FixedLocations.SectionName,
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec,
	SampleEvent.LongitudeDec,
	SurveyQuadrat.SampleEventID
	
ORDER BY
	Estuary, 
	TripDate,
	FixedLocationID;