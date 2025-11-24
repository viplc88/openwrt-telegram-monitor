# 📡 OpenWrt Telegram Network Monitor

**Giám sát mạng OpenWrt với Telegram Bot - Thông báo kết nối/ngắt kết nối thiết bị real-time**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-Compatible-blue.svg)](https://openwrt.org/)
[![Telegram Bot](https://img.shields.io/badge/Telegram-Bot-blue.svg)](https://telegram.org/)

## ✨ Tính năng

- 🔔 **Thông báo real-time** khi thiết bị kết nối/ngắt kết nối
- 📱 **Quản lý qua Telegram** - Xem danh sách, chặn/bỏ chặn thiết bị
- 🎨 **Giao diện đẹp** - Emoji, format HTML, dễ đọc
- 📋 **Hostname tự động** - Làm sạch và giới hạn 20 ký tự
- 📝 **Code tag** - IP/MAC trong `<code>` để dễ copy
- 🚀 **Cài đặt nhanh** - Chỉ 1 lệnh duy nhất
- 🔄 **Tự động khởi động** - Chạy ngay sau reboot
- 🐛 **Debug logging** - Dễ dàng troubleshoot

## 📸 Screenshots

**Thông báo kết nối:**
```
🟢 THIẾT BỊ KẾT NỐI

📱 Hostname: iPhone_13
🌐 Địa chỉ IP: 192.168.1.100
🔖 Địa chỉ MAC: AA:BB:CC:DD:EE:FF
⏰ Thời gian: 14:30:45 24/11/25
📊 Trạng thái: Đang hoạt động
```

**Danh sách thiết bị:**
```
📋 DANH SÁCH THIẾT BỊ

1. 🟢 iPhone_13
📱 Hostname: iPhone_13
🌐 IP: 192.168.1.100
🔖 MAC: AA:BB:CC:DD:EE:FF

📊 Tổng: 5 | 🟢 4 | 🚫 1
```

## 🚀 Cài đặt nhanh

### Yêu cầu

- OpenWrt router
- Telegram Bot Token (từ [@BotFather](https://t.me/BotFather))
- Telegram Chat ID (từ [@userinfobot](https://t.me/userinfobot))

### Cài đặt 1 lệnh

```bash
wget -O - https://raw.githubusercontent.com/viplc88/openwrt-telegram-monitor/main/install.sh | sh
```

Hoặc cách thủ công:

```bash
# 1. Tải script
wget https://raw.githubusercontent.com/viplc88/openwrt-telegram-monitor/main/install.sh

# 2. Chạy
sh install.sh
```

Script sẽ hỏi:
- Bot Token (từ @BotFather)
- Chat ID (từ @userinfobot)

Sau đó tự động:
1. Cài đặt packages cần thiết
2. Tạo các script
3. Cấu hình cron/rc.local
4. Khởi động bot
5. Gửi tin nhắn test

## 📖 Hướng dẫn chi tiết

### 1. Tạo Telegram Bot

1. Mở Telegram, chat với [@BotFather](https://t.me/BotFather)
2. Gửi `/newbot`
3. Đặt tên bot (vd: "My Network Monitor")
4. Đặt username (vd: "my_network_bot")
5. Copy **Bot Token** (dạng: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)

### 2. Lấy Chat ID

1. Chat với [@userinfobot](https://t.me/userinfobot)
2. Bot sẽ trả về Chat ID của bạn (dạng: `123456789`)

### 3. Cài đặt

SSH vào OpenWrt router:

```bash
ssh root@192.168.1.1
```

Chạy lệnh cài đặt:

```bash
wget -O - https://raw.githubusercontent.com/viplc88/openwrt-telegram-monitor/main/install.sh | sh
```

Nhập Bot Token và Chat ID khi được hỏi.

### 4. Kiểm tra

Gửi `/help` trên Telegram → Bot sẽ phản hồi trong 30 giây!

## 🎮 Lệnh Telegram

| Lệnh | Mô tả |
|------|-------|
| `/list` | Xem danh sách tất cả thiết bị |
| `/blocked` | Xem thiết bị bị chặn |
| `/block MAC` | Chặn thiết bị (vd: `/block AA:BB:CC:DD:EE:FF`) |
| `/unblock MAC` | Bỏ chặn thiết bị |
| `/help` | Hiển thị hướng dẫn |

## 🔧 Cấu hình

Các file quan trọng:

```
/root/network-monitor/
├── config.sh              # Cấu hình Bot Token và Chat ID
├── network-monitor.sh     # Script giám sát kết nối
└── telegram-bot.sh        # Script xử lý lệnh Telegram

/etc/blocked_devices.txt   # Danh sách thiết bị bị chặn
/tmp/telegram_debug.log    # Debug log
```

### Thay đổi cấu hình

Chỉnh sửa Bot Token hoặc Chat ID:

```bash
vi /root/network-monitor/config.sh
```

## 🐛 Troubleshooting

### Bot không phản hồi

1. Kiểm tra bot có chạy không:
```bash
ps | grep bot
```

2. Xem debug log:
```bash
tail -f /tmp/telegram_debug.log
```

3. Test thủ công:
```bash
/root/network-monitor/telegram-bot.sh
```

### Không nhận thông báo kết nối

1. Kiểm tra monitor có chạy không:
```bash
cat /tmp/network_monitor.log
```

2. Kiểm tra cron:
```bash
crontab -l
```

### Khởi động lại bot

```bash
# Nếu dùng fix-now.sh
kill $(cat /tmp/bot.pid)
sh /tmp/fix-now.sh

# Nếu dùng cron
/etc/init.d/cron restart
```

## 🔄 Cập nhật

```bash
# Tải script mới
wget https://raw.githubusercontent.com/viplc88/openwrt-telegram-monitor/main/install.sh

# Chạy lại (giữ nguyên danh sách blocked)
sh install.sh
```

## 📝 Ghi chú

- Hostname tự động làm sạch, giới hạn 20 ký tự
- Ký tự đặc biệt thay bằng `_`
- IP/MAC trong `<code>` tag để dễ copy
- Danh sách blocked được lưu sau reboot
- Bot kiểm tra Telegram mỗi 30 giây

## 🤝 Đóng góp

Contributions, issues và feature requests luôn được chào đón!

1. Fork dự án
2. Tạo branch (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add some AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License

Dự án này được phân phối dưới [MIT License](LICENSE).

## 👤 Tác giả

**Your Name**

- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)

## ⭐ Star History

Nếu dự án này hữu ích, hãy cho một star! ⭐

## 🙏 Cảm ơn

- [OpenWrt](https://openwrt.org/) - Router OS tuyệt vời
- [Telegram Bot API](https://core.telegram.org/bots/api) - API mạnh mẽ
- Tất cả contributors!

---

**Made with ❤️ for OpenWrt Community**
