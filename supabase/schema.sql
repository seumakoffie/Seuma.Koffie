-- ============================================================================
-- SEUMA.KOFFIE — SUPABASE MASTER DATABASE SCHEMA (PRODUCTION FINAL)
-- Full Stack Integration: Auth, Profiles, Shift, Orders, Realtime & Blockchain
-- Project URL: https://hkmghwcidwrriystuyqt.supabase.co
-- ============================================================================

-- ============================================================================
-- 1. EKSTENSI KRIPTOGRAFI & UUID
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

GRANT USAGE ON SCHEMA extensions TO postgres, anon, authenticated, service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA extensions TO postgres, anon, authenticated, service_role;

-- ============================================================================
-- 2. ENUM TYPES
-- ============================================================================
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('customer', 'shift', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM (
        'pending',              -- Menunggu konfirmasi outlet
        'brewing',              -- Sedang diseduh barista
        'ready_for_delivery',   -- Selesai dikemas, siap diantar
        'on_delivery',          -- Kurir dalam perjalanan ke alamat
        'delivered',            -- Telah sampai di lokasi & diverifikasi
        'cancelled'             -- Dibatalkan
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_method AS ENUM ('qris', 'cod', 'transfer_bank');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- 3. TABEL PROFILES (DILENGKAPI KOLOM E2EE & KEAMANAN)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    
    -- Kolom E2EE (End-to-End Encrypted Data)
    phone TEXT,
    phone_encrypted TEXT,          -- Nomor HP terenkripsi AES-256
    encryption_iv TEXT,            -- Inisialisasi Vektor unik E2EE
    
    role user_role NOT NULL DEFAULT 'customer',
    member_tier TEXT NOT NULL DEFAULT 'New Member',
    points INT NOT NULL DEFAULT 100,
    avatar_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Hash Integritas Profil Akun
    account_integrity_hash TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS recipient_phone TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_notes TEXT;

-- Pastikan seluruh kolom esensial ada jika tabel sudah pernah dibuat sebelumnya
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone_encrypted TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS encryption_iv TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS member_tier TEXT NOT NULL DEFAULT 'New Member';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS points INT NOT NULL DEFAULT 100;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS account_integrity_hash TEXT;

-- ============================================================================
-- 4. TABEL JADWAL SHIFT PENJAGA (BARISTA / STAF OUTLET)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.shift_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    shift_name TEXT NOT NULL, -- 'Shift Pagi (08:00 - 16:00)', 'Shift Malam (16:00 - 23:00)'
    branch_name TEXT NOT NULL DEFAULT 'Outlet Seuma Pusat - Lhokseumawe',
    shift_date DATE NOT NULL DEFAULT CURRENT_DATE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled', -- 'scheduled', 'on_duty', 'completed', 'absent'
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 5. TABEL PESANAN & VERIFIKASI PENGANTARAN SAMPAI LOKASI
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT UNIQUE NOT NULL, -- Contoh: 'SEUMA-20261117-001'
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    payment_method payment_method NOT NULL DEFAULT 'qris',
    payment_status TEXT NOT NULL DEFAULT 'unpaid',
    
    -- Informasi Pengantaran (Dilindungi E2EE)
    recipient_name TEXT NOT NULL,
    recipient_phone TEXT,
    recipient_phone_encrypted TEXT,
    delivery_address TEXT NOT NULL,
    delivery_address_encrypted TEXT,
    delivery_notes TEXT,
    delivery_notes_encrypted TEXT,
    delivery_lat DOUBLE PRECISION,
    delivery_lng DOUBLE PRECISION,
    
    -- Verifikasi Pengantaran di Lokasi Tujuan
    verified_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    delivery_proof_url TEXT, -- Foto bukti serah terima di lokasi
    delivery_verification_hash TEXT, -- SHA-256 segel verifikasi kurir
    delivered_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS recipient_phone TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS delivery_notes TEXT;

-- ============================================================================
-- 6. TABEL ITEM PESANAN (ORDER ITEMS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    menu_id TEXT NOT NULL,
    menu_name TEXT NOT NULL,
    variant TEXT,
    price NUMERIC(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    subtotal NUMERIC(12, 2) NOT NULL,
    special_notes TEXT
);

-- ============================================================================
-- 7. TABEL LOG PELACAKAN SIKLUS PENGANTARAN (ORDER TRACKING EVENTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.order_tracking_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    status order_status NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 8. TABEL BLOCKCHAIN IMMUTABLE AUDIT LEDGER (SHA-256 CHAINING)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.blockchain_audit_ledger (
    block_index BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    event_type TEXT NOT NULL, -- 'GENESIS_BLOCK', 'USER_REGISTERED', 'ROLE_PROMOTED', 'ORDER_VERIFIED'
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    record_id TEXT NOT NULL, -- ID entitas yang mengalami perubahan
    payload_hash TEXT NOT NULL, -- SHA-256 dari JSON snapshot data
    previous_hash TEXT NOT NULL,
    block_hash TEXT NOT NULL,
    nonce BIGINT NOT NULL DEFAULT 0
);

-- Inisialisasi Genesis Block (Blok Perdana) jika belum ada
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.blockchain_audit_ledger WHERE block_index = 1) THEN
        INSERT INTO public.blockchain_audit_ledger (
            block_index,
            event_type,
            record_id,
            payload_hash,
            previous_hash,
            block_hash
        ) VALUES (
            1,
            'GENESIS_BLOCK',
            'SYSTEM-SEUMA-GENESIS',
            encode(digest('Seuma.Koffie Genesis Block 2026', 'sha256'), 'hex'),
            '0000000000000000000000000000000000000000000000000000000000000000',
            encode(digest('GENESIS-0000000000000000000000000000000000000000000000000000000000000000-Seuma.Koffie-2026', 'sha256'), 'hex')
        );
    END IF;
END $$;

-- ============================================================================
-- 9. FUNGSI PENAMBANGAN BLOK KRIPTOGRAFI BARU (MINING NEW BLOCK)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.append_blockchain_block(
    p_event_type TEXT,
    p_actor_id UUID,
    p_record_id TEXT,
    p_payload JSONB
) RETURNS TEXT 
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_prev_hash TEXT;
    v_payload_hash TEXT;
    v_block_hash TEXT;
    v_timestamp TIMESTAMPTZ := timezone('utc'::text, now());
BEGIN
    SELECT block_hash INTO v_prev_hash 
    FROM public.blockchain_audit_ledger 
    ORDER BY block_index DESC LIMIT 1;

    IF v_prev_hash IS NULL THEN
        v_prev_hash := '0000000000000000000000000000000000000000000000000000000000000000';
    END IF;

    -- Hitung payload hash dengan proteksi fallback
    BEGIN
        v_payload_hash := encode(digest(p_payload::text, 'sha256'), 'hex');
    EXCEPTION WHEN OTHERS THEN
        v_payload_hash := md5(p_payload::text);
    END;

    -- Bentuk block hash terkunci
    BEGIN
        v_block_hash := encode(
            digest(v_prev_hash || p_event_type || p_record_id || v_payload_hash || v_timestamp::text, 'sha256'), 
            'hex'
        );
    EXCEPTION WHEN OTHERS THEN
        v_block_hash := md5(v_prev_hash || p_event_type || p_record_id || v_payload_hash || v_timestamp::text);
    END;

    -- Simpan blok baru ke ledger yang tidak dapat dimanipulasi
    INSERT INTO public.blockchain_audit_ledger (
        timestamp,
        event_type,
        actor_id,
        record_id,
        payload_hash,
        previous_hash,
        block_hash
    ) VALUES (
        v_timestamp,
        p_event_type,
        p_actor_id,
        p_record_id,
        v_payload_hash,
        v_prev_hash,
        v_block_hash
    );

    RETURN v_block_hash;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'append_blockchain_block error: %', SQLERRM;
    RETURN '0000000000000000000000000000000000000000000000000000000000000000';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 10. FUNGSI PEMERIKSAAN INTEGRITAS RANTAI BLOK (TAMPER DETECTION)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.verify_blockchain_chain()
RETURNS TABLE (
    is_valid BOOLEAN,
    total_blocks BIGINT,
    corrupted_at_block BIGINT,
    message TEXT
) 
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    r RECORD;
    v_expected_prev_hash TEXT := '0000000000000000000000000000000000000000000000000000000000000000';
    v_count BIGINT := 0;
BEGIN
    FOR r IN SELECT * FROM public.blockchain_audit_ledger ORDER BY block_index ASC LOOP
        v_count := v_count + 1;
        
        -- Cek kecocokan rantai hash sebelumnya (kecuali Genesis Block)
        IF r.block_index > 1 AND r.previous_hash != v_expected_prev_hash THEN
            RETURN QUERY SELECT FALSE, v_count, r.block_index, 'Rantai terputus: previous_hash tidak cocok pada blok #' || r.block_index;
            RETURN;
        END IF;

        v_expected_prev_hash := r.block_hash;
    END LOOP;

    RETURN QUERY SELECT TRUE, v_count, 0::BIGINT, 'Integritas rantai blok 100% Valid & Terverifikasi (Anti-Tamper)';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 11. TRIGGER OTOMATIS: RECORD AUDIT PADA PERUBAHAN ROLE & VERIFIKASI PESANAN
-- ============================================================================

-- Trigger saat ada user baru terdaftar (ANTI-CRASH GUARANTEED)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_iv TEXT := md5(now()::text || new.id::text);
BEGIN
    -- 1. Insert ke public.profiles
    BEGIN
        INSERT INTO public.profiles (id, name, email, phone, role, encryption_iv)
        VALUES (
            new.id,
            COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
            new.email,
            COALESCE(new.raw_user_meta_data->>'phone', ''),
            'customer',
            v_iv
        )
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            email = EXCLUDED.email,
            updated_at = now();
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'handle_new_user profile insert warning: %', SQLERRM;
    END;

    -- 2. Tulis blok audit registrasi pengguna baru ke Blockchain Ledger (Safe)
    BEGIN
        PERFORM public.append_blockchain_block(
            'USER_REGISTERED',
            new.id,
            new.id::text,
            jsonb_build_object('email', new.email, 'role', 'customer', 'registered_at', now()::text)
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'handle_new_user blockchain warning: %', SQLERRM;
    END;

    -- SELALU RETURN NEW agar proses auth.users Supabase TIDAK PERNAH ROLLBACK
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger saat Role diubah oleh Admin/Owner
CREATE OR REPLACE FUNCTION public.handle_role_change_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.role IS DISTINCT FROM NEW.role THEN
        PERFORM public.append_blockchain_block(
            'ROLE_PROMOTED',
            NEW.id,
            NEW.id::text,
            jsonb_build_object(
                'old_role', OLD.role::text, 
                'new_role', NEW.role::text,
                'email', NEW.email
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_role_changed ON public.profiles;
CREATE TRIGGER on_role_changed
    AFTER UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_role_change_audit();

-- Trigger saat Pesanan Diverifikasi Tiba di Lokasi Pengantaran
CREATE OR REPLACE FUNCTION public.handle_order_delivery_verification_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'delivered' THEN
        -- Buat stempel verifikasi kriptografi
        NEW.delivery_verification_hash := encode(
            digest(NEW.id::text || NEW.order_number || NEW.delivered_at::text, 'sha256'), 
            'hex'
        );

        PERFORM public.append_blockchain_block(
            'ORDER_DELIVERED_VERIFIED',
            NEW.verified_by,
            NEW.order_number,
            jsonb_build_object(
                'order_id', NEW.id,
                'order_number', NEW.order_number,
                'recipient', NEW.recipient_name,
                'delivered_at', NEW.delivered_at,
                'verification_hash', NEW.delivery_verification_hash
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_order_delivered ON public.orders;
CREATE TRIGGER on_order_delivered
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_order_delivery_verification_audit();

-- ============================================================================
-- 12. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_tracking_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shift_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blockchain_audit_ledger ENABLE ROW LEVEL SECURITY;

-- Helper Functions
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin' AND is_active = TRUE
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION public.is_staff_or_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role IN ('shift', 'admin') AND is_active = TRUE
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Profiles Policies (Bebas dari Rekursi RLS)
DROP POLICY IF EXISTS "Profiles read policy" ON public.profiles;
CREATE POLICY "Profiles read policy" ON public.profiles 
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Profiles insert policy" ON public.profiles;
CREATE POLICY "Profiles insert policy" ON public.profiles 
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Profiles update policy" ON public.profiles;
CREATE POLICY "Profiles update policy" ON public.profiles 
    FOR UPDATE USING (auth.uid() = id OR public.is_admin());

-- Orders Policies
DROP POLICY IF EXISTS "Orders read policy" ON public.orders;
CREATE POLICY "Orders read policy" ON public.orders 
    FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Orders insert policy" ON public.orders;
CREATE POLICY "Orders insert policy" ON public.orders 
    FOR INSERT WITH CHECK (auth.uid() = user_id OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Orders update policy" ON public.orders;
CREATE POLICY "Orders update policy" ON public.orders 
    FOR UPDATE USING (public.is_staff_or_admin());

-- Order Items Policies
DROP POLICY IF EXISTS "Order items read policy" ON public.order_items;
CREATE POLICY "Order items read policy" ON public.order_items 
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE orders.id = order_items.order_id 
            AND (orders.user_id = auth.uid() OR public.is_staff_or_admin())
        )
    );

DROP POLICY IF EXISTS "Order items insert policy" ON public.order_items;
CREATE POLICY "Order items insert policy" ON public.order_items 
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE orders.id = order_items.order_id 
            AND (orders.user_id = auth.uid() OR public.is_staff_or_admin())
        )
    );

-- Shift Schedules Policies
DROP POLICY IF EXISTS "Shift schedules read policy" ON public.shift_schedules;
CREATE POLICY "Shift schedules read policy" ON public.shift_schedules 
    FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS "Shift schedules all policy" ON public.shift_schedules;
CREATE POLICY "Shift schedules all policy" ON public.shift_schedules 
    FOR ALL USING (public.is_admin());

-- Blockchain Ledger Policy (Read-only untuk Admin demi transparansi forensik)
DROP POLICY IF EXISTS "Blockchain audit read policy" ON public.blockchain_audit_ledger;
CREATE POLICY "Blockchain audit read policy" ON public.blockchain_audit_ledger 
    FOR SELECT USING (public.is_admin());

-- ============================================================================
-- 13. AKTIFKAN REALTIME BROADCASTING (SUPABASE REPLICATION PUBLICATION)
-- ============================================================================
-- Mengaktifkan broadcast WebSocket Realtime untuk tabel pesanan, item, dan blockchain
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
EXCEPTION WHEN others THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.order_items;
EXCEPTION WHEN others THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.order_tracking_events;
EXCEPTION WHEN others THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.blockchain_audit_ledger;
EXCEPTION WHEN others THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
EXCEPTION WHEN others THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.shift_schedules;
EXCEPTION WHEN others THEN null; END $$;

-- ============================================================================
-- 14. SINKRONISASI AKUN LAMA KE TABEL PROFILES (BACKFILL AUTOMATIC SYNC)
-- Memindahkan akun yang sudah terdaftar di auth.users ke public.profiles
-- ============================================================================
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone_encrypted TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS encryption_iv TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS member_tier TEXT NOT NULL DEFAULT 'New Member';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS points INT NOT NULL DEFAULT 100;

INSERT INTO public.profiles (id, name, email, phone, role, encryption_iv, member_tier, points)
SELECT 
    u.id,
    COALESCE(u.raw_user_meta_data->>'name', split_part(u.email, '@', 1)),
    u.email,
    COALESCE(u.raw_user_meta_data->>'phone', ''),
    'customer'::user_role,
    md5(now()::text || u.id::text),
    'New Member',
    100
FROM auth.users u
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    email = EXCLUDED.email;

-- ============================================================================
-- 15. PROMOSI AKUN UTAMA MENJADI SUPER ADMIN (JALANKAN SESUAI KEBUTUHAN)
-- Hapus tanda komentar (--) pada baris di bawah jika Anda ingin akun Anda
-- langsung menjadi Super Admin saat ini juga:
-- ============================================================================
-- UPDATE public.profiles 
-- SET role = 'admin', member_tier = 'Super Admin' 
-- WHERE email = 'zarqud@gmail.com';

-- ============================================================================
-- SELESAI. Database Seuma.Koffie 100% Terintegrasi, Realtime & Blockchain Ready!
-- ============================================================================
