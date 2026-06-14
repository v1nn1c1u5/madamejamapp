import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Verify user JWT
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const anonClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: authError } = await anonClient.auth.getUser()
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 2. Get customer record
    const { data: customer, error: custError } = await supabase
      .from('customers')
      .select('id')
      .eq('user_id', user.id)
      .single()

    if (custError || !customer) {
      return new Response(JSON.stringify({ error: 'Customer not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 3. Parse request body
    const { cart, deliveryDate, deliveryAddress } = await req.json()

    if (!cart?.length || !deliveryDate || !deliveryAddress) {
      return new Response(JSON.stringify({ error: 'Dados inválidos' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 4. Validate SKUs and calculate total from DB (never trust client prices)
    const skuIds = cart.map((item: { skuId: string }) => item.skuId)
    const { data: skus, error: skusError } = await supabase
      .from('skus')
      .select('id, price, min_quantity, active')
      .in('id', skuIds)

    if (skusError || !skus?.length) {
      return new Response(JSON.stringify({ error: 'SKUs inválidos' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const skuMap = Object.fromEntries(skus.map((s: { id: string; price: number; min_quantity: number; active: boolean }) => [s.id, s]))

    let totalCents = 0
    const itemsToInsert: Array<{ sku_id: string; quantity: number; unit_price: number }> = []

    for (const item of cart) {
      const sku = skuMap[item.skuId]
      if (!sku || !sku.active) {
        return new Response(JSON.stringify({ error: `SKU ${item.skuId} inativo` }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
      if (item.quantity < sku.min_quantity) {
        return new Response(
          JSON.stringify({ error: `Quantidade mínima para ${item.skuId} é ${sku.min_quantity}` }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      const unitPrice = Number(sku.price)
      totalCents += Math.round(unitPrice * 100) * item.quantity
      itemsToInsert.push({ sku_id: item.skuId, quantity: item.quantity, unit_price: unitPrice })
    }

    // 5. Create order in DB
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert({
        customer_id: customer.id,
        delivery_date: deliveryDate,
        delivery_address: deliveryAddress,
        total: totalCents / 100,
        payment_status: 'pending',
        production_status: 'aguardando',
      })
      .select('id')
      .single()

    if (orderError || !order) {
      throw orderError ?? new Error('Failed to create order')
    }

    // 6. Insert order items
    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(itemsToInsert.map(i => ({ ...i, order_id: order.id })))

    if (itemsError) throw itemsError

    // 7. Create Stripe PaymentIntent
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
      apiVersion: '2024-06-20',
    })

    const paymentIntent = await stripe.paymentIntents.create({
      amount: totalCents,
      currency: 'brl',
      payment_method_types: ['card', 'pix'],
      metadata: { order_id: order.id },
    })

    // 8. Save stripe_payment_intent_id
    await supabase
      .from('orders')
      .update({ stripe_payment_intent_id: paymentIntent.id })
      .eq('id', order.id)

    return new Response(
      JSON.stringify({ orderId: order.id, clientSecret: paymentIntent.client_secret }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
