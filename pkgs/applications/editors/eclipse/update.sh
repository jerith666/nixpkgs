#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure -p curl cacert libxml2 yq nix jq
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/3c7487575d9445185249a159046cc02ff364bff8.tar.gz
#                                                                ^
#                                                                |
#                   nixos-unstable ~ 2023-07-06 -----------------/

set -o errexit
set -o nounset

# scrape the downloads page for release info

curl -s -o eclipse-dl.html https://download.eclipse.org/eclipse/downloads/

dlquery() {
    q=$1
    xmllint --html eclipse-dl.html --xmlout 2>/dev/null | xq -r ".html.body.main.div.table[3].tr[1].td[0].a${q}";
}

# extract release info from download page HTML

platform_major=$(dlquery '."#text" | split(".") | .[0]' -r);
platform_minor=$(dlquery '."#text" | split(".") | .[1]' -r);

year=$(dlquery '."@href" | split("/") | .[] | select(. | startswith("R")) | split("-") | .[2] | .[0:4]')
buildmonth=$(dlquery '."@href" | split("/") | .[] | select(. | startswith("R")) | split("-") | .[2] | .[4:6]')
builddaytime=$(dlquery '."@href" | split("/") | .[] | select(. | startswith("R")) | split("-") | .[2] | .[6:12]')
timestamp="${year}${buildmonth}${builddaytime}";

# cleanup

rm eclipse-dl.html;

# account for possible release-month vs. build-month mismatches

month=$buildmonth;
if [[ "$buildmonth" == "02" || "$buildmonth" == "04" ]]; then
    month = "03";
elif [[ "$buildmonth" == "05" || "$buildmonth" == "07" ]]; then
    month = "06";
elif [[ "$buildmonth" == "08" || "$buildmonth" == "10" ]]; then
    month = "09";
elif [[ "$buildmonth" == "11" || "$buildmonth" == "01" ]]; then
    month = "12";
fi

cat <<EOF

paste the following into the 'let' block near the top of pkgs/applications/editors/eclipse/default.nix:

  platform_major = "${platform_major}";
  platform_minor = "${platform_minor}";
  year = "${year}";
  month = "${month}"; #release month
  buildmonth = "${buildmonth}"; #sometimes differs from release month
  timestamp = "\${year}\${buildmonth}${builddaytime}";
EOF

# strip existing download hashes

sed -i 's/64 = ".*";$/64 = "";/g' pkgs/applications/editors/eclipse/default.nix

# prefetch new download hashes

echo;
echo "paste the following url + hash blocks into pkgs/applications/editors/eclipse/default.nix:";

for u in $(grep 'url = ' pkgs/applications/editors/eclipse/default.nix | grep arch | cut -d '"' -f 2 | sed 's/&/\\&/g'); do
    echo;
    echo "        url = \"${u}\";";
    echo "        hash = {";
    for arch in x86_64 aarch64; do
        us=$(eval echo "$u");
        h=$(nix store prefetch-file --json "$us" | jq -r .hash);
        echo "          $arch = \"${h}\";";
    done
    echo '        }.${arch};';
done
