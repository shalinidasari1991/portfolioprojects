-- cleaning data in sql queries ----

select * from dbo.navshillehousing

-- Standardized sale date --
select converteddate  ,convert( date, SaleDate) 
from navshillehousing


alter table navshillehousing 
add converteddate date;

update navshillehousing 
set converteddate = CONVERT(date, SaleDate)

-- later we can remove saledate column.

-- populate property address column
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
 from dbo.navshillehousing a 
 join dbo.navshillehousing b
 on a .ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null
 -- update these changes in table using update command 

 update a 
 set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
 from dbo.navshillehousing a 
 join dbo.navshillehousing b
 on a .ParcelID = b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null


-- breaking property Address column into separate colomn( city, country, state)
select PropertyAddress from 
dbo.navshillehousing 

select 
SUBSTRING(PropertyAddress, 1, charindex (',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress , charindex (',', PropertyAddress) +1, len(PropertyAddress)) as address
from dbo.navshillehousing


-- add these two columns into table using alter and update command 



alter table Navshillehousing
add PropertysplitAddress Nvarchar(255)

update Navshillehousing 
set PropertysplitAddress =SUBSTRING(PropertyAddress, 1, charindex (',', PropertyAddress) -1)


alter table Navshillehousing
add Propertysplitcity Nvarchar(255)

update Navshillehousing 
set Propertysplitcity =SUBSTRING(PropertyAddress , charindex (',', PropertyAddress) +1, len(PropertyAddress))

select * from dbo.navshillehousing
--  converting owners address into state city country

select 
PARSENAME(replace (OwnerAddress, ',', '.' ),3),
PARSENAME(replace (OwnerAddress, ',', '.' ),2),
PARSENAME(replace (OwnerAddress, ',', '.' ),1)
from dbo.navshillehousing

-- create new columns for each varaibles . addess , city, state.


alter table Navshillehousing
add OwnersplitAddress Nvarchar(255)

update Navshillehousing 
set OwnersplitAddress =PARSENAME(replace (OwnerAddress, ',', '.' ),3)


alter table Navshillehousing
add ownerysplitcity Nvarchar(255)

update Navshillehousing 
set Ownerysplitcity = PARSENAME(replace (OwnerAddress, ',', '.' ),2)


alter table Navshillehousing
add ownersplitstate Nvarchar(255)

update Navshillehousing 
set Ownersplitstate = PARSENAME(replace (OwnerAddress, ',', '.' ),1)


-- change N and Y into yes and no , from sold as vacant colomn

select distinct(SoldAsVacant), count(SoldAsVacant) 
from dbo.navshillehousing
group by SoldAsVacant
order by  2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then  'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 
from dbo.navshillehousing

-- updating the new coloum in to table 

update dbo.navshillehousing
set SoldAsVacant =
case when SoldAsVacant = 'Y' then  'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
	 
-- removing duplicate record using row_number and partition function 

with RowNumCTE as (
select *, 
ROW_NUMBER() over (
partition by ParcelId,
            PropertyAddress, 
			SalePrice,
			SaleDate,
			Legalreference
			order by UniqueID
			) row_num
from dbo.navshillehousing
--order by ParcelID
)
select * from RowNumCTE
where row_num > 1 
--order by PropertyAddress


-- delete unused columns 
select * from dbo.navshillehousing

Alter table dbo.navshillehousing
drop column PropertyAddress, OwnerAddress,TaxDistrict


Alter table dbo.navshillehousing
drop column SaleDate










