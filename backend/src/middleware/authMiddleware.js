const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET;

const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.split(' ')[1]; 
  if (!token) return res.status(401).json({ message: 'Access denied, token missing.' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid token.' });
    req.user = user; 
    next();
  });
};

module.exports = { authMiddleware };