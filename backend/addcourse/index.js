const functions = require('@google-cloud/functions-framework');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

functions.http('addcourse', (req, res) => {
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

      try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        userId = decodedToken.uid;
      } catch (authError) {
        console.log('Token verification note:', authError.message);
      }

      const { id, name, faculty, facultyShort, description, universityId } = req.body;

      // Validation
      if (!id || id.trim().length < 3) {
        return res.status(400).json({ error: 'Course code must be at least 3 characters' });
      }

      if (!name || name.trim().length < 3) {
        return res.status(400).json({ error: 'Course name must be at least 3 characters' });
      }

      if (!faculty || faculty.trim().length === 0) {
        return res.status(400).json({ error: 'Faculty is required' });
      }

      if (!facultyShort || facultyShort.trim().length === 0 || facultyShort.trim().length > 10) {
        return res.status(400).json({ error: 'Faculty short name must be 1-10 characters' });
      }

      if (!universityId) {
        return res.status(400).json({ error: 'University is required' });
      }

      // Sanitize inputs
      const sanitizedId = id.trim().toUpperCase();
      const sanitizedName = name.trim();
      const sanitizedFaculty = faculty.trim();
      const sanitizedFacultyShort = facultyShort.trim().toUpperCase();
      const sanitizedDescription = description ? description.trim() : '';

      // Verify university exists
      const universityDoc = await db.collection('universities').doc(universityId).get();
      if (!universityDoc.exists) {
        return res.status(400).json({ error: 'Selected university does not exist' });
      }

      const universityData = universityDoc.data();

      // Check if course already exists (using course code as document ID)
      const existingCourse = await db.collection('courses').doc(sanitizedId).get();

      if (existingCourse.exists) {
        return res.status(409).json({ error: 'Course with this code already exists' });
      }

      // Create new course with course code as document ID (matching existing structure)
      const courseData = {
        name: sanitizedName,
        faculty: sanitizedFaculty,
        facultyshort: sanitizedFacultyShort,  // lowercase to match existing data
        description: sanitizedDescription,
        universityId: universityId,
        universityName: universityData.name,
        averageRating: 0,
        totalReviews: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: userId
      };

      // Use course code as document ID (e.g., "AGR3101")
      await db.collection('courses').doc(sanitizedId).set(courseData);

      // Update university's course count
      await db.collection('universities').doc(universityId).update({
        totalCourses: admin.firestore.FieldValue.increment(1)
      });

      return res.status(201).json({
        id: sanitizedId,
        name: sanitizedName,
        faculty: sanitizedFaculty,
        facultyShort: sanitizedFacultyShort,
        description: sanitizedDescription,
        universityId: universityId,
        universityName: universityData.name,
        averageRating: 0,
        totalReviews: 0
      });

    } catch (error) {
      console.error('Error adding course:', error);
      return res.status(500).json({ error: 'Unable to add course. Please try again.' });
    }
  });
});
