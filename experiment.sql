-- Step 1: Initial Query Analysis
EXPLAIN ANALYZE 
SELECT * FROM employees 
WHERE department = 'Sales' AND salary > 50000;

-- Step 2: Create Incorrect Index (already in schema but for clarity)
-- This index puts the range filter column first.
DROP INDEX IF EXISTS idx_salary_department;
CREATE INDEX idx_incorrect_order ON employees(salary, department);

-- Re-run Analysis
EXPLAIN ANALYZE 
SELECT * FROM employees 
WHERE department = 'Sales' AND salary > 50000;

-- Step 4: Fix the Index Order
-- This index puts the equality filter column first.
DROP INDEX IF EXISTS idx_incorrect_order;
CREATE INDEX idx_correct_order ON employees(department, salary);

-- Final Performance Check
EXPLAIN ANALYZE 
SELECT * FROM employees 
WHERE department = 'Sales' AND salary > 50000;
