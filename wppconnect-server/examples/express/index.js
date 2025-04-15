const express = require('express');
const { create } = require('@wppconnect-team/wppconnect');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

let client;

// Rota raiz (GET /)
app.get('/', (req, res) => {
  res.send('🚀 Servidor do WppConnect rodando com sucesso!');
});

// Inicializa o cliente do WppConnect
create({
  headless: true,
  browserArgs: ['--no-sandbox', '--disable-setuid-sandbox'],
  // Mostra QR Code no navegador ao iniciar
  statusFind: (statusSession, session) => {
    if (['isLogged', 'qrReadSuccess'].includes(statusSession)) return;

    // Abre automaticamente no navegador padrão
    import('open').then(open => {
      open.default(`http://localhost:${port}`);
    });
  }
})
  .then((wpp) => {
    client = wpp;
    console.log('✅ Cliente iniciado com sucesso');
  })
  .catch((error) => {
    console.error('❌ Erro ao iniciar o cliente:', error);
  });

// Rota para enviar mensagens
app.post('/send-message', async (req, res) => {
  const { phone, message } = req.body;

  if (!client) {
    console.error('⚠️ Cliente ainda não está pronto');
    return res.status(500).send('Cliente ainda não está pronto');
  }

  try {
    const result = await client.sendText(`${phone}@c.us`, message);
    console.log(`✅ Mensagem enviada para ${phone}`);
    res.send(result);
  } catch (error) {
    console.error('❌ Erro ao enviar mensagem:', error);
    res.status(500).send(error);
  }
});

// Inicia o servidor
app.listen(port, () => {
  console.log(`🚀 Servidor rodando na porta ${port}`);
});
