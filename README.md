# Instalación de MySQL, Apache, WordPress y Moodle 5.1 en Debian

Esta guía detalla paso a paso la instalación completa de un entorno con MySQL, Apache, WordPress y Moodle 5.1 en Debian.

> ⚠️ IMPORTANTE: Todas las contraseñas incluidas son ejemplos. Debes usar siempre contraseñas seguras y únicas.

## 1. Preparar el sistema

Actualizar el sistema e instalar herramientas básicas:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install wget curl git unzip sudo nano -y
```

## 2. Instalar MySQL 8.4

Agregar el repositorio oficial (ejemplo):

```bash
echo "deb [signed-by=/usr/share/keyrings/mysql.gpg] https://repo.mysql.com/apt/debian/ $(lsb_release -sc) mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
sudo apt update
```

Instalar MySQL:

```bash
sudo apt install mysql-server -y
```

Iniciar y habilitar el servicio:

```bash
sudo systemctl start mysql
sudo systemctl enable mysql
sudo systemctl status mysql
```

Configuración de seguridad:

```bash
sudo mysql_secure_installation
```

Configurar (ejemplos):

- Contraseña root: `RootMySQL!23`
- Eliminar usuarios anónimos
- Deshabilitar login remoto de root
- Eliminar base de datos `test`

Crear bases de datos y usuarios:

Para WordPress:

```sql
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'WpS3cur3!2025';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
```

Para Moodle:

```sql
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'Moodl3S3cur3!';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
```

## 3. Instalar Apache y PHP

```bash
sudo apt install apache2 php libapache2-mod-php php-mysql php-curl php-xml php-gd php-mbstring php-zip php-intl php-soap php-xmlrpc php-cli php-json -y
```

Iniciar y habilitar Apache:

```bash
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2
```

## 4. Instalar WordPress

```bash
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo rm latest.tar.gz
sudo chown -R www-data:www-data wordpress
sudo chmod -R 755 wordpress
```

Configurar Apache para WordPress (archivo de ejemplo `/etc/apache2/sites-available/wordpress.conf`):

```apache
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/wordpress
    ServerName midominio.local

    <Directory /var/www/html/wordpress/>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/wordpress_error.log
    CustomLog ${APACHE_LOG_DIR}/wordpress_access.log combined
</VirtualHost>
```

Activar sitio y módulo rewrite:

```bash
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

Agregar host (ejemplo):

```bash
sudo nano /etc/hosts
```

Añadir:

```text
127.0.0.1 midominio.local
```

Acceso:

➡️ http://midominio.local

## 5. Instalar Moodle 5.1 desde Git

```bash
cd /var/www
sudo git clone -b MOODLE_501_STABLE git://git.moodle.org/moodle.git moodle
```

Crear directorio de datos:

```bash
sudo mkdir -p /var/moodledata
sudo chown -R www-data:www-data /var/moodledata
sudo chmod -R 777 /var/moodledata
```

Permisos:

```bash
sudo chown -R www-data:www-data /var/www/moodle
sudo chmod -R 755 /var/www/moodle
```

> Nota: darle 777 a /var/moodledata es práctico pero menos seguro; ajustar según políticas de seguridad.

## 6. Instalar dependencias con Composer

```bash
cd /var/www/moodle
sudo composer install --no-dev --classmap-authoritative
```

## 7. Configurar Moodle

Accede:

➡️ http://moodle.local

Datos de conexión (ejemplo):

Campo    | Valor
-------- | -----
Tipo DB  | MySQL (mysqli)
Servidor | localhost
Base de datos | moodle
Usuario  | moodleuser
Contraseña | Moodl3S3cur3!
Prefijo  | mdl_

Directorio de datos:

`/var/moodledata`

Usuario administrador: `admin`
Contraseña segura (ejemplo): `Adm!nM00dle2025`

## 8. Verificación final

Servicio | Comando | Estado
-------- | ------- | -----
MySQL    | `sudo systemctl status mysql` | ✅
Apache   | `sudo systemctl status apache2` | ✅
WordPress| `http://midominio.local` | ✅
Moodle   | `http://moodle.local` | ✅
Permisos | Correctos | ✅
Extensiones PHP | Instaladas | ✅
