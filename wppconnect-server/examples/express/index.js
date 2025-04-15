const express = require('express');
const { create } = require('@wppconnect-team/wppconnect');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

let client = null;
let clientReady = false;
const pendingMessages = [];

// Rota raiz
app.get('/', (req, res) => {
  res.send('🚀 Servidor do WppConnect está rodando!');
});

// Health Check
app.get('/health', (req, res) => {
  if (clientReady) {
    res.status(200).send('READY');
  } else {
    res.status(503).send('Client not ready');
  }
});

// Inicializa cliente WppConnect
create({
  headless: true,
  browserArgs: ['--no-sandbox', '--disable-setuid-sandbox'],
})
  .then((wpp) => {
    client = wpp;
    clientReady = true;
    console.log('✅ Cliente WppConnect iniciado com sucesso');

    // Processa mensagens pendentes
    while (pendingMessages.length > 0) {
      const { phone, message, res } = pendingMessages.shift();
      sendMessageNow(phone, message, res);
    }
  })
  .catch((error) => {
    console.error('❌ Erro ao iniciar cliente:', error);
  });

// Função para envio imediato
async function sendMessageNow(phone, message, res) {
  try {
    const result = await client.sendText(`${phone}@c.us`, message);
    console.log(`📤 Mensagem enviada para ${phone}`);
    res.status(200).send(result);
  } catch (error) {
    console.error('❌ Erro ao enviar mensagem:', error);
    res.status(500).send({ error: 'Falha ao enviar mensagem', detalhes: error });
  }
}

// Rota para envio
app.post('/send-message', (req, res) => {
  const { phone, message } = req.body;

  if (!phone || !message) {
    return res.status(400).send({ error: 'Campos phone e message são obrigatórios' });
  }

  if (!clientReady) {
    console.warn(`⏳ Cliente ainda não está pronto. Enfileirando mensagem para ${phone}`);
    pendingMessages.push({ phone, message, res });
    return;
  }

  sendMessageNow(phone, message, res);
});

// Inicia o servidor
app.listen(port, () => {
  console.log(`🚀 Servidor rodando na porta ${port}`);
});
