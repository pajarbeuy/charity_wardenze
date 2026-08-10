# 03-tech-stack.md

# Technology Stack

> Version: 1.0.0
> Status: Draft
> Last Update: July 2026

---

# Overview

Dokumen ini menjelaskan teknologi yang digunakan pada **Charity Fund Management System (CFMS)** beserta alasan pemilihannya.

Prinsip utama dalam pemilihan teknologi adalah:

* **Simple over Complex**
* **Maintainability**
* **Scalability**
* **Cost Efficient**
* **Production Ready**

Karena sistem ini ditujukan untuk komunitas dengan jumlah anggota yang relatif sedikit (±20 anggota) namun tetap dirancang agar mudah dikembangkan di masa depan, teknologi dipilih berdasarkan kebutuhan nyata, bukan tren.

---

# System Architecture Overview

```text
Flutter (Android & Web)
            │
            ▼
 Cloudflare Tunnel
            │
            ▼
         Nginx
            │
            ▼
      Laravel API
      ┌──────────────┐
      │              │
      ▼              ▼
   MySQL         RabbitMQ
                      │
                      ▼
          Notification Worker
```

---

# Frontend

## Flutter

**Version**

```
Flutter Stable
```

### Why Flutter?

Flutter dipilih karena mampu menghasilkan aplikasi Android dan Web dari satu codebase sehingga mengurangi biaya pengembangan serta mempermudah maintenance.

### Advantages

* Single Codebase
* UI Modern
* Fast Development
* Cross Platform
* Material Design
* Banyak package yang mature

### Used For

* Android App
* Web Admin Dashboard

---

# Backend

## Laravel

**Version**

```
Laravel 12/13
```

### Why Laravel?

Laravel menyediakan fondasi backend yang matang dengan fitur autentikasi, ORM, queue, scheduler, filesystem, hingga API yang lengkap sehingga sangat cocok untuk sistem administrasi seperti CFMS.

### Advantages

* MVC Architecture
* Eloquent ORM
* Queue System
* Scheduler
* Validation
* Storage
* Artisan CLI
* Built-in Authentication
* REST API Friendly

### Used For

* REST API
* Authentication
* Business Logic
* Reporting
* File Upload
* Queue Processing

---

# Programming Language

## PHP

**Version**

```
PHP 8.4
```

### Why PHP?

Laravel dibangun di atas PHP sehingga penggunaan versi terbaru memberikan performa yang lebih baik, syntax modern, dan dukungan jangka panjang.

---

# Database

## MySQL

**Version**

```
MySQL 9
```

### Why MySQL?

Data yang disimpan bersifat relasional dan memiliki hubungan yang jelas antar tabel seperti User, Payment, Withdrawal, dan Audit Log.

MySQL sudah lebih dari cukup untuk menangani kebutuhan sistem ini.

### Advantages

* Open Source
* Stable
* ACID Compliant
* Mudah di-backup
* Mudah di-deploy

### Used For

* User Data
* Payment
* Withdrawal
* Reports
* Audit Log

---

# Authentication

## Laravel Sanctum

### Why Sanctum?

Sistem hanya membutuhkan autentikasi sederhana menggunakan token tanpa kompleksitas OAuth.

### Advantages

* Lightweight
* Secure
* Official Laravel Package
* Mudah digunakan bersama Flutter

---

# Reverse Proxy

## Nginx

### Why Nginx?

Nginx digunakan sebagai reverse proxy untuk menerima request dari Cloudflare Tunnel sebelum diteruskan ke Laravel.

### Advantages

* Ringan
* Cepat
* Stabil
* Mudah dikonfigurasi

---

# Containerization

## Docker

### Why Docker?

Docker memastikan seluruh developer menggunakan environment yang sama sehingga mengurangi masalah konfigurasi.

### Services

* Laravel
* Nginx
* MySQL
* RabbitMQ

---

# Queue Broker

## RabbitMQ

### Why RabbitMQ?

Walaupun sistem ini masih kecil, beberapa proses tidak perlu dijalankan secara synchronous.

Contohnya:

* Mengirim Email
* Reminder Bulanan
* Mencatat Audit Log
* Generate Laporan
* Broadcast Notification

RabbitMQ memungkinkan proses tersebut berjalan di background sehingga request utama tetap cepat.

### Event Example

```
PaymentVerified

↓

NotificationSent

↓

AuditLogCreated
```

---

# File Storage

## Local Storage

### Why?

Versi pertama hanya menyimpan bukti pembayaran sehingga Local Storage sudah cukup.

Jika suatu saat sistem berkembang, storage dapat dipindahkan ke MinIO atau Object Storage tanpa mengubah business logic secara signifikan.

---

# API Style

## REST API

### Why REST?

REST lebih sederhana, mudah dipahami, dan sesuai dengan kebutuhan aplikasi mobile maupun web.

Contoh Endpoint

```
GET /api/payments

POST /api/payments

GET /api/dashboard
```

---

# QR Payment

## Static QRIS Merchant

### Why Static QRIS?

Project ini tidak menggunakan payment gateway seperti Midtrans atau Xendit karena ingin menghindari biaya transaksi (gateway fee) dan menjaga seluruh dana donasi tetap masuk ke kas komunitas.

Alur pembayaran:

```
Input Nominal

↓

QRIS Merchant Ditampilkan

↓

Transfer Manual

↓

Upload Bukti Pembayaran

↓

Verifikasi Admin
```

Pendekatan ini dipilih karena jumlah anggota masih sedikit sehingga proses verifikasi tetap efisien.

---

# Notification

## Laravel Queue + RabbitMQ

Notification dikirim secara asynchronous.

Contoh:

* Payment Verified
* Payment Rejected
* Monthly Reminder
* Withdrawal Announcement

---

# Scheduler

## Laravel Scheduler

Digunakan untuk proses otomatis seperti:

* Reminder donasi bulanan
* Generate laporan bulanan
* Membersihkan file sementara
* Backup database (opsional)

---

# Security

Teknologi keamanan yang digunakan:

* Laravel Sanctum
* Password Hashing (Argon2id/Bcrypt)
* CSRF Protection
* Rate Limiting
* Input Validation
* Authorization Policy
* HTTPS melalui Cloudflare Tunnel

---

# Deployment

Deployment menggunakan:

* Docker Compose
* Nginx
* Cloudflare Tunnel

Keuntungan:

* Gratis
* Tidak perlu membuka port publik
* Mendukung HTTPS otomatis
* Konfigurasi sederhana untuk VPS

---

# Development Tools

| Tools              | Purpose               |
| ------------------ | --------------------- |
| Visual Studio Code | Source Code Editor    |
| Git                | Version Control       |
| GitHub             | Repository Hosting    |
| Docker Desktop     | Local Development     |
| Postman / Bruno    | API Testing           |
| DBeaver            | Database Management   |
| Figma              | UI/UX Design          |
| Mermaid            | Diagram Documentation |

---

# Technology Summary

| Layer          | Technology           |
| -------------- | -------------------- |
| Frontend       | Flutter              |
| Backend        | Laravel 12/13        |
| Language       | PHP 8.4              |
| Database       | MySQL 9              |
| Authentication | Laravel Sanctum      |
| Queue          | RabbitMQ             |
| Reverse Proxy  | Nginx                |
| Container      | Docker Compose       |
| Payment        | Static QRIS Merchant |
| Storage        | Local Storage        |
| Tunnel         | Cloudflare Tunnel    |
| API            | REST API             |
| Documentation  | Markdown + Mermaid   |

---

# Future Technology Roadmap

Teknologi berikut dapat dipertimbangkan apabila kebutuhan sistem berkembang:

| Technology                | Purpose                    |
| ------------------------- | -------------------------- |
| MinIO                     | Object Storage             |
| Redis                     | Cache & Queue Backend      |
| Laravel Horizon           | Queue Monitoring           |
| Grafana                   | Monitoring Dashboard       |
| Prometheus                | Metrics Collection         |
| OCR Engine                | Validasi Bukti Pembayaran  |
| WhatsApp API              | Notifikasi Otomatis        |
| Payment Gateway           | QRIS Dynamic               |
| Multi Tenant Architecture | Mendukung banyak komunitas |

---

# Technology Decision

| Decision             | Reason                                                               |
| -------------------- | -------------------------------------------------------------------- |
| Flutter              | Satu codebase untuk Android & Web                                    |
| Laravel              | Framework matang, produktif, dan mudah dipelihara                    |
| MySQL                | Relasional, stabil, dan sesuai kebutuhan                             |
| RabbitMQ             | Menjalankan proses asynchronous secara efisien                       |
| Docker               | Konsistensi environment development dan production                   |
| Cloudflare Tunnel    | Deployment gratis tanpa membuka port publik                          |
| Static QRIS Merchant | Menghindari biaya payment gateway dan menjaga dana donasi tetap utuh |

---

# Conclusion

Technology Stack pada CFMS dipilih dengan mempertimbangkan **kesederhanaan, efisiensi biaya, kemudahan pemeliharaan, dan potensi pengembangan di masa depan**. Seluruh komponen merupakan teknologi yang matang, banyak digunakan di industri, dan sesuai dengan kebutuhan sistem tanpa menambahkan kompleksitas yang tidak diperlukan.
