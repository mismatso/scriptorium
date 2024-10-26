# Scriptorium

Bienvenido a **Scriptorium**. En este repositorio estaré subiendo scripts de bash útiles para la realización de tareas comunes en GNU/Linux.

## **CPDF**

El script `cpdf` permite comprimir archivos PDF, alcanzando una tasa de compresión de aproximadamente 13%. En pruebas realizadas, ha logrado reducir el tamaño de los archivos hasta en un 86%.

### **Uso de CPDF**

#### **Prerrequisitos**

Para que `cpdf` funcione, primero instala los paquetes necesarios. En GNU/Linux Debian, ejecuta:

```bash
sudo apt update
sudo apt install pdftk ghostscript
```

#### **Instalación de CPDF**

1. Clona el repositorio **Scriptorium**:

    Si tienes una clave SSH configurada en GitHub:
    ```bash
    git clone git@github.com:mismatso/scriptorium.git
    ```
    Si prefieres la URL HTTPS:
    ```bash
    git clone https://github.com/mismatso/scriptorium.git
    ```

1. Ingresa al directorio del repositorio:
   ```bash
   cd scriptorium
   ```

2. Crea un directorio para alojar los scripts:
   ```bash
   sudo mkdir -p /opt/scriptorium
   ```

3. Copia el script `cpdf` a este directorio:
   ```bash
   sudo cp scripts/cpdf.sh /opt/scriptorium
   ```

4. Crea un enlace simbólico para ejecutarlo desde cualquier ubicación:
   ```bash
   sudo ln -s /opt/scriptorium/cpdf.sh /usr/local/bin/cpdf
   ```

¡Listo! Ahora puedes ejecutar `cpdf` desde cualquier ubicación en tu sistema.

#### **Ejecutar CPDF**

Para comprimir un archivo PDF, sitúate en la carpeta donde esté el archivo y ejecuta `cpdf` seguido del nombre del archivo. CPDF generará una versión comprimida del archivo con el sufijo `_comprimido`:

```bash
cpdf archivo.pdf
```

El comando generará un nuevo archivo llamado `archivo_comprimido.pdf`.

## **VUP**

El script `vup` facilita la gestión de máquinas virtuales Vagrant, permitiendo arrancarlas y conectarse a ellas, o bien apagarlas, sin necesidad de navegar al directorio del `Vagrantfile`.

### **Uso de VUP**

#### **Prerrequisitos**

Asegúrate de tener Vagrant instalado y las instancias aprovisionadas que deseas gestionar con `vup`.

#### **Instalación de VUP**

1. Clona el repositorio **Scriptorium**:

    Si tienes una clave SSH configurada en GitHub:
    ```bash
    git clone git@github.com:mismatso/scriptorium.git
    ```
    Si prefieres la URL HTTPS:
    ```bash
    git clone https://github.com/mismatso/scriptorium.git
    ```

2. Ingresa al directorio del repositorio:
   ```bash
   cd scriptorium
   ```

3. Crea un directorio para alojar los scripts:
   ```bash
   sudo mkdir -p /opt/scriptorium
   ```

4. Copia el script `vup` a este directorio:
   ```bash
   sudo cp scripts/vup.sh /opt/scriptorium
   ```

5. Crea un enlace simbólico para ejecutarlo desde cualquier ubicación:
   ```bash
   sudo ln -s /opt/scriptorium/vup.sh /usr/local/bin/vup
   ```

`vup` ya está listo para usarse desde cualquier ubicación en tu sistema.

#### **Ejecutar VUP**

Para iniciar una instancia Vagrant y conectarte a ella mediante SSH, usa `vup` seguido del nombre o ID de la instancia.

1. Obtén el ID o nombre de tus instancias Vagrant con:
   ```bash
   vagrant global-status
   ```

2. Para iniciar y conectarte a una instancia (por ejemplo, `webserver`):
   ```bash
   vup webserver
   ```

3. Para apagar la misma instancia:
   ```bash
   vup webserver -d
   ```

## **«Self-Promotion»**

Si lo desea, puede visitar mi canal de YouTube [MizaqScreencasts](https://www.youtube.com/MizaqScreencasts), seguirme en [Twitter](https://twitter.com/mismatso) o escribirme por [Telegram](https://t.me/mismatso).

## **Licencia**

[Scriptorium](https://github.com/mismatso/scriptorium) © 2024 by [Misael Matamoros](https://t.me/mismatso) está licenciado bajo la **GNU General Public License, version 3 (GPLv3)**. Para más detalles, consulta el archivo [LICENSE](./LICENSE).

!["GPLv3"](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)