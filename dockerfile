# Utiliser l'image Node officielle
FROM node:18-alpine

# Dossier de travail
WORKDIR /app

# Copier package.json et installer dépendances
COPY package*.json ./
RUN npm install --production

# Copier le reste du code
COPY . .

# Exposer le port
EXPOSE 3000

# Commande de lancement
CMD ["npm", "start"]
