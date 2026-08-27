#!/usr/bin/env bash

set -o errexit
set -o nounset

git fetch --all

current=$(nixos-version --revision);

cb=$(git branch --show-current);

if [ "$cb" == "home-alpha-i9" ]; then
    ub=origin/nixos-unstable;
elif [ "$cb" == "work-laptop-t14s" ]; then
    ub=jerith666/home-alpha-i9;
else
    echo "current branch $cb has no defined nixpkgs upstream";
    exit 1;
fi

if git merge-base --is-ancestor ${ub} $current; then
    echo;
    echo "at                                         $(date +%c)";
    echo;
    echo "the current version:        $(git log -1 --date=format-local:%c --format='%h @ %ad' $current)";
    echo;
    echo "already contains the";
    echo "latest ${ub}:";
    echo "                            $(git log -1 --date=format-local:%c --format='%h @ %ad' origin/nixos-unstable)"
    echo;
    exit 0;
fi;

d=$(date +%Y-%m-%d-%H-%M)

wt=${HOME}/git/nixos/nixpkgs-update-$d

git worktree add -b update-$d $wt $current

pushd $wt

for commit in ${PRE_REVERT:-}; do
    git revert --no-edit $commit;
done

for commit in ${PRE_CHERRY:-}; do
    git cherry-pick -x $commit;
done

git merge ${ub} \
    -X ignore-space-change \
    -m "Merge remote-tracking branch '${ub}'";

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
mkdir result-$d;
for f in $wt/*-result; do
    nix-store --add-root result-$d/$(basename $f) --indirect -r $(readlink -e $f);
done

rm -rf $wt;
git worktree prune;

echo;
echo "to review changes:";
echo;
echo "less update-$d.txt";
echo;
echo "commands to switch to new system (depending on whether reboot is needed):";
echo;
echo "git merge --ff-only update-$d && sudo sh -c \"ulimit -s 100000 && nixos-rebuild boot -I nixpkgs=$(pwd) |& nom\"";
echo;
echo "git merge --ff-only update-$d && sudo sh -c \"ulimit -s 100000 && nixos-rebuild switch -I nixpkgs=$(pwd) |& nom\"";
echo;
