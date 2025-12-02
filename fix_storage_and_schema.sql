-- Create 'images' bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- Policy to allow public viewing of images
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'images' );

-- Policy to allow authenticated users to upload images
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'images' AND auth.role() = 'authenticated' );

-- Policy to allow authenticated users to update their own images (or all images if admin)
-- For simplicity, allowing authenticated users to update images in the 'images' bucket
CREATE POLICY "Authenticated Update"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'images' AND auth.role() = 'authenticated' );

-- Policy to allow authenticated users to delete images
CREATE POLICY "Authenticated Delete"
ON storage.objects FOR DELETE
USING ( bucket_id = 'images' AND auth.role() = 'authenticated' );

-- Add new columns to 'images' table
ALTER TABLE images ADD COLUMN IF NOT EXISTS sub_category TEXT;
ALTER TABLE images ADD COLUMN IF NOT EXISTS posing_instructions TEXT;

-- Add new columns to 'quotes' table
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS category TEXT;

-- Update RLS policies for 'images' table to include new columns if necessary
-- (Existing policies usually cover all columns, but good to verify)
-- Assuming existing policies are like "Enable read access for all users" and "Enable insert for authenticated users only"

-- Ensure 'quotes' table has RLS enabled and policies
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY
CREATE POLICY "Public quotes access"
ON quotes FOR SELECT
USING ( true );

CREATE POLICY "Authenticated quotes insert"
ON quotes FOR INSERT
WITH CHECK ( auth.role() = 'authenticated' );

CREATE POLICY "Authenticated quotes update"
ON quotes FOR UPDATE
USING ( auth.role() = 'authenticated' );

CREATE POLICY "Authenticated quotes delete"
ON quotes FOR DELETE
USING ( auth.role() = 'authenticated' );
