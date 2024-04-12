#!/bin/bash

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4
ARCH=$5

set -e

# Copy DTB, Unofficial support board update kernel while lost dtb.
BOOT_CONF=/boot/extlinux/extlinux.conf
if [ -f ${BOOT_CONF} ]; then
    mkdir -p /boot/dtb
    DTB_PATH=$(cat ${BOOT_CONF} | grep 'fdt /boot/dtb/' | awk '{print $2}')
    DTB_NAME=$(echo ${DTB_PATH##*/})
    NEW_PATH=/boot/dtb/${DTB_NAME}
    \cp ${DTB_PATH} ${NEW_PATH}
    sed -i "s|${DTB_PATH}|${NEW_PATH}|g" ${BOOT_CONF}
fi

# Disable update kernel
mkdir -p /etc/apt/preferences.d
DISABLE_UPDATE_CONF=/etc/apt/preferences.d/disable-update
PKG_LIST=$(dpkg-query --show --showformat='${Package}\n')

function DISABLE_UPDATE() {
    echo -e "Package: $1\nPin: version *\nPin-Priority: -1\n" >> ${DISABLE_UPDATE_CONF}
}

cat /dev/null > ${DISABLE_UPDATE_CONF}
DISABLE_UPDATE armbian-firmware
DISABLE_UPDATE $(echo "${PKG_LIST}" | grep "armbian-bsp-cli-")
DISABLE_UPDATE $(echo "${PKG_LIST}" | grep "^linux-image-")
DISABLE_UPDATE $(echo "${PKG_LIST}" | grep "^linux-dtb-")
DISABLE_UPDATE $(echo "${PKG_LIST}" | grep "^linux-u-boot")

# Replace USTC mirror source
FIRST_RUN=/root/first_run.sh
cat <<EOF >${FIRST_RUN}
#!/bin/bash

# Set mirrors to USTC
# Debian
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
sed -i 's|security.debian.org|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

# Ubuntu
sed -i 's|ports.ubuntu.com|mirrors.ustc.edu.cn/ubuntu-ports|g' /etc/apt/sources.list

# Armbian
sed -i 's|apt.armbian.com|mirrors.ustc.edu.cn/armbian|g' /etc/apt/sources.list.d/armbian.list

EOF
chmod +x ${FIRST_RUN}

# htoprc
mkdir -p /etc/skel/.config/htop
cat <<EOF >/etc/skel/.config/htop/htoprc
show_cpu_usage=1
show_cpu_frequency=1
show_cpu_temperature=1
tree_view=1

EOF

# ZCube1 Max no have WiFi
if [ "${BOARD}" = "zcube1-max" ]; then
    systemctl disable wpa_supplicant.service
fi
