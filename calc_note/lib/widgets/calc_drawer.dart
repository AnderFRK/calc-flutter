import 'package:flutter/material.dart';

class CalcDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> savedFilesList;
  final VoidCallback onNewFile;
  final Function(String, String) onFileLoaded;
  final VoidCallback onImport; // Nueva función

  const CalcDrawer({
    super.key,
    required this.savedFilesList,
    required this.onNewFile,
    required this.onFileLoaded,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20),
            color: const Color(0xFF3399FF),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.folder_open, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('Mis Documentos', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(Icons.note_add, "Nuevo", onNewFile),
                _actionButton(Icons.file_upload, "Importar", onImport),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: savedFilesList.length,
              itemBuilder: (context, index) {
                var file = savedFilesList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE6F2FF),
                      child: Icon(Icons.description, color: Colors.blue),
                    ),
                    title: Text(file['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(file['guide'] != "" ? "Guía: ${file['guide']}" : "Sin guía"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onFileLoaded(file['title'], file['guide']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }
}