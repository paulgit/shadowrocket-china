#!/bin/bash

CMD_DATE='/bin/date'
YEAR="$(${CMD_DATE} +%Y)"
MONTH="$(${CMD_DATE} +%m)"
DAY="$(${CMD_DATE} +%d)"
TIME="$(${CMD_DATE} +%H:%M:%S)"
BUILD_TIME="${YEAR}-${MONTH}-${DAY} $TIME"
SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REGEX_DOMAIN="\.?\b([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b"
ACCEL_DOMAIN_FILES="apple.china.conf"
SHADOWROCKET_CONF="$SCRIPT_FOLDER/shadowrocket-china.conf"

printf "Building Paul Git's Shadowrocket Rules for China\n"

printf "# Paul Git's Shadowrocket Rules for China\n" > $SHADOWROCKET_CONF
printf "#   https://code.paulg.it/shadowrocket-china\n" >> $SHADOWROCKET_CONF
printf "#\n" >> $SHADOWROCKET_CONF
printf "# Direct link to this file:\n" >> $SHADOWROCKET_CONF
printf "#   https://code.paulg.it/paulgit/shadowrocket-china/raw/branch/master/shadowrocket-china.conf\n" >> $SHADOWROCKET_CONF
printf "#\n" >> $SHADOWROCKET_CONF
printf "# Build Time: $BUILD_TIME\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "[General]\n" >> $SHADOWROCKET_CONF
printf "bypass-system = true\n" >> $SHADOWROCKET_CONF
printf "dns-server = system, 223.5.5.5, 223.6.6.6, 1.1.1.1, 9.9.9.9\n" >> $SHADOWROCKET_CONF
printf "skip-proxy = 127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, 17.0.0.0/8, localhost, *.local, *.crashlytics.com\n" >> $SHADOWROCKET_CONF
printf "bypass-tun = 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.0.0.0/24, 192.0.2.0/24, 192.88.99.0/24, 192.168.0.0/16, 198.18.0.0/15, 198.51.100.0/24, 203.0.113.0/24, 224.0.0.0/4, 255.255.255.255/32\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "[Rule]\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,1.1.1.1/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,1.0.0.1/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,8.8.8.8/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,8.8.4.4/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,9.9.9.9/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,149.112.112.112/32,PROXY\n" >> $SHADOWROCKET_CONF

for FILE in ${ACCEL_DOMAIN_FILES}; do
  printf "\nAdding $FILE...\n"
  curl -o $SCRIPT_FOLDER/$FILE https://code.paulg.it/paulgit/dnsmasq-china-list/raw/branch/master/$FILE
  DOMAIN_LIST=$(grep -oE $REGEX_DOMAIN "$SCRIPT_FOLDER/$FILE")
  for DOMAIN_ENTRY in $DOMAIN_LIST
  do
    printf "DOMAIN-SUFFIX,$DOMAIN_ENTRY,DIRECT\n" >> $SHADOWROCKET_CONF
  done
done

printf "GEOIP,CN,DIRECT\n" >> $SHADOWROCKET_CONF
printf "FINAL,PROXY" >> $SHADOWROCKET_CONF
