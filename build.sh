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
ACCEL_DOMAIN_FILES="$SCRIPT_FOLDER/dnsmasq-china-list/accelerated-domains.china.conf"
IPCIDR_FILES="$SCRIPT_FOLDER/chn-iplist/chnroute-ipv4.txt"
SHADOWROCKET_CONF="$SCRIPT_FOLDER/build/china.conf"
APPLE_RULES_FILE=$SCRIPT_FOLDER/templates/apple-rules.template
GOOGLE_RULES_FILE=$SCRIPT_FOLDER/templates/google-rules.template
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
printf "dns-server = 114.114.114.114, 119.29.29.29, 1.1.1.1, 208.67.222.222, 8.8.8.8\n" >> $SHADOWROCKET_CONF
printf "skip-proxy = 127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, 17.0.0.0/8, localhost, *.local, *.lan, *.crashlytics.com\n" >> $SHADOWROCKET_CONF
printf "bypass-tun = 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.0.0.0/24, 192.0.2.0/24, 192.88.99.0/24, 192.168.0.0/16, 198.18.0.0/15, 198.51.100.0/24, 203.0.113.0/24, 224.0.0.0/4, 255.255.255.255/32\n" >> $SHADOWROCKET_CONF
printf "\n" >> $SHADOWROCKET_CONF
printf "[Rule]\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,1.1.1.1/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,1.0.0.1/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,8.8.8.8/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,8.8.4.4/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,9.9.9.9/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,208.67.222.222/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "IP-CIDR,149.112.112.112/32,PROXY\n" >> $SHADOWROCKET_CONF
printf "DOMAIN-SUFFIX,cn,DIRECT\n" >> $SHADOWROCKET_CONF

printf "## > Apple Service Rules for China\n" >> $SHADOWROCKET_CONF
cat $APPLE_RULES_FILE >> $SHADOWROCKET_CONF
printf "\n\n" >> $SHADOWROCKET_CONF
printf "## > Google Service Rules for China\n" >> $SHADOWROCKET_CONF
cat $GOOGLE_RULES_FILE >> $SHADOWROCKET_CONF
printf "\n\n" >> $SHADOWROCKET_CONF
printf "## > Accelerated Domain Rules for China\n" >> $SHADOWROCKET_CONF
for FILE in ${ACCEL_DOMAIN_FILES}; do
  printf "\nAdding $FILE...\n"
  DOMAIN_LIST=$(grep -oE $REGEX_DOMAIN "$FILE")
  for DOMAIN_ENTRY in $DOMAIN_LIST
  do
    printf "DOMAIN-SUFFIX,$DOMAIN_ENTRY,DIRECT\n" >> $SHADOWROCKET_CONF
  done
done
printf "\n\n" >> $SHADOWROCKET_CONF
printf "## > Paul Git's Other Rules for China\n" >> $SHADOWROCKET_CONF
cat $OTHER_RULES_FILE >> $SHADOWROCKET_CONF
printf "\n\n" >> $SHADOWROCKET_CONF

printf "## > IPCIDR list for China\n" >> $SHADOWROCKET_CONF
for FILE in ${IPCIDR_FILES}; do
  printf "\nAdding $FILE...\n"
  IPCIDR_LIST=$(grep -v '^#' "$FILE")
  for IPCIDR_ENTRY in $IPCIDR_LIST
  do
    printf "IP-CIDR,$IPCIDR_ENTRY,DIRECT\n" >> $SHADOWROCKET_CONF
  done
done
printf "\n\n" >> $SHADOWROCKET_CONF

printf "FINAL,PROXY" >> $SHADOWROCKET_CONF
