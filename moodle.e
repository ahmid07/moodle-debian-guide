```bash
#!/bin/bash
# Script para instalar Moodle 5.1 en Debian con Apache2, MariaDB y PHP
# Manteniendo WordPress en /var/www/html

# Variables (modificar según necesites)
MOODLE_DB="moodle"
MOODLE_DB_USER="moodleuser"
MOODLE_DB_PASS="TuPasswordSegura"
MOODLE_DIR="/var/www/moodle"
MOODLEDATA_DIR="/var/www/moodledata"
TGZ_FILE="/var/www/moodle-5.1.tgz"

# Actualizar sistema
echo "Actualizando sistema..."
apt update && apt upgrade -y

# Instalar Apache, MariaDB y PHP con extensiones
echo "Instalando Apache, MariaDB y PHP..."
apt install apache2 mariadb-server php php-cli php-fpm php-common php-zip php-gd php-mbstring \
php-curl php-xml php-xmlrpc php-intl php-soap php-bcmath php-mysql php-ldap \
php-opcache php-readline php-apcu unzip -y

# Comprobar estado MariaDB
systemctl enable mariadb
systemctl start mariadb

# Crear base de datos y usuario
echo "Creando base de datos y usuario para Moodle..."
mysql -u root <<EOF
CREATE DATABASE ${MOODLE_DB} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${MOODLE_DB_USER}'@'localhost' IDENTIFIED BY '${MOODLE_DB_PASS}';
GRANT ALL PRIVILEGES ON ${MOODLE_DB}.* TO '${MOODLE_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Extraer Moodle
echo "Extrayendo Moodle..."
mkdir -p ${MOODLE_DIR} ${MOODLEDATA_DIR}
tar -xvzf ${TGZ_FILE} -C /var/www/
mv /var/www/moodle ${MOODLE_DIR} 2>/dev/null || true

# Configurar permisos
echo "Configurando permisos..."
chown -R www-data:www-data ${MOODLE_DIR} ${MOODLEDATA_DIR}
chmod -R 755 ${MOODLE_DIR}
chmod -R 770 ${MOODLEDATA_DIR}

# Configurar Apache
echo "Configurando Apache..."
APACHE_CONF="/etc/apache2/sites-available/000-default.conf"
cp ${APACHE_CONF} ${APACHE_CONF}.bak
sed -i '/<\/VirtualHost>/i \
# Moodle Alias\nAlias /moodle /var/www/moodle\n<Directory /var/www/moodle>\n    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>\n' ${APACHE_CONF}

# Habilitar rewrite y reiniciar Apache
a2enmod rewrite
systemctl restart apache2

echo "✅ Moodle 5.1 instalado correctamente."
echo "Visita http://TU_IP/moodle para continuar la configuración desde el navegador."
```
