-- Data request for Vaughn Weaver (ECT) August 2025
-- Providing Location, Recruitment, and Survey data for St. Andrew Bay (North) 2022-01-01 to 2024-12-31 

----------------------------------------------------------------------------------------
-- Select Location data 
----------------------------------------------------------------------------------------

select 
	FixedLocationID,
	Estuary,
	SectionName,
	StationNumber as 'Station number', 
	LatitudeDec as 'Latitude (Decimal degrees)',
	LongitudeDec as 'Longitude (Decimal degrees)',
	Comments 
from 
	dbo.FixedLocations
where
	Estuary = 'SA' and
	SectionName = 'N' 
order by
	StationNumber;



----------------------------------------------------------------------------------------
-- Select Recruitment data
----------------------------------------------------------------------------------------

select 
	FixedLocations.StationNumber as 'Station number',
	FixedLocations.FixedLocationID,
	FixedLocations.SectionName as 'Section name',
	Recruitment.DeployedDate as 'Date Deployed',
	TripInfo.TripDate as 'Date Retrieved',
	Recruitment.ShellReplicate as 'Replicate number',
	Recruitment.ShellPosition as 'Shell position',
	Recruitment.NumBottom as 'Number of spat',
	Recruitment.Comments as 'Recruitment comments'

from 
	hsdb.TripInfo

join
	hsdb.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
join
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
join
	hsdb.Recruitment
	ON
	SampleEvent.SampleEventID=Recruitment.SampleEventID

where
	TripInfo.TripID like 'SARCRT_%' and 
	SectionName = 'N' and
	(Recruitment.ShellPosition between 2 and 5
	OR Recruitment.ShellPosition between 8 and 11)
	
order by
	Recruitment.SampleEventID,
	Recruitment.ShellReplicate,
	Recruitment.ShellPosition;




	
----------------------------------------------------------------------------------------
-- Select Survey data
----------------------------------------------------------------------------------------

-- Quadrat data

SELECT
	QuadratID,
	TripInfo.TripDate AS 'Date',
	Estuary,
	FixedLocations.SectionName, 
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
	TripInfo.TripID like 'SA%' and
	FixedLocations.SectionName = 'N'

ORDER BY
	QuadratID

-- Shell height data

SELECT
	SurveySH.ShellHeightID,
	SurveySH.QuadratID,
	TripInfo.TripDate AS 'Date',
	FixedLocations.Estuary, 
	FixedLocations.SectionName, 
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
	TripInfo.TripID like 'SA%' and
	FixedLocations.SectionName = 'N'

ORDER BY
	ShellHeightID