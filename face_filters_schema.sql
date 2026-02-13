-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the face_filters table
CREATE TABLE face_filters (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  name text NOT NULL,
  type text NOT NULL, -- 'asset' or 'procedural' or 'none'
  icon_url text NOT NULL,
  asset_url text,
  anchor text, 
  scale float DEFAULT 1.0,
  offset_x float DEFAULT 0.0,
  offset_y float DEFAULT 0.0,
  params jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE face_filters ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read filters
CREATE POLICY "Public filters are viewable by everyone" 
ON face_filters FOR SELECT 
USING ( true );

-- Policy: Only authenticated users can insert/update (if needed, or just admin)
CREATE POLICY "Authorized users can insert filters" 
ON face_filters FOR INSERT 
WITH CHECK ( auth.role() = 'authenticated' );

-- Insert some default filters
INSERT INTO face_filters (name, type, icon_url, asset_url, anchor, scale, offset_y)
VALUES 
('Cool Shades', 'asset', 'https://cdn-icons-png.flaticon.com/512/17/17260.png', 'https://i.imgur.com/g3d0J3m.png', 'eyes', 2.5, 0.0),
('Flower Crown', 'asset', 'https://cdn-icons-png.flaticon.com/512/187/187158.png', 'https://i.imgur.com/2X7l3wB.png', 'forehead', 1.8, -50.0),
('Puppy', 'asset', 'https://cdn-icons-png.flaticon.com/512/616/616430.png', 'https://i.imgur.com/c6U7k4P.png', 'forehead', 2.0, -80.0);
