# 05-api.md

# REST API Specification

> Version: 1.0.0
> API Version: v1
> Architecture: REST API
> Authentication: Laravel Sanctum (Bearer Token)

---

# Overview

Dokumen ini mendefinisikan seluruh endpoint REST API yang digunakan pada **Charity Fund Management System (CFMS)**.

Base URL

```http
/api/v1
```

Semua response menggunakan format JSON.

---

# Authentication

Semua endpoint (kecuali Login) membutuhkan Bearer Token.

Header

```http
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

---

# Response Standard

## Success

```json
{
    "success": true,
    "message": "Success",
    "data": {}
}
```

---

## Error

```json
{
    "success": false,
    "message": "Validation Error",
    "errors": {}
}
```

---

# Authentication Module

---

## Login

```http
POST /auth/login
```

### Request

```json
{
    "email":"admin@email.com",
    "password":"password"
}
```

### Response

```json
{
    "success":true,
    "message":"Login Success",
    "data":{
        "token":"xxxx",
        "user":{}
    }
}
```

---

## Logout

```http
POST /auth/logout
```

Authorization Required

---

## Current User

```http
GET /auth/me
```

Authorization Required

---

# Dashboard Module

---

## Member Dashboard

```http
GET /dashboard/member
```

Response

```json
{
    "total_donation":350000,
    "payment_count":35,
    "current_month":"Verified",
    "recent_transactions":[]
}
```

---

## Admin Dashboard

```http
GET /dashboard/admin
```

Response

```json
{
    "cash":5000000,
    "income":6200000,
    "expense":1200000,
    "pending_payment":4,
    "member":19
}
```

---

# Payment Module

---

## Create Payment

```http
POST /payments
```

### Request

```json
{
    "amount":30000,
    "allocation_type":"DONATION"
}
```

allocation_type

| Value      | Description                      |
| ---------- | -------------------------------- |
| DONATION   | Donasi tambahan                  |
| NEXT_MONTH | Dialokasikan ke bulan berikutnya |

---

### Response

```json
{
    "success":true,
    "message":"Payment Created"
}
```

---

## Upload Payment Proof

```http
POST /payments/{id}/proof
```

Form Data

```text
proof=image.jpg
```

---

## Payment History

```http
GET /payments
```

Query

```http
?page=1

?status=verified

?status=pending

?status=rejected
```

---

## Payment Detail

```http
GET /payments/{id}
```

---

## Cancel Payment

Hanya pembayaran yang masih Pending.

```http
DELETE /payments/{id}
```

---

# Payment Verification

(Admin Only)

---

## Pending Payments

```http
GET /admin/payments/pending
```

---

## Verify Payment

```http
PATCH /admin/payments/{id}/verify
```

Request

```json
{
    "note":"Transfer sesuai"
}
```

---

## Reject Payment

```http
PATCH /admin/payments/{id}/reject
```

Request

```json
{
    "reason":"Nominal tidak sesuai"
}
```

---

# Withdrawal Module

(Admin Only)

---

## Create Withdrawal

```http
POST /withdrawals
```

Request

```json
{
    "amount":700000,
    "withdraw_date":"2026-08-01",
    "description":"Santunan Bulanan"
}
```

---

## Withdrawal List

```http
GET /withdrawals
```

---

## Withdrawal Detail

```http
GET /withdrawals/{id}
```

---

## Update Withdrawal

```http
PUT /withdrawals/{id}
```

---

## Delete Withdrawal

```http
DELETE /withdrawals/{id}
```

---

# User Module

(Admin)

---

## Get Users

```http
GET /users
```

Query

```http
?page=1

?search=pajar

?status=active
```

---

## User Detail

```http
GET /users/{id}
```

---

## Create User

```http
POST /users
```

Request

```json
{
    "name":"Pajar",
    "email":"pajar@email.com",
    "password":"password"
}
```

---

## Update User

```http
PUT /users/{id}
```

---

## Delete User

```http
DELETE /users/{id}
```

Soft Delete.

---

# Profile Module

---

## My Profile

```http
GET /profile
```

---

## Update Profile

```http
PUT /profile
```

---

## Change Password

```http
PATCH /profile/password
```

Request

```json
{
    "current_password":"password",
    "new_password":"passwordbaru",
    "new_password_confirmation":"passwordbaru"
}
```

---

# Statistics Module

(Admin)

---

## Monthly Income

```http
GET /statistics/income
```

Response

```json
{
    "January":1200000,
    "February":950000
}
```

---

## Monthly Expense

```http
GET /statistics/expense
```

---

## Dashboard Chart

```http
GET /statistics/dashboard
```

---

# Charity Target Module

---

## Current Target

```http
GET /charity-target
```

Response

```json
{
    "cash":5600000,
    "target_per_child":70000,
    "children":80
}
```

---

## Update Target

(Admin)

```http
PUT /charity-target
```

Request

```json
{
    "target_per_child":70000
}
```

---

# Report Module

(Admin)

---

## Generate PDF

```http
GET /reports/pdf
```

Query

```http
?start_date=2026-01-01

&end_date=2026-12-31
```

---

## Export Excel

```http
GET /reports/excel
```

---

# Audit Log

(Admin)

---

## Audit List

```http
GET /audit-logs
```

---

## Audit Detail

```http
GET /audit-logs/{id}
```

---

# Notification Module

---

## My Notifications

```http
GET /notifications
```

---

## Read Notification

```http
PATCH /notifications/{id}/read
```

---

# Settings Module

(Admin)

---

## Get Settings

```http
GET /settings
```

---

## Update Settings

```http
PUT /settings
```

Example

```json
{
    "monthly_fee":10000,
    "target_per_child":70000
}
```

---

# HTTP Status Code

| Code | Meaning               |
| ---- | --------------------- |
| 200  | Success               |
| 201  | Created               |
| 204  | No Content            |
| 400  | Bad Request           |
| 401  | Unauthorized          |
| 403  | Forbidden             |
| 404  | Not Found             |
| 409  | Conflict              |
| 422  | Validation Error      |
| 500  | Internal Server Error |

---

# API Security

* Laravel Sanctum Authentication
* Password Hashing (Argon2id/Bcrypt)
* Role-Based Authorization
* Input Validation
* Rate Limiting
* File Validation
* CSRF Protection (Web)
* HTTPS via Cloudflare Tunnel

---

# Endpoint Summary

| Module               | Endpoint Count |
| -------------------- | :------------: |
| Authentication       |        3       |
| Dashboard            |        2       |
| Payments             |        5       |
| Payment Verification |        3       |
| Withdrawals          |        5       |
| Users                |        5       |
| Profile              |        3       |
| Statistics           |        3       |
| Charity Target       |        2       |
| Reports              |        2       |
| Audit Log            |        2       |
| Notifications        |        2       |
| Settings             |        2       |

**Total Endpoint:** **39 REST Endpoints**

---

# Future API

Endpoint berikut direncanakan pada versi selanjutnya:

| Endpoint               | Version |
| ---------------------- | ------- |
| QRIS Dynamic Payment   | v2.0    |
| OCR Payment Validation | v2.0    |
| WhatsApp Notification  | v2.0    |
| Email Notification     | v2.0    |
| Public Donation API    | v3.0    |
| Multi Organization API | v3.0    |

---

# API Design Principles

* RESTful Resource Naming
* Stateless Authentication
* Consistent JSON Response
* Versioned API (`/api/v1`)
* Soft Delete untuk data penting
* Pagination pada seluruh endpoint list
* Filter dan Search untuk endpoint data besar
* Role-Based Access Control (RBAC)
* Idempotent untuk operasi yang sesuai (GET, PUT, DELETE)
* Validasi request di seluruh endpoint sebelum business logic dijalankan.
