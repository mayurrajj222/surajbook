-- ==============================================================================
-- SUPABASE POSTGRESQL SCHEMA FOR SURAJBOOK / VYPAAR FLUTTER APP
-- ==============================================================================

-- 1. COMPANIES TABLE
CREATE TABLE IF NOT EXISTS public.companies (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PARTIES TABLE (Customers, Members, Suppliers, Distributors)
CREATE TABLE IF NOT EXISTS public.parties (
    id TEXT PRIMARY KEY,
    company_id TEXT REFERENCES public.companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT DEFAULT '',
    address TEXT DEFAULT '',
    email TEXT DEFAULT '',
    opening_balance NUMERIC DEFAULT 0.0,
    current_balance NUMERIC DEFAULT 0.0,
    type TEXT NOT NULL, -- 'youWillGet' or 'youWillGive'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. INVENTORY ITEMS TABLE (Products & Services)
CREATE TABLE IF NOT EXISTS public.inventory_items (
    id TEXT PRIMARY KEY,
    company_id TEXT REFERENCES public.companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'product', -- 'product' or 'service'
    stock NUMERIC DEFAULT 0.0,
    sale_price NUMERIC DEFAULT 0.0,
    purchase_price NUMERIC DEFAULT 0.0,
    unit TEXT DEFAULT 'PCS',
    code TEXT DEFAULT '',
    category TEXT DEFAULT 'Others',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. BANK ACCOUNTS TABLE (Cash registers & Bank accounts)
CREATE TABLE IF NOT EXISTS public.bank_accounts (
    id TEXT PRIMARY KEY,
    company_id TEXT REFERENCES public.companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    account_number TEXT DEFAULT '',
    balance NUMERIC DEFAULT 0.0,
    is_cash BOOLEAN DEFAULT FALSE,
    print_on_invoice BOOLEAN DEFAULT FALSE,
    print_upi_on_invoice BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TRANSACTIONS TABLE (Sales, Purchases, Payments, Expenses, Orders, Challans, Estimates)
CREATE TABLE IF NOT EXISTS public.transactions (
    id TEXT PRIMARY KEY,
    company_id TEXT REFERENCES public.companies(id) ON DELETE CASCADE,
    party_id TEXT DEFAULT '',
    party_name TEXT DEFAULT '',
    type TEXT NOT NULL, -- 'sale', 'purchase', 'paymentIn', 'paymentOut', 'expense', 'saleReturn', 'purchaseReturn', 'purchaseOrder', 'estimate', 'deliveryChallan'
    amount NUMERIC DEFAULT 0.0,
    date TIMESTAMPTZ DEFAULT NOW(),
    description TEXT DEFAULT '',
    invoice_no TEXT DEFAULT '',
    payment_type TEXT DEFAULT 'Credit',
    items_json JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. APP SETTINGS & ONLINE STORE TABLE
CREATE TABLE IF NOT EXISTS public.app_settings (
    id TEXT PRIMARY KEY,
    company_id TEXT REFERENCES public.companies(id) ON DELETE CASCADE,
    is_online_store_enabled BOOLEAN DEFAULT TRUE,
    online_store_name TEXT DEFAULT 'Suraj Book Store Online',
    online_store_whatsapp TEXT DEFAULT '9876543210',
    online_store_delivery_fee NUMERIC DEFAULT 40.0,
    invoice_theme TEXT DEFAULT 'Modern Indigo',
    invoice_show_gst BOOLEAN DEFAULT TRUE,
    invoice_show_qr BOOLEAN DEFAULT TRUE,
    invoice_show_signature BOOLEAN DEFAULT TRUE,
    invoice_terms_and_conditions TEXT DEFAULT '1. Goods once sold will not be taken back.\n2. Subject to local jurisdiction.',
    is_cloud_sync_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- INDEXES FOR MAXIMUM QUERY PERFORMANCE
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_parties_company_id ON public.parties(company_id);
CREATE INDEX IF NOT EXISTS idx_inventory_items_company_id ON public.inventory_items(company_id);
CREATE INDEX IF NOT EXISTS idx_bank_accounts_company_id ON public.bank_accounts(company_id);
CREATE INDEX IF NOT EXISTS idx_transactions_company_id ON public.transactions(company_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON public.transactions(type);
CREATE INDEX IF NOT EXISTS idx_app_settings_company_id ON public.app_settings(company_id);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Permissive policies allowing read, insert, update, delete for the app
-- ==============================================================================

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

-- Companies policies
DROP POLICY IF EXISTS "Allow all access to companies" ON public.companies;
CREATE POLICY "Allow all access to companies" ON public.companies FOR ALL USING (true) WITH CHECK (true);

-- Parties policies
DROP POLICY IF EXISTS "Allow all access to parties" ON public.parties;
CREATE POLICY "Allow all access to parties" ON public.parties FOR ALL USING (true) WITH CHECK (true);

-- Inventory items policies
DROP POLICY IF EXISTS "Allow all access to inventory_items" ON public.inventory_items;
CREATE POLICY "Allow all access to inventory_items" ON public.inventory_items FOR ALL USING (true) WITH CHECK (true);

-- Bank accounts policies
DROP POLICY IF EXISTS "Allow all access to bank_accounts" ON public.bank_accounts;
CREATE POLICY "Allow all access to bank_accounts" ON public.bank_accounts FOR ALL USING (true) WITH CHECK (true);

-- Transactions policies
DROP POLICY IF EXISTS "Allow all access to transactions" ON public.transactions;
CREATE POLICY "Allow all access to transactions" ON public.transactions FOR ALL USING (true) WITH CHECK (true);

-- App settings policies
DROP POLICY IF EXISTS "Allow all access to app_settings" ON public.app_settings;
CREATE POLICY "Allow all access to app_settings" ON public.app_settings FOR ALL USING (true) WITH CHECK (true);

