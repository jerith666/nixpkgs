#!/usr/bin/env bash

set -o errexit
set -o nounset

d=$1

wt=$2

echo "computing store path for new system"
system=$(nixos-rebuild dry-build -I nixpkgs=$wt 2>&1 | grep nixos-system)

echo "building new system store path $system"
nix build $system;

nixos-rebuild build -I nixpkgs=$wt;

nix-store --realise --add-root system-result --indirect result;

nix-build -I nixpkgs=$wt -A pkgs.client-ip-echo;
nix-store --realise --add-root client-ip-echo-result --indirect result;

nix-shell -I nixpkgs=$wt ~/git/elbum/shell.nix --run true;

nix-shell -I nixpkgs=$wt ~/git/bills-automation/shell.nix --run true;

echo;
echo "rebuild complete, computing changes";
echo;

nox-update --quiet /run/current-system system-result | \
    grep -v '\.drv : $' | \
    sed 's|^ */nix/store/[a-z0-9]*-||' | \
    sort -u > \
         update-${d}.txt

