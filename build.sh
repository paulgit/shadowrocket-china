#!/bin/bash

CMD_DATE='/bin/date'
YEAR="$(${CMD_DATE} +%Y)"
MONTH="$(${CMD_DATE} +%m)"
DAY="$(${CMD_DATE} +%d)"
TIME="$(${CMD_DATE} +%H:%M:%S)"
BUILD_TIME="${YEAR}-${MONTH}-${DAY} $TIME"
SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_FOLDER="$SCRIPT_FOLDER/build"
REGEX_DOMAIN="\.?\b([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b"
ACCEL_DOMAIN_FILES="$SCRIPT_FOLDER/dnsmasq-china-list/apple.china.conf $SCRIPT_FOLDER/dnsmasq-china-list/google.china.conf $SCRIPT_FOLDER/dnsmasq-china-list/accelerated-domains.china.conf"
SHADOWROCKET_CONF="$SCRIPT_FOLDER/build/china.conf"
OTHER_RULES_FILE=$SCRIPT_FOLDER/templates/other-rules.template

printf "Building Paul Git's Shadowrocket Rules for China\n"

# Create build folder if it doesn't already exit
mkdir -p $BUILD_FOLDER > /dev/null

# Empty build folder
rm -f $BUILD_FOLDER/*

# Update the submodules to get their rules
git submodule foreach git reset --hard HEAD
git submodule foreach git clean -df 
git submodule foreach git pull origin master --no-rebase

printf "# Paul Git's Shadowrocket Rules for China\n" > $SHADOWROCKET_CONF
printf "#   https://code.paulg.it/shadowrocket-china\n" >> $SHADOWROCKET_CONF
printf "#\n" >> $SHADOWROCKET_CONF
printf "# Direct link to this file:\n" >> $SHADOWROCKET_CONF
printf "#   https://assets.paulg.it/shadowrocket/china.conf\n" >> $SHADOWROCKET_CONF
printf "#\n" >> $SHADOWROCKET_CONF
printf "# Build Time: $BUILD_TIME\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "[General]\n" >> $SHADOWROCKET_CONF
printf "bypass-system = true\n" >> $SHADOWROCKET_CONF
printf "skip-proxy = 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, localhost, *.local, captive.apple.com\n" >> $SHADOWROCKET_CONF
printf "tun-excluded-routes = 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.0.0.0/24, 192.0.2.0/24, 192.88.99.0/24, 192.168.0.0/16, 198.51.100.0/24, 203.0.113.0/24, 224.0.0.0/4, 255.255.255.255/32, 239.255.255.250/32\n" >> $SHADOWROCKET_CONF
printf "dns-server = system\n" >> $SHADOWROCKET_CONF
printf "ipv6 = true\n" >> $SHADOWROCKET_CONF
printf "prefer-ipv6 = false\n" >> $SHADOWROCKET_CONF
printf "dns-fallback-system = false\n" >> $SHADOWROCKET_CONF
printf "dns-direct-system = false\n" >> $SHADOWROCKET_CONF
printf "icmp-auto-reply = true\n" >> $SHADOWROCKET_CONF
printf "always-reject-url-rewrite = false\n" >> $SHADOWROCKET_CONF
printf "private-ip-answer = true\n" >> $SHADOWROCKET_CONF
printf "# direct domain fail to resolve use proxy rule\n" >> $SHADOWROCKET_CONF
printf "dns-direct-fallback-proxy = true\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "[Rule]\n" >> $SHADOWROCKET_CONF
printf "DOMAIN-SUFFIX,cn,DIRECT\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "## > Accelerated Domain Rules for China\n" >> $SHADOWROCKET_CONF
for FILE in ${ACCEL_DOMAIN_FILES}; do
  printf "\nAdding $FILE...\n"
  DOMAIN_LIST=$(grep -oE $REGEX_DOMAIN "$FILE")
  for DOMAIN_ENTRY in $DOMAIN_LIST
  do
    printf "DOMAIN-SUFFIX,$DOMAIN_ENTRY,DIRECT\n" >> $SHADOWROCKET_CONF
  done
done
printf "\n" >> $SHADOWROCKET_CONF
printf "## > Paul Git's Other Rules for China\n" >> $SHADOWROCKET_CONF
cat $OTHER_RULES_FILE >> $SHADOWROCKET_CONF
printf "\n\n" >> $SHADOWROCKET_CONF
printf "# LAN\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,192.168.0.0/16,DIRECT\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,10.0.0.0/8,DIRECT\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,172.16.0.0/12,DIRECT\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,127.0.0.0/8,DIRECT\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "# China\n" >> $SHADOWROCKET_CONF
printf "GEOIP,CN,DIRECT\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "FINAL,PROXY\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "[Host]\n" >> $SHADOWROCKET_CONF
printf "localhost = 127.0.0.1\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "[URL Rewrite]\n" >> $SHADOWROCKET_CONF
printf "^https\?://(www.)\?g.cn https://www.google.com 302\n" >> $SHADOWROCKET_CONF
printf "^https\?://(www.)\?google.cn https://www.google.com 302\n" >> $SHADOWROCKET_CONF
