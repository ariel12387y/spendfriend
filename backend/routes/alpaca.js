const express = require('express');
const router = express.Router();
const Alpaca = require('@alpacahq/alpaca-trade-api');
const { supabase } = require('../services/supabaseClient');

// Endpoint to associate Alpaca API keys with a user
router.post('/connect', async (req, res) => {
    const { userId, alpacaKey, alpacaSecret } = req.body;
    
    if (!userId || !alpacaKey || !alpacaSecret) {
        return res.status(400).json({ error: 'Missing required parameters' });
    }

    try {
        // Validate keys actually work by checking the account
        const alpaca = new Alpaca({
            keyId: alpacaKey,
            secretKey: alpacaSecret,
            paper: true,
        });

        const account = await alpaca.getAccount();
        if (account.status !== 'ACTIVE') {
            return res.status(400).json({ error: 'Alpaca account is not active' });
        }

        // Store securely in Supabase
        const { error: dbError } = await supabase
            .from('financial_connections')
            .upsert({ 
                user_id: userId, 
                alpaca_api_key: alpacaKey, 
                alpaca_secret_key: alpacaSecret 
            }, { onConflict: 'user_id' });

        if (dbError) throw dbError;

        res.json({ success: true, message: 'Alpaca Connected' });
    } catch (err) {
        console.error('Alpaca Connection Error:', err.message);
        res.status(500).json({ error: 'Failed to connect Alpaca' });
    }
});

module.exports = router;
