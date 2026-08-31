import 'package:flutter/material.dart';

void main() {
  runApp(const BukuKontakApp());
}

class BukuKontakApp extends StatelessWidget {
  const BukuKontakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Kontak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BerandaPage(),
    );
  }
}

// Model data untuk kontak dengan tambahan status favorit
class KontakModel {
  final String nama;
  final String email;
  final String telepon;
  bool isFavorit;

  KontakModel({
    required this.nama,
    required this.email,
    required this.telepon,
    this.isFavorit = false,
  });
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<KontakModel> _daftarKontak = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk menambah kontak baru
  void _tambahKontak(String nama, String email, String telepon) {
    setState(() {
      _daftarKontak.add(
        KontakModel(nama: nama, email: email, telepon: telepon),
      );
    });
  }

  // Fungsi untuk menghapus kontak berdasarkan objek
  void _hapusKontak(KontakModel kontak) {
    setState(() {
      _daftarKontak.remove(kontak);
    });
  }

  // Fungsi untuk mengubah status favorit
  void _toggleFavorit(KontakModel kontak) {
    setState(() {
      kontak.isFavorit = !kontak.isFavorit;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Memfilter daftar kontak yang berstatus favorit
    final daftarFavorit = _daftarKontak.where((k) => k.isFavorit).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('BUKU KONTAK'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.blue,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Kontak'),
                Tab(icon: Icon(Icons.star), text: 'Favorit'),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'BUKU KONTAK',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Kontak'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Kontak'),
              onTap: () async {
                Navigator.pop(context);
                final hasilBaru = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TambahKontakPage(),
                  ),
                );
                if (hasilBaru != null && hasilBaru is KontakModel) {
                  _tambahKontak(
                    hasilBaru.nama,
                    hasilBaru.email,
                    hasilBaru.telepon,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorit'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TentangPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KontakPage(
            daftarKontak: _daftarKontak,
            onHapus: _hapusKontak,
            onToggleFavorit: _toggleFavorit,
          ),
          FavoritPage(
            daftarFavorit: daftarFavorit,
            onToggleFavorit: _toggleFavorit,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final hasilBaru = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahKontakPage()),
          );
          if (hasilBaru != null && hasilBaru is KontakModel) {
            _tambahKontak(hasilBaru.nama, hasilBaru.email, hasilBaru.telepon);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class KontakPage extends StatelessWidget {
  final List<KontakModel> daftarKontak;
  final Function(KontakModel) onHapus;
  final Function(KontakModel) onToggleFavorit;

  const KontakPage({
    super.key,
    required this.daftarKontak,
    required this.onHapus,
    required this.onToggleFavorit,
  });

  @override
  Widget build(BuildContext context) {
    if (daftarKontak.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: daftarKontak.length,
      itemBuilder: (context, index) {
        final kontak = daftarKontak[index];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(kontak.nama),
          subtitle: Text('${kontak.email}\n${kontak.telepon}'),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  kontak.isFavorit ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => onToggleFavorit(kontak),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onHapus(kontak),
              ),
            ],
          ),
        );
      },
    );
  }
}

// FavoritPage gabungan: Menampilkan kontak bawaan (Anshar)
// dan kontak dinamis yang ditandai bintang
class FavoritPage extends StatelessWidget {
  final List<KontakModel> daftarFavorit;
  final Function(KontakModel) onToggleFavorit;

  const FavoritPage({
    super.key,
    required this.daftarFavorit,
    required this.onToggleFavorit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Kontak statis/bawaan milikmu
        const ListTile(
          leading: Icon(Icons.person),
          title: Text('Andreas Dwi Prakasa'),
          subtitle: Text('andreasprakasa85@gmail.com\n082206541044'),
          isThreeLine: true,
          trailing: Icon(Icons.star, color: Colors.amber),
        ),
        // Kontak dinamis dari tab 'Kontak' yang ditandai bintang
        ...daftarFavorit.map(
          (kontak) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(kontak.nama),
            subtitle: Text('${kontak.email}\n${kontak.telepon}'),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.star, color: Colors.amber),
              onPressed: () => onToggleFavorit(kontak),
            ),
          ),
        ),
      ],
    );
  }
}

class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() => _TambahKontakPageState();
}

class _TambahKontakPageState extends State<TambahKontakPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tambah Kontak'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(labelText: 'No Handphone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      KontakModel(
                        nama: _namaController.text,
                        email: _emailController.text,
                        telepon: _teleponController.text,
                      ),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tentang'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/foto_profil.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Andreas Dwi Prakasa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('XII RPL B', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'SMK Negeri 5 Surakarta',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
