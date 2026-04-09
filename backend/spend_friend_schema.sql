-- spend_friend_schema.sql

-- 0. Create a public users table for metadata
CREATE TABLE IF NOT EXISTS public.users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    apple_id TEXT UNIQUE,
    email TEXT UNIQUE,
    full_name TEXT,
    last_login TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 1. Create a table to store users' financial API connections securely
CREATE TABLE IF NOT EXISTS public.financial_connections (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    plaid_access_token TEXT,
    plaid_item_id TEXT UNIQUE,
    alpaca_api_key TEXT,
    alpaca_secret_key TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 2. Create a table for Investment Rules (Brands that trigger purchases)
CREATE TABLE IF NOT EXISTS public.investment_rules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    brand_name TEXT NOT NULL, -- e.g. "Starbucks"
    stock_ticker TEXT NOT NULL, -- e.g. "SBUX"
    investment_amount NUMERIC NOT NULL, -- e.g. 5.00
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create a table for tracking automated orders
CREATE TABLE IF NOT EXISTS public.automated_investments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    plaid_transaction_id TEXT,
    alpaca_order_id TEXT,
    ticker TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.financial_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.automated_investments ENABLE ROW LEVEL SECURITY;

-- Security Policies (Users can only read/edit their own data)
CREATE POLICY "Users can manage their own rules" 
    ON public.investment_rules FOR ALL 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own investments" 
    ON public.automated_investments FOR SELECT 
    USING (auth.uid() = user_id);

-- Note: 'financial_connections' holds sensitive API keys.
-- We restrict access so ONLY the service role (backend) can read/write access tokens.
CREATE POLICY "Users can INSERT connection info" 
    ON public.financial_connections FOR INSERT 
    WITH CHECK (auth.uid() = user_id);
