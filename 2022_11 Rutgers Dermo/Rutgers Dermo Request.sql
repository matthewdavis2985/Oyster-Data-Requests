-- Data request for David Bushek (Rutgers) November 2022
-- Including Lucia De Souza Lima Safi (RSSBP post doc) and Emily McGurk (Haskin Lab histopathologist)
-- Providing Location and Dermo data for Apalachicola Bay 2016-01-01 to 2021-09-30 

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
	hsdb.FixedLocations
	ON
	FixedLocations.FixedLocationID=SampleEvent.FixedLocationID
join
	hsdb.Dermo
	ON
	SampleEvent.SampleEventID=Dermo.SampleEventID

where
	TripInfo.TripID like 'AB%'

order by
	OysterID;
