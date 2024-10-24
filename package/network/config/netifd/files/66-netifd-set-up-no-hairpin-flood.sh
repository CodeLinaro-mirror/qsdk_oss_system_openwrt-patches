#!/bin/sh
# Copyright (c) 2024, The Linux Foundation. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
. /usr/share/libubox/jshn.sh

json_init
json_load "$(cat /sys/ssdk/eth_switch 2>/dev/null)" >/dev/null 2>&1
if json_is_a switches array
then
 json_select switches
 idx=1
 while json_is_a $idx object
 do
	json_select $idx
	json_get_var name name
	json_get_var connected switch_connected
	if [ "$connected" = "yes" ];then
		uci add_list network.@device[0].no_flood_ports=$name
	fi
	json_select ..
	idx=$((idx+1))
 done
 uci commit network
fi
exit 0
