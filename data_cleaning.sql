/**
 * Script: data_cleaning.sql
 * Project: Worldwide Layoffs Data (2020 - 2023)
 * Description: This script cleans up a messy raw dataset of layoffs.
 * Steps: Makes a safe working copy, deletes identical duplicate rows, standardizes text typos, 
 * fixes text dates into actual calendar formats, and fills in missing blanks.
 */

-- Look at the raw table to spot initial errors
SELECT *
FROM layoffs;

-- ==========================================================
-- STEP 1: MAKE A SAFE WORKING COPY (STAGING)
-- ==========================================================

-- Create an empty copy with the exact same structure as the raw table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Fill our new working table with all the raw data
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- ==========================================================
-- STEP 2: FIND AND REMOVE TRIPPED/DUPLICATE ROWS
-- ==========================================================

/**
 * Use a window function (ROW_NUMBER) to look at every column. 
 * If a row has the exact same company, date, numbers, and country as another row, 
 * it gets a row number of 2 or higher. This shows us our duplicates.
 */
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, 
                         percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Create a second staging table that includes a physical column for row numbers.
-- This lets us safely delete rows based on that number.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Put the data into our second table, labeling duplicates with a number higher than 1
INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

-- Delete the duplicates, keeping only the original row (where row_num is 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- ==========================================================
-- STEP 3: CLEAN UP TEXT INCONSISTENCIES AND TYPOS
-- ==========================================================

-- Remove accidental blank spaces from the beginning and end of company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Group different text variations into single, neat categories.
-- Fixes items like 'Crypto' and 'CryptoCurrency' so they match under just 'Crypto'.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Fix country typos, like stripping an accidental period at the end of 'United States.'
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- ==========================================================
-- STEP 4: CHANGE DATE TEXT INTO ACTUAL DATES
-- ==========================================================

-- Change plain text string dates (like '03/11/2020') into a standard computer date format (YYYY-MM-DD)
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the table structure permanently so the database knows this column holds true calendar dates
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ==========================================================
-- STEP 5: FILL IN MISSING BLANK VALUES
-- ==========================================================

-- Change empty text strings ('') into standard database NULL values so they are easier to handle
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Look up other rows for the same company to safely copy over and fill in missing industry blanks.
-- For example, if one row says Google is 'Tech' and another row leaves it blank, fill the blank with 'Tech'.
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- ==========================================================
-- STEP 6: DROP USELESS ROWS AND METADATA
-- ==========================================================

-- Delete any rows where we don't have any layoff numbers or percentages at all
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove the temporary 'row_num' column we created in Step 2 since we are done cleaning
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Display the final, completely clean data
SELECT * FROM layoffs_staging2;
