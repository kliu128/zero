# Yubikey GPG Runbook

## Current setup

```
sub  rsa4096/5A824102DFE3DD86 2016-07-25 Kevin Liu <kevin@potatofrom.space>
sec#  rsa4096/2160C3EB40A944EC  created: 2016-07-25  expires: never     
ssb>  rsa4096/70BD9204A269C241  created: 2016-07-25  expires: 2019-08-15
                                card-no: 0006 07754603
ssb>  rsa4096/5A824102DFE3DD86  created: 2016-07-25  expires: 2019-08-15
                                card-no: 0006 07754603
ssb>  rsa4096/8E73D7268B26C51C  created: 2019-04-13  expires: 2020-04-12
                                card-no: 0006 07754603
```

All three secret subkeys are on the Yubikey; the master key is not. The master key is stored on Emergency Backup, as well as on G-Suite and personal drive. They are encrypted in a VeraCrypt container. The key itself has your Standard Passphrase.

## Rotating keys

See https://github.com/drduh/YubiKey-Guide#rotating-keys.

1. `export GNUPGHOME=$(mktemp -d)`
1. `gpg --import <secret key file>`
1. `gpg --keyserver keyserver.ubuntu.com --recv 8792E2260F507DA00F0DB58E2160C3EB40A944EC`
1. `gpg --edit-key 8792E2260F507DA00F0DB58E2160C3EB40A944EC`
1. Select keys with `key #`, `expire` to change expiration date
1. `gpg --keyserver keyserver.ubuntu.com --send-keys 8792E2260F507DA00F0DB58E2160C3EB40A944EC`
1. On normal GPG, recv keys.