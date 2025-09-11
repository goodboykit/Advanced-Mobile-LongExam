const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const getUsers = async (req, res) => {
  try {
    const users = await User.find({}, '-password');
    res.json({ users });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createUser = async (req, res) => {
  try {
    const { 
      firstName, 
      lastName, 
      age, 
      gender, 
      contactNumber, 
      email, 
      username, 
      password, 
      address 
    } = req.body;

    // Input validation
    if (!firstName || !lastName || !age || !gender || !contactNumber || !email || !username || !password || !address) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    // Email validation
    const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ message: 'Invalid email format' });
    }

    // Age validation
    if (age < 18 || age > 100) {
      return res.status(400).json({ message: 'Age must be between 18 and 100' });
    }

    // Password strength validation
    if (password.length < 8) {
      return res.status(400).json({ message: 'Password must be at least 8 characters long' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ 
      $or: [{ email }, { username }] 
    });
    if (existingUser) {
      if (existingUser.email === email) {
        return res.status(409).json({ message: 'Email already registered' });
      }
      if (existingUser.username === username) {
        return res.status(409).json({ message: 'Username already taken' });
      }
    }

    // Sanitize and prepare data
    const userData = {
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      age: parseInt(age),
      gender: gender.trim(),
      contactNumber: contactNumber.trim(),
      email: email.trim().toLowerCase(),
      username: username.trim().toLowerCase(),
      address: address.trim(),
      isActive: true,
      type: 'user'
    };

    const hashedPassword = await bcrypt.hash(password, 12);
    
    const user = await User.create({ 
      ...userData, 
      password: hashedPassword 
    });

    // Generate token for immediate login after registration
    const token = jwt.sign(
      { id: user._id, email: user.email, type: user.type },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );
    
    // Return user data without password
    const userResponse = {
      _id: user._id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      username: user.username,
      type: user.type,
      token
    };
    
    res.status(201).json(userResponse);
  } catch (error) {
    if (error.code === 11000) {
      const field = Object.keys(error.keyValue)[0];
      return res.status(409).json({ message: `${field} already exists` });
    }
    res.status(400).json({ message: error.message });
  }
};

const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    if (!user.isActive) {
      return res
        .status(403)
        .json({ message: 'Your account is inactive. Please contact support.' });
    }
    
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    const token = jwt.sign(
      { id: user._id, email: user.email, type: user.type },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );
    
    res.json({
      message: 'Login successful',
      token,
      type: user.type,
      firstName: user.firstName,
      lastName: user.lastName,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getUsers, createUser, loginUser };