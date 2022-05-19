select *
from PortofolioProject..NashvilleHousing

--mengganti tipe data pada kolom SaleDate menjadi date

select SaleDate, CONVERT(date,SaleDate)
from PortofolioProject..NashvilleHousing

--melakukan update data terhadap kolom SaleDate

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--menambahkan kolom baru SaleDateConverted

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

--melakukan update data ke kolom SaleDateConverted

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--melihat data null pada propertyaddress 

Select PropertyAddress
From PortofolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

--menambahkan address yang sebelumnya null pada kolom propertyaddress berdasarkan parcelID yang memiliki propertyaddress yang sama
--menggunakan join untuk melakukan select data terhadap parcelID yang sama tetapi UniqueID yang berbeda
--query ISNULL untuk (untuk melakukan cek data yang null, jika datanya null maka akan diganti datanya dengan kolom ini )

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProject.dbo.NashvilleHousing a
JOIN PortofolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--melakukan update data terhadap propertyaddress yang null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProject.dbo.NashvilleHousing a
JOIN PortofolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select PropertyAddress
From PortofolioProject.dbo.NashvilleHousing

--membagi propertyaddress menjadi 2 bagian yaitu kolom address dan kolom city
--menggunakan query substring dan charindex
--query substring untuk memisahkan alamat yang terdiri dari 3 input(kolom yang ditinjau, 1 untuk mulai dari first value, sampai charindex yaitu (,) -1 digunakan untuk menghilangkan koma [menampilkan value sebelum huruf di charindex yaitu (,)]
--charindex untuk melakukan searching untuk specific value

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
--mulai dari , lalu +1 value berarti setelah , sampai value terakhir di address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

From PortofolioProject.dbo.NashvilleHousing

--menambahkan kolom PropertySplitAddress

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

--melakukan update data ke kolom PropertySplitAddress

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

----menambahkan kolom PropertySplitCity

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

--melakukan update data ke kolom PropertySplitCity

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortofolioProject.dbo.NashvilleHousing

Select OwnerAddress
From PortofolioProject.dbo.NashvilleHousing

--memisahkan owneraddress menjadi 3 bagian yaitu kolom address, city, dan state dengan metode PARSENAME
--PARSENAME dapat berfungsi dengan (.) sedangkan pada owneraddress terpisahkan dengan (,) sehingga digunakan REPLACE

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortofolioProject.dbo.NashvilleHousing

--menambahkan kolom OwnerSplitAddress

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

--melakukan update data ke kolom OwnerSplitAddress

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

--menambahkan kolom OwnerSplitCity

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

--melakukan update data ke kolom OwnerSplitCity

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

--menambahkan kolom OwnerSplitState

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

--melakukan update data ke kolom OwnerSplitState

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortofolioProject.dbo.NashvilleHousing

--mengubah nilai Y dan N pada kolom SoldAsVacant menjadi Yes dan No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortofolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2  

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortofolioProject.dbo.NashvilleHousing

--melakukan update data ke kolom SoldAsVacant

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--menggunakan CTE, fungsi di dalam WITH untuk melihat data yang duplikat, lalu selanjutnya akan dilakukan penghapusan terhadap data duplikat tersebut
--menghilangkan duplikat
--menggunakan query ROW_NUMBER untuk melihat seberapa banyak data yang sama, bernilai 1 apabila data unique, 2 apabila terdapat 1 duplikat, 3 apabila terdapat 2 duplikat dan seterusnya
--menggunakan partition untuk memulai perhitungan data pada setiap partisi dan apabila ada data yang duplikat maka rownumber akan bernilai 2 dan untuk melakukan perhitungan rownumber dengan data yang berbeda lagi akan dimulai dari 1 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortofolioProject.dbo.NashvilleHousing
)
--melihat terlebih dahulu data mana saja yang duplikat
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--menghapus duplikat data dengan query dibawah
--Delete
--From RowNumCTE
--Where row_num > 1

Select *
From PortofolioProject.dbo.NashvilleHousing

--menghapus kolom yang tidak dipakai

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, PropertyAddress
