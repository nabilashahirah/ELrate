# Critical Backend Security Fixes for Cloud Functions

## ⚠️ CRITICAL: Implement These BEFORE Your Lecturer Tests

Your lecturer will try to hack your backend. Here are the **MUST-HAVE** fixes for your Cloud Functions.

---

## 1. Add Rate Limiting (CRITICAL - Prevents Brute Force)

Install the package:
```bash
cd functions
npm install express-rate-limit
```

Update **EVERY** Cloud Function:

```javascript
const rateLimit = require('express-rate-limit');

// Login endpoint - strict rate limiting
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per 15 minutes
  message: { error: 'Too many login attempts. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Signup endpoint
const signupLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 signups per hour per IP
  message: { error: 'Too many accounts created. Please try again later.' },
});

// Review endpoints
const reviewLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 10, // 10 requests per 5 minutes
  message: { error: 'Too many requests. Please slow down.' },
});

exports.login = async (req, res) => {
  // Apply rate limiting
  loginLimiter(req, res, async () => {
    // Set CORS
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      return res.status(204).send('');
    }

    // Your existing login code...
  });
};
```

---

## 2. Sanitize All Inputs (CRITICAL - Prevents XSS/Injection)

Install sanitization package:
```bash
npm install validator
```

Add this helper function to EVERY Cloud Function file:

```javascript
const validator = require('validator');

// Sanitization helper
function sanitizeInput(input) {
  if (typeof input !== 'string') return input;

  // Remove HTML tags and dangerous characters
  let sanitized = validator.escape(input);
  sanitized = validator.trim(sanitized);

  // Remove script tags explicitly
  sanitized = sanitized.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');

  return sanitized;
}

// Use it on ALL user inputs
exports.addreview = async (req, res) => {
  // ... CORS and rate limiting ...

  try {
    const { courseId, userId, rating, comment, isAnonymous, isRecommended, studentName } = req.body;

    // Sanitize ALL text inputs
    const sanitizedCourseId = sanitizeInput(courseId);
    const sanitizedComment = sanitizeInput(comment);
    const sanitizedStudentName = sanitizeInput(studentName);

    // Validate comment length (prevent DoS via large inputs)
    if (sanitizedComment.length > 1000) {
      return res.status(400).json({ error: 'Comment too long. Maximum 1000 characters.' });
    }

    // Validate rating range
    if (rating < 0 || rating > 5) {
      return res.status(400).json({ error: 'Invalid rating' });
    }

    // Continue with sanitized data...
  } catch (error) {
    return res.status(500).json({ error: 'Server error' }); // Generic error
  }
};
```

---

## 3. Restrict CORS (CRITICAL - Prevents API Abuse)

**STOP using `*` for CORS!** Replace this in ALL functions:

```javascript
// BAD (what you have now):
res.set('Access-Control-Allow-Origin', '*');

// GOOD (restrict to your domain):
const allowedOrigins = [
  'https://yourdomain.com',
  'http://localhost:8080', // For development
];

const origin = req.headers.origin;
if (allowedOrigins.includes(origin)) {
  res.set('Access-Control-Allow-Origin', origin);
} else {
  res.set('Access-Control-Allow-Origin', allowedOrigins[0]);
}

res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
res.set('Access-Control-Max-Age', '86400'); // 24 hours
```

---

## 4. Add Token Expiration (CRITICAL)

Update your login and signup functions:

```javascript
const jwt = require('jsonwebtoken');

// Generate token with expiration
const token = jwt.sign(
  {
    userId: userDoc.id,
    email: userDoc.data().email,
    iat: Math.floor(Date.now() / 1000) // Issued at
  },
  process.env.JWT_SECRET || 'your-secret-key-change-this', // Use environment variable!
  { expiresIn: '24h' } // Token expires in 24 hours
);

// Return token
return res.status(200).json({
  token: token,
  userId: userDoc.id,
  name: userDoc.data().name,
  email: userDoc.data().email,
  expiresIn: 86400 // seconds (24 hours)
});
```

---

## 5. Verify JWT Tokens (CRITICAL)

Add this middleware to ALL protected endpoints:

```javascript
const jwt = require('jsonwebtoken');

// Verify JWT token
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  const token = authHeader.substring(7); // Remove 'Bearer ' prefix

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key-change-this');
    req.user = decoded; // Add user info to request
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired. Please login again.' });
    }
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// Use it in protected endpoints
exports.addreview = async (req, res) => {
  verifyToken(req, res, async () => {
    // ... your review code ...
  });
};
```

---

## 6. Hash Passwords Properly (CRITICAL if storing passwords)

```bash
npm install bcryptjs
```

```javascript
const bcrypt = require('bcryptjs');

// When creating user (signup)
const hashedPassword = await bcrypt.hash(password, 12); // 12 rounds

await admin.firestore().collection('users').doc(email).set({
  name: name,
  email: email,
  password: hashedPassword, // Store hashed, not plain text!
  createdAt: admin.firestore.FieldValue.serverTimestamp()
});

// When logging in
const userDoc = await admin.firestore().collection('users').doc(email).get();
const isValidPassword = await bcrypt.compare(password, userDoc.data().password);

if (!isValidPassword) {
  return res.status(401).json({ error: 'Invalid credentials' }); // Generic message
}
```

---

## 7. Prevent Email Enumeration (MEDIUM Priority)

```javascript
// BAD - reveals if email exists:
if (!userDoc.exists) {
  return res.status(404).json({ error: 'User not found' });
}

// GOOD - generic error:
if (!userDoc.exists) {
  return res.status(401).json({ error: 'Invalid credentials' });
}

// Forgot password - same response regardless:
if (!userDoc.exists) {
  // Don't reveal if email exists
  return res.status(200).json({
    message: 'If this email exists, a reset link has been sent.'
  });
}
```

---

## 8. Add Input Validation (ALL Endpoints)

```javascript
// Email validation
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Password strength (minimum requirements)
function isStrongPassword(password) {
  return password.length >= 8 &&
         /[A-Z]/.test(password) &&  // At least one uppercase
         /[a-z]/.test(password) &&  // At least one lowercase
         /[0-9]/.test(password);    // At least one number
}

// Use in signup:
if (!isValidEmail(email)) {
  return res.status(400).json({ error: 'Invalid email format' });
}

if (!isStrongPassword(password)) {
  return res.status(400).json({
    error: 'Password must be 8+ characters with uppercase, lowercase, and numbers'
  });
}
```

---

## 9. Add Request Size Limits (Prevents DoS)

```javascript
exports.addreview = async (req, res) => {
  // Check request size
  const contentLength = parseInt(req.headers['content-length'] || '0');
  if (contentLength > 10000) { // 10KB limit
    return res.status(413).json({ error: 'Request too large' });
  }

  // Your code...
};
```

---

## 10. Use Environment Variables (CRITICAL)

**NEVER hardcode secrets!**

Create `.env` file (add to .gitignore):
```
JWT_SECRET=your-super-secret-key-minimum-32-characters
DB_PASSWORD=your-db-password
```

Use in code:
```javascript
require('dotenv').config();

const jwtSecret = process.env.JWT_SECRET;
```

In Cloud Functions, set via console:
```bash
firebase functions:config:set jwt.secret="your-secret-key"
```

Access in code:
```javascript
const jwtSecret = functions.config().jwt.secret;
```

---

## 🎯 Quick Implementation Checklist

Apply to **EVERY** Cloud Function:

- [ ] ✅ Add rate limiting
- [ ] ✅ Sanitize all inputs
- [ ] ✅ Restrict CORS (no more `*`)
- [ ] ✅ Add token expiration
- [ ] ✅ Verify JWT on protected endpoints
- [ ] ✅ Hash passwords with bcrypt
- [ ] ✅ Generic error messages (no details)
- [ ] ✅ Validate email format
- [ ] ✅ Validate password strength
- [ ] ✅ Limit request sizes
- [ ] ✅ Use environment variables

---

## 🚨 What Your Lecturer Will Try

1. **Brute force login** → Blocked by rate limiting
2. **SQL/NoSQL injection** → Blocked by sanitization
3. **XSS attacks via reviews** → Blocked by sanitization
4. **Token replay** → Blocked by expiration
5. **CSRF** → Blocked by CORS + token verification
6. **Email enumeration** → Blocked by generic errors
7. **API abuse** → Blocked by rate limiting
8. **Large payload DoS** → Blocked by size limits

---

## 📚 Test Your Security

Before demo, test with:
```bash
# Brute force test
for i in {1..10}; do
  curl -X POST https://your-login-url -d '{"email":"test@test.com","password":"wrong"}'
done
# Should block after 5 attempts

# XSS test
curl -X POST https://your-review-url -d '{"comment":"<script>alert(1)</script>"}'
# Should sanitize the script tag
```

---

## ⏰ Priority Order

1. **NOW (Before Demo):**
   - Rate limiting on login/signup
   - Input sanitization
   - Generic error messages
   - Restrict CORS

2. **If You Have Time:**
   - Token expiration
   - Password hashing
   - Request size limits

---

Good luck! Your lecturer will be impressed if you have these in place. 🔒
