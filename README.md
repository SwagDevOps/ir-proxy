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

## Sample startup scripts

Using a dedicated user:

```sh
#!/usr/bin/env sh

socat - EXEC:'ir-keytable -D 550 -P 150 -t',pty | sudo -u user ir-proxy pipe
```

Using a global config (run as root):

```sh
#!/usr/bin/env sh

socat - EXEC:'ir-keytable -D 550 -P 150 -t',pty | ir-proxy pipe --config /etc/ir-proxy/config.yml
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
