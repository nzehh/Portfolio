/*
--cleaning data in sql queries
*/

Select * from nashvillehousing

--Standardize date format

Select saledateconverted,cornvert(date,saledate) 
from nashvillehousing

Update Nashvillehousing
Set saledate = convert (date,saledate)

Alter table nashvillehousing
Add saledateconverted date;

Update Nashvillehousing
Set saledateconverted = convert(date,saledate)

--Populate property address data

Select *
from nashvillehousing
where PropertyAddress is null
order by ParcelID

--Using self joins

Select a.parcelID,a.propertyaddress,b.parcelID,b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)
from Nashvillehousing a 
join Nashvillehousing b
      on a.parcelID = b.parcelID
      AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from Nashvillehousing a 
join Nashvillehousing b
      on a.parcelID = b.parcelID
     AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (address,city,state)

Select PropertyAddress
from nashvillehousing

Select 
Substring (propertyaddress,1, charindex(',',propertyaddress)-1) as address,
Substring (propertyaddress, charindex(',',propertyaddress)+1, len (propertyaddress)) as address
From Nashvillehousing

Alter table nashvillehousing
Add propertysplitaddress varchar (255);

Update Nashvillehousing
set propertysplitaddress= substring (propertyaddress,1, charindex(',',propertyaddress)-1)

Alter table nashvillehousing
add propertysplitcity varchar(255);

Update Nashvillehousing
set propertysplitcity=substring (propertyaddress, charindex(',',propertyaddress)+1, len (propertyaddress))

--USING PARSENAME

Select owneraddress
from Nashvillehousing

Select 
parsename (REPLACE (owneraddress, ',', '.'),3) 
,parsename (REPLACE (owneraddress, ',', '.'),2) 
,parsename (REPLACE (owneraddress, ',', '.'),1) 
from Nashvillehousing

Alter table nashvillehousing
add ownersplitaddress varchar (255);

Update Nashvillehousing
set ownersplitaddress=parsename (REPLACE (owneraddress, ',', '.'),3) 

Alter table nashvillehousing
add ownersplitcity varchar (255);

Update Nashvillehousing
set ownersplitcity=parsename (REPLACE (owneraddress, ',', '.'),2)

Alter table nashvillehousing
add ownersplitstate varchar (255);

Update Nashvillehousing
set ownersplitstate=parsename (REPLACE (owneraddress, ',', '.'),1)

Select * from Nashvillehousing


--CHANGE Y AND N TO YES AND No IN 'soldasvacant' FEILD

Select distinct(soldasvacant),count(soldasvacant)
 from Nashvillehousing
 group by SoldAsVacant
 order by 2

 Select soldasvacant, 
 case when soldasvacant = 'Y' then 'YES'
      when soldasvacant = 'N' then 'NO'
	  else soldasvacant
	  end
from nashvillehousing

update Nashvillehousing
set SoldAsVacant= case when soldasvacant = 'Y' then 'YES'
      when soldasvacant = 'N' then 'NO'
	  else soldasvacant
	  end
from nashvillehousing

--REMOVE DUPLICATES

WITH rownumCTE as (
select *,
row_number () over (
partition by  ParcelID,
			Propertyaddress,
			Saleprice,
			saledate,
			legalreference
	       order by uniqueID) as row_num
from Nashvillehousing) 
--order by parcelID
Select *
from rownumCTE
where row_num > 1
--order by propertyaddress


--DELETE UNUSED COLUMNS


Select * from Nashvillehousing

Alter table Nashvillehousing
Drop column taxDistrict,
            owneraddress,
			saledate,
			propertyaddress


 
