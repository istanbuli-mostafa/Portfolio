-- Cleaning Data in SQL

-- Viewing table to get better understanding of the dataset we are working with
SELECT *
FROM Portfolioproject3..nashvillehousing

-- 1st Cleaning item: Standarize saledate column
SELECT SaleDate, CONVERT(date,SaleDate)
FROM Portfolioproject3..nashvillehousing 

UPDATE nashvillehousing
SET SaleDate = CONVERT(date,SaleDate)

-- OR add a new column with Sale date converted

ALTER TABLE nashvillehousing
ADD SaleDateConverted DATE;

UPDATE nashvillehousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-- 2nd Cleaning item: Populate missing Property Address Data

--Checking for Null values
SELECT *
FROM Portfolioproject3..nashvillehousing
WHERE PropertyAddress IS NULL

-- We can see that property address is the same for all matching parcel ID 
SELECT *
FROM Portfolioproject3..nashvillehousing
ORDER BY ParcelID

-- To populate use self join
SELECT a.[UniqueID ], 
	   a.ParcelID, 
	   a.PropertyAddress,
	   b.[UniqueID ], 
	   b.ParcelID, 
	   b.PropertyAddress, 
	   ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolioproject3..nashvillehousing AS a
JOIN Portfolioproject3..nashvillehousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolioproject3..nashvillehousing AS a
JOIN Portfolioproject3..nashvillehousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--3rd Cleaning Item: Breaking out address into individual columns(address, city, state)

--Notice property address contains address and city combined together
SELECT PropertyAddress
FROM Portfolioproject3..nashvillehousing
-- Seperating the address into Address and City
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Portfolioproject3..nashvillehousing

-- Adding 2 new columns
--For address
ALTER TABLE nashvillehousing
ADD PropertySplitaddress Nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--For city
ALTER TABLE nashvillehousing
ADD PropertySplitCity Nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Check work
Select *
FROM Portfolioproject3..nashvillehousing


-- Now apply same changes to Owneraddress using another method other than SUBSTRING

Select OwnerAddress
FROM Portfolioproject3..nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) AS OwnerSplitAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) AS OwnerSplitCity, 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) AS OwnerSplitState
FROM Portfolioproject3..nashvillehousing


--Adding the new 3 columns
--For address
ALTER TABLE nashvillehousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

--For City
ALTER TABLE nashvillehousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

--For State
ALTER TABLE nashvillehousing
ADD OwnerSplitState Nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

--Check work
Select *
FROM Portfolioproject3..nashvillehousing

--4th Cleaning item: standardizing the Soldasvacant column
--As shown from below query 4 unique entries that correspond to 2 actual responses
Select DISTINCT(SoldAsVacant)	
FROM Portfolioproject3..nashvillehousing

--Using CASE statement

Select SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM Portfolioproject3..nashvillehousing

--Update original table

UPDATE Portfolioproject3..nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
--To check run the DISTINCT QUERY again
Select DISTINCT(SoldAsVacant)	
FROM Portfolioproject3..nashvillehousing

-- 5th Cleaning Item: Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				uniqueID
				) AS row_num


FROM Portfolioproject3..nashvillehousing
)

DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1

--To check run query below and we should have empty result back confirming that duplicated data has been removed
WITH RowNumCTE AS (
SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				uniqueID
				) AS row_num


FROM Portfolioproject3..nashvillehousing
)

SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1

-- 6th Cleaning Item: Removing Unused Columns
Select *
FROM Portfolioproject3..nashvillehousing

ALTER TABLE Portfolioproject3..nashvillehousing
DROP COLUMN OwnerAddress, PropertyAddress, Saledate

ALTER TABLE Portfolioproject3..nashvillehousing
DROP COLUMN Saledate


-- Please note that usually any data removal conducted needs to happen on views and not on original data sets.
-- Always maintain origianl data sets and if any columns or cells need to be removed it should be done on a view or dataset copy.
