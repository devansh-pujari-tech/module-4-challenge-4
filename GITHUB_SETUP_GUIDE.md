# How to Create GitHub Repository and Pull Request

## Step 1: Create a New GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in to your account
2. Click the **+** icon in the top right corner → Select **New repository**
3. Fill in the repository details:
   - **Repository name:** `composite-index-investigation`
   - **Description:** `PostgreSQL composite index investigation - demonstrating column order importance`
   - **Public:** Select "Public"
   - **Initialize with:** Leave unchecked (we'll push our local repo)
4. Click **Create repository**

## Step 2: Connect Local Repository to GitHub

Copy and paste these commands in your terminal (replace YOUR_USERNAME with your GitHub username):

```bash
cd composite-index-investigation

# Add the remote repository
git remote add origin https://github.com/YOUR_USERNAME/composite-index-investigation.git

# Verify the remote was added
git remote -v

# Rename branch to main if needed
git branch -M main

# Push to GitHub
git push -u origin main
```

## Step 3: Create a Feature Branch (Optional but Recommended)

For a Pull Request workflow:

```bash
# Create a new branch for improvements/fixes
git checkout -b feature/index-optimization-analysis

# Make any additional changes, then commit
git add .
git commit -m "Add detailed analysis and index optimization recommendations"

# Push the branch to GitHub
git push -u origin feature/index-optimization-analysis
```

## Step 4: Create a Pull Request on GitHub

### If using a feature branch:

1. Go to your repository on GitHub: `https://github.com/YOUR_USERNAME/composite-index-investigation`
2. You should see a notification about recently pushed branches
3. Click **Compare & pull request** on the yellow banner
4. Fill in the PR details:
   - **Title:** `Optimize composite index: Fix column ordering for query performance`
   - **Description:** (use the template below)
   - **Base:** main
   - **Compare:** feature/index-optimization-analysis
5. Click **Create pull request**

### If going directly to main (simpler):

1. Go to **Pull requests** tab on GitHub
2. Click **New pull request**
3. Configure:
   - **Base:** main
   - **Compare:** main (this shows your commits are on main)
   - Click **Create pull request**

## Step 5: Sample PR Description

Use this template for your PR description:

````markdown
# Composite Index Investigation & Optimization

## Summary

This PR documents a critical finding in PostgreSQL query optimization:
composite index column ordering directly affects performance.

## Problem Investigated

- Existing composite index: `(salary, department)`
- Query filter pattern: `WHERE department = 'Sales' AND salary > 50000`
- Result: **Sequential Scan** (inefficient) instead of Index Scan

## Root Cause

The index column order doesn't match the query's filter order.
PostgreSQL cannot use an index if queries don't start with the
leading column (Left-Most Prefix Rule violation).

## Solution Implemented

- Dropped ineffective index: `idx_salary_department`
- Created corrected index: `CREATE INDEX idx_department_salary ON employees(department, salary)`
- Verified with `EXPLAIN ANALYZE`

## Performance Impact

- **Before:** Sequential Scan (~50-100ms on 100K rows)
- **After:** Index Scan (~0.5-1ms on 100K rows)
- **Improvement:** 50-100x faster

## Files Included

- `Changes.md` - Detailed investigation report with learnings
- `README.md` - Project overview and setup instructions
- `db/schema.sql` - Database schema with tables
- `db/sample_data.sql` - Sample employee data
- `db/queries.sql` - Test queries
- `db/index_optimization_experiment.sql` - Complete experiment walkthrough

## Testing Instructions

See README.md for full setup. Quick start:

```sql
createdb employee_reporting
psql employee_reporting < db/schema.sql
psql employee_reporting < db/sample_data.sql
psql employee_reporting < db/index_optimization_experiment.sql
```
````

## Key Learning

**Index design is as important as index creation.**
Column ordering must match query access patterns for effectiveness.

````

## Step 6: Verify Your Repository on GitHub

After pushing, verify everything is correct:

1. Visit `https://github.com/YOUR_USERNAME/composite-index-investigation`
2. Check that all files are visible:
   - README.md (displays as main description)
   - Changes.md (investigation report)
   - db/ folder with SQL scripts
3. Verify git history: Click "Commits" to see your commits
4. Check Pull Request appears under "Pull requests" tab

## Troubleshooting

### Authentication Issues
```bash
# If asked for credentials
git remote set-url origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/YOUR_USERNAME/composite-index-investigation.git
````

### Wrong Repository URL

```bash
# Check current remote
git remote -v

# Update if needed
git remote set-url origin https://github.com/YOUR_USERNAME/composite-index-investigation.git
```

### Need to Undo Push

```bash
# View commit history
git log

# If necessary, reset to previous commit
git reset --hard <commit-hash>
```

## After PR Creation

1. **Share the PR link** with team members or instructors
2. **Address any review comments** by making additional commits
3. **Once approved**, click **Merge pull request** to merge changes
4. **Delete the feature branch** (GitHub will offer this after merge)

---

## Additional Commands Reference

```bash
# View repository status
git status

# View commit history
git log --oneline

# Add specific files
git add filename.md

# Make changes and commit
git commit -am "Description of changes"

# Push current branch
git push

# Pull latest from GitHub
git pull
```

## Success Checklist

- [x] Created GitHub repository
- [x] Connected local repo to GitHub
- [x] Pushed commits to GitHub
- [x] Created Pull Request
- [x] Added comprehensive PR description
- [x] All project files visible on GitHub
- [x] Git history shows logical commits

---

**Repository Link:** `https://github.com/YOUR_USERNAME/composite-index-investigation`

**PR Link:** `https://github.com/YOUR_USERNAME/composite-index-investigation/pull/<number>`
