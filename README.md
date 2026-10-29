# State & Preferences

Aplikasi Flutter sederhana untuk mengelola profil dan preferensi lokal.

## Fitur

- Tema terang/gelap yang tersimpan dengan key `is_dark_mode`.
- Penghitung kunjungan aplikasi dengan key `visit_count`.
- Daftar favorit yang dapat ditambah dan dihapus dengan key `favorites`.
- Profil pengguna dikelola menggunakan `provider` dan `ChangeNotifier`.
- Validasi email yang sudah tersimpan serta penolakan karakter `<` dan `>` pada nama.

Data disimpan secara lokal menggunakan `SharedPreferences`, yang tidak terenkripsi.
Jangan gunakan untuk menyimpan kata sandi atau informasi sensitif.

## Menjalankan dan menguji

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```
