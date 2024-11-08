[↩︎ Volver al índice](/README.md)

# **CPDF**

El script `cpdf` permite comprimir archivos PDF, alcanzando una tasa de compresión de aproximadamente 13%. En pruebas realizadas, ha logrado reducir el tamaño de los archivos hasta en un 86%.

## **Instalación y uso de CPDF**

### **Prerrequisitos**

Para que `cpdf` funcione, primero instala los paquetes necesarios. En GNU/Linux Debian, ejecuta:

```bash
sudo apt update
sudo apt install pdftk ghostscript
```

### **Instalación de CPDF**

1. Descarga el script `cpdf.sh`:

    Si tiene `curl` instalado:
    ```bash
    curl -o cpdf.sh -L https://raw.githubusercontent.com/mismatso/scriptorium/main/scripts/cpdf.sh
    ```
    Si prefiere usar el clásico `wget`:
    ```bash
    wget -O cpdf.sh https://raw.githubusercontent.com/mismatso/scriptorium/main/scripts/cpdf.sh
    ```

2. Crea un directorio para alojar los scripts:
   ```bash
   sudo mkdir -p /opt/scriptorium
   ```

3. Mueve el script `cpdf` a este directorio:
   ```bash
   sudo mv cpdf.sh /opt/scriptorium
   ```

4. Otorga permisos de ejecución al script `cpdf.sh`:
   ```bash
   sudo chmod o+x /opt/scriptorium/cpdf.sh
   ```

5. Crea un enlace simbólico para ejecutarlo desde cualquier ubicación:
   ```bash
   sudo ln -s /opt/scriptorium/cpdf.sh /usr/local/bin/cpdf
   ```

¡Listo! Ahora puedes ejecutar `cpdf` desde cualquier ubicación en tu sistema.

### **Utilizando CPDF para comprimir mis archivos PDF**

Para comprimir un archivo PDF con CPDF simplemente abre una terminal en la ubicación del archivo y ejecuta `cpdf archivo-sin-comprimir.pdf`.

1. Comprimir un archivo PDF:
   ```bash
   cpdf archivo-sin-comprimir.pdf
   ```

2. Verificar la creación del archivo comprimido y comparar sus pesos:
   ```bash
   for file in *_comprimido*; do base_name="${file%_comprimido*}"; du -h "${base_name}"* 2>/dev/null; done | sort -u
   ```

## **Self-Promotion**

Si lo desea, puede:

- Visitar mi canal de YouTube [MizaqScreencasts](https://www.youtube.com/MizaqScreencasts)
- Seguirme en [Twitter](https://twitter.com/mismatso)
- Contactarme por [Telegram](https://t.me/mismatso)

## **Licencia**

[Scriptorium](https://github.com/mismatso/scriptorium) © 2024 by [Misael Matamoros](https://t.me/mismatso) está licenciado bajo la **GNU General Public License, version 3 (GPLv3)**. Para más detalles, consulta el archivo [LICENSE](/LICENSE).

!["GPLv3"](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)