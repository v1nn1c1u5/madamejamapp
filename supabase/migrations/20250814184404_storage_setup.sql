-- Location: supabase/migrations/20250814184404_storage_setup.sql
-- Schema Analysis: Setting up storage buckets for bakery management system
-- Integration Type: Addition - Storage infrastructure for product images
-- Dependencies: Existing user_profiles table

-- Create storage bucket for product images (public access)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'product-images',
    'product-images',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
);

-- RLS Policy: Anyone can view product images (public bucket)
CREATE POLICY "public_can_view_product_images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'product-images');

-- RLS Policy: Only authenticated admins can upload product images
CREATE POLICY "admins_upload_product_images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- RLS Policy: Only file owner (admin) can update/delete product images
CREATE POLICY "admins_manage_product_images"
ON storage.objects
FOR UPDATE, DELETE
TO authenticated
USING (
    bucket_id = 'product-images'
    AND owner = auth.uid()
    AND EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);