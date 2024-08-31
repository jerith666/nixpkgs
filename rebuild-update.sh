#!/usr/bin/env bash

set -o errexit
set -o nounset

if [ -v 1 ]; then
    d=$1
else
    d=$(basename $(realpath $(dirname $0)) | sed 's/nixpkgs-update-//')
    echo rebuild-update guessing date-tag: $d
fi

if [ -v 2 ]; then
    wt=$2
else
    wt=$(dirname $(realpath $0))
    echo rebuild-update guessing worktree: $wt
fi

ulimit -s 100000;

echo "computing store path for new system";
echo;
if nixos-rebuild dry-build -I nixpkgs=$wt 2>dryout >dryout; then
    if grep nixos-system dryout; then
        system=$(grep nixos-system dryout);
        echo "building new system store path $system";
        echo;
        nix build --keep-going ${system}^\*;
    else
        echo "nixos-rebuild dry-build succeeded without producing a nixos-system path";
        echo "perhaps the system is already built; proceeding with nixos-rebuild";
        echo;
    fi
    nixos-rebuild build -I nixpkgs=$wt;
    rm dryout;
else
    echo "nixos-rebuild dry-build failed";
    cat dryout;
    rm dryout;
    exit;
fi

nix-store --realise --add-root system-result --indirect result;

nix-build -I nixpkgs=$wt -A pkgs.client-ip-echo;
nix-store --realise --add-root client-ip-echo-result --indirect result;

for sd in calendar-filter client-ip-echo elbum bills-automation haskell-rest-service; do
    echo; echo "confirming that nix-shell works for ${sd}";
    todo=$(nix-shell -I nixpkgs=$wt ~/git/${sd}/shell.nix --dry-run 2>&1 | grep '/nix/store/.*\.drv$' || true)
    if echo $todo | grep '/nix/store/.*\.drv$' > /dev/null; then
        nix build $(echo $todo | sed 's|.drv|.drv^\*|g') --keep-going --max-jobs 4;
    fi
    nix-shell -I nixpkgs=$wt ~/git/${sd}/shell.nix --keep-going --run true;
    nix-build -I nixpkgs=$wt ~/git/${sd}/shell.nix -A inputDerivation -o shell-${sd}-result
    if [ -f ~/git/${sd}/default.nix ]; then
        nix build -I nixpkgs=$wt -f ~/git/${sd}/default.nix -o ${sd}-result
    fi
done

echo;
echo "rebuild complete, computing changes";
echo;

current=$(nixos-version --revision);

git log -p ${current}... -- nixos/doc/manual/release-notes > update-${d}.txt

./system-result/sw/bin/nvd --color=always \
                           diff \
                           /run/current-system \
                           system-result >> \
                           update-${d}.txt
