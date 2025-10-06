import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String nickname;

  const CustomDrawer({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB388EB), Color(0xFFE0BBE4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF6A0572)),
                ),
                const SizedBox(height: 10),
                Text(
                  "Hola, $nickname 👋",
                  style: const TextStyle(
                    fontFamily: "LuckiestGuy",
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () => Navigator.pushReplacementNamed(context, "/home"),
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text("IA"),
            onTap: () => Navigator.pushNamed(context, "/ai"),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text("Diario"),
            onTap: () => Navigator.pushNamed(context, "/diary"),
          ),
          ListTile(
            leading: const Icon(Icons.poll),
            title: const Text("Encuestas"),
            onTap: () => Navigator.pushNamed(context, "/surveys"),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Calendario"),
            onTap: () => Navigator.pushNamed(context, "/calendar"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
