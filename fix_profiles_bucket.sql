-- Create 'profiles' bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Policy to allow public viewing of profiles
CREATE POLICY "Public Access Profiles"
ON storage.objects FOR SELECT
USING ( bucket_id = 'profiles' );

-- Policy to allow authenticated users to upload their own profile pictures
CREATE POLICY "Authenticated Upload Profiles"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'profiles' AND auth.role() = 'authenticated' );

-- Policy to allow authenticated users to update their own profile pictures
CREATE POLICY "Authenticated Update Profiles"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'profiles' AND auth.role() = 'authenticated' );

-- Policy to allow authenticated users to delete their own profile pictures
CREATE POLICY "Authenticated Delete Profiles"
ON storage.objects FOR DELETE
USING ( bucket_id = 'profiles' AND auth.role() = 'authenticated' );
