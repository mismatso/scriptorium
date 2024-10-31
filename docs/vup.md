[↩︎ Volver al índice](/README.md)

## **VUP**

El script `vup` facilita la gestión de máquinas virtuales Vagrant, permitiendo arrancarlas y conectarse a ellas, o bien apagarlas, sin necesidad de navegar al directorio del `Vagrantfile`.

### **Uso de VUP**

#### **Prerrequisitos**

Asegúrate de tener Vagrant instalado y las instancias que deseas gestionar con `vup` aprovisionadas.

#### **Instalación de VUP**

1. Descarga el script `vup.sh`:

    Si tiene `curl` instalado:
    ```bash
    curl -o vup.sh -L https://raw.githubusercontent.com/mismatso/scriptorium/main/scripts/vup.sh
    ```
    Si prefiere usar el clásico `wget`:
    ```bash
    wget -O vup.sh https://raw.githubusercontent.com/mismatso/scriptorium/main/scripts/vup.sh
    ```

2. Crea un directorio para alojar los scripts:
   ```bash
   sudo mkdir -p /opt/scriptorium
   ```

3. Mueve el script `vup` a este directorio:
   ```bash
   sudo mv vup.sh /opt/scriptorium
   ```

4. Otorga permisos de ejecución al script `vup.sh`:
   ```bash
   sudo chmod o+x /opt/scriptorium/vup.sh
   ```

5. Crea un enlace simbólico para ejecutarlo desde cualquier ubicación:
   ```bash
   sudo ln -s /opt/scriptorium/vup.sh /usr/local/bin/vup
   ```

¡Listo! Ahora puedes ejecutar `vup` desde cualquier ubicación en tu sistema.

#### **Ejecutar VUP**

Para iniciar una instancia Vagrant y conectarte a ella mediante SSH, usa `vup` seguido del nombre o ID de la instancia.

1. Obtén el ID o nombre de tus instancias Vagrant con:
   ```bash
   vagrant global-status
   ```

2. Si la _cache_ de la información de instancias de Vagrant está desactualizada, debe limpiarla (antes de utilizar `vup`) y luego iniciar manualmente cada instancia con `vagrant up` para reconstruir la información de las instancias:
   ```bash
   vagrant global-status --prune
   ```

3. Para iniciar y conectarte a una instancia (por ejemplo, `webserver`):
   ```bash
   vup webserver
   ```

4. Para apagar la misma instancia:
   ```bash
   vup webserver -d
   ```

5. Para iniciar todas instancias de _Vagrant_:
   ```bash
   vup --all -u
   ```

6. Para apagar todas instancias de _Vagrant_:
   ```bash
   vup --all -d
   ```   

## **«Self-Promotion»**

Si lo desea, puede visitar mi canal de YouTube [MizaqScreencasts](https://www.youtube.com/MizaqScreencasts), seguirme en [Twitter](https://twitter.com/mismatso) o escribirme por [Telegram](https://t.me/mismatso).

## **Licencia**

[Scriptorium](https://github.com/mismatso/scriptorium) © 2024 by [Misael Matamoros](https://t.me/mismatso) está licenciado bajo la **GNU General Public License, version 3 (GPLv3)**. Para más detalles, consulta el archivo [LICENSE](/LICENSE).

!["GPLv3"](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)