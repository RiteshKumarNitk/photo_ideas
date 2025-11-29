-- Create a table to store image metadata
create table public.images (
  id uuid default gen_random_uuid() primary key,
  url text not null,
  category text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  user_id uuid references auth.users default auth.uid()
);

-- Enable Row Level Security (RLS)
alter table public.images enable row level security;

-- Create a policy that allows anyone to view images
create policy "Public images are viewable by everyone"
  on public.images for select
  using ( true );

-- Create a policy that allows authenticated users to upload images
-- (You can further restrict this to specific emails if you want strict security)
create policy "Authenticated users can insert images"
  on public.images for insert
  with check ( auth.role() = 'authenticated' );

-- Create a storage bucket for images if it doesn't exist
-- Note: You usually create buckets in the Supabase Dashboard -> Storage
-- But you can try inserting into storage.buckets if you have permissions
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do nothing;

-- Set up storage policies for the 'images' bucket
create policy "Give public access to images"
  on storage.objects for select
  using ( bucket_id = 'images' );

create policy "Allow authenticated uploads"
  on storage.objects for insert
  with check ( bucket_id = 'images' and auth.role() = 'authenticated' );
