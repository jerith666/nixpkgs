#!/usr/bin/env bash

set -o errexit
set -o nounset

git fetch --all

current=$(nixos-version --revision);

if git merge-base --is-ancestor origin/nixos-unstable $current; then
    echo "current version ($current) already contains latest nixos-unstable";
    exit 0;
fi;

d=$(date +%Y-%m-%d-%H-%M)

wt=/home/matt/git/nixos/nixpkgs-update-$d

git worktree add -b update-$d $wt $current

pushd $wt

for commit in ${PRE_REVERT:-}; do
    git revert --no-edit $commit;
done

for commit in ${PRE_CHERRY:-}; do
    git cherry-pick -x $commit;
done

git merge origin/nixos-unstable -m "Merge remote-tracking branch 'origin/nixos-unstable'";

for commit in ${POST_REVERT:-}; do
    git revert --no-edit $commit;
done

for commit in ${POST_CHERRY:-}; do
    git cherry-pick -x $commit;
done

./rebuild-update.sh "$d" "$wt";

popd;

mv -iv $wt/update-$d.txt .;

#prevent gc while changes are reviewed
nix-store --add-root result-$d --indirect -r $(readlink -e $wt/system-result);

rm -rf $wt;
git worktree prune;

echo;
echo "to review changes:";
echo;
echo "less update-$d.txt";
echo;
echo "commands to switch to new system (depending on whether reboot is needed):";
echo;
echo "git merge --ff-only update-$d && sudo sh -c \"ulimit -s 100000 && nixos-rebuild boot -I nixpkgs=$(pwd)\"";
echo;
echo "git merge --ff-only update-$d && sudo sh -c \"ulimit -s 100000 && nixos-rebuild switch -I nixpkgs=$(pwd)\"";
echo;
