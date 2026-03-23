-- Data request for Whitney Scheffel (PPBEP) February 2025
-- Providing Location, Water Quality, Recruitment, and Sedimentation data for Pensacola Bay 2022-01-01 to 2024-12-31 

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
	dbo.FixedLocations
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
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID

where
	TripInfo.TripID like 'PERCRT_%' 

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
	dbo.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
join
	hsdb.Recruitment
	ON
	SampleEvent.SampleEventID=Recruitment.SampleEventID

where
	TripInfo.TripID like 'PERCRT_%' and 
	(Recruitment.ShellPosition between 2 and 5
	OR Recruitment.ShellPosition between 8 and 11)
	
order by
	Recruitment.SampleEventID,
	Recruitment.ShellReplicate,
	Recruitment.ShellPosition;


----------------------------------------------------------------------------------------
-- Select Sediment data
----------------------------------------------------------------------------------------

select 
	FixedLocations.StationNumber as 'Station number',
	FixedLocations.FixedLocationID,
	SedimentTrap.DeployedDate as 'Date Deployed',
	TripInfo.TripDate as 'Date Retrieved',
	SedimentTrap.CupSampleID as 'CupSampleID',
	SedimentTrap.FilterTareWeight as 'Filter Tare Weight (g)',
	SedimentTrap.PanTareWeight as 'Pan Tare Weight (g)',
	SedimentTrap.FilterDryWeight as 'Filter Dry Weight (g)',
	SedimentTrap.PanDryWeight as 'Pan Dry Weight (g)',
	SedimentTrap.NumDrills as 'Number of Drills',
	SedimentTrap.NumCrabs as 'Number of Crabs',
	SedimentTrap.NumHermitCrabs as 'Number of Hermit Crabs',
	SedimentTrap.NumFish as 'Number of Fish',
	SedimentTrap.NumOtherBiota as 'Number of Other Biota',
	SedimentTrap.Comments as 'Sediment trap comments'

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
	hsdb.SedimentTrap
	ON
	SampleEvent.SampleEventID=SedimentTrap.SampleEventID

where
	TripInfo.TripID like 'PESDTP%' 
	
order by
	SedimentTrap.SampleEventID,
	SedimentTrap.CupSampleID