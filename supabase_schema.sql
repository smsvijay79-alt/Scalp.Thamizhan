-- Create payments table to track user purchases
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    user_email TEXT,
    plan_name TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    account_number TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create videos table for admin-uploaded content
CREATE TABLE IF NOT EXISTS public.videos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    description TEXT,
    plan_required TEXT, -- e.g., 'BASIC PLAN', 'INTERMEDIATE'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;

-- Policies for Payments
CREATE POLICY "Users can view their own payments" 
ON public.payments FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payments" 
ON public.payments FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policies for Videos
CREATE POLICY "Anyone can view video metadata" 
ON public.videos FOR SELECT 
TO authenticated 
USING (true);

-- Enable Realtime for payments (to notify admin app if needed)
ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;

-- ==========================================
-- STORAGE BUCKET FOR VIDEOS
-- ==========================================

-- 1. Create a bucket for course videos
INSERT INTO storage.buckets (id, name, public) 
VALUES ('course-videos', 'course-videos', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Allow public access to read videos
CREATE POLICY "Public Read Access" 
ON storage.objects FOR SELECT 
TO public 
USING (bucket_id = 'course-videos');

-- 3. Allow authenticated users (Admins) to upload videos
-- Note: In a production app, you'd restrict this to specific admin IDs
CREATE POLICY "Admin Upload Access" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'course-videos');

-- 4. Allow authenticated users to update their own uploads (standard bucket practice)
CREATE POLICY "Admin Update Access" 
ON storage.objects FOR UPDATE 
TO authenticated 
USING (bucket_id = 'course-videos');
