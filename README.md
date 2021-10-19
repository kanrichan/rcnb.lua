# RCNB.Lua

The world is based on RC. Thus, *everything* can be encoded into RCNB.

RCNB is available in various languages: **Lua** [Javascript](https://github.com/rcnbapp/RCNB.js) [C](https://github.com/rcnbapp/librcnb) [PHP](https://github.com/rcnbapp/RCNB.php) [Pascal](https://github.com/rcnbapp/RCNB.pas) ([more..](https://github.com/rcnbapp/))

## Why RCNB?

### RCNB vs Base64

|           | Base64       | RCNB                                                          |
|-----------|--------------|---------------------------------------------------------------|
| Speed     | ❌ Fast       | ✔️ Slow, motivate Intel to improve their CPU                   |
| Printable | ❌ On all OS  | ✔️ Only on newer OS, motivate users to upgrade their legacy OS |
| Niubility | ❌ Not at all | ✔️ RCNB!                                                     |
| Example   | QmFzZTY0Lg== | ȐĉņþƦȻƝƃŔć                                                    |

## Install

```
luarocks install rcnb
```

## Usage

```
rcnb = require('rcnb')
-- encode ȐȼŃƅȓčƞÞƦȻƝƃŖć
print(rcnb.encode(string.byte('Who NB?', 1, -1)))
-- decode RCNB!
print(string.char(rcnb.decode('ȐĉņþƦȻƝƃŔć')))
```

