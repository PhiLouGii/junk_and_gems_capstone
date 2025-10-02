require('dotenv').config();

const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { upload, uploadToCloudinary } = require('./config/cloudinary');

const app = express();
const port = 3003;

app.use(cors({
  origin: ['http://localhost:3003', 'http://10.0.2.2:3003', 'http://127.0.0.1:3003'],
  credentials: true,
}));
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "junk_and_gems",
  password: "philippa",
  port: 5433, 
});

// Test route
app.get('/api/test-cloudinary', async (req, res) => {
  try {
    res.json({ 
      success: true, 
      message: 'Cloudinary is configured correctly',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: 'Cloudinary configuration error: ' + error.message 
    });
  }
});

// Test Cloudinary configuration
app.get('/api/test-cloudinary-config', async (req, res) => {
  try {
    res.json({ 
      success: true, 
      message: 'Cloudinary configuration test',
      cloudName: process.env.CLOUDINARY_CLOUD_NAME ? 'Set' : 'Missing',
      apiKey: process.env.CLOUDINARY_API_KEY ? 'Set' : 'Missing',
      hasApiSecret: !!process.env.CLOUDINARY_API_SECRET
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: 'Cloudinary test failed: ' + error.message
    });
  }
});

// --- ROUTES ---

// Signup
app.post("/signup", async (req, res) => {
  const { name, email, password } = req.body;
  try {
    if (!name || !email || !password) {
      return res.status(400).json({ error: "Missing fields" });
    }
    
    // Check if user already exists
    const existingUser = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: "User already exists with this email" });
    }
    
    // Generate username from email
    const username = email.split('@')[0];
    
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      "INSERT INTO users (name, email, password, username) VALUES ($1, $2, $3, $4) RETURNING *",
      [name, email, hashedPassword, username]
    );
    
    const user = result.rows[0];
    const token = jwt.sign({ id: user.id }, "your_jwt_secret", { expiresIn: "1h" });
    
    res.json({ 
      message: "User created successfully", 
      token: token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        username: user.username
      }
    });
  } catch (err) {
    console.error("Signup error:", err); 
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Login
app.post("/login", async (req, res) => {
  const { email, password } = req.body;
  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (result.rows.length === 0) {
      return res.status(400).json({ error: "User not found" });
    }

    const user = result.rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(400).json({ error: "Incorrect password" });
    }

    const token = jwt.sign({ id: user.id }, "your_jwt_secret", { expiresIn: "1h" });
    
    res.json({ 
      message: "Login successful", 
      token: token, 
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        username: user.username || user.email.split('@')[0]
      }
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Image upload endpoint
app.post('/api/upload-image', upload.single('image'), async (req, res) => {
  try {
    console.log('📸 Upload endpoint called');
    
    if (!req.file) {
      console.log('❌ No file provided');
      return res.status(400).json({ 
        success: false, 
        error: 'No image file provided' 
      });
    }

    console.log('✅ File received:', {
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size
    });

    console.log('☁️ Uploading to Cloudinary...');
    const result = await uploadToCloudinary(req.file.buffer);
    console.log('✅ Upload successful:', result.secure_url);
    
    res.json({
      success: true,
      imageUrl: result.secure_url,
      message: 'Image uploaded successfully'
    });

  } catch (error) {
    console.error('❌ Upload error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Image upload failed: ' + error.message 
    });
  }
});

// Multiple images upload endpoint
app.post('/api/upload-images', upload.array('images', 5), async (req, res) => {
  try {
    console.log('📸 Multiple upload endpoint called');
    
    if (!req.files || req.files.length === 0) {
      console.log('❌ No files provided');
      return res.status(400).json({ 
        success: false, 
        error: 'No image files provided' 
      });
    }

    console.log(`✅ ${req.files.length} files received`);

    console.log('☁️ Uploading to Cloudinary...');
    const uploadPromises = req.files.map(file => 
      uploadToCloudinary(file.buffer)
    );

    const results = await Promise.all(uploadPromises);
    const imageUrls = results.map(result => result.secure_url);

    console.log(`✅ All uploads successful: ${imageUrls.length} images`);
    
    res.json({
      success: true,
      imageUrls: imageUrls,
      message: `${req.files.length} images uploaded successfully`
    });

  } catch (error) {
    console.error('❌ Upload error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Image upload failed: ' + error.message 
    });
  }
});

// Get all materials
app.get("/materials", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.email as uploader_email
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      ORDER BY m.created_at DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Create new material/donation
app.post("/materials", async (req, res) => {
  const { 
    title, 
    description, 
    category, 
    quantity, 
    location, 
    delivery_option, 
    available_from, 
    available_until, 
    is_fragile, 
    contact_preferences,
    image_urls,
    uploader_id 
  } = req.body;

  try {
    if (!title || !description || !category || !uploader_id) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const result = await pool.query(
      `INSERT INTO materials 
       (title, description, category, quantity, location, delivery_option, 
        available_from, available_until, is_fragile, contact_preferences, 
        image_urls, uploader_id) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
       RETURNING *`,
      [
        title, description, category, quantity, location, delivery_option,
        available_from, available_until, is_fragile, 
        JSON.stringify(contact_preferences), 
        JSON.stringify(image_urls), uploader_id
      ]
    );

    // Get the created material with uploader info
    const materialWithUploader = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.email as uploader_email
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      WHERE m.id = $1
    `, [result.rows[0].id]);

    res.status(201).json(materialWithUploader.rows[0]);
  } catch (err) {
    console.error("Create material error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get featured artisans
app.get("/api/artisans", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        id, name, username, profile_image_url, specialty, bio,
        donation_count::integer, created_at, user_type
      FROM users 
      WHERE user_type IN ('artisan', 'both')
      ORDER BY donation_count::integer DESC, created_at DESC
      LIMIT 10
    `);
    res.json(result.rows);
  } catch (err) {
    console.error("Get artisans error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get top contributors
app.get("/api/contributors", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        u.id, u.name, u.username, u.profile_image_url, 
        u.specialty, u.bio, u.donation_count::integer, u.created_at, u.user_type,
        COUNT(m.id)::integer as material_count,
        COALESCE(STRING_AGG(DISTINCT m.category, ', '), 'Various') as top_categories
      FROM users u
      LEFT JOIN materials m ON u.id = m.uploader_id
      WHERE u.user_type IN ('contributor', 'both') OR m.id IS NOT NULL
      GROUP BY u.id, u.name, u.username, u.profile_image_url, 
               u.specialty, u.bio, u.donation_count, u.created_at, u.user_type
      ORDER BY u.donation_count::integer DESC, material_count DESC
      LIMIT 10
    `);
    res.json(result.rows);
  } catch (err) {
    console.error("Get contributors error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Test route to check all users
app.get("/api/test-users", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, user_type, specialty, donation_count 
      FROM users 
      ORDER BY name
    `);
    
    res.json({
      success: true,
      count: result.rows.length,
      users: result.rows
    });
    
  } catch (err) {
    console.error("Test users error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Update user profile
app.put("/api/users/:id/profile", async (req, res) => {
  const { id } = req.params;
  const { name, specialty, bio, user_type } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users 
       SET name = $1, specialty = $2, bio = $3, user_type = $4 
       WHERE id = $5 
       RETURNING id, name, username, profile_image_url, specialty, bio, user_type`,
      [name, specialty, bio, user_type, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("Update profile error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Upload profile picture
app.post("/api/users/:id/profile-picture", upload.single('profile_picture'), async (req, res) => {
  const { id } = req.params;

  try {
    if (!req.file) {
      return res.status(400).json({ error: "No image file provided" });
    }

    const result = await uploadToCloudinary(req.file.buffer);
    const imageUrl = result.secure_url;

    // Update user's profile picture
    await pool.query(
      "UPDATE users SET profile_image_url = $1 WHERE id = $2",
      [imageUrl, id]
    );

    res.json({
      success: true,
      profile_image_url: imageUrl,
      message: "Profile picture updated successfully"
    });

  } catch (error) {
    console.error("Profile picture upload error:", error);
    res.status(500).json({ error: "Profile picture upload failed" });
  }
});

app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
  console.log(`📡 Available test routes:`);
  console.log(`   GET  /api/test-cloudinary`);
  console.log(`   GET  /api/test-cloudinary-config`);
  console.log(`   GET  /api/test-users`);
  console.log(`   GET  /api/artisans`);
  console.log(`   GET  /api/contributors`);
});