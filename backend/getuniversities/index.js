const functions = require('@google-cloud/functions-framework');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

functions.http('getuniversities', (req, res) => {
  cors(req, res, async () => {
    // Only allow GET
    if (req.method !== 'GET') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
      const universitiesSnapshot = await db.collection('universities').get();

      const universities = [];
      universitiesSnapshot.forEach((doc) => {
        universities.push({
          id: doc.id,
          ...doc.data()
        });
      });

      return res.status(200).json(universities);
    } catch (error) {
      console.error('Error fetching universities:', error);
      return res.status(500).json({ error: 'Unable to fetch universities' });
    }
  });
});
