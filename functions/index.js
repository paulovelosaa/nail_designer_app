const functions = require("firebase-functions");
const axios = require("axios");

exports.sendWhatsApp = functions.firestore
    .document("appointments/{appointmentId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      if (before.status === after.status) return null;

      const nome = after.nome;
      const status = after.status;
      const hora = after.hour;
      const date = after.date;
      const phone = after.telefone; // Ex: +5511999999999

      if (!nome || !status || !hora || !date || !phone) return null;

      const text = encodeURIComponent(
          `Olá ${nome}, seu agendamento para ${date} às ${hora} foi ${status}.`,
      );
      const phoneClean = phone.replace("+", "");
      const apiKey = "8624290"; // ✅ Use somente a API key, sem a URL

      const url =
      `https://api.callmebot.com/whatsapp.php?` +
      `phone=${phoneClean}&text=${text}&apikey=${apiKey}`;

      try {
        await axios.get(url);
        console.log(`Mensagem enviada para ${nome}`);
      } catch (error) {
        console.error("Erro ao enviar WhatsApp:", error);
      }

      return null;
    });
