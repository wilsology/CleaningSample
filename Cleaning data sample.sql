SELECT *
FROM PortofolioProject..NashvilleHousing

--standardize date format
SELECT SaleDate
FROM PortofolioProject..NashvilleHousing  --in date and time format

ALTER TABLE NashvilleHousing
ALTER COLUMN [SaleDate]Date  --change to date format

--property Address, based on data, parcelID go to the same propertyAddress, so this is to populate address if another parcelID have the address already
SELECT *
FROM PortofolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)  --if a.Address isnull, put b.address
FROM PortofolioProject..NashvilleHousing AS a
JOIN PortofolioProject..NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]

UPDATE a   --must use the aliase
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)  --if a.Address isnull, put b.address
FROM PortofolioProject..NashvilleHousing AS a
JOIN PortofolioProject..NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress is null

	--split address into individual column (address, city, state)
	SELECT PropertyAddress
	FROM PortofolioProject..NashvilleHousing
SELECT SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Address   -- 1 at the beginning to specify start from where, look for a specific character in charindex to split it, in this case looking for comma, -1 to exclude the comma
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD [PropertySplitAddress] nvarchar(255) -- adding a column for the new splitted Address

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)  --inserting the values inside

ALTER TABLE NashvilleHousing
ADD [PropertySplitCity] nvarchar(255) -- adding a column for the new splitted City

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitCity
FROM PortofolioProject..NashvilleHousing


--owner address using parse name, useful when got delimiter, it split it out at the period
SELECT ownerAddress
FROM PortofolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),  --since parsename only split it on the period, we replace the commas with period
PARSENAME(REPLACE(OwnerAddress,',','.'),2),   -- 3 2 1 as parseword goes backwards
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD [OwnerSplitAddress] nvarchar(255) -- adding a column for the new splitted Address

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)  --inserting the values inside

ALTER TABLE NashvilleHousing
ADD [OwnerSplitCity] nvarchar(255) -- adding a column for the new splitted Address

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)  --inserting the values inside

ALTER TABLE NashvilleHousing
ADD [OwnerSplitState] nvarchar(255) -- adding a column for the new splitted Address

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)  --inserting the values inside




-- counting how many unique values (Y N Yes No)
SELECT Distinct(soldasvacant), COUNT(SoldAsVacant)
FROM PortofolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--replace Y as Yes and N as No

SELECT Soldasvacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortofolioProject..NashvilleHousing

UPDATE NashvilleHousing  --update the field in table with the replacement
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--removing duplicates (assumming that any lines with similar PArcelID,PRoAddress,Saleprice,Saledate,Legalref are duplicates)
WITH RowNumCTE AS(
SELECT *,
	ROW_Number() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID -- making a CTE to pull out those that have the samne in parcelID,proAddress,etcetc.
				 ) AS Row_Num
FROM PortofolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE Row_Num >1     --finding how many are "duplicates"

WITH RowNumCTE AS(
SELECT *,
	ROW_Number() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID -- making a CTE to pull out those that have the samne in parcelID,proAddress,etcetc.
				 ) AS Row_Num
FROM PortofolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num >1     --Deleting those duplicates


--deleting unused column, do not do on raw data, only personal files
SELECT *
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress    --deleting