#!/usr/bin/env bash

set -o errexit
set -o nounset

d=$1

wt=$2

nixos-rebuild build -I nixpkgs=$wt;

mv -iv result system-result;

nix-build -I nixpkgs=$wt -A pkgs.client-ip-echo;

nix-shell -I nixpkgs=$wt ~/git/elbum/shell.nix --run true;

echo;
echo "rebuild complete, computing changes";
echo;

nox-update --quiet /run/current-system system-result | \
    grep -v '\.drv : $' | \
    sed 's|^ */nix/store/[a-z0-9]*-||' | \
    sort -u > \
         update-${d}.txt

