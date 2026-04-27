# Composite Index Investigation

This project investigates how the order of columns in a composite index affects query performance in PostgreSQL.

## Approach
1.  **Analyze**: Used `EXPLAIN ANALYZE` to observe the execution plan of a multi-filter query.
2.  **Experiment**: Tested a composite index with the "incorrect" column order (range filter before equality filter).
3.  **Optimize**: Reordered the index columns to follow the **Left-Most Prefix Rule**, prioritizing equality filters.
4.  **Validate**: Verified performance improvements with subsequent analysis.

## Key Files
- `Changes.md`: Detailed explanation of the findings and the Left-Most Prefix Rule.
- `experiment.sql`: SQL commands used during the investigation.
- `db/schema.sql`: Initial database structure.
- `db/sample_data.sql`: Data used for testing.
- `db/queries.sql`: Queries analyzed for performance.

## How to Run
1.  Set up a PostgreSQL database.
2.  Execute `db/schema.sql` and `db/sample_data.sql`.
3.  Run the statements in `experiment.sql` to observe the performance differences.

## Findings
The investigation confirmed that putting equality filters (e.g., `department = 'Sales'`) before range filters (e.g., `salary > 50000`) in a composite index significantly improves query performance by allowing the database to more effectively narrow down the search space.
