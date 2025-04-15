# Etapa 1 - Baixa a imagem Node + Puppeteer compatível
FROM buildkite/puppeteer:latest

# Define diretório de trabalho dentro do container
WORKDIR /app

# Copia tudo do repositório
COPY . .

# Instala dependências do Node.js
RUN yarn install

# Expõe a porta padrão usada pelo WppConnect
EXPOSE 3000

# Comando que inicia o servidor (ajuste conforme o script usado: ex: index.js, server.js, express.js etc)
CMD ["node", "examples/express/index.js"]
