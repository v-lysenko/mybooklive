# Описание #
"Внутри" накопителей серии MyBook Live работает Debian GNU/Linux 5 "Lenny". Обновить его и доустановить нужные программы (особенно, совеременных версий) трудно или практически невозможно. В процессе копания интернетов мною были почерпнуты различные интересные идеи и предпринята попытка свести наиболее понравившиеся в одну систему.

## Что получилось ##
  * ~~Исправление репозиториев для Debian 5 _(правка sources.list)_. Блокировка версии udev, для предотвращения развала системы при (случайном) обновлении~~ (нет необходимости изменять стандартную прошивку);
  * Отключение назойливой принудительной парковки головок hdd _(продлит срок службы жёсткого диска)_;
  * Установка пакетного менеджера системы Optware - **ipkg** _(репозитории специально собраных программных пакетов - те же htop, mc, most, etc)_ с автозапуском сервисов Optware на старте устройства;
  * Установка полноценного Debian testing в chroot и настройка запуска нужных сервисов из chroot при запуске устройства;
  * Лёгкое восстановление произведённых модификаций _(в том числе данной системы)_ после обновления прошивки;

### Как использовать ###
  * **/root/.bin/mychroot** - позволяет быстро зайти в chroot, либо запустить внутри него нужную программу _($ mychroot.sh progname arg1 ... argN)_;
  * **/root/.bin/createReadonlyPublicShare.sh** - возможность создать публичный ресурс (шару) с доступом только на чтение _(может пригодиться, если нужно выложить какую-то информацию, которую никто посторонний не должен модифицировать, например, всяческие справочники и т.д.)_;

### Как модифицировать для своих нужд ###
  * **/etc/opt/restore-configs.sh** - запускается в процессе процедуры восстановления, выполняя заданные пользователем команды. Изначально отсутствует, составляется пользователем на доступном в оригинальной прошивке shell.
  * **/etc/opt/chroot-services** - содержит список демонов (сервисов), которые должны быть запущены внутри chroot. Изначально пуст. Должен содержать имена файлов из директории /etc/init.d чрута. Соответствующие сервисы будут запущены после старта устройства и остановлены перед выключением.

---

# Installation #

## Stable ##
wget -O - http://mybooklive.googlecode.com/files/mybooklive-stable.sh | sh

## Trunk ##
wget -O - http://mybooklive.googlecode.com/files/mybooklive.sh | sh

---

[WD MyBook Live & Live Duo](http://www.wdc.com/ru/products/products.aspx?id=280) contains old broken crippled debian 5. Enduser can't use and modify it in safe way. So I'll try to fix this unfairness...
## This will ##
  * ~~Fix repositories, hold udev~~ (no need to modify original firmware)
  * Install optware
  * Disable load cycle count for hdd
  * Install Debian testing in chroot
  * Keep all previous things on /DataVolume/custom, so you can restore you customizations after firmware upgrade in few seconds

---

## Scripts & configs ##
  * **/root/.bin/mychroot** will allow you run any program in your chroot and enter the chroot
  * **/root/.bin/createReadonlyPublicShare.sh** - no comments ;)
  * **/etc/opt/restore-configs.sh** will help you to restore your customizations in rootfs
  * **/etc/opt/chroot-services** should contain chroot init-script names

---

### Links ###
_[1](http://mybookworld.wikidot.com/mybook-live), [2](http://colekcolek.com/2011/12/20/hack-wd-book-live/), [3](http://wiki.debian.org/Debootstrap)_


---

_Sorry for my bad engRish))_