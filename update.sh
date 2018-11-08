#!/usr/bin/env bash

set -o errexit
set -o nounset

git fetch --all

current=$(nixos-version --revision);

if git merge-base --is-ancestor channels/nixos-unstable $current; then
    echo "current version ($current) already contains latest nixos-unstable";
    exit 0;
fi;

d=$(date +%Y-%m-%d-%H-%M)

wt=/home/matt/git/nixos/nixpkgs-update-$d

git worktree add -b update-$d $wt $current

pushd $wt

git merge channels/nixos-unstable -m "Merge remote-tracking branch 'channels/nixos-unstable'";

nixos-rebuild build -I nixpkgs=$wt;

nix-shell -I nixpkgs=$wt ~/git/elbum/shell.nix --run true;

echo;
echo "rebuild complete, computing changes";
echo;

nox-update --quiet /run/current-system result | \
    grep -v '\.drv : $' | \
    sed 's|^ */nix/store/[a-z0-9]*-||' | \
    sort -u > \
         update-${d}.txt

popd;

mv $wt/update-$d.txt .;

#prevent gc while changes are reviewed
nix-store --add-root result-$d --indirect -r $(readlink -e $wt/result);

rm -rf $wt;
git worktree prune;

echo;
echo "to review changes:";
echo;
echo "less update-$d.txt";
echo;
echo "to switch to new system:";
echo;
echo "git merge --ff-only update-$d";
echo "sudo nixos-rebuild boot -I nixpkgs=$(pwd)";
echo;
