# Supabase 401 Error - Fix Summary

## 🔍 Problem

The app was getting **401 Unauthorized** errors when accessing Supabase:
```
GET | 401 | /rest/v1/user_subscriptions
Error: PGRST303
```

## ✅ Code Fixes Applied

### 1. **Token Refresh Function** (`refreshAccessToken()`)
- Automatically refreshes expired access tokens using refresh token
- Saves new tokens to UserDefaults
- Handles errors gracefully

### 2. **Automatic 401 Handling** (in `makeRequest()`)
- Detects 401 Unauthorized errors
- Automatically calls `refreshAccessToken()`
- Retries the original request with new token
- Prevents infinite loops (only retries once)

### 3. **Better Error Messages**
- Clear messages when token refresh fails
- Guides users to sign in again if tokens are invalid

## 📋 What You Need to Check in Supabase Dashboard

The 401 error might **also** be caused by **Row Level Security (RLS) policies**. Please verify:

### Step 1: Check RLS is Enabled
1. Go to Supabase Dashboard → Table Editor
2. Select `user_profiles` table
3. Check if "RLS Enabled" is ON
4. Repeat for `user_subscriptions` table

### Step 2: Verify RLS Policies Exist

#### For `user_profiles` table:
```sql
-- Users can SELECT their own profile
CREATE POLICY "Users can view own profile"
ON user_profiles FOR SELECT
USING (auth.uid()::text = id::text);

-- Users can UPDATE their own profile
CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
USING (auth.uid()::text = id::text);

-- Users can INSERT their own profile
CREATE POLICY "Users can insert own profile"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid()::text = id::text);
```

#### For `user_subscriptions` table:
```sql
-- Users can SELECT their own subscriptions
CREATE POLICY "Users can view own subscriptions"
ON user_subscriptions FOR SELECT
USING (auth.uid()::text = user_id::text);

-- Users can INSERT their own subscriptions
CREATE POLICY "Users can insert own subscriptions"
ON user_subscriptions FOR INSERT
WITH CHECK (auth.uid()::text = user_id::text);
```

### Step 3: Check Column Types Match

Ensure UUID columns match:
- `user_profiles.id` should be `uuid` (references `auth.users.id`)
- `user_subscriptions.user_id` should be `uuid` (references `auth.users.id`)

## 🧪 Testing After Fix

1. **Sign in** to the app
2. **Wait** for token to expire (or manually expire it)
3. **Try to sync** data (e.g., save profile)
4. **Check console logs** for:
   - `🔄🔄🔄 REFRESHING ACCESS TOKEN 🔄🔄🔄`
   - `✅✅✅ TOKEN REFRESHED SUCCESSFULLY ✅✅✅`
   - `🔄 Retrying request with refreshed token...`
5. **Verify** data syncs successfully

## ⚠️ Important Notes

- **Token expiration**: Access tokens expire after ~1 hour
- **Refresh tokens**: Usually valid for 30 days
- **RLS policies**: Must be correctly configured
- **UUID format**: Ensure UUIDs match between `auth.users` and tables

## 🔧 If Still Getting 401 Errors

1. **Check Supabase logs** for detailed error messages
2. **Verify RLS policies** are correctly set up
3. **Check token expiration** in Supabase Dashboard → Authentication → Users
4. **Test with fresh sign-in** to get new tokens

## 📝 Files Changed

- `LifeLab/LifeLab/Services/SupabaseService.swift`
  - Added `refreshAccessToken()` function
  - Updated `makeRequest()` to handle 401 errors
  - Added automatic token refresh on 401
