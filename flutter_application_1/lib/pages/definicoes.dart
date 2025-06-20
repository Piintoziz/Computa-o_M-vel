import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_routes.dart';

class DefinicoesPage extends StatelessWidget {
  const DefinicoesPage({Key? key}) : super(key: key);

  Widget _buildSettingsTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFE9E9E9),
        child: ListTile(
          leading: Icon(icon, size: 28, color: Colors.black87),
          title: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Definições',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.settings,
              title: 'Geral',
              subtitle: 'Veja e atualize os detalhes da loja',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.definicoesGeral); 
              },
            ),
            _buildSettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Métodos de Pagamento',
              subtitle: 'Escolha como pretende receber os pagamentos',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.definicoesPagamento); 
              }, 
            ),
            _buildSettingsTile(
              icon: Icons.local_shipping_outlined,
              title: 'Logística',
              subtitle: 'Gerencie como envia produtos para os clientes',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.definicoesLogistica); 
              },
            ),
            _buildSettingsTile(
              icon: Icons.receipt_long_outlined,
              title: 'Faturação',
              subtitle: 'Gerencie toda a faturação',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.definicoesFaturacao); 
              },
            ),
            _buildSettingsTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notificações',
              subtitle: 'Gerencie as notificações que deseja receber',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.definicoesNotificacoes); 
              },
            ),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Conta',
              subtitle: 'Gerencie a sua conta e permissões',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.definicoesConta); 

              },
            ),
          ],
        ),
      ),
    );
  }
}