const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { upload } = require('./config/cloudinary');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "junk_and_gems",
  password: "philippa",
  port: 5433, 
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
    
    // Return the same structure as login
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

    // Generate JWT token
    const token = jwt.sign({ id: user.id }, "your_jwt_secret", { expiresIn: "1h" });
    
    // Return the exact structure we're expecting in Flutter
    res.json({ 
      message: "Login successful", 
      token: token, 
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        username: user.username || user.email.split('@')[0] // Fallback to email prefix if username is null
      }
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});


// Get user info (example: dashboard)
app.get("/user/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "SELECT id, name, email, username FROM users WHERE id = $1", 
      [id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: "User not found" });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Image upload endpoint
app.post('/api/upload-image', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        error: 'No image file provided' 
      });
    }

    const imageUrl = req.file.path;

    res.json({
      success: true,
      imageUrl: imageUrl,
      message: 'Image uploaded successfully'
    });

  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Image upload failed' 
    });
  }
});

// Multiple images upload endpoint
app.post('/api/upload-images', upload.array('images', 5), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ 
        success: false, 
        error: 'No image files provided' 
      });
    }

    const imageUrls = req.files.map(file => file.path);

    res.json({
      success: true,
      imageUrls: imageUrls,
      message: `${req.files.length} images uploaded successfully`
    });

  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Image upload failed' 
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

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
