<!-- ( vim: set fenc=utf-8 spell spl=en: ) -->

# Proxy for ``ir-keytable``

``ir-proxy`` can be used on a [pipeline][wikipedia:pipeline] to process
``ir-keytable`` output and propagate key events. It uses adapters
(``xdotool``) to send key events to the [display server][wikipedia:xorg].

``ir-proxy`` conforms to [XDG Base Directory][freedesktop:basedir-spec],
as a result, [configuration][file:config] file is located:

```sh
${XDG_CONFIG_HOME:-~/home/.config}/ir-proxy/config.yml
```

## Sample commands

```sh
sudo socat - EXEC:'ir-keytable -D 550 -P 150 -t',pty | sudo -u user ir-proxy pipe
```

```sh
sudo socat - EXEC:'ir-keytable -D 550 -P 150 -t',pty | sudo -u user ir-proxy pipe --config /etc/ir-proxy/config.yml
```

## Sample ``systemd`` service

```ini
# /lib/systemd/system/ir-proxy.service
[Unit]
Description=Remote support service
PartOf=graphical-session.target
ConditionPathExists=/dev/tty20

[Service]
Type=simple
ExecStart=/usr/local/bin/_ir-proxy user
StandardInput=tty-fail
StandardOutput=tty
User=root
TTYVHangup=yes
TTYPath=/dev/tty20
TTYReset=yes
RemainAfterExit=false
Restart=always
RestartSec=1s

[Install]
WantedBy=default.target
```

```sh
#!/usr/bin/env sh
# /usr/local/bin/_ir-proxy

export DISPLAY=${2:-:0}
set -eu
X_USER=${1}
LOGFILE=/var/log/ir-proxy.log
CONFIG=/etc/ir-proxy/config.yml
export XAUTHORITY=$(getent passwd "${X_USER}" | cut -d: -f6)/.Xauthority

touch "${LOGFILE}"
chown "${X_USER}" "${LOGFILE}"
(socat - EXEC:'ir-keytable -D 550 -P 150 -t',pty,setsid,ctty | \
    sudo -Eu "${X_USER}" ir-proxy pipe --config "${CONFIG}") > "${LOGFILE}" 2>&1
```

```sh
sudo systemctl enable ir-proxy.service
```

## Sample keymap

```xml
<!-- ~/.kodi/userdata/keymaps/mce-vista.xml -->
<keymap>
  <global>
    <keyboard>
     <power>XBMC.ShutDown()</power>
     <f12>XBMC.ActivateWindow(Home)</f12>
    </keyboard>
  </global>
</keymap>
```

## Extract available keys

```sh
grep -Eo 'KEY_.*' /lib/udev/rc_keymaps/rc6_mce.toml | tr -d '"' | sort | perl -pe 's/^KEY_//' | sort -u | perl -pe 's/^(.*)$/  \1:/g'
```

## Resources

* [ir-keytable on the Orange Pi Zero](https://www.sigmdel.ca/michel/ha/opi/ir_03_en.html)
* [List of Keysyms Recognised by Xmodmap](http://wiki.linuxquestions.org/wiki/List_of_Keysyms_Recognised_by_Xmodmap)
* [XF86 keyboard symbols](http://wiki.linuxquestions.org/wiki/XF86_keyboard_symbols)
* [Keyboard controls - Official Kodi Wiki](https://kodi.wiki/view/Keyboard_controls)
* [Remote controller tables — The Linux Kernel documentation](https://www.kernel.org/doc/html/v4.14/media/uapi/rc/rc-tables.html)


<!-- hyeprlinks -->

[file:config]: ./config.sample.yml
[wikipedia:pipeline]: https://en.wikipedia.org/wiki/Pipeline_(Unix)
[wikipedia:xorg]: https://en.wikipedia.org/wiki/X.Org_Server
[freedesktop:basedir-spec]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
