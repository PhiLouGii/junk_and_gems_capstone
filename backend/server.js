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
  
  console.log(`📨 Loading conversations for user: ${userId}`);
  
  try {
    // Verify the user exists
    const userCheck = await pool.query('SELECT id FROM users WHERE id = $1', [userId]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const result = await pool.query(`
      SELECT DISTINCT
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
      JOIN users u ON (
        u.id != $1 AND 
        u.id IN (SELECT user_id FROM conversation_participants WHERE conversation_id = c.id AND user_id != $1)
      )
      LEFT JOIN LATERAL (
        SELECT message_text, sent_at
        FROM messages 
        WHERE conversation_id = c.id 
        ORDER BY sent_at DESC 
        LIMIT 1
      ) last_msg ON true
      WHERE cp.user_id = $1
      ORDER BY last_msg.sent_at DESC NULLS LAST, c.updated_at DESC
    `, [userId]);

    console.log(`✅ Found ${result.rows.length} conversations for user ${userId}`);
    
    // Debug: log the actual conversations found
    if (result.rows.length > 0) {
      console.log('🎯 Conversations found:', result.rows);
    } else {
      console.log('❌ No conversations found with current query');
      
      // Let's try a simpler query to debug
      const debugResult = await pool.query(`
        SELECT 
          c.id as conversation_id,
          cp.user_id,
          (SELECT COUNT(*) FROM conversation_participants WHERE conversation_id = c.id) as participant_count
        FROM conversations c
        JOIN conversation_participants cp ON c.id = cp.conversation_id
        WHERE cp.user_id = $1
      `, [userId]);
      
      console.log('🔍 Debug query result:', debugResult.rows);
    }
    
    res.json(result.rows);
  } catch (err) {
    console.error("❌ Get conversations error:", err);
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: "Check server logs for more information"
    });
  }
});

app.get("/api/debug/user-conversations/:userId", async (req, res) => {
  const { userId } = req.params;
  
  try {
    console.log(`🔍 Debug: Checking conversations for user ${userId}`);
    
    // Check conversation participants
    const participants = await pool.query(`
      SELECT cp.*, u.name as user_name
      FROM conversation_participants cp
      JOIN users u ON cp.user_id = u.id
      WHERE cp.conversation_id IN (
        SELECT conversation_id FROM conversation_participants WHERE user_id = $1
      )
      ORDER BY cp.conversation_id, cp.user_id
    `, [userId]);
    
    // Check messages
    const messages = await pool.query(`
      SELECT m.*, u.name as sender_name
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id IN (
        SELECT conversation_id FROM conversation_participants WHERE user_id = $1
      )
      ORDER BY m.conversation_id, m.sent_at
    `, [userId]);
    
    res.json({
      user_id: userId,
      participant_data: participants.rows,
      message_data: messages.rows,
      summary: {
        total_conversations: new Set(participants.rows.map(p => p.conversation_id)).size,
        total_messages: messages.rows.length
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
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

// Start or get conversation with artisan
app.post("/api/conversations/start", async (req, res) => {
  console.log('=== CONVERSATION START REQUEST ===');
  console.log('Request body:', req.body);
  
  const { currentUserId, otherUserId, productId, initialMessage } = req.body;
  
  // Validate required fields
  if (!currentUserId || !otherUserId) {
    console.log('❌ Missing required fields');
    return res.status(400).json({ 
      error: "Missing required fields: currentUserId and otherUserId are required" 
    });
  }

  try {
    console.log('Checking if users exist...');
    
    // Check if both users exist
    const userCheck = await pool.query(
      'SELECT id, name FROM users WHERE id IN ($1, $2) ORDER BY id',
      [currentUserId, otherUserId]
    );

    console.log('Found users:', userCheck.rows);

    if (userCheck.rows.length < 2) {
      const foundIds = userCheck.rows.map(row => row.id);
      const missingIds = [currentUserId, otherUserId].filter(id => !foundIds.includes(parseInt(id)));
      console.log(`❌ Missing users: ${missingIds.join(', ')}`);
      return res.status(400).json({ 
        error: `Users not found: ${missingIds.join(', ')}` 
      });
    }

    console.log('✓ Both users exist');

    // Check if conversation already exists between these users
    const existingConv = await pool.query(`
      SELECT c.* 
      FROM conversations c
      JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
      JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
      WHERE cp1.user_id = $1 AND cp2.user_id = $2
      LIMIT 1
    `, [currentUserId, otherUserId]);

    let conversationId;
    
    if (existingConv.rows.length > 0) {
      conversationId = existingConv.rows[0].id;
      console.log('✓ Found existing conversation:', conversationId);
    } else {
      // Create new conversation
      const newConv = await pool.query(
        'INSERT INTO conversations (created_at, updated_at) VALUES (NOW(), NOW()) RETURNING *'
      );
      
      conversationId = newConv.rows[0].id;
      console.log('✓ Created new conversation:', conversationId);

      // Add both users as participants
      await pool.query(
        'INSERT INTO conversation_participants (conversation_id, user_id) VALUES ($1, $2), ($1, $3)',
        [conversationId, currentUserId, otherUserId]
      );
      console.log('✓ Added participants to conversation');
    }

    // If there's an initial message, send it
    if (initialMessage) {
      await pool.query(
        'INSERT INTO messages (conversation_id, sender_id, message_text, sent_at) VALUES ($1, $2, $3, NOW())',
        [conversationId, currentUserId, initialMessage]
      );
      console.log('✓ Added initial message:', initialMessage);
      
      // Update conversation updated_at
      await pool.query(
        'UPDATE conversations SET updated_at = NOW() WHERE id = $1',
        [conversationId]
      );
    }

    // Return conversation info
    const conversationInfo = await pool.query(`
      SELECT 
        c.*,
        json_agg(
          json_build_object(
            'user_id', u.id,
            'name', u.name,
            'email', u.email
          )
        ) as participants
      FROM conversations c
      JOIN conversation_participants cp ON c.id = cp.conversation_id
      JOIN users u ON cp.user_id = u.id
      WHERE c.id = $1
      GROUP BY c.id
    `, [conversationId]);

    console.log('✓ Conversation created successfully:', conversationId);
    
    res.json({
      id: conversationId,
      ...conversationInfo.rows[0]
    });
    
  } catch (err) {
    console.error("❌ Start conversation error:", err);
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: "Check server logs for more information"
    });
  }
});

// Mark messages as read
app.put("/api/conversations/:conversationId/read", authenticateToken, async (req, res) => {
  const { conversationId } = req.params;
  const { userId } = req.body;

  try {
    await pool.query(`
      UPDATE messages 
      SET read_at = NOW() 
      WHERE conversation_id = $1 AND sender_id != $2 AND read_at IS NULL
    `, [conversationId, userId]);

    res.json({ success: true });
  } catch (err) {
    console.error("Mark as read error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.post("/api/setup-messaging", async (req, res) => {
  try {
    console.log('Starting messaging setup...');

    // Create conversations table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS conversations (
        id SERIAL PRIMARY KEY,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✓ Created conversations table');

    // Create conversation_participants table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS conversation_participants (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        joined_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(conversation_id, user_id)
      )
    `);
    console.log('✓ Created conversation_participants table');

    // Create messages table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        message_text TEXT NOT NULL,
        sent_at TIMESTAMP DEFAULT NOW(),
        read_at TIMESTAMP NULL
      )
    `);
    console.log('✓ Created messages table');

    // Create a simple password hash that works
    const simpleHash = await bcrypt.hash('testpassword123', 10);

    // Check and create test users
    const existingUser1 = await pool.query('SELECT id FROM users WHERE id = 1');
    if (existingUser1.rows.length === 0) {
      await pool.query(
        'INSERT INTO users (id, name, email, password) VALUES ($1, $2, $3, $4)',
        [1, 'Test User', 'test@user.com', simpleHash]
      );
      console.log('✓ Created test user 1');
    } else {
      console.log('✓ Test user 1 already exists');
    }

    const existingUser2 = await pool.query('SELECT id FROM users WHERE id = 2');
    if (existingUser2.rows.length === 0) {
      await pool.query(
        'INSERT INTO users (id, name, email, password) VALUES ($1, $2, $3, $4)',
        [2, 'Nthati Radiapole', 'nthati@artisan.com', simpleHash]
      );
      console.log('✓ Created test user 2');
    } else {
      console.log('✓ Test user 2 already exists');
    }

    res.json({ 
      success: true, 
      message: "Messaging setup completed successfully",
      test_users: {
        buyer: { id: 1, name: 'Test User' },
        artisan: { id: 2, name: 'Nthati Radiapole' }
      }
    });
  } catch (err) {
    console.error("Setup error:", err);
    res.status(500).json({ error: "Setup failed: " + err.message });
  }
});


app.get("/api/debug/users", async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name, email FROM users ORDER BY id');
    res.json({
      total_users: result.rows.length,
      users: result.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Test if specific users exist
app.get("/api/debug/users/:id", async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name, email FROM users WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: `User ${req.params.id} not found` });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
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

app.get("/api/debug/all-users", async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name, email FROM users ORDER BY id');
    res.json({
      total_users: result.rows.length,
      users: result.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get user's cart
app.get("/api/cart", authenticateToken, async (req, res) => {
  const userId = req.user.id;

  try {
    // Get or create cart for user
    let cart = await pool.query(
      "SELECT * FROM carts WHERE user_id = $1",
      [userId]
    );

    if (cart.rows.length === 0) {
      const newCart = await pool.query(
        "INSERT INTO carts (user_id) VALUES ($1) RETURNING *",
        [userId]
      );
      cart = newCart;
    }

    const cartId = cart.rows[0].id;

    // Get cart items with product details
    const cartItems = await pool.query(`
      SELECT 
        ci.*,
        p.title,
        p.price,
        p.image_url,
        p.description
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
      WHERE ci.cart_id = $1
    `, [cartId]);

    res.json({
      cartId: cartId,
      items: cartItems.rows,
      totalItems: cartItems.rows.reduce((sum, item) => sum + item.quantity, 0)
    });
  } catch (err) {
    console.error("Get cart error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Add item to cart
app.post("/api/cart/items", authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { productId, quantity = 1 } = req.body;

  try {
    // Get user's cart
    let cart = await pool.query(
      "SELECT * FROM carts WHERE user_id = $1",
      [userId]
    );

    if (cart.rows.length === 0) {
      const newCart = await pool.query(
        "INSERT INTO carts (user_id) VALUES ($1) RETURNING *",
        [userId]
      );
      cart = newCart;
    }

    const cartId = cart.rows[0].id;

    // Check if item already exists in cart
    const existingItem = await pool.query(
      "SELECT * FROM cart_items WHERE cart_id = $1 AND product_id = $2",
      [cartId, productId]
    );

    if (existingItem.rows.length > 0) {
      // Update quantity if item exists
      const updatedItem = await pool.query(
        "UPDATE cart_items SET quantity = quantity + $1, updated_at = NOW() WHERE cart_id = $2 AND product_id = $3 RETURNING *",
        [quantity, cartId, productId]
      );
      res.json(updatedItem.rows[0]);
    } else {
      // Add new item to cart
      const newItem = await pool.query(
        "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *",
        [cartId, productId, quantity]
      );
      res.status(201).json(newItem.rows[0]);
    }
  } catch (err) {
    console.error("Add to cart error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Update cart item quantity
app.put("/api/cart/items/:itemId", authenticateToken, async (req, res) => {
  const { itemId } = req.params;
  const { quantity } = req.body;
  const userId = req.user.id;

  try {
    // Verify user owns this cart item
    const cartItem = await pool.query(`
      SELECT ci.* FROM cart_items ci
      JOIN carts c ON ci.cart_id = c.id
      WHERE ci.id = $1 AND c.user_id = $2
    `, [itemId, userId]);

    if (cartItem.rows.length === 0) {
      return res.status(404).json({ error: "Cart item not found" });
    }

    if (quantity <= 0) {
      // Remove item if quantity is 0 or less
      await pool.query("DELETE FROM cart_items WHERE id = $1", [itemId]);
      res.json({ message: "Item removed from cart" });
    } else {
      // Update quantity
      const updatedItem = await pool.query(
        "UPDATE cart_items SET quantity = $1, updated_at = NOW() WHERE id = $2 RETURNING *",
        [quantity, itemId]
      );
      res.json(updatedItem.rows[0]);
    }
  } catch (err) {
    console.error("Update cart item error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Remove item from cart
app.delete("/api/cart/items/:itemId", authenticateToken, async (req, res) => {
  const { itemId } = req.params;
  const userId = req.user.id;

  try {
    // Verify user owns this cart item
    const cartItem = await pool.query(`
      SELECT ci.* FROM cart_items ci
      JOIN carts c ON ci.cart_id = c.id
      WHERE ci.id = $1 AND c.user_id = $2
    `, [itemId, userId]);

    if (cartItem.rows.length === 0) {
      return res.status(404).json({ error: "Cart item not found" });
    }

    await pool.query("DELETE FROM cart_items WHERE id = $1", [itemId]);
    res.json({ message: "Item removed from cart" });
  } catch (err) {
    console.error("Remove cart item error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Clear entire cart
app.delete("/api/cart", authenticateToken, async (req, res) => {
  const userId = req.user.id;

  try {
    const cart = await pool.query(
      "SELECT * FROM carts WHERE user_id = $1",
      [userId]
    );

    if (cart.rows.length === 0) {
      return res.status(404).json({ error: "Cart not found" });
    }

    const cartId = cart.rows[0].id;
    await pool.query("DELETE FROM cart_items WHERE cart_id = $1", [cartId]);
    
    res.json({ message: "Cart cleared successfully" });
  } catch (err) {
    console.error("Clear cart error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// --- CHECKOUT ENDPOINTS ---

// Create order from cart
app.post("/api/orders", authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { appliedGems = 0, shippingAddress, paymentMethod } = req.body;

  try {
    // Get user's cart with items
    const cart = await pool.query(`
      SELECT 
        c.id as cart_id,
        ci.product_id,
        ci.quantity,
        p.title,
        p.price,
        p.image_url,
        u.available_gems
      FROM carts c
      JOIN cart_items ci ON c.id = ci.cart_id
      JOIN products p ON ci.product_id = p.id
      JOIN users u ON c.user_id = u.id
      WHERE c.user_id = $1
    `, [userId]);

    if (cart.rows.length === 0) {
      return res.status(400).json({ error: "Cart is empty" });
    }

    // Calculate totals
    const subtotal = cart.rows.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    
    // Validate applied gems
    const availableGems = cart.rows[0].available_gems || 0;
    const actualAppliedGems = Math.min(appliedGems, availableGems, subtotal);
    
    const total = subtotal - actualAppliedGems;

    // Generate order number
    const orderNumber = `ORD-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    // Start transaction
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Create order
      const orderResult = await client.query(`
        INSERT INTO orders (user_id, order_number, subtotal, gems_discount, total_amount, shipping_address, payment_method)
        VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *
      `, [userId, orderNumber, subtotal, actualAppliedGems, total, shippingAddress, paymentMethod]);

      const order = orderResult.rows[0];

      // Create order items
      for (const item of cart.rows) {
        await client.query(`
          INSERT INTO order_items (order_id, product_id, quantity, price_at_time)
          VALUES ($1, $2, $3, $4)
        `, [order.id, item.product_id, item.quantity, item.price]);
      }

      // Update user's gems if any were applied
      if (actualAppliedGems > 0) {
        await client.query(
          "UPDATE users SET available_gems = available_gems - $1 WHERE id = $2",
          [actualAppliedGems, userId]
        );
      }

      // Clear the cart
      await client.query("DELETE FROM cart_items WHERE cart_id = $1", [cart.rows[0].cart_id]);

      await client.query('COMMIT');

      // Get complete order details
      const orderDetails = await pool.query(`
        SELECT 
          o.*,
          json_agg(
            json_build_object(
              'product_id', oi.product_id,
              'title', p.title,
              'price', oi.price_at_time,
              'quantity', oi.quantity,
              'image_url', p.image_url
            )
          ) as items
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN products p ON oi.product_id = p.id
        WHERE o.id = $1
        GROUP BY o.id
      `, [order.id]);

      res.status(201).json({
        success: true,
        order: orderDetails.rows[0],
        message: "Order created successfully"
      });

    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }

  } catch (err) {
    console.error("Create order error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Get user's orders
app.get("/api/orders", authenticateToken, async (req, res) => {
  const userId = req.user.id;

  try {
    const orders = await pool.query(`
      SELECT 
        o.*,
        json_agg(
          json_build_object(
            'product_id', oi.product_id,
            'title', p.title,
            'price', oi.price_at_time,
            'quantity', oi.quantity,
            'image_url', p.image_url
          )
        ) as items
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      JOIN products p ON oi.product_id = p.id
      WHERE o.user_id = $1
      GROUP BY o.id
      ORDER BY o.created_at DESC
    `, [userId]);

    res.json(orders.rows);
  } catch (err) {
    console.error("Get orders error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get user's available gems
app.get("/api/user/gems", authenticateToken, async (req, res) => {
  const userId = req.user.id;

  try {
    const result = await pool.query(
      "SELECT available_gems FROM users WHERE id = $1",
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({ available_gems: result.rows[0].available_gems });
  } catch (err) {
    console.error("Get user gems error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// --- PRODUCTS ENDPOINTS ---

// Get all products
app.get("/api/products", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT * FROM products 
      ORDER BY created_at DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error("Get products error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Add some sample products (run this once)
app.post("/api/setup-products", async (req, res) => {
  try {
    // Insert sample products
    const sampleProducts = [
      {
        title: 'Sta-Soft Lamp',
        description: 'Beautiful lamp made from recycled materials',
        price: 400,
        image_url: 'assets/images/featured3.jpg',
        category: 'lighting'
      },
      {
        title: 'Can Tab Lamp',
        description: 'Creative lamp made from can tabs',
        price: 650,
        image_url: 'assets/images/featured6.jpg',
        category: 'lighting'
      },
      {
        title: 'Denim Patchwork Bag',
        description: 'Unique bag made from denim patches',
        price: 330,
        image_url: 'assets/images/upcycled1.jpg',
        category: 'accessories'
      }
    ];

    for (const product of sampleProducts) {
      await pool.query(
        `INSERT INTO products (title, description, price, image_url, category) 
         VALUES ($1, $2, $3, $4, $5)`,
        [product.title, product.description, product.price, product.image_url, product.category]
      );
    }

    res.json({ message: "Sample products added successfully" });
  } catch (err) {
    console.error("Setup products error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.get("/api/conversations/users/:userId1/:userId2", authenticateToken, async (req, res) => {
  const { userId1, userId2 } = req.params;
  
  try {
    const result = await pool.query(`
      SELECT c.* 
      FROM conversations c
      JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
      JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
      WHERE cp1.user_id = $1 AND cp2.user_id = $2
      LIMIT 1
    `, [userId1, userId2]);

    if (result.rows.length > 0) {
      res.json(result.rows[0]);
    } else {
      res.status(404).json({ error: "Conversation not found" });
    }
  } catch (err) {
    console.error("Get conversation between users error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.get("/api/debug/conversations/:conversationId/messages", async (req, res) => {
  const { conversationId } = req.params;
  
  console.log(`🔍 DEBUG: Checking messages for conversation ${conversationId}`);
  
  try {
    // First check if conversation exists
    const conversationCheck = await pool.query(
      'SELECT * FROM conversations WHERE id = $1',
      [conversationId]
    );
    
    if (conversationCheck.rows.length === 0) {
      return res.json({ 
        error: 'Conversation not found',
        conversationId: conversationId 
      });
    }
    
    console.log(`✅ Conversation ${conversationId} exists`);
    
    // Check participants
    const participants = await pool.query(
      'SELECT * FROM conversation_participants WHERE conversation_id = $1',
      [conversationId]
    );
    
    console.log(`✅ Participants: ${participants.rows.length}`);
    
    // Get messages
    const messages = await pool.query(`
      SELECT 
        m.*,
        u.name as sender_name,
        u.profile_image_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.sent_at ASC
    `, [conversationId]);
    
    console.log(`✅ Found ${messages.rows.length} messages`);
    
    res.json({
      conversation_exists: true,
      participant_count: participants.rows.length,
      message_count: messages.rows.length,
      participants: participants.rows,
      messages: messages.rows
    });
    
  } catch (err) {
    console.error("Debug conversation error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/conversations/:conversationId/messages", authenticateToken, async (req, res) => {
  const { conversationId } = req.params;
  
  console.log(`📨 Loading messages for conversation: ${conversationId}`);
  
  try {
    // First check if user has access to this conversation
    const accessCheck = await pool.query(`
      SELECT 1 FROM conversation_participants 
      WHERE conversation_id = $1 AND user_id = $2
    `, [conversationId, req.user.id]);

    if (accessCheck.rows.length === 0) {
      console.log(`❌ User ${req.user.id} doesn't have access to conversation ${conversationId}`);
      return res.status(403).json({ error: "Access denied to this conversation" });
    }

    console.log(`✅ User ${req.user.id} has access to conversation ${conversationId}`);

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

    console.log(`✅ Found ${result.rows.length} messages for conversation ${conversationId}`);
    
    res.json(result.rows);
  } catch (err) {
    console.error("❌ Get messages error:", err);
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: "Check server logs for more information"
    });
  }
});

app.get("/api/test-messages/:conversationId", async (req, res) => {
  const { conversationId } = req.params;
  
  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as sender_name
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.sent_at ASC
    `, [conversationId]);

    res.json({
      conversation_id: conversationId,
      message_count: result.rows.length,
      messages: result.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get user's donations
app.get("/api/users/:userId/donations", async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.profile_image_url as uploader_avatar
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      WHERE m.uploader_id = $1
      ORDER BY m.created_at DESC
    `, [userId]);

    const donations = result.rows.map(material => ({
      id: material.id,
      title: material.title,
      description: material.description,
      category: material.category,
      quantity: material.quantity,
      location: material.location,
      image_urls: material.image_data_base64 ? material.image_data_base64.map(img => `data:image/jpeg;base64,${img}`) : [],
      created_at: material.created_at,
      time: formatTimeAgo(material.created_at),
      is_claimed: material.is_claimed
    }));

    res.json(donations);
  } catch (err) {
    console.error("Get user donations error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get user's upcycled products
app.get("/api/users/:userId/products", async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT 
        p.*,
        u.name as creator_name,
        u.profile_image_url as creator_avatar
      FROM products p
      JOIN users u ON p.creator_id = u.id
      WHERE p.creator_id = $1
      ORDER BY p.created_at DESC
    `, [userId]);

    res.json(result.rows);
  } catch (err) {
    console.error("Get user products error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.get("/api/users/:userId/profile", async (req, res) => {
  const { userId } = req.params;

  try {
    const userResult = await pool.query(`
      SELECT 
        id, name, username, profile_image_url, 
        user_type, specialty, bio, donation_count,
        available_gems, created_at
      FROM users 
      WHERE id = $1
    `, [userId]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userResult.rows[0];
    
    // Get user stats from materials table
    const donationsCount = await pool.query(
      'SELECT COUNT(*) FROM materials WHERE uploader_id = $1',
      [userId]
    );
    
    // Get products count (if products table exists with creator_id)
    let productsCount = { rows: [{ count: '0' }] };
    try {
      productsCount = await pool.query(
        'SELECT COUNT(*) FROM products WHERE creator_id = $1',
        [userId]
      );
    } catch (err) {
      console.log('Products table might not exist yet, using 0');
    }

    res.json({
      ...user,
      total_donations: parseInt(donationsCount.rows[0].count),
      total_products: parseInt(productsCount.rows[0].count)
    });
  } catch (err) {
    console.error("Get user profile error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get user's donations (materials they uploaded)
app.get("/api/users/:userId/donations", async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.profile_image_url as uploader_avatar
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      WHERE m.uploader_id = $1
      ORDER BY m.created_at DESC
    `, [userId]);

    const donations = result.rows.map(material => ({
      id: material.id,
      title: material.title,
      description: material.description,
      category: material.category,
      quantity: material.quantity,
      location: material.location,
      image_urls: material.image_data_base64 ? 
        material.image_data_base64.map(img => `data:image/jpeg;base64,${img}`) : [],
      created_at: material.created_at,
      time: formatTimeAgo(material.created_at),
      is_claimed: material.is_claimed
    }));

    res.json(donations);
  } catch (err) {
    console.error("Get user donations error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get user's products (if products table exists)
app.get("/api/users/:userId/products", async (req, res) => {
  const { userId } = req.params;

  try {
    // Check if products table exists and has creator_id column
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'products'
      );
    `);

    if (!tableCheck.rows[0].exists) {
      return res.json([]);
    }

    const result = await pool.query(`
      SELECT 
        p.*,
        u.name as creator_name,
        u.profile_image_url as creator_avatar
      FROM products p
      JOIN users u ON p.creator_id = u.id
      WHERE p.creator_id = $1
      ORDER BY p.created_at DESC
    `, [userId]);

    res.json(result.rows);
  } catch (err) {
    console.error("Get user products error:", err);
    // Return empty array if products table doesn't exist or has issues
    res.json([]);
  }
});

app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
});