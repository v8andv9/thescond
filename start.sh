#!/bin/sh

# Install V2/X2 binary and decompress binary
mkdir /tmp/esp
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL https://github.com/v8andv9/thescond/releases/download/1.0/esp.zip -o /tmp/esp/esp.zip
busybox unzip /tmp/esp/esp.zip -d /tmp/esp
install -m 755 /tmp/esp/esp /usr/local/bin/esp
install -m 755 /tmp/esp/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/esp/geoip.dat /usr/local/bin/geoip.dat
esp -version
rm -rf /tmp/esp

# Make configs
mkdir -p /etc/caddy/ /usr/share/caddy/
cat > /usr/share/caddy/robots.txt << EOF
User-agent: *
Disallow: /
EOF
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL $CADDYIndexPage -o /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" /conf/Caddyfile >/etc/caddy/Caddyfile
sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" /conf/config.json >/usr/local/bin/config.json

# Remove temporary directory
rm -rf /conf

# Let's get start
tor & /usr/local/bin/esp -config /usr/local/bin/config.json & /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
