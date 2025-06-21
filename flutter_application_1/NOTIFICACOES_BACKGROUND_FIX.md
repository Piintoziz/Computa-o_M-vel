# Correção das Notificações em Background

## Problemas Identificados e Soluções Implementadas

### 1. Permissões Android
**Problema**: Faltavam permissões essenciais para notificações em background.

**Solução**: Adicionadas as seguintes permissões no `AndroidManifest.xml`:
- `POST_NOTIFICATIONS` - Para Android 13+ (API 33+)
- `WAKE_LOCK` - Para manter o dispositivo acordado
- `VIBRATE` - Para vibração das notificações
- `RECEIVE_BOOT_COMPLETED` - Para receber notificações após reinicialização

### 2. Configuração do Firebase Messaging
**Problema**: O Firebase Messaging não estava configurado corretamente para background.

**Solução**: 
- Adicionado o handler de background no `main.dart`
- Configurado o serviço do Firebase Messaging no `AndroidManifest.xml`
- Adicionadas meta-datas para configuração padrão das notificações

### 3. Inicialização das Notificações Locais
**Problema**: As notificações locais não eram inicializadas no background handler.

**Solução**: 
- Movido o background handler para o `main.dart` como função top-level
- Adicionada inicialização das notificações locais no background handler
- Removida duplicação de código

### 4. Configuração do Canal de Notificações
**Problema**: O canal de notificações não estava configurado corretamente.

**Solução**:
- Criado arquivo `colors.xml` para definir cores das notificações
- Criado arquivo `strings.xml` para definir strings do canal
- Configurado canal com alta prioridade e vibração

### 5. Dependências Android
**Problema**: Faltavam dependências específicas do Firebase.

**Solução**: Adicionadas no `build.gradle.kts`:
- `firebase-messaging:23.4.0`
- `firebase-analytics:21.5.0`
- `multidex:2.0.1`

## Como Testar

### 1. Compilar e Instalar
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### 2. Verificar Permissões
- Abrir a app
- Verificar se as permissões de notificação foram concedidas
- Se não, ir em Configurações > Apps > Hello Farmer > Notificações e ativar

### 3. Testar Notificações
- Fechar completamente a app (remover da memória recente)
- Enviar uma mensagem através do Firebase Functions
- Verificar se a notificação aparece

### 4. Verificar Logs
```bash
flutter logs
```

## Configurações Importantes

### Android 13+ (API 33+)
- A permissão `POST_NOTIFICATIONS` é obrigatória
- O usuário deve conceder permissão manualmente

### Configurações do Dispositivo
- Verificar se as notificações estão ativadas nas configurações do sistema
- Verificar se a app não está em "Modo de economia de bateria"
- Verificar se a app não está em "Otimização de bateria"

### Firebase Functions
- O arquivo `firebase-functions/index.js` já está configurado corretamente
- As notificações são enviadas automaticamente quando uma mensagem é criada

## Troubleshooting

### Se as notificações ainda não funcionam:

1. **Verificar FCM Token**:
   - Abrir a app e verificar os logs para o FCM token
   - Verificar se o token está salvo no Firebase Database

2. **Verificar Permissões**:
   - Ir em Configurações > Apps > Hello Farmer > Permissões
   - Verificar se todas as permissões estão concedidas

3. **Verificar Configurações do Sistema**:
   - Configurações > Notificações > Hello Farmer
   - Verificar se está ativado

4. **Testar com App Aberta**:
   - Se funcionar com a app aberta mas não fechada, o problema é de configuração de background

5. **Verificar Logs do Firebase**:
   - Ir ao Firebase Console > Functions > Logs
   - Verificar se há erros no envio das notificações

## Arquivos Modificados

1. `android/app/src/main/AndroidManifest.xml` - Permissões e configurações
2. `android/app/src/main/res/values/colors.xml` - Cores das notificações
3. `android/app/src/main/res/values/strings.xml` - Strings do canal
4. `android/app/build.gradle.kts` - Dependências
5. `android/app/src/main/kotlin/com/example/flutter_application_1/MainActivity.kt` - Configuração do plugin
6. `lib/main.dart` - Background handler
7. `lib/services/notification_service.dart` - Melhorias na configuração

## Notas Importantes

- As notificações em background dependem do sistema operacional
- Android pode matar apps em background para economizar bateria
- iOS tem restrições mais rigorosas para apps em background
- Testar sempre em dispositivos físicos, não emuladores 