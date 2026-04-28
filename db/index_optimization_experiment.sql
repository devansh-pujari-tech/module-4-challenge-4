-- ============================================================
-- INDEX ORDER MATTERS: Complete Experiment & Optimization
-- ============================================================
-- This script demonstrates how composite index column ordering
-- affects query performance in PostgreSQL.
-- ============================================================

-- ============================================================
-- PART 1: CREATE DATABASE & SCHEMA WITH BROKEN INDEX
-- ============================================================

-- Note: Run this separately to create database
-- CREATE DATABASE employee_reporting;
-- \c employee_reporting

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary NUMERIC,
    hire_date DATE
);

-- BROKEN INDEX - Column order doesn't match query pattern
-- This index has (salary, department) but queries filter by (department, salary)
CREATE INDEX idx_salary_department ON employees(salary, department);

-- ============================================================
-- PART 2: LOAD SAMPLE DATA
-- ============================================================

DELETE FROM employees;  -- Clear for fresh start

INSERT INTO employees (name, department, salary, hire_date) VALUES
('Alice', 'Sales', 60000, '2020-01-15'),
('Bob', 'Engineering', 75000, '2019-03-20'),
('Charlie', 'Sales', 55000, '2021-06-10'),
('David', 'HR', 50000, '2018-11-05'),
('Eve', 'Engineering', 80000, '2020-07-22'),
('Frank', 'Sales', 45000, '2022-02-12'),
('Grace', 'Engineering', 72000, '2019-12-30'),
('Heidi', 'HR', 48000, '2021-04-18');

-- ============================================================
-- PART 3: TEST QUERIES WITH BROKEN INDEX
-- ============================================================

-- QUERY 1: Department filter first, then salary range
-- Expected: Sequential Scan (index is ineffective)
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000;

-- QUERY 2: Different department, same filter pattern
-- Expected: Sequential Scan (same issue)
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE department = 'Engineering'
AND salary >= 70000;

-- ============================================================
-- PART 4: UNDERSTAND THE PROBLEM
-- ============================================================
-- The broken index (salary, department) cannot efficiently handle
-- queries that filter by (department, salary) because:
--
-- - B-tree indexes are sorted by the leftmost column first
-- - Index (salary, department) sorts by salary values globally
-- - To find department='Sales', PostgreSQL must scan ALL salary ranges
-- - The index becomes useless for department-first filtering
-- - PostgreSQL chooses Sequential Scan (full table scan)
-- ============================================================

-- ============================================================
-- PART 5: DEMONSTRATE THE FIX
-- ============================================================

-- Step 1: Drop the broken index
DROP INDEX IF EXISTS idx_salary_department;

-- Step 2: Create index with CORRECT column order
-- Department first (equality filter) → Salary second (range filter)
CREATE INDEX idx_department_salary ON employees(department, salary);

-- Step 3: Re-run queries with the corrected index
-- Expected: Index Scan (now efficient!)

EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000;

EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE department = 'Engineering'
AND salary >= 70000;

-- ============================================================
-- PART 6: ADDITIONAL QUERY PATTERNS
-- ============================================================

-- Query using only department (still uses index due to left-most prefix)
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE department = 'Sales';

-- Query using only salary (DOES NOT use idx_department_salary effectively)
-- Would need a separate index or different approach
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary > 60000;

-- Query with both filters reversed order in code but same logical order
-- Still uses the index because PostgreSQL reorders the conditions
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary > 50000
AND department = 'Sales';

-- ============================================================
-- PART 7: PERFORMANCE COMPARISON SCRIPT
-- ============================================================
-- Run this to generate statistics for comparison

-- Count rows by department for analysis
SELECT department, COUNT(*) as count, AVG(salary) as avg_salary
FROM employees
GROUP BY department
ORDER BY count DESC;

-- Show which rows match the test query
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000
ORDER BY salary DESC;

-- ============================================================
-- PART 8: CLEANUP (OPTIONAL)
-- ============================================================
-- Uncomment to reset for testing

-- DROP INDEX IF EXISTS idx_department_salary;
-- DROP TABLE IF EXISTS employees;

-- ============================================================
-- KEY INSIGHTS
-- ============================================================
-- 1. Index column order MUST match query filter order
-- 2. Put EQUALITY filters first (most selective)
-- 3. Put RANGE/INEQUALITY filters second
-- 4. Test with EXPLAIN ANALYZE to verify index usage
-- 5. Look for "Index Scan" (good) vs "Seq Scan" (bad)
-- 6. The Left-Most Prefix Rule: queries must start with
--    the leading column(s) to use the index effectively
-- ============================================================
