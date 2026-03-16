# Supabase RLS (Row Level Security) Guide

## 🔍 How to Check if RLS is Enabled

### Method 1: Supabase Dashboard (Easiest)

1. **Go to Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select your project: `inlzhosqbccyynofbmjt`

2. **Navigate to Table Editor**
   - Click "Table Editor" in the left sidebar
   - Select `user_profiles` table
   - Look for **"RLS Enabled"** toggle at the top
   - ✅ **ON** = RLS is enabled
   - ❌ **OFF** = RLS is disabled (needs to be enabled)

3. **Repeat for `user_subscriptions` table**
   - Select `user_subscriptions` table
   - Check "RLS Enabled" toggle

### Method 2: SQL Editor

1. **Go to SQL Editor** in Supabase Dashboard
2. **Run this query**:
   ```sql
   SELECT 
     schemaname,
     tablename,
     rowsecurity as rls_enabled
   FROM pg_tables
   WHERE schemaname = 'public'
     AND tablename IN ('user_profiles', 'user_subscriptions');
   ```
3. **Check results**:
   - `rls_enabled = true` ✅ RLS is enabled
   - `rls_enabled = false` ❌ RLS is disabled

## ✅ How to Enable RLS

### Step 1: Enable RLS on Tables

```sql
-- Enable RLS on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Enable RLS on user_subscriptions
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
```

### Step 2: Create RLS Policies

#### For `user_profiles` table:

```sql
-- Policy: Users can SELECT their own profile
CREATE POLICY "Users can view own profile"
ON user_profiles FOR SELECT
USING (auth.uid()::text = id::text);

-- Policy: Users can UPDATE their own profile
CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
USING (auth.uid()::text = id::text);

-- Policy: Users can INSERT their own profile
CREATE POLICY "Users can insert own profile"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid()::text = id::text);

-- Policy: Users can DELETE their own profile
CREATE POLICY "Users can delete own profile"
ON user_profiles FOR DELETE
USING (auth.uid()::text = id::text);
```

#### For `user_subscriptions` table:

```sql
-- Policy: Users can SELECT their own subscriptions
CREATE POLICY "Users can view own subscriptions"
ON user_subscriptions FOR SELECT
USING (auth.uid()::text = user_id::text);

-- Policy: Users can INSERT their own subscriptions
CREATE POLICY "Users can insert own subscriptions"
ON user_subscriptions FOR INSERT
WITH CHECK (auth.uid()::text = user_id::text);

-- Policy: Users can UPDATE their own subscriptions
CREATE POLICY "Users can update own subscriptions"
ON user_subscriptions FOR UPDATE
USING (auth.uid()::text = user_id::text);
```

## 🔧 How to Check Existing Policies

Run this query in SQL Editor:

```sql
-- Check policies for user_profiles
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('user_profiles', 'user_subscriptions')
ORDER BY tablename, policyname;
```

## ⚠️ Important Notes

1. **UUID Format**: Ensure `id` and `user_id` columns are `uuid` type
2. **Auth.uid()**: This function returns the current authenticated user's ID
3. **Type Casting**: Use `::text` to ensure UUID comparison works correctly
4. **Test After Setup**: Sign in and try to save data to verify RLS works

## 🧪 Testing RLS

1. **Sign in** to your app
2. **Try to save** user profile
3. **Check Supabase logs** for any 401 errors
4. **Verify data** appears in `user_profiles` table with correct `id`

---

## 📺 About Supabase Realtime

### Should You Enable Realtime?

**Short Answer**: **No, not needed for your current use case.**

### What is Realtime?

Supabase Realtime allows you to:
- Listen to database changes in real-time
- Get instant updates when data changes
- Build collaborative features

### When to Use Realtime

✅ **Enable if you need**:
- Live chat features
- Collaborative editing
- Real-time notifications
- Live data updates (e.g., live dashboard)

❌ **Don't enable if**:
- You only need basic CRUD operations
- Data sync happens on user action (not continuous)
- You want to reduce costs (Realtime uses more resources)

### For LifeLab App

**Recommendation**: **Don't enable Realtime** because:
- ✅ Your app syncs data when users save (not continuously)
- ✅ No need for real-time collaboration
- ✅ Reduces costs and complexity
- ✅ Current sync mechanism works fine

### How to Check if Realtime is Enabled

1. Go to **Database** → **Replication** in Supabase Dashboard
2. Check if any tables have "Enable Replication" turned ON
3. If OFF, Realtime is disabled (which is fine for your app)
