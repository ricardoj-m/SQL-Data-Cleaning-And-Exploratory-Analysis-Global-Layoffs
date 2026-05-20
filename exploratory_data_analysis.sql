/**
 * Script: exploratory_data_analysis.sql
 * Project: Worldwide Layoffs Data (2020 - 2023)
 * Description: This script queries our clean data to find key trends and insights.
 * Goals: Find the biggest layout events, see which industries and countries were hit the hardest, 
 * calculate running totals over time, and rank top companies per year.
 */

-- Ensure our numbers are treated as proper integers and decimals before calculating
ALTER TABLE layoffs_staging2 MODIFY COLUMN total_laid_off INT;
ALTER TABLE layoffs_staging2 MODIFY COLUMN percentage_laid_off DECIMAL(10,2);

-- Find the absolute largest single layoff and the highest percentage laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Look at companies that went out of business completely (100% layoffs), sorted by size
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1.00
ORDER BY total_laid_off DESC;

-- Look at the companies that completely shut down, sorted by how much funding money they raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1.00
ORDER BY funds_raised_millions DESC;

-- Add up all individual layoffs to find the absolute total job losses for each company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Find the earliest and latest dates in our dataset to know the time window
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Add up total layoffs by industry type to see which business sectors suffered the most
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Add up total layoffs by country to see where job losses were concentrated geographically
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Group layoffs by year to see how job losses changed annually
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Group layoffs by company stage (e.g., Seed, Series A, Post-IPO) to see if company maturity mattered
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- ==========================================================
-- ADVANCED TIMELINE TREND: MONTH-BY-MONTH RUNNING TOTALS
-- ==========================================================

/**
 * First, calculate total layoffs for each month (YYYY-MM).
 * Second, use a window function to continuously add each month's total to a running, cumulative snowball total.
 */
WITH Rolling_Total AS (
    SELECT 
        SUBSTRING(`date`, 1, 7) AS `MONTH`, 
        SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1 ASC
)
SELECT `MONTH`, 
       total_off, 
       SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- ==========================================================
-- SYSTEM METRIC: ANNUAL WORST-COMPANY LEADERBOARDS
-- ==========================================================

/**
 * Uses a double-step ranking process to find the top 5 worst companies per year.
 * Step 1 (Company_Year): Add up total layoffs for every company grouped by individual years.
 * Step 2 (Company_Year_Rank): Rank companies from highest to lowest layoffs *inside* each year group.
 * Main Query: Filter to display only the top 5 ranked companies for each respective year.
 */
WITH Company_Year (company, years, total_laid_off) AS (
    SELECT 
        company, 
        YEAR(`date`), 
        SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS (
    SELECT *, 
           DENSE_RANK() OVER (
               PARTITION BY years 
               ORDER BY total_laid_off DESC
           ) AS Ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)
SELECT * FROM Company_Year_Rank
WHERE Ranking <= 5;
