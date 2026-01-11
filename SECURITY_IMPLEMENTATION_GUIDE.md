# Security Implementation Guide - ELRate

## 🔐 **Current Security Status**

### ✅ **What's Already Secure (Flutter App)**
Your Flutter app is **correctly implemented**:
- ✅ Passwords sent over **HTTPS** (encrypted in transit)
- ✅ No client-side password encryption (correct approach)
- ✅ Proper validation before sending to server

### 🔧 **What Needs to be Updated (Cloud Functions)**
Your Cloud Functions need **bcrypt password hashing**:
- ⚠️ Currently storing passwords in plain text (insecure)
- ✅ Need to hash passwords with bcrypt before storing
- ✅ Need to compare hashed passwords on login

---

## 📡 **Your Deployed Endpoints**

### Signup
```
https://signup-1089993125152.asia-southeast2.run.app
```

### Login
```
https://login-1089993125152.asia-southeast2.run.app
```

---

## 🛠️ **Cloud Function Updates Required**

### **Step 1: Install Required Packages**

In your Cloud Functions directory, run:

```bash
npm install bcrypt jsonwebtoken
```

Add to `package.json`:
```json
{
  "dependencies": {
    "@google-cloud/firestore": "^7.1.0",
    "bcrypt": "^5.1.1",
    "jsonwebtoken": "^9.0.2"
  }
}
```

---

### **Step 2: Update Signup Function**

**File**: `signup/index.js`

```javascript
const functions = require('@google-cloud/functions-framework');
const { Firestore } = require('@google-cloud/firestore');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const firestore = new Firestore();

// IMPORTANT: Store this in environment variables in production
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this';

functions.http('signup', async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(204).send('');
  }

  try {
    const { name, email, password } = req.body;

    // Validate inputs
    if (!name || !email || !password) {
      return res.status(400).json({
        message: 'All fields are required'
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        message: 'Invalid email format'
      });
    }

    // Validate password length
    if (password.length < 6) {
      return res.status(400).json({
        message: 'Password must be at least 6 characters'
      });
    }

    // Check if user already exists
    const existingUsers = await firestore
      .collection('users')
      .where('email', '==', email)
      .get();

    if (!existingUsers.empty) {
      return res.status(400).json({
        message: 'Email already registered'
      });
    }

    // ⭐ HASH PASSWORD WITH BCRYPT (10 rounds of salting)
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user with hashed password
    const userRef = await firestore.collection('users').add({
      name: name,
      email: email,
      password: hashedPassword,  // ⭐ Store HASHED password, never plain text!
      createdAt: Firestore.Timestamp.now(),
      updatedAt: Firestore.Timestamp.now()
    });

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: userRef.id,
        email: email
      },
      JWT_SECRET,
      { expiresIn: '24h' }  // Token expires in 24 hours
    );

    // Return success response
    return res.status(201).json({
      token: token,
      userId: userRef.id,
      name: name,
      email: email,
      message: 'User created successfully'
    });

  } catch (error) {
    console.error('Signup error:', error);
    return res.status(500).json({
      message: 'Error during signup: ' + error.message
    });
  }
});
```

---

### **Step 3: Update Login Function**

**File**: `login/index.js`

```javascript
const functions = require('@google-cloud/functions-framework');
const { Firestore } = require('@google-cloud/firestore');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const firestore = new Firestore();

// IMPORTANT: Use the SAME secret as signup
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this';

functions.http('login', async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(204).send('');
  }

  try {
    const { email, password } = req.body;

    // Validate inputs
    if (!email || !password) {
      return res.status(400).json({
        message: 'Email and password are required'
      });
    }

    // Find user by email
    const usersSnapshot = await firestore
      .collection('users')
      .where('email', '==', email)
      .get();

    if (usersSnapshot.empty) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    const userDoc = usersSnapshot.docs[0];
    const user = userDoc.data();

    // ⭐ COMPARE PLAIN PASSWORD WITH HASHED PASSWORD
    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: userDoc.id,
        email: user.email
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    // Return success response
    return res.status(200).json({
      token: token,
      userId: userDoc.id,
      name: user.name,
      email: user.email,
      message: 'Login successful'
    });

  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      message: 'Error during login: ' + error.message
    });
  }
});
```

---

## 🔑 **JWT Secret Key Configuration**

### **For Development (Quick Setup)**
Just use a hardcoded string in the code:
```javascript
const JWT_SECRET = 'upm-elrate-secret-key-2026';
```

### **For Production (Recommended)**
Use environment variables:

```bash
# When deploying to Cloud Run
gcloud functions deploy login \
  --set-env-vars JWT_SECRET=your-super-secret-key-here

gcloud functions deploy signup \
  --set-env-vars JWT_SECRET=your-super-secret-key-here
```

---

## 🚀 **Deployment Commands**

### **Deploy Signup Function**
```bash
cd signup
gcloud functions deploy signup \
  --runtime nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --region asia-southeast2
```

### **Deploy Login Function**
```bash
cd login
gcloud functions deploy login \
  --runtime nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --region asia-southeast2
```

---

## 🧪 **Testing the Updated Functions**

### **Test Signup**
```bash
curl -X POST https://signup-1089993125152.asia-southeast2.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@upm.edu.my",
    "password": "test123"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "abc123",
  "name": "Test User",
  "email": "test@upm.edu.my",
  "message": "User created successfully"
}
```

### **Test Login**
```bash
curl -X POST https://login-1089993125152.asia-southeast2.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@upm.edu.my",
    "password": "test123"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "abc123",
  "name": "Test User",
  "email": "test@upm.edu.my",
  "message": "Login successful"
}
```

---

## 🔐 **Security Features Implemented**

| Feature | Implementation | Status |
|---------|---------------|--------|
| **HTTPS Encryption** | Automatic with Cloud Run | ✅ Built-in |
| **Password Hashing** | bcrypt with 10 rounds | ✅ After update |
| **JWT Tokens** | Signed with secret key | ✅ After update |
| **Token Expiration** | 24 hours | ✅ After update |
| **Input Validation** | Email format, password length | ✅ After update |
| **Duplicate Check** | Email uniqueness | ✅ After update |
| **CORS Enabled** | Cross-origin requests | ✅ After update |

---

## 📋 **Firestore Database Structure**

### **Users Collection**
```javascript
{
  "users": {
    "userId123": {
      "name": "Ahmad bin Ali",
      "email": "ahmad@upm.edu.my",
      "password": "$2b$10$xYz...",  // Bcrypt hashed password
      "createdAt": Timestamp,
      "updatedAt": Timestamp
    }
  }
}
```

**⚠️ NEVER store plain passwords!** Always the bcrypt hash.

---

## 🛡️ **How bcrypt Works**

### **During Signup**
```
1. User enters: "mypassword123"
2. Bcrypt generates salt (random string)
3. Bcrypt hashes: password + salt → "$2b$10$AbC..."
4. Store in database: "$2b$10$AbC..." (60 characters)
```

### **During Login**
```
1. User enters: "mypassword123"
2. Fetch from database: "$2b$10$AbC..."
3. Bcrypt extracts salt from stored hash
4. Bcrypt hashes entered password with same salt
5. Compare: new hash === stored hash
6. If match → Login success!
```

**Why it's secure:**
- ⭐ Same password → Different hash each time (because of random salt)
- ⭐ One-way encryption (can't decrypt back to plain password)
- ⭐ Computationally expensive (prevents brute force attacks)

---

## ✅ **Checklist Before Going to Production**

### **Cloud Functions**
- [ ] Install bcrypt and jsonwebtoken packages
- [ ] Update signup function with password hashing
- [ ] Update login function with password comparison
- [ ] Set JWT_SECRET as environment variable
- [ ] Deploy updated functions
- [ ] Test both endpoints
- [ ] Enable Cloud Armor (DDoS protection)
- [ ] Set up rate limiting

### **Flutter App**
- [ ] Update API URLs in `auth_service.dart` (already done ✅)
- [ ] Switch from `mockLogin` to real `login` API
- [ ] Switch from `mockSignup` to real `signup` API
- [ ] Test authentication flow
- [ ] Implement token refresh (optional)
- [ ] Add biometric auth (optional)

### **Database Security**
- [ ] Set up Firestore security rules
- [ ] Ensure passwords are hashed (not plain text)
- [ ] Create indexes for email queries
- [ ] Enable backup and recovery

---

## 📚 **Additional Security Recommendations**

### **1. Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can only read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### **2. Rate Limiting**
Add to Cloud Functions:
```javascript
// Limit to 5 login attempts per minute
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 5 // limit each IP to 5 requests per windowMs
});
```

### **3. Account Lockout**
After 5 failed login attempts, temporarily lock the account.

### **4. Email Verification**
Send verification email after signup (using SendGrid/Firebase Auth).

---

## 🎓 **Learning Resources**

- [bcrypt Documentation](https://www.npmjs.com/package/bcrypt)
- [JWT.io - JSON Web Tokens](https://jwt.io)
- [Google Cloud Functions Security](https://cloud.google.com/functions/docs/securing)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)

---

## 📞 **Support**

If you encounter issues:
1. Check Cloud Function logs: `gcloud functions logs read <function-name>`
2. Test with curl commands above
3. Verify JWT_SECRET is the same in both functions
4. Check Firestore permissions

---

**Version**: 2.0.0 - Secure Authentication
**Last Updated**: January 2026
**Status**: Ready for Production Deployment

**🔒 Stay Secure! 🔒**
