# Etapa 1 - Imagem Node 20 + Puppeteer compatível
FROM buildkite/puppeteer:20.9.0

# Define diretório de trabalho
WORKDIR /app

# Copia o conteúdo do projeto
COPY . .

# Instala dependências com Yarn
RUN yarn install

# Expõe porta padrão usada no projeto
EXPOSE 3000

# Comando para iniciar o servidor
CMD ["node", "examples/express/index.js"]
