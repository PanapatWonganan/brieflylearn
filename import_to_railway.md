# Import Database to Railway

## Copy Connection Details จาก Railway MySQL:
- Host: xxxxx.railway.app
- Port: xxxx
- Username: root
- Password: xxxxxxxxxxxxx
- Database: railway

## คำสั่ง Import:
```bash
mysql -h [HOST] -P [PORT] -u root -p[PASSWORD] railway < /Users/panapat/khun_bebe/database_backup.sql
```

ตัวอย่าง:
```bash
mysql -h monorail.proxy.rlwy.net -P 31177 -u root -pAbC123XyZ railway < /Users/panapat/khun_bebe/database_backup.sql
```

หรือผ่าน MySQL Workbench:
1. New Connection
2. ใส่ Host, Port, Username, Password จาก Railway
3. Test Connection
4. เข้า Connection
5. File → Run SQL Script → เลือก database_backup.sql