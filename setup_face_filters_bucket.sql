
-- 1. Create 'face-filters' bucket (safe insert)
INSERT INTO storage.buckets (id, name, public)
VALUES ('face-filters', 'face-filters', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Drop existing policies to avoid "policy already exists" errors
DROP POLICY IF EXISTS "Public Access to Face Filters" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Export of Face Filters" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update of Face Filters" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete of Face Filters" ON storage.objects;

-- 3. Re-create Policies

-- Policy: Everyone can view/download filter assets
CREATE POLICY "Public Access to Face Filters"
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'face-filters' );

-- Policy: Only authenticated users can upload assets
CREATE POLICY "Authenticated Export of Face Filters"
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'face-filters' AND auth.role() = 'authenticated' );

-- Policy: Only authenticated users can update assets
CREATE POLICY "Authenticated Update of Face Filters"
  ON storage.objects FOR UPDATE
  USING ( bucket_id = 'face-filters' AND auth.role() = 'authenticated' );

-- Policy: Only authenticated users can delete assets
CREATE POLICY "Authenticated Delete of Face Filters"
  ON storage.objects FOR DELETE
  USING ( bucket_id = 'face-filters' AND auth.role() = 'authenticated' );
