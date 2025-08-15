-- Location: supabase/migrations/20250814184403_customer_delivery_management.sql
-- Schema Analysis: Existing user_profiles table with basic admin/customer roles
-- Integration Type: Addition - new customer management and delivery support modules
-- Dependencies: user_profiles (existing table)

-- Create ENUM types for new modules
CREATE TYPE public.customer_status AS ENUM ('ativo', 'inativo', 'vip', 'bloqueado');
CREATE TYPE public.delivery_status AS ENUM ('pendente', 'coletado', 'em_transito', 'entregue', 'problema', 'cancelado');
CREATE TYPE public.priority_level AS ENUM ('baixa', 'normal', 'alta', 'urgente');
CREATE TYPE public.contact_preference AS ENUM ('whatsapp', 'sms', 'email', 'ligacao');

-- Extended customer profiles for customer database functionality
CREATE TABLE public.customer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_profile_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    customer_code TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    whatsapp TEXT,
    email TEXT,
    birth_date DATE,
    document_number TEXT,
    customer_status public.customer_status DEFAULT 'ativo'::public.customer_status,
    contact_preference public.contact_preference DEFAULT 'whatsapp'::public.contact_preference,
    notes TEXT,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    last_order_date TIMESTAMPTZ,
    registration_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Customer addresses for delivery management
CREATE TABLE public.customer_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES public.customer_profiles(id) ON DELETE CASCADE,
    address_name TEXT NOT NULL,
    street_address TEXT NOT NULL,
    neighborhood TEXT,
    city TEXT NOT NULL,
    state TEXT DEFAULT 'SP',
    postal_code TEXT,
    complement TEXT,
    reference_point TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Delivery management system
CREATE TABLE public.deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_code TEXT UNIQUE NOT NULL,
    customer_id UUID REFERENCES public.customer_profiles(id) ON DELETE SET NULL,
    address_id UUID REFERENCES public.customer_addresses(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    order_value DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    delivery_fee DECIMAL(10,2) DEFAULT 0.00,
    delivery_status public.delivery_status DEFAULT 'pendente'::public.delivery_status,
    priority_level public.priority_level DEFAULT 'normal'::public.priority_level,
    scheduled_date TIMESTAMPTZ,
    pickup_time TIMESTAMPTZ,
    delivery_time TIMESTAMPTZ,
    estimated_arrival TIMESTAMPTZ,
    delivery_instructions TEXT,
    customer_notes TEXT,
    admin_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Delivery status tracking
CREATE TABLE public.delivery_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id UUID REFERENCES public.deliveries(id) ON DELETE CASCADE,
    status public.delivery_status NOT NULL,
    notes TEXT,
    location_latitude DECIMAL(10,8),
    location_longitude DECIMAL(11,8),
    updated_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Support tickets for delivery issues
CREATE TABLE public.delivery_support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_number TEXT UNIQUE NOT NULL,
    delivery_id UUID REFERENCES public.deliveries(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES public.customer_profiles(id) ON DELETE SET NULL,
    issue_type TEXT NOT NULL,
    description TEXT NOT NULL,
    priority_level public.priority_level DEFAULT 'normal'::public.priority_level,
    status TEXT DEFAULT 'aberto',
    assigned_to UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    resolution_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Essential Indexes for performance
CREATE INDEX idx_customer_profiles_user_profile_id ON public.customer_profiles(user_profile_id);
CREATE INDEX idx_customer_profiles_customer_code ON public.customer_profiles(customer_code);
CREATE INDEX idx_customer_profiles_status ON public.customer_profiles(customer_status);
CREATE INDEX idx_customer_profiles_registration_date ON public.customer_profiles(registration_date);

CREATE INDEX idx_customer_addresses_customer_id ON public.customer_addresses(customer_id);
CREATE INDEX idx_customer_addresses_is_default ON public.customer_addresses(is_default);

CREATE INDEX idx_deliveries_customer_id ON public.deliveries(customer_id);
CREATE INDEX idx_deliveries_assigned_to ON public.deliveries(assigned_to);
CREATE INDEX idx_deliveries_status ON public.deliveries(delivery_status);
CREATE INDEX idx_deliveries_scheduled_date ON public.deliveries(scheduled_date);
CREATE INDEX idx_deliveries_created_at ON public.deliveries(created_at);

CREATE INDEX idx_delivery_tracking_delivery_id ON public.delivery_tracking(delivery_id);
CREATE INDEX idx_delivery_tracking_created_at ON public.delivery_tracking(created_at);

CREATE INDEX idx_delivery_support_tickets_delivery_id ON public.delivery_support_tickets(delivery_id);
CREATE INDEX idx_delivery_support_tickets_customer_id ON public.delivery_support_tickets(customer_id);
CREATE INDEX idx_delivery_support_tickets_status ON public.delivery_support_tickets(status);

-- Enable RLS for all tables
ALTER TABLE public.customer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_support_tickets ENABLE ROW LEVEL SECURITY;

-- RLS Policies following the 7-pattern system
-- Pattern 6: Role-based access using auth metadata
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role = 'admin'
)
$$;

-- Admin access to customer profiles
CREATE POLICY "admin_full_access_customer_profiles"
ON public.customer_profiles
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Customer access to own profile
CREATE POLICY "customers_view_own_profile"
ON public.customer_profiles
FOR SELECT
TO authenticated
USING (user_profile_id = auth.uid());

-- Admin access to customer addresses  
CREATE POLICY "admin_full_access_customer_addresses"
ON public.customer_addresses
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Admin access to deliveries
CREATE POLICY "admin_full_access_deliveries"
ON public.deliveries
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Admin access to delivery tracking
CREATE POLICY "admin_full_access_delivery_tracking"
ON public.delivery_tracking
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Admin access to support tickets
CREATE POLICY "admin_full_access_delivery_support_tickets"
ON public.delivery_support_tickets
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Triggers for updated_at columns
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_customer_profiles_updated_at
    BEFORE UPDATE ON public.customer_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_customer_addresses_updated_at
    BEFORE UPDATE ON public.customer_addresses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_deliveries_updated_at
    BEFORE UPDATE ON public.deliveries
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_delivery_support_tickets_updated_at
    BEFORE UPDATE ON public.delivery_support_tickets
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Mock data for customer database and delivery support
DO $$
DECLARE
    existing_admin_id UUID;
    customer1_id UUID := gen_random_uuid();
    customer2_id UUID := gen_random_uuid();
    customer3_id UUID := gen_random_uuid();
    addr1_id UUID := gen_random_uuid();
    addr2_id UUID := gen_random_uuid();
    addr3_id UUID := gen_random_uuid();
    delivery1_id UUID := gen_random_uuid();
    delivery2_id UUID := gen_random_uuid();
    delivery3_id UUID := gen_random_uuid();
BEGIN
    -- Get existing admin user ID
    SELECT id INTO existing_admin_id 
    FROM public.user_profiles 
    WHERE role = 'admin' 
    LIMIT 1;
    
    -- Create sample customer profiles
    INSERT INTO public.customer_profiles (
        id, customer_code, full_name, phone, whatsapp, email, 
        customer_status, total_spent, total_orders, last_order_date
    ) VALUES
        (customer1_id, 'CUST001', 'Maria Silva Santos', '+55 11 99999-1111', '+55 11 99999-1111', 'maria.silva@email.com', 
         'vip', 1250.50, 15, NOW() - INTERVAL '2 days'),
        (customer2_id, 'CUST002', 'João Carlos Oliveira', '+55 11 99999-2222', '+55 11 99999-2222', 'joao.carlos@email.com', 
         'ativo', 850.30, 8, NOW() - INTERVAL '1 week'),
        (customer3_id, 'CUST003', 'Ana Beatriz Costa', '+55 11 99999-3333', '+55 11 99999-3333', 'ana.costa@email.com', 
         'ativo', 420.80, 5, NOW() - INTERVAL '3 days');

    -- Create customer addresses
    INSERT INTO public.customer_addresses (
        id, customer_id, address_name, street_address, neighborhood, city, 
        postal_code, is_default, reference_point
    ) VALUES
        (addr1_id, customer1_id, 'Casa', 'Rua das Flores, 123', 'Vila Madalena', 'São Paulo', 
         '05419-000', true, 'Próximo ao mercado Extra'),
        (addr2_id, customer2_id, 'Trabalho', 'Av. Paulista, 1000 - Sala 504', 'Bela Vista', 'São Paulo', 
         '01310-100', true, 'Edifício comercial azul'),
        (addr3_id, customer3_id, 'Residência', 'Rua dos Jardins, 456', 'Jardins', 'São Paulo', 
         '01401-001', true, 'Casa com portão branco');

    -- Create sample deliveries
    INSERT INTO public.deliveries (
        id, delivery_code, customer_id, address_id, assigned_to, order_value, 
        delivery_fee, delivery_status, priority_level, scheduled_date, delivery_instructions
    ) VALUES
        (delivery1_id, 'DEL001', customer1_id, addr1_id, existing_admin_id, 125.50, 
         8.00, 'em_transito', 'alta', NOW() + INTERVAL '2 hours', 'Entregar na portaria se ninguém atender'),
        (delivery2_id, 'DEL002', customer2_id, addr2_id, existing_admin_id, 89.90, 
         10.00, 'pendente', 'normal', NOW() + INTERVAL '4 hours', 'Ligar antes de entregar'),
        (delivery3_id, 'DEL003', customer3_id, addr3_id, existing_admin_id, 156.80, 
         12.00, 'coletado', 'normal', NOW() + INTERVAL '1 day', 'Entregar após 14h');

    -- Create delivery tracking records
    INSERT INTO public.delivery_tracking (delivery_id, status, notes, updated_by) VALUES
        (delivery1_id, 'pendente', 'Pedido confirmado e aguardando coleta', existing_admin_id),
        (delivery1_id, 'coletado', 'Pedido coletado na loja', existing_admin_id),
        (delivery1_id, 'em_transito', 'Saindo para entrega', existing_admin_id),
        (delivery2_id, 'pendente', 'Aguardando confirmação do cliente', existing_admin_id),
        (delivery3_id, 'pendente', 'Pedido em preparação', existing_admin_id),
        (delivery3_id, 'coletado', 'Pedido pronto para entrega', existing_admin_id);

    -- Create sample support tickets
    INSERT INTO public.delivery_support_tickets (
        ticket_number, delivery_id, customer_id, issue_type, description, 
        priority_level, status, assigned_to
    ) VALUES
        ('TICK001', delivery1_id, customer1_id, 'Atraso na entrega', 
         'Cliente reporta atraso de mais de 30 minutos na entrega', 'alta', 'em_andamento', existing_admin_id),
        ('TICK002', delivery2_id, customer2_id, 'Endereço incorreto', 
         'Endereço informado está incompleto, faltam detalhes do complemento', 'normal', 'aberto', existing_admin_id);

    -- Handle case where no admin user exists
    IF existing_admin_id IS NULL THEN
        RAISE NOTICE 'No admin user found. Some mock data references may be NULL.';
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error during mock data insertion: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error during mock data insertion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error during mock data insertion: %', SQLERRM;
END $$;