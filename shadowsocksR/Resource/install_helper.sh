#!/bin/sh

#  install_helper.sh
#  shadowsocks
#
#  Created by clowwindy on 14-3-15.

cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "/Library/Application Support/ShadowsocksR/"
sudo cp proxy_conf_helper "/Library/Application Support/ShadowsocksR/"
sudo chown root:admin "/Library/Application Support/ShadowsocksR/proxy_conf_helper"
sudo chmod +s "/Library/Application Support/ShadowsocksR/proxy_conf_helper"

echo done