#!/bin/sh

# Find the connection UUID with "nmcli con show" in terminal.
# All NetworkManager connection types are supported: wireless, VPN, wired...
WANTED_CON_UUID="CHANGE-ME-NOW-9c7eff15-010a-4b1c-a786-9b4efa218ba9"

#if [[ "$CONNECTION_UUID" == "$WANTED_CON_UUID" ]]; then
    
    # Script parameter $1: NetworkManager connection name, not used
    # Script parameter $2: dispatched event
    
    case "$2" in
        "up")
            systemctl start wireguard-wg0
            mount /mnt/storage
            mount /mnt/home
            ;;
        "pre-down");&
        "vpn-pre-down")
            umount -l -a -t nfs4,nfs >/dev/null
            ;;
    esac
#fi
