Bu script kurumsal (enterprise) tehdit modellerini hedeflemez; Debian 13 stable üzerinde günlük kullanım için optimize edilmiştir.

1) Bu script ne iş yapıyor?
Bu script sistemi gereksiz şişirmeden, boş laf üretmeden net şekilde sıkılaştırır.
Amaç: saldırganın işini zorlaştırmak, açık kapıları kapatmak, zayıf noktaları minimuma indirmek.
Script şunları yapar:
    • Ağ, DNS, firewall, USB, sandbox ve çekirdek tarafında katı kurallar uygular
    • Sistem servislerini, izinlerini ve kernel parametrelerini daha güvenli hâle getirir
    • Gereksiz servisleri kapatır, gereksiz riskleri temizler
    • Tarayıcıyı ve uygulamaları firejail + apparmor ile ayrı kafeslere alır
    • MAC, DNS, network fingerprinting gibi iz bırakabilecek noktaları törpüler
    • Exploit geldiğinde zararın yayılmasını sınırlar
    • Saldırı yüzeyini küçültür, gereksiz açık kapıları kapatır
    • Günlük kullanımda fark edilmeyen ama kritik olan zayıflıkları otomatik kapatır
Özet: Bu script saldırıyı imkânsız yapmaz; uğraştırır, zaman kaybettirir, bazı noktalarda saf dışı bırakır.
3) Kime karşı etkili?
Bu script bir anda “devlet seviyesi koruma” vermez ama günlük hayatta karşılaşacağın saldırganların %90’ını boğar.
Durdurduğu profil:
    • Hazır exploit arayan, tool çalıştırıp şans deneyen, nmap/naabu/nessus tarayıp açık kovalayanlar
    • IPv4’ü süpüren, zayıf port arayan, exploit paketleyen otomatik botlar 
    • Lokal exploit deneyen, browser’dan içeri girmeye çalışan, USB’den payload sokmaya uğraşanlar
    • Discord’dan topladığı exploit’lerle sisteme girmeye çalışanlar
    • MAC/DNS üzerinden iz sürmeye çalışan yarım yamalak saldırganlar
    • Kernel hardening’i geçemeyen, privilege escalation kovalayan, network pivot denemek isteyen insanlar
    • Yan servislerden dolanıp içeri yürümeyi hedefleyen çakallar
    • Ağ üzerinden “ufak tefek paket oyunları” ile içeri sızacağını düşünenler
Bu düzeydeki herkesin önünü keser.

4) Engelleyebildiği/zorlaştırdığı saldırılar
Scriptin tam olarak kestiği veya ciddi şekilde zorlaştırdığı şeyler:
    • Tarayıcı istismarından sonra sistem içine yayılma girişimleri
    • MAC, DNS, fingerprinting ile kimlik izi çıkarma denemeleri
    • BadUSB, HID injection, sahte klavye/mouse gibi USB saldırıları
    • Dışarıdan port tarama, servis tespiti, açık servis bulma çabaları
    • Yan servisler üzerinden içeri dolanma senaryoları
    • Temel ağ tabanlı saldırılar, düşük seviye paket manipülasyonları
    • Kernel parametreleri üzerinden yapılabilecek bazı zorlama yöntemleri
    • Firejail/AppArmor bypass denemelerinin büyük kısmı
Kısaca ortalama saldırgan bu sisteme dokunamaz.

5) Kimler hâlâ sızabilir?
Bu script güçlü, evet.
Ama fiziksel kuralları, insan kaynaklı salaklık düzeyi(sosyal mühendislik ve bilinmeyen içeriğe yetki verme) ve 0‑day piyasasını yenemez.
Bu hardening ile içeri giremeyenler:
    • Script‑kiddie çöplüğü
    • Discord/YouTube hırdavatçıları
    • Otomatik botlar
    • Kopyala‑yapıştır exploitçiler
    • “Port taradım açık yok mu” 
    • USB/Payload denemecileri
    • Tarayıcı exploit’inden shell bekleyenler
    • Ele geçirme umuduyla mass‑scan yapan kitle
Bu hardening ile zorlananlar:
    • Deneyimli bireysel saldırganlar
    • Linux privilege‑escalation uzmanları
    • Network pivot ve yan servis kovalayanlar
Bu hardening’i aşabilecek tek grup:
    • APT düzeyi, özel exploit geliştiren gerçek profesyoneller
    • Fiziksel erişimi olan ekipler
Bu script bu seviyeye karşı “tam koruma” iddiasında olmaz — kimse olamaz.
Ama saldırı yüzeyini daraltır, açıklarını azaltır, eşiği yükseltir.



6) Hangi araçları kullanıyor?
Bu script sistemde zaten bulunan mekanizmaları sonuna kadar kullanıyor, dışarıdan çöplük taşımıyor.
Kullanılan araçlar:
    • UFW → basit ama etkili firewall
    • AppArmor → çekirdek seviyesinde confinement
    • Firejail → uygulama sandbox’ı
    • USBGuard → USB saldırılarına karşı kontrol katmanı
    • macchanger → MAC rastgeleleştirme
    • TLP → pil/enerji optimizasyonu (gereksiz güç tüketimi = gereksiz saldırı yüzeyi)
    • Powertop → derin enerji ayarı (agresif modda)
    • sysctl → ağ, kernel ve hafıza tarafında sıkı parametreler
    • systemd → gereksiz servis kapatma / temizleme
    • dns ayarları → güvenli resolver, sızıntı engelleme

7) Script tam olarak ne yapıyor?
• MAC adreslerini rastgeleleştirir
Kimlik izi çıkarmayı zorlaştırır.
Ağ tarafında iz sürmeyi ciddi anlamda baltalar.
• DNS’i güvenli moda çeker
DNS sızıntılarını keser, takip ve yönlendirme saldırılarını zorlaştırır.
• UFW firewall’ı kapı duvarına çevirir
Gelen her şey engellenir, sadece çıkış izni kalır.
İçeriye doğru açık port = sıfır.
• AppArmor’u aktif edip profilleri devreye alır
Tarayıcı ve kritik uygulamalar kernel seviyesinde çitlenir.
Exploit gelse bile hareket alanı dardır.
• Firejail ile tarayıcı ve hassas uygulamalar sandbox’a alınır
Dosya sistemine, ağ kaynaklarına ve proseslere erişim kesilir.
Saldırgan tarayıcıdan çıkamaz.
• USBGuard ile USB cihazları kontrol altına alınır
HID injection, BadUSB, klavye/mouse taklidi yapan cihazlar bloklanır.
• Kernel ve sysctl parametrelerini sertleştirir
Ağ güvenliği, bellek rastgeleliği, TCP stack davranışı, spoofing önlemleri…
Linux’un defolt ayarındaki çoğu gevşek nokta kapanır.
• Gereksiz servisler kapatılır
Arka planda duran, işlevi olmayan, ama saldırı yüzeyi açan ne varsa gömülür.
• Pil ve güç ayarları optimize edilir
Gereksiz donanım aktiviteleri azalır → saldırı yüzeyi küçülür → stabilite artar.
• Disk tarafındaki bazı enerji/erişim parametreleri sıkılaştırılır
Arka plan disk I/O davranışlarını iyileştirir.
• /tmp, /var/tmp, /dev/shm için noexec/nosuid uygulanır
Bellek içi dosya sisteminden exploit çalıştırmayı zorlaştırır.
Birçok tarayıcı exploit zinciri burada patlar.
• Önemli dosyalara izin sıkılaştırması uygulanır
SUID, world-writable gibi saçmalıklar temizlenir.
