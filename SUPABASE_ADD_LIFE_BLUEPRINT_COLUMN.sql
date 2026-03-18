-- CRITICAL: Add life_blueprint and related columns if they don't exist
-- Run this in Supabase Dashboard → SQL Editor
-- Error "Could not find the 'life_blueprint' column" means your table was created before these columns were added

-- Add life_blueprint column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_profiles' AND column_name = 'life_blueprint'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN life_blueprint JSONB;
    RAISE NOTICE '✅ Added life_blueprint column';
  ELSE
    RAISE NOTICE 'ℹ️ life_blueprint column already exists';
  END IF;
END $$;

-- Add life_blueprints column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_profiles' AND column_name = 'life_blueprints'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN life_blueprints JSONB;
    RAISE NOTICE '✅ Added life_blueprints column';
  ELSE
    RAISE NOTICE 'ℹ️ life_blueprints column already exists';
  END IF;
END $$;

-- Add action_plan column if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_profiles' AND column_name = 'action_plan'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN action_plan JSONB;
    RAISE NOTICE '✅ Added action_plan column';
  ELSE
    RAISE NOTICE 'ℹ️ action_plan column already exists';
  END IF;
END $$;

-- Verify
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
ORDER BY ordinal_position;
