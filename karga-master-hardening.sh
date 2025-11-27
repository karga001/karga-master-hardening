#!/bin/bash
# master_hardening.sh
# Debian 13 stable (trixie) cinnamon edition hardening-anonimlik paketi

set -euo pipefail

echo "[*] Master hardening ve anonimlik scripti başlıyor..."

# 1) Paketler 
apt update -y
apt install -y --no-install-recommends usbguard firejail apparmor-utils \
    macchanger ufw tlp tlp-rdw powertop

# 2) MAC adresleri
echo "[*] MAC adresleri rastgele değiştiriliyor..."
for iface in $(ls /sys/class/net/ | grep -v -E 'lo|bluetooth|usb'); do
    ip link set dev "$iface" down
    macchanger -r "$iface"
    ip link set dev "$iface" up
done

# 3) DNS ayarları
echo "[*] DNS ayarları uygulanıyor..."
RESOLV_CONF="/etc/resolv.conf"
# immutable ise kaldır
chattr -i $RESOLV_CONF 2>/dev/null || true
echo -e "nameserver 1.1.1.1\nnameserver 9.9.9.9" | tee $RESOLV_CONF > /dev/null

# 4) Kernel & sysctl hardening 
echo "[*] Kernel ve sysctl hardening uygulanıyor..."
SYSCTL_CONF="/etc/sysctl.d/99-master-hardening.conf"

cat > "$SYSCTL_CONF" <<'EOF'
# NETWORK HARDENING
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.arp_ignore = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# KERNEL HARDENING
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.randomize_va_space = 2
kernel.yama.ptrace_scope = 2
kernel.perf_event_paranoid = 3
kernel.unprivileged_userns_clone = 0
kernel.unprivileged_bpf_disabled = 1
kernel.kexec_load_disabled = 1

# SYSTEM HARDENING 
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_regular = 1
fs.suid_dumpable = 0
fs.protected_fifos = 1
EOF

sysctl --system >/dev/null 2>&1 || true

#  5) Gereksiz servisler
echo "[*] Gereksiz servisler durduruluyor..."
SERVICES=(avahi-daemon cups telnet ftp rpcbind modemmanager triggerhappy)
for s in "${SERVICES[@]}"; do
    systemctl stop "$s" 2>/dev/null || true
    systemctl disable "$s" 2>/dev/null || true
done

# 6) SSH hardening
if [ -f /etc/ssh/sshd_config ]; then
    echo "[*] SSH sertleştiriliyor..."
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config || true
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config || true
    sed -i 's/#PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config || true
    systemctl restart sshd 2>/dev/null || true
fi

# 7) Firewall (UFW)
echo "[*] UFW firewall yapılandırılıyor..."
ufw default deny incoming
ufw default allow outgoing
systemctl is-active --quiet ssh && ufw allow ssh
ufw --force enable

# 8) USB koruması
echo "[*] USB koruması uygulanıyor..."
cat > /etc/udev/rules.d/99-block-badusb.rules <<'EOF'
SUBSYSTEM=="usb", ATTR{bDeviceClass}=="00", ATTR{product}!="Keyboard", ATTR{product}!="Mouse", ATTR{product}!="USB Receiver", ATTR{product}!="Receiver", MODE="0660"
EOF

# 9) Firejail & AppArmor
echo "[*] Firejail ve AppArmor yapılandırılıyor..."
systemctl enable apparmor --now

FJ_PROFILE="/etc/firejail/firefox.profile"
if [ -f "$FJ_PROFILE" ]; then
    grep -q "noroot" "$FJ_PROFILE" || echo "noroot" >> "$FJ_PROFILE"
fi

WRAP="/usr/local/bin/firefox-firejail"
cat > "$WRAP" <<'EOF'
#!/bin/bash
if [ -x /usr/bin/firefox ]; then
  exec firejail --profile=/etc/firejail/firefox.profile /usr/bin/firefox "$@"
elif [ -x /usr/bin/firefox-esr ]; then
  exec firejail --profile=/etc/firejail/firefox.profile /usr/bin/firefox-esr "$@"
fi
EOF
chmod +x "$WRAP"

# 10) Pil ve güç yönetimi
echo "[*] Pil optimizasyonu uygulanıyor..."
systemctl enable tlp --now
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo schedutil > "$cpu/cpufreq/scaling_governor" || true
done
powertop --auto-tune || true

for disk in /sys/block/sd*; do
    echo 1 > "$disk/device/queue/rotational" 2>/dev/null || true
done

# 11) Tehlikeli dizinlere  noexec uygulanıyor 
echo "[*] /tmp, /var/tmp, /dev/shm için noexec..."
mount -o remount,noexec /tmp || true
mount -o remount,noexec /var/tmp || true
mount -o remount,noexec /dev/shm || true

# 12) Dosya izinleri 
echo "[*] Önemli dosya izinleri ayarlanıyor..."
chmod 600 /etc/shadow /etc/gshadow
chmod 600 /etc/ssh/ssh_host_* 2>/dev/null || true

echo "[*] Master Hardening & Anonimlik tamamlandı"
echo "Karga tarafından yapılmıştır."
