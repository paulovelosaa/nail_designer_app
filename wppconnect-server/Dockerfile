# Usa imagem oficial do Node + Puppeteer
FROM ghcr.io/puppeteer/puppeteer:latest

# Cria diretório de trabalho
WORKDIR /app

# Copia os arquivos
COPY . .

# Instala dependências
RUN yarn install --unsafe-perm

# Expõe a porta que o Railway espera
EXPOSE 3000

# Inicia o servidor (ajustado para environments)
CMD ["node", "wppconnect-server/examples/express/index.js"]
