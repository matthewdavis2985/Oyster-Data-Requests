-- Data request for Tara Stewart Merrill (FSUCML) February 2022
-- Providing Location, Recruitment, Survey, and Collection data for Apalachicola Bay 2015-01-01 to 2019-12-31 

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
	hsdb.FixedLocations
where
	Estuary = 'AB' and
	StationNumber <= 20 and
	(Recruitment = 'Y' or Survey = 'Y' or Collections = 'Y')
order by
	StationNumber;

----------------------------------------------------------------------------------------
-- Select Recruitment data
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
	TripType = 'Recruitment' and 
	TripDate < '2020-01-01' 
order by 
	TripDate;

select 
	SampleEventID,
	TripID,
	FixedLocationID,
	Comments
from 
	hsdb.SampleEvent
where
	TripID like 'ABRCRT%' and
	not TripID like 'ABRCRT_2020%'
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
	SampleEventID like 'ABRCRT%' and
	not SampleEventID like 'ABRCRT_2020%'
order by 
	SampleEventID;

select 
	ShellID,
	SampleEventID,
	DeployedDate,
	ShellReplicate,
	ShellPosition,
	NumTop,
	NumBottom
from 
	hsdb.Recruitment
where
	not ShellID like 'ABRCRT_2020%'
order by
	ShellID;

----------------------------------------------------------------------------------------
-- Select Survey data
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
	TripType = 'Survey' and 
	TripDate < '2020-01-01' 
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
	TripID like 'ABSRVY%' and
	not TripID like 'ABSRVY_2020%'
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
	SampleEventID like 'ABSRVY%' and
	not SampleEventID like 'ABSRVY_2020%'
order by 
	SampleEventID;

select 
	QuadratID,
	SampleEventID,
	QuadratNumber,
	NumLive,
	NumDead,
	NumDrills,
	TotalVolume,
	TotalWeight,
	Comments,
	AdminNotes
from 
	hsdb.SurveyQuadrat
where
	not QuadratID like 'ABSRVY_2020%'
order by
	QuadratID;

select 
	ShellHeightID,
	QuadratID,
	ShellHeight,
	Comments,
	AdminNotes
from 
	hsdb.SurveySH
where
	not ShellHeightID like 'ABSRVY_2020%'
order by
	ShellHeightID;

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
	TripType = 'Collections' and 
	TripDate < '2020-01-01' 
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
	TripID like 'ABCOLL%' and
	not TripID like 'ABCOLL_2020%'
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
	SampleEventID like 'ABCOLL%' and
	not SampleEventID like 'ABCOLL_2020%'
order by 
	SampleEventID;

select 
	OysterID,
	SampleEventID,
	ShellHeight,
	ShellLength, 
	ShellWidth,
	TotalWeight,
	TarePanWeight,
	ShellWetWeight,
	TissueWetWeight,
	ShellDryWeight,
	TissueDryWeight,
	OldSampleNumber,
	Comments,
	AdminNotes
from 
	hsdb.ConditionIndex
where
	not SampleEventID like 'ABCOLL_2020%'
order by
	OysterID;

select 
	ShellPestID,
	OysterID,
	SampleEventID,
	PhotoSurface,
	TotalArea,
	TotalHeight,
	TotalLength,
	ClionaArea,
	PolydoraArea,
	ClamCount,
	ClamAverageDiameter,
	OldSampleNumber,
	Comments
from 
	hsdb.ShellPest
where
	not SampleEventID like 'ABCOLL_2020%'
order by
	ShellPestID;

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
	Dermo.OldSampleNumber,
	Dermo.Comments
from
	hsdb.Dermo
Join hsdb.Repro on hsdb.Dermo.OysterID=hsdb.Repro.OysterID
order by
	OysterID;