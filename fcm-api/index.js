import express from 'express';
import admin from 'firebase-admin';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Corrige para carregar o JSON direto via fs (compatível com Windows)
const serviceAccountPath = path.join(__dirname, 'firebaseKey.json');
const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

const app = express();
app.use(express.json());
app.use(cors());

// Inicializa o Firebase Admin com a chave lida
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

app.post('/send-notification', async (req, res) => {
  const { token, title, body } = req.body;

  if (!token || !title || !body) {
    return res.status(400).json({ error: 'Campos obrigatórios: token, title, body' });
  }

  const message = {
    token,
    notification: { title, body },
  };

  try {
    const response = await admin.messaging().send(message);
    res.status(200).json({ success: true, response });
  } catch (error) {
    console.error('Erro ao enviar FCM:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`📢 FCM API rodando em http://localhost:${PORT}`);
});
