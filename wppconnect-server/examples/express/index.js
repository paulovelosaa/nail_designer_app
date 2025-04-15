const express = require('express');
const { create } = require('@wppconnect-team/wppconnect');
const app = express();
const port = 3000;

app.use(express.json());

let client;

create()
  .then((wpp) => {
    client = wpp;
    console.log('✅ Cliente iniciado com sucesso');
  })
  .catch((error) => {
    console.error('❌ Erro ao iniciar o cliente', error);
  });

app.post('/send-message', async (req, res) => {
  const { phone, message } = req.body;

  if (!client) return res.status(500).send('Cliente ainda não está pronto');

  try {
    const result = await client.sendText(`${phone}@c.us`, message);
    res.send(result);
  } catch (error) {
    res.status(500).send(error);
  }
});

app.listen(port, () => {
  console.log(`🚀 Servidor rodando em http://localhost:${port}`);
});
