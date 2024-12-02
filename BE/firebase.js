const admin = require('firebase-admin');
const serviceAccount = require('./firebase-admin.json'); // JSON 파일 경로

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
