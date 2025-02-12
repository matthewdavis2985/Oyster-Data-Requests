-- Data request for Lauren Rice (FSUCML) February 2025
-- Providing Location, and Collection (Dermo and Repro) data for Apalachicola Bay 2015-01-01 to 2023-02-28 

----------------------------------------------------------------------------------------
-- Select Location data 
----------------------------------------------------------------------------------------

select 
	FixedLocationID,
	Estuary,
	SectionName,
	StationNumber, 
	LatitudeDec,
	LongitudeDec,
	StartDate,
	EndDate
from 
	dbo.FixedLocations
where
	Estuary = 'AB' and
	StationNumber <= 20 and
	Collections = 'Y'
order by
	StationNumber;


----------------------------------------------------------------------------------------
-- Select Collections data
----------------------------------------------------------------------------------------

select
	TripID,
	TripType,
	TripDate,
	Comments,
	AdminNotes
from 
	hsdb.TripInfo 
where 
	TripID like 'ABCOLL%'  
order by 
	TripDate;

select 
	SampleEventID,
	TripID,
	FixedLocationID,
	LatitudeDec,
	LongitudeDec,
	Comments
from 
	hsdb.SampleEvent
where
	TripID like 'ABCOLL%' 
order by
	SampleEventID;

select 
	SampleEventWQID,
	SampleEventID,
	Temperature,
	Salinity,
	DissolvedOxygen,
	pH,
	Depth,
	Secchi,
	Comments,
	AdminNotes
from 
	hsdb.SampleEventWQ
where
	SampleEventID like 'ABCOLL%'
order by 
	SampleEventID;

select 
	Dermo.OysterID,
	Dermo.SampleEventID,
	ShellHeight,
	ShellLength, 
	ShellWidth,
	TotalWeight,
	ShellWetWeight,
	DermoMantle,
	DermoGill,
	Sex,
	ReproStage,
	Parasite,
	BadSlide,
	Dermo.OldSampleNumber,
	Dermo.Comments
from
	hsdb.Dermo
Join hsdb.Repro on hsdb.Dermo.OysterID=hsdb.Repro.OysterID
order by
	OysterID;