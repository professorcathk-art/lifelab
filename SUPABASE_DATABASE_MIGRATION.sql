-- Supabase Database Migration Script
-- Add missing columns to user_profiles table
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/YOUR_PROJECT/sql

-- Step 1: Add missing columns for UserProfile structure
-- Note: All JSONB columns allow NULL for optional fields

-- Add acquiredStrengths column (JSONB for nested structure)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "acquiredStrengths" JSONB;

-- Add other potentially missing columns based on UserProfile model
-- Check if these exist, add if missing:

-- Basic Info (nested structure)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "basicInfo" JSONB;

-- Flow Diary Entries (array of objects)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "flowDiaryEntries" JSONB DEFAULT '[]'::jsonb;

-- Values Questions (nested structure)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "valuesQuestions" JSONB;

-- Resource Inventory (nested structure)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "resourceInventory" JSONB;

-- Feasibility Assessment (nested structure)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "feasibilityAssessment" JSONB;

-- Life Blueprint (nested structure)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "lifeBlueprint" JSONB;

-- Life Blueprints (array of blueprints)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "lifeBlueprints" JSONB DEFAULT '[]'::jsonb;

-- Action Plan (nested structure)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "actionPlan" JSONB;

-- Last Blueprint Generation Time (timestamp)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "lastBlueprintGenerationTime" TIMESTAMPTZ;

-- Ensure existing columns exist (if not already present)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "interests" JSONB DEFAULT '[]'::jsonb;

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "strengths" JSONB DEFAULT '[]'::jsonb;

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "values" JSONB DEFAULT '[]'::jsonb;

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMPTZ DEFAULT NOW();

-- Step 2: Verify the table structure
-- Run this query to see all columns:
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'user_profiles'
-- ORDER BY column_name;

-- Step 3: Grant necessary permissions (if needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON user_profiles TO authenticated;
-- GRANT USAGE ON SEQUENCE user_profiles_id_seq TO authenticated;
