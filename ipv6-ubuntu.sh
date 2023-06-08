#!/bin/bash
ipv4=$(curl -4 -s icanhazip.com)
IPC=$(curl -4 -s icanhazip.com | cut -d"." -f3)
IPD=$(curl -4 -s icanhazip.com | cut -d"." -f4)
INT=$(ls /sys/class/net | grep e)
if [ "$IPC" = "4" ]; then
	IPV6_ADDRESS="2403:6a40:0:40::$IPD:0000/64"
	PREFIX_LENGTH="64"
	INTERFACE="$INT"
	GATEWAY="2403:6a40:0:40::1"
elif [ "$IPC" = "5" ]; then
	IPV6_ADDRESS="2403:6a40:0:41::$IPD:0000/64"
	PREFIX_LENGTH="64"
	INTERFACE="$INT"
	GATEWAY="2403:6a40:0:41::1"
elif [ "$IPC" = "244" ]; then
	IPV6_ADDRESS="2403:6a40:2000:244::$IPD:0000/64"
	PREFIX_LENGTH="64"
	INTERFACE="$INT"
	GATEWAY="2403:6a40:2000:244::1"
else
	IPV6_ADDRESS="2403:6a40:0:$IPC::$IPD:0000/64"
	PREFIX_LENGTH="64"
	INTERFACE="$INT"
	GATEWAY="2403:6a40:0:$IPC::1"
fi
interface_name="$INTERFACE"  # Thay thế bằng tên giao diện mạng của bạn
ipv6_address="$IPV6_ADDRESS"
gateway6_address="$GATEWAY"
if [ "$INT" = "ens160" ]; then
	netplan_path="/etc/netplan/99-netcfg-vmware.yaml"  # Thay thế bằng đường dẫn tệp cấu hình Netplan của bạn
	netplan_config=$(cat "$netplan_path")
	new_netplan_config=$(sed "/gateway4:/i \ \ \ \ \ \ \  - $ipv6_address" <<< "$netplan_config")
	new_netplan_config=$(sed "/gateway4:.*/a \ \ \ \ \  gateway6: $gateway6_address" <<< "$new_netplan_config")
elif [ "$INT" = "eth0" ]; then
	netplan_path="/etc/netplan/50-cloud-init.yaml"
	netplan_config=$(cat "$netplan_path")
	# Tạo đoạn cấu hình IPv6 mới
	new_netplan_config=$(sed "/gateway4:/i \ \ \ \ \ \ \ \ \ \ \ \ - $ipv6_address" <<< "$netplan_config")
	# cập nhật gateway ipv6
	new_netplan_config=$(sed "/gateway4:.*/a \ \ \ \ \ \ \ \ \ \ \ \ gateway6: $gateway6_address" <<< "$new_netplan_config")
else
	echo 'Khong co card mang phu hop'
fi
    
echo "$new_netplan_config" > "$netplan_path"

# Áp dụng cấu hình Netplan
sudo netplan apply
