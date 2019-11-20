--@Autor: Flores García Karina
--@Autor: Pablo Rodrigo Francisco
--@Fecha creación: 19/11/2019
--@Descripcion: Subconsultas

--EJERCICIO 1
create table consulta_1 as (
	select count(*) num_articulos, sum(precio_venta) ingresos from (
		select precio_venta
		from subasta s
		join articulo a
		on  s.subasta_id = a.subasta_id
		left join subasta_venta sv
		on sv.articulo_id = a.articulo_id
		where to_char(fecha_inicio,'yyyy') = '2010'
		and to_char(fecha_fin,'yyyy') = '2010'
	)
);

--EJERCICIO 3
create table consulta_3 as ( -- totalmente copiada de David
	select min(precio_inicial) mas_barato_compra, 
	max(precio_inicial) mas_caro_compra, 
	min(precio_venta) mas_barato_venta,
	max(precio_venta) mas_caro_venta 
	from (
		select sv.precio_venta, a.precio_inicial
		from subasta s
		join articulo a
		on s.subasta_id = a.subasta_id
		join subasta_venta sv
		on sv.articulo_id = a. articulo_id
		where s.nombre = 'EXPO-MAZATLAN' 
	)
);

--EJERCICIO 4
create table consulta_4 as (
	select q1.cliente_id,email,numero_tarjeta from (
		select c.cliente_id
		from cliente c,tarjeta_cliente tc
		where c.cliente_id = tc.cliente_id
		and extract(year from fecha_nacimiento) >=1970
		and extract(year from fecha_nacimiento) <= 1975
		minus
		select sv.cliente_id from subasta_venta sv
	) q1, tarjeta_cliente tc,cliente c
	where q1.cliente_id = tc.cliente_id
	and c.cliente_id = q1.cliente_id
);

--EJERCICIO 6
create table consulta_6 as
	select s.nombre, s.fecha_inicio, s.lugar, a.tipo_articulo, 
	sum(sv.precio_venta) as total_venta
	from subasta_venta sv
	join articulo a
	on sv.articulo_id = a.articulo_id
	join subasta s
	on s.subasta_id = a.subasta_id
	where to_char(s.fecha_inicio, 'YYYY') = '2009'and 
	      to_char(s.fecha_fin, 'YYYY') = '2009'
	group by s.nombre, s.fecha_inicio, s.lugar, a.tipo_articulo
	order by total_venta desc;

--EJERCICIO 8 (ya no la pude optimizar más :( )
create table consulta_8 as
	select q1.subasta_id,q1.nombre_subasta,fecha_inicio,
	a.nombre nombre_articulo,a.clave_articulo,q1.mas_caro
	from (
		select s.subasta_id,max(precio_venta) mas_caro,
		fecha_inicio,fecha_fin,	s.nombre nombre_subasta
		from subasta s,articulo a, subasta_venta sv
		where s.subasta_id = a.subasta_id 
		and sv.articulo_id = a.articulo_id
		group by s.subasta_id,fecha_inicio,fecha_fin,s.nombre
	) q1,articulo a, subasta_venta sv
	where q1.subasta_id = a.subasta_id 
	and sv.articulo_id = a.articulo_id
	and sv.precio_venta = q1.mas_caro
	and (
		extract(year from fecha_inicio) = 2010
		and extract(year from fecha_fin) = 2010
	) and (
		extract(month from fecha_inicio) = 1
		or extract(month from fecha_inicio) = 3
		or extract(month from fecha_inicio) = 6
	) and (
		a.status_articulo_id = 3 
		or a.status_articulo_id = 4
	)
	order by subasta_id;