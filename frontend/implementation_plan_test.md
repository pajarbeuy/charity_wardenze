# Implementation Plan - Enhanced Frontend Test Suite (Flutter with Mocktail)

Mengimplementasikan **suite pengujian otomatis Flutter** yang solid dan fleksibel dengan menggunakan strategi **Mocktail** (tanpa perlunya *code generation* `build_runner`) dan **Dependency Injection (DI)** pada Provider layer.

---

## User Review Required

> [!IMPORTANT]
> 1. Terlebih dahulu dilakukan **Refactoring Ringan (Prasyarat)** pada source code aplikasi:
>    - Membuat `ApiService` menerima HTTP client injectable / mengekstrak `AuthRepository` & `CfmsRepository` agar `AuthProvider` dan `CfmsProvider` dapat menerima repository via **Constructor Injection**.
>    - Menambahkan `Key` pada widget interaktif di `LoginScreen` (`Key('emailField')`, `Key('passwordField')`, `Key('loginButton')`).
> 2. `mocktail` versi `^1.0.4` telah dipasang di `dev_dependencies`.

---

## Proposed Folder & File Architecture

```text
frontend/
├── lib/                             # Source Code Refactor (DI & Keys)
│   ├── repositories/
│   │   ├── auth_repository.dart     # Repository abstraksi Auth
│   │   └── cfms_repository.dart     # Repository abstraksi CFMS (Payments, Users, Dashboard, Stats)
│   ├── providers/
│   │   ├── auth_provider.dart       # Updated: Terima AuthRepository via constructor (DI)
│   │   └── cfms_provider.dart       # Updated: Terima CfmsRepository via constructor (DI)
│   └── screens/
│       └── login_screen.dart        # Updated: Ditambahkan ValueKey pada TextField & Button
│
├── test/
│   ├── fixtures/                    # Data Dummy Sample (9 Models)
│   │   ├── user_fixture.dart
│   │   ├── payment_fixture.dart
│   │   ├── dashboard_fixture.dart
│   │   ├── setting_fixture.dart
│   │   ├── withdrawal_fixture.dart
│   │   ├── charity_target_fixture.dart
│   │   ├── audit_log_fixture.dart
│   │   └── notification_fixture.dart
│   │
│   ├── mocks/                       # Mock Repositories
│   │   └── mock_repositories.dart   # MockAuthRepository & MockCfmsRepository via Mocktail
│   │
│   ├── helpers/                     # Widget Test Helper
│   │   └── pump_app.dart            # MultiProvider & MaterialApp Wrapper Helper
│   │
│   ├── unit/                        # 1. Unit Logic Tests
│   │   ├── models_test.dart         # Deserialisasi 9 Model dari Fixtures
│   │   ├── auth_provider_test.dart  # Unit Test AuthProvider (Login, Logout, Server Down 500/SocketException, Admin Role)
│   │   └── cfms_provider_test.dart  # Unit Test CfmsProvider (Fetch Dashboard, Create Payment, Verify, Reset Pass)
│   │
│   └── widget/                      # 2. UI Component & Widget Tests
│       ├── login_screen_widget_test.dart    # Test Form UI, Popup Server Down (Amber), Popup Login Failed (Red)
│       ├── member_dashboard_widget_test.dart# Test Render Donasi, Status Pembayaran, Tombol Aksi
│       ├── admin_dashboard_widget_test.dart # Test 4 Card KPI, Target Anak Yatim, Grid Menu Admin
│       ├── monthly_status_widget_test.dart # Test Filter Chip, Ringkasan Lunas/Pending/Unpaid
│       └── user_management_widget_test.dart# Test Member List, Dialog Tambah User, Dialog Reset Password
│
└── integration_test/                # 3. App Flow Integration Tests
    ├── app_login_flow_test.dart     # Flow: Login -> Navigate to Dashboard -> Logout
    └── admin_feature_flow_test.dart # Flow: Admin Dashboard -> Kelola Member -> Status Bulan -> Rekap Income
```

---

## Detailed Test Scenarios

### 1. Unit Logic Tests (`test/unit/`)
- **`models_test.dart`**: Memverifikasi `fromJson()` dan getter pada seluruh 9 data models menggunakan fixture JSON.
- **`auth_provider_test.dart`**:
  - `login()` sukses -> `isAuthenticated == true`, `user` terisi.
  - `login()` server down (`SocketException` / `Connection refused`) -> `rethrow` error / tangkap exception.
  - `login()` gagal (kredensial salah 401) -> tangkap exception pesan error.
  - `isAdmin` checking -> true jika role `'Admin'`.
  - `logout()` -> `token` dan `user` menjadi `null`, `isAuthenticated == false`.
- **`cfms_provider_test.dart`**:
  - `fetchMemberDashboard()`, `fetchAdminDashboard()`, `fetchPayments()`.
  - `resetUserPassword()` -> memanggil repository `put('/users/{id}', ...)`.

### 2. Widget & Popup Tests (`test/widget/`)
- **`login_screen_widget_test.dart`**:
  - Render elemen form, email & password field.
  - Validasi pesan `Email wajib diisi` & `Password wajib diisi`.
  - **Popup Warning (Server Tidak Tersedia)**: Saat login melempar `SocketException`/`Connection refused`, memverifikasi judul "Server Tidak Tersedia", icon `wifi_off`, info kontak admin, dan tombol "Coba Lagi".
  - **Popup Danger (Login Gagal)**: Saat login melempar 401, memverifikasi dialog header merah, pesan error, dan tombol "Coba Lagi".
- **`member_dashboard_widget_test.dart`**: Render kartu total donasi & status bulan ini.
- **`admin_dashboard_widget_test.dart`**: Render 4 card KPI (Saldo Kas, Total Masuk, Total Pengeluaran, Pending) & menu navigasi.
- **`monthly_status_widget_test.dart`**: Interaksi tap filter chip (`Semua`, `Lunas`, `Pending`, `Belum Bayar`), render total income bulan ini.
- **`user_management_widget_test.dart`**: Render tombol `⋮` per member, membuka dialog Reset Password, input password baru, dan tombol reset.

### 3. Integration Tests (`integration_test/`)
- **`app_login_flow_test.dart`**: End-to-End simulasi interaksi user dari layar login sampai masuk dashboard dan kembali logout.

---

## Verification Plan

### Execution Commands
1. **Unit & Widget Tests (`flutter_test`)**:
   ```bash
   flutter test
   ```
2. **Integration Tests (`integration_test`)**:
   ```bash
   flutter test integration_test
   ```

### Goal
Seluruh unit logic, widget UI component, dan integration flow tests berhasil dibuat dan **LULUS 100%**.
