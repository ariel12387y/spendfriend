const express = require('express');
const router = express.Router();
const { Configuration, PlaidApi, PlaidEnvironments } = require('plaid');
const { supabase } = require('../services/supabaseClient');

// Initialize Plaid client
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

// Create a link token
router.post('/create_link_token', async (req, res) => {
  try {
    const request = {
      user: { client_user_id: req.body.userId || 'user_good' },
      client_name: 'Spend Friend',
      products: ['transactions'],
      country_codes: ['US'],
      language: 'en',
      webhook: process.env.WEBHOOK_URL,
    };
    const createTokenResponse = await plaidClient.linkTokenCreate(request);
    res.json(createTokenResponse.data);
  } catch (error) {
    console.error('Plaid Link Token Error:', error.response?.data || error.message);
    res.status(500).json({ error: 'Failed to create link token' });
  }
});

// Exchange public token for access token
router.post('/set_access_token', async (req, res) => {
  const { public_token, userId } = req.body;
  
  if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
  }

  try {
    const tokenResponse = await plaidClient.itemPublicTokenExchange({
      public_token: public_token,
    });
    const accessToken = tokenResponse.data.access_token;
    const itemId = tokenResponse.data.item_id;

    // Securely Store in Supabase
    const { error: dbError } = await supabase
      .from('financial_connections')
      .upsert({ 
          user_id: userId, 
          plaid_access_token: accessToken, 
          plaid_item_id: itemId 
      }, { onConflict: 'user_id' });

    if (dbError) throw dbError;

    res.json({ success: true, message: "Plaid Connected Successfully" });
  } catch (error) {
    console.error('Plaid Exchange Token Error:', error.response?.data || error.message);
    res.status(500).json({ error: 'Failed to exchange and store token' });
  }
});

// Get Investment History from Supabase
router.get('/history', async (req, res) => {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ error: 'userId is required' });

    try {
        const { data: history, error } = await supabase
            .from('automated_investments')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json(history);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
