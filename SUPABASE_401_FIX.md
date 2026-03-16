# Supabase 401 Error Fix

## 🔍 Problem Identified

The app is getting **401 Unauthorized** errors when trying to access Supabase:
- Request to `/rest/v1/user_subscriptions` returns 401
- Error code: `PGRST303` (PostgREST error)
- Token appears to be present but may be expired

## ✅ Solution Implemented

### 1. **Token Refresh Logic**
Added `refreshAccessToken()` function that:
- Uses the refresh token to get a new access token
- Automatically saves new tokens to UserDefaults
- Handles errors gracefully

### 2. **Automatic Token Refresh on 401**
Modified `makeRequest()` to:
- Detect 401 Unauthorized errors
- Automatically refresh the access token
- Retry the original request with the new token
- Prevent infinite loops (only retry once)

### 3. **Better Error Handling**
- Clear invalid tokens when refresh fails
- Provide clear error messages to users
- Guide users to sign in again if tokens are invalid

## 🔧 What Changed

### `SupabaseService.swift`
1. **New function**: `refreshAccessToken()` - Refreshes expired tokens
2. **Updated**: `makeRequest()` - Now handles 401 errors automatically
3. **Added**: `shouldRetryOn401` parameter to prevent infinite loops

## 📋 Next Steps for Supabase Dashboard

### Check Row Level Security (RLS) Policies

The 401 error might also be caused by missing RLS policies. Please verify in Supabase Dashboard:

1. **Go to**: Authentication → Policies
2. **Check tables**:
   - `user_profiles`
   - `user_subscriptions`

3. **Verify RLS policies exist**:
   ```sql
   -- Example policy for user_profiles
   CREATE POLICY "Users can view own profile"
   ON user_profiles FOR SELECT
   USING (auth.uid() = id);
   
   CREATE POLICY "Users can update own profile"
   ON user_profiles FOR UPDATE
   USING (auth.uid() = id);
   
   CREATE POLICY "Users can insert own profile"
   ON user_profiles FOR INSERT
   WITH CHECK (auth.uid() = id);
   ```

4. **For user_subscriptions**:
   ```sql
   CREATE POLICY "Users can view own subscriptions"
   ON user_subscriptions FOR SELECT
   USING (auth.uid()::text = user_id::text);
   ```

## 🧪 Testing

After deploying this fix:
1. Sign in to the app
2. Wait for token to expire (or manually expire it)
3. Try to sync data
4. Verify token refresh happens automatically
5. Verify data syncs successfully

## ⚠️ Important Notes

- **Token expiration**: Access tokens typically expire after 1 hour
- **Refresh tokens**: Usually valid for 30 days
- **RLS policies**: Must be correctly configured in Supabase
- **User ID format**: Ensure UUIDs match between auth.users and tables
