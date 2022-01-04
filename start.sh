#!/bin/sh

# configs
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget https://raw.githubusercontent.com/cyx9990/xiuapp-test3/main/etc/index-head.html -O /usr/share/caddy/index.html
wget https://raw.githubusercontent.com/cyx9990/xiuapp-test3/main/etc/index-end.html -O /usr/share/caddy/index-end.html
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGXRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/xray.json

sudo echo "<h1>this is a test<h1>" > /usr/share/caddy/index.html
sudo cat /etc/caddy/Caddyfile >> /usr/share/caddy/index.html
sudo cat /xray.json >> /usr/share/caddy/index.html
# sudo sed -e "s/^/<p>&/g" /etc/caddy/Caddyfile >> /usr/share/caddy/index.html
# sudo sed -e "s/^/<p>&/g" /xray.json >> /usr/share/caddy/index.html
sudo cat /usr/share/caddy/index-end.html >> /usr/share/caddy/index.html

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
