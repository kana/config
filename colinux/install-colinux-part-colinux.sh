#!/bin/bash

EDITOR=${EDITOR:-editor}

echo ''
echo '1. Swap disk'
# ?: add '/dev/cobd1 none swap sw 0 0' in /etc/fstab
mkswap /dev/cobd1
/etc/init.d/mountall.sh




echo ''
echo '2. Network'
# ?: write /etc/network/interfaces (but use the default file as is)
cat >/dev/null <<'__END__'
auto lo eth0

iface lo inet loopback

iface eth0 inet static
  address 10.0.2.15
    netmask 255.255.255.0
      broadcast 10.0.2.255
        gateway 10.0.2.2
__END__

# ?: write /etc/resolv.conf (but use the default file as is)
cat >/dev/null <<'__END__'
nameserver 10.0.2.3
__END__

# ?: write /etc/hosts.allow
mv /etc/hosts.allow{,.orig}
cat >/etc/hosts.allow <<'__END__'
ALL: localhost 10.0.2.0/255.255.255.0
__END__

# ?: write /etc/hosts.deny
mv /etc/hosts.deny{,.orig}
cat >/etc/hosts.deny <<'__END__'
ALL: ALL
__END__

echo '- Edit yoru favorite hostname.'
echo -n '(continue)'; read
$EDITOR /etc/hostname
$EDITOR /etc/hosts
/etc/init.d/hostname.sh




echo ''
echo '3. Timezone'
tzconfig
/etc/init.d/hwclock.sh start




echo ''
echo '4. Account'
echo -n 'User name? '; read username
echo -n 'Comment? '; read comment
useradd -c "$comment" -g users -m -s /bin/bash "$username"
passwd "$username"




echo ''
echo '5. Absolutely necessary packages'
apt-get update
apt-get dist-upgrade
for package in \
  ssh sudo vim gcc make python perl cvs subversion svk zip gzip bzip2 smbfs
do
  apt-get -y install $package
done

echo '5.1. GNU screen with 256 colors'
echo '- Uncomment --enable-colors256'
echo -n '(continue)'; read
mkdir -p /usr/src
cd /usr/src
apt-get source screen
apt-get build-dep screen
apt-get install ncurses-term
dpkg-source -x screen_4.0.3-0.3.dsc
cd screen-4.0.3/
$EDITOR debian/rules
dpkg-buildpackage -us -uc
dpkg --install ../screen_4.0.3-0.3_i386.deb
cd




# __END__
