# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<EOSCRIPT

read -d '' PUBLIC_KEY <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQENBFOpvpgBCADkP656H41i8fpplEEB8IeLhugyC2rTEwwSclb8tQNYtUiGdna9
m38kb0OS2DDrEdtdQb2hWCnswxaAkUunb2qq18vd3dBvlnI+C4/xu5ksZZkRj+fW
tArNR18V+2jkwcG26m8AxIrT+m4M6/bgnSfHTBtT5adNfVcTHqiT1JtCbQcXmwVw
WbqS6v/LhcsBE//SHne4uBCK/GHxZHhQ5jz5h+3vWeV4gvxS3Xu6v1IlIpLDwUts
kT1DumfynYnnZmWTGc6SYyIFXTPJLtnoWDb9OBdWgZxXfHEcBsKGha+bXO+m2tHA
gNneN9i5f8oNxo5njrL8jkCckOpNpng18BKXABEBAAG0MlNhbHRTdGFjayBQYWNr
YWdpbmcgVGVhbSA8cGFja2FnaW5nQHNhbHRzdGFjay5jb20+iQE4BBMBAgAiBQJT
qb6YAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRAOCKFJ3le/vhkqB/0Q
WzELZf4d87WApzolLG+zpsJKtt/ueXL1W1KA7JILhXB1uyvVORt8uA9FjmE083o1
yE66wCya7V8hjNn2lkLXboOUd1UTErlRg1GYbIt++VPscTxHxwpjDGxDB1/fiX2o
nK5SEpuj4IeIPJVE/uLNAwZyfX8DArLVJ5h8lknwiHlQLGlnOu9ulEAejwAKt9CU
4oYTszYM4xrbtjB/fR+mPnYh2fBoQO4d/NQiejIEyd9IEEMd/03AJQBuMux62tjA
/NwvQ9eqNgLw9NisFNHRWtP4jhAOsshv1WW+zPzu3ozoO+lLHixUIz7fqRk38q8Q
9oNR31KvrkSNrFbA3D89uQENBFOpvpgBCADJ79iH10AfAfpTBEQwa6vzUI3Eltqb
9aZ0xbZV8V/8pnuU7rqM7Z+nJgldibFk4gFG2bHCG1C5aEH/FmcOMvTKDhJSFQUx
uhgxttMArXm2c22OSy1hpsnVG68G32Nag/QFEJ++3hNnbyGZpHnPiYgej3FrerQJ
zv456wIsxRDMvJ1NZQB3twoCqwapC6FJE2hukSdWB5yCYpWlZJXBKzlYz/gwD/Fr
GL578WrLhKw3UvnJmlpqQaDKwmV2s7MsoZogC6wkHE92kGPG2GmoRD3ALjmCvN1E
PsIsQGnwpcXsRpYVCoW7e2nW4wUf7IkFZ94yOCmUq6WreWI4NggRcFC5ABEBAAGJ
AR8EGAECAAkFAlOpvpgCGwwACgkQDgihSd5Xv74/NggA08kEdBkiWWwJZUZEy7cK
WWcgjnRuOHd4rPeT+vQbOWGu6x4bxuVf9aTiYkf7ZjVF2lPn97EXOEGFWPZeZbH4
vdRFH9jMtP+rrLt6+3c9j0M8SIJYwBL1+CNpEC/BuHj/Ra/cmnG5ZNhYebm76h5f
T9iPW9fFww36FzFka4VPlvA4oB7ebBtquFg3sdQNU/MmTVV4jPFWXxh4oRDDR+8N
1bcPnbB11b5ary99F/mqr7RgQ+YFF0uKRE3SKa7a+6cIuHEZ7Za+zhPaQlzAOZlx
fuBmScum8uQTrEF5+Um5zkwC7EXTdH1co/+/V/fpOtxIg4XO4kcugZefVm5ERfVS
MA==
=dtMN
-----END PGP PUBLIC KEY BLOCK-----
EOF

OS_VERSION="$(. /etc/os-release; echo $VERSION_ID)"
OS_CODENAME="$(. /etc/os-release; echo $VERSION | sed s/[^a-z]//g)"

APT_REPO_FILE="/etc/apt/sources.list.d/saltstack.list"
APT_REPO="deb http://repo.saltstack.com/apt/debian/$OS_VERSION/amd64/latest $OS_CODENAME main"

# Add the saltstack repostory
echo "$APT_REPO" > $APT_REPO_FILE

# Trust the saltstack repository signing key
echo "$PUBLIC_KEY" | apt-key add -

# Install salt minion and packages for testing wallabag
if [[ $OS_VERSION -eq 8 ]]; then
    LIBAPACHE_MOD_PHP="libapache2-mod-php5"
else
    LIBAPACHE_MOD_PHP="libapache2-mod-php"
fi

apt-get update
apt-get upgrade -y -q
apt-get install -y salt-minion \
    apache2 $LIBAPACHE_MOD_PHP \
    postgresql

# Create DB and User
cat <<EOF | su - postgres -c psql
CREATE USER wallabag WITH PASSWORD 'wallabagpass';
CREATE DATABASE wallabag;
GRANT ALL PRIVILEGES ON DATABASE wallabag TO wallabag;
EOF

read -d '' APACHE_CONF <<EOF

        <Directory /var/www/wallabag/web>
                RewriteEngine On
                RewriteCond %{REQUEST_FILENAME} !-f
                RewriteRule ^(.*)$ app.php [QSA,L]
        </Directory>
EOF

# Update default Apache DocumentRoot
sed -i /DocumentRoot/s/html/wallabag/ /etc/apache2/sites-available/000-default.conf

cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/wallabag/web
    <Directory /var/www/wallabag/web>
        AllowOverride None
        Order Allow,Deny
        Allow from All

        Options -MultiViews
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ app.php [QSA,L]
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
systemctl reload apache2.service

# Configure Minion
cat <<EOF > /etc/salt/minion
file_client: local

file_roots:
  base:
    - /srv/salt
    - /srv/salt/tests/states

pillar_roots:
  base:
    - /srv/salt/tests/pillar
EOF

EOSCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define "wallabag", primary: true do |host|
        host.vm.box = 'debian/contrib-stretch64'
        host.vm.host_name = 'wallabag.salt.example.com'
        host.vm.network :private_network, type: "dhcp"
        host.vm.synced_folder "./", "/srv/salt"
        host.vm.provision "shell", inline: $script
    end
end
