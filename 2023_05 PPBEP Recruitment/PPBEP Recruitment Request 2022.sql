-- Data request for Whitney Scheffel (PPBEP) May 2023
-- Providing Location, Water Quality, and Recruitment data for Pensacola Bay 2022-01-01 to 2022-12-31 

----------------------------------------------------------------------------------------
-- Select Location data 
----------------------------------------------------------------------------------------

select 
	FixedLocationID,
	Estuary,
	SectionName,
	StationNumber as 'Station number', 
	LatitudeDec as 'Latitude (Decimal degrees)',
	LongitudeDec as 'Longitude (Decimal degrees)'
from 
	hsdb.FixedLocations
where
	Estuary = 'PE' and
	Recruitment = 'Y' and
	StartDate Between '2022-01-01' and '2022-12-31' and
	EndDate >= '2022-01-01'
order by
	StationNumber;


----------------------------------------------------------------------------------------
-- Select Water quality data
----------------------------------------------------------------------------------------

select 
	TripInfo.TripDate as 'Trip date',
	FixedLocations.StationNumber as 'Station number',
	FixedLocations.FixedLocationID,
	SampleEventWQ.SampleDepth as 'Sample depth (m)',
	SampleEventWQ.Temperature as 'Temperature (°C)',
	SampleEventWQ.Salinity as 'Salinity (ppt)',
	SampleEventWQ.DissolvedOxygen as 'Dissolved oxygen (mg/L)',
	SampleEventWQ.pH,
	SampleEventWQ.TurbidityYSI as 'Turbidity (FNU)',
	SampleEventWQ.Depth as 'Depth (m)',
	SampleEventWQ.Secchi as 'Secchi depth (m)',
	SampleEventWQ.Comments as 'Water quality comments'
	
from 
	hsdb.TripInfo

join 
	hsdb.SampleEvent
	ON
	TripInfo.TripID=SampleEvent.TripID
join
	hsdb.SampleEventWQ
	ON
	SampleEventWQ.SampleEventID=SampleEvent.SampleEventID
join
	hsdb.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID

where
	TripInfo.TripID like 'PERCRT_2022%' 

order by 
	SampleEventWQID;


----------------------------------------------------------------------------------------
-- Select Recruitment data
----------------------------------------------------------------------------------------

select 
	FixedLocations.StationNumber as 'Station number',
	FixedLocations.FixedLocationID,
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
	hsdb.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
join
	hsdb.Recruitment
	ON
	SampleEvent.SampleEventID=Recruitment.SampleEventID

where
	TripInfo.TripID like 'PERCRT_2022%' and 
	(Recruitment.ShellPosition between 2 and 5
	OR Recruitment.ShellPosition between 8 and 11)
	
order by
	Recruitment.SampleEventID,
	Recruitment.ShellReplicate,
	Recruitment.ShellPosition;
