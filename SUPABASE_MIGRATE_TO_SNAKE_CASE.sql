-- Migration Script: Convert camelCase columns to snake_case
-- Run this if you already have a user_profiles table with camelCase columns
-- This script will rename columns to match Swift's convertToSnakeCase strategy

-- Step 1: Check if table exists and has camelCase columns
DO $$
BEGIN
  -- Check if basicInfo column exists (camelCase)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_profiles' AND column_name = 'basicInfo'
  ) THEN
    RAISE NOTICE 'Found camelCase columns. Starting migration...';
    
    -- Rename columns from camelCase to snake_case
    ALTER TABLE user_profiles RENAME COLUMN "basicInfo" TO basic_info;
    RAISE NOTICE 'Renamed basicInfo → basic_info';
    
    -- Rename other camelCase columns if they exist
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'flowDiaryEntries') THEN
      ALTER TABLE user_profiles RENAME COLUMN "flowDiaryEntries" TO flow_diary_entries;
      RAISE NOTICE 'Renamed flowDiaryEntries → flow_diary_entries';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'valuesQuestions') THEN
      ALTER TABLE user_profiles RENAME COLUMN "valuesQuestions" TO values_questions;
      RAISE NOTICE 'Renamed valuesQuestions → values_questions';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'resourceInventory') THEN
      ALTER TABLE user_profiles RENAME COLUMN "resourceInventory" TO resource_inventory;
      RAISE NOTICE 'Renamed resourceInventory → resource_inventory';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'acquiredStrengths') THEN
      ALTER TABLE user_profiles RENAME COLUMN "acquiredStrengths" TO acquired_strengths;
      RAISE NOTICE 'Renamed acquiredStrengths → acquired_strengths';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'feasibilityAssessment') THEN
      ALTER TABLE user_profiles RENAME COLUMN "feasibilityAssessment" TO feasibility_assessment;
      RAISE NOTICE 'Renamed feasibilityAssessment → feasibility_assessment';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'lifeBlueprint') THEN
      ALTER TABLE user_profiles RENAME COLUMN "lifeBlueprint" TO life_blueprint;
      RAISE NOTICE 'Renamed lifeBlueprint → life_blueprint';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'lifeBlueprints') THEN
      ALTER TABLE user_profiles RENAME COLUMN "lifeBlueprints" TO life_blueprints;
      RAISE NOTICE 'Renamed lifeBlueprints → life_blueprints';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'actionPlan') THEN
      ALTER TABLE user_profiles RENAME COLUMN "actionPlan" TO action_plan;
      RAISE NOTICE 'Renamed actionPlan → action_plan';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'lastBlueprintGenerationTime') THEN
      ALTER TABLE user_profiles RENAME COLUMN "lastBlueprintGenerationTime" TO last_blueprint_generation_time;
      RAISE NOTICE 'Renamed lastBlueprintGenerationTime → last_blueprint_generation_time';
    END IF;
    
    -- Update indexes
    DROP INDEX IF EXISTS idx_user_profiles_basic_info;
    CREATE INDEX IF NOT EXISTS idx_user_profiles_basic_info ON user_profiles USING GIN (basic_info);
    
    RAISE NOTICE '✅ Migration completed successfully!';
  ELSE
    RAISE NOTICE 'No camelCase columns found. Table may already use snake_case or not exist.';
  END IF;
END $$;
