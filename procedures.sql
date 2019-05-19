create FUNCTION AVERAGE_SALARY return int as 
    avg_sal int;
BEGIN
	SELECT AVG(SALARY) into avg_sal from EMPLOYEES;
	return avg_sal;
END;
/

create function distance_between_2cities(or1 varchar, or2 varchar) return int is
    result int;
begin
	select DISTANCE.distance into result from DISTANCE
	WHERE (CITY1 = or1 and CITY2 = or2) or (CITY1 = or2 and CITY2 = or1);
	return result;
end;
/

create function find_locID_by_name(locname varchar2) return int as
	result int;
begin
	select loc_id into result from LOCATIONS where name = locname;
	return result;
end;
/

create PROCEDURE gen_emp_pdf(emp_id int) IS
    emp_data EMPLOYEES%rowtype;
    gen_pdf blob;
    already int;
    exis int;
BEGIN

	select * into emp_data from EMPLOYEES where EMPLOYEES.ID = emp_id;

	plpdf.init();
	plpdf.newpage;

	plpdf.SetPrintFont(
		p_family => 'Arial',
		p_style => null,
		p_size => 30
	);

	plpdf.PrintoutText(
		p_x => 100,
		p_y => 30,
		p_txt => emp_data.FULL_NAME
	);

	plpdf.SetPrintFont(
		p_family => 'Arial',
		p_style => null,
		p_size => 12
	);

	plpdf.PrintoutText(
		p_x => 30,
		p_y => 50,
		p_txt => 'Email:	' || emp_data.EMAIL
	);

	plpdf.PrintoutText(
		p_x => 30,
		p_y => 60,
		p_txt => 'Salary:	' || emp_data.SALARY || '$'
		);

	plpdf.PrintoutText(
		p_x => 30,
		p_y => 70,
		p_txt => 'Hire date:	' || to_char(emp_data.HIRE_DATE, 'yyyy/mm/dd')
	);

	plpdf.PrintoutText(
		p_x => 30,
		p_y => 80,
		p_txt => 'Bate of birth:	' || to_char(emp_data.DATE_OF_BIRTH, 'yyyy/mm/dd')
	);

	plpdf.sendDoc(p_blob => gen_pdf);

	select count(*) into already from INVOICES where id = emp_id;

	if already = 0 then
		insert into INVOICES(id, invoice_pdf) VALUES (emp_id, gen_pdf);
	else
	    update INVOICES set INVOICE_PDF = gen_pdf where id = emp_id;
	end if;

	commit;

END;
/

create function get_emp_fullname_by_email(e_mail varchar2) return varchar2 is
	fn varchar2(50);
begin
	select FULL_NAME into fn from EMPLOYEES where EMPLOYEES.EMAIL = e_mail;
	return fn;
end;
/

create function get_emp_hiredate_by_email(e_mail varchar2) return date is
	hd date;
begin
	select HIRE_DATE into hd from EMPLOYEES where EMPLOYEES.EMAIL = e_mail;
	return hd;
end;
/

create function get_emp_pdf_by_email(e_mail varchar2) return blob is
	emp_pdf blob;
	emp_id integer;
begin
    select id into emp_id from EMPLOYEES where EMPLOYEES.EMAIL = e_mail;
    GEN_EMP_PDF(emp_id);
    
    select INVOICE_PDF into emp_pdf from INVOICES where INVOICES.ID = emp_id;
    return emp_pdf;
end;
/

create function get_emp_salary_by_email(e_mail varchar2) return integer is
	sal integer;
begin
	select salary into sal from EMPLOYEES where EMPLOYEES.EMAIL = e_mail;
	return sal;
end;
/

create function get_vehID_by_name(veh_name varchar2) return int is
	result int;
begin
	select id into result from VEHICLE_TYPES where full_name = veh_name;

    return result;
end;
/

create procedure insert_driver(full_name varchar2, email varchar2 ,password varchar2, birth_date varchar2) as
    id_driver int;
        bd date;
begin
    select max(id) into id_driver from DRIVERS;
    if (id_driver is null) then
		id_driver := 1;
	else
        id_driver := id_driver + 1;
	end if;

	bd := to_date(birth_date, 'yyyy-mm-dd');

	insert into DRIVERS values (id_driver, full_name, email, password, bd, sysdate, sysdate, 100, 0);
    commit;
end;
/

create procedure insert_emp(full_name varchar2, password varchar2, birth_date varchar2) as
    id_emp int;
	gen_email EMPLOYEES.EMAIL%TYPE;
    bd date;
begin
	select max(id) into id_emp from EMPLOYEES;
    if (id_emp is null) then
		id_emp := 1;
	else
        id_emp := id_emp + 1;
	end if;

	gen_email := replace(full_name, ' ', '.');
	gen_email := lower(gen_email)||'@transporter.com';
	bd := to_date(birth_date, 'yyyy-mm-dd');

	DBMS_OUTPUT.put_line(gen_email);
	DBMS_OUTPUT.put_line(id_emp);

	insert into EMPLOYEES(
	                      id, full_name, email, password,
	                      date_of_birth, is_full_time,
	                      salary, dept_id, hire_date,
	                      created_at, updated_at, country_code
	                      )
	                      values
	                      (
	                      id_emp, full_name,
	                      gen_email, password,
	                      bd, 1, 0, null,
	                      sysdate, sysdate, sysdate, 0
						  );
	commit;
end;
/

create procedure pdf_example is
	l_pdf blob;
BEGIN
	PLPDF.INIT();
	PLPDF.NewPage;
	plpdf.SetPrintFont(
		p_family => 'Arial',
		p_style => null,
		p_size => 12
	);
	plpdf.PrintoutText(
		p_x => 20,
		p_y => 30,
		p_txt => 'HOHOHO acesta este un document pdf'
	);
	plpdf.SendDoc(
	    p_blob => l_pdf
	);
	insert into STORE_BLOB(blob_file, created_date, filename)
	VALUES (l_pdf, sysdate, 'Example.pdf');
	commit; 
end;
/

create procedure set_emp_salary(emp_id int, sal int) as
begin
    update EMPLOYEES set salary = sal where id = emp_id;
	commit;
end;
/

create PACKAGE route_controller as
    type nrarr is table of NUMBER index by pls_integer;
    type arrtype is table of varchar2(100) index by pls_integer;
    procedure calculate_itinerary(cities in out arrtype, maxi_load int);
    function distance_between_cities(cities in arrtype) return int;
    procedure bkt(cities in out arrtype,position in out nrarr, n int, best in out arrtype);
    function insert_route(stop_array in out arrtype, maxi_load int, veh_name varchar2) return blob;
    function get_route_blob(id_super_route int, stop_array arrtype) return blob;
    procedure test;
end route_controller;
/

create package body route_controller as

    function distance_between_cities(cities in arrtype) return int is
        total_distance int := 0;
    begin

        for i in cities.first..cities.LAST-1 loop
			total_distance := total_distance +
			                  distance_between_2cities(cities(i), cities(i+1));
		end loop;

		return total_distance;

    end distance_between_cities;

    procedure bkt(cities in out arrtype,position in out nrarr, n int, best in out arrtype) is
        total_dist int;
        finish_cand arrtype;
        is_present int := 0;
    begin
		if n = cities.COUNT + 1 then
			for i in position.first..position.last loop
				finish_cand(i) := cities(position(i));
			end loop;
-- 			DBMS_OUTPUT.put_line(finish_cand(1)||' '||finish_cand(2)||' '||finish_cand(3)||' '||finish_cand(4)||'-'||distance_between_cities(finish_cand));
-- 			DBMS_OUTPUT.put_line(position(1)||position(2)||position(3));
			total_dist := distance_between_cities(finish_cand);
			if total_dist < distance_between_cities(best) then
				best := finish_cand;
			end if;
		else
			for i in cities.first..cities.LAST loop
-- 			    DBMS_OUTPUT.put_line('trying'||i);
				is_present := 0;
				--verficam aparitiea anterioara
				for j in cities.first..n - 1 loop
-- 				    DBMS_OUTPUT.put_line('j'||position(j));
					if position(j) = i then
						is_present := 1;
					end if;
				end loop;
				--daca nu exista il inseram, trebuie de fiecare daca sa existe macar unul
				if is_present = 0 then
					position(n) := i;
-- 					DBMS_OUTPUT.put_line('Inseram '||i);
					bkt(cities, position, n + 1, best);
				end if;

			end loop;
		end if;
    end bkt;


    procedure CALCULATE_ITINERARY(cities in out arrtype, maxi_load int) is
        pos nrarr;
        n int;
        first varchar2(100);
        second varchar2(100);
        veh_name VEHICLE_TYPES.FULL_NAME%TYPE;
        exists_car int;
        total_dist int;
        consum int;
        price int;
	begin

	    n := cities.count;

	    for i in cities.first..cities.LAST loop
			pos(i) := 0;
		end loop;

		bkt(cities, pos, 1, cities);

		total_dist := distance_between_cities(cities);

		for i in n+1..2*n-1 loop
		    first := cities(i - n);
		    second := cities(i - n + 1);
			cities(i) := DISTANCE_BETWEEN_2CITIES(first, second);
		end loop;

		SELECT count(FULL_NAME) INTO exists_car from
		        (
		            select * from
					VEHICLE_TYPES t join VEHICLES v
					on t.ID = v.VEHICLE_TYPE
					where t.MAX_LOAD > maxi_load
					order by t.FUEL_CONS_100KM, t.CUBIC_CAP_CCM asc
				) where ROWNUM=1;

		if exists_car = 0 then
			cities(2 * n) := 'No car available at the moment but best route is';
			cities(2 * n + 1) := 'Cannot calculate fuel price';
		else
		    SELECT FULL_NAME, FUEL_CONS_100KM
		    INTO veh_name, consum from
		        (
		            select * from
					VEHICLE_TYPES t join VEHICLES v
					on t.ID = v.VEHICLE_TYPE
					where t.MAX_LOAD > maxi_load
					order by t.FUEL_CONS_100KM, t.CUBIC_CAP_CCM asc
				) where ROWNUM=1;
			cities(2 * n) := veh_name;
			price := (5.8 * (total_dist/100) * consum)||'';
		    cities(2 * n + 1) := price;

		end if;

		cities(2 * n + 2) := total_dist;

	end CALCULATE_ITINERARY;


	function insert_route(stop_array in out arrtype, maxi_load int, veh_name varchar2) return blob is
		n int;
		id_super_route int;
		total_dist int;
		id_atomic int;
		start_id int;
		dest_id int;
		seq_nr int := 1;
	begin

	    select count(*) into id_super_route from SUPER_ROUTES;

	    if id_super_route = 0 then
			id_super_route := 1;
		else
	        select max(SUPER_ROUTE_ID) + 1 into id_super_route from SUPER_ROUTES;
		end if;

		n := stop_array.count;
		total_dist := stop_array(n);

		select count(*) into id_atomic from ATOMIC_ROUTES;

	    if id_atomic = 0 then
			id_atomic := 1;
		else
	        select max(AT_ROUTE_ID) + 1 into id_atomic from ATOMIC_ROUTES;
		end if;

		n := (n-3)/2 - 1;

		for i in stop_array.first..n loop

		    start_id := FIND_LOCID_BY_NAME(stop_array(i));
		    dest_id  := FIND_LOCID_BY_NAME(stop_array(i+ 1));

			insert into ATOMIC_ROUTES(at_route_id, super_route_id, start_location,
			                          dest_location, is_load_point, dest_client_id,
			                          kg_to_load, seq_nr_in_route)
			    					  values
									  (
									   id_atomic, id_super_route, start_id,
									   dest_id, 1, null, maxi_load, seq_nr
									  );
			id_atomic := id_atomic + 1;
			seq_nr := seq_nr + 1;
		end loop;

		start_id := FIND_LOCID_BY_NAME(stop_array(1));
		dest_id  := FIND_LOCID_BY_NAME(stop_array(n+1));

		insert into SUPER_ROUTES(super_route_id, start_location, dest_location, vehicle, driver)
		VALUES (id_super_route, start_id, dest_id, get_vehID_by_name(veh_name), null);

		commit;

		return get_route_blob(id_super_route, stop_array);
	end insert_route;


	function get_route_blob(id_super_route int, stop_array arrtype) return blob is
		bob blob;
		total_dist int;
		car varchar2(50);
		price int;
		n int;
	begin
	    PLPDF.INIT();
		PLPDF.NewPage;
		plpdf.SetPrintFont(
			p_family => 'Arial',
			p_style => null,
			p_size => 40
		);

		plpdf.PrintoutText(
			p_x => 75,
			p_y => 20,
			p_txt => 'Transporter'
		);

		plpdf.SetPrintFont(
			p_family => 'Arial',
			p_style => null,
			p_size => 12
		);

		plpdf.PrintoutText(
			p_x => 80,
			p_y => 30,
			p_txt => 'We bring everything everywhere'
		);



		n := stop_array.COUNT;
		total_dist := stop_array(n);
		price := stop_array(n-1) + stop_array(n-1)/3;
		car := stop_array(n-2);

		n := n-3;

		plpdf.SetPrintFont(
			p_family => 'Arial',
			p_style => null,
			p_size => 15
		);

		for i in stop_array.first..(n/2)-1 loop
			plpdf.PrintoutText(
				p_x => 30,
				p_y => 50 + i*10,
				p_txt => stop_array(i) || ' --- ' || stop_array(i+n/2)||'km --- '||stop_array(i+1)
			);
		end loop;

		plpdf.PrintoutText(
			p_x => 30,
			p_y => 150,
			p_txt => 'Car : '|| car
		);

		plpdf.PrintoutText(
			p_x => 30,
			p_y => 160,
			p_txt => 'Price (fuel + 30%) : ' || price
		);

		plpdf.PrintoutText(
			p_x => 30,
			p_y => 170,
			p_txt => 'Total distance : '|| total_dist
		);


		plpdf.PrintoutText(
			p_x => 30,
			p_y => 230,
			p_txt => 'Transporter'
		);

		plpdf.PrintoutText(
			p_x => 30,
			p_y => 250,
			p_txt => '-----------'
		);
		plpdf.PrintoutText(
			p_x => 150,
			p_y => 230,
			p_txt => 'Client signature'
		);
		plpdf.PrintoutText(
			p_x => 150,
			p_y => 250,
			p_txt => '-------------'
		);

		plpdf.SendDoc(p_blob => bob);

		insert into ROUTE_PDF(sr_id, b_pdf) VALUES (id_super_route, bob);
		commit;
		return bob;
	end;


    procedure test is
    	cities arrtype;
    	dum arrtype;
    	pos nrarr;
    	bob blob;
    begin
        cities(1) := 'Arad';
        cities(3) := 'Călăraşi';
        cities(2) := 'Constanţa';

        calculate_itinerary(cities, 1000);

        bob := insert_route(cities, 1000, 'Land Rover model 12');

    end test;

end route_controller;
/

