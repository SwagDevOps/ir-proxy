<!-- ( vim: set fenc=utf-8 spell spl=en: ) -->

## Samples

```sh
bundle exec bin/ir-proxy sample | env sudo -u "$(whoami)" bundle exec bin/ir-proxy pipe
```

## Commands


```sh
sudo ir-keytable -D 500 -P 500 -t
sudo socat - EXEC:'ir-keytable -D 500 -P 500 -t',pty,setsid,ctty
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
