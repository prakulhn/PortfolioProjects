--DATA CLEANING IN SQL

SELECT * FROM PortfolioProject..NavshilleHousing

-----------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT

SELECT SaleDateConverted, CAST(SaleDate AS DATE) Date
FROM PortfolioProject..NavshilleHousing

ALTER TABLE NavshilleHousing
ADD SaleDateConverted DATE

UPDATE NavshilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE)

-----------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

SELECT * FROM NavshilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY 2

SELECT NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, 
ISNULL(NH1.PropertyAddress, NH2.PropertyAddress) PropertAdress
FROM NavshilleHousing NH1
JOIN NavshilleHousing NH2
  ON NH1.ParcelID = NH2.ParcelID
  AND NH1.UniqueID <> NH2.UniqueID
WHERE NH1.PropertyAddress IS NULL

UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM NavshilleHousing NH1
JOIN NavshilleHousing NH2
  ON NH1.ParcelID = NH2.ParcelID
  AND NH1.UniqueID <> NH2.UniqueID
WHERE NH1.PropertyAddress IS NULL

--SELECT * FROM NavshilleHousing
--WHERE PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------

--BREAKING ADDRESS INTO INDIVIDUAL COULMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress FROM NavshilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) Address
FROM NavshilleHousing

ALTER TABLE NavshilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NavshilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NavshilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NavshilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM NavshilleHousing

SELECT OwnerAddress FROM NavshilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NavshilleHousing

ALTER TABLE NavshilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NavshilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NavshilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NavshilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NavshilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NavshilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NavshilleHousing

-----------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT'

SELECT DISTINCT(SoldAsVacant)
FROM NavshilleHousing

--USING UPDATE

UPDATE NavshilleHousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y'

UPDATE NavshilleHousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N'

--USING CASE

SELECT SoldAsVacant,
CASE
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
END
FROM NavshilleHousing

--USING UPDATE AND CASE 

UPDATE NavshilleHousing
SET SoldAsVacant =
  CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END

-----------------------------------------------------------------------------------------------

--REMOVE DUPLICATES

WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
               SaleDate,
			   SalePrice,
			   LegalReference
  ORDER BY UniqueID
  ) Row_Num
FROM NavshilleHousing
)

--DELETE FROM RowNumCTE
--WHERE Row_Num > 1

SELECT * FROM RowNumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress

-----------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

SELECT * FROM NavshilleHousing

ALTER TABLE NavshilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE NavshilleHousing
DROP COLUMN SaleDate

-----------------------------------------------------------------------------------------------

--RENAME ALTERED COLUMN NAMES

EXEC sp_rename 'NavshilleHousing.SaleDateConverted', 'SaleDate', 'COLUMN'
EXEC sp_rename 'NavshilleHousing.PropertySplitAddress', 'PropertyAddress', 'COLUMN'
EXEC sp_rename 'NavshilleHousing.PropertySplitCity', 'PropertyCity', 'COLUMN'
EXEC sp_rename 'NavshilleHousing.OwnerSplitAddress', 'OwnerAddress', 'COLUMN'
EXEC sp_rename 'NavshilleHousing.OwnerSplitCity', 'OwnerCity', 'COLUMN'
EXEC sp_rename 'NavshilleHousing.OwnerSplitState', 'OwnerState', 'COLUMN'

SELECT * FROM NavshilleHousing