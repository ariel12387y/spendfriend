const express = require('express');
const router = express.Router();
const appleSignin = require('apple-signin-auth');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

// Apple Sign-In Token Verification
router.post('/apple', async (req, res) => {
    const { identityToken, fullName, email } = req.body;

    if (!identityToken) {
        return res.status(400).json({ error: 'Missing identityToken' });
    }

    try {
        // 1. Verify the identityToken with Apple
        const { sub: appleId, email: appleEmail } = await appleSignin.verifyIdToken(identityToken, {
            // Re-verify against your app's Bundle ID
            audience: process.env.APPLE_CLIENT_ID, 
            ignoreExpiration: false,
        });

        const userEmail = email || appleEmail;

        // 2. Link or Create User in Supabase
        // Note: Using the public 'users' table we created for metadata
        const { data: user, error } = await supabase
            .from('users')
            .upsert({ 
                apple_id: appleId, 
                email: userEmail,
                full_name: fullName,
                last_login: new Date()
            }, { onConflict: 'apple_id' })
            .select()
            .single();

        if (error) {
            console.error('Supabase Upsert Error:', error);
            throw error;
        }

        res.json({ 
            success: true, 
            userId: user.id,
            email: user.email 
        });

    } catch (error) {
        console.error('Apple Auth Error:', error);
        res.status(500).json({ error: 'Authentication failed: ' + error.message });
    }
});

module.exports = router;
