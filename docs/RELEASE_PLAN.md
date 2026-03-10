# Release ve Dağıtım Dokümanı

## 1. Versiyon Geçmişi
### v1.0.0-alpha (Mevcut Durum)
- Temel Flutter proje kurulumu.
- Firebase entegrasyonu (Auth & Firestore).
- 7 ana ekranın UI kodlaması (Mor tema).
- Temel navigasyon yapısı (FAB & BottomBar).

## 2. Yol Haritası (Roadmap)
### Faz 1: Fonksiyonellik (MVP)
- [ ] Firebase Auth (E-posta/Şifre) giriş mantığının bağlanması.
- [ ] Web Scraping (URL'den haber içeriği çekme) servisinin yazılması.
- [ ] Firestore veri okuma/yazma işlemlerinin tamamlanması.

### Faz 2: Gelişmiş Özellikler
- [ ] Bildirim (Push Notification) sistemi.
- [ ] Çevrimdışı (Offline) okuma desteği.
- [ ] Yapay zeka ile haber özeti çıkarma.

## 3. Dağıtım Planı
- **Staging:** TestFlight (iOS) ve Google Play Console Internal Testing (Android) üzerinden yapılacak.
- **Production:** App Store ve Google Play Store.

## 4. Bağımlılıklar ve Kurulum
Projeyi çalıştırmak için:
1. Flutter SDK yüklü olmalı.
2. `flutter pub get` çalıştırılmalı.
3. Firebase projesine erişim izni olmalı.
