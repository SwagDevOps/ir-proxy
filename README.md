<!-- ( vim: set fenc=utf-8 spell spl=en: ) -->

# Proxy for ``ir-keytable``

``ir-proxy`` can be used on a [pipeline][wikipedia:pipeline] to process
``ir-keytable`` output and propagate key events.
``ir-proxy`` uses adapters (``xdotool``) to send key events to the [display server][wikipedia:xorg].
``ir-proxy`` conforms to the [XDG Base Directory][freedesktop:basedir-spec].
As a result, [configuration file][file:config] file is located:

```sh
${XDG_CONFIG_HOME:-~/.config}/ir-proxy/config.yml
```

## Synopsys

```
Commands:
  ir-proxy config          # Display config
  ir-proxy help [COMMAND]  # Describe available commands or one specific command
  ir-proxy pipe            # React to STDIN events
  ir-proxy sample          # Print samples on STDOUT
```

## Sample commands

```sh
sudo socat - EXEC:'ir-keytable -tc -D 850 -P 250',pty,setsid,ctty | sudo -u $(whoami) ir-proxy pipe
```

```sh
sudo socat - EXEC:'ir-keytable -tc',pty | sudo -u $(whoami) ir-proxy pipe
```

```sh
sudo socat - EXEC:'ir-keytable -tc',pty | sudo -u $(whoami) ir-proxy pipe --config /etc/ir-proxy/config.yml
```

### Testing

```sh
bundle install --standalone
sudo socat - EXEC:'ir-keytable -tc',pty | ruby bin/ir-proxy pipe --config config.sample.yml
```

## Install ``production`` only

```shell
bundle install --standalone --without development test doc repl
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
(socat - EXEC:'ir-keytable -tc',pty,setsid,ctty | sudo -nEu "${X_USER}" -- ir-proxy pipe --config "${CONFIG}") > "${LOGFILE}" 2>&1
```

```sh
sudo systemctl enable ir-proxy.service
```

## Sample ``kodi`` keymap

```xml
<!-- ~/.kodi/userdata/keymaps/ir-proxy.xml -->
<keymap>
  <global>
    <keyboard>
      <f12>ActivateWindow(Home)</f12>
      <power>ActivateWindow(ShutdownMenu)</power>
    </keyboard>
  </global>
</keymap>
```

## Disable poweroff button

Disable poweroff button (e.g. against occasional pressing on remote)<br />
edit ``/etc/systemd/logind.conf`` file

```ini
HandlePowerKey=ignore
```

## Extract available keys to a YAML syntax

```sh
grep -Eo 'KEY_.*' /lib/udev/rc_keymaps/rc6_mce.toml | perl -pe 's/\s+=\s+/: /g' | perl -pe 's/:\s+"KEY_/: "/'
```

## Resources

* [ir-keytable on the Orange Pi Zero](https://www.sigmdel.ca/michel/ha/opi/ir_03_en.html)
* [List of Keysyms Recognised by Xmodmap](http://wiki.linuxquestions.org/wiki/List_of_Keysyms_Recognised_by_Xmodmap)
* [XF86 keyboard symbols](http://wiki.linuxquestions.org/wiki/XF86_keyboard_symbols)
* [Keyboard controls - Official Kodi Wiki][kodi.wiki/keyboard_controls]
* [Remote controller tables — The Linux Kernel documentation](https://www.kernel.org/doc/html/v4.14/media/uapi/rc/rc-tables.html)
* [xdotool | Linux man page](http://linuxcommandlibrary.com/man/xdotool.html)
* [xbmc-system/keymaps/keyboard.xml][xbmc/system/keymaps/keyboard]
* [xdotool list of key codes][wikis/xdotool-list-of-key-codes]
* [XF86 keyboard symbols][wikis/XF86_keyboard_symbols]
* [List of built-in functions - Official Kodi Wiki][kodi.wiki/built-in_functions]
* [Window IDs - Official Kodi Wiki][kodi.wiki/window_IDs]
* [Raspberry Pi4 and kodi as mediacenter](https://medium.com/@stas.berkov/raspberry-pi4-and-kodi-as-mediacenter-b3a2d8b44759)

<!-- hyeprlinks -->

[file:config]: ./samples/config/config.yml

[wikipedia:pipeline]: https://en.wikipedia.org/wiki/Pipeline_(Unix)

[wikipedia:xorg]: https://en.wikipedia.org/wiki/X.Org_Server

[freedesktop:basedir-spec]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

[xbmc/system/keymaps/keyboard]: https://fossies.org/linux/xbmc/system/keymaps/keyboard.xml

[wikis/xdotool-list-of-key-codes]: https://gitlab.com/cunidev/gestures/-/wikis/xdotool-list-of-key-codes

[wikis/XF86_keyboard_symbols]: https://wiki.linuxquestions.org/wiki/XF86_keyboard_symbols

[kodi.wiki/keyboard_controls]: https://kodi.wiki/view/Keyboard_controls

[kodi.wiki/built-in_functions]: https://kodi.wiki/view/List_of_built-in_functions

[kodi.wiki/window_IDs]: https://kodi.wiki/view/Window_IDs
