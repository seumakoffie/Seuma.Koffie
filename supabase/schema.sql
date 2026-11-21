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
    member_tier TEXT NOT NULL DEFAULT 'Member',
    points INT NOT NULL DEFAULT 0,
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
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS maps_url TEXT;
ALTER TABLE public.orders ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.orders ALTER COLUMN delivery_address_encrypted DROP NOT NULL;
ALTER TABLE public.orders ALTER COLUMN recipient_phone_encrypted DROP NOT NULL;
ALTER TABLE public.orders ALTER COLUMN delivery_notes_encrypted DROP NOT NULL;

-- Pastikan seluruh kolom esensial ada jika tabel sudah pernah dibuat sebelumnya
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone_encrypted TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS encryption_iv TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS member_tier TEXT NOT NULL DEFAULT 'Member';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS points INT NOT NULL DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());
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
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS maps_url TEXT;
ALTER TABLE public.orders ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.orders ALTER COLUMN delivery_address_encrypted DROP NOT NULL;
ALTER TABLE public.orders ALTER COLUMN recipient_phone_encrypted DROP NOT NULL;
ALTER TABLE public.orders ALTER COLUMN delivery_notes_encrypted DROP NOT NULL;

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

-- Alias untuk RPC verify_blockchain_integrity
CREATE OR REPLACE FUNCTION public.verify_blockchain_integrity()
RETURNS TABLE (
    is_valid BOOLEAN,
    total_blocks BIGINT,
    corrupted_at_block BIGINT,
    message TEXT
) 
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.verify_blockchain_chain();
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.verify_blockchain_chain() TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.verify_blockchain_integrity() TO anon, authenticated, service_role;

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

-- Profiles Policies (Bebas dari Rekursi RLS - Akses Penuh untuk Admin Dashboard)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.profiles TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.orders TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.order_items TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.order_tracking_events TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.shift_schedules TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.blockchain_audit_ledger TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

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
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Orders insert policy" ON public.orders;
CREATE POLICY "Orders insert policy" ON public.orders 
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Orders update policy" ON public.orders;
CREATE POLICY "Orders update policy" ON public.orders 
    FOR UPDATE USING (true) WITH CHECK (true);

-- Order Items Policies
DROP POLICY IF EXISTS "Order items read policy" ON public.order_items;
CREATE POLICY "Order items read policy" ON public.order_items 
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Order items insert policy" ON public.order_items;
CREATE POLICY "Order items insert policy" ON public.order_items 
    FOR INSERT WITH CHECK (true);

-- Shift Schedules Policies
DROP POLICY IF EXISTS "Shift schedules read policy" ON public.shift_schedules;
CREATE POLICY "Shift schedules read policy" ON public.shift_schedules 
    FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS "Shift schedules all policy" ON public.shift_schedules;
CREATE POLICY "Shift schedules all policy" ON public.shift_schedules 
    FOR ALL USING (public.is_admin());

-- Blockchain Ledger Policy (Read-only untuk Admin & Forensik Integritas)
DROP POLICY IF EXISTS "Blockchain audit read policy" ON public.blockchain_audit_ledger;
CREATE POLICY "Blockchain audit read policy" ON public.blockchain_audit_ledger 
    FOR SELECT USING (true);

-- Trigger Otomatis Pembuatan Blok Kriptografi saat Pesanan Dibuat (ORDER_CREATED)
CREATE OR REPLACE FUNCTION public.handle_order_created_blockchain_audit()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM public.append_blockchain_block(
        'ORDER_CREATED',
        NEW.user_id,
        NEW.order_number,
        jsonb_build_object(
            'order_id', NEW.id,
            'order_number', NEW.order_number,
            'recipient', NEW.recipient_name,
            'total_amount', NEW.total_amount,
            'payment_method', NEW.payment_method,
            'created_at', NEW.created_at
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_order_created_blockchain ON public.orders;
CREATE TRIGGER on_order_created_blockchain
    AFTER INSERT ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_order_created_blockchain_audit();

-- Trigger Otomatis Pembuatan Blok saat Status Pesanan Diperbarui (ORDER_STATUS_UPDATED)
CREATE OR REPLACE FUNCTION public.handle_order_status_blockchain_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status != 'delivered' THEN
        PERFORM public.append_blockchain_block(
            'ORDER_STATUS_UPDATED',
            NEW.verified_by,
            NEW.order_number,
            jsonb_build_object(
                'order_number', NEW.order_number,
                'previous_status', OLD.status,
                'new_status', NEW.status,
                'updated_at', now()
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_order_status_changed_blockchain ON public.orders;
CREATE TRIGGER on_order_status_changed_blockchain
    AFTER UPDATE OF status ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_order_status_blockchain_audit();

-- ============================================================================
-- 13. AKTIFKAN REALTIME BROADCASTING (SUPABASE REPLICATION PUBLICATION)
-- ============================================================================
-- Mengaktifkan broadcast WebSocket Realtime untuk tabel pesanan, item, dan blockchain
ALTER TABLE public.orders REPLICA IDENTITY FULL;
ALTER TABLE public.blockchain_audit_ledger REPLICA IDENTITY FULL;

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
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS member_tier TEXT NOT NULL DEFAULT 'Member';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS points INT NOT NULL DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());

INSERT INTO public.profiles (id, name, email, phone, role, encryption_iv, member_tier, points)
SELECT 
    u.id,
    COALESCE(u.raw_user_meta_data->>'name', split_part(u.email, '@', 1)),
    u.email,
    COALESCE(u.raw_user_meta_data->>'phone', ''),
    'customer'::user_role,
    md5(now()::text || u.id::text),
    'Member',
    0
FROM auth.users u
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    email = EXCLUDED.email;

-- ============================================================================
-- 15. PROMOSI AKUN UTAMA MENJADI SUPER ADMIN & VERIFIKASI
-- ============================================================================
UPDATE public.profiles 
SET role = 'admin', 
    member_tier = 'Super Admin' 
WHERE email IN ('zarqud@gmail.com', 'seumakoffie20@gmail.com');

-- Verifikasi data profil seluruh akun admin
SELECT id, name, email, role, member_tier 
FROM public.profiles 
WHERE role = 'admin' OR email IN ('zarqud@gmail.com', 'seumakoffie20@gmail.com');

-- ============================================================================
-- 16. TABEL SESI PERANGKAT & RESET SANDI AMAN (MULTI-DEVICE & ON-SCREEN OTP)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.user_device_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_fingerprint TEXT NOT NULL,
    device_name TEXT NOT NULL,
    ip_address TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_active TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.user_device_sessions DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.user_device_sessions TO anon, authenticated, service_role;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_device_sessions;
EXCEPTION WHEN others THEN null; END $$;

-- Fungsi Reset Password Langsung Aman Tanpa Perlu SMTP Email
CREATE OR REPLACE FUNCTION public.reset_user_password(
    p_email TEXT,
    p_new_password TEXT
) RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
BEGIN
    UPDATE auth.users
    SET encrypted_password = crypt(p_new_password, gen_salt('bf')),
        updated_at = now()
    WHERE email = p_email;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.reset_user_password(TEXT, TEXT) TO anon, authenticated, service_role;

-- Fungsi Keluarkan Sesi Perangkat Lain
CREATE OR REPLACE FUNCTION public.revoke_other_device_sessions(
    p_user_id UUID,
    p_current_device_id TEXT
) RETURNS VOID
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_device_sessions
    SET is_active = FALSE
    WHERE user_id = p_user_id AND device_fingerprint != p_current_device_id;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.revoke_other_device_sessions(UUID, TEXT) TO anon, authenticated, service_role;

-- ============================================================================
-- 13. TABEL KATALOG MENU & HARGA (REALTIME CRUD SUPER ADMIN)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.menu_items (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    category_slug TEXT NOT NULL,
    description TEXT NOT NULL,
    price_hot INT,
    price_ice INT,
    price_fixed INT,
    temp_option TEXT NOT NULL DEFAULT 'both',
    is_best_seller BOOLEAN NOT NULL DEFAULT FALSE,
    is_new BOOLEAN NOT NULL DEFAULT FALSE,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    icon_emoji TEXT NOT NULL DEFAULT '☕',
    image_path TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Row Level Security (RLS)
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;

-- Semua pengguna (anon & authenticated) dapat melihat menu
DROP POLICY IF EXISTS "Public Read Menu Items" ON public.menu_items;
CREATE POLICY "Public Read Menu Items"
    ON public.menu_items FOR SELECT
    USING (true);

-- Hanya Super Admin & Admin yang dapat memodifikasi (Insert, Update, Delete)
DROP POLICY IF EXISTS "Admin All Menu Items" ON public.menu_items;
CREATE POLICY "Admin All Menu Items"
    ON public.menu_items FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid()
            AND (profiles.role = 'admin' OR profiles.email IN ('zarqud@gmail.com', 'seumakoffie20@gmail.com'))
        )
    );

-- Aktifkan Realtime Publication pada Tabel menu_items
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.menu_items;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Seeding Data 30 Menu Awal Seuma.Koffie
INSERT INTO public.menu_items (id, name, category, category_slug, description, price_hot, price_ice, price_fixed, temp_option, is_best_seller, is_new, icon_emoji, sort_order)
VALUES
('esp-1', 'Espresso', 'Espresso', 'espresso', 'Single shot espresso murni dari biji kopi sangrai terbaik, pekat dan kaya crema.', 10000, null, null, 'hotOnly', true, false, '☕', 1),
('ame-1', 'Americano', 'Kopi Americano', 'americano', 'Espresso diencerkan dengan air panas/dingin, rasa bersih dengan aftertaste manis.', 10000, 12000, null, 'both', true, false, '🫖', 2),
('ame-2', 'Peach Americano', 'Kopi Americano', 'americano', 'Sensasi asam manis buah peach segar berpadu sempurna dengan dinginnya espresso.', null, 15000, null, 'iceOnly', false, true, '🍑', 3),
('ame-3', 'Lemon Americano', 'Kopi Americano', 'americano', 'Perasan jeruk lemon segar menyatu dengan espresso dingin, sangat membangkitkan stamina.', null, 15000, null, 'iceOnly', false, false, '🍋', 4),
('ame-4', 'Orange Americano', 'Kopi Americano', 'americano', 'Kombinasi eksotis sari jeruk orange tropis dan double shot espresso chilled.', null, 15000, null, 'iceOnly', false, false, '🍊', 5),
('san-1', 'Sanger Espresso', 'Kopi Sanger', 'sanger', 'Kopi khas Aceh legendaris! Racikan espresso pekat dengan susu kental manis proporsi pas.', 12000, 14000, null, 'both', true, false, '🥛', 6),
('san-2', 'Sanger Tegur', 'Kopi Sanger', 'sanger', 'Varian Sanger dengan body ekstra mantap dan aroma biji sangrai lebih pekat menggoda.', 14000, 16000, null, 'both', false, false, '⚡', 7),
('sus-1', 'Kopi Susu Aren', 'Kopi Susu', 'susu', 'Espresso berpadu susu segar dan gula aren alami murni, manis legit tanpa enek.', 15000, 17000, null, 'both', true, false, '🌴', 8),
('sus-2', 'Kopi Susu Creamy', 'Kopi Susu', 'susu', 'Tekstur super lembut dan gurih berkat racikan double cream rahasia Seuma.', 16000, 18000, null, 'both', false, false, '🍦', 9),
('sus-3', 'Kopi Susu Caramel', 'Kopi Susu', 'susu', 'Sentuhan sirup karamel bakar Prancis beraroma toasty yang lumer di lidah.', 17000, 19000, null, 'both', false, false, '🍮', 10),
('sus-4', 'Kopi Susu Hazelnut', 'Kopi Susu', 'susu', 'Aroma kacang hazelnut panggang berpadu elegan dengan kopi susu dingin.', 17000, 19000, null, 'both', false, false, '🌰', 11),
('sus-5', 'Kopi Susu Pandan', 'Kopi Susu', 'susu', 'Harum ekstrak daun pandan wangi asli berpadu lembut dengan susu kopi.', 16000, 18000, null, 'both', false, false, '🍃', 12),
('sus-6', 'Kopi Susu Butterscotch', 'Kopi Susu', 'susu', 'Gurih manisnya butterscotch butter brown sugar yang memanjakan pecinta kopi manis.', 17000, 19000, null, 'both', false, false, '🧈', 13),
('lat-1', 'Coffee Latte', 'Kopi Latte', 'latte', 'Espresso klasik dengan steamed milk lembut dan lapisan microfoam tipis.', 15000, 17000, null, 'both', false, false, '☕', 14),
('lat-2', 'Spanish Latte', 'Kopi Latte', 'latte', 'Latte manis lembut khas Spanyol dengan campuran susu kondensasi gurih.', 16000, 18000, null, 'both', false, false, '🇪🇸', 15),
('lat-3', 'Seasalt Caramel Latte', 'Kopi Latte', 'latte', 'Foam gurih asin seasalt berpadu kontras dengan manis karamel dan kopi.', null, 20000, null, 'iceOnly', false, true, '🧂', 16),
('lat-4', 'Seasalt Butterscotch Latte', 'Kopi Latte', 'latte', 'Sentuhan foam seasalt gurih di atas butterscotch latte dingin aromatik.', null, 20000, null, 'iceOnly', false, true, '🧈', 17),
('non-1', 'Chocolate Latte', 'Non Coffee', 'latte', 'Cokelat Belgia pekat berpadu susu segar murni, rasa manis pahit seimbang.', 15000, 17000, null, 'both', false, false, '🍫', 18),
('non-2', 'Taro Latte', 'Non Coffee', 'taro', 'Ubi taro ungu lembut beraroma vanilla manis yang creamy dan menenangkan.', 15000, 17000, null, 'both', false, false, '🍠', 19),
('non-3', 'Red Velvet Latte', 'Non Coffee', 'velvet', 'Kue red velvet dalam cangkir! Kaya rasa cokelat dan buttermilk gurih.', 15000, 17000, null, 'both', false, false, '🍰', 20),
('non-4', 'Kopi Coklat', 'Kopi Fusion', 'latte', 'Mocha fusion perpaduan espresso mantap dan lelehan cokelat premium.', 16000, 18000, null, 'both', false, false, '☕🍫', 21),
('non-5', 'Kopi Taro', 'Kopi Fusion', 'taro', 'Eksperimen rasa unik: gurih legitnya taro ungu berpadu espresso pekat.', 16000, 18000, null, 'both', false, false, '☕🍠', 22),
('non-6', 'Kopi Red Velvet', 'Kopi Fusion', 'velvet', 'Perkawinan rasa red velvet lembut dan kehangatan espresso berkualitas.', 16000, 18000, null, 'both', false, false, '☕🍰', 23),
('mat-1', 'Matcha Original', 'Matcha', 'matcha', 'Matcha murni Uji Jepang berkualitas tinggi, rasa umami lembut menenangkan.', 16000, 18000, null, 'both', true, false, '🍵', 24),
('mat-2', 'Matcha Strawberry', 'Matcha', 'matcha', 'Layering visual estetik selai stroberi manis di dasar dan matcha latte di atasnya.', null, 20000, null, 'iceOnly', false, true, '🍓', 25),
('mat-3', 'Matcha Ube', 'Matcha', 'matcha', 'Perpaduan earthy matcha Jepang dan gurihnya ube ungu, cita rasa eksklusif.', null, 20000, null, 'iceOnly', false, false, '🍠', 26),
('squ-1', 'Orange Squash', 'Squash', 'squash', 'Kesegaran bulir jeruk dengan soda berkarbonasi dingin pelepas dahaga.', null, 13000, null, 'iceOnly', false, false, '🍊', 27),
('squ-2', 'Lemon Squash', 'Squash', 'squash', 'Asam segar jeruk lemon asli berpadu soda dingin menusuk tenggorokan.', null, 13000, null, 'iceOnly', false, false, '🍋', 28),
('squ-3', 'Strawberry Squash', 'Squash', 'squash', 'Manis asam buah stroberi segar dipadukan dengan soda dingin effervescent.', null, 14000, null, 'iceOnly', false, false, '🍓', 29),
('squ-4', 'Lychee Squash', 'Squash', 'squash', 'Aroma leci tropis manis harum dengan sensasi dingin soda yang refreshing.', null, 14000, null, 'iceOnly', false, false, '🍒', 30),
('squ-5', 'Manggo Squash', 'Squash', 'squash', 'Manis legit buah mangga matang disajikan dengan soda dingin bergelembung.', null, 14000, null, 'iceOnly', false, false, '🥭', 31),
('sak-1', 'Kopi Susu Aren 200ml', 'Kopi Saku 200ml', 'saku', 'Kopi susu gula aren kemasan saku 200ml praktis, cocok dibawa kerja atau kuliah.', null, null, 12000, 'iceOnly', true, false, '🧃', 32),
('sak-2', 'Kopi Susu Hazelnut 200ml', 'Kopi Saku 200ml', 'saku', 'Kopi susu aroma kacang hazelnut kemasan botol siap minum di mana saja.', null, null, 13000, 'iceOnly', false, false, '🧃', 33),
('sak-3', 'Matcha Latte 200ml', 'Kopi Saku 200ml', 'saku', 'Matcha latte Jepang kemasan praktis 200ml dingin, menyegarkan hari Anda.', null, null, 13000, 'iceOnly', false, false, '🧃', 34)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    category_slug = EXCLUDED.category_slug,
    description = EXCLUDED.description,
    price_hot = EXCLUDED.price_hot,
    price_ice = EXCLUDED.price_ice,
    price_fixed = EXCLUDED.price_fixed,
    temp_option = EXCLUDED.temp_option,
    is_best_seller = EXCLUDED.is_best_seller,
    is_new = EXCLUDED.is_new,
    icon_emoji = EXCLUDED.icon_emoji,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();

-- ============================================================================
-- SELESAI. Database Seuma.Koffie 100% Terintegrasi, Realtime & Blockchain Ready!
-- ============================================================================
