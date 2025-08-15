-- Location: supabase/migrations/20250814184403_bakery_management_system.sql
-- Schema Analysis: Existing user_profiles table with authentication
-- Integration Type: Extension - Adding bakery management functionality
-- Dependencies: user_profiles (existing table with id, role, email, full_name)

-- Create custom types for bakery management
CREATE TYPE public.product_status AS ENUM ('active', 'inactive', 'out_of_stock');
CREATE TYPE public.order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled');
CREATE TYPE public.payment_method AS ENUM ('cash', 'card', 'credit', 'pix');

-- Create product categories table
CREATE TABLE public.product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category_id UUID REFERENCES public.product_categories(id) ON DELETE SET NULL,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    stock_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5,
    status public.product_status DEFAULT 'active'::public.product_status,
    preparation_time_minutes INTEGER DEFAULT 30,
    allergens TEXT[],
    is_gluten_free BOOLEAN DEFAULT false,
    is_vegan BOOLEAN DEFAULT false,
    weight_grams INTEGER,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create product images table
CREATE TABLE public.product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text TEXT,
    display_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create customers table (extending customer functionality)
CREATE TABLE public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_profile_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    phone TEXT,
    birth_date DATE,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    delivery_notes TEXT,
    is_vip BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT UNIQUE NOT NULL,
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    status public.order_status DEFAULT 'pending'::public.order_status,
    total_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    payment_method public.payment_method,
    payment_status TEXT DEFAULT 'pending',
    delivery_date DATE,
    delivery_time_start TIME,
    delivery_time_end TIME,
    delivery_address TEXT,
    special_instructions TEXT,
    internal_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create order items table
CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create delivery routes table
CREATE TABLE public.delivery_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    driver_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    delivery_date DATE NOT NULL,
    estimated_start_time TIME,
    estimated_end_time TIME,
    status TEXT DEFAULT 'planned',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create order deliveries table (linking orders to delivery routes)
CREATE TABLE public.order_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    delivery_route_id UUID REFERENCES public.delivery_routes(id) ON DELETE SET NULL,
    delivery_sequence INTEGER,
    actual_delivery_time TIMESTAMPTZ,
    delivery_notes TEXT,
    is_delivered BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create essential indexes
CREATE INDEX idx_products_category_id ON public.products(category_id);
CREATE INDEX idx_products_status ON public.products(status);
CREATE INDEX idx_products_created_by ON public.products(created_by);
CREATE INDEX idx_product_images_product_id ON public.product_images(product_id);
CREATE INDEX idx_customers_user_profile_id ON public.customers(user_profile_id);
CREATE INDEX idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX idx_orders_created_by ON public.orders(created_by);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_order_number ON public.orders(order_number);
CREATE INDEX idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON public.order_items(product_id);
CREATE INDEX idx_delivery_routes_driver_id ON public.delivery_routes(driver_id);
CREATE INDEX idx_order_deliveries_order_id ON public.order_deliveries(order_id);
CREATE INDEX idx_order_deliveries_route_id ON public.order_deliveries(delivery_route_id);

-- Create function to generate order numbers
CREATE OR REPLACE FUNCTION public.generate_order_number()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    current_date_str TEXT;
    sequence_num INTEGER;
    order_number TEXT;
BEGIN
    current_date_str := to_char(CURRENT_DATE, 'YYYYMMDD');
    
    SELECT COALESCE(MAX(CAST(RIGHT(order_number, 4) AS INTEGER)), 0) + 1
    INTO sequence_num
    FROM public.orders
    WHERE order_number LIKE 'ORD-' || current_date_str || '-%';
    
    order_number := 'ORD-' || current_date_str || '-' || LPAD(sequence_num::TEXT, 4, '0');
    
    RETURN order_number;
END;
$$;

-- Create trigger function for updating timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Add triggers for updated_at columns
CREATE TRIGGER update_product_categories_updated_at
    BEFORE UPDATE ON public.product_categories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON public.customers
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_delivery_routes_updated_at
    BEFORE UPDATE ON public.delivery_routes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Enable RLS for all tables
ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_deliveries ENABLE ROW LEVEL SECURITY;

-- RLS Policies using Pattern 1 and Pattern 2 from best practices

-- Product categories - Public read, admin manage
CREATE POLICY "public_can_read_product_categories"
ON public.product_categories
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_product_categories"
ON public.product_categories
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Products - Public read, admin/staff manage
CREATE POLICY "public_can_read_products"
ON public.products
FOR SELECT
TO public
USING (status = 'active'::public.product_status);

CREATE POLICY "admin_manage_products"
ON public.products
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role IN ('admin')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role IN ('admin')
    )
);

-- Product images - Public read, admin manage
CREATE POLICY "public_can_read_product_images"
ON public.product_images
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_product_images"
ON public.product_images
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Customers - Users manage own customer data, admin manage all
CREATE POLICY "users_manage_own_customers"
ON public.customers
FOR ALL
TO authenticated
USING (user_profile_id = auth.uid())
WITH CHECK (user_profile_id = auth.uid());

CREATE POLICY "admin_manage_all_customers"
ON public.customers
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Orders - Customers see own orders, admin see all
CREATE POLICY "customers_view_own_orders"
ON public.orders
FOR SELECT
TO authenticated
USING (
    customer_id IN (
        SELECT c.id FROM public.customers c
        WHERE c.user_profile_id = auth.uid()
    )
);

CREATE POLICY "admin_manage_all_orders"
ON public.orders
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Order items - Follow parent order permissions
CREATE POLICY "customers_view_own_order_items"
ON public.order_items
FOR SELECT
TO authenticated
USING (
    order_id IN (
        SELECT o.id FROM public.orders o
        JOIN public.customers c ON o.customer_id = c.id
        WHERE c.user_profile_id = auth.uid()
    )
);

CREATE POLICY "admin_manage_all_order_items"
ON public.order_items
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Delivery routes - Admin and assigned drivers only
CREATE POLICY "drivers_view_assigned_routes"
ON public.delivery_routes
FOR SELECT
TO authenticated
USING (driver_id = auth.uid());

CREATE POLICY "admin_manage_delivery_routes"
ON public.delivery_routes
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Order deliveries - Follow delivery route permissions
CREATE POLICY "drivers_manage_assigned_deliveries"
ON public.order_deliveries
FOR ALL
TO authenticated
USING (
    delivery_route_id IN (
        SELECT dr.id FROM public.delivery_routes dr
        WHERE dr.driver_id = auth.uid()
    )
)
WITH CHECK (
    delivery_route_id IN (
        SELECT dr.id FROM public.delivery_routes dr
        WHERE dr.driver_id = auth.uid()
    )
);

CREATE POLICY "admin_manage_all_deliveries"
ON public.order_deliveries
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Mock data for bakery system
DO $$
DECLARE
    admin_user_id UUID;
    customer_user_id UUID;
    breads_category_id UUID := gen_random_uuid();
    cakes_category_id UUID := gen_random_uuid();
    savory_category_id UUID := gen_random_uuid();
    bread_product_id UUID := gen_random_uuid();
    cake_product_id UUID := gen_random_uuid();
    customer_id UUID := gen_random_uuid();
    order_id UUID := gen_random_uuid();
    delivery_route_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user IDs
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE role = 'admin' LIMIT 1;
    SELECT id INTO customer_user_id FROM public.user_profiles WHERE role = 'customer' LIMIT 1;

    -- Create product categories
    INSERT INTO public.product_categories (id, name, description, display_order) VALUES
        (breads_category_id, 'Pães Pequenos', 'Pães artesanais e tradicionais em porções individuais', 1),
        (cakes_category_id, 'Bolos', 'Bolos doces para todas as ocasiões', 2),
        (savory_category_id, 'Tortas Salgadas', 'Tortas e salgados para refeições', 3);

    -- Create sample products
    INSERT INTO public.products (id, name, description, category_id, price, cost_price, stock_quantity, preparation_time_minutes, is_gluten_free, is_vegan, weight_grams, created_by) VALUES
        (bread_product_id, 'Pão Francês Artesanal', 'Pão francês tradicional feito com fermentação natural e ingredientes selecionados', breads_category_id, 8.50, 3.20, 50, 45, false, false, 80, admin_user_id),
        (cake_product_id, 'Bolo de Chocolate', 'Bolo de chocolate cremoso com cobertura de brigadeiro', cakes_category_id, 35.90, 12.50, 15, 90, false, false, 800, admin_user_id),
        (gen_random_uuid(), 'Torta de Frango', 'Torta salgada recheada com frango desfiado e temperos especiais', savory_category_id, 28.00, 10.80, 8, 60, false, false, 1200, admin_user_id);

    -- Create product images
    INSERT INTO public.product_images (product_id, image_url, alt_text, display_order, is_primary) VALUES
        (bread_product_id, 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73', 'Pão Francês Artesanal dourado e crocante', 0, true),
        (cake_product_id, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587', 'Bolo de Chocolate com cobertura cremosa', 0, true);

    -- Create customer profile (if customer user exists)
    IF customer_user_id IS NOT NULL THEN
        INSERT INTO public.customers (id, user_profile_id, phone, address_line1, city, state, postal_code) VALUES
            (customer_id, customer_user_id, '(11) 99999-8888', 'Rua das Flores, 123', 'São Paulo', 'SP', '01234-567');

        -- Create sample order
        INSERT INTO public.orders (id, order_number, customer_id, created_by, status, total_amount, payment_method, delivery_date, delivery_address, special_instructions) VALUES
            (order_id, public.generate_order_number(), customer_id, admin_user_id, 'confirmed'::public.order_status, 44.40, 'card'::public.payment_method, CURRENT_DATE + INTERVAL '1 day', 'Rua das Flores, 123 - São Paulo, SP', 'Entregar pela manhã, preferencialmente até 10h');

        -- Create order items
        INSERT INTO public.order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
            (order_id, bread_product_id, 2, 8.50, 17.00),
            (order_id, cake_product_id, 1, 35.90, 35.90);

        -- Create delivery route
        INSERT INTO public.delivery_routes (id, name, driver_id, delivery_date, estimated_start_time, estimated_end_time) VALUES
            (delivery_route_id, 'Rota Centro - Manhã', admin_user_id, CURRENT_DATE + INTERVAL '1 day', '08:00', '12:00');

        -- Link order to delivery route
        INSERT INTO public.order_deliveries (order_id, delivery_route_id, delivery_sequence) VALUES
            (order_id, delivery_route_id, 1);
    END IF;

    RAISE NOTICE 'Bakery management system mock data created successfully';
END $$;