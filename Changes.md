# Index Order Investigation

## Step 1: Initial Analysis
The original query being tested is:
```sql
SELECT *
FROM employees
WHERE department = 'Sales'
AND salary > 50000;
```

When running `EXPLAIN ANALYZE` on this query with the initial index:
```sql
CREATE INDEX idx_salary_department ON employees(salary, department);
```
PostgreSQL might perform a **Sequential Scan** or an inefficient **Index Scan**. This is because the index starts with `salary`, which is used for a range comparison (`> 50000`), while `department` (an equality check) comes second in the index.

## Step 2: Incorrect Index Experiment
I created an index with an incorrect column order (which was already present in the starter):
```sql
CREATE INDEX idx_incorrect_order ON employees(salary, department);
```
Observation: The query performance did not significantly improve. The database still had to scan a large portion of the index or table because the leading column of the index (`salary`) was used in a range filter, making the subsequent columns less effective for narrowing down the search.

## Step 3: Analysis of the Problem
The **Left-Most Prefix Rule** states that an index can be used if the query's filters match the columns of the index from left to right. 
- In our case, the query filters on `department` and `salary`.
- With the index `(salary, department)`, the database first filters by `salary > 50000`. 
- Since `salary` is a range filter, it includes many rows, and for each row, the database must still check the `department`.
- If the index were `(department, salary)`, the database could jump directly to the rows where `department = 'Sales'` and then efficiently find only those with `salary > 50000` within that sorted subset.

## Step 4: Fixed Index Order
I created a corrected composite index:
```sql
DROP INDEX IF EXISTS idx_salary_department;
CREATE INDEX idx_correct_order ON employees(department, salary);
```

## Step 5: Explanation of Optimization
- **Original Index (`salary, department`)**: Ineffective because the range scan on the first column (`salary`) prevents the database from using the second column (`department`) to narrow down the search significantly within the index structure.
- **Corrected Index (`department, salary`)**: Highly effective. By putting the equality filter (`department`) first, the database can immediately navigate to the relevant section of the index. Then, it performs a range scan on the second column (`salary`) only within that department's data.
- **Left-Most Prefix Rule**: This rule dictates that composite indexes are most powerful when the columns used in equality filters appear first, followed by columns used in range filters.
