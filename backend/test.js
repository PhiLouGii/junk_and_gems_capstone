// test.js
require('dotenv').config();

const express = require("express");
const app = express();
const port = 3000;

app.use(express.json());

// Simple test route
app.get('/api/test', (req, res) => {
    console.log("✅ Test route was hit!");
    res.json({ 
        success: true, 
        message: 'Server is working!',
        timestamp: new Date().toISOString()
    });
});

// Root route
app.get('/', (req, res) => {
    res.json({ message: 'Junk and Gems API is running!' });
});

app.listen(port, () => {
    console.log(`✅ Server running on http://localhost:${port}`);
    console.log(`✅ Test this: http://localhost:3000/api/test`);
});