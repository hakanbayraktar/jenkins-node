FROM node:12.2.0-alpine
# Mutlak yol kullanarak çalışma dizinini belirtin
WORKDIR /app
# Uygulama dosyalarını kopyalayın
COPY . .
# Bağımlılıkları yükleyin
RUN npm install
# Test komutunu çalıştırın
RUN npm run test
# Uygulama için portu açın
EXPOSE 8000
# Uygulamayı başlatın
CMD ["node", "app.js"]
