/*

Cleaning data in SQL queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing


--Standardize date format 

select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)


alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)


--Populate property adress data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null   


--Breaking out Address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address 

from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )


alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


Select*
from PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing



Select 
PARSENAME (replace(OwnerAddress, ',', '.') ,3)
,PARSENAME (replace(OwnerAddress, ',', '.') ,2)
,PARSENAME (replace(OwnerAddress, ',', '.') ,1)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (replace(OwnerAddress, ',', '.') ,3)


alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME (replace(OwnerAddress, ',', '.') ,2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME (replace(OwnerAddress, ',', '.') ,1)


Select *
from PortfolioProject.dbo.NashvilleHousing



--change y and n to yes and no in "sold as vacant" field

Select Distinct(SoldAsVacant), count(SoldasVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2 




select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   end 
from PortfolioProject.dbo.NashvilleHousing




update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   end  




----Remove duplicates


with RowNumCTE AS(
Select *,
	ROW_NUMBER()Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num


from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select*
--Delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress




------

--Delete unused columns


Select*
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
