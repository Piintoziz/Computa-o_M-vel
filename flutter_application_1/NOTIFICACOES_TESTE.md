# Sistema de Notificações - Guia de Teste

Este documento explica como testar o sistema de notificações implementado na aplicação.

## 🎯 **Funcionalidades Implementadas**

### 1. **Notificações Locais**
- ✅ Notificações aparecem mesmo com a app fechada
- ✅ Som e vibração
- ✅ Ícone personalizado
- ✅ Título e corpo da mensagem

### 2. **Firebase Cloud Messaging (FCM)**
- ✅ Configuração completa
- ✅ Tokens salvos na base de dados
- ✅ Permissões solicitadas

### 3. **Sistema de Mensagens**
- ✅ Notificações automáticas quando mensagem é enviada
- ✅ Nome do remetente na notificação
- ✅ Texto da mensagem no corpo

## 🧪 **Como Testar**

### **Teste 1: Notificação Local**
1. Abra a aplicação
2. Vá para uma página de mensagens
3. Toque no ícone de notificação (🔔) na barra superior
4. Deve aparecer uma notificação de teste

### **Teste 2: Notificação de Mensagem**
1. Abra a aplicação em dois dispositivos diferentes
2. Faça login com contas diferentes
3. Envie uma mensagem de um dispositivo para o outro
4. O dispositivo destinatário deve receber uma notificação

### **Teste 3: Notificação com App Fechada**
1. Feche completamente a aplicação no dispositivo destinatário
2. Envie uma mensagem do outro dispositivo
3. A notificação deve aparecer mesmo com a app fechada

## 📱 **Configuração Necessária**

### **Android**
- ✅ Permissões adicionadas ao `AndroidManifest.xml`
- ✅ Core library desugaring habilitado
- ✅ FCM service configurado

### **Firebase**
- ✅ `google-services.json` no projeto
- ✅ Cloud Messaging habilitado no Firebase Console
- ✅ Tokens FCM salvos na base de dados

## 🔧 **Estrutura dos Dados**

### **Estrutura da Base de Dados**
```
users/
  {userId}/
    fcmToken: "token_do_dispositivo"
    name: "Nome do Utilizador"

messages/
  {messageId}/
    from: "userId_remetente"
    to: "userId_destinatario"
    text: "Texto da mensagem"
    timestamp: 1234567890
```

## 🚨 **Troubleshooting**

### **Problema: Notificações não aparecem**
**Solução:**
1. Verificar se as permissões foram concedidas
2. Verificar se o `google-services.json` está correto
3. Verificar se o FCM está habilitado no Firebase Console

### **Problema: Notificações só funcionam com app aberta**
**Solução:**
1. Verificar se o FCM service está configurado corretamente
2. Verificar se o background handler está funcionando
3. Testar em dispositivo físico (não emulador)

### **Problema: Tokens não são salvos**
**Solução:**
1. Verificar se o utilizador está autenticado
2. Verificar se a base de dados está acessível
3. Verificar os logs para erros

## 📋 **Logs para Debug**

### **Logs Importantes**
```dart
// Token FCM
print('FCM Token: $token');

// Mensagem recebida
print('Got a message whilst in the foreground!');

// Erro de envio
print('Error sending message notification: $e');
```

## 🎉 **Resultado Esperado**

Quando o sistema estiver funcionando corretamente:

1. **Mensagem enviada** → Notificação aparece no dispositivo destinatário
2. **App fechada** → Notificação ainda aparece
3. **Toque na notificação** → App abre na página de mensagens
4. **Som e vibração** → Notificação é audível e visível

## 🔄 **Próximos Passos**

Para implementação completa em produção:

1. **Firebase Functions**: Criar função para enviar notificações push
2. **Server Key**: Configurar chave do servidor FCM
3. **Analytics**: Adicionar tracking de notificações
4. **Personalização**: Permitir configurações de notificação por utilizador 