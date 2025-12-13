Bu script kurumsal (enterprise) tehdit modellerini hedeflemez; Debian 13 stable üzerinde günlük kullanım için optimize edilmiştir.

## 1) Bu script ne iş yapıyor?

Bu script, sistemi gereksiz bileşenlerle şişirmeden, doğrudan güvenlik odaklı olacak şekilde hardening uygular.

Amaç; saldırı yüzeyini küçültmek, zayıf noktaları kapatmak ve olası bir saldırı durumunda saldırganın ilerlemesini zorlaştırmak, yavaşlatmak ve bazı senaryolarda tamamen engellemektir.

## 2) Script şunları yapar:

Ağ, DNS, firewall, USB, sandbox ve kernel seviyesinde katı güvenlik kuralları uygular

Sistem servislerini, dosya izinlerini ve kernel parametrelerini daha güvenli hâle getirir

Gereksiz servisleri devre dışı bırakır ve potansiyel riskleri temizler

Tarayıcı ve kritik uygulamaları Firejail + AppArmor ile izole eder

MAC adresi, DNS ve network fingerprinting gibi iz bırakabilecek yüzeyleri azaltır

Olası bir exploit sonrası zararın sistem geneline yayılmasını sınırlar

Saldırı yüzeyini küçülterek gereksiz açık noktaları kapatır

Günlük kullanımda fark edilmeyen ancak kritik öneme sahip zayıflıkları otomatik olarak giderir

Özet:
Bu script saldırıları imkânsız hâle getirme iddiasında değildir; ancak saldırganın işini ciddi şekilde zorlaştırır, zaman ve kaynak kaybettirir.

## 3) Kime karşı etkili?

Bu script “devlet seviyesi” koruma sağlamaz; ancak günlük hayatta karşılaşılabilecek saldırgan profillerinin %90’ından fazlasını etkisiz hâle getirir.

Etkili olduğu saldırgan profilleri:

Hazır exploit arayan, tool çalıştırıp şans deneyen kişiler

nmap / naabu / nessus gibi araçlarla otomatik tarama yapanlar

IPv4 taraması yaparak açık port kovalayan botlar

Lokal exploit deneyen, tarayıcı üzerinden sistem içine girmeye çalışanlar

USB üzerinden payload veya HID injection denemeleri yapanlar

Discord, forum ve hazır kaynaklardan toplanmış exploit’lerle saldıranlar

MAC, DNS ve fingerprinting üzerinden iz sürmeye çalışan düşük seviye saldırganlar

Kernel hardening’i aşamayan, privilege escalation kovalayanlar

Yan servisler üzerinden sisteme sızmayı hedefleyen saldırganlar

Bu seviyedeki saldırganların tamamı ya durdurulur ya da etkisiz hâle getirilir.

## 4) Engelleyebildiği / zorlaştırdığı saldırılar

Bu script tarafından doğrudan engellenen veya ciddi şekilde zorlaştırılan saldırılar:

Tarayıcı exploit’lerinden sonra sistem içine yayılma girişimleri

MAC, DNS ve fingerprinting tabanlı kimlik tespiti denemeleri

BadUSB, HID injection, sahte klavye/mouse tabanlı USB saldırıları

Dışarıdan port tarama ve servis keşfi girişimleri

Yan servisler üzerinden içeri sızma senaryoları

Temel ağ tabanlı saldırılar ve düşük seviye paket manipülasyonları

Kernel parametreleri üzerinden yapılan bazı zorlama yöntemleri

Firejail ve AppArmor bypass denemelerinin büyük bir kısmı

Sonuç:
Ortalama bir saldırgan bu sisteme doğrudan erişim sağlayamaz.

## 5) Kimler hâlâ sızabilir?

Bu script güçlüdür; ancak fizik kurallarını, insan hatasını ve 0-day ekosistemini ortadan kaldıramaz.

Bu hardening ile içeri giremeyenler:

Script-kiddie profilleri

Otomatik botlar

Kopyala-yapıştır exploit kullananlar

USB / payload denemecileri

Tarayıcı exploit’inden doğrudan shell bekleyenler

Mass-scan yapan saldırganlar

Bu hardening ile zorlananlar:

Deneyimli bireysel saldırganlar

Linux privilege escalation bilgisi olan kişiler

Network pivot ve yan servis kovalayanlar

# Bu hardening’i aşabilecek tek grup:

APT seviyesinde, özel exploit geliştirebilen profesyonel ekipler

Fiziksel erişimi olan saldırganlar

Bu script bu seviyeye karşı tam koruma iddiasında bulunmaz.
Ama saldırı yüzeyini daraltır, eşiği yükseltir ve maliyeti artırır.

## 6) Hangi araçları kullanıyor?

Bu script sistemde zaten bulunan mekanizmaları kullanır; harici, gereksiz bağımlılıklar eklemez.

Kullanılan araçlar:

UFW → Basit ama etkili firewall

AppArmor → Kernel seviyesinde confinement

Firejail → Uygulama sandbox’ı

USBGuard → USB saldırılarına karşı kontrol katmanı

macchanger → MAC adresi rastgeleleştirme

TLP → Güç yönetimi ve optimizasyon

Powertop → Agresif enerji ayarları

sysctl → Ağ, kernel ve bellek parametreleri

systemd → Gereksiz servisleri kapatma

DNS ayarları → Güvenli resolver ve sızıntı engelleme

## 7) Script tam olarak ne yapıyor?

MAC adreslerini rastgeleleştirir

DNS’i güvenli moda alır ve sızıntıları engeller

UFW firewall’ı varsayılan olarak deny-all inbound hâline getirir

AppArmor profillerini aktif eder

Firejail ile tarayıcı ve kritik uygulamaları sandbox’a alır

USBGuard ile USB cihazlarını kontrol altına alır

Kernel ve sysctl parametrelerini sertleştirir

Gereksiz servisleri kapatır

Güç ve disk erişim ayarlarını optimize eder

/tmp, /var/tmp, /dev/shm için noexec / nosuid uygular

Kritik dosyalar için izin sıkılaştırması yapar

# Kullanım:
```
git clone https://github.com/karga001/karga-master-hardening.git
cd karga-master-hardening/
chmod +x karga-master-hardening.sh
sudo ./karga-master-hardening.sh
```

# Kalıcı yapmak için:
```
sudo nano /etc/systemd/system/hardening.service
```

# Dosyanın içine yapıştırın:
```
[Unit]
Description=Karga Hardening
After=network.target local-fs.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/home/KULLANICIADI/karga-master-hardening/karga-master_hardening.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

# Etkinleştirmek için:
```
sudo systemctl daemon-reload
sudo systemctl enable hardening.service
sudo systemctl start hardening.service
```


