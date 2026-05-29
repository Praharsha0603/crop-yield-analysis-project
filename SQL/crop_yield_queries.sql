USE crop_project;
SELECT *
FROM crop_cleaned
LIMIT 5;

ALTER TABLE crop_cleaned
RENAME COLUMN average_rain_fall_mm_per_year TO avg_rainfall;

-- Finding Total Rows
SELECT count(*)
FROM crop_cleaned;

-- number of unique crops are present in the dataset
SELECT COUNT(distinct crop)
FROM crop_cleaned;

-- Name of the crops present
SELECT DISTINCT 
crop 
FROM crop_cleaned;

-- crops having highest total production?
SELECT
crop,
AVG(hg_ha_yield) AS avg_yield
FROM crop_cleaned
GROUP BY crop
ORDER BY AVG(hg_ha_yield) DESC;

-- areas having the highest average crop yield
SELECT
Area,
AVG(hg_ha_yield) AS avg_yield
FROM crop_cleaned
GROUP BY Area
ORDER by AVG(hg_ha_yield) DESC;

-- Rank crops based on average yield.
SELECT crop,
AVG(hg_ha_yield) as avg_yield,
RANK()
OVER(ORDER BY AVG(hg_ha_yield) DESC)
AS crop_rank
FROM crop_cleaned
GROUP BY crop;

-- Top yielding crop INSIDE each Area.
SELECT crop,
Area,
AVG(hg_ha_yield) AS avg_yield,
RANK()
OVER(
    PARTITION BY Area
    ORDER BY AVG(hg_ha_yield) DESC
)
FROM crop_cleaned
GROUP BY Area, crop;


-- ONLY the top yielding crop from each Area.
WITH ranked_crops AS
(
SELECT crop,
Area,
AVG(hg_ha_yield) as avg_yield,
RANK()
OVER( PARTITION BY Area
ORDER BY AVG(hg_ha_yield) DESC
) AS crop_rank
FROM crop_cleaned
GROUP BY Area, crop
)
SELECT * 
FROM ranked_crops 
WHERE crop_rank=1;

-- Running total of average crop yield over years.
SELECT 
Year,
AVG(hg_ha_yield) as avg_yield,
SUM(AVG(hg_ha_yield))
OVER(ORDER BY Year)
AS Running_Total
FROM crop_cleaned
GROUP BY Year;

-- relationship between rainfall and crop yield.
SELECT AVG(hg_ha_yield) AS avg_yield,


CASE 
	WHEN avg_rainfall < 1000 THEN 'low_rainfall'
    WHEN avg_rainfall < 2000 THEN 'medium_rainfall'
    ELSE 'high_rainfall'
END AS rainfall_category

FROM crop_cleaned
GROUP BY rainfall_category
ORDER BY avg_yield DESC;

-- crops performing best in different temperature conditions
SELECT Crop,
AVG(avg_temp),
AVG(hg_ha_yield)
FROM crop_cleaned
GROUP BY Crop
ORDER BY AVG(hg_ha_yield) DESC;

-- Highest yielding crop for each year.
WITH yearly_rank AS
(
    SELECT Year,
    Crop,
	AVG(hg_ha_yield) AS avg_yield,
	RANK()
    OVER(
        PARTITION BY Year
        ORDER BY AVG(hg_ha_yield) DESC
    ) AS crop_rank
	FROM crop_cleaned
	GROUP BY Year, Crop
)SELECT *
FROM yearly_rank
WHERE crop_rank = 1;