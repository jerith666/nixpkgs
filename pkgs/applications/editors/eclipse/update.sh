#!/usr/bin/env bash

set -o errexit
set -o nounset

curl -s -o eclipse-dl.html https://download.eclipse.org/eclipse/downloads/

dlquery() {
    q=$1
    xmllint --html eclipse-dl.html --xmlout 2>/dev/null | xq -r ".html.body.main.div.table[3].tr[1].td[0].a${q}";
}

platform_major=$(dlquery '."#text" | split(".") | .[0]' -r);
platform_minor=$(dlquery '."#text" | split(".") | .[1]' -r);

year=$(dlquery '."@href" | split("/") | .[] | select(. | startswith("R")) | split("-") | .[2] | .[0:4]')
buildmonth=$(dlquery '."@href" | split("/") | .[] | select(. | startswith("R")) | split("-") | .[2] | .[4:6]')
builddaytime=$(dlquery '."@href" | split("/") | .[] | select(. | startswith("R")) | split("-") | .[2] | .[6:12]')

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
  platform_major = "${platform_major}";
  platform_minor = "${platform_minor}";
  year = "${year}";
  month = "${month}"; #release month
  buildmonth = "${buildmonth}"; #sometimes differs from release month
  timestamp = "\${year}\${buildmonth}${builddaytime}";
EOF

sed -i 's/64 = ".*";$/64 = "";/g' pkgs/applications/editors/eclipse/default.nix
