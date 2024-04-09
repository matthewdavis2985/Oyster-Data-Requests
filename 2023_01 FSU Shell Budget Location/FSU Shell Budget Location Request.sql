-- Data request for Sandra Brooke (FSUCML) January 2023
-- Providing Location information for current (January 2023) Apalachicola Bay sampling stations for Shell Budget Survey

----------------------------------------------------------------------------------------
-- Select Location data 
----------------------------------------------------------------------------------------

use Oysters

select 
	FixedLocationID,
	StationName,
	ParcelName,
	substring(Comments, 21, 9) as LatA,
	substring(Comments, 31, 10) as LonA,
	substring(Comments, 42, 9) as LatB,
	substring(Comments, 52, 10) as LonB,
	substring(Comments, 63, 9) as LatC,
	substring(Comments, 73, 10) as LonC,
	substring(Comments, 84, 9) as LatD,
	substring(Comments, 94, 10) as LonD

from 
	hsdb.FixedLocations

where
	Estuary = 'AB' and
	StationNumber <= 20 and
	ShellBudget = 'Y' and 
	StartDate <= '2023-01-01' and
	EndDate >= '2023-01-31'

order by
	StationNumber;