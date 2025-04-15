# Base oficial com Node + Puppeteer + Chromium
FROM ghcr.io/puppeteer/puppeteer:latest

# Troca o usuário para root (essencial!)
USER root

# Define diretório de trabalho
WORKDIR /app

# Copia o projeto
COPY . .

# Instala dependências como root
RUN yarn install --ignore-scripts || true && yarn install --force --unsafe-perm

# Expõe a porta padrão
EXPOSE 3000

# Comando para iniciar
CMD ["node", "examples/express/index.js"]
