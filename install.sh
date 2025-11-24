#!/bin/sh

# OpenWrt Telegram Network Monitor - Install Script
# GitHub: https://github.com/YOUR_USERNAME/openwrt-telegram-monitor

GITHUB_REPO="YOUR_USERNAME/openwrt-telegram-monitor"
GITHUB_RAW="https://raw.githubusercontent.com/${GITHUB_REPO}/main"

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║     OpenWrt Telegram Network Monitor - Installer 📡          ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "GitHub: https://github.com/${GITHUB_REPO}"
echo ""

# Kiểm tra quyền root
if [ "$(id -u)" != "0" ]; then
    echo "❌ Script này cần chạy với quyền root!"
    exit 1
fi

# Kiểm tra kết nối internet
echo "🔍 Kiểm tra kết nối internet..."
if ! ping -c 1 -W 3 github.com > /dev/null 2>&1; then
    echo "❌ Không thể kết nối đến GitHub!"
    echo "   Kiểm tra kết nối internet và thử lại."
    exit 1
fi
echo "✅ Kết nối OK"
echo ""

# Nhập thông tin
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 NHẬP THÔNG TIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Lấy Bot Token từ: @BotFather trên Telegram"
echo "Lấy Chat ID từ: @userinfobot trên Telegram"
echo ""

read -p "Nhập Bot Token: " BOT_TOKEN
read -p "Nhập Chat ID: " CHAT_ID

if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
    echo ""
    echo "❌ Bot Token và Chat ID không được để trống!"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 CÀI ĐẶT PACKAGES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Cập nhật danh sách packages..."
opkg update > /dev/null 2>&1

packages="curl ca-bundle ca-certificates"
for pkg in $packages; do
    if ! opkg list-installed | grep -q "^${pkg} "; then
        echo "Cài đặt $pkg..."
        opkg install $pkg > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ $pkg"
        else
            echo "⚠️  Lỗi khi cài $pkg (có thể đã có sẵn)"
        fi
    else
        echo "✅ $pkg (đã cài)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 TẢI SCRIPTS TỪ GITHUB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p /root/network-monitor

echo "Tải network-monitor.sh..."
curl -sL "${GITHUB_RAW}/scripts/network-monitor.sh" -o /root/network-monitor/network-monitor.sh
if [ $? -eq 0 ]; then
    echo "✅ network-monitor.sh"
else
    echo "❌ Không thể tải network-monitor.sh"
    exit 1
fi

echo "Tải telegram-bot.sh..."
curl -sL "${GITHUB_RAW}/scripts/telegram-bot.sh" -o /root/network-monitor/telegram-bot.sh
if [ $? -eq 0 ]; then
    echo "✅ telegram-bot.sh"
else
    echo "❌ Không thể tải telegram-bot.sh"
    exit 1
fi

chmod +x /root/network-monitor/network-monitor.sh
chmod +x /root/network-monitor/telegram-bot.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  CẤU HÌNH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat > /root/network-monitor/config.sh << EOF
#!/bin/sh
TELEGRAM_BOT_TOKEN="${BOT_TOKEN}"
TELEGRAM_CHAT_ID="${CHAT_ID}"
EOF

chmod +x /root/network-monitor/config.sh
echo "✅ Đã tạo config.sh"

touch /etc/blocked_devices.txt
echo "✅ Đã tạo blocked_devices.txt"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 CẤU HÌNH TỰ ĐỘNG CHẠY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Tạo bot runner
cat > /tmp/bot-runner.sh << 'RUNNER'
#!/bin/sh
while true; do
    /root/network-monitor/telegram-bot.sh > /dev/null 2>&1
    /root/network-monitor/network-monitor.sh > /dev/null 2>&1
    sleep 30
done
RUNNER

chmod +x /tmp/bot-runner.sh
echo "✅ Đã tạo bot-runner.sh"

# Stop old process
if [ -f /tmp/bot.pid ]; then
    old_pid=$(cat /tmp/bot.pid)
    if kill -0 "$old_pid" 2>/dev/null; then
        kill $old_pid 2>/dev/null
        echo "✅ Đã dừng bot cũ"
    fi
fi

# Cấu hình rc.local để tự động khởi động
if ! grep -q "bot-runner.sh" /etc/rc.local 2>/dev/null; then
    sed -i '/^exit 0/d' /etc/rc.local 2>/dev/null
    cat >> /etc/rc.local << 'EOF'

# Network Monitor Bot
if [ -f /tmp/bot-runner.sh ]; then
    /tmp/bot-runner.sh &
fi

exit 0
EOF
    echo "✅ Đã cấu hình rc.local"
fi

# Khởi động bot
/tmp/bot-runner.sh &
BOT_PID=$!
echo $BOT_PID > /tmp/bot.pid
echo "✅ Bot đã khởi động (PID: $BOT_PID)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 TEST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Gửi tin nhắn test..."
sleep 2

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="${CHAT_ID}" \
    -d parse_mode="HTML" \
    -d text="🎉 <b>CÀI ĐẶT THÀNH CÔNG!</b>

📡 <b>OpenWrt Telegram Monitor</b>

Bot đã sẵn sàng!
Gửi /help để xem hướng dẫn.

━━━━━━━━━━━━━━━━━━━━━━
<b>Tính năng:</b>
• 🔔 Thông báo kết nối/ngắt kết nối
• 📱 Quản lý thiết bị qua Telegram
• 🚫 Chặn/bỏ chặn thiết bị
• 📋 Xem danh sách thiết bị" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Đã gửi tin nhắn test đến Telegram!"
else
    echo "⚠️  Không thể gửi tin nhắn test"
    echo "   Kiểm tra Bot Token và Chat ID"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║               ✅ CÀI ĐẶT HOÀN TẤT! 🎉                        ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📱 MỞ TELEGRAM VÀ:"
echo "   1. Gửi /help để xem hướng dẫn"
echo "   2. Gửi /list để xem danh sách thiết bị"
echo ""
echo "🔍 DEBUG (nếu cần):"
echo "   tail -f /tmp/telegram_debug.log"
echo ""
echo "🛑 DỪNG BOT:"
echo "   kill \$(cat /tmp/bot.pid)"
echo ""
echo "🔄 KHỞI ĐỘNG LẠI BOT:"
echo "   /tmp/bot-runner.sh &"
echo "   echo \$! > /tmp/bot.pid"
echo ""
echo "📖 HƯỚNG DẪN ĐẦY ĐỦ:"
echo "   https://github.com/${GITHUB_REPO}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
