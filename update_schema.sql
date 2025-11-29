-- Add title and subtitle columns to the images table
alter table public.images 
add column if not exists title text,
add column if not exists subtitle text;

-- Update the policy to allow updates for authenticated users
create policy "Authenticated users can update images"
  on public.images for update
  using ( auth.role() = 'authenticated' )
  with check ( auth.role() = 'authenticated' );

-- Update the policy to allow deletions for authenticated users
create policy "Authenticated users can delete images"
  on public.images for delete
  using ( auth.role() = 'authenticated' );
