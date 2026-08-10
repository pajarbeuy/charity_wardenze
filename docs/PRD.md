# PRD.md

# Charity Fund Management System (CFMS)

> Version: 1.0.0
> Status: Draft
> Author: Project Team
> Last Update: July 2026

---

# 1. Overview

## Background

Saat ini pengelolaan kas donasi dilakukan secara manual menggunakan spreadsheet atau pencatatan sederhana. Dengan jumlah anggota yang terus bertambah, proses pencatatan menjadi kurang efisien, rentan kesalahan, serta sulit dipantau secara transparan.

Project ini bertujuan membangun sebuah sistem manajemen donasi internal yang memungkinkan setiap anggota melakukan pembayaran iuran bulanan, memantau riwayat donasi, serta memberikan transparansi penuh terhadap pemasukan dan pencairan dana santunan.

Project ini **bukan** merupakan aplikasi crowdfunding publik, melainkan sistem internal komunitas.

---

# 2. Problem Statement

Permasalahan yang dihadapi saat ini:

* Pencatatan pembayaran masih manual.
* Sulit mengetahui siapa yang sudah membayar.
* Riwayat donasi setiap anggota tidak terdokumentasi dengan baik.
* Rekapitulasi saldo dilakukan secara manual.
* Perhitungan jumlah anak yatim yang dapat disantuni masih menggunakan kalkulator.
* Tidak ada dashboard maupun laporan yang mudah dipahami.

---

# 3. Goals

## Business Goals

* Digitalisasi pencatatan kas.
* Transparansi pemasukan dan pengeluaran.
* Mempermudah proses administrasi.
* Mengurangi human error.
* Menjadi laporan keuangan yang dapat dipertanggungjawabkan.

---

## Product Goals

* Login untuk setiap anggota.
* Dashboard personal.
* Dashboard admin.
* Riwayat donasi.
* Verifikasi pembayaran.
* Rekapitulasi kas otomatis.
* Perhitungan target santunan otomatis.

---

# 4. Scope

## Included

### Authentication

* Login
* Logout
* Role Management
* Session Management

---

### Member

* Dashboard
* Riwayat Donasi
* Melakukan Donasi
* Upload Bukti Pembayaran
* Status Pembayaran
* Profile

---

### Admin

* Dashboard
* Kelola User
* Verifikasi Pembayaran
* Riwayat Transaksi
* Pencairan Dana
* Pengaturan Target Santunan
* Laporan

---

### System

* Audit Log
* Notification
* Monthly Statistics

---

## Out of Scope

Versi pertama **tidak mencakup**:

* Multi organisasi
* Crowdfunding publik
* Integrasi payment gateway otomatis
* AI chatbot
* Mobile Push Notification
* WhatsApp Automation
* OCR bukti transfer (dapat dipertimbangkan pada versi berikutnya)

---

# 5. User Roles

## Member

Hak akses:

* Login
* Melihat dashboard
* Membuat donasi
* Upload bukti pembayaran
* Melihat histori
* Mengubah profile

---

## Admin

Hak akses:

* Semua hak Member
* CRUD User
* Verifikasi pembayaran
* Input pencairan dana
* Mengubah target santunan
* Melihat seluruh laporan
* Export data

---

# 6. Business Rules

## BR-001

Setiap anggota wajib memiliki akun.

---

## BR-002

Minimal donasi bulanan adalah

**Rp10.000**

---

## BR-003

User boleh membayar lebih dari Rp10.000.

---

## BR-004

Jika nominal melebihi kewajiban, sistem harus menampilkan pilihan:

* Donasi tambahan bulan ini
* Dialokasikan ke bulan berikutnya

Contoh:

Donasi:

Rp30.000

Pilihan:

Option A

```text
Juli

Iuran      10.000
Donasi     20.000
```

Option B

```text
Juli       ✔

Agustus    ✔

September  ✔
```

---

## BR-005

Pembayaran menggunakan

**QRIS Merchant Statis**

---

## BR-006

Sistem **tidak** memverifikasi pembayaran secara otomatis.

---

## BR-007

User wajib mengunggah bukti pembayaran.

Status awal:

```text
Pending
```

---

## BR-008

Admin melakukan verifikasi.

Status dapat berubah menjadi

* Verified
* Rejected

---

## BR-009

Saldo kas hanya bertambah jika pembayaran sudah diverifikasi.

---

## BR-010

Hanya Admin yang dapat melakukan pencairan dana.

---

## BR-011

Perhitungan jumlah anak yatim dilakukan otomatis.

Formula:

```text
Jumlah Anak

=

Saldo Kas

/

Target Santunan Per Anak
```

Contoh:

Saldo

Rp4.200.000

Target

Rp70.000

Hasil

60 Anak

---

## BR-012

Semua perubahan data harus tercatat dalam Audit Log.

---

# 7. User Flow

## Member

```text
Login

↓

Dashboard

↓

Klik Donasi

↓

Input Nominal

↓

QRIS Ditampilkan

↓

Transfer

↓

Upload Bukti

↓

Pending

↓

Admin Verifikasi

↓

Verified

↓

Saldo Bertambah
```

---

## Admin

```text
Login

↓

Dashboard

↓

Lihat Pembayaran Pending

↓

Verifikasi

↓

Saldo Bertambah

↓

Input Pencairan

↓

Saldo Berkurang

↓

Laporan
```

---

# 8. Functional Requirements

## Authentication

### F-001

User dapat login menggunakan email dan password.

---

### F-002

User dapat logout.

---

## Dashboard Member

### F-003

Menampilkan:

* Nama
* Total Donasi
* Total Pembayaran
* Status Bulan Ini
* Progress Donasi
* Riwayat Terbaru

---

## Donasi

### F-004

User dapat memasukkan nominal donasi.

---

### F-005

Minimal nominal adalah

Rp10.000

---

### F-006

Jika nominal lebih besar dari kewajiban, sistem memberikan pilihan alokasi.

---

### F-007

Sistem menampilkan QRIS Merchant.

---

### F-008

User dapat mengunggah bukti pembayaran.

---

### F-009

Status pembayaran:

* Pending
* Verified
* Rejected

---

## Dashboard Admin

### F-010

Menampilkan:

* Total Kas
* Total Donasi
* Total Pengeluaran
* Saldo
* Jumlah Member
* Pembayaran Pending

---

### F-011

Menampilkan grafik pemasukan bulanan.

---

### F-012

Menampilkan grafik pencairan.

---

## Verifikasi

### F-013

Admin dapat:

* Approve
* Reject

---

### F-014

Admin dapat memberikan catatan.

---

## Withdrawal

### F-015

Admin dapat membuat pencairan.

Field:

* Nominal
* Tanggal
* Keterangan

---

### F-016

Saldo otomatis berkurang.

---

## Report

### F-017

Export PDF.

---

### F-018

Export Excel.

---

# 9. Non Functional Requirements

## Performance

* Response API < 500 ms
* Dashboard < 2 detik
* Mendukung minimal 100 user aktif (jauh di atas kebutuhan awal 19 anggota)

---

## Security

* Password di-hash menggunakan Argon2id atau Bcrypt.
* Authentication menggunakan Laravel Sanctum.
* Validasi seluruh input.
* CSRF Protection.
* Rate Limiter.
* Audit Log.

---

## Availability

Target uptime:

99%

---

## Maintainability

* Clean Architecture
* Repository Pattern (opsional)
* REST API
* Dockerized
* Environment Configuration

---

# 10. Success Metrics

Project dianggap berhasil apabila:

* Seluruh anggota memiliki akun.
* Seluruh pembayaran tercatat dalam sistem.
* Tidak ada perhitungan saldo manual.
* Laporan dapat dihasilkan kapan saja.
* Perhitungan target santunan berjalan otomatis.
* Admin dapat memverifikasi pembayaran kurang dari 30 detik per transaksi.

---

# 11. Future Enhancements

Versi berikutnya dapat menambahkan:

* OCR bukti transfer
* WhatsApp Notification
* Email Notification
* QRIS Dynamic
* Payment Gateway
* Auto Verification
* Mobile App
* Face ID Login
* AI Financial Insight
* Multi Community Support

---

# 12. MVP Definition

Versi 1.0 dianggap selesai apabila tersedia fitur berikut:

* Login
* Dashboard Member
* Dashboard Admin
* Donasi
* QRIS Merchant Statis
* Upload Bukti Pembayaran
* Verifikasi Admin
* Riwayat Donasi
* Pencairan Dana
* Grafik Pemasukan
* Kalkulator Target Santunan
* Laporan PDF
* Audit Log

---

# 13. Acceptance Criteria

| Modul                | Acceptance Criteria                                                                                 |
| -------------------- | --------------------------------------------------------------------------------------------------- |
| Authentication       | User dapat login dan logout dengan benar.                                                           |
| Donasi               | User dapat mengirim donasi minimal Rp10.000 dan mengunggah bukti pembayaran.                        |
| Verifikasi           | Admin dapat menyetujui atau menolak pembayaran.                                                     |
| Dashboard            | Data kas, donasi, dan statistik ditampilkan secara akurat.                                          |
| Withdrawal           | Saldo otomatis berkurang setelah pencairan dicatat.                                                 |
| Laporan              | Sistem dapat menghasilkan laporan PDF dan Excel.                                                    |
| Perhitungan Santunan | Jumlah anak yatim yang dapat disantuni dihitung otomatis berdasarkan saldo kas dan target per anak. |

---

# 14. Project Vision Statement

> **Membangun sistem manajemen donasi yang sederhana, transparan, mudah digunakan, dan dapat dipercaya untuk membantu komunitas mengelola iuran serta menyalurkan santunan kepada anak yatim secara lebih efektif dan akuntabel.**
