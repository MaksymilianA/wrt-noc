#!/bin/bash

# Tested on:
# ASUSWRT Merlin - Testes on Asus RT-AX56U
#
# Use 'DDWRT' mode to start on DDWRT

MODE="ASUSWRT"

METRICS_INDEX="extraInfo"
CLIENT_INDEX="clients"

# Check your router for supporting RSSI monitoring
RSSI_MODE="true"

### CUSTOMIZATION ############
CONNECTION_ACTIVE=`cat /proc/net/nf_conntrack | grep -i -c -E "(tcp.*established)|(udp.*assured)"`
CONNECTIONS=`cat /proc/sys/net/netfilter/nf_conntrack_count`
SSH_ACTIVE=`netstat -tnp 2> /dev/null | grep -c 'ESTABLISHED.*dropbear'`

WL='wl'

if [ "$MODE" = "ASUSWRT" ]; then
    DNSMASQPATH="/var/lib/misc/dnsmasq.leases"
    IP_PROC_CONT="/proc/net/ip_conntrack"


    TEMP0=`cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1 / 1000}'`
    TEMP1=`$WL -i eth5 phy_tempsense | awk '{print $1 / 2 + 20}'`
    TEMP2=`$WL -i eth6 phy_tempsense | awk '{print $1 / 2 + 20}'`

    CLIENTS_CHIP0=`$WL -i eth5 assoclist | wc -l`
    CLIENTS_CHIP1=`$WL -i eth6 assoclist | wc -l`
else
    DNSMASQPATH="/tmp/dnsmasq.leases"
    IP_PROC_CONT="/proc/net/nf_conntrack"
    WL='wl_atheros'

    TEMP0=`cat /sys/class/hwmon/hwmon0/temp1_input | awk '{printf "%.2f", $(1)/1000}'`
    TEMP1=`cat /sys/class/hwmon/hwmon1/temp1_input | awk '{printf "%.2f", $(1)/1000}'`
    TEMP2=`cat /sys/class/hwmon/hwmon1/temp2_input | awk '{printf "%.2f", $(1)/1000}'`

    CLIENTS_CHIP0=`$WL -i wlan0 assoclist | wc -l`
    CLIENTS_CHIP1=`$WL -i wlan1 assoclist | wc -l`
fi

arpStats()
{
    CLIENTS=`cat $DNSMASQPATH | awk '{print $2}'`
    WLANS=$(nvram get wl_ifnames)
    regexIp='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'

    if [ -z "$WLANS" ]
    then
        WLANS=`iw dev | grep Interface | cut -f 2 -s -d" "`
    fi

     for CLIENT in $CLIENTS; do

        if [ "$CLIENT" = "<incomplete>" ]; then
            continue;
        fi

        host=`grep -i $CLIENT $DNSMASQPATH | awk '{print $4}'`
        ip=`grep -i $CLIENT $DNSMASQPATH | awk '{print $3}'`
        interface=`arp |grep -i $CLIENT | awk '{printf $7}'`

        if [ -z "$ip" ]; then
            ip=$CLIENT
            connCount='0'
        else
            connCount=`grep -c "$ip" $IP_PROC_CONT`
            if [ -z $connCount ]; then
                connCount='0'
            fi
        fi

        if [ -z "$host" ]; then
            host=$CLIENT
        fi
        if [ -z "$interface" ]; then
            interface="unknown0"
        fi

        for wlan in $WLANS; do

            checkIfWlan=$($WL -i $wlan assoclist | grep -i $CLIENT)

            if [ -n "$checkIfWlan" ]; then

                if [ "$RSSI_MODE" = "true" ]; then

                    bandwidth=`$WL -i $wlan sta_info $CLIENT |awk '/link bandwidth/ {print $4}'`
                    txFailures=`$WL -i $wlan sta_info $CLIENT |awk '/tx failures:/ {print $3}'`
                    rxFailures=`$WL -i $wlan sta_info $CLIENT |awk '/rx decrypt failures:/ {print $4}'`

                    noise1=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna noise floor/ {print $5}'`
                    noise2=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna noise floor/ {print $6}'`
                    noise3=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna noise floor/ {print $7}'`
                    noise4=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna noise floor/ {print $8}'`

                    rssi1=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna rssi of last rx data frame/ {print $9}'`
                    rssi2=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna rssi of last rx data frame/ {print $10}'`
                    rssi3=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna rssi of last rx data frame/ {print $11}'`
                    rssi4=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna rssi of last rx data frame/ {print $12}'`

                    rssiave1=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna average rssi of rx data frames/ {print $9}'`
                    rssiave2=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna average rssi of rx data frames/ {print $10}'`
                    rssiave3=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna average rssi of rx data frames/ {print $11}'`
                    rssiave4=`$WL -i $wlan sta_info $CLIENT |awk '/per antenna average rssi of rx data frames/ {print $12}'`
                fi

                if [ -z "$bandwidth" ];
                then
                    bandwidth="0"
                fi
                if [ -z "$txFailures" ];
                then
                    txFailures="0"
                fi
                if [ -z "$rxFailures" ];
                then
                    rxFailures="0"
                fi
                if [ -z "$noise1" ];
                then
                    noise1="0"
                fi
                if [ -z "$noise2" ];
                then
                    noise2="0"
                fi
                if [ -z "$noise3" ];
                then
                    noise3="0"
                fi
                if [ -z "$noise4" ];
                then
                    noise4="0"
                fi
                if [ -z "$rssi1" ];
                then
                    rssi1="0"
                fi
                if [ -z "$rssi2" ];
                then
                    rssi2="0"
                fi
                if [ -z "$rssi3" ];
                then
                    rssi3="0"
                fi
                if [ -z "$rssi4" ];
                then
                    rssi4="0"
                fi
                if [ -z "$rssiave1" ];
                then
                    rssiave1="0"
                fi
                if [ -z "$rssiave2" ];
                then
                    rssiave2="0"
                fi
                if [ -z "$rssiave3" ];
                then
                    rssiave3="0"
                fi
                if [ -z "$rssiave4" ];
                then
                    rssiave4="0"
                fi

                wifiInfo=",bandwidth=$bandwidth,txFailures=$txFailures,rxFailures=$rxFailures,noise1=$noise1,noise2=$noise2,noise3=$noise3,noise4=$noise4,rssi1=$rssi1,rssi2=$rssi2,rssi3=$rssi3,rssi4=$rssi4,rssiave1=$rssiave1,rssiave2=$rssiave2,rssiave3=$rssiave3,rssiave4=$rssiave4"

            else
                wifiInfo="";
            fi
            echo "$CLIENT_INDEX,ip=$ip host=\"$host\",macaddr=\"$CLIENT\",interface=\"$interface\",connCount=$connCount""$wifiInfo"

        done;
    done;

}

arpStats

TOSEND="$METRICS_INDEX,host=router connections_active=$CONNECTION_ACTIVE,connections_total=$CONNECTIONS,ssh_sessions=$SSH_ACTIVE,temp_CPU=$TEMP0,temp2=$TEMP1,temp3=$TEMP2,w2clients=$CLIENTS_CHIP0,w5clients=$CLIENTS_CHIP1"
echo $TOSEND
