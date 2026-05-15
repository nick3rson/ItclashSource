# 🐳 Docker & Docker Compose — คู่มือคำสั่งวันแข่ง
> **IT Clash 2569 | Cybersecurity Track**
> คู่มือนี้รวมคำสั่ง Docker ทั้งหมดที่ต้องใช้วันแข่ง อ่านแล้วทำได้เลย

---

## 📋 สารบัญ

1. [ติดตั้ง Docker](#-ติดตั้ง-docker)
2. [Docker Compose พื้นฐาน](#-docker-compose-พื้นฐาน)
3. [อ่าน docker-compose.yml](#-อ่าน-docker-composeyml)
4. [จัดการ Container](#-จัดการ-container)
5. [ดู Log](#-ดู-log)
6. [Debug ภายใน Container](#-debug-ภายใน-container)
7. [Network](#-network)
8. [Workflow วันแข่ง](#-workflow-วันแข่ง)

---

## 🔧 ติดตั้ง Docker

### Ubuntu
```bash
# ติดตั้ง Docker Engine
sudo apt update
sudo apt install -y docker.io docker-compose-plugin

# เพิ่ม user เข้ากลุ่ม docker (ไม่ต้องพิมพ์ sudo ทุกครั้ง)
sudo usermod -aG docker $USER

# logout แล้ว login ใหม่ หรือรัน
newgrp docker

# ทดสอบ
docker --version
docker compose version
```

### ทดสอบว่าใช้ได้
```bash
docker run hello-world
# ถ้าเห็น "Hello from Docker!" = ใช้ได้แล้ว ✅
```

---

## 🚀 Docker Compose พื้นฐาน

> คำสั่งที่ใช้บ่อยที่สุดวันแข่ง ต้องจำให้ได้!

### ▶️ รัน Project
```bash
# รันแบบ background (แนะนำ)
docker compose up -d

# อธิบาย:
# up   = เริ่ม container ทั้งหมดใน docker-compose.yml
# -d   = detached mode (รันใน background ไม่ block terminal)
```

### ⏹️ หยุด Project
```bash
# หยุดและลบ container (แต่เก็บ data ไว้)
docker compose down

# หยุดและลบทุกอย่างรวมถึง volume (ลบ database ด้วย!)
docker compose down -v
# ⚠️ ระวัง! -v จะลบข้อมูล database ทั้งหมด
```

### 🔄 Rebuild หลังแก้ Code (ใช้บ่อยที่สุดวันแข่ง)
```bash
# rebuild image ใหม่แล้วรัน
docker compose up --build -d

# อธิบาย:
# --build = บังคับ build image ใหม่ แม้ไม่มีการเปลี่ยนแปลง
# -d      = รันใน background

# ถ้าแก้ code แล้วต้องการ deploy ใหม่ รันคำสั่งนี้เลย!
```

### 🔁 Restart Container
```bash
# restart ทุก container
docker compose restart

# restart เฉพาะ service ที่ต้องการ
docker compose restart app
docker compose restart db
```

### ⏸️ หยุดชั่วคราว (ไม่ลบ container)
```bash
docker compose stop

# เริ่มใหม่โดยไม่ต้อง build
docker compose start
```

---

## 📄 อ่าน docker-compose.yml

> ตัวอย่าง docker-compose.yml ที่จะเจอวันแข่ง

```yaml
services:
  app:                          # ชื่อ service
    build: .                    # build จาก Dockerfile ใน folder นี้
    ports:
      - "8080:8080"             # host:container (เปิด port 8080)
    environment:
      - DB_HOST=db              # ตัวแปร environment
      - DB_PORT=5432
      - DB_NAME=myapp
      - DB_USER=admin
      - DB_PASSWORD=secret
      - JWT_SECRET=mysecret     # ⚠️ secret อ่อน = JWT crack ได้!
    depends_on:
      - db                      # รอ db ขึ้นก่อน
    volumes:
      - ./:/app                 # mount code จาก host เข้า container

  db:
    image: postgres:15          # ใช้ image สำเร็จรูป
    ports:
      - "5432:5432"             # เปิด port database
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=secret
    volumes:
      - db_data:/var/lib/postgresql/data  # เก็บ data ถาวร

volumes:
  db_data:                      # named volume สำหรับ database
```

### จุดที่ต้องสังเกต
```
JWT_SECRET=mysecret    ← ⚠️ secret สั้น = crack ด้วย jwt_tool ได้!
DB_PASSWORD=secret     ← ⚠️ password อ่อน
ports: "8080:8080"     ← รู้ว่าเว็บอยู่ที่ port ไหน
```

---

## 📊 จัดการ Container

### ดูสถานะ Container
```bash
# ดูเฉพาะ project นี้
docker compose ps

# ผลลัพธ์ตัวอย่าง:
# NAME          STATUS          PORTS
# myapp-app-1   Up 5 minutes    0.0.0.0:8080->8080/tcp
# myapp-db-1    Up 5 minutes    0.0.0.0:5432->5432/tcp

# ดูทุก container ในเครื่อง
docker ps

# ดูทั้ง running และ stopped
docker ps -a
```

### ดู Resource ที่ใช้
```bash
docker stats

# ผลลัพธ์:
# NAME          CPU %   MEM USAGE   NET I/O
# myapp-app-1   0.5%    50MB        1MB / 500KB
```

### ลบ Image/Container ที่ไม่ใช้
```bash
# ลบทุกอย่างที่ไม่ได้ใช้ (ถ้า disk เต็ม)
docker system prune -f

# ลบ image ที่ไม่ได้ใช้
docker image prune -f
```

---

## 📋 ดู Log

### ดู Log แบบ Realtime (ใช้บ่อยมาก!)
```bash
# ดู log ทุก service พร้อมกัน
docker compose logs -f

# ดู log เฉพาะ app
docker compose logs -f app

# ดู log เฉพาะ database
docker compose logs -f db

# อธิบาย:
# -f = follow (แสดง log ใหม่แบบ realtime)
# กด Ctrl+C เพื่อหยุด
```

### ดู Log ย้อนหลัง
```bash
# ดู 50 บรรทัดล่าสุด
docker compose logs --tail=50 app

# ดู 100 บรรทัดล่าสุดพร้อม timestamp
docker compose logs --tail=100 -t app
```

### อ่าน Log หา Error
```bash
# หา error ใน log
docker compose logs app | grep -i "error"

# หา panic (Go app crash)
docker compose logs app | grep -i "panic"

# หา SQL error
docker compose logs app | grep -i "sql"
```

---

## 🔍 Debug ภายใน Container

### เข้าไปใน Container (เหมือน SSH)
```bash
# เข้าไปใน app container
docker compose exec app sh

# ถ้าใช้ bash ได้
docker compose exec app bash

# เข้าไปใน database container
docker compose exec db sh

# อธิบาย:
# exec = รัน command ใน container ที่กำลัง run อยู่
# app  = ชื่อ service
# sh   = shell ที่จะใช้
```

### รัน Command ใน Container โดยตรง
```bash
# ดูไฟล์ใน container
docker compose exec app ls -la

# ดู environment variable
docker compose exec app env

# ดู process ที่รันอยู่
docker compose exec app ps aux
```

### เข้าไปใน PostgreSQL
```bash
# เข้า psql ใน database container
docker compose exec db psql -U admin -d myapp

# คำสั่ง psql ที่มีประโยชน์:
\l          # ดู database ทั้งหมด
\c myapp    # เชื่อมต่อ database ชื่อ myapp
\dt         # ดู table ทั้งหมด
\d users    # ดูโครงสร้าง table users

# ดูข้อมูลใน table
SELECT * FROM users;
SELECT * FROM users LIMIT 10;

# ออกจาก psql
\q
```

---

## 🌐 Network

### ดู Network ทั้งหมด
```bash
docker network ls

# ผลลัพธ์:
# NETWORK ID   NAME              DRIVER
# abc123       myapp_default     bridge
```

### ดู IP ของ Container
```bash
docker inspect myapp-app-1 | grep IPAddress

# หรือเข้าไปใน container แล้วรัน
docker compose exec app hostname -I
```

### ทดสอบ Connection ระหว่าง Container
```bash
# เข้าไปใน app แล้วลอง ping database
docker compose exec app ping db

# ทดสอบ port database
docker compose exec app nc -zv db 5432
```

---

## 🎮 Workflow วันแข่ง

### ⚡ รับ Source Code แล้วรันทันที
```bash
# Step 1: Clone หรือรับ source code มา
git clone <repo_url>
cd <project_folder>

# Step 2: ดู structure ก่อน
ls -la
cat docker-compose.yml    # อ่านว่าใช้ port อะไร service อะไร

# Step 3: รัน
docker compose up --build -d

# Step 4: เช็คว่า up ไหม
docker compose ps

# Step 5: ทดสอบ
curl http://localhost:8080
# หรือเปิด browser ไปที่ http://localhost:8080
```

---

### 🩹 แก้ Code แล้ว Redeploy (Defense Workflow)
```bash
# Step 1: แก้ไข code
nano main.go
# หรือ
vim main.go

# Step 2: บันทึกไฟล์

# Step 3: Rebuild และ Deploy
docker compose up --build -d

# Step 4: ตรวจสอบว่า build สำเร็จ
docker compose ps
# STATUS ต้องเป็น "Up" ไม่ใช่ "Exited"

# Step 5: ทดสอบว่า site ยังใช้ได้
curl http://localhost:8080/health
# หรือเปิด browser

# Step 6: ดู log ว่ามี error ไหม
docker compose logs --tail=20 app
```

---

### 🚨 ถ้า Site ล่ม — กู้คืนด่วน!
```bash
# Step 1: ดูว่า container ยัง run อยู่ไหม
docker compose ps

# Step 2: ดู log หา error
docker compose logs --tail=50 app

# Step 3: ถ้า container Exited → restart
docker compose restart app

# Step 4: ถ้า restart ไม่ได้ → down แล้ว up ใหม่
docker compose down
docker compose up -d

# Step 5: ถ้ายังไม่ได้ → rebuild
docker compose up --build -d

# Step 6: ตรวจสอบ
docker compose ps
curl http://localhost:8080
```

---

### 🔍 Patch SQLi แล้ว Verify
```bash
# Step 1: เปิดไฟล์ main.go
nano main.go

# Step 2: หาจุดที่เป็น SQLi
# กด Ctrl+W แล้วพิมพ์ db.Query เพื่อหา

# Step 3: แก้จาก string concat เป็น prepared statement
# ก่อน: db.Query("SELECT * FROM users WHERE id=" + id)
# หลัง: db.Query("SELECT * FROM users WHERE id=$1", id)

# Step 4: บันทึก (Ctrl+X → Y → Enter)

# Step 5: Rebuild
docker compose up --build -d

# Step 6: ทดสอบว่า SQLi ปิดแล้ว
# ลองใส่ ' ใน input field ดูว่ายัง error ไหม
# หรือรัน sqlmap ใส่ตัวเอง
sqlmap -u "http://localhost:8080/api/products?id=1" --dbms=postgresql --batch
# ถ้า sqlmap บอก "not injectable" = ปิดได้แล้ว ✅
```

---

### 📋 Cheatsheet คำสั่งสำคัญ

| คำสั่ง | ทำอะไร |
|---|---|
| `docker compose up -d` | รัน project ใน background |
| `docker compose up --build -d` | rebuild แล้วรัน ← ใช้บ่อยที่สุด |
| `docker compose down` | หยุดและลบ container |
| `docker compose restart app` | restart เฉพาะ app |
| `docker compose ps` | ดูสถานะ container |
| `docker compose logs -f app` | ดู log realtime |
| `docker compose logs --tail=50 app` | ดู log 50 บรรทัดล่าสุด |
| `docker compose exec app sh` | เข้าไปใน container |
| `docker compose exec db psql -U admin -d myapp` | เข้า PostgreSQL |
| `docker stats` | ดู CPU/RAM ที่ใช้ |
| `docker system prune -f` | ลบ cache ที่ไม่ใช้ |

---

### ⚠️ สิ่งที่ต้องระวัง

```
❌ อย่ารัน docker compose down -v
   → จะลบ database ทั้งหมด!

❌ อย่าลืม -d ตอนรัน
   → ถ้าไม่มี -d terminal จะ block อยู่

✅ หลังแก้ code ต้องรัน --build เสมอ
   → ไม่งั้น code เก่าจะยังทำงานอยู่

✅ เช็ค docker compose ps หลัง deploy ทุกครั้ง
   → ตรวจสอบว่า STATUS เป็น "Up" ไม่ใช่ "Exited"
```

---

*คู่มือนี้จัดทำสำหรับ IT Clash 2569 | Cybersecurity Track*
*โชคดีวันแข่งครับ! 🔥*
