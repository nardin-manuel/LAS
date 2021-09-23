#!/bin/sh

if [ ! -f opt/bootnode/boot.key ]; then
    echo "opt/bootnode/boot.key not found, generating..."
    bootnode --genkey /opt/bootnode/boot.key
    echo "...done!"
fi

echo "enode://$(bootnode --nodekey /opt/bootnode/boot.key -writeaddress)@$(hostname -i):30301" > /opt/bootnode/key/public.key
bootnode --nodekey /opt/bootnode/boot.key --verbosity 2