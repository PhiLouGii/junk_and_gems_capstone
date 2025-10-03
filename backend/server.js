require('dotenv').config();

const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const app = express();
const port = 3003;

app.use(cors({
  origin: ['http://localhost:3003', 'http://10.0.2.2:3003', 'http://127.0.0.1:3003', 'http://localhost:3003'],
  credentials: true,
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// PostgreSQL connection
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "junk_and_gems",
  password: "philippa",
  port: 5433, 
});

// --- AUTHENTICATION MIDDLEWARE ---
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: "Access token required" });
  }

  jwt.verify(token, "your_jwt_secret", (err, user) => {
    if (err) {
      return res.status(403).json({ error: "Invalid token" });
    }
    req.user = user;
    next();
  });
}

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

// Get all materials with real data
app.get("/materials", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.email as uploader_email,
        u.profile_image_url as uploader_avatar
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      WHERE m.is_claimed = false
      ORDER BY m.created_at DESC
    `);
    
    // Convert database results to frontend format
    const materials = result.rows.map(material => ({
      id: material.id,
      title: material.title,
      description: material.description,
      category: material.category,
      quantity: material.quantity,
      location: material.location,
      delivery_option: material.delivery_option,
      available_from: material.available_from,
      available_until: material.available_until,
      is_fragile: material.is_fragile,
      contact_preferences: material.contact_preferences,
      image_urls: material.image_data_base64 ? material.image_data_base64.map(img => `data:image/jpeg;base64,${img}`) : [],
      uploader: material.uploader_name,
      amount: material.quantity,
      created_at: material.created_at,
      time: formatTimeAgo(material.created_at)
    }));

    res.json(materials);
  } catch (err) {
    console.error("Get materials error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Create new material/donation with base64 images
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
    image_data_base64, // Array of base64 strings
    uploader_id 
  } = req.body;

  try {
    if (!title || !description || !category || !uploader_id) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Process base64 images - extract just the data part
    const processedImages = image_data_base64 ? image_data_base64.map(img => {
      // Remove data:image/xxx;base64, prefix if present
      return img.includes('base64,') ? img.split('base64,')[1] : img;
    }) : [];

    const result = await pool.query(
      `INSERT INTO materials 
       (title, description, category, quantity, location, delivery_option, 
        available_from, available_until, is_fragile, contact_preferences, 
        image_data_base64, uploader_id) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
       RETURNING *`,
      [
        title, description, category, quantity, location, delivery_option,
        available_from, available_until, is_fragile, 
        JSON.stringify(contact_preferences), 
        processedImages, uploader_id
      ]
    );

    // Get the created material with uploader info
    const materialWithUploader = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.email as uploader_email,
        u.profile_image_url as uploader_avatar
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      WHERE m.id = $1
    `, [result.rows[0].id]);

    const material = materialWithUploader.rows[0];
    
    // Format response for frontend
    const formattedMaterial = {
      ...material,
      image_urls: material.image_data_base64 ? material.image_data_base64.map(img => `data:image/jpeg;base64,${img}`) : [],
      uploader: material.uploader_name,
      amount: material.quantity,
      time: formatTimeAgo(material.created_at)
    };

    res.status(201).json(formattedMaterial);
  } catch (err) {
    console.error("Create material error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Claim a material
app.put("/materials/:id/claim", authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { claimed_by } = req.body;

  try {
    const result = await pool.query(
      `UPDATE materials 
       SET is_claimed = true, claimed_by = $1, claimed_at = NOW() 
       WHERE id = $2 
       RETURNING *`,
      [claimed_by, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Material not found" });
    }

    res.json({ 
      success: true, 
      message: "Material claimed successfully",
      material: result.rows[0]
    });
  } catch (err) {
    console.error("Claim material error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get user's posted materials
app.get("/users/:userId/materials", authenticateToken, async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      WHERE m.uploader_id = $1
      ORDER BY m.created_at DESC
    `, [userId]);

    const materials = result.rows.map(material => ({
      ...material,
      image_urls: material.image_data_base64 ? material.image_data_base64.map(img => `data:image/jpeg;base64,${img}`) : [],
      uploader: material.uploader_name,
      amount: material.quantity,
      time: formatTimeAgo(material.created_at)
    }));

    res.json(materials);
  } catch (err) {
    console.error("Get user materials error:", err);
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

// Update user profile
app.put("/api/users/:id/profile", authenticateToken, async (req, res) => {
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

// Upload profile picture as base64
app.post("/api/users/:id/profile-picture", authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { image_data_base64 } = req.body;

  try {
    if (!image_data_base64) {
      return res.status(400).json({ error: "No image data provided" });
    }

    // Process base64 image
    const processedImage = image_data_base64.includes('base64,') 
      ? image_data_base64.split('base64,')[1] 
      : image_data_base64;

    // Update user's profile picture
    await pool.query(
      "UPDATE users SET profile_image_url = $1 WHERE id = $2",
      [`data:image/jpeg;base64,${processedImage}`, id]
    );

    res.json({
      success: true,
      profile_image_url: `data:image/jpeg;base64,${processedImage}`,
      message: "Profile picture updated successfully"
    });

  } catch (error) {
    console.error("Profile picture upload error:", error);
    res.status(500).json({ error: "Profile picture upload failed" });
  }
});

// --- CHAT ENDPOINTS (keep existing) ---
app.get("/api/conversations/:userId1/:userId2", authenticateToken, async (req, res) => {
  const { userId1, userId2 } = req.params;
  
  try {
    // Check if conversation already exists
    const existingConv = await pool.query(`
      SELECT c.* 
      FROM conversations c
      JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
      JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
      WHERE cp1.user_id = $1 AND cp2.user_id = $2
    `, [userId1, userId2]);

    if (existingConv.rows.length > 0) {
      return res.json(existingConv.rows[0]);
    }

    // Create new conversation
    const newConv = await pool.query(
      'INSERT INTO conversations DEFAULT VALUES RETURNING *'
    );
    
    const convId = newConv.rows[0].id;

    // Add both users as participants
    await pool.query(
      'INSERT INTO conversation_participants (conversation_id, user_id) VALUES ($1, $2), ($1, $3)',
      [convId, userId1, userId2]
    );

    res.json(newConv.rows[0]);
  } catch (err) {
    console.error("Get conversation error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.get("/api/users/:userId/conversations", authenticateToken, async (req, res) => {
  const { userId } = req.params;
  
  try {
    const result = await pool.query(`
      SELECT 
        c.id as conversation_id,
        c.updated_at,
        u.id as other_user_id,
        u.name as other_user_name,
        u.profile_image_url,
        last_msg.message_text as last_message,
        last_msg.sent_at as last_message_time,
        (SELECT COUNT(*) FROM messages m 
         WHERE m.conversation_id = c.id 
         AND m.sender_id != $1 
         AND m.read_at IS NULL) as unread_count
      FROM conversations c
      JOIN conversation_participants cp ON c.id = cp.conversation_id
      JOIN users u ON u.id = cp.user_id AND u.id != $1
      LEFT JOIN LATERAL (
        SELECT message_text, sent_at
        FROM messages 
        WHERE conversation_id = c.id 
        ORDER BY sent_at DESC 
        LIMIT 1
      ) last_msg ON true
      WHERE cp.user_id = $1
      ORDER BY last_msg.sent_at DESC NULLS LAST
    `, [userId]);

    res.json(result.rows);
  } catch (err) {
    console.error("Get conversations error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.get("/api/conversations/:conversationId/messages", authenticateToken, async (req, res) => {
  const { conversationId } = req.params;
  
  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as sender_name,
        u.profile_image_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.sent_at ASC
    `, [conversationId]);

    res.json(result.rows);
  } catch (err) {
    console.error("Get messages error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.post("/api/conversations/:conversationId/messages", authenticateToken, async (req, res) => {
  const { conversationId } = req.params;
  const { senderId, messageText } = req.body;
  
  try {
    const result = await pool.query(`
      INSERT INTO messages (conversation_id, sender_id, message_text)
      VALUES ($1, $2, $3)
      RETURNING *,
        (SELECT name FROM users WHERE id = $2) as sender_name,
        (SELECT profile_image_url FROM users WHERE id = $2) as sender_avatar
    `, [conversationId, senderId, messageText]);

    // Update conversation updated_at
    await pool.query(
      'UPDATE conversations SET updated_at = NOW() WHERE id = $1',
      [conversationId]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Send message error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Helper function to format time ago
function formatTimeAgo(date) {
  const now = new Date();
  const diffMs = now - new Date(date);
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins} mins ago`;
  if (diffHours < 24) return `${diffHours} hrs ago`;
  if (diffDays < 7) return `${diffDays} days ago`;
  return new Date(date).toLocaleDateString();
}

app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
});