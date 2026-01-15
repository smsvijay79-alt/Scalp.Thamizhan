-- Razorpay Payment Integration Setup

-- 1. Create the payments table for automated storage
-- This table stores all successful payments from Razorpay
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    user_email TEXT,
    plan_name TEXT,
    amount NUMERIC,
    razorpay_payment_id TEXT UNIQUE, -- Store Razorpay payment ID for tracking
    status TEXT DEFAULT 'paid', -- Status is 'paid' immediately upon successful Razorpay callback
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Enable Row Level Security
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies

-- Users can view their own successful payments
CREATE POLICY "Users can view their own payments" 
ON public.payments 
FOR SELECT 
USING (auth.uid() = user_id);

-- Users can insert their own payments after successful gateway callback
CREATE POLICY "Users can insert their own payments" 
ON public.payments 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- 4. Video Access logic (No changes needed if it uses verified/paid status)
CREATE TABLE IF NOT EXISTS public.videos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT,
    url TEXT,
    plan_required TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;

-- Everyone can view videos if they have a 'paid' or 'verified' status for that plan
CREATE POLICY "Users can view videos of paid plans" 
ON public.videos 
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.payments 
        WHERE payments.user_id = auth.uid() 
        AND (payments.status = 'paid' OR payments.status = 'verified') 
        AND payments.plan_name = videos.plan_required
    )
);
