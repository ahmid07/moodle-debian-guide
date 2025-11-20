# moodle-debian-guide
# Instalación de Moodle 5.1 en Debian junto a WordPress

Guía paso a paso para instalar Moodle 5.1 en un sistema Debian con Apache2, MariaDB y PHP, manteniendo WordPress funcionando en `/var/www/html`.

---

## 1️⃣ Preparar Debian

Actualizar el sistema:

```bash
sudo apt update && sudo apt upgrade -y
```

Instalar Apache, MariaDB y PHP con extensiones:

```bash
sudo apt install apache2 mariadb-server php php-cli php-fpm php-common php-zip php-gd php-mbstring \
php-curl php-xml php-xmlrpc php-intl php-soap php-bcmath php-mysql php-ldap \
php-opcache php-readline php-apcu unzip -y
```

Verificar PHP:

```bash
php -v
```

---

## 2️⃣ Configurar MariaDB

Asegurarse de que MariaDB está activo:

```bash
sudo systemctl status mariadb
```

Si no está activo:

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

Crear base de datos y usuario para Moodle:

```bash
sudo mariadb -u root -p
```

Dentro de MariaDB:

```sql
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'tu_password_segura';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

> Cambia `tu_password_segura` por una contraseña segura.

---

## 3️⃣ Descargar y extraer Moodle

Si tienes el archivo `.tgz`:

```bash
cd /var/www
sudo tar -xvzf moodle-5.1.tgz
sudo mkdir /var/www/moodledata
```

---

## 4️⃣ Configurar permisos

```bash
sudo chown -R www-data:www-data /var/www/moodle
sudo chmod -R 755 /var/www/moodle
sudo chmod -R 770 /var/www/moodledata
```

---

## 5️⃣ Configurar Apache

Editar el VirtualHost principal:

```bash
sudo nano /etc/apache2/sites-available/000-default.conf
```

Añadir dentro de `<VirtualHost *:80>`:

```apache
# Moodle en /moodle
Alias /moodle /var/www/moodle
<Directory /var/www/moodle>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

# WordPress en /var/www/html
<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```

Guardar y cerrar el archivo.

---

## 6️⃣ Habilitar módulo rewrite y reiniciar Apache

```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

---

## 7️⃣ Instalar Moodle desde el navegador

Visitar:

```
http://TU_IP/moodle
```

Configurar:

* Carpeta de datos: `/var/www/moodledata`
* Base de datos: `moodle`
* Usuario DB: `moodleuser`
* Contraseña DB: la que definiste

Seguir los pasos del instalador web.

---

## 8️⃣ Comprobaciones finales

* WordPress: `http://TU_IP/`
* Moodle: `http://TU_IP/moodle/`

Ambos sitios deben funcionar correctamente.

---

**Notas:**

* Mantén Moodle y WordPress en carpetas separadas (`/var/www/moodle` y `/var/www/html`).
* Siempre usa permisos correctos para que Apache pueda escribir en `moodledata`.
* Este README está listo para subir a GitHub.

---
