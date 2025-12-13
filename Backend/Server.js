const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs-extra');
const path = require('path');

const app = express();
const PORT = 3000;

// ✅ CORS Configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

app.use(bodyParser.json());

const USERS_FILE = path.join(__dirname, 'users.json');
const MESSAGES_FILE = path.join(__dirname, 'messages.json');
const SESSIONS_FILE = path.join(__dirname, 'sessions.json');

// Create files if missing
if (!fs.existsSync(USERS_FILE)) fs.writeJsonSync(USERS_FILE, []);
if (!fs.existsSync(MESSAGES_FILE)) fs.writeJsonSync(MESSAGES_FILE, []);
if (!fs.existsSync(SESSIONS_FILE)) fs.writeJsonSync(SESSIONS_FILE, []);

// Generate simple session token
function generateSessionToken() {
  return 's_' + Math.random().toString(36).substr(2, 9) + Date.now();
}

// Verify session token
async function verifySession(token) {
  if (!token || !token.startsWith('s_')) return null;
  const sessions = await fs.readJson(SESSIONS_FILE);
  const session = sessions.find(s => s.token === token && Date.now() - s.created < 3600000); // 1hr
  if (!session) return null;
  return session.userId;
}

// ==================== PUBLIC ROUTES (NO AUTH) ====================

// REGISTER
app.post('/api/register', async (req, res) => {
  console.log('📝 Register request:', req.body);
  const { name, dob, email, password } = req.body;

  if (!name || !dob || !email || !password) {
    return res.status(400).json({ error: 'All fields required' });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: 'Password must be 6+ characters' });
  }

  const users = await fs.readJson(USERS_FILE);
  if (users.find(u => u.email === email)) {
    return res.status(400).json({ error: 'Email already registered' });
  }

  const newUser = {
    id: Date.now(),
    name,
    dob,
    email,
    username: email,
    password
  };
  users.push(newUser);
  await fs.writeJson(USERS_FILE, users);
  console.log('✅ User registered:', email);
  res.json({ message: 'Registered successfully', user: newUser });
});

// LOGIN
app.post('/api/login', async (req, res) => {
  console.log('🔐 Login request:', req.body.email);
  const { email, password } = req.body;
  const users = await fs.readJson(USERS_FILE);
  const user = users.find(u => u.email === email && u.password === password);

  if (!user) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }

  const token = generateSessionToken();
  const sessions = await fs.readJson(SESSIONS_FILE);
  sessions.push({
    token,
    userId: user.id,
    username: user.email,
    name: user.name,
    email: user.email,
    dob: user.dob,
    isGuest: false,
    created: Date.now()
  });
  await fs.writeJson(SESSIONS_FILE, sessions);

  console.log('✅ Login successful:', email);
  res.json({
    token,
    username: user.email,
    name: user.name,
    email: user.email,
    dob: user.dob,
    isGuest: false
  });
});

// GUEST LOGIN
app.post('/api/guest', async (req, res) => {
  console.log('👤 Guest login request');
  const token = generateSessionToken();
  const sessions = await fs.readJson(SESSIONS_FILE);
  sessions.push({
    token,
    userId: 'guest_' + Date.now(),
    username: 'Guest',
    name: 'Guest User',
    email: 'guest@example.com',
    dob: 'N/A',
    isGuest: true,
    created: Date.now()
  });
  await fs.writeJson(SESSIONS_FILE, sessions);

  console.log('✅ Guest logged in');
  res.json({
    token,
    username: 'Guest',
    name: 'Guest User',
    email: 'guest@example.com',
    dob: 'N/A',
    isGuest: true
  });
});

// LOGOUT
app.post('/api/logout', async (req, res) => {
  const token = req.headers['authorization']?.replace('Bearer ', '');
  console.log('👋 Logout request');
  if (token) {
    const sessions = await fs.readJson(SESSIONS_FILE);
    const updated = sessions.filter(s => s.token !== token);
    await fs.writeJson(SESSIONS_FILE, updated);
  }
  res.json({ message: 'Logged out' });
});

// ==================== PROTECTED ROUTES (REQUIRE AUTH) ====================

// GET CURRENT USER
app.get('/api/protected/user', async (req, res) => {
  const token = req.headers['authorization']?.replace('Bearer ', '');
  console.log('👤 Get user request, token:', token?.substring(0, 15) + '...');

  const userId = await verifySession(token);
  if (!userId) {
    console.log('❌ Unauthorized - invalid token');
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const sessions = await fs.readJson(SESSIONS_FILE);
  const session = sessions.find(s => s.token === token);

  if (!session) {
    console.log('❌ Session not found');
    return res.status(404).json({ error: 'Session not found' });
  }

  console.log('✅ User found:', session.email);
  res.json({
    name: session.name,
    email: session.email,
    dob: session.dob,
    username: session.username,
    isGuest: session.isGuest || false
  });
});

// GET MESSAGES
app.get('/api/protected/messages', async (req, res) => {
  const token = req.headers['authorization']?.replace('Bearer ', '');
  console.log('💬 Get messages request');

  const userId = await verifySession(token);
  if (!userId) {
    console.log('❌ Unauthorized');
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const messages = await fs.readJson(MESSAGES_FILE);
  console.log('✅ Returning', messages.length, 'messages');
  res.json(messages);
});

// SEND MESSAGE
app.post('/api/protected/messages', async (req, res) => {
  const token = req.headers['authorization']?.replace('Bearer ', '');
  console.log('📤 Send message request');

  const userId = await verifySession(token);
  if (!userId) {
    console.log('❌ Unauthorized');
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const { text, isAI } = req.body;
  const messages = await fs.readJson(MESSAGES_FILE);
  const sessions = await fs.readJson(SESSIONS_FILE);
  const session = sessions.find(s => s.token === token);

  const newMessage = {
    id: Date.now(),
    username: isAI ? 'AI Assistant' : (session?.username || 'Unknown'),
    text,
    isAI: isAI || false,
    timestamp: new Date().toISOString()
  };

  messages.push(newMessage);
  await fs.writeJson(MESSAGES_FILE, messages.slice(-100));

  console.log('✅ Message saved:', isAI ? 'AI' : session?.username);
  res.json(newMessage);
});

// ==================== START SERVER ====================
app.listen(PORT, () => {
  console.log(`✅ Server running on: http://localhost:${PORT}`);
  console.log('\n📌 Available Endpoints:');
  console.log('   POST   /api/register          - Register with name, dob, email, password');
  console.log('   POST   /api/login             - Login with email and password');
  console.log('   POST   /api/guest             - Guest login (no registration)');
  console.log('   POST   /api/logout            - Logout (clears session)');
  console.log('   GET    /api/protected/user    - Get current user info');
  console.log('   GET    /api/protected/messages - Get all messages');
  console.log('   POST   /api/protected/messages - Send a message');
  console.log('\n🌐 CORS enabled for all origins');
  console.log('🔥 Server is ready!\n');
});