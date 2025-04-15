# Base oficial com Node + Puppeteer + Chromium
FROM ghcr.io/puppeteer/puppeteer:latest

# Define diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Instala dependências do Node.js com permissões elevadas
RUN yarn install --unsafe-perm

# Expõe a porta padrão do servidor
EXPOSE 3000

# Comando que inicia o servidor (ajuste se necessário)
CMD ["node", "examples/express/index.js"]
