-- Update payment_method enum to replace 'credit' with 'reservation'
-- This migration changes the credit payment method to a reservation-based payment (50% upfront, 50% on delivery)

-- Step 1: Add the new 'reservation' value to the enum
ALTER TYPE public.payment_method ADD VALUE 'reservation';

-- Step 2: Update any existing records that use 'credit' to use 'reservation'
UPDATE public.orders 
SET payment_method = 'reservation' 
WHERE payment_method = 'credit';

-- Step 3: Create a new enum without 'credit'
CREATE TYPE public.payment_method_new AS ENUM ('cash', 'card', 'reservation', 'pix');

-- Step 4: Update the orders table to use the new enum
ALTER TABLE public.orders 
ALTER COLUMN payment_method TYPE public.payment_method_new 
USING payment_method::text::public.payment_method_new;

-- Step 5: Drop the old enum and rename the new one
DROP TYPE public.payment_method;
ALTER TYPE public.payment_method_new RENAME TO payment_method;

-- Add a comment to document the change
COMMENT ON TYPE public.payment_method IS 'Payment methods: cash, card, reservation (50% upfront + 50% on delivery), pix';
