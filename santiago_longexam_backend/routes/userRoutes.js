const express = require('express');
const { getUsers, getAllUsersForChat, createUser, loginUser, updateUsername, changePassword, deleteAccount } = require('../controllers/userController');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

// Public routes
router.route('/').get(getUsers).post(createUser);
router.post('/login', loginUser);
router.get('/chat-users', getAllUsersForChat);

// Protected routes (require authentication)
router.put('/update-username', authMiddleware, updateUsername);
router.put('/change-password', authMiddleware, changePassword);
router.delete('/delete-account', authMiddleware, deleteAccount);

module.exports = router;