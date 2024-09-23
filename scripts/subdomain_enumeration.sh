#!/bin/sh

if [ $1 = "-h" ]; then
    echo "subdomain_enumeration main_domains.txt"
    exit 0
else
    domains_file="$1"
fi

subfinder -dL ${domains_file} -v -o "all_subs_${domains_file}" -pc /.config/subfinder/provider-config.yaml && 
dnsx -l "all_subs_${domains_file}" -v -stats -o "live_subs_${domains_file}" &&
gowitness scan file -D -f "live_subs_${domains_file}" --write-db &&
echo "####################*******SERVER STARTED******##########################################" &&
gowitness report server -D --host 0.0.0.0 --port 7171