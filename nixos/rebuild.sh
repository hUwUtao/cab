#!/bin/sh
nixos-rebuild switch --upgrade && nix-collect-garbage --delete-old && nixos-rebuild boot
