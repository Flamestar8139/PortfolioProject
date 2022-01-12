/* 

--Cleaning Data in SQL Queries

*/

select *
From [Portflio project].dbo.Nashvillehousing


-----------------------------------------------------------------------------------------------------------


--Standardize Date Format

select SaleDateConverted,CONVERT(Date,SaleDate)
From [Portflio project].dbo.Nashvillehousing

Update Nashvillehousing 
Set SaleDate=Convert(Date,SaleDate)

Alter Table Nashvillehousing
Add SaleDateConverted Date;

Update Nashvillehousing 
Set SaleDateConverted=Convert(Date,SaleDate)


------------------------------------------------------------------------------------------------------------


--Populate Property Address Data


select *
From [Portflio project].dbo.Nashvillehousing
--Where PropertyAddress is NULL
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
From [Portflio project].dbo.Nashvillehousing  a
join [Portflio project].dbo.Nashvillehousing  b
    on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


Update a
Set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
From [Portflio project].dbo.Nashvillehousing  a
join [Portflio project].dbo.Nashvillehousing  b
    on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------


--Breaking out Address into Individual Columns(Address, City, State)


select PropertyAddress
From [Portflio project].dbo.Nashvillehousing
--Where PropertyAddress is NULL
--order by ParcelID

select 
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) as Address
From [Portflio project].dbo.Nashvillehousing


Alter Table Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update Nashvillehousing 
Set PropertySplitAddress=Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update Nashvillehousing 
Set PropertySplitCity=Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))


Select*
From [Portflio project].dbo.Nashvillehousing




Select OwnerAddress
From [Portflio project].dbo.Nashvillehousing



Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From [Portflio project].dbo.Nashvillehousing


Alter Table Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update Nashvillehousing 
Set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)


Alter Table Nashvillehousing
Add OwnerSplitCity Nvarchar(255);

Update Nashvillehousing 
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)


Alter Table Nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update Nashvillehousing 
Set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)


-----------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold as Vacant" field


Select distinct(SoldAsVacant),count(SoldAsVacant)
From [Portflio project].dbo.Nashvillehousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
       when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end
From [Portflio project].dbo.Nashvillehousing


update Nashvillehousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
       when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end


----------------------------------------------------------------------------------------------------


--Remove Duplicates


with RowNumCTE as(
Select*,
     ROW_NUMBER() over (
	 Partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order by UniqueID
				  ) Row_num
				  
From [Portflio project].dbo.Nashvillehousing
--Order by ParcelID
)
select*
From RowNumCTE
Where Row_num>1
order by PropertyAddress



----------------------------------------------------------------------------------------------------


--Delete Unused Coloumns


Select*
From [Portflio project].dbo.Nashvillehousing

alter table[Portflio project].dbo.Nashvillehousing
drop column OwnerAddress, TaxDistrict,PropertyAddress

alter table[Portflio project].dbo.Nashvillehousing
drop column SaleDate


-------------------------------------------------------------------------------------------------