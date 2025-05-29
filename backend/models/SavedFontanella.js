const SavedFontanellaSchema = new Schema({
  userId: String, // o mongoose.Schema.Types.ObjectId se preferisci
  fontanellaId: String
}, { timestamps: true });
