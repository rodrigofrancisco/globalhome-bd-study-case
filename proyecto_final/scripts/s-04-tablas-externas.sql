--Se requiere hacer uso del usuario SYS para crear un objeto tipo
--directory y otorgar privilegios. 
prompt Conectando como sys
connect sys as sysdba

--Un objeto tipo directory es un objeto que se crea y almacena en el
-- diccionario de datos y se emplea para mapear directorios
-- reales en el sistema de archivos. En este caso tmp_dir es un
-- objeto que apunta al directorio /tmp/bases del servidor 
prompt creando directorio tmp_dir
create or replace directory tmp_dir as '/tmp/bases';

--se otorgan permisos para que el usuario jorge_0307 de la BD pueda leer
--el contenido del directorio
grant read, write on directory tmp_dir to ff_proy_admin;

prompt Contectando con usuario ff_proy_admin para crear la tabla externa
connect ff_proy_admin
show user
prompt creando tabla externa
create table vivienda_ext (
    num_empleado     number(10,0),
    nombre			 varchar2(40),
    ap_paterno       varchar2(40),
    ap_materno       varchar2(40),
    fecha_nacimiento date,
    email            varchar2(100),
    sueldo_mensual   number(8,2),
    comision         number(5,2)
)
organization external (
    --En oracle existen 2 tipos de drivers para parsear el archivo:
    -- oracle_loader  y oracle_datapump
    type oracle_loader
    default directory tmp_dir
    access parameters (
        records delimited by newline
        badfile tmp_dir:'vivienda_ext_bad.log'
        logfile tmp_dir:'vivienda_ext.log'
        fields terminated by ','
        lrtrim
        missing field values are null 
        (
        	num_empleado, nombre, ap_paterno, ap_materno,
        	fecha_nacimiento date mask "dd/mm/yyyy",email,sueldo_mensual,comision
        )
    )
    location ('vivienda_ext.csv')
)
reject limit unlimited;

--Dentro de sqlplus se pueden ejecutar comandos del s.o. empleando '!'
--En esta instrucción se crea el directorio /tmp/bases para
--copiar el archivo csv
prompt creando el directorio /tmp/bases en caso de no existir
!mkdir -p /tmp/bases

-- Asegurarse que el archivo csv se encuentra en elmismo
-- directorio donde se está ejecutando este script.
-- De lo contrario,  el comando cp fallará.
prompt copiando el archivo csv a /tmp/bases
!cp vivienda_ext.csv /tmp/bases
prompt cambiando permisos
!chmod 777 /tmp/bases

prompt mostrando los datos 

col nombre format a15
col ap_paterno format a15
col ap_materno format a15
col email format a15

select * from vivienda_ext;

