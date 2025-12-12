const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs-extra');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(cors());
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

// Register
app.post('/api/register', async (req, res) => {
  const { username, password } = req.body;
  const users = await fs.readJson(USERS_FILE);

  if (users.find(u => u.username === username)) {
    return res.status(400).json({ error: 'User exists' });
  }

  const newUser = { id: Date.now(), username, password };
  users.push(newUser);
  await fs.writeJson(USERS_FILE, users);
  res.json({ message: 'Registered successfully' });
});

// Login
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  const users = await fs.readJson(USERS_FILE);
  const user = users.find(u => u.username === username && u.password === password);

  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = generateSessionToken();
  const sessions = await fs.readJson(SESSIONS_FILE);
  sessions.push({ token, userId: user.id, username: user.username, created: Date.now() });
  await fs.writeJson(SESSIONS_FILE, sessions);

  res.json({ token, username: user.username });
});

// Logout
app.post('/api/logout', async (req, res) => {
  const token = req.headers['authorization']?.replace('Bearer ', '');
  if (token) {
    const sessions = await fs.readJson(SESSIONS_FILE);
    const updated = sessions.filter(s => s.token !== token);
    await fs.writeJson(SESSIONS_FILE, updated);
  }
  res.json({ message: 'Logged out' });
});

// Middleware for auth
app.use('/api/protected', async (req, res, next) => {
  const token = req.headers['authorization']?.replace('Bearer ', '');
  const userId = await verifySession(token);
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  req.userId = userId;
  next();
});

// Get messages (protected)
app.get('/api/protected/messages', async (req, res) => {
  const messages = await fs.readJson(MESSAGES_FILE);
  res.json(messages);
});

// Send message (protected)
app.post('/api/protected/messages', async (req, res) => {
  const { text } = req.body;
  const messages = await fs.readJson(MESSAGES_FILE);
  const sessions = await fs.readJson(SESSIONS_FILE);
  const session = sessions.find(s => s.token === req.headers['authorization']?.replace('Bearer ', ''));

  const newMessage = {
    id: Date.now(),
    username: session.username,
    text,
    timestamp: new Date().toISOString()
  };
  messages.push(newMessage);
  await fs.writeJson(MESSAGES_FILE, messages.slice(-100)); // Last 100 messages
  res.json(newMessage);
});

app.listen(PORT, () => {
  console.log(`Server: http://localhost:${PORT}`);
  console.log('Endpoints:');
  console.log('POST /api/register');
  console.log('POST /api/login');
  console.log('POST /api/logout');
  console.log('GET/POST /api/protected/messages');
});
