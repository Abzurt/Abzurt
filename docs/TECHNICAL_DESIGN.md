# Teknik Tasarım Dokümanı (Technical Design)

## 1. Teknoloji Yığını
- **Framework:** Flutter (Android, iOS, Web, Desktop)
- **Backend:** Firebase (Auth, Firestore)
- **State Management:** Provider / Riverpod (Planlanan)
- **Local Storage:** Hive / Shared Preferences

## 2. Veri Modelleri

### UserModel
Kullanıcı profilini ve etkileşimlerini tutar.
- `id`: Unique String
- `email`: String
- `displayName`: String
- `readNewsIds`: List<String>
- `savedNewsIds`: List<String>
- `sharedNewsIds`: List<String>

### NewsModel
Haber içeriklerini temsil eder.
- `id`: Unique String
- `title`: String
- `content`: String
- `imageUrl`: String
- `sourceUrl`: String
- `category`: String
- `timestamp`: DateTime

### SourceModel
Kullanıcılar tarafından eklenen haber kaynaklarını temsil eder.
- `id`: Unique String
- `url`: String
- `category`: String
- `addedBy`: String (UserId)

## 3. Mimari Yapı
Uygulama **Clean Architecture** prensiplerine uygun olarak klasörlenmiştir:
- `lib/models/`: Veri yapıları.
- `lib/screens/`: UI ekranları.
- `lib/widgets/`: Tekrar kullanılabilir arayüz birimleri.
- `lib/services/`: Veritabanı ve scraping servisleri.

## 4. Güvenlik ve Kimlik Doğrulama
- Tüm veriler Firebase Auth ile yetkilendirilmiş kullanıcılar bazında Firestore üzerinde saklanır.
- Firestore Security Rules ile sadece kullanıcıların kendi verilerine erişimi sağlanır.
