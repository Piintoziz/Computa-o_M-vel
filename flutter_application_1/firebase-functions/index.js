const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendMessageNotification = functions.database
  .ref('/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.val();
    const messageId = context.params.messageId;

    // Get message details
    const fromUserId = messageData.from;
    const toUserId = messageData.to;
    const messageText = messageData.text;

    // Don't send notification if user is messaging themselves
    if (fromUserId === toUserId) {
      return null;
    }

    try {
      // Get sender's name
      const senderSnapshot = await admin.database()
        .ref(`/userdata/${fromUserId}/name`)
        .once('value');
      
      const senderName = senderSnapshot.val() || 'Utilizador';

      // Get recipient's FCM token
      const recipientSnapshot = await admin.database()
        .ref(`/users/${toUserId}/fcmToken`)
        .once('value');

      const fcmToken = recipientSnapshot.val();

      if (!fcmToken) {
        console.log('No FCM token found for user:', toUserId);
        return null;
      }

      // Prepare notification message
      const notification = {
        title: `Nova mensagem de ${senderName}`,
        body: messageText,
        sound: 'default',
        badge: '1',
      };

      const data = {
        type: 'message',
        fromUserId: fromUserId,
        toUserId: toUserId,
        messageId: messageId,
        messageText: messageText,
        senderName: senderName,
      };

      // Send FCM notification
      const message = {
        token: fcmToken,
        notification: notification,
        data: data,
        android: {
          priority: 'high',
          notification: {
            channelId: 'messages_channel',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log('Successfully sent message notification:', response);
      
      return response;
    } catch (error) {
      console.error('Error sending message notification:', error);
      return null;
    }
  }); 