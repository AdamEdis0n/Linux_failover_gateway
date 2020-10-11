#!/bin/bash
defaultGate=192.168.8.1     # Domyslna brama
backupGate=192.168.2.1  # Brama zapasowa
logFile=/root/logRoute.log
defRoute=$(ip route  | grep default | cut -d" " -f3 | head -n 1) # Pobranie aktualnej domyslnej trasy
date >> /root/test.txt
echo $(date) >> $logFile
if [ "$defRoute" == "$defaultGate" ]; then
        # Mamy ustawiona domyslna trase przez glowne lacze
        if ping -c1 8.8.8.8; then
                # ping dziala, nic nie robimy
                echo $(date) Ustawiona domyslna trasa, wszystko dziala, nic nie robie >> $logFile
        else
                # Mamy domyslna trase, ale net nie dziala. Trzeba przelaczyc na zapasowe lacze
                echo $(date) Domyslna trasa nie dziala, przelaczam na zapasowa  >> $logFile
                /sbin/route del default gw $defaultGate
                /sbin/route add default gw $backupGate
                /root/firewall_minimal
                systemctl restart openvpn.service
        fi
else
        # Mamy ustawiona domyslna trase przez zapasowe lacze
        if ping -c1 8.8.8.8; then
                # ping dziala przez glowne lacze dziala, wracamy do normalnej pracy
                echo $(date) Ustawiona zapasowa trasa, a glowne lacze dziala, wracam do normalnych ustawien >> $logFile
                /sbin/route del default gw $backupGate
                /sbin/route add default gw $defaultGate
                /root/firewall
                systemctl restart openvpn.service
        else
                # Mamy domyslna trase ustawiona na zapasowe lacze, a glowne wciaz nie dizala
                echo $(date) Domyslna trasa nie dziala, zostaje na zapasowym laczu >> $logFile
        fi
fi
