const functions = require('@google-cloud/functions-framework');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// One-time migration: Add universityId to existing courses that don't have it
functions.http('migratecourses', (req, res) => {
  cors(req, res, async () => {
    // Only allow POST
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
      const { universityId } = req.body;

      if (!universityId) {
        return res.status(400).json({ error: 'universityId is required' });
      }

      // Verify university exists
      const universityDoc = await db.collection('universities').doc(universityId).get();
      if (!universityDoc.exists) {
        return res.status(400).json({ error: 'University does not exist' });
      }

      const universityData = universityDoc.data();

      // Get all courses without universityId
      const coursesSnapshot = await db.collection('courses').get();

      let updatedCount = 0;
      let skippedCount = 0;
      const batch = db.batch();

      coursesSnapshot.forEach((doc) => {
        const data = doc.data();
        // Only update courses that don't have universityId
        if (!data.universityId) {
          batch.update(doc.ref, {
            universityId: universityId,
            universityName: universityData.name
          });
          updatedCount++;
        } else {
          skippedCount++;
        }
      });

      if (updatedCount > 0) {
        await batch.commit();
      }

      return res.status(200).json({
        message: 'Migration completed',
        updated: updatedCount,
        skipped: skippedCount,
        universityId: universityId,
        universityName: universityData.name
      });

    } catch (error) {
      console.error('Error migrating courses:', error);
      return res.status(500).json({ error: 'Migration failed. ' + error.message });
    }
  });
});
