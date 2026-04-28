# Composite Index Investigation: Index Order Matters

## Project Overview

This project investigates why a PostgreSQL composite index fails to improve query performance and demonstrates the importance of column ordering in database indexes.

**Key Discovery:** The index column order must match the query's WHERE clause filter pattern to be effective. A broken index `(salary, department)` cannot optimize queries filtering by `(department, salary)` first.

---

## Problem Summary

### The Broken Index

```sql
CREATE INDEX idx_salary_department ON employees(salary, department);
```

### The Query Pattern

```sql
SELECT * FROM employees
WHERE department = 'Sales'
AND salary > 50000;
```

### The Result

- **Performance:** Full table scan (Sequential Scan)
- **Reason:** Query filters by `department` first, but index sorts by `salary` first
- **Cost:** O(n) scan time instead of O(log n) with index

---

## Root Cause: The Left-Most Prefix Rule

PostgreSQL composite indexes follow the **left-most prefix rule**:

1. **Index can be used** if queries filter by leading column(s)
2. **Index is skipped** if queries filter by non-leading columns first
3. **Index is partially used** if only some leading columns are queried

### Example:

- Index: `(department, salary, hire_date)`
- ✅ `WHERE department='Sales'` → Uses index
- ✅ `WHERE department='Sales' AND salary > 50000` → Uses index fully
- ✅ `WHERE department='Sales' AND salary > 50000 AND hire_date > '2020-01-01'` → Uses full index
- ❌ `WHERE salary > 50000` → Does NOT use index (skips leading column)
- ❌ `WHERE hire_date > '2020-01-01'` → Does NOT use index

---

## Solution: Correct Index Ordering

### The Fix

```sql
DROP INDEX idx_salary_department;
CREATE INDEX idx_department_salary ON employees(department, salary);
```

### Why This Works

1. **Department first** (equality filter) - Most selective
2. **Salary second** (range filter) - Applied to filtered subset
3. Queries can now use the index efficiently

---

## Performance Impact

### Before Fix (Sequential Scan)

| Metric              | Value                        |
| ------------------- | ---------------------------- |
| Scan Method         | Seq Scan (full table)        |
| Rows Examined       | All rows                     |
| Execution Time      | O(n) - grows with table size |
| Example (100K rows) | ~50-100+ ms                  |

### After Fix (Index Scan)

| Metric              | Value                                |
| ------------------- | ------------------------------------ |
| Scan Method         | Index Scan                           |
| Rows Examined       | Only matching rows                   |
| Execution Time      | O(log n) - stable regardless of size |
| Example (100K rows) | ~0.5-1 ms                            |

**Improvement: 50-100x faster at scale**

---

## Experiment Steps

### 1. Initial Query Analysis

```sql
EXPLAIN ANALYZE
SELECT * FROM employees
WHERE department = 'Sales'
AND salary > 50000;
```

**Observation:** Seq Scan - index not used

### 2. Create Intentionally Wrong Index

```sql
CREATE INDEX idx_wrong_order ON employees(salary, department);
```

**Observation:** Still Seq Scan - proves column order matters

### 3. Create Corrected Index

```sql
CREATE INDEX idx_department_salary ON employees(department, salary);
```

**Observation:** Now uses Index Scan - performance improved

### 4. Verify with Multiple Query Patterns

```sql
-- Both queries now use the index efficiently
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department = 'Engineering' AND salary >= 70000;

EXPLAIN ANALYZE
SELECT * FROM employees WHERE department = 'Sales' AND salary > 50000;
```

---

## Key Design Principles

### 1. Column Order Priority

1. **Equality filters first** (most selective)
   - Example: `WHERE department = 'X'`
2. **Range/inequality filters second**
   - Example: `AND salary > 50000`
3. **Non-indexed columns last** (if needed)

### 2. Query Analysis

- Use `EXPLAIN ANALYZE` to verify index usage
- Look for "Index Scan" (efficient) vs "Seq Scan" (inefficient)
- Check execution time and rows examined

### 3. Index Effectiveness

- **Effective:** Query filters = Index column order
- **Ineffective:** Query filters ≠ Index column order
- **Partial:** Query uses subset of leading index columns

---

## Files Included

```
.
├── README.md                              # This file
├── Changes.md                             # Detailed investigation report
└── db/
    ├── schema.sql                         # Original database schema
    ├── sample_data.sql                    # Sample employee data
    ├── queries.sql                        # Test queries
    └── index_optimization_experiment.sql  # Complete experiment script
```

---

## How to Use This Repository

### Setup PostgreSQL Database

```bash
createdb employee_reporting
psql employee_reporting < db/schema.sql
psql employee_reporting < db/sample_data.sql
```

### Run Query Analysis

```sql
-- Connect to database
psql employee_reporting

-- Run with broken index
\i db/queries.sql

-- Run full experiment (includes fix)
\i db/index_optimization_experiment.sql
```

### Analyze Performance

```sql
-- Observe Sequential Scan with broken index
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department = 'Sales' AND salary > 50000;

-- After applying fixes (in index_optimization_experiment.sql)
-- Observe Index Scan for efficient execution
```

---

## Learning Outcomes

After completing this investigation, you'll understand:

1. **Why indexes exist** - Reduce query scan time
2. **How composite indexes work** - Multi-column sorting
3. **The importance of column order** - Affects usability
4. **Left-Most Prefix Rule** - Query must start with leading columns
5. **Analysis tools** - EXPLAIN ANALYZE to verify efficiency
6. **Design strategy** - Equality columns first, range columns second
7. **Performance impact** - O(n) vs O(log n) scalability

---

## Common Mistakes to Avoid

❌ **Creating indexes without analyzing query patterns**

- Result: Indexes aren't used

❌ **Putting range filters before equality filters**

- Result: Index becomes partially unusable

❌ **Assuming all queries use the same filter order**

- Result: Need separate indexes for different queries

❌ **Creating too many indexes**

- Result: Slows down INSERT/UPDATE/DELETE operations

✅ **Analyze EXPLAIN ANALYZE output**

- Verify index is actually being used

✅ **Match index order to query filter order**

- Ensures optimal performance

✅ **Test with realistic data size**

- Performance differences show at scale

---

## Further Reading

- PostgreSQL Documentation: Indexes
- B-Tree Index Behavior
- Query Optimization
- Composite Index Design Patterns

---

## Conclusion

This project demonstrates a critical database optimization principle: **index design is as important as index creation**. A poorly designed composite index wastes storage and provides no performance benefit. By understanding column ordering and the left-most prefix rule, database engineers can create indexes that truly optimize query performance and scale efficiently.
