// models/User.js
import mongoose from 'mongoose'

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },

  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },

  passwordHash: {
    type: String,
    required: true,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  }
})

// Evita errori in Next.js con hot reload (modelli duplicati)
export default mongoose.models.User || mongoose.model('User', UserSchema)
