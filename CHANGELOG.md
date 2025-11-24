# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-11-24

### Added
- Initial release
- Real-time device connection/disconnection notifications
- Telegram bot commands (/list, /block, /unblock, /blocked, /help)
- Automatic hostname cleaning (max 20 characters)
- Code tags for easy IP/MAC copying
- Debug logging
- Auto-start on boot
- One-command installation from GitHub

### Features
- 🔔 Real-time notifications
- 📱 Telegram bot management
- 🎨 Beautiful HTML formatting with emojis
- 📋 Automatic hostname processing
- 📝 IP/MAC in `<code>` tags for easy copying
- 🚀 One-command install
- 🔄 Auto-restart on reboot
- 🐛 Debug logging support

### Technical Details
- Compatible with OpenWrt
- Uses `dhcp.leases` for device tracking
- Monitors via `/proc/net/arp`
- Blocks devices using `iptables`
- Runs every 30 seconds
- Persistent blocked device list

---

## [Future]

### Planned
- [ ] Web UI dashboard
- [ ] Multiple admin support
- [ ] Device grouping
- [ ] Bandwidth monitoring
- [ ] Notification scheduling
- [ ] Custom alerts
- [ ] Device nickname support
