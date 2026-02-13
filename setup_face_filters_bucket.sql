-- Create a new public bucket for face filter assets
insert into storage.buckets (id, name, public)
values ('face-filters', 'face-filters', true);

-- Policy: Everyone can view/download filter assets
create policy "Public Access to Face Filters"
  on storage.objects for select
  using ( bucket_id = 'face-filters' );

-- Policy: Only authenticated users can upload assets (e.g. admin)
create policy "Authenticated Export of Face Filters"
  on storage.objects for insert
  with check ( bucket_id = 'face-filters' and auth.role() = 'authenticated' );

-- Policy: Only authenticated users can update assets
create policy "Authenticated Update of Face Filters"
  on storage.objects for update
  using ( bucket_id = 'face-filters' and auth.role() = 'authenticated' );

-- Policy: Only authenticated users can delete assets
create policy "Authenticated Delete of Face Filters"
  on storage.objects for delete
  using ( bucket_id = 'face-filters' and auth.role() = 'authenticated' );
