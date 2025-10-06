import dotenv from 'dotenv';
dotenv.config();

import express from "express";
import cors from "cors";
import { Pool } from "pg";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import cloudinary from 'cloudinary';

const app = express();
const port = 3003;

app.use(cors({
  origin: ['http://localhost:3003', 'http://10.0.2.2:3003', 'http://127.0.0.1:3003', 'http://localhost:3000'],
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

// Configure Cloudinary
cloudinary.v2.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
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

     console.log(`✅ Found ${result.rows.length} materials`);

      // Convert database results to frontend format
    const materials = result.rows.map(material => {
      // Get images from image_data_base64 (our working column)
      const imageUrls = material.image_data_base64 || [];
      
      if (imageUrls.length > 0) {
        console.log(`📸 Material ${material.id} has ${imageUrls.length} images`);
      } else {
        console.log(`⚠️ Material ${material.id} has no images`);
      }
    
    const materialData = {
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
        image_urls: imageUrls, // Always use image_data_base64 content
        uploader: material.uploader_name,
        amount: material.quantity,
        created_at: material.created_at,
        time: formatTimeAgo(material.created_at)
      };

      return materialData;
    });

    res.json(materials);
  } catch (err) {
    console.error("Get materials error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Create new material/donation with base64 images
app.post("/materials", async (req, res) => {
  console.log('📝 Received material creation request');
const { 
    title, description, category, quantity, location, delivery_option, 
    available_from, available_until, is_fragile, contact_preferences,
    image_urls, uploader_id 
  } = req.body;
 
  try {
    // Basic validation
    if (!title || !description || !category || !uploader_id) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    console.log('🔍 Image URLs received:', image_urls);
    console.log('🔍 Contact preferences received:', contact_preferences, 'type:', typeof contact_preferences);

    // Handle image_urls - ensure it's a proper array
    let imageUrls = [];
    if (image_urls && Array.isArray(image_urls)) {
      imageUrls = image_urls;
    }

    console.log('✅ Final image URLs:', imageUrls);

     let contactPrefs = {};
    if (contact_preferences) {
      if (typeof contact_preferences === 'string') {
        try {
          contactPrefs = JSON.parse(contact_preferences);
          console.log('✅ Parsed contact_preferences from string to object');
        } catch (e) {
          console.log('❌ Failed to parse contact_preferences string, using empty object');
          contactPrefs = {};
        }
      } else if (typeof contact_preferences === 'object') {
        contactPrefs = contact_preferences;
      }
    }
    console.log('✅ Final contact_preferences:', contactPrefs);

   const result = await pool.query(
      `INSERT INTO materials 
       (title, description, category, quantity, location, delivery_option, 
        available_from, available_until, is_fragile, contact_preferences, 
        image_data_base64, uploader_id) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
       RETURNING *`,
      [
        title, description, category, quantity || 'Not specified', location, 
        delivery_option || 'Needs Pickup', available_from || new Date().toISOString(),
        available_until || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        is_fragile || false, 
        contactPrefs, 
        imageUrls, 
        uploader_id
      ]
    );

    console.log('✅ Material created successfully with ID:', result.rows[0].id);

    await pool.query(
  "UPDATE users SET available_gems = available_gems + 5 WHERE id = $1",
  [uploader_id]
);
await pool.query(
  "INSERT INTO gem_transactions (user_id, amount, type, description) VALUES ($1, $2, 'earn', $3)",
  [uploader_id, 5, `Earned for donating material: ${title}`]
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

     /// Format response - use image_data_base64 for the response
    const formattedMaterial = {
      ...material,
      image_urls: material.image_data_base64 || [], // Map to image_urls for frontend
      uploader: material.uploader_name,
      amount: material.quantity,
      time: formatTimeAgo(material.created_at)
    };

    console.log('✅ Sending response with image_urls:', formattedMaterial.image_urls);
    res.status(201).json(formattedMaterial);
  } catch (err) {
    console.error("❌ Create material error:", err);
    console.error("❌ Error details:", err.stack);
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
        donation_count::integer, created_at, user_type,
        available_gems::integer
      FROM users 
      WHERE user_type IN ('artisan', 'both')
      ORDER BY donation_count::integer DESC, created_at DESC
      LIMIT 10
    `);
    
    console.log(`✅ Found ${result.rows.length} artisans`);
    
    // Ensure all artisans have profile pictures
    const artisansWithImages = result.rows.map(artisan => ({
      ...artisan,
      profile_image_url: artisan.profile_image_url || 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200&h=200&fit=crop&crop=face'
    }));
    
    res.json(artisansWithImages);
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
        u.available_gems::integer,
        COUNT(m.id)::integer as material_count,
        COALESCE(STRING_AGG(DISTINCT m.category, ', '), 'Various') as top_categories
      FROM users u
      LEFT JOIN materials m ON u.id = m.uploader_id
      WHERE u.user_type IN ('contributor', 'both') OR m.id IS NOT NULL
      GROUP BY u.id, u.name, u.username, u.profile_image_url, 
               u.specialty, u.bio, u.donation_count, u.created_at, u.user_type, u.available_gems
      ORDER BY u.donation_count::integer DESC, material_count DESC
      LIMIT 10
    `);
    
    console.log(`✅ Found ${result.rows.length} contributors`);
    
    // Ensure all contributors have profile pictures
    const contributorsWithImages = result.rows.map(contributor => ({
      ...contributor,
      profile_image_url: contributor.profile_image_url || 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face'
    }));
    
    res.json(contributorsWithImages);
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

// Upload profile picture to Cloudinary
app.post("/api/users/:id/profile-picture", authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { image_data_base64 } = req.body;

  try {
    if (!image_data_base64) {
      return res.status(400).json({ error: "No image data provided" });
    }

    console.log('📸 Uploading profile picture to Cloudinary for user:', id);

    // Upload to Cloudinary
    const uploadResult = await cloudinary.uploader.upload(image_data_base64, {
      folder: 'junk_and_gems/profile_pictures',
      resource_type: 'image',
      width: 200,
      height: 200,
      crop: 'fill',
      gravity: 'face'
    });

    console.log('✅ Cloudinary upload result:', uploadResult.secure_url);

    // Update user's profile picture URL
    await pool.query(
      "UPDATE users SET profile_image_url = $1 WHERE id = $2",
      [uploadResult.secure_url, id]
    );

    res.json({
      success: true,
      profile_image_url: uploadResult.secure_url,
      message: "Profile picture updated successfully"
    });

  } catch (error) {
    console.error("Profile picture upload error:", error);
    res.status(500).json({ error: "Profile picture upload failed: " + error.message });
  }
});

// Add sample profile pictures to users without them
app.post("/api/fix-user-profile-pictures", async (req, res) => {
  try {
    const users = await pool.query(`
      SELECT id, name, user_type 
      FROM users 
      WHERE profile_image_url IS NULL OR profile_image_url = ''
    `);
    
    console.log(`📝 Found ${users.rows.length} users without profile pictures`);
    
    const sampleAvatars = {
      'artisan': [
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200&h=200&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=200&h=200&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=200&h=200&fit=crop&crop=face'
      ],
      'contributor': [
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop&crop=face'
      ],
      'both': [
        'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200&h=200&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face'
      ]
    };
    
    for (const user of users.rows) {
      const userType = user.user_type?.toLowerCase() || 'contributor';
      const avatars = sampleAvatars[userType] || sampleAvatars.contributor;
      const randomAvatar = avatars[Math.floor(Math.random() * avatars.length)];
      
      await pool.query(
        'UPDATE users SET profile_image_url = $1 WHERE id = $2',
        [randomAvatar, user.id]
      );
      
      console.log(`✅ Added profile picture to user ${user.id} (${user.name})`);
    }
    
    res.json({
      success: true,
      message: `Added profile pictures to ${users.rows.length} users`
    });
    
  } catch (err) {
    console.error("Fix profile pictures error:", err);
    res.status(500).json({ error: "Fix failed: " + err.message });
  }
});

// --- CHAT ENDPOINTS ---
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
    
    res.json(result.rows);
  } catch (err) {
    console.error("❌ Get conversations error:", err);
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: "Check server logs for more information"
    });
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

// Setup products table
app.post("/api/setup-products-table", async (req, res) => {
  try {
    console.log('Creating products table...');

    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        category VARCHAR(100),
        condition VARCHAR(50),
        materials_used TEXT,
        dimensions VARCHAR(100),
        location VARCHAR(255),
        image_url VARCHAR(500),
        artisan_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✓ Created products table');

    // Create index for better performance
    try {
      await pool.query(`CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at DESC)`);
      console.log('✓ Created index on created_at');
    } catch (indexErr) {
      console.log('Index creation for created_at failed:', indexErr.message);
    }

    res.json({ 
      success: true, 
      message: "Products table setup completed successfully" 
    });
  } catch (err) {
    console.error("Setup products table error:", err);
    res.status(500).json({ error: "Setup failed: " + err.message });
  }
});

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

// Create new product listing
app.post("/api/products", async (req, res) => {
  console.log('📝 Received product creation request');
  console.log('Request body:', JSON.stringify(req.body, null, 2));
  
  const { 
    title, 
    description, 
    price, 
    category, 
    condition, 
    materials_used, 
    dimensions, 
    location,
    artisan_id,
    image_data_base64
  } = req.body;

  try {
    // Basic validation
    if (!title || !description || !price || !artisan_id) {
      return res.status(400).json({ 
        error: "Missing required fields: title, description, price, and artisan_id are required" 
      });
    }

    console.log('✅ Validating product data:', {
      title,
      price,
      category,
      condition,
      artisan_id
    });

    // Insert the new product
    const result = await pool.query(
      `INSERT INTO products 
       (title, description, price, category, condition, materials_used, dimensions, location, artisan_id, image_data_base64) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) 
       RETURNING *`,
      [
        title,
        description,
        price,
        category,
        condition || null,
        materials_used || null,
        dimensions || null,
        location || null,
        artisan_id,
        image_data_base64 || []
      ]
    );

    const product = result.rows[0];
    console.log('✅ Product created successfully with ID:', product.id);

    // Get the created product with creator info
    const productWithCreator = await pool.query(`
      SELECT 
        p.*,
        u.name as creator_name,
        u.profile_image_url as creator_avatar
      FROM products p
      JOIN users u ON p.artisan_id = u.id
      WHERE p.id = $1
    `, [product.id]);

    const fullProduct = productWithCreator.rows[0];

    console.log('✅ Sending response for product:', fullProduct.id);
    res.status(201).json(fullProduct);

  } catch (err) {
    console.error("❌ Create product error:", err);
    console.error("❌ Error details:", err.stack);
    
    // Check if it's a foreign key constraint error (creator doesn't exist)
    if (err.code === '23503') {
      return res.status(400).json({ error: "Invalid creator: User does not exist" });
    }
    
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Get user's profile
app.get("/api/users/:userId/profile", async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT 
        id, name, username, profile_image_url, 
        user_type, specialty, bio, donation_count,
        available_gems, created_at
      FROM users 
      WHERE id = $1
    `, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = result.rows[0];
    
    // Get user stats from materials table
    const donationsCount = await pool.query(
      'SELECT COUNT(*) FROM materials WHERE uploader_id = $1',
      [userId]
    );
    
    // Get products count (if products table exists with artisan_id)
    let productsCount = { rows: [{ count: '0' }] };
    try {
      productsCount = await pool.query(
        'SELECT COUNT(*) FROM products WHERE artisan_id = $1',
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

// Get user's products
app.get("/api/users/:userId/products", async (req, res) => {
  const { userId } = req.params;

  try {
    // Check if products table exists and has artisan_id column
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
      JOIN users u ON p.artisan_id = u.id
      WHERE p.artisan_id = $1
      ORDER BY p.created_at DESC
    `, [userId]);

    res.json(result.rows);
  } catch (err) {
    console.error("Get user products error:", err);
    // Return empty array if products table doesn't exist or has issues
    res.json([]);
  }
});

// Get user's impact
app.get("/api/users/:userId/impact", async (req, res) => {
  const { userId } = req.params;

  try {
    const userResult = await pool.query(`
      SELECT 
        donation_count,
        available_gems
      FROM users 
      WHERE id = $1
    `, [userId]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userResult.rows[0];
    const upcycledItems = Math.floor(user.donation_count * 0.1);

    res.json({
      pieces_donated: user.donation_count,
      upcycled_items: upcycledItems,
      gems_earned: user.available_gems
    });
  } catch (err) {
    console.error("Get user impact error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Upload image to Cloudinary
app.post("/api/upload-image", async (req, res) => {
  const { image_data_base64 } = req.body;

  try {
    if (!image_data_base64) {
      return res.status(400).json({ error: "No image data provided" });
    }

    // Upload to Cloudinary
    const uploadResult = await cloudinary.uploader.upload(image_data_base64, {
      folder: 'junk_and_gems/materials',
      resource_type: 'image'
    });

    res.json({
      success: true,
      image_url: uploadResult.secure_url,
      public_id: uploadResult.public_id
    });
  } catch (error) {
    console.error("Cloudinary upload error:", error);
    res.status(500).json({ error: "Image upload failed" });
  }
});

// Quick fix for empty materials images
app.post("/api/quick-fix-empty-materials", async (req, res) => {
  try {
    // Get materials with no images
    const materials = await pool.query(`
      SELECT id, title, category 
      FROM materials 
      WHERE image_data_base64 IS NULL OR array_length(image_data_base64, 1) = 0
    `);
    
    console.log(`📝 Found ${materials.rows.length} materials without images`);
    
    const sampleImages = {
      'plastic': ['https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&h=300&fit=crop'],
      'fabric': ['https://images.unsplash.com/photo-1520006403909-838d6b92c22e?w=400&h=300&fit=crop'],
      'glass': ['https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&h=300&fit=crop'],
      'wood': ['https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop'],
      'metal': ['https://images.unsplash.com/photo-1565373679108-41aac54c36a8?w=400&h=300&fit=crop'],
      'electronics': ['https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400&h=300&fit=crop'],
      'ceramics': ['https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop'],
      'computer': ['https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400&h=300&fit=crop']
    };
    
    for (const material of materials.rows) {
      const category = material.category?.toLowerCase() || 'general';
      const categoryKey = Object.keys(sampleImages).find(key => category.includes(key)) || 'general';
      const imageUrl = sampleImages[categoryKey] || ['https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop'];
      
      await pool.query(
        'UPDATE materials SET image_data_base64 = $1 WHERE id = $2',
        [imageUrl, material.id]
      );
      
      console.log(`✅ Added sample image to material ${material.id} (${material.category})`);
    }
    
    res.json({
      success: true,
      message: `Added sample images to ${materials.rows.length} materials`
    });
    
  } catch (err) {
    console.error("Quick fix error:", err);
    res.status(500).json({ error: "Quick fix failed: " + err.message });
  }
});

app.post("/api/reset-products-table", async (req, res) => {
  try {
    console.log('🔄 Resetting products table...');

    // Drop the table if it exists
    await pool.query('DROP TABLE IF EXISTS products');
    console.log('✓ Dropped products table');

    // Create the table with correct schema
    await pool.query(`
      CREATE TABLE products (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        category VARCHAR(100),
        condition VARCHAR(50),
        materials_used TEXT,
        dimensions VARCHAR(100),
        location VARCHAR(255),
        image_url VARCHAR(500),
        artisan_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✓ Created products table with correct schema');

    // Create index
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at DESC)`);
    console.log('✓ Created index on created_at');

    res.json({ 
      success: true, 
      message: "Products table reset and created successfully" 
    });
  } catch (err) {
    console.error("Reset products table error:", err);
    res.status(500).json({ error: "Reset failed: " + err.message });
  }
});

app.post("/api/fix-products-table", async (req, res) => {
  try {
    console.log('🔧 Fixing products table...');

    // Check if category column exists
    const checkResult = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products' AND column_name = 'category'
    `);

    if (checkResult.rows.length === 0) {
      // Add the missing category column
      await pool.query('ALTER TABLE products ADD COLUMN category VARCHAR(100)');
      console.log('✓ Added category column');
    } else {
      console.log('✓ Category column already exists');
    }

    // Similarly check and add other missing columns
    const columnsToCheck = ['condition', 'materials_used', 'dimensions', 'location', 'artisan_id'];
    
    for (const column of columnsToCheck) {
      const columnCheck = await pool.query(`
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = $1
      `, [column]);

      if (columnCheck.rows.length === 0) {
        let columnType = 'VARCHAR(255)';
        if (column === 'condition') columnType = 'VARCHAR(50)';
        if (column === 'materials_used') columnType = 'TEXT';
        if (column === 'dimensions') columnType = 'VARCHAR(100)';
        if (column === 'artisan_id') columnType = 'INTEGER REFERENCES users(id) ON DELETE CASCADE';
        
        await pool.query(`ALTER TABLE products ADD COLUMN ${column} ${columnType}`);
        console.log(`✓ Added ${column} column`);
      } else {
        console.log(`✓ ${column} column already exists`);
      }
    }

    res.json({ 
      success: true, 
      message: "Products table fixed successfully" 
    });
  } catch (err) {
    console.error("Fix products table error:", err);
    res.status(500).json({ error: "Fix failed: " + err.message });
  }
});

app.get("/api/debug/products-schema", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        column_name, 
        data_type, 
        is_nullable,
        column_default
      FROM information_schema.columns 
      WHERE table_name = 'products' 
      ORDER BY ordinal_position;
    `);
    
    res.json({
      table: 'products',
      columns: result.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/debug/products-dependencies", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        tc.table_schema, 
        tc.table_name, 
        tc.constraint_name,
        tc.constraint_type,
        kcu.column_name,
        ccu.table_schema AS foreign_table_schema,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM information_schema.table_constraints AS tc 
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      WHERE ccu.table_name = 'products' OR tc.table_name = 'products'
    `);
    
    res.json({
      dependencies: result.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- ORDERS & GEM SYSTEM ---
app.post("/api/orders", authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { totalAmount, appliedGems = 0, shippingAddress, paymentMethod } = req.body;

  try {
    // Basic validation
    if (!totalAmount || totalAmount <= 0) {
      return res.status(400).json({ error: "Invalid total amount" });
    }

    // Fetch user's gem balance
    const userResult = await pool.query(
      "SELECT available_gems FROM users WHERE id = $1",
      [userId]
    );

    const availableGems = parseInt(userResult.rows[0].available_gems || 0);
    const actualAppliedGems = Math.min(appliedGems, availableGems);

    // Calculate final amount
    const gemValue = 1; // 1 gem = 1 LSL
    const finalAmount = Math.max(0, totalAmount - actualAppliedGems * gemValue);

    // Create new order
    const orderResult = await pool.query(
      `INSERT INTO orders (user_id, total_amount, applied_gems, final_amount, shipping_address, payment_method, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'completed') RETURNING *`,
      [userId, totalAmount, actualAppliedGems, finalAmount, shippingAddress, paymentMethod]
    );

    // Update gems & transactions
    if (actualAppliedGems > 0) {
      await pool.query(
        "UPDATE users SET available_gems = available_gems - $1 WHERE id = $2",
        [actualAppliedGems, userId]
      );
      await pool.query(
        "INSERT INTO gem_transactions (user_id, amount, type, description) VALUES ($1, $2, 'spend', $3)",
        [userId, -actualAppliedGems, "Used gems for discount on order"]
      );
    }

    // Reward small gem bonus for completing an order
    await pool.query(
      "UPDATE users SET available_gems = available_gems + 2 WHERE id = $1",
      [userId]
    );
    await pool.query(
      "INSERT INTO gem_transactions (user_id, amount, type, description) VALUES ($1, $2, 'earn', 'Bonus for completing an order')",
      [userId, 2]
    );

    res.status(201).json({
      success: true,
      message: "Order created successfully",
      order: orderResult.rows[0],
      applied_gems: actualAppliedGems,
      final_amount: finalAmount,
    });
  } catch (err) {
    console.error("Create order error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Fetch user's gem balance and history
app.get("/api/users/:userId/gems", authenticateToken, async (req, res) => {
  const { userId } = req.params;
  try {
    const gems = await pool.query(
      "SELECT available_gems FROM users WHERE id = $1",
      [userId]
    );
    const history = await pool.query(
      "SELECT * FROM gem_transactions WHERE user_id = $1 ORDER BY created_at DESC",
      [userId]
    );
    res.json({
      available_gems: gems.rows[0].available_gems,
      transactions: history.rows,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/orders/:userId", authenticateToken, async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await pool.query(
      "SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC",
      [userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Get user orders error:", err);
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