# PostgREST Schema Cache Refresh Guide

## 🔍 What is PostgREST Schema Cache?

PostgREST (PostgreSQL REST API) caches the database schema to improve performance. When you add or modify columns, the cache needs to refresh to recognize the changes.

## ⏱️ Automatic Refresh

**Good news**: PostgREST schema cache refreshes **automatically** every 1-5 minutes. You don't need to do anything manually!

## ✅ After Running SQL Migrations

1. **Wait 1-5 minutes** after running SQL scripts
2. The schema cache will refresh automatically
3. Try syncing data from the app again

## 🔧 Manual Refresh Options (if needed)

### Option 1: Wait (Recommended)
- **Easiest**: Just wait 1-5 minutes
- Schema cache refreshes automatically
- No action needed

### Option 2: Check Supabase Dashboard
- Go to **Supabase Dashboard → Settings → API**
- Look for any "Refresh" or "Restart" options
- **Note**: Not all Supabase plans have this option visible
- If you don't see it, use Option 1 (wait)

### Option 3: Make a Test Query
Sometimes making a simple query can trigger cache refresh:
```sql
-- Run this in SQL Editor
SELECT * FROM user_profiles LIMIT 1;
```

### Option 4: Contact Support
If schema cache issues persist after waiting:
- Contact Supabase Support
- They can manually refresh the cache

## 🧪 Verify Schema is Updated

After waiting a few minutes, verify the schema:

```sql
-- Check if columns exist
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'user_profiles'
ORDER BY ordinal_position;
```

Expected columns (snake_case):
- `id`
- `basic_info`
- `interests`
- `strengths`
- `values`
- `flow_diary_entries`
- `values_questions`
- `resource_inventory`
- `acquired_strengths`
- `feasibility_assessment`
- `life_blueprint`
- `life_blueprints`
- `action_plan`
- `last_blueprint_generation_time`

## 📝 Summary

**You don't need to manually restart PostgREST!**

Just:
1. ✅ Run the SQL migration script
2. ⏱️ Wait 1-5 minutes
3. 🧪 Test data sync from the app

The schema cache will refresh automatically. If you still see errors after 5 minutes, contact Supabase support.
