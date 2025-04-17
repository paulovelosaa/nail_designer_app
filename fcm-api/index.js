import express from 'express';
import admin from 'firebase-admin';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());

// 🔐 Carrega o conteúdo do firebaseKey.json da variável de ambiente
const firebaseKey = process.env.FIREBASE_CREDENTIAL;

if (!firebaseKey) {
  throw new Error('Variável de ambiente FIREBASE_CREDENTIAL não definida.');
}

const serviceAccount = JSON.parse(firebaseKey);

// Inicializa o Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Rota para envio de notificação
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

// Inicia o servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`📢 FCM API rodando em http://localhost:${PORT}`);
});
