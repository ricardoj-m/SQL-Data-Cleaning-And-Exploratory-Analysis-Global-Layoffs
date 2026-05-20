# SQL-Data-Cleaning-And-Exploratory-Analysis-Global-Layoffs
End-to-end SQL portfolio project showing data sanitization and exploratory analysis on worldwide layoff logs. Uses advanced techniques—including Window Functions, CTEs, and self-joins—to transform messy raw data into rolling monthly totals and annual leaderboards.

📌 **Project Overview**

This repository contains a two-phase SQL project focused on data cleaning and exploratory data analysis (EDA) of global layoffs from the start of the COVID-19 pandemic through 2023. The goal of this project was to take a messy, raw dataset, build a safe staging pipeline to transform it into a trusted analytical ledger, and then query it to uncover macroeconomic displacement trends across various industries, countries, and funding stages.

🛠️ **Tech Stack & Skills Highlighted**

* Language: SQL (MySQL compatible).

* Advanced Concepts Used: Multi-stage staging tables, Common Table Expressions (CTEs), Window Functions (ROW_NUMBER(), DENSE_RANK()), Data Imputation via self-joins, Type Casting and String Normalization.

🧹 **Phase 1: The Data Cleaning Pipeline**

Raw, user-submitted data is inherently chaotic. Before performing any analytics, I built a data-hardening workflow to handle structural anomalies and missing information.

The pipeline executes the following sanitization steps:

1. Safe Working Layer (Staging): Created a duplicate table structure to isolate and process records safely without mutating the original source ledger.

1. Transactional Deduplication: Applied a windowing function partition across all criteria vectors to isolate identical duplicates, using an indexing table strategy to safely purge multi-logged transactions.

1. Categorical Standardization: Fixed text inconsistencies and group fragmentation (e.g., merging variations like 'CryptoCurrency' and 'Crypto' into a unified 'Crypto' sector; stripping stray periods from country entries like 'United States.').

1. Temporal Transformation: Parsed text strings into validated ISO standard date values (YYYY-MM-DD) and altered table columns to enable accurate time-series scaling.

1. Missing Value Imputation: Fixed blank categories using a self-join technique that references valid sibling entries for the same company and location.

1. Data Compaction: Cleared rows missing both total volumes and percentages, removing uninformative entries.

📊 **Phase 2: Exploratory Data Analysis (EDA)**

With a clean foundation, I executed descriptive statistics and multi-dimensional aggregations to extract macroeconomic stories.

Key Focus Areas:

* Absolute Thresholds: Investigated the largest single-day mass layoffs and identified companies that shut down entirely (100% layoffs) relative to their funding capitals.

* Volume Aggregations: Grouped total workforce reductions by company, industry sector, geographic location, and investment maturity stages to locate core displacement impact zones.

* Month-over-Month Rolling Compaction: Developed a time-series query tracking cumulative rolling totals, exposing the acceleration of global workforce adjustments month-by-month.

* Annual Leaderboards: Implemented a double-layer CTE structure employing DENSE_RANK() to isolate and display the top 5 worst companies for layoffs inside every individual year.

📈 **Sample Insights Discovered**

* Hardest-Hit Sectors: The Tech/Consumer sectors experienced the heaviest structural staff displacements overall compared to traditional retail.

* Peak Timeline: Layoffs dramatically accelerated in late 2022 and early 2023, dwarfing the initial spikes seen at the start of the 2020 pandemic.

* Geographic Concentration: The United States logged the highest volume of consolidated job losses, primarily concentrated within major tech hubs.

📂 Repository Structure

* data_cleaning.sql: Contains the complete data sanitization, deduplication, and transformation queries.

* exploratory_data_analysis.sql: Contains the trend analytics, cumulative calculations, and ranking models.
