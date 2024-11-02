[↩︎ Volver al índice](/README.md)

# **VUP**

El script `vup` facilita la gestión de máquinas virtuales Vagrant, permitiendo arrancarlas y conectarse a ellas, o bien apagarlas, sin necesidad de navegar al directorio del `Vagrantfile`.

## **Instalación y uso de VUP**

### **Prerrequisitos**

Asegúrese de tener Vagrant instalado y las instancias que desea gestionar con `vup` aprovisionadas.

### **Instalación de VUP**

1. Descargue el script `vup.sh`:

    Si tiene `curl` instalado:
    ```bash
    curl -o vup.sh -L https://raw.githubusercontent.com/mismatso/scriptorium/main/scripts/vup.sh
    ```
    Si prefiere usar `wget`:
    ```bash
    wget -O vup.sh https://raw.githubusercontent.com/mismatso/scriptorium/main/scripts/vup.sh
    ```

2. Cree un directorio para alojar los scripts:
   ```bash
   sudo mkdir -p /opt/scriptorium
   ```

3. Mueva el script `vup` a este directorio:
   ```bash
   sudo mv vup.sh /opt/scriptorium
   ```

4. Otorgue permisos de ejecución al script `vup.sh`:
   ```bash
   sudo chmod +x /opt/scriptorium/vup.sh
   ```

5. Cree un enlace simbólico para ejecutarlo desde cualquier ubicación:
   ```bash
   sudo ln -s /opt/scriptorium/vup.sh /usr/local/bin/vup
   ```

¡Listo! Ahora puede ejecutar `vup` desde cualquier ubicación en su sistema.

### **Verificación de Caché en Vagrant**

El correcto funcionamiento de `vup` depende de la información que se obtiene de _Vagrant_ a través del comando `vagrant global-status`. Si esta información está desactualizada o es inválida, debe regenerar la caché antes de usar `vup`.

1. Verifique la información de la caché de _Vagrant_ con:
   ```bash
   vagrant global-status
   ```

2. Si la caché de la información de instancias de Vagrant está desactualizada, límpiela antes de utilizar `vup` y luego inicie manualmente cada instancia con `vagrant up` para reconstruir la información de las instancias:
   ```bash
   vagrant global-status --prune
   ```

### **Utilizando VUP para gestionar mis máquinas Vagrant**

Para iniciar una instancia Vagrant y conectarse a ella mediante SSH, use `vup` seguido del nombre o ID de la instancia.

1. Para iniciar una instancia (por ejemplo, `webserver`):
   ```bash
   vup -u webserver
   ```

2. Para iniciar dos instancias a la vez (por ejemplo, `webserver` y `database`):
   ```bash
   vup -u webserver -u database
   ```

3. Para conectarse a una instancia (por ejemplo, `webserver`):
   ```bash
   vup -c webserver
   ```

4. Para conectarse a una instancia e iniciarla sin preguntar si está apagada (por ejemplo, `fileserver`):
   ```bash
   vup -c --quiet fileserver
   ```

5. Para mostrar información de todas las instancias de Vagrant:
   ```bash
   vup -s
   ```

6. Para apagar la instancia `webserver`:
   ```bash
   vup -d webserver
   ```

7. Para iniciar todas las instancias de _Vagrant_:
   ```bash
   vup -u --all
   ```

8. Para apagar todas las instancias de _Vagrant_:
   ```bash
   vup -d --all
   ```

## **Self-Promotion**

Si lo desea, puede:

- Visitar mi canal de YouTube [MizaqScreencasts](https://www.youtube.com/MizaqScreencasts)
- Seguirme en [Twitter](https://twitter.com/mismatso)
- Contactarme por [Telegram](https://t.me/mismatso)

## **Licencia**

[Scriptorium](https://github.com/mismatso/scriptorium) © 2024 by [Misael Matamoros](https://t.me/mismatso) está licenciado bajo la **GNU General Public License, version 3 (GPLv3)**. Para más detalles, consulta el archivo [LICENSE](/LICENSE).

!["GPLv3"](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)