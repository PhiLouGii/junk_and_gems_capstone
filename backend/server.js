import dotenv from 'dotenv';
dotenv.config();

import express from "express";
import cors from "cors";
import { Pool } from "pg";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { v2 as cloudinary } from 'cloudinary';
import multer from 'multer';
import sgMail from '@sendgrid/mail';

const app = express();
const port = process.env.PORT || 3003;

// Configure SendGrid
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Email sending helper function
async function sendEmail({ to, subject, text, html }) {
  try {
    const msg = {
      to,
      from: {
        email: process.env.SENDGRID_FROM_EMAIL,
        name: process.env.SENDGRID_FROM_NAME || 'Junk & Gems CEO'
      },
      subject,
      text,
      html: html || text
    };

    await sgMail.send(msg);
    console.log(`✅ Email sent to ${to}: ${subject}`);
    return { success: true };
  } catch (error) {
    console.error('❌ SendGrid error:', error);
    if (error.response) {
      console.error('Error details:', error.response.body);
    }
    return { success: false, error: error.message };
  }
}

// Welcome email template
function getWelcomeEmailHtml(name) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          background-color: #88844D;
          color: white;
          padding: 30px;
          text-align: center;
          border-radius: 10px 10px 0 0;
        }
        .content {
          background-color: #F7F2E4;
          padding: 30px;
          border-radius: 0 0 10px 10px;
        }
        .button {
          display: inline-block;
          padding: 12px 30px;
          background-color: #88844D;
          color: white;
          text-decoration: none;
          border-radius: 5px;
          margin: 20px 0;
        }
        .footer {
          text-align: center;
          margin-top: 30px;
          color: #666;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Welcome to Junk & Gems! 🎉</h1>
      </div>
      <div class="content">
        <h2>Hi ${name}!</h2>
        <p>Thank you for joining our community of eco-conscious creators and contributors.</p>
        <p><strong>What you can do now:</strong></p>
        <ul>
          <li>🎁 Donate materials you no longer need</li>
          <li>🔍 Browse available materials for your projects</li>
          <li>💎 Earn gems for your contributions</li>
          <li>🛍️ Shop unique upcycled products from artisans</li>
          <li>💬 Connect with other community members</li>
        </ul>
        <p><strong>Welcome bonus:</strong> You've received 5 gems to get started!</p>
        <p>Start exploring and making a difference today!</p>
        <div class="footer">
          <p>Junk & Gems - Turning waste into wonder</p>
          <p>If you have any questions, feel free to reach out to our support team.</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

// Password reset email template
function getPasswordResetEmailHtml(name, resetToken) {
  const resetUrl = `https://junk-and-gems-api.onrender.com/reset-password?token=${resetToken}`;
  
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          background-color: #88844D;
          color: white;
          padding: 30px;
          text-align: center;
          border-radius: 10px 10px 0 0;
        }
        .content {
          background-color: #F7F2E4;
          padding: 30px;
          border-radius: 0 0 10px 10px;
        }
        .button {
          display: inline-block;
          padding: 12px 30px;
          background-color: #88844D;
          color: white;
          text-decoration: none;
          border-radius: 5px;
          margin: 20px 0;
        }
        .warning {
          background-color: #fff3cd;
          border-left: 4px solid #ffc107;
          padding: 15px;
          margin: 20px 0;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Password Reset Request 🔒</h1>
      </div>
      <div class="content">
        <h2>Hi ${name},</h2>
        <p>We received a request to reset your password for your Junk & Gems account.</p>
        <p>Your password reset code is:</p>
        <h1 style="text-align: center; color: #88844D; letter-spacing: 5px;">${resetToken}</h1>
        <p>Enter this code in the app to reset your password. This code will expire in 1 hour.</p>
        <div class="warning">
          <strong>Security Notice:</strong> If you didn't request this password reset, please ignore this email. Your password will remain unchanged.
        </div>
      </div>
    </body>
    </html>
  `;
}

// Material donation confirmation email
function getDonationConfirmationEmailHtml(name, materialTitle, gemsEarned) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          background-color: #88844D;
          color: white;
          padding: 30px;
          text-align: center;
          border-radius: 10px 10px 0 0;
        }
        .content {
          background-color: #F7F2E4;
          padding: 30px;
          border-radius: 0 0 10px 10px;
        }
        .gems-badge {
          background-color: #88844D;
          color: white;
          padding: 10px 20px;
          border-radius: 50px;
          display: inline-block;
          margin: 20px 0;
          font-size: 18px;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Donation Posted Successfully! 🎉</h1>
      </div>
      <div class="content">
        <h2>Hi ${name}!</h2>
        <p>Great news! Your donation has been posted successfully.</p>
        <p><strong>Material:</strong> ${materialTitle}</p>
        <div class="gems-badge">💎 +${gemsEarned} Gems Earned!</div>
        <p>Your material is now visible to the community. Artisans and creators can browse and claim it for their projects.</p>
        <p><strong>What happens next?</strong></p>
        <ul>
          <li>Community members can view your donation</li>
          <li>Interested users can message you to arrange pickup</li>
          <li>You'll be notified when someone claims your item</li>
        </ul>
        <p>Thank you for contributing to a more sustainable future! 🌍</p>
      </div>
    </body>
    </html>
  `;
}

app.use(cors({
  origin: '*', // Allow all origins for mobile app
  credentials: true,
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || "postgresql://postgres:philippa@localhost:5433/junk_and_gems",
  ssl: process.env.DATABASE_URL ? {
    rejectUnauthorized: false
  } : false
});

// Test the connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error connecting to database:', err.stack);
  } else {
    console.log('Database connected successfully');
    release();
  }
});

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_NAME,
  api_key: process.env.CLOUDINARY_KEY,
  api_secret: process.env.CLOUDINARY_SECRET,
});

// Set up multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({ storage });

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
    
    const existingUser = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: "User already exists with this email" });
    }
    
    const username = email.split('@')[0];
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const result = await pool.query(
      "INSERT INTO users (name, email, password, username) VALUES ($1, $2, $3, $4) RETURNING *",
      [name, email, hashedPassword, username]
    );
    
    const user = result.rows[0];
    const token = jwt.sign({ id: user.id }, "your_jwt_secret", { expiresIn: "1h" });
    
    //NOTIFY ALL USERS BEFORE SENDING RESPONSE
    console.log(`Notifying all users about new member: ${user.name} (ID: ${user.id})`);
    await notifyAllUsersAboutNewUser(user.id, user.name);
    
    // Send welcome email (don't await - let it send in background)
    sendEmail({
      to: email,
      subject: 'Welcome to Junk & Gems! 🎉',
      text: `Hi ${name}! Welcome to Junk & Gems. Thank you for joining our community of eco-conscious creators.`,
      html: getWelcomeEmailHtml(name)
    }).catch(err => console.error('Failed to send welcome email:', err));
    
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

// --- NEW PASSWORD RESET REQUEST ENDPOINT ---
app.post("/request-password-reset", async (req, res) => {
  const { email } = req.body;
  
  try {
    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    
    if (result.rows.length === 0) {
      // Don't reveal if email exists for security
      return res.json({ 
        message: "If that email exists, a reset code has been sent" 
      });
    }

    const user = result.rows[0];
    
    // Generate 6-digit reset code
    const resetToken = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 3600000); // 1 hour

    // Store reset token in database
    await pool.query(
      "UPDATE users SET reset_token = $1, reset_token_expires = $2 WHERE id = $3",
      [resetToken, expiresAt, user.id]
    );

    // Send reset email
    await sendEmail({
      to: email,
      subject: 'Password Reset Code - Junk & Gems',
      text: `Hi ${user.name}, Your password reset code is: ${resetToken}. This code expires in 1 hour.`,
      html: getPasswordResetEmailHtml(user.name, resetToken)
    });

    res.json({ 
      message: "If that email exists, a reset code has been sent" 
    });
    
  } catch (err) {
    console.error("Password reset request error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// --- VERIFY RESET CODE ENDPOINT ---
app.post("/verify-reset-code", async (req, res) => {
  const { email, code } = req.body;
  
  try {
    if (!email || !code) {
      return res.status(400).json({ error: "Email and code are required" });
    }

    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1 AND reset_token = $2 AND reset_token_expires > NOW()",
      [email, code]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: "Invalid or expired reset code" });
    }

    res.json({ 
      message: "Code verified successfully",
      userId: result.rows[0].id 
    });
    
  } catch (err) {
    console.error("Verify reset code error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// --- RESET PASSWORD ENDPOINT ---
app.post("/reset-password", async (req, res) => {
  const { email, code, newPassword } = req.body;
  
  try {
    if (!email || !code || !newPassword) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1 AND reset_token = $2 AND reset_token_expires > NOW()",
      [email, code]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: "Invalid or expired reset code" });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await pool.query(
      "UPDATE users SET password = $1, reset_token = NULL, reset_token_expires = NULL WHERE id = $2",
      [hashedPassword, result.rows[0].id]
    );

    res.json({ message: "Password reset successfully" });
    
  } catch (err) {
    console.error("Reset password error:", err);
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

// Daily login reward endpoint
app.post("/api/daily-login-reward", authenticateToken, async (req, res) => {
  const userId = req.user.id;

  try {
    // Check if user already claimed reward today
    const today = new Date().toISOString().split('T')[0];
    
    const existingClaim = await pool.query(
      "SELECT * FROM daily_login_rewards WHERE user_id = $1 AND claim_date = $2",
      [userId, today]
    );

    if (existingClaim.rows.length > 0) {
      return res.json({
        success: false,
        message: "Daily reward already claimed today",
        gems_earned: 0,
        streak: existingClaim.rows[0].current_streak
      });
    }

    // Get user's current streak
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];

    const lastClaim = await pool.query(
      "SELECT * FROM daily_login_rewards WHERE user_id = $1 ORDER BY claim_date DESC LIMIT 1",
      [userId]
    );

    let currentStreak = 1;
    if (lastClaim.rows.length > 0) {
      const lastClaimDate = new Date(lastClaim.rows[0].claim_date).toISOString().split('T')[0];
      if (lastClaimDate === yesterdayStr) {
        currentStreak = lastClaim.rows[0].current_streak + 1;
      }
    }

    // Calculate gems based on streak (5 gems base + bonus for streaks)
    const baseGems = 5;
    const streakBonus = Math.min(Math.floor(currentStreak / 7) * 2, 10); // +2 gems per week, max +10
    const totalGems = baseGems + streakBonus;

    // Start transaction
    await pool.query('BEGIN');

    // Add gems to user
    await pool.query(
      "UPDATE users SET available_gems = available_gems + $1 WHERE id = $2",
      [totalGems, userId]
    );

    // Record gem transaction
    await pool.query(
      "INSERT INTO gem_transactions (user_id, amount, type, description) VALUES ($1, $2, 'earn', $3)",
      [userId, totalGems, `Daily login reward (${currentStreak} day streak)`]
    );

    // Record daily login
    await pool.query(
      "INSERT INTO daily_login_rewards (user_id, gems_earned, current_streak, claim_date) VALUES ($1, $2, $3, $4)",
      [userId, totalGems, currentStreak, today]
    );

    await pool.query('COMMIT');

    res.json({
      success: true,
      gems_earned: totalGems,
      streak: currentStreak,
      streak_bonus: streakBonus,
      message: `You earned ${totalGems} gems today!`
    });

  } catch (err) {
    await pool.query('ROLLBACK');
    console.error("Daily login reward error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Create daily_login_rewards table setup endpoint
app.post("/api/setup-daily-rewards-table", async (req, res) => {
  try {
    console.log('Creating daily_login_rewards table...');

    await pool.query(`
      CREATE TABLE IF NOT EXISTS daily_login_rewards (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        gems_earned INTEGER NOT NULL,
        current_streak INTEGER NOT NULL,
        claim_date DATE NOT NULL,
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, claim_date)
      )
    `);
    console.log('✓ Created daily_login_rewards table');

    // Create index for better performance
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_daily_rewards_user_date ON daily_login_rewards(user_id, claim_date DESC)`);
    console.log('✓ Created index on daily_login_rewards');

    res.json({ 
      success: true, 
      message: "Daily rewards table setup completed successfully" 
    });
  } catch (err) {
    console.error("Setup daily rewards table error:", err);
    res.status(500).json({ error: "Setup failed: " + err.message });
  }
});

async function notifyAllUsersAboutNewUser(newUserId, newUserName) {
  try {
    console.log(`Creating notifications for new user: ${newUserName} (ID: ${newUserId})`);
    
    // Get all user IDs except the new user
    const usersResult = await pool.query(
      'SELECT id FROM users WHERE id != $1 AND id IS NOT NULL',
      [newUserId]
    );

    if (usersResult.rows.length === 0) {
      console.log('ℹ️ No existing users to notify');
      return;
    }

    console.log(`Found ${usersResult.rows.length} users to notify`);

    // Create notification for each user - FIXED: No extra space in title
    const notificationValues = usersResult.rows.map(user => 
      `(${user.id}, 'new_user', 'New Member! 🎉', 'Say hello to ${newUserName} who just joined Junk & Gems!', ${newUserId}, FALSE, NOW(), NOW() + INTERVAL '7 days')`
    ).join(',');

    const insertQuery = `
      INSERT INTO user_notifications 
        (user_id, notification_type, title, message, related_user_id, is_read, created_at, expires_at)
      VALUES ${notificationValues}
      RETURNING id
    `;

    console.log('Executing insert query...');
    const result = await pool.query(insertQuery);

    console.log(`Created ${result.rows.length} notifications for new user: ${newUserName}`);
    return result.rows.length;
    
  } catch (error) {
    console.error('Error creating new user notifications:', error);
    console.error('Error details:', error.message);
    console.error('Error code:', error.code);
    // Don't throw - we don't want to break signup if notifications fail
    return 0;
  }
}

// Helper function to format notification time
function formatNotificationTime(timestamp) {
  if (!timestamp) return 'Just now';
  
  try {
    const now = new Date();
    const notifTime = new Date(timestamp);
    const diffMs = now - notifTime;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    
    return notifTime.toLocaleDateString();
  } catch (e) {
    return 'Recently';
  }
}


// Get notifications for a specific user
app.get('/api/users/:userId/notifications', async (req, res) => {
  try {
    const { userId } = req.params;
    const { unread_only, limit = 50 } = req.query;

    let query = `
      SELECT 
        n.id,
        n.notification_type,
        n.title,
        n.message,
        n.is_read,
        n.created_at,
        n.related_user_id,
        u.name as related_user_name,
        u.profile_image_url as related_user_image
      FROM user_notifications n
      LEFT JOIN users u ON n.related_user_id = u.id
      WHERE n.user_id = $1 
        AND (n.expires_at IS NULL OR n.expires_at > NOW())
    `;

    const queryParams = [userId];

    if (unread_only === 'true') {
      query += ' AND n.is_read = FALSE';
    }

    query += ' ORDER BY n.created_at DESC LIMIT $2';
    queryParams.push(limit);

    const result = await pool.query(query, queryParams);

    // Format the response
    const notifications = result.rows.map(notif => ({
      id: notif.id,
      type: notif.notification_type,
      title: notif.title,
      message: notif.message,
      isRead: notif.is_read,
      createdAt: notif.created_at,
      relatedUserId: notif.related_user_id,
      relatedUserName: notif.related_user_name,
      relatedUserImage: notif.related_user_image,
      time: formatNotificationTime(notif.created_at)
    }));

    res.json({
      success: true,
      notifications,
      unreadCount: notifications.filter(n => !n.isRead).length
    });

  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to fetch notifications' 
    });
  }
});

// Mark notification(s) as read
app.put('/api/users/:userId/notifications/read', async (req, res) => {
  try {
    const { userId } = req.params;
    const { notificationIds, markAll } = req.body;

    let query;
    let queryParams;

    if (markAll) {
      query = `
        UPDATE user_notifications 
        SET is_read = TRUE 
        WHERE user_id = $1 AND is_read = FALSE
        RETURNING id
      `;
      queryParams = [userId];
    } else if (notificationIds && notificationIds.length > 0) {
      query = `
        UPDATE user_notifications 
        SET is_read = TRUE 
        WHERE user_id = $1 AND id = ANY($2)
        RETURNING id
      `;
      queryParams = [userId, notificationIds];
    } else {
      return res.status(400).json({ 
        success: false, 
        error: 'Provide notificationIds or set markAll to true' 
      });
    }

    const result = await pool.query(query, queryParams);

    res.json({
      success: true,
      message: `Marked ${result.rows.length} notification(s) as read`,
      updatedCount: result.rows.length
    });

  } catch (error) {
    console.error('Error marking notifications as read:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to mark notifications as read' 
    });
  }
});

// Delete old/expired notifications (cleanup endpoint)
app.delete('/api/notifications/cleanup', async (req, res) => {
  try {
    const result = await pool.query(`
      DELETE FROM user_notifications 
      WHERE expires_at < NOW() OR created_at < NOW() - INTERVAL '30 days'
      RETURNING id
    `);

    res.json({
      success: true,
      message: `Deleted ${result.rows.length} expired notifications`,
      deletedCount: result.rows.length
    });

  } catch (error) {
    console.error('Error cleaning up notifications:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to cleanup notifications' 
    });
  }
});

// Get unread notification count
app.get('/api/users/:userId/notifications/unread-count', async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await pool.query(`
      SELECT COUNT(*) as count
      FROM user_notifications
      WHERE user_id = $1 
        AND is_read = FALSE
        AND (expires_at IS NULL OR expires_at > NOW())
    `, [userId]);

    res.json({
      success: true,
      unreadCount: parseInt(result.rows[0].count)
    });

  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to fetch unread count' 
    });
  }
});

// Create custom notification (for other events)
app.post('/api/notifications/create', async (req, res) => {
  try {
    const { 
      userIds, 
      notificationType, 
      title, 
      message, 
      relatedUserId,
      expiresInDays = 7 
    } = req.body;

    if (!userIds || !notificationType || !title || !message) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields' 
      });
    }

    const notificationValues = userIds.map(userId => 
      `(${userId}, '${notificationType}', '${title}', '${message}', ${relatedUserId || 'NULL'}, FALSE, NOW(), NOW() + INTERVAL '${expiresInDays} days')`
    ).join(',');

    const result = await pool.query(`
      INSERT INTO user_notifications 
        (user_id, notification_type, title, message, related_user_id, is_read, created_at, expires_at)
      VALUES ${notificationValues}
      RETURNING id
    `);

    res.json({
      success: true,
      message: `Created ${result.rows.length} notifications`,
      createdCount: result.rows.length
    });

  } catch (error) {
    console.error('❌ Error creating notifications:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to create notifications' 
    });
  }
});

console.log('User notification endpoints initialized');

// Get all materials with real data
app.get("/materials", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.name as uploader,
        u.email as uploader_email,
        u.profile_image_url as uploader_avatar,
        u.id as uploader_id
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      ORDER BY m.created_at DESC
    `);

     console.log(`Found ${result.rows.length} materials (including claimed)`);

      // Convert database results to frontend format
    const materials = result.rows.map(material => {
      // Get images from image_data_base64 
      const imageUrls = material.image_data_base64 || [];
      
      if (imageUrls.length > 0) {
        console.log(`Material ${material.id} has ${imageUrls.length} images`);
      } else {
        console.log(`Material ${material.id} has no images`);
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
        uploader_id: material.uploader_id, // IMPORTANT: Include uploader_id
        uploader_email: material.uploader_email,
        uploader_avatar: material.uploader_avatar,
        amount: material.quantity,
        created_at: material.created_at,
        time: formatTimeAgo(material.created_at),
        is_claimed: material.is_claimed || false, 
        claimed_by: material.claimed_by, 
        claimed_at: material.claimed_at
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
  console.log('Received material creation request');
  console.log('Request body:', JSON.stringify(req.body, null, 2));
  
  const { 
    title, description, category, quantity, location, delivery_option, 
    available_from, available_until, is_fragile, contact_preferences,
    image_urls, uploader_id 
  } = req.body;
 
  try {
    // Validate required fields
    if (!title || !description || !category || !uploader_id) {
      console.log('Missing required fields');
      return res.status(400).json({ error: "Missing required fields" });
    }

    console.log(`Validated input - Uploader ID: ${uploader_id}`);

    // IMPORTANT: Verify the user exists and get their actual name
    const userCheck = await pool.query(
      'SELECT id, name, email, profile_image_url FROM users WHERE id = $1',
      [uploader_id]
    );

    if (userCheck.rows.length === 0) {
      console.log(`User with ID ${uploader_id} not found`);
      return res.status(400).json({ error: "Invalid uploader_id - user not found" });
    }

    const uploaderInfo = userCheck.rows[0];
    console.log(`✅ User verified: ${uploaderInfo.name} (${uploaderInfo.email})`);

    // Process images
    let imageUrls = [];
    if (image_urls && Array.isArray(image_urls)) {
      imageUrls = image_urls;
    }

    // Process contact preferences
    let contactPrefs = {};
    if (contact_preferences) {
      if (typeof contact_preferences === 'string') {
        try {
          contactPrefs = JSON.parse(contact_preferences);
        } catch (e) {
          contactPrefs = {};
        }
      } else if (typeof contact_preferences === 'object') {
        contactPrefs = contact_preferences;
      }
    }

    console.log('Inserting material into database...');

    // Insert the material
    const result = await pool.query(
      `INSERT INTO materials 
       (title, description, category, quantity, location, delivery_option, 
        available_from, available_until, is_fragile, contact_preferences, 
        image_data_base64, uploader_id) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
       RETURNING *`,
      [
        title, 
        description, 
        category, 
        quantity || 'Not specified', 
        location, 
        delivery_option || 'Needs Pickup', 
        available_from || new Date().toISOString(),
        available_until || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        is_fragile || false, 
        contactPrefs, 
        imageUrls, 
        uploader_id
      ]
    );

    const insertedMaterial = result.rows[0];
    console.log(`Material inserted with ID: ${insertedMaterial.id}`);

    // Award gems to uploader
    try {
      await pool.query(
        "UPDATE users SET available_gems = available_gems + 5 WHERE id = $1",
        [uploader_id]
      );
      await pool.query(
        "INSERT INTO gem_transactions (user_id, amount, type, description) VALUES ($1, $2, 'earn', $3)",
        [uploader_id, 5, `Earned for donating material: ${title}`]
      );
      console.log(`💎 Awarded 5 gems to user ${uploader_id}`);
    } catch (gemErr) {
      console.log('⚠️ Could not award gems:', gemErr.message);
    }

    // Send confirmation email (background - don't wait)
    sendEmail({
      to: uploaderInfo.email,
      subject: 'Donation Posted Successfully!',
      text: `Hi ${uploaderInfo.name}! Your donation "${title}" has been posted successfully. You earned 5 gems!`,
      html: getDonationConfirmationEmailHtml(uploaderInfo.name, title, 5)
    }).catch(err => console.error('Failed to send donation confirmation email:', err));

    // CRITICAL FIX: Return the material with the ACTUAL user data from the database
    const formattedMaterial = {
      id: insertedMaterial.id,
      title: insertedMaterial.title,
      description: insertedMaterial.description,
      category: insertedMaterial.category,
      quantity: insertedMaterial.quantity,
      location: insertedMaterial.location,
      delivery_option: insertedMaterial.delivery_option,
      available_from: insertedMaterial.available_from,
      available_until: insertedMaterial.available_until,
      is_fragile: insertedMaterial.is_fragile,
      contact_preferences: insertedMaterial.contact_preferences,
      image_urls: insertedMaterial.image_data_base64 || [],
      uploader_id: uploader_id,
      uploader: uploaderInfo.name, // ✅ Use ACTUAL user name from database query
      uploader_name: uploaderInfo.name, // ✅ Also include as uploader_name
      uploader_email: uploaderInfo.email,
      uploader_avatar: uploaderInfo.profile_image_url,
      amount: insertedMaterial.quantity,
      time: formatTimeAgo(insertedMaterial.created_at),
      created_at: insertedMaterial.created_at,
      is_claimed: false,
      claimed_by: null,
      claimed_at: null
    };

    console.log('Sending response with uploader:', uploaderInfo.name);
    console.log('Full response:', JSON.stringify(formattedMaterial, null, 2));

    res.status(201).json(formattedMaterial);
  } catch (err) {
    console.error("Create material error:", err);
    console.error("Stack trace:", err.stack);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Search materials by category or title
app.get("/materials/search", async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query) {
      return res.status(400).json({ error: "Search query required" });
    }

    console.log(`🔍 Searching materials for: "${query}"`);

    const result = await pool.query(`
      SELECT 
        m.*,
        u.name as uploader_name,
        u.email as uploader_email,
        u.profile_image_url as uploader_avatar
      FROM materials m
      JOIN users u ON m.uploader_id = u.id
      WHERE m.is_claimed = false 
        AND (
          LOWER(m.title) LIKE LOWER($1) 
          OR LOWER(m.description) LIKE LOWER($1)
          OR LOWER(m.category) LIKE LOWER($1)
        )
      ORDER BY m.created_at DESC
    `, [`%${query}%`]);

    console.log(`✅ Found ${result.rows.length} materials matching "${query}"`);

    // Convert database results to frontend format
    const materials = result.rows.map(material => {
      const imageUrls = material.image_data_base64 || [];
      
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
        image_urls: imageUrls,
        uploader: material.uploader_name,
        amount: material.quantity,
        created_at: material.created_at,
        time: formatTimeAgo(material.created_at)
      };

      return materialData;
    });

    res.json(materials);
  } catch (err) {
    console.error("Search materials error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Claim a material
app.put("/materials/:id/claim", async (req, res) => {
  const { id } = req.params;
  const { claimed_by } = req.body;

  console.log('🎯 Claim material request:');
  console.log('Material ID:', id);
  console.log('Claimed by user:', claimed_by);

  try {
    // Validate input
    if (!claimed_by) {
      return res.status(400).json({ error: "claimed_by is required" });
    }

    // Check if material exists
    const materialCheck = await pool.query(
      "SELECT * FROM materials WHERE id = $1",
      [id]
    );

    if (materialCheck.rows.length === 0) {
      console.log('❌ Material not found:', id);
      return res.status(404).json({ error: "Material not found" });
    }

    const material = materialCheck.rows[0];
    console.log('✅ Material found:', material.title);

    // Check if already claimed
    if (material.is_claimed) {
      console.log('⚠️ Material already claimed');
      return res.status(400).json({ 
        error: "Material already claimed",
        claimed_by: material.claimed_by 
      });
    }

    // Check if user exists
    const userCheck = await pool.query(
      "SELECT id, name FROM users WHERE id = $1",
      [claimed_by]
    );

    if (userCheck.rows.length === 0) {
      console.log('❌ User not found:', claimed_by);
      return res.status(404).json({ error: "User not found" });
    }

    console.log('✅ User found:', userCheck.rows[0].name);

    // Update material to claimed
    const result = await pool.query(
      `UPDATE materials 
       SET is_claimed = true, claimed_by = $1, claimed_at = NOW() 
       WHERE id = $2 
       RETURNING *`,
      [claimed_by, id]
    );

    console.log('✅ Material claimed successfully');

    // Award gems to claimer (optional - 2 gems for claiming)
    try {
      await pool.query(
        "UPDATE users SET available_gems = available_gems + 2 WHERE id = $1",
        [claimed_by]
      );
      await pool.query(
        "INSERT INTO gem_transactions (user_id, amount, type, description) VALUES ($1, $2, 'earn', $3)",
        [claimed_by, 2, `Claimed material: ${material.title}`]
      );
      console.log('💎 Awarded 2 gems for claiming');
    } catch (gemErr) {
      console.log('⚠️ Could not award gems:', gemErr.message);
    }

    res.json({ 
      success: true, 
      message: "Material claimed successfully",
      material: result.rows[0],
      gems_earned: 2
    });

  } catch (err) {
    console.error("❌ Claim material error:", err);
    res.status(500).json({ 
      error: "Server error: " + err.message 
    });
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
app.get("/api/users/:userId/conversations", authenticateToken, async (req, res) => {
  const { userId } = req.params;
  
  console.log(`📨 Loading conversations for user: ${userId}`);
  
  try {
    // Verify the user exists
    const userCheck = await pool.query('SELECT id, name FROM users WHERE id = $1', [userId]);
    if (userCheck.rows.length === 0) {
      console.log(`❌ User ${userId} not found`);
      return res.status(404).json({ error: "User not found" });
    }

    console.log(`✅ User found: ${userCheck.rows[0].name}`);

    const result = await pool.query(`
      SELECT 
        c.id as conversation_id,
        c.created_at,
        c.updated_at,
        u.id as other_user_id,
        COALESCE(u.name, 'Unknown User') as other_user_name,
        u.profile_image_url,
        COALESCE(last_msg.message_text, 'No messages yet') as last_message,
        last_msg.sent_at as last_message_time,
        COALESCE(
          (SELECT COUNT(*)::text FROM messages m 
           WHERE m.conversation_id = c.id 
           AND m.sender_id != $1 
           AND m.read_at IS NULL),
          '0'
        ) as unread_count
      FROM conversations c
      INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
      INNER JOIN conversation_participants cp_other ON c.id = cp_other.conversation_id 
        AND cp_other.user_id != $1
      INNER JOIN users u ON cp_other.user_id = u.id
      LEFT JOIN LATERAL (
        SELECT message_text, sent_at
        FROM messages 
        WHERE conversation_id = c.id 
        ORDER BY sent_at DESC 
        LIMIT 1
      ) last_msg ON true
      WHERE cp.user_id = $1
      ORDER BY COALESCE(last_msg.sent_at, c.created_at) DESC
    `, [userId]);

    console.log(`✅ Found ${result.rows.length} conversations for user ${userId}`);
    
    if (result.rows.length > 0) {
      console.log(`📋 First conversation:`, JSON.stringify(result.rows[0], null, 2));
    }

    res.json(result.rows);
  } catch (err) {
    console.error("❌ Get conversations error:", err);
    console.error("Error details:", err.stack);
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: err.stack
    });
  }
});

// 2. Get messages for a conversation (MUST come before the dynamic route)
app.get("/api/conversations/:conversationId/messages", authenticateToken, async (req, res) => {
  const { conversationId } = req.params;
  
  console.log('='.repeat(60));
  console.log(`📨 GET MESSAGES REQUEST`);
  console.log(`Conversation ID: ${conversationId}`);
  console.log(`Authenticated User ID: ${req.user.id}`);
  console.log('='.repeat(60));
  
  try {
    // Validate conversationId is a number
    if (isNaN(conversationId)) {
      console.log(`❌ Invalid conversation ID: ${conversationId}`);
      return res.status(400).json({ error: "Invalid conversation ID" });
    }

    // Step 1: Check if conversation exists
    console.log(`Step 1: Checking if conversation ${conversationId} exists...`);
    const convCheck = await pool.query(
      'SELECT id FROM conversations WHERE id = $1',
      [conversationId]
    );

    if (convCheck.rows.length === 0) {
      console.log(`❌ Conversation ${conversationId} not found`);
      return res.status(404).json({ error: "Conversation not found" });
    }
    console.log(`✅ Conversation ${conversationId} exists`);

    // Step 2: Check if user has access to this conversation
    console.log(`Step 2: Checking if user ${req.user.id} has access...`);
    const accessCheck = await pool.query(`
      SELECT 1 FROM conversation_participants 
      WHERE conversation_id = $1 AND user_id = $2
    `, [conversationId, req.user.id]);

    if (accessCheck.rows.length === 0) {
      console.log(`❌ User ${req.user.id} doesn't have access to conversation ${conversationId}`);
      return res.status(403).json({ error: "Access denied to this conversation" });
    }
    console.log(`✅ User ${req.user.id} has access to conversation ${conversationId}`);

    // Step 3: Get all messages with sender info
    console.log(`Step 3: Fetching messages...`);
    const result = await pool.query(`
      SELECT 
        m.id,
        m.conversation_id,
        m.sender_id,
        m.message_text,
        m.sent_at,
        m.read_at,
        COALESCE(u.name, 'Unknown User') as sender_name,
        u.profile_image_url as sender_avatar
      FROM messages m
      LEFT JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.sent_at ASC
    `, [conversationId]);

    console.log(`✅ Found ${result.rows.length} messages for conversation ${conversationId}`);
    
    if (result.rows.length > 0) {
      console.log(`📋 Sample messages (first 3):`);
      result.rows.slice(0, 3).forEach((msg, idx) => {
        console.log(`  ${idx + 1}. ID: ${msg.id}, Sender: ${msg.sender_name} (${msg.sender_id}), Text: "${msg.message_text.substring(0, 50)}..."`);
      });
    } else {
      console.log(`ℹ️ No messages found in conversation ${conversationId}`);
    }

    console.log('='.repeat(60));
    console.log(`✅ Sending ${result.rows.length} messages to client`);
    console.log('='.repeat(60));
    
    res.json(result.rows);
    
  } catch (err) {
    console.error('='.repeat(60));
    console.error("❌ GET MESSAGES ERROR");
    console.error("Error message:", err.message);
    console.error("Error code:", err.code);
    console.error("Stack trace:", err.stack);
    console.error('='.repeat(60));
    
    return res.status(500).json({ 
      error: "Server error: " + err.message,
      code: err.code
    });
  }
});

// 3. Send a message
app.post("/api/conversations/:conversationId/messages", authenticateToken, async (req, res) => {
  const { conversationId } = req.params;
  const { senderId, messageText } = req.body;
  
  console.log(`📨 Sending message to conversation ${conversationId}`);
  console.log(`👤 Sender: ${senderId}`);
  console.log(`💬 Message: ${messageText}`);
  
  try {
    if (!senderId || !messageText) {
      return res.status(400).json({ error: "senderId and messageText are required" });
    }

    const accessCheck = await pool.query(`
      SELECT 1 FROM conversation_participants 
      WHERE conversation_id = $1 AND user_id = $2
    `, [conversationId, senderId]);

    if (accessCheck.rows.length === 0) {
      console.log(`❌ Sender ${senderId} doesn't have access to conversation ${conversationId}`);
      return res.status(403).json({ error: "Access denied to this conversation" });
    }

    const result = await pool.query(`
      INSERT INTO messages (conversation_id, sender_id, message_text, sent_at)
      VALUES ($1, $2, $3, NOW())
      RETURNING *
    `, [conversationId, senderId, messageText]);

    const message = result.rows[0];
    console.log(`✅ Message sent with ID: ${message.id}`);

    const senderInfo = await pool.query(
      'SELECT name, profile_image_url FROM users WHERE id = $1',
      [senderId]
    );

    await pool.query(
      'UPDATE conversations SET updated_at = NOW() WHERE id = $1',
      [conversationId]
    );

    const fullMessage = {
      ...message,
      sender_name: senderInfo.rows[0]?.name || 'Unknown User',
      sender_avatar: senderInfo.rows[0]?.profile_image_url
    };

    res.status(201).json(fullMessage);
  } catch (err) {
    console.error("❌ Send message error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// 4. Mark messages as read
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

// 5. Start or get conversation with artisan
app.post("/api/conversations/start", async (req, res) => {
  console.log('=== CONVERSATION START REQUEST ===');
  console.log('Request body:', req.body);
  
  const { currentUserId, otherUserId, productId, initialMessage } = req.body;
  
  if (!currentUserId || !otherUserId) {
    console.log('❌ Missing required fields');
    return res.status(400).json({ 
      error: "Missing required fields: currentUserId and otherUserId are required" 
    });
  }

  try {
    console.log('Checking if users exist...');
    
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

    console.log('✅ Both users exist');

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
      console.log('✅ Found existing conversation:', conversationId);
    } else {
      const newConv = await pool.query(
        'INSERT INTO conversations (created_at, updated_at) VALUES (NOW(), NOW()) RETURNING *'
      );
      
      conversationId = newConv.rows[0].id;
      console.log('✅ Created new conversation:', conversationId);

      await pool.query(
        'INSERT INTO conversation_participants (conversation_id, user_id) VALUES ($1, $2), ($1, $3)',
        [conversationId, currentUserId, otherUserId]
      );
      console.log('✅ Added participants to conversation');
    }

    if (initialMessage) {
      await pool.query(
        'INSERT INTO messages (conversation_id, sender_id, message_text, sent_at) VALUES ($1, $2, $3, NOW())',
        [conversationId, currentUserId, initialMessage]
      );
      console.log('✅ Added initial message:', initialMessage);
      
      await pool.query(
        'UPDATE conversations SET updated_at = NOW() WHERE id = $1',
        [conversationId]
      );
    }

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

    console.log('✅ Conversation created successfully:', conversationId);
    
    res.json({
      id: conversationId,
      ...conversationInfo.rows[0]
    });
    
  } catch (err) {
    console.error("❌ Start conversation error:", err);
    res.status(500).json({ 
      error: "Server error: " + err.message
    });
  }
});

// 6. LAST: Dynamic route (catches /api/conversations/NUMBER/NUMBER)
// This should be at the END so it doesn't catch other routes
app.get("/api/conversations/:userId1/:userId2", authenticateToken, async (req, res) => {
  const { userId1, userId2 } = req.params;
  
  try {
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

    const newConv = await pool.query(
      'INSERT INTO conversations DEFAULT VALUES RETURNING *'
    );
    
    const convId = newConv.rows[0].id;

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
      SELECT 
        p.*,
        COALESCE(u.name, p.creator_name, 'Unknown Artisan') as creator_name,
        u.profile_image_url as creator_avatar
      FROM products p
      LEFT JOIN users u ON p.artisan_id = u.id
      ORDER BY p.created_at DESC
    `);
    
    console.log(`Returning ${result.rows.length} products`);
    
    // Log first product for debugging
    if (result.rows.length > 0) {
      const firstProduct = result.rows[0];
      console.log('   First product:');
      console.log('   ID:', firstProduct.id);
      console.log('   Title:', firstProduct.title);
      console.log('   Has image_data_base64:', firstProduct.image_data_base64 ? 'Yes' : 'No');
      
      if (firstProduct.image_data_base64) {
        console.log('   image_data_base64 type:', typeof firstProduct.image_data_base64);
        console.log('   image_data_base64 is array:', Array.isArray(firstProduct.image_data_base64));
        
        if (Array.isArray(firstProduct.image_data_base64)) {
          console.log('   Images count:', firstProduct.image_data_base64.length);
          if (firstProduct.image_data_base64.length > 0) {
            const firstUrl = firstProduct.image_data_base64[0];
            console.log('   First URL:', firstUrl);
            console.log('   Is valid URL:', firstUrl.startsWith('http'));
          }
        }
      }
    }
    
    res.json(result.rows);
  } catch (err) {
    console.error("Get products error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

app.post("/api/fix-products-image-column", async (req, res) => {
  try {
    console.log('🔧 Fixing products table image column...');

    // Check if image_data_base64 column exists
    const columnCheck = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'products' AND column_name = 'image_data_base64'
    `);

    if (columnCheck.rows.length === 0) {
      // Add the column if it doesn't exist
      await pool.query(`
        ALTER TABLE products 
        ADD COLUMN image_data_base64 TEXT[]
      `);
      console.log('✅ Added image_data_base64 column as TEXT array');
    } else {
      // Check if it's the right type
      const currentType = columnCheck.rows[0].data_type;
      console.log('Current image_data_base64 type:', currentType);
      
      if (currentType !== 'ARRAY') {
        // Drop and recreate with correct type
        await pool.query(`
          ALTER TABLE products 
          DROP COLUMN IF EXISTS image_data_base64
        `);
        await pool.query(`
          ALTER TABLE products 
          ADD COLUMN image_data_base64 TEXT[]
        `);
        console.log('✅ Recreated image_data_base64 column as TEXT array');
      } else {
        console.log('✅ image_data_base64 column already has correct type');
      }
    }

    // Also ensure we have image_url for backwards compatibility
    const imageUrlCheck = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products' AND column_name = 'image_url'
    `);

    if (imageUrlCheck.rows.length === 0) {
      await pool.query(`
        ALTER TABLE products 
        ADD COLUMN image_url VARCHAR(500)
      `);
      console.log('✅ Added image_url column for backwards compatibility');
    }

    res.json({ 
      success: true, 
      message: "Products table image columns fixed successfully" 
    });
  } catch (err) {
    console.error("❌ Fix products table error:", err);
    res.status(500).json({ error: "Fix failed: " + err.message });
  }
});

// Search products by title, description, category, or artisan name
app.get("/api/products/search", async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query) {
      return res.status(400).json({ error: "Search query required" });
    }

    console.log(`🔍 Searching products for: "${query}"`);

    const result = await pool.query(`
      SELECT 
        p.*,
        u.name as creator_name,
        u.profile_image_url as creator_avatar
      FROM products p
      JOIN users u ON p.artisan_id = u.id
      WHERE (
        LOWER(p.title) LIKE LOWER($1) 
        OR LOWER(p.description) LIKE LOWER($1)
        OR LOWER(p.category) LIKE LOWER($1)
        OR LOWER(p.materials_used) LIKE LOWER($1)
        OR LOWER(u.name) LIKE LOWER($1)
      )
      ORDER BY p.created_at DESC
    `, [`%${query}%`]);

    console.log(` Found ${result.rows.length} products matching "${query}"`);

    res.json(result.rows);
  } catch (err) {
    console.error("Search products error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// Create new product listing
app.post("/api/products", upload.array('images', 5), async (req, res) => {
  console.log('CREATE PRODUCT REQUEST');
  console.log('Body:', JSON.stringify(req.body, null, 2));
  
  const { 
    title, description, price, category, condition, 
    materials_used, dimensions, location, artisan_id, creator_name 
  } = req.body;

  try {
    // Validate required fields
    if (!title || !description || !price || !artisan_id) {
      console.log('Missing required fields');
      return res.status(400).json({ error: "Missing required fields" });
    }

    console.log(`Validated input - Artisan ID: ${artisan_id}`);

    // Verify the user exists
    const userResult = await pool.query(
      'SELECT id, name FROM users WHERE id = $1',
      [artisan_id]
    );

    if (userResult.rows.length === 0) {
      console.log(`❌ User with ID ${artisan_id} not found`);
      return res.status(400).json({ error: "Invalid artisan_id - user not found" });
    }

    const actualCreatorName = userResult.rows[0].name;
    console.log(`User verified: ${actualCreatorName}`);

    // Process image URLs from request body
    let imageUrls = [];
    
    // CRITICAL: Parse image_urls from the request body
    if (req.body.image_urls) {
      try {
        // If it's a string, parse it as JSON
        if (typeof req.body.image_urls === 'string') {
          imageUrls = JSON.parse(req.body.image_urls);
        } 
        // If it's already an array, use it directly
        else if (Array.isArray(req.body.image_urls)) {
          imageUrls = req.body.image_urls;
        }
        
        console.log(`Received ${imageUrls.length} Cloudinary image URLs`);
        
        // Log each URL to verify they're valid
        imageUrls.forEach((url, index) => {
          console.log(`   ${index + 1}. ${url}`);
          
          // Validate URL format
          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            console.log(`Warning: URL ${index + 1} doesn't start with http/https`);
          }
        });
        
      } catch (parseErr) {
        console.log('Error parsing image_urls:', parseErr);
        imageUrls = [];
      }
    } else {
      console.log('No image_urls provided in request');
    }

    // Ensure we have at least one image
    if (imageUrls.length === 0) {
      console.log('No valid image URLs found');
      return res.status(400).json({ 
        error: "At least one product image is required" 
      });
    }

    console.log('Inserting product into database...');

    // Insert the product with image_data_base64 containing Cloudinary URLs
    const result = await pool.query(
      `INSERT INTO products 
       (title, description, price, category, condition, materials_used, 
        dimensions, location, artisan_id, image_data_base64, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW()) 
       RETURNING *`,
      [
        title, 
        description, 
        parseFloat(price), 
        category, 
        condition || null, 
        materials_used || null, 
        dimensions || null, 
        location || null, 
        parseInt(artisan_id),
        imageUrls  // Store Cloudinary URLs as array
      ]
    );

    const insertedProduct = result.rows[0];
    console.log(`Product inserted with ID: ${insertedProduct.id}`);
    console.log(`Stored ${imageUrls.length} image URLs in database`);

    // Format response
    const responseProduct = {
      id: insertedProduct.id,
      title: insertedProduct.title,
      description: insertedProduct.description,
      price: insertedProduct.price,
      category: insertedProduct.category,
      condition: insertedProduct.condition,
      materials_used: insertedProduct.materials_used,
      dimensions: insertedProduct.dimensions,
      location: insertedProduct.location,
      artisan_id: insertedProduct.artisan_id,
      creator_name: actualCreatorName,
      image_urls: insertedProduct.image_data_base64,  // Return the stored URLs
      image_data_base64: insertedProduct.image_data_base64,  // Also include for compatibility
      created_at: insertedProduct.created_at
    };

    console.log('Sending response with product data');
    console.log('=' * 60);
    
    res.status(201).json(responseProduct);

  } catch (err) {
    console.error("Server error creating product:", err);
    console.error("Stack trace:", err.stack);
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: err.stack
    });
  }
});

app.post("/api/fix-products-image-urls-column", async (req, res) => {
  try {
    console.log('Adding image_urls column to products table...');

    // Check if column exists
    const columnCheck = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products' AND column_name = 'image_urls'
    `);

    if (columnCheck.rows.length === 0) {
      // Add the column
      await pool.query(`
        ALTER TABLE products 
        ADD COLUMN image_urls TEXT[]
      `);
      console.log('Added image_urls column');
    } else {
      console.log('image_urls column already exists');
    }

    // Copy data from image_data_base64 to image_urls for existing products
    await pool.query(`
      UPDATE products 
      SET image_urls = image_data_base64 
      WHERE image_data_base64 IS NOT NULL AND image_urls IS NULL
    `);
    console.log('Copied existing image data');

    res.json({ 
      success: true, 
      message: "Products table image_urls column added successfully" 
    });
  } catch (err) {
    console.error("Fix error:", err);
    res.status(500).json({ error: "Fix failed: " + err.message });
  }
});

app.get("/api/debug/product-images/:productId", async (req, res) => {
  const { productId } = req.params;
  
  try {
    console.log(`Checking images for product ${productId}...`);
    
    const result = await pool.query(
      'SELECT id, title, image_data_base64, image_url, image_urls FROM products WHERE id = $1',
      [productId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    const product = result.rows[0];
    
    const imageInfo = {
      product_id: product.id,
      title: product.title,
      has_image_data_base64: product.image_data_base64 !== null,
      has_image_url: product.image_url !== null,
      has_image_urls: product.image_urls !== null,
      image_data_base64_type: product.image_data_base64 ? typeof product.image_data_base64 : null,
      image_data_base64_is_array: Array.isArray(product.image_data_base64),
      image_data_base64_length: Array.isArray(product.image_data_base64) ? product.image_data_base64.length : 0,
      image_data_base64_content: product.image_data_base64,
      image_url: product.image_url,
      image_urls: product.image_urls
    };
    
    // Check if URLs are valid Cloudinary URLs
    if (Array.isArray(product.image_data_base64)) {
      imageInfo.urls_analysis = product.image_data_base64.map((url, index) => ({
        index: index + 1,
        url: url,
        is_cloudinary: url.includes('cloudinary.com'),
        is_http: url.startsWith('http'),
        is_base64: url.startsWith('data:image')
      }));
    }
    
    console.log('Image info:', JSON.stringify(imageInfo, null, 2));
    
    res.json(imageInfo);
    
  } catch (err) {
    console.error('Debug error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Also add this endpoint to test product creation with a test image
app.post("/api/debug/test-product-creation", async (req, res) => {
  try {
    console.log('Testing product creation with sample Cloudinary URL...');
    
    const testImageUrl = 'https://res.cloudinary.com/demo/image/upload/sample.jpg';
    
    const result = await pool.query(
      `INSERT INTO products 
       (title, description, price, category, artisan_id, image_data_base64) 
       VALUES ($1, $2, $3, $4, $5, $6) 
       RETURNING *`,
      [
        'Test Product',
        'Test description',
        100.00,
        'Test',
        1,  // Make sure this user ID exists
        [testImageUrl]  // Array with one test URL
      ]
    );
    
    const product = result.rows[0];
    
    console.log('   Test product created:', product.id);
    console.log('   image_data_base64:', product.image_data_base64);
    
    res.json({
      success: true,
      product: product,
      image_stored_correctly: Array.isArray(product.image_data_base64) && 
                              product.image_data_base64.length > 0 &&
                              product.image_data_base64[0].startsWith('http')
    });
    
  } catch (err) {
    console.error('Test creation error:', err);
    res.status(500).json({ error: err.message });
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
    
    console.log(`Found ${materials.rows.length} materials without images`);
    
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
    console.log('Resetting products table...');

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
  const { 
    cartItems,
    totalAmount, 
    appliedGems = 0, 
    shippingAddress, 
    paymentMethod,
    deliveryAddress,
    phoneNumber,
    paymentReference // For bank transfers
  } = req.body;

  try {
    console.log('📦 Creating order...');
    console.log('Payment method:', paymentMethod);
    console.log('Total amount:', totalAmount);

    // Basic validation
    if (!totalAmount || totalAmount <= 0) {
      return res.status(400).json({ error: "Invalid total amount" });
    }

    if (!paymentMethod) {
      return res.status(400).json({ error: "Payment method is required" });
    }

    // Validate payment method specific requirements
    if (paymentMethod === 'cod' && !deliveryAddress) {
      return res.status(400).json({ error: "Delivery address required for Cash on Delivery" });
    }

    if (paymentMethod === 'cod' && !phoneNumber) {
      return res.status(400).json({ error: "Phone number required for Cash on Delivery" });
    }

    if (paymentMethod === 'bank_transfer' && !paymentReference) {
      return res.status(400).json({ error: "Payment reference required for Bank Transfer" });
    }

    // Fetch user's gem balance
    const userResult = await pool.query(
      "SELECT available_gems, email, name FROM users WHERE id = $1",
      [userId]
    );

    const user = userResult.rows[0];
    const availableGems = parseInt(user.available_gems || 0);
    const actualAppliedGems = Math.min(appliedGems, availableGems);

    // Calculate final amount
    const gemValue = 1; // 1 gem = 1 LSL
    let finalAmount = Math.max(0, totalAmount - actualAppliedGems * gemValue);

    // Add COD fee if applicable (M20 delivery fee)
    if (paymentMethod === 'cod') {
      finalAmount += 20; // M20 COD fee
    }

    // Determine payment status based on method
    let paymentStatus = 'pending';
    let orderStatus = 'pending';
    
    if (paymentMethod === 'cod') {
      paymentStatus = 'cod_pending'; // Will be paid on delivery
      orderStatus = 'confirmed'; // Order is confirmed, awaiting delivery
    } else if (paymentMethod === 'bank_transfer' || paymentMethod === 'ussd') {
      paymentStatus = 'awaiting_confirmation'; // Manual verification needed
      orderStatus = 'pending'; // Pending until payment confirmed
    } else if (paymentMethod === 'card') {
      paymentStatus = 'completed';
      orderStatus = 'completed';
    }

    // Create new order
    const orderResult = await pool.query(
      `INSERT INTO orders (
        user_id, 
        total_amount, 
        applied_gems, 
        final_amount, 
        shipping_address, 
        payment_method,
        payment_status,
        status,
        delivery_address,
        phone_number,
        payment_reference,
        created_at
      )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW()) 
       RETURNING *`,
      [
        userId, 
        totalAmount, 
        actualAppliedGems, 
        finalAmount, 
        shippingAddress || deliveryAddress, 
        paymentMethod,
        paymentStatus,
        orderStatus,
        deliveryAddress,
        phoneNumber,
        paymentReference
      ]
    );

    const order = orderResult.rows[0];

    // Update gems & transactions if gems were used
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

    // Reward gems for completing an order (only for paid orders)
    if (paymentMethod === 'card') {
      await pool.query(
        "UPDATE users SET available_gems = available_gems + 2 WHERE id = $1",
        [userId]
      );
      await pool.query(
        "INSERT INTO gem_transactions (user_id, amount, type, description) VALUES ($1, $2, 'earn', 'Bonus for completing an order')",
        [userId, 2]
      );
    }

    // Clear user's cart after order creation
    if (cartItems && cartItems.length > 0) {
      await pool.query(
        "DELETE FROM cart_items WHERE user_id = $1",
        [userId]
      );
      console.log('🗑️ Cleared cart after order creation');
    }

    // Send confirmation email based on payment method
    let emailSubject = '';
    let emailText = '';
    
    if (paymentMethod === 'cod') {
      emailSubject = 'Order Confirmed - Cash on Delivery';
      emailText = `Hi ${user.name}! Your order #${order.id} has been confirmed. Total amount: M${finalAmount.toFixed(2)} (including M20 delivery fee). You'll pay when the items are delivered to: ${deliveryAddress}. We'll call you on ${phoneNumber} to arrange delivery.`;
    } else if (paymentMethod === 'bank_transfer') {
      emailSubject = 'Order Pending - Bank Transfer Confirmation Required';
      emailText = `Hi ${user.name}! Your order #${order.id} is pending payment confirmation. Reference: ${paymentReference}. Once we verify your payment, we'll process your order.`;
    } else if (paymentMethod === 'ussd') {
      emailSubject = 'Order Pending - USSD Payment Confirmation Required';
      emailText = `Hi ${user.name}! Your order #${order.id} is pending payment confirmation. Once we verify your USSD payment, we'll process your order.`;
    } else {
      emailSubject = 'Order Confirmed!';
      emailText = `Hi ${user.name}! Your order #${order.id} has been confirmed. Total: M${finalAmount.toFixed(2)}.`;
    }

    // Send email in background
    sendEmail({
      to: user.email,
      subject: emailSubject,
      text: emailText
    }).catch(err => console.error('Failed to send order confirmation email:', err));

    console.log(`Order created: #${order.id} - ${paymentMethod}`);

    res.status(201).json({
      success: true,
      message: "Order created successfully",
      order: order,
      applied_gems: actualAppliedGems,
      final_amount: finalAmount,
      payment_status: paymentStatus,
      order_status: orderStatus
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

// Get user's shopping cart
app.get("/api/users/:userId/cart", authenticateToken, async (req, res) => {
  const { userId } = req.params;

  try {
    console.log(`🛒 Getting cart for user ${userId}`);
    
    // First, let's check what columns actually exist in products table
    const productColumns = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products'
    `);
    
    const hasImageData = productColumns.rows.some(col => col.column_name === 'image_data_base64');
    const hasImageUrl = productColumns.rows.some(col => col.column_name === 'image_url');
    
    console.log(`🛒 Products table - has image_data_base64: ${hasImageData}, has image_url: ${hasImageUrl}`);
    
    // Build dynamic query based on available columns
    let query = `
      SELECT 
        ci.id as cart_item_id,
        ci.quantity,
        p.id as product_id,
        p.title,
        p.description,
        p.price,
        p.category,
        p.condition,
        p.materials_used,
        p.dimensions,
        p.location,
        p.artisan_id,
        u.name as artisan_name,
        u.profile_image_url as artisan_avatar
    `;
    
    // Add image column based on what exists
    if (hasImageData) {
      query += `, p.image_data_base64`;
    } else if (hasImageUrl) {
      query += `, p.image_url as image_data_base64`;
    } else {
      query += `, NULL as image_data_base64`;
    }
    
    query += `
      FROM cart_items ci
      LEFT JOIN products p ON ci.product_id = p.id
      LEFT JOIN users u ON p.artisan_id = u.id
      WHERE ci.user_id = $1
      ORDER BY ci.created_at DESC
    `;

    console.log(`🛒 Executing query:`, query);
    
    const result = await pool.query(query, [userId]);
    console.log(`🛒 Found ${result.rows.length} cart items for user ${userId}`);

    // Process results safely
    const cartItems = result.rows.map(item => {
      try {
        const cartItem = {
          cart_item_id: item.cart_item_id,
          product_id: item.product_id,
          title: item.title || 'Unknown Product',
          description: item.description || '',
          price: item.price ? parseFloat(item.price) : 0,
          category: item.category,
          condition: item.condition,
          materials_used: item.materials_used,
          dimensions: item.dimensions,
          location: item.location,
          image_data_base64: item.image_data_base64 || [],
          artisan_id: item.artisan_id,
          artisan_name: item.artisan_name || 'Unknown Artisan',
          artisan_avatar: item.artisan_avatar,
          quantity: item.quantity || 1
        };
        
        // If we have image_url but no image_data_base64, convert it
        if (item.image_url && (!item.image_data_base64 || item.image_data_base64.length === 0)) {
          cartItem.image_data_base64 = [item.image_url];
        }
        
        return cartItem;
      } catch (itemErr) {
        console.error(`❌ Error processing cart item:`, itemErr);
        return null;
      }
    }).filter(item => item !== null); // Remove any null items from errors

    console.log(`🛒 Successfully processed ${cartItems.length} cart items`);
    res.json(cartItems);
    
  } catch (err) {
    console.error("❌ Get cart error:", err);
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: "Check server logs for more information"
    });
  }
});

// Add item to cart
app.post("/api/users/:userId/cart", authenticateToken, async (req, res) => {
  const { userId } = req.params;
  const { product_id, quantity = 1 } = req.body;

  try {
    console.log(`🛒 Add to cart - User: ${userId}, Product: ${product_id}, Quantity: ${quantity}`);
    
    // Validate input
    if (!product_id) {
      return res.status(400).json({ error: "Product ID is required" });
    }

    // Check if product exists
    const productCheck = await pool.query(
      "SELECT id, title FROM products WHERE id = $1",
      [product_id]
    );

    if (productCheck.rows.length === 0) {
      console.log(`❌ Product ${product_id} not found`);
      return res.status(404).json({ error: "Product not found" });
    }

    console.log(`✅ Product found: ${productCheck.rows[0].title}`);

    // Check if item already in cart
    const existingItem = await pool.query(
      "SELECT id, quantity FROM cart_items WHERE user_id = $1 AND product_id = $2",
      [userId, product_id]
    );

    let result;
    if (existingItem.rows.length > 0) {
      // Update quantity if item exists
      console.log(`🔄 Updating existing cart item quantity`);
      result = await pool.query(
        "UPDATE cart_items SET quantity = quantity + $1, updated_at = NOW() WHERE user_id = $2 AND product_id = $3 RETURNING *",
        [quantity, userId, product_id]
      );
    } else {
      // Add new item to cart
      console.log(`🆕 Adding new item to cart`);
      result = await pool.query(
        "INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *",
        [userId, product_id, quantity]
      );
    }

    console.log(`✅ Cart operation successful, item ID: ${result.rows[0].id}`);
    
    res.status(201).json({
      success: true,
      message: "Item added to cart",
      cart_item: result.rows[0]
    });
    
  } catch (err) {
    console.error("❌ Add to cart error:", err);
    
    // Check if it's a foreign key violation
    if (err.code === '23503') {
      return res.status(400).json({ 
        error: "Invalid product or user",
        details: "The product or user does not exist"
      });
    }
    
    res.status(500).json({ 
      error: "Server error: " + err.message,
      details: "Check server logs for more information"
    });
  }
});

// Update cart item quantity
app.put("/api/users/:userId/cart/:itemId", authenticateToken, async (req, res) => {
  const { userId, itemId } = req.params;
  const { quantity } = req.body;

  try {
    if (quantity < 1) {
      return res.status(400).json({ error: "Quantity must be at least 1" });
    }

    const result = await pool.query(
      "UPDATE cart_items SET quantity = $1, updated_at = NOW() WHERE id = $2 AND user_id = $3 RETURNING *",
      [quantity, itemId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Cart item not found" });
    }

    res.json({
      success: true,
      message: "Cart updated",
      cart_item: result.rows[0]
    });
  } catch (err) {
    console.error("Update cart error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Remove item from cart
app.delete("/api/users/:userId/cart/:itemId", authenticateToken, async (req, res) => {
  const { userId, itemId } = req.params;

  try {
    const result = await pool.query(
      "DELETE FROM cart_items WHERE id = $1 AND user_id = $2 RETURNING *",
      [itemId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Cart item not found" });
    }

    res.json({
      success: true,
      message: "Item removed from cart"
    });
  } catch (err) {
    console.error("Remove from cart error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Clear user's cart
app.delete("/api/users/:userId/cart", authenticateToken, async (req, res) => {
  const { userId } = req.params;

  try {
    await pool.query(
      "DELETE FROM cart_items WHERE user_id = $1",
      [userId]
    );

    res.json({
      success: true,
      message: "Cart cleared"
    });
  } catch (err) {
    console.error("Clear cart error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Get user's available gems
app.get("/api/users/:userId/gems", authenticateToken, async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(
      "SELECT available_gems FROM users WHERE id = $1",
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({
      available_gems: parseInt(result.rows[0].available_gems) || 0
    });
  } catch (err) {
    console.error("Get user gems error:", err);
    res.status(500).json({ error: "Server error: " + err.message });
  }
});

// Setup cart table
app.post("/api/setup-cart-table", async (req, res) => {
  try {
    console.log('Creating cart_items table...');

    // First check if table exists
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'cart_items'
      );
    `);

    if (tableCheck.rows[0].exists) {
      console.log('📦 cart_items table already exists, checking columns...');
      
      // Check if user_id column exists
      const userIdColumnCheck = await pool.query(`
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'cart_items' AND column_name = 'user_id'
      `);

      if (userIdColumnCheck.rows.length === 0) {
        console.log('➡️ Adding user_id column to cart_items table...');
        await pool.query('ALTER TABLE cart_items ADD COLUMN user_id INTEGER');
      }

      // Check if product_id column exists
      const productIdColumnCheck = await pool.query(`
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'cart_items' AND column_name = 'product_id'
      `);

      if (productIdColumnCheck.rows.length === 0) {
        console.log('➡️ Adding product_id column to cart_items table...');
        await pool.query('ALTER TABLE cart_items ADD COLUMN product_id INTEGER');
      }

      // Check if quantity column exists
      const quantityColumnCheck = await pool.query(`
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'cart_items' AND column_name = 'quantity'
      `);

      if (quantityColumnCheck.rows.length === 0) {
        console.log('➡️ Adding quantity column to cart_items table...');
        await pool.query('ALTER TABLE cart_items ADD COLUMN quantity INTEGER DEFAULT 1');
      }

      // Add foreign key constraints if they don't exist
      try {
        await pool.query('ALTER TABLE cart_items ADD CONSTRAINT fk_cart_items_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE');
        console.log('✓ Added user foreign key constraint');
      } catch (fkErr) {
        console.log('User foreign key already exists or cannot be added');
      }

      try {
        await pool.query('ALTER TABLE cart_items ADD CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE');
        console.log('✓ Added product foreign key constraint');
      } catch (fkErr) {
        console.log('Product foreign key already exists or cannot be added');
      }

      // Add unique constraint if it doesn't exist
      try {
        await pool.query('ALTER TABLE cart_items ADD CONSTRAINT unique_user_product UNIQUE (user_id, product_id)');
        console.log('✓ Added unique constraint');
      } catch (uniqueErr) {
        console.log('Unique constraint already exists or cannot be added');
      }

    } else {
      // Create the table if it doesn't exist
      await pool.query(`
        CREATE TABLE cart_items (
          id SERIAL PRIMARY KEY,
          user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
          product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
          quantity INTEGER NOT NULL DEFAULT 1,
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW(),
          UNIQUE(user_id, product_id)
        )
      `);
      console.log('✓ Created cart_items table');
    }

    // Create index for better performance
    try {
      await pool.query(`CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id)`);
      console.log('✓ Created index on cart_items');
    } catch (indexErr) {
      console.log('Index creation for cart_items failed:', indexErr.message);
    }

    res.json({ 
      success: true, 
      message: "Cart table setup completed successfully" 
    });
  } catch (err) {
    console.error("Setup cart table error:", err);
    res.status(500).json({ error: "Setup failed: " + err.message });
  }
});

app.get("/api/debug/cart-query/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    console.log(`🔍 Debug: Testing cart query for user ${userId}`);
    
    // Step 1: Check if user exists
    const userCheck = await pool.query("SELECT id, name FROM users WHERE id = $1", [userId]);
    console.log(`🔍 User check: ${userCheck.rows.length} users found`);
    
    // Step 2: Check cart_items directly
    const cartCheck = await pool.query("SELECT * FROM cart_items WHERE user_id = $1", [userId]);
    console.log(`🔍 Cart items raw: ${cartCheck.rows.length} items found`);
    console.log(`🔍 Cart items:`, cartCheck.rows);
    
    // Step 3: Check products table structure
    const productColumns = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'products' 
      ORDER BY ordinal_position
    `);
    console.log(`🔍 Products table columns:`, productColumns.rows);
    
    // Step 4: Try simplified query first
    const simpleQuery = await pool.query(`
      SELECT 
        ci.id as cart_item_id,
        ci.quantity,
        ci.user_id,
        ci.product_id,
        p.id as product_id,
        p.title,
        p.price
      FROM cart_items ci
      LEFT JOIN products p ON ci.product_id = p.id
      WHERE ci.user_id = $1
    `, [userId]);
    
    console.log(`🔍 Simple query result: ${simpleQuery.rows.length} items`);
    
    res.json({
      user_exists: userCheck.rows.length > 0,
      cart_items_count: cartCheck.rows.length,
      cart_items: cartCheck.rows,
      products_columns: productColumns.rows,
      simple_query_results: simpleQuery.rows
    });
    
  } catch (err) {
    console.error("Debug cart query error:", err);
    res.status(500).json({ error: "Debug query failed: " + err.message });
  }
});

// Debug endpoint to manually add item to cart - NO AUTHENTICATION
app.post("/api/debug/users/:userId/cart/add", async (req, res) => {
  const { userId } = req.params;
  const { product_id, quantity = 1 } = req.body;

  try {
    console.log(`🔍 Debug: Adding item to cart for user ${userId}, product ${product_id}`);
    
    // Check if product exists
    const productCheck = await pool.query(
      "SELECT id, title FROM products WHERE id = $1",
      [product_id]
    );

    if (productCheck.rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    console.log(`🔍 Debug: Product found: ${productCheck.rows[0].title}`);

    // Add to cart
    const result = await pool.query(
      "INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *",
      [userId, product_id, quantity]
    );

    console.log(`✅ Debug: Item added to cart with ID: ${result.rows[0].id}`);
    
    res.json({
      success: true,
      message: "Debug: Item added to cart",
      cart_item: result.rows[0],
      product: productCheck.rows[0]
    });
  } catch (err) {
    console.error("Debug add to cart error:", err);
    res.status(500).json({ error: "Debug add failed: " + err.message });
  }
});

// Debug endpoint to check all tables - NO AUTHENTICATION
app.get("/api/debug/tables", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `);
    
    res.json({
      tables: result.rows.map(row => row.table_name)
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Debug endpoint to check products - NO AUTHENTICATION
app.get("/api/debug/products", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, title, price FROM products ORDER BY id LIMIT 10
    `);
    
    res.json({
      products: result.rows,
      count: result.rows.length
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/debug/test-cart/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    console.log(`🧪 Running comprehensive cart test for user ${userId}`);
    
    // Step 1: Check if user exists
    const userCheck = await pool.query("SELECT id, name FROM users WHERE id = $1", [userId]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }
    
    // Step 2: Check if we have products
    const products = await pool.query("SELECT id, title FROM products LIMIT 1");
    if (products.rows.length === 0) {
      return res.status(404).json({ error: "No products found in database" });
    }
    
    const testProductId = products.rows[0].id;
    console.log(`🧪 Using product ID ${testProductId} for testing`);
    
    // Step 3: Clear any existing cart items for this user
    await pool.query("DELETE FROM cart_items WHERE user_id = $1", [userId]);
    console.log(`🧪 Cleared existing cart items`);
    
    // Step 4: Add item to cart
    const addResult = await pool.query(
      "INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *",
      [userId, testProductId, 2]
    );
    console.log(`🧪 Added item to cart:`, addResult.rows[0]);
    
    // Step 5: Retrieve cart items
    const cartItems = await pool.query(`
      SELECT ci.*, p.title, p.price 
      FROM cart_items ci 
      JOIN products p ON ci.product_id = p.id 
      WHERE ci.user_id = $1
    `, [userId]);
    
    console.log(`🧪 Retrieved ${cartItems.rows.length} cart items`);
    
    res.json({
      success: true,
      test_user: userCheck.rows[0],
      test_product: products.rows[0],
      added_cart_item: addResult.rows[0],
      retrieved_cart_items: cartItems.rows,
      message: "Cart test completed successfully"
    });
    
  } catch (err) {
    console.error("Cart test error:", err);
    res.status(500).json({ error: "Cart test failed: " + err.message });
  }
});

app.get("/api/debug/cart-raw/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    console.log(`🔍 Checking raw cart data for user ${userId}`);
    
    // Simple query without joins first
    const rawCart = await pool.query(`
      SELECT * FROM cart_items WHERE user_id = $1
    `, [userId]);
    
    console.log(`📦 Raw cart items:`, rawCart.rows);

    res.json({
      user_id: userId,
      cart_items: rawCart.rows,
      count: rawCart.rows.length
    });
  } catch (err) {
    console.error("Raw cart debug error:", err);
    res.status(500).json({ error: "Raw cart debug failed: " + err.message });
  }
});

app.post("/api/debug/cart-test-add/:userId", async (req, res) => {
  const { userId } = req.params;
  const { product_id } = req.body;

  try {
    console.log(`🧪 Test: Adding product ${product_id} to cart for user ${userId}`);
    
    // Step 1: Clear existing cart
    await pool.query("DELETE FROM cart_items WHERE user_id = $1", [userId]);
    console.log(`🧪 Cleared existing cart items`);
    
    // Step 2: Add test item
    const addResult = await pool.query(
      "INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *",
      [userId, product_id, 1]
    );
    console.log(`🧪 Added item:`, addResult.rows[0]);
    
    // Step 3: Retrieve using main cart endpoint (with authentication simulation)
    const cartResult = await pool.query(`
      SELECT 
        ci.id as cart_item_id,
        ci.quantity,
        p.id as product_id,
        p.title,
        p.price
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
      WHERE ci.user_id = $1
    `, [userId]);
    
    console.log(`🧪 Retrieved ${cartResult.rows.length} items via main query`);
    
    res.json({
      success: true,
      added_item: addResult.rows[0],
      retrieved_items: cartResult.rows,
      message: "Test completed"
    });
    
  } catch (err) {
    console.error("Cart test error:", err);
    res.status(500).json({ error: "Cart test failed: " + err.message });
  }
});

// Debug endpoint: Check if cart_items table exists and has correct structure
app.get("/api/debug/cart-schema", async (req, res) => {
  try {
    console.log('🔍 Checking cart_items table schema...');
    
    // Check if table exists
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'cart_items'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      return res.json({
        exists: false,
        message: 'cart_items table does not exist',
        solution: 'Run the /api/setup-cart-table endpoint'
      });
    }
    
    // Get table structure
    const columns = await pool.query(`
      SELECT 
        column_name, 
        data_type, 
        is_nullable,
        column_default
      FROM information_schema.columns 
      WHERE table_name = 'cart_items' 
      ORDER BY ordinal_position;
    `);
    
    // Get constraints
    const constraints = await pool.query(`
      SELECT 
        tc.constraint_name,
        tc.constraint_type,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM information_schema.table_constraints AS tc 
      LEFT JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      LEFT JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      WHERE tc.table_name = 'cart_items';
    `);
    
    // Count existing cart items
    const count = await pool.query('SELECT COUNT(*) FROM cart_items');
    
    res.json({
      exists: true,
      columns: columns.rows,
      constraints: constraints.rows,
      total_items: parseInt(count.rows[0].count),
      message: 'Table structure looks good'
    });
    
  } catch (err) {
    console.error('❌ Cart schema check error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Debug endpoint: Test add to cart manually
app.post("/api/debug/test-add-to-cart", async (req, res) => {
  const { userId, productId } = req.body;
  
  try {
    console.log('🧪 Testing add to cart...');
    console.log('User ID:', userId);
    console.log('Product ID:', productId);
    
    // Check if user exists
    const userCheck = await pool.query(
      'SELECT id, name FROM users WHERE id = $1',
      [userId]
    );
    
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ 
        error: 'User not found',
        userId: userId 
      });
    }
    
    console.log('✅ User found:', userCheck.rows[0].name);
    
    // Check if product exists
    const productCheck = await pool.query(
      'SELECT id, title, price FROM products WHERE id = $1',
      [productId]
    );
    
    if (productCheck.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Product not found',
        productId: productId 
      });
    }
    
    console.log('✅ Product found:', productCheck.rows[0].title);
    
    // Check if item already in cart
    const existingItem = await pool.query(
      'SELECT * FROM cart_items WHERE user_id = $1 AND product_id = $2',
      [userId, productId]
    );
    
    if (existingItem.rows.length > 0) {
      console.log('ℹ️ Item already in cart, updating quantity...');
      const updated = await pool.query(
        'UPDATE cart_items SET quantity = quantity + 1 WHERE user_id = $1 AND product_id = $2 RETURNING *',
        [userId, productId]
      );
      
      return res.json({
        success: true,
        message: 'Updated existing cart item',
        cart_item: updated.rows[0],
        user: userCheck.rows[0],
        product: productCheck.rows[0]
      });
    }
    
    // Add new item to cart
    console.log('➕ Adding new item to cart...');
    const result = await pool.query(
      'INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *',
      [userId, productId, 1]
    );
    
    console.log('✅ Item added to cart:', result.rows[0]);
    
    res.json({
      success: true,
      message: 'Item added to cart successfully',
      cart_item: result.rows[0],
      user: userCheck.rows[0],
      product: productCheck.rows[0]
    });
    
  } catch (err) {
    console.error('❌ Test add to cart error:', err);
    res.status(500).json({ 
      error: err.message,
      details: err.stack 
    });
  }
});

// Debug endpoint: View all cart items for a user
app.get("/api/debug/cart-items/:userId", async (req, res) => {
  const { userId } = req.params;
  
  try {
    console.log(`🔍 Getting all cart items for user ${userId}`);
    
    const result = await pool.query(`
      SELECT 
        ci.*,
        p.title as product_title,
        p.price as product_price,
        u.name as user_name
      FROM cart_items ci
      LEFT JOIN products p ON ci.product_id = p.id
      LEFT JOIN users u ON ci.user_id = u.id
      WHERE ci.user_id = $1
      ORDER BY ci.created_at DESC
    `, [userId]);
    
    console.log(`✅ Found ${result.rows.length} cart items`);
    
    res.json({
      user_id: userId,
      total_items: result.rows.length,
      items: result.rows
    });
    
  } catch (err) {
    console.error('❌ Get cart items error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Debug endpoint: Clear cart for a user
app.delete("/api/debug/clear-cart/:userId", async (req, res) => {
  const { userId } = req.params;
  
  try {
    console.log(`🗑️ Clearing cart for user ${userId}`);
    
    const result = await pool.query(
      'DELETE FROM cart_items WHERE user_id = $1 RETURNING *',
      [userId]
    );
    
    console.log(`✅ Deleted ${result.rows.length} items`);
    
    res.json({
      success: true,
      message: `Cleared ${result.rows.length} items from cart`,
      deleted_items: result.rows
    });
    
  } catch (err) {
    console.error('❌ Clear cart error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Enhanced add to cart with better logging
app.post("/api/users/:userId/cart-enhanced", authenticateToken, async (req, res) => {
  const { userId } = req.params;
  const { product_id, quantity = 1 } = req.body;

  console.log('='.repeat(50));
  console.log('🛒 ADD TO CART REQUEST');
  console.log('User ID:', userId);
  console.log('Product ID:', product_id);
  console.log('Quantity:', quantity);
  console.log('Auth User ID:', req.user.id);
  console.log('='.repeat(50));

  try {
    // Validate user authorization
    if (parseInt(userId) !== req.user.id) {
      console.log('❌ User ID mismatch');
      return res.status(403).json({ error: 'Unauthorized' });
    }

    // Validate input
    if (!product_id) {
      console.log('❌ Missing product_id');
      return res.status(400).json({ error: 'Product ID is required' });
    }

    // Check if product exists
    const productCheck = await pool.query(
      'SELECT id, title, price FROM products WHERE id = $1',
      [product_id]
    );

    if (productCheck.rows.length === 0) {
      console.log('❌ Product not found:', product_id);
      return res.status(404).json({ error: 'Product not found' });
    }

    console.log('✅ Product found:', productCheck.rows[0].title);

    // Check if item already in cart
    const existingItem = await pool.query(
      'SELECT id, quantity FROM cart_items WHERE user_id = $1 AND product_id = $2',
      [userId, product_id]
    );

    let result;
    if (existingItem.rows.length > 0) {
      console.log('📝 Updating existing cart item...');
      result = await pool.query(
        'UPDATE cart_items SET quantity = quantity + $1, updated_at = NOW() WHERE user_id = $2 AND product_id = $3 RETURNING *',
        [quantity, userId, product_id]
      );
      console.log('✅ Cart item updated');
    } else {
      console.log('➕ Adding new cart item...');
      result = await pool.query(
        'INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *',
        [userId, product_id, quantity]
      );
      console.log('✅ Cart item added');
    }

    console.log('Result:', result.rows[0]);
    console.log('='.repeat(50));

    res.status(201).json({
      success: true,
      message: 'Item added to cart',
      cart_item: result.rows[0],
      product: productCheck.rows[0]
    });

  } catch (err) {
    console.error('❌ Add to cart error:', err);
    console.error('Stack trace:', err.stack);
    console.log('='.repeat(50));
    
    if (err.code === '23503') {
      return res.status(400).json({ 
        error: 'Invalid product or user',
        details: 'Foreign key constraint violation'
      });
    }
    
    res.status(500).json({ 
      error: 'Server error: ' + err.message,
      details: err.stack
    });
  }
});

// Test all cart functionality
app.get("/api/debug/test-cart-flow/:userId", async (req, res) => {
  const { userId } = req.params;
  
  try {
    console.log('🧪 TESTING COMPLETE CART FLOW');
    const results = {
      steps: [],
      success: true
    };
    
    // Step 1: Check user exists
    const userCheck = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
    results.steps.push({
      step: 1,
      name: 'User Check',
      success: userCheck.rows.length > 0,
      data: userCheck.rows[0] || null
    });
    
    if (userCheck.rows.length === 0) {
      results.success = false;
      return res.json(results);
    }
    
    // Step 2: Get first product
    const productCheck = await pool.query('SELECT * FROM products LIMIT 1');
    results.steps.push({
      step: 2,
      name: 'Product Check',
      success: productCheck.rows.length > 0,
      data: productCheck.rows[0] || null
    });
    
    if (productCheck.rows.length === 0) {
      results.success = false;
      return res.json(results);
    }
    
    const testProduct = productCheck.rows[0];
    
    // Step 3: Clear existing cart items for this test
    await pool.query('DELETE FROM cart_items WHERE user_id = $1', [userId]);
    results.steps.push({
      step: 3,
      name: 'Clear Cart',
      success: true
    });
    
    // Step 4: Add item to cart
    const addResult = await pool.query(
      'INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *',
      [userId, testProduct.id, 1]
    );
    results.steps.push({
      step: 4,
      name: 'Add to Cart',
      success: addResult.rows.length > 0,
      data: addResult.rows[0]
    });
    
    // Step 5: Retrieve cart items
    const cartCheck = await pool.query(
      'SELECT * FROM cart_items WHERE user_id = $1',
      [userId]
    );
    results.steps.push({
      step: 5,
      name: 'Retrieve Cart',
      success: cartCheck.rows.length > 0,
      data: cartCheck.rows
    });
    
    results.final_cart_count = cartCheck.rows.length;
    results.message = results.success ? 'All tests passed!' : 'Some tests failed';
    
    res.json(results);
    
  } catch (err) {
    console.error('❌ Cart flow test error:', err);
    res.status(500).json({ 
      error: err.message,
      stack: err.stack
    });
  }
});

app.post("/api/fix-messaging-system", async (req, res) => {
  try {
    console.log('🔧 Fixing messaging system...');

    // 1. Drop and recreate conversations table
    await pool.query('DROP TABLE IF EXISTS messages CASCADE');
    await pool.query('DROP TABLE IF EXISTS conversation_participants CASCADE');
    await pool.query('DROP TABLE IF EXISTS conversations CASCADE');
    console.log('✅ Dropped old tables');

    // 2. Create conversations table
    await pool.query(`
      CREATE TABLE conversations (
        id SERIAL PRIMARY KEY,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✅ Created conversations table');

    // 3. Create conversation_participants table
    await pool.query(`
      CREATE TABLE conversation_participants (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        joined_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(conversation_id, user_id)
      )
    `);
    console.log('✅ Created conversation_participants table');

    // 4. Create messages table with proper structure
    await pool.query(`
      CREATE TABLE messages (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        message_text TEXT NOT NULL,
        sent_at TIMESTAMP DEFAULT NOW(),
        read_at TIMESTAMP NULL
      )
    `);
    console.log('✅ Created messages table');

    // 5. Create indexes for better performance
    await pool.query(`
      CREATE INDEX idx_messages_conversation ON messages(conversation_id, sent_at DESC);
      CREATE INDEX idx_conv_participants_user ON conversation_participants(user_id);
      CREATE INDEX idx_messages_sender ON messages(sender_id);
    `);
    console.log('✅ Created indexes');

    // 6. Get existing users to create test conversations
    const users = await pool.query('SELECT id, name FROM users ORDER BY id LIMIT 5');
    
    if (users.rows.length >= 2) {
      console.log('📝 Creating sample conversations...');
      
      // Create test conversations between existing users
      for (let i = 0; i < users.rows.length - 1; i++) {
        const user1 = users.rows[i];
        const user2 = users.rows[i + 1];
        
        // Create conversation
        const conv = await pool.query(
          'INSERT INTO conversations (created_at, updated_at) VALUES (NOW(), NOW()) RETURNING id'
        );
        const convId = conv.rows[0].id;
        
        // Add participants
        await pool.query(
          'INSERT INTO conversation_participants (conversation_id, user_id) VALUES ($1, $2), ($1, $3)',
          [convId, user1.id, user2.id]
        );
        
        // Add a sample message
        await pool.query(
          'INSERT INTO messages (conversation_id, sender_id, message_text, sent_at) VALUES ($1, $2, $3, NOW())',
          [convId, user1.id, `Hi ${user2.name}! This is a test message.`]
        );
        
        console.log(`✅ Created conversation ${convId} between ${user1.name} and ${user2.name}`);
      }
    }

    res.json({ 
      success: true, 
      message: "Messaging system fixed successfully",
      users_count: users.rows.length,
      sample_conversations_created: users.rows.length - 1
    });
  } catch (err) {
    console.error("❌ Fix messaging system error:", err);
    res.status(500).json({ error: "Fix failed: " + err.message });
  }
});

app.get("/api/debug/messaging-tables", async (req, res) => {
  try {
    console.log('🔍 Checking messaging tables structure...');
    
    // Check if tables exist
    const tablesCheck = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
        AND table_name IN ('conversations', 'conversation_participants', 'messages')
      ORDER BY table_name
    `);
    
    const existingTables = tablesCheck.rows.map(row => row.table_name);
    console.log('Existing tables:', existingTables);
    
    const results = {
      tables_exist: {
        conversations: existingTables.includes('conversations'),
        conversation_participants: existingTables.includes('conversation_participants'),
        messages: existingTables.includes('messages')
      },
      table_details: {}
    };
    
    // Get structure of each table if it exists
    for (const tableName of ['conversations', 'conversation_participants', 'messages']) {
      if (existingTables.includes(tableName)) {
        const columns = await pool.query(`
          SELECT 
            column_name, 
            data_type, 
            is_nullable,
            column_default
          FROM information_schema.columns 
          WHERE table_name = $1
          ORDER BY ordinal_position
        `, [tableName]);
        
        const count = await pool.query(`SELECT COUNT(*) FROM ${tableName}`);
        
        results.table_details[tableName] = {
          columns: columns.rows,
          row_count: parseInt(count.rows[0].count)
        };
      }
    }
    
    // Get sample data from each table
    if (results.tables_exist.conversations) {
      const sampleConv = await pool.query('SELECT * FROM conversations LIMIT 3');
      results.sample_conversations = sampleConv.rows;
    }
    
    if (results.tables_exist.conversation_participants) {
      const samplePart = await pool.query(`
        SELECT cp.*, u.name as user_name 
        FROM conversation_participants cp
        LEFT JOIN users u ON cp.user_id = u.id
        LIMIT 5
      `);
      results.sample_participants = samplePart.rows;
    }
    
    if (results.tables_exist.messages) {
      const sampleMsg = await pool.query(`
        SELECT m.*, u.name as sender_name 
        FROM messages m
        LEFT JOIN users u ON m.sender_id = u.id
        LIMIT 5
      `);
      results.sample_messages = sampleMsg.rows;
    }
    
    // Check conversation 3 specifically
    if (results.tables_exist.conversations) {
      const conv3 = await pool.query('SELECT * FROM conversations WHERE id = 3');
      results.conversation_3 = {
        exists: conv3.rows.length > 0,
        data: conv3.rows[0] || null
      };
      
      if (conv3.rows.length > 0) {
        const conv3Participants = await pool.query(`
          SELECT cp.*, u.name as user_name 
          FROM conversation_participants cp
          LEFT JOIN users u ON cp.user_id = u.id
          WHERE cp.conversation_id = 3
        `);
        results.conversation_3.participants = conv3Participants.rows;
        
        const conv3Messages = await pool.query(`
          SELECT m.*, u.name as sender_name 
          FROM messages m
          LEFT JOIN users u ON m.sender_id = u.id
          WHERE m.conversation_id = 3
          ORDER BY m.sent_at ASC
        `);
        results.conversation_3.messages = conv3Messages.rows;
      }
    }
    
    console.log('✅ Debug check complete');
    res.json(results);
    
  } catch (err) {
    console.error('❌ Debug check error:', err);
    res.status(500).json({ 
      error: err.message,
      stack: err.stack 
    });
  }
});

app.get("/api/debug/conversation/:id", async (req, res) => {
  const { id } = req.params;
  
  try {
    console.log(`🔍 Checking conversation ${id}...`);
    
    // Check conversation exists
    const conv = await pool.query('SELECT * FROM conversations WHERE id = $1', [id]);
    
    if (conv.rows.length === 0) {
      return res.json({
        exists: false,
        message: `Conversation ${id} does not exist`
      });
    }
    
    // Get participants
    const participants = await pool.query(`
      SELECT cp.user_id, u.name, u.email 
      FROM conversation_participants cp
      JOIN users u ON cp.user_id = u.id
      WHERE cp.conversation_id = $1
    `, [id]);
    
    // Get messages
    const messages = await pool.query(`
      SELECT 
        m.id, 
        m.sender_id, 
        m.message_text, 
        m.sent_at,
        u.name as sender_name
      FROM messages m
      LEFT JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
      ORDER BY m.sent_at ASC
    `, [id]);
    
    res.json({
      exists: true,
      conversation: conv.rows[0],
      participants: participants.rows,
      messages: messages.rows,
      message_count: messages.rows.length
    });
    
  } catch (err) {
    console.error('Error checking conversation:', err);
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/debug/fix-conversation-access/:conversationId/:userId", async (req, res) => {
  const { conversationId, userId } = req.params;
  
  try {
    console.log(`🔧 Fixing access for user ${userId} to conversation ${conversationId}`);
    
    // Check if user exists
    const userCheck = await pool.query('SELECT id, name FROM users WHERE id = $1', [userId]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }
    
    // Check if conversation exists
    const convCheck = await pool.query('SELECT id FROM conversations WHERE id = $1', [conversationId]);
    if (convCheck.rows.length === 0) {
      return res.status(404).json({ error: "Conversation not found" });
    }
    
    // Check if user is already a participant
    const participantCheck = await pool.query(
      'SELECT 1 FROM conversation_participants WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );
    
    if (participantCheck.rows.length > 0) {
      return res.json({
        success: true,
        message: `User ${userId} already has access to conversation ${conversationId}`,
        already_participant: true
      });
    }
    
    // Add user as participant
    await pool.query(
      'INSERT INTO conversation_participants (conversation_id, user_id) VALUES ($1, $2)',
      [conversationId, userId]
    );
    
    console.log(`✅ Added user ${userId} (${userCheck.rows[0].name}) to conversation ${conversationId}`);
    
    res.json({
      success: true,
      message: `Successfully added user ${userId} to conversation ${conversationId}`,
      user: userCheck.rows[0]
    });
    
  } catch (err) {
    console.error('Error fixing conversation access:', err);
    res.status(500).json({ error: err.message });
  }
});

// Payment Methods
app.post("/api/setup-payment-methods", async (req, res) => {
  try {
    console.log('Setting up payment methods support...');

    // 1. Add payment_method column to orders table if it doesn't exist
    await pool.query(`
      DO $$ 
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'orders' AND column_name = 'payment_method'
        ) THEN
          ALTER TABLE orders ADD COLUMN payment_method VARCHAR(50) DEFAULT 'card';
        END IF;
      END $$;
    `);
    console.log('Added payment_method column to orders');

    // 2. Add payment_status column
    await pool.query(`
      DO $$ 
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'orders' AND column_name = 'payment_status'
        ) THEN
          ALTER TABLE orders ADD COLUMN payment_status VARCHAR(50) DEFAULT 'pending';
        END IF;
      END $$;
    `);
    console.log('Added payment_status column to orders');

    // 3. Add payment_reference column for bank transfers and USSD
    await pool.query(`
      DO $$ 
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'orders' AND column_name = 'payment_reference'
        ) THEN
          ALTER TABLE orders ADD COLUMN payment_reference VARCHAR(255);
        END IF;
      END $$;
    `);
    console.log('Added payment_reference column to orders');

    // 4. Add delivery_address column for COD
    await pool.query(`
      DO $$ 
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'orders' AND column_name = 'delivery_address'
        ) THEN
          ALTER TABLE orders ADD COLUMN delivery_address TEXT;
        END IF;
      END $$;
    `);
    console.log('Added delivery_address column to orders');

    // 5. Add phone_number column for COD callbacks
    await pool.query(`
      DO $$ 
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'orders' AND column_name = 'phone_number'
        ) THEN
          ALTER TABLE orders ADD COLUMN phone_number VARCHAR(20);
        END IF;
      END $$;
    `);
    console.log('Added phone_number column to orders');

    res.json({ 
      success: true, 
      message: "Payment methods setup completed successfully" 
    });
  } catch (err) {
    console.error("Setup payment methods error:", err);
    res.status(500).json({ error: "Setup failed: " + err.message });
  }
});

// Seed static products into database
app.post("/api/seed-static-products", async (req, res) => {
  try {
    console.log('🌱 Seeding static products...');

    const staticProducts = [
      {
        id: 1,
        title: 'Fabric and Denim Patchwork Jacket',
        description: 'Beautiful handcrafted jacket made from upcycled fabric and denim patches',
        price: 450,
        category: 'Fashion',
        artisan_id: 2,
      },
      {
        id: 2,
        title: 'Beer Bottle Lamp',
        description: 'Unique lamp crafted from recycled beer bottles',
        price: 380,
        category: 'Home Decor',
        artisan_id: 3,
      },
      {
        id: 3,
        title: 'Sta-Soft Lamp',
        description: 'Creative lamp made from Sta-Soft containers',
        price: 300,
        category: 'Home Decor',
        artisan_id: 10,
      },
      {
        id: 4,
        title: 'Belt Patchwork Bag',
        description: 'Stylish bag made from upcycled leather belts',
        price: 200,
        category: 'Fashion',
        artisan_id: 5,
      },
      {
        id: 5,
        title: 'Denim Patchwork Bag',
        description: 'Trendy tote bag made from denim scraps',
        price: 330,
        category: 'Fashion',
        artisan_id: 7,
      },
      {
        id: 6,
        title: 'Shoelace Table Coasters',
        description: 'Colorful coasters woven from old shoelaces',
        price: 250,
        category: 'Home Decor',
        artisan_id: 11,
      },
      {
        id: 13,
        title: 'Broken China Mosaic',
        description: 'Beautiful mosaic art from broken china pieces',
        price: 250,
        category: 'Home Decor',
        artisan_id: 12,
      },
      {
        id: 14,
        title: 'Bottle Cap Soap Dish',
        description: 'Practical soap dish made from bottle caps',
        price: 200,
        category: 'Home Decor',
        artisan_id: 12,
      },
      {
        id: 15,
        title: 'Shoprite Shower curtain',
        description: 'Unique shower curtain from Shoprite bags',
        price: 200,
        category: 'Home Decor',
        artisan_id: 12,
      },
      {
        id: 16,
        title: 'Cassette Wall Art',
        description: 'Nostalgic wall art made from old cassette tapes',
        price: 650,
        category: 'Home Decor',
        artisan_id: 12,
      },
    ];

    for (const product of staticProducts) {
      // Check if product already exists
      const existing = await pool.query(
        'SELECT id FROM products WHERE id = $1',
        [product.id]
      );

      if (existing.rows.length === 0) {
        // Insert with specific ID
        await pool.query(
          `INSERT INTO products (id, title, description, price, category, artisan_id, created_at)
           VALUES ($1, $2, $3, $4, $5, $6, NOW())
           ON CONFLICT (id) DO NOTHING`,
          [product.id, product.title, product.description, product.price, product.category, product.artisan_id]
        );
        console.log(`✅ Added product: ${product.title}`);
      } else {
        console.log(`⏭️  Skipped existing product: ${product.title}`);
      }
    }

    // Reset sequence to avoid ID conflicts with new products
    await pool.query(`SELECT setval('products_id_seq', (SELECT MAX(id) FROM products))`);

    res.json({
      success: true,
      message: `Seeded ${staticProducts.length} static products`
    });
  } catch (err) {
    console.error("Seed static products error:", err);
    res.status(500).json({ error: "Seed failed: " + err.message });
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

app.post("/test-email", async (req, res) => {
  const { to, subject, message } = req.body;
  
  try {
    const result = await sendEmail({
      to: to || process.env.SENDGRID_FROM_EMAIL,
      subject: subject || 'Test Email from Junk & Gems',
      text: message || 'This is a test email.',
      html: `<h1>Test Email</h1><p>${message || 'This is a test email.'}</p>`
    });
    
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
  console.log(`📧 SendGrid configured: ${process.env.SENDGRID_API_KEY ? 'Yes' : 'No'}`);
});