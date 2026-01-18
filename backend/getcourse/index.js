const functions = require('@google-cloud/functions-framework');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

functions.http('getcourse', (req, res) => {
  cors(req, res, async () => {
    // Only allow GET
    if (req.method !== 'GET') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
      const coursesSnapshot = await db.collection('courses').get();

      const courses = [];
      coursesSnapshot.forEach((doc) => {
        const data = doc.data();
        courses.push({
          id: doc.id,
          name: data.name || '',
          faculty: data.faculty || '',
          facultyShort: data.facultyshort || data.facultyShort || 'Gen',
          description: data.description || '',
          averageRating: data.averageRating || 0,
          totalReviews: data.totalReviews || 0,
          universityId: data.universityId || null,
          universityName: data.universityName || null
        });
      });

      return res.status(200).json(courses);
    } catch (error) {
      console.error('Error fetching courses:', error);
      return res.status(500).json({ error: 'Unable to fetch courses' });
    }
  });
});
