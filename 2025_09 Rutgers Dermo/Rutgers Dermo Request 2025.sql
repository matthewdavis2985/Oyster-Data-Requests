-- Data request for Emily McGurk (Rutgers) September 2025
-- See Rutgers 2022 for previous request David Bushek
-- Providing Location and Dermo data for Apalachicola Bay 2021-10-01 to 2024-12-31 

----------------------------------------------------------------------------------------
-- Select requested data and join into a single, flat table 
----------------------------------------------------------------------------------------

select
	Dermo.OysterID,
	TripInfo.TripDate,
	replace(
		Estuary, 'AB', 'Apalachicola Bay') EstuaryName,
	replace(replace(replace(
		FixedLocations.SectionName, 'E', 'East'), 'C', 'Central'), 'W', 'West') FullSectionName,
	FixedLocations.StationName,
	SampleEvent.FixedLocationID,
	SampleEvent.LatitudeDec,
	SampleEvent.LongitudeDec,
	Dermo.ShellHeight,
	Dermo.TotalWeight,
	Dermo.DermoMantle,
	Dermo.DermoGill,
	Dermo.Comments
	
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
	hsdb.Dermo
	ON
	SampleEvent.SampleEventID=Dermo.SampleEventID

where
	TripInfo.TripID like 'AB%' and
	TripInfo.TripDate >= '2021-10-01'

order by
	OysterID;
