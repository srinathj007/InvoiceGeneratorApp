-- =====================================================
-- SQL Commands to Link Invoices to Business Profiles
-- Run these commands in your Supabase SQL Editor
-- =====================================================

-- Step 1: Remove the unique constraint on user_id (if not already done)
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_user_id_key;

-- Step 2: Add profile_id column to invoices table
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE;

-- Step 3: Create index for better performance
CREATE INDEX IF NOT EXISTS idx_invoices_profile_id ON invoices(profile_id);

-- Step 4: Update existing invoices to link to user's first profile (migration)
-- This will assign all existing invoices to the user's first profile
UPDATE invoices 
SET profile_id = (
  SELECT id 
  FROM profiles 
  WHERE profiles.user_id = invoices.user_id 
  LIMIT 1
)
WHERE profile_id IS NULL;

-- Step 5: Make profile_id NOT NULL after migration
ALTER TABLE invoices ALTER COLUMN profile_id SET NOT NULL;

-- Step 6: Update RLS policies to use profile_id instead of user_id

-- Drop old policies
DROP POLICY IF EXISTS "Invoices: select own" ON invoices;
DROP POLICY IF EXISTS "Invoices: insert own" ON invoices;
DROP POLICY IF EXISTS "Invoices: update own" ON invoices;
DROP POLICY IF EXISTS "Invoices: delete own" ON invoices;

-- Create new policies based on profile_id
CREATE POLICY "Invoices: select own profile"
ON invoices
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = invoices.profile_id 
    AND profiles.user_id = auth.uid()
  )
);

CREATE POLICY "Invoices: insert own profile"
ON invoices
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = invoices.profile_id 
    AND profiles.user_id = auth.uid()
  )
);

CREATE POLICY "Invoices: update own profile"
ON invoices
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = invoices.profile_id 
    AND profiles.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = invoices.profile_id 
    AND profiles.user_id = auth.uid()
  )
);

CREATE POLICY "Invoices: delete own profile"
ON invoices
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.id = invoices.profile_id 
    AND profiles.user_id = auth.uid()
  )
);

-- =====================================================
-- DONE! Now each invoice is linked to a specific business profile
-- =====================================================
