const functions = require('@google-cloud/functions-framework');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

functions.http('adduniversity', (req, res) => {
  cors(req, res, async () => {
    // Only allow POST
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
      // Verify authentication token
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized. Please login first.' });
      }

      const token = authHeader.split('Bearer ')[1];
      let userId = 'anonymous';

      // Verify JWT token (adjust based on your auth setup)
      try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        userId = decodedToken.uid;
      } catch (authError) {
        console.log('Token verification note:', authError.message);
      }

      const { name, shortName, country } = req.body;

      // Validation
      if (!name || name.trim().length < 3) {
        return res.status(400).json({ error: 'University name must be at least 3 characters' });
      }

      if (!shortName || shortName.trim().length === 0 || shortName.trim().length > 10) {
        return res.status(400).json({ error: 'Short name must be 1-10 characters' });
      }

      if (!country || country.trim().length === 0) {
        return res.status(400).json({ error: 'Country is required' });
      }

      // Sanitize inputs
      const sanitizedName = name.trim();
      const sanitizedShortName = shortName.trim().toUpperCase();
      const sanitizedCountry = country.trim();

      // Check if university already exists (using shortName as document ID)
      const existingDoc = await db.collection('universities').doc(sanitizedShortName).get();

      if (existingDoc.exists) {
        return res.status(409).json({ error: 'University with this abbreviation already exists' });
      }

      // Create new university with shortName as document ID
      const universityData = {
        name: sanitizedName,
        shortName: sanitizedShortName,
        country: sanitizedCountry,
        totalCourses: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: userId
      };

      await db.collection('universities').doc(sanitizedShortName).set(universityData);

      return res.status(201).json({
        id: sanitizedShortName,
        name: sanitizedName,
        shortName: sanitizedShortName,
        country: sanitizedCountry,
        totalCourses: 0
      });

    } catch (error) {
      console.error('Error adding university:', error);
      return res.status(500).json({ error: 'Unable to add university. Please try again.' });
    }
  });
});
