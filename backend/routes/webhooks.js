const express = require('express');
const router = express.Router();
const { Configuration, PlaidApi, PlaidEnvironments } = require('plaid');
const Alpaca = require('@alpacahq/alpaca-trade-api');
const { supabase } = require('../services/supabaseClient');

// Setup Plaid Client
const configuration = new Configuration({
  basePath: PlaidEnvironments[process.env.PLAID_ENV || 'sandbox'],
  baseOptions: {
    headers: {
      'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
      'PLAID-SECRET': process.env.PLAID_SECRET,
    },
  },
});
const plaidClient = new PlaidApi(configuration);

router.post('/plaid', async (req, res) => {
  const { webhook_type, webhook_code, item_id, new_transactions } = req.body;
  
  // Acknowledge webhook immediately
  res.status(200).send('Webhook received');
  
  if (webhook_type === 'TRANSACTIONS' && (webhook_code === 'SYNC_UPDATES_AVAILABLE' || webhook_code === 'DEFAULT_UPDATE')) {
    console.log(`Transactions available for item: ${item_id}`);
    
    try {
        // 1. Get the UserID and connections for this item_id
        const { data: connection, error: connError } = await supabase
            .from('financial_connections')
            .select('*')
            .eq('plaid_item_id', item_id)
            .single();
            
        if (connError || !connection) {
            console.error('No connection found for item_id:', item_id);
            return;
        }
        
        const userId = connection.user_id;

        // 2. Fetch new transactions from Plaid (simplified sync)
        const syncResponse = await plaidClient.transactionsSync({
            access_token: connection.plaid_access_token,
            // In a real app, store and use the cursor here to only get new ones
        });
        const addedTransactions = syncResponse.data.added;

        // 3. Fetch active rules for the user
        const { data: rules, error: rulesError } = await supabase
            .from('investment_rules')
            .select('*')
            .eq('user_id', userId)
            .eq('is_active', true);
            
        if (rulesError || !rules?.length) {
            console.log('No active rules for user:', userId);
            return;
        }

        // Initialize Alpaca Client for this user
        const alpaca = new Alpaca({
            keyId: connection.alpaca_api_key,
            secretKey: connection.alpaca_secret_key,
            paper: true, // Paper trading default
        });

        // 4. Process each new transaction
        for (const txn of addedTransactions) {
            const merchantName = (txn.merchant_name || txn.name || '').toLowerCase();
            if (!merchantName) continue;

            // Check if merchant matches any rule
            const matchedRule = rules.find(rule => 
                merchantName.includes(rule.brand_name.toLowerCase())
            );

            if (matchedRule) {
                console.log(`Match detected! Bought ${merchantName}, triggering ${matchedRule.stock_ticker} order for $${matchedRule.investment_amount}.`);
                
                try {
                    const order = await alpaca.createOrder({
                        symbol: matchedRule.stock_ticker,
                        notional: matchedRule.investment_amount,
                        side: 'buy',
                        type: 'market',
                        time_in_force: 'day'
                    });

                    // Log to database
                    await supabase
                        .from('automated_investments')
                        .insert({
                            user_id: userId,
                            plaid_transaction_id: txn.transaction_id,
                            alpaca_order_id: order.id,
                            ticker: matchedRule.stock_ticker,
                            amount: matchedRule.investment_amount,
                            status: 'success'
                        });

                } catch (orderError) {
                    console.error(`Failed to place order for ${matchedRule.stock_ticker}:`, orderError.message);
                }
            }
        }

    } catch (err) {
        console.error('Error processing webhook:', err.message);
    }
  }
});

module.exports = router;
