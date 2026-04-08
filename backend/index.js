const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Routes
const plaidRoutes = require('./routes/plaid');
const alpacaRoutes = require('./routes/alpaca');
const webhookRoutes = require('./routes/webhooks');

app.use('/api/plaid', plaidRoutes);
app.use('/api/alpaca', alpacaRoutes);
app.use('/api/webhooks', webhookRoutes);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'spend-friend-api' });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});
