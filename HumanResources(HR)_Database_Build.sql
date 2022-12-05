--drop table HR_COUNTRIES cascade constraints ;
--drop table HR_departments cascade constraints;
--drop table HR_employees cascade constraints ;
--drop table HR_job_grades cascade constraints ;
--drop table HR_jobs cascade constraints ;
--drop table HR_locations cascade constraints ;

--drop table HR_regions cascade constraints ;
--drop table hr_job_history cascade constraints ;



Rem
Rem $Header: hr_cre.sql 03-mar-2001.10:05:13 ahunold Exp $
Rem
Rem hr_cre.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      hr_cre.sql - Create data objects for HR schema
Rem
Rem    DESCRIPTION
Rem      This script creates six tables, associated constraints
Rem      and indexes in the human resources (HR) schema.
Rem
Rem    NOTES
Rem
Rem    CREATED by Nancy Greenberg, Nagavalli Pataballa - 06/01/00
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ahunold     09/14/00 - Added emp_details_view
Rem    ahunold     02/20/01 - New header
Rem    vpatabal	 03/02/01 - Added HR_regions table, modified HR_regions
Rem			            column in HR_COUNTRIES table to NUMBER.
Rem			            Added foreign key from HR_COUNTRIES table
Rem			            to HR_regions table on region_id.
Rem		                    Removed currency name, currency symbol 
Rem			            columns from the HR_COUNTRIES table.
Rem		      	            Removed dn columns from HR_employees and
Rem			            HR_departments tables.
Rem			            Added sequences.	
Rem			            Removed not null constraint from 
Rem 			            salary column of the HR_employees table.
Rem   Chaitanya Koratamaddi - 02/05/06
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF 

REM ********************************************************************
REM Create the HR_regions table to hold region information for HR_locations
REM HR.HR_locations table has a foreign key to this table.

Prompt ******  Creating HR_regions table ....

CREATE TABLE HR_regions
    ( region_id      NUMBER 
       CONSTRAINT  region_id_nn NOT NULL 
    , region_name    VARCHAR2(25) 
    );

CREATE UNIQUE INDEX HR_reg_id_pk
ON HR_regions (region_id);

ALTER TABLE HR_regions
ADD ( CONSTRAINT reg_id_pk
       		 PRIMARY KEY (region_id)
    ) ;

REM ********************************************************************
REM Create the HR_COUNTRIES table to hold country information for customers
REM and company HR_locations. 
REM OE.CUSTOMERS table and HR.HR_locations have a foreign key to this table.

Prompt ******  Creating HR_COUNTRIES table ....

CREATE TABLE HR_COUNTRIES 
    ( country_id      CHAR(2) 
       CONSTRAINT  country_id_nn NOT NULL 
    , country_name    VARCHAR2(40) 
    , region_id       NUMBER 
    , CONSTRAINT     country_c_id_pk 
        	     PRIMARY KEY (country_id) 
    ) 
    ORGANIZATION INDEX; 

ALTER TABLE HR_COUNTRIES
ADD ( CONSTRAINT countr_reg_fk
        	 FOREIGN KEY (region_id)
          	  REFERENCES HR_regions(region_id) 
    ) ;

REM ********************************************************************
REM Create the HR_locations table to hold address information for company HR_departments.
REM HR.HR_departments has a foreign key to this table.

Prompt ******  Creating HR_locations table ....

CREATE TABLE HR_locations
    ( location_id    NUMBER(4)
    , street_address VARCHAR2(40)
    , postal_code    VARCHAR2(12)
    , city       VARCHAR2(30)
	CONSTRAINT     loc_city_nn  NOT NULL
    , state_province VARCHAR2(25)
    , country_id     CHAR(2)
    ) ;

CREATE UNIQUE INDEX HR_loc_id_pk
ON HR_locations (location_id) ;

ALTER TABLE HR_locations
ADD ( CONSTRAINT loc_id_pk
       		 PRIMARY KEY (location_id)
    , CONSTRAINT loc_c_id_fk
       		 FOREIGN KEY (country_id)
        	  REFERENCES HR_COUNTRIES(country_id) 
    ) ;

Rem 	Useful for any subsequent addition of rows to HR_locations table
Rem 	Starts with 3300

CREATE SEQUENCE HR_locations_seq
 START WITH     3300
 INCREMENT BY   100
 MAXVALUE       9900
 NOCACHE
 NOCYCLE;

REM ********************************************************************
REM Create the HR_departments table to hold company department information.
REM HR.HR_employees and HR.JOB_HISTORY have a foreign key to this table.

Prompt ******  Creating HR_departments table ....

CREATE TABLE HR_departments
    ( department_id    NUMBER(4)
    , department_name  VARCHAR2(30)
	CONSTRAINT  dept_name_nn  NOT NULL
    , manager_id       NUMBER(6)
    , location_id      NUMBER(4)
    ) ;

CREATE UNIQUE INDEX HR_dept_id_pk
ON HR_departments (department_id) ;

ALTER TABLE HR_departments
ADD ( CONSTRAINT dept_id_pk
       		 PRIMARY KEY (department_id)
    , CONSTRAINT dept_loc_fk
       		 FOREIGN KEY (location_id)
        	  REFERENCES HR_locations (location_id)
     ) ;

Rem 	Useful for any subsequent addition of rows to HR_departments table
Rem 	Starts with 280 

CREATE SEQUENCE HR_departments_seq
 START WITH     280
 INCREMENT BY   10
 MAXVALUE       9990
 NOCACHE
 NOCYCLE;

REM ********************************************************************
REM Create the HR_jobs table to hold the different names of job roles within the company.
REM HR.HR_employees has a foreign key to this table.

Prompt ******  Creating HR_jobs table ....

CREATE TABLE HR_jobs
    ( job_id         VARCHAR2(10)
    , job_title      VARCHAR2(35)
	CONSTRAINT     job_title_nn  NOT NULL
    , min_salary     NUMBER(6)
    , max_salary     NUMBER(6)
    ) ;

CREATE UNIQUE INDEX HR_job_id_pk 
ON HR_jobs (job_id) ;

ALTER TABLE HR_jobs
ADD ( CONSTRAINT job_id_pk
      		 PRIMARY KEY(job_id)
    ) ;

REM ********************************************************************
REM Create the HR_employees table to hold the employee personnel 
REM information for the company.
REM HR.HR_employees has a self referencing foreign key to this table.

Prompt ******  Creating HR_employees table ....

CREATE TABLE HR_employees
    ( employee_id    NUMBER(6)
    , first_name     VARCHAR2(20)
    , last_name      VARCHAR2(25)
	 CONSTRAINT     emp_last_name_nn  NOT NULL
    , email          VARCHAR2(25)
	CONSTRAINT     emp_email_nn  NOT NULL
    , phone_number   VARCHAR2(20)
    , hire_date      DATE
	CONSTRAINT     emp_hire_date_nn  NOT NULL
    , job_id         VARCHAR2(10)
	CONSTRAINT     emp_job_nn  NOT NULL
    , salary         NUMBER(8,2)
    , commission_pct NUMBER(2,2)
    , manager_id     NUMBER(6)
    , department_id  NUMBER(4)
    , CONSTRAINT     emp_salary_min
                     CHECK (salary > 0) 
    , CONSTRAINT     emp_email_uk
                     UNIQUE (email)
    ) ;

CREATE UNIQUE INDEX HR_emp_emp_id_pk
ON HR_employees (employee_id) ;


ALTER TABLE HR_employees
ADD ( CONSTRAINT     emp_emp_id_pk
                     PRIMARY KEY (employee_id)
    , CONSTRAINT     emp_dept_fk
                     FOREIGN KEY (department_id)
                      REFERENCES HR_departments
    , CONSTRAINT     emp_job_fk
                     FOREIGN KEY (job_id)
                      REFERENCES HR_jobs (job_id)
    , CONSTRAINT     emp_manager_fk
                     FOREIGN KEY (manager_id)
                      REFERENCES HR_employees
    ) ;

ALTER TABLE HR_departments
ADD ( CONSTRAINT dept_mgr_fk
      		 FOREIGN KEY (manager_id)
      		  REFERENCES HR_employees (employee_id)
    ) ;


Rem 	Useful for any subsequent addition of rows to HR_employees table
Rem 	Starts with 207 


CREATE SEQUENCE HR_employees_seq
 START WITH     207
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

REM ********************************************************************
REM Create the JOB_HISTORY table to hold the history of HR_jobs that 
REM HR_employees have held in the past.
REM HR.HR_jobs, HR_HR_departments, and HR.HR_employees have a foreign key to this table.

Prompt ******  Creating JOB_HISTORY table ....

CREATE TABLE HR_job_history
    ( employee_id   NUMBER(6)
	 CONSTRAINT    jhist_employee_nn  NOT NULL
    , start_date    DATE
	CONSTRAINT    jhist_start_date_nn  NOT NULL
    , end_date      DATE
	CONSTRAINT    jhist_end_date_nn  NOT NULL
    , job_id        VARCHAR2(10)
	CONSTRAINT    jhist_job_nn  NOT NULL
    , department_id NUMBER(4)
    , CONSTRAINT    jhist_date_interval
                    CHECK (end_date > start_date)
    ) ;

CREATE UNIQUE INDEX HR_jhist_emp_id_st_date_pk 
ON hr_job_history (employee_id, start_date) ;

ALTER TABLE HR_job_history
ADD ( CONSTRAINT jhist_emp_id_st_date_pk
      PRIMARY KEY (employee_id, start_date)
    , CONSTRAINT     jhist_job_fk
                     FOREIGN KEY (job_id)
                     REFERENCES HR_jobs
    , CONSTRAINT     jhist_emp_fk
                     FOREIGN KEY (employee_id)
                     REFERENCES HR_employees
    , CONSTRAINT     jhist_dept_fk
                     FOREIGN KEY (department_id)
                     REFERENCES HR_departments
    ) ;

REM ********************************************************************
REM Create the EMP_DETAILS_VIEW that joins the HR_employees, HR_jobs, 
REM HR_departments, HR_jobs, HR_COUNTRIES, and HR_locations table to provide details
REM about HR_employees.

Prompt ******  Creating EMP_DETAILS_VIEW view ...

CREATE OR REPLACE VIEW HR_emp_details_view
  (employee_id,
   job_id,
   manager_id,
   department_id,
   location_id,
   country_id,
   first_name,
   last_name,
   salary,
   commission_pct,
   department_name,
   job_title,
   city,
   state_province,
   country_name,
   region_name)
AS SELECT
  e.employee_id, 
  e.job_id, 
  e.manager_id, 
  e.department_id,
  d.location_id,
  l.country_id,
  e.first_name,
  e.last_name,
  e.salary,
  e.commission_pct,
  d.department_name,
  j.job_title,
  l.city,
  l.state_province,
  c.country_name,
  r.region_name
FROM
  HR_employees e,
  HR_departments d,
  HR_jobs j,
  HR_locations l,
  HR_COUNTRIES c,
  HR_regions r
WHERE e.department_id = d.department_id
  AND d.location_id = l.location_id
  AND l.country_id = c.country_id
  AND c.region_id = r.region_id
  AND j.job_id = e.job_id 
WITH READ ONLY;

COMMIT;


create table HR_job_grades (
GRADE_LEVEL VARCHAR2(3),
LOWEST_SAL NUMBER,
HIGHEST_SAL NUMBER);
 



 
rem
rem Header: hr_popul.sql 09-jan-01
rem
rem Copyright (c) 2001 Oracle Corporation.  All rights reserved.
rem
rem Owner  : ahunold
rem
rem NAME
rem   hr_popul.sql - Populate script for HR schema
rem
rem DESCRIPTON
rem
rem
rem NOTES
rem   There is a circular foreign key reference between 
rem   EMPLOYESS and HR_departments. That's why we disable
rem   the FK constraints here
rem
rem CREATED
rem   Nancy Greenberg, Nagavalli Pataballa - 06/01/00
rem
rem MODIFIED   (MM/DD/YY)
rem   ahunold   03/07/01 - small data errors corrected
rem                      - Modified region values of HR_COUNTRIES table
rem                      - Replaced ID sequence values for HR_employees
rem                        and HR_departments tables with numbers
rem                      - Moved create sequence statements to hr_cre
rem                      - Removed dn values for HR_employees and
rem                        HR_departments tables
rem                      - Removed currency columns values from
rem                        HR_COUNTRIES table
rem   ngreenbe           - Updated employee 178 for no department
rem   pnathan            - Insert new rows to HR_job_history table
rem   ahunold   02/20/01 - NLS_LANGUAGE, replacing non American
rem   ahunold   01/09/01 - checkin ADE
rem   Chaitanya Koratamaddi - 02/05/06

SET VERIFY OFF
ALTER SESSION SET NLS_LANGUAGE=American; 

REM ***************************insert data into the HR_regions table

Prompt ******  Populating HR_regions table ....

INSERT INTO HR_regions VALUES 
        ( 1
        , 'Europe' 
        );

INSERT INTO HR_regions VALUES 
        ( 2
        , 'Americas' 
        );

INSERT INTO HR_regions VALUES 
        ( 3
        , 'Asia' 
        );

INSERT INTO HR_regions VALUES 
        ( 4
        , 'Middle East and Africa' 
        );

REM ***************************insert data into the HR_COUNTRIES table

Prompt ******  Populating COUNTIRES table ....

INSERT INTO HR_COUNTRIES VALUES 
        ( 'IT'
        , 'Italy'
        , 1 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'JP'
        , 'Japan'
	, 3 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'US'
        , 'United States of America'
        , 2 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'CA'
        , 'Canada'
        , 2 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'CN'
        , 'China'
        , 3 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'IN'
        , 'India'
        , 3 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'AU'
        , 'Australia'
        , 3 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'ZW'
        , 'Zimbabwe'
        , 4 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'SG'
        , 'Singapore'
        , 3 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'UK'
        , 'United Kingdom'
        , 1 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'FR'
        , 'France'
        , 1 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'DE'
        , 'Germany'
        , 1 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'ZM'
        , 'Zambia'
        , 4 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'EG'
        , 'Egypt'
        , 4 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'BR'
        , 'Brazil'
        , 2 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'CH'
        , 'Switzerland'
        , 1 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'NL'
        , 'Netherlands'
        , 1 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'MX'
        , 'Mexico'
        , 2 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'KW'
        , 'Kuwait'
        , 4 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'IL'
        , 'Israel'
        , 4 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'DK'
        , 'Denmark'
        , 1 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'HK'
        , 'HongKong'
        , 3 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'NG'
        , 'Nigeria'
        , 4 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'AR'
        , 'Argentina'
        , 2 
        );

INSERT INTO HR_COUNTRIES VALUES 
        ( 'BE'
        , 'Belgium'
        , 1 
        );


REM ***************************insert data into the HR_locations table

Prompt ******  Populating HR_locations table ....

INSERT INTO HR_locations VALUES 
        ( 1000 
        , '1297 Via Cola di Rie'
        , '00989'
        , 'Roma'
        , NULL
        , 'IT'
        );

INSERT INTO HR_locations VALUES 
        ( 1100 
        , '93091 Calle della Testa'
        , '10934'
        , 'Venice'
        , NULL
        , 'IT'
        );

INSERT INTO HR_locations VALUES 
        ( 1200 
        , '2017 Shinjuku-ku'
        , '1689'
        , 'Tokyo'
        , 'Tokyo Prefecture'
        , 'JP'
        );

INSERT INTO HR_locations VALUES 
        ( 1300 
        , '9450 Kamiya-cho'
        , '6823'
        , 'Hiroshima'
        , NULL
        , 'JP'
        );

INSERT INTO HR_locations VALUES 
        ( 1400 
        , '2014 Jabberwocky Rd'
        , '26192'
        , 'Southlake'
        , 'Texas'
        , 'US'
        );

INSERT INTO HR_locations VALUES 
        ( 1500 
        , '2011 Interiors Blvd'
        , '99236'
        , 'South San Francisco'
        , 'California'
        , 'US'
        );

INSERT INTO HR_locations VALUES 
        ( 1600 
        , '2007 Zagora St'
        , '50090'
        , 'South Brunswick'
        , 'New Jersey'
        , 'US'
        );

INSERT INTO HR_locations VALUES 
        ( 1700 
        , '2004 Charade Rd'
        , '98199'
        , 'Seattle'
        , 'Washington'
        , 'US'
        );

INSERT INTO HR_locations VALUES 
        ( 1800 
        , '147 Spadina Ave'
        , 'M5V 2L7'
        , 'Toronto'
        , 'Ontario'
        , 'CA'
        );

INSERT INTO HR_locations VALUES 
        ( 1900 
        , '6092 Boxwood St'
        , 'YSW 9T2'
        , 'Whitehorse'
        , 'Yukon'
        , 'CA'
        );

INSERT INTO HR_locations VALUES 
        ( 2000 
        , '40-5-12 Laogianggen'
        , '190518'
        , 'Beijing'
        , NULL
        , 'CN'
        );

INSERT INTO HR_locations VALUES 
        ( 2100 
        , '1298 Vileparle (E)'
        , '490231'
        , 'Bombay'
        , 'Maharashtra'
        , 'IN'
        );

INSERT INTO HR_locations VALUES 
        ( 2200 
        , '12-98 Victoria Street'
        , '2901'
        , 'Sydney'
        , 'New South Wales'
        , 'AU'
        );

INSERT INTO HR_locations VALUES 
        ( 2300 
        , '198 Clementi North'
        , '540198'
        , 'Singapore'
        , NULL
        , 'SG'
        );

INSERT INTO HR_locations VALUES 
        ( 2400 
        , '8204 Arthur St'
        , NULL
        , 'London'
        , NULL
        , 'UK'
        );

INSERT INTO HR_locations VALUES 
        ( 2500 
        , 'Magdalen Centre, The Oxford Science Park'
        , 'OX9 9ZB'
        , 'Oxford'
        , 'Oxford'
        , 'UK'
        );

INSERT INTO HR_locations VALUES 
        ( 2600 
        , '9702 Chester Road'
        , '09629850293'
        , 'Stretford'
        , 'Manchester'
        , 'UK'
        );

INSERT INTO HR_locations VALUES 
        ( 2700 
        , 'Schwanthalerstr. 7031'
        , '80925'
        , 'Munich'
        , 'Bavaria'
        , 'DE'
        );

INSERT INTO HR_locations VALUES 
        ( 2800 
        , 'Rua Frei Caneca 1360 '
        , '01307-002'
        , 'Sao Paulo'
        , 'Sao Paulo'
        , 'BR'
        );

INSERT INTO HR_locations VALUES 
        ( 2900 
        , '20 Rue des Corps-Saints'
        , '1730'
        , 'Geneva'
        , 'Geneve'
        , 'CH'
        );

INSERT INTO HR_locations VALUES 
        ( 3000 
        , 'Murtenstrasse 921'
        , '3095'
        , 'Bern'
        , 'BE'
        , 'CH'
        );

INSERT INTO HR_locations VALUES 
        ( 3100 
        , 'Pieter Breughelstraat 837'
        , '3029SK'
        , 'Utrecht'
        , 'Utrecht'
        , 'NL'
        );

INSERT INTO HR_locations VALUES 
        ( 3200 
        , 'Mariano Escobedo 9991'
        , '11932'
        , 'Mexico City'
        , 'Distrito Federal,'
        , 'MX'
        );


REM ****************************insert data into the HR_departments table

Prompt ******  Populating HR_departments table ....

REM disable integrity constraint to HR_employees to load data

ALTER TABLE HR_departments 
  DISABLE CONSTRAINT dept_mgr_fk;

INSERT INTO HR_departments VALUES 
        ( 10
        , 'Administration'
        , 200
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 20
        , 'Marketing'
        , 201
        , 1800
        );
                                
INSERT INTO HR_departments VALUES 
        ( 30
        , 'Purchasing'
        , 114
        , 1700
	);
                
INSERT INTO HR_departments VALUES 
        ( 40
        , 'Human Resources'
        , 203
        , 2400
        );

INSERT INTO HR_departments VALUES 
        ( 50
        , 'Shipping'
        , 121
        , 1500
        );
                
INSERT INTO HR_departments VALUES 
        ( 60 
        , 'IT'
        , 103
        , 1400
        );
                
INSERT INTO HR_departments VALUES 
        ( 70 
        , 'Public Relations'
        , 204
        , 2700
        );
                
INSERT INTO HR_departments VALUES 
        ( 80 
        , 'Sales'
        , 145
        , 2500
        );
                
INSERT INTO HR_departments VALUES 
        ( 90 
        , 'Executive'
        , 100
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 100 
        , 'Finance'
        , 108
        , 1700
        );
                
INSERT INTO HR_departments VALUES 
        ( 110 
        , 'Accounting'
        , 205
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 120 
        , 'Treasury'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 130 
        , 'Corporate Tax'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 140 
        , 'Control And Credit'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 150 
        , 'Shareholder Services'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 160 
        , 'Benefits'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 170 
        , 'Manufacturing'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 180 
        , 'Construction'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 190 
        , 'Contracting'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 200 
        , 'Operations'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 210 
        , 'IT Support'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 220 
        , 'NOC'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 230 
        , 'IT Helpdesk'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 240 
        , 'Government Sales'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 250 
        , 'Retail Sales'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 260 
        , 'Recruiting'
        , NULL
        , 1700
        );

INSERT INTO HR_departments VALUES 
        ( 270 
        , 'Payroll'
        , NULL
        , 1700
        );


REM ***************************insert data into the HR_jobs table

Prompt ******  Populating HR_jobs table ....

INSERT INTO HR_jobs VALUES 
        ( 'AD_PRES'
        , 'President'
        , 20000
        , 40000
        );
INSERT INTO HR_jobs VALUES 
        ( 'AD_VP'
        , 'Administration Vice President'
        , 15000
        , 30000
        );

INSERT INTO HR_jobs VALUES 
        ( 'AD_ASST'
        , 'Administration Assistant'
        , 3000
        , 6000
        );

INSERT INTO HR_jobs VALUES 
        ( 'FI_MGR'
        , 'Finance Manager'
        , 8200
        , 16000
        );

INSERT INTO HR_jobs VALUES 
        ( 'FI_ACCOUNT'
        , 'Accountant'
        , 4200
        , 9000
        );

INSERT INTO HR_jobs VALUES 
        ( 'AC_MGR'
        , 'Accounting Manager'
        , 8200
        , 16000
        );

INSERT INTO HR_jobs VALUES 
        ( 'AC_ACCOUNT'
        , 'Public Accountant'
        , 4200
        , 9000
        );
INSERT INTO HR_jobs VALUES 
        ( 'SA_MAN'
        , 'Sales Manager'
        , 10000
        , 20000
        );

INSERT INTO HR_jobs VALUES 
        ( 'SA_REP'
        , 'Sales Representative'
        , 6000
        , 12000
        );

INSERT INTO HR_jobs VALUES 
        ( 'PU_MAN'
        , 'Purchasing Manager'
        , 8000
        , 15000
        );

INSERT INTO HR_jobs VALUES 
        ( 'PU_CLERK'
        , 'Purchasing Clerk'
        , 2500
        , 5500
        );

INSERT INTO HR_jobs VALUES 
        ( 'ST_MAN'
        , 'Stock Manager'
        , 5500
        , 8500
        );
INSERT INTO HR_jobs VALUES 
        ( 'ST_CLERK'
        , 'Stock Clerk'
        , 2000
        , 5000
        );

INSERT INTO HR_jobs VALUES 
        ( 'SH_CLERK'
        , 'Shipping Clerk'
        , 2500
        , 5500
        );

INSERT INTO HR_jobs VALUES 
        ( 'IT_PROG'
        , 'Programmer'
        , 4000
        , 10000
        );

INSERT INTO HR_jobs VALUES 
        ( 'MK_MAN'
        , 'Marketing Manager'
        , 9000
        , 15000
        );

INSERT INTO HR_jobs VALUES 
        ( 'MK_REP'
        , 'Marketing Representative'
        , 4000
        , 9000
        );

INSERT INTO HR_jobs VALUES 
        ( 'HR_REP'
        , 'Human Resources Representative'
        , 4000
        , 9000
        );

INSERT INTO HR_jobs VALUES 
        ( 'PR_REP'
        , 'Public Relations Representative'
        , 4500
        , 10500
        );


REM ***************************insert data into the HR_employees table

Prompt ******  Populating HR_employees table ....

INSERT INTO HR_employees VALUES 
        ( 100
        , 'Steven'
        , 'King'
        , 'SKING'
        , '515.123.4567'
        , TO_DATE('17-JUN-1987', 'dd-MON-yyyy')
        , 'AD_PRES'
        , 24000
        , NULL
        , NULL
        , 90
        );

INSERT INTO HR_employees VALUES 
        ( 101
        , 'Neena'
        , 'Kochhar'
        , 'NKOCHHAR'
        , '515.123.4568'
        , TO_DATE('21-SEP-1989', 'dd-MON-yyyy')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO HR_employees VALUES 
        ( 102
        , 'Lex'
        , 'De Haan'
        , 'LDEHAAN'
        , '515.123.4569'
        , TO_DATE('13-JAN-1993', 'dd-MON-yyyy')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO HR_employees VALUES 
        ( 103
        , 'Alexander'
        , 'Hunold'
        , 'AHUNOLD'
        , '590.423.4567'
        , TO_DATE('03-JAN-1990', 'dd-MON-yyyy')
        , 'IT_PROG'
        , 9000
        , NULL
        , 102
        , 60
        );

INSERT INTO HR_employees VALUES 
        ( 104
        , 'Bruce'
        , 'Ernst'
        , 'BERNST'
        , '590.423.4568'
        , TO_DATE('21-MAY-1991', 'dd-MON-yyyy')
        , 'IT_PROG'
        , 6000
        , NULL
        , 103
        , 60
        );

INSERT INTO HR_employees VALUES 
        ( 105
        , 'David'
        , 'Austin'
        , 'DAUSTIN'
        , '590.423.4569'
        , TO_DATE('25-JUN-1997', 'dd-MON-yyyy')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO HR_employees VALUES 
        ( 106
        , 'Valli'
        , 'Pataballa'
        , 'VPATABAL'
        , '590.423.4560'
        , TO_DATE('05-FEB-1998', 'dd-MON-yyyy')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO HR_employees VALUES 
        ( 107
        , 'Diana'
        , 'Lorentz'
        , 'DLORENTZ'
        , '590.423.5567'
        , TO_DATE('07-FEB-1999', 'dd-MON-yyyy')
        , 'IT_PROG'
        , 4200
        , NULL
        , 103
        , 60
        );

INSERT INTO HR_employees VALUES 
        ( 108
        , 'Nancy'
        , 'Greenberg'
        , 'NGREENBE'
        , '515.124.4569'
        , TO_DATE('17-AUG-1994', 'dd-MON-yyyy')
        , 'FI_MGR'
        , 12000
        , NULL
        , 101
        , 100
        );

INSERT INTO HR_employees VALUES 
        ( 109
        , 'Daniel'
        , 'Faviet'
        , 'DFAVIET'
        , '515.124.4169'
        , TO_DATE('16-AUG-1994', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 9000
        , NULL
        , 108
        , 100
        );

INSERT INTO HR_employees VALUES 
        ( 110
        , 'John'
        , 'Chen'
        , 'JCHEN'
        , '515.124.4269'
        , TO_DATE('28-SEP-1997', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 8200
        , NULL
        , 108
        , 100
        );

INSERT INTO HR_employees VALUES 
        ( 111
        , 'Ismael'
        , 'Sciarra'
        , 'ISCIARRA'
        , '515.124.4369'
        , TO_DATE('30-SEP-1997', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 7700
        , NULL
        , 108
        , 100
        );

INSERT INTO HR_employees VALUES 
        ( 112
        , 'Jose Manuel'
        , 'Urman'
        , 'JMURMAN'
        , '515.124.4469'
        , TO_DATE('07-MAR-1998', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 7800
        , NULL
        , 108
        , 100
        );

INSERT INTO HR_employees VALUES 
        ( 113
        , 'Luis'
        , 'Popp'
        , 'LPOPP'
        , '515.124.4567'
        , TO_DATE('07-DEC-1999', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 6900
        , NULL
        , 108
        , 100
        );

INSERT INTO HR_employees VALUES 
        ( 114
        , 'Den'
        , 'Raphaely'
        , 'DRAPHEAL'
        , '515.127.4561'
        , TO_DATE('07-DEC-1994', 'dd-MON-yyyy')
        , 'PU_MAN'
        , 11000
        , NULL
        , 100
        , 30
        );

INSERT INTO HR_employees VALUES 
        ( 115
        , 'Alexander'
        , 'Khoo'
        , 'AKHOO'
        , '515.127.4562'
        , TO_DATE('18-MAY-1995', 'dd-MON-yyyy')
        , 'PU_CLERK'
        , 3100
        , NULL
        , 114
        , 30
        );

INSERT INTO HR_employees VALUES 
        ( 116
        , 'Shelli'
        , 'Baida'
        , 'SBAIDA'
        , '515.127.4563'
        , TO_DATE('24-DEC-1997', 'dd-MON-yyyy')
        , 'PU_CLERK'
        , 2900
        , NULL
        , 114
        , 30
        );

INSERT INTO HR_employees VALUES 
        ( 117
        , 'Sigal'
        , 'Tobias'
        , 'STOBIAS'
        , '515.127.4564'
        , TO_DATE('24-JUL-1997', 'dd-MON-yyyy')
        , 'PU_CLERK'
        , 2800
        , NULL
        , 114
        , 30
        );

INSERT INTO HR_employees VALUES 
        ( 118
        , 'Guy'
        , 'Himuro'
        , 'GHIMURO'
        , '515.127.4565'
        , TO_DATE('15-NOV-1998', 'dd-MON-yyyy')
        , 'PU_CLERK'
        , 2600
        , NULL
        , 114
        , 30
        );

INSERT INTO HR_employees VALUES 
        ( 119
        , 'Karen'
        , 'Colmenares'
        , 'KCOLMENA'
        , '515.127.4566'
        , TO_DATE('10-AUG-1999', 'dd-MON-yyyy')
        , 'PU_CLERK'
        , 2500
        , NULL
        , 114
        , 30
        );

INSERT INTO HR_employees VALUES 
        ( 120
        , 'Matthew'
        , 'Weiss'
        , 'MWEISS'
        , '650.123.1234'
        , TO_DATE('18-JUL-1996', 'dd-MON-yyyy')
        , 'ST_MAN'
        , 8000
        , NULL
        , 100
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 121
        , 'Adam'
        , 'Fripp'
        , 'AFRIPP'
        , '650.123.2234'
        , TO_DATE('10-APR-1997', 'dd-MON-yyyy')
        , 'ST_MAN'
        , 8200
        , NULL
        , 100
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 122
        , 'Payam'
        , 'Kaufling'
        , 'PKAUFLIN'
        , '650.123.3234'
        , TO_DATE('01-MAY-1995', 'dd-MON-yyyy')
        , 'ST_MAN'
        , 7900
        , NULL
        , 100
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 123
        , 'Shanta'
        , 'Vollman'
        , 'SVOLLMAN'
        , '650.123.4234'
        , TO_DATE('10-OCT-1997', 'dd-MON-yyyy')
        , 'ST_MAN'
        , 6500
        , NULL
        , 100
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 124
        , 'Kevin'
        , 'Mourgos'
        , 'KMOURGOS'
        , '650.123.5234'
        , TO_DATE('16-NOV-1999', 'dd-MON-yyyy')
        , 'ST_MAN'
        , 5800
        , NULL
        , 100
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 125
        , 'Julia'
        , 'Nayer'
        , 'JNAYER'
        , '650.124.1214'
        , TO_DATE('16-JUL-1997', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 126
        , 'Irene'
        , 'Mikkilineni'
        , 'IMIKKILI'
        , '650.124.1224'
        , TO_DATE('28-SEP-1998', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 127
        , 'James'
        , 'Landry'
        , 'JLANDRY'
        , '650.124.1334'
        , TO_DATE('14-JAN-1999', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 128
        , 'Steven'
        , 'Markle'
        , 'SMARKLE'
        , '650.124.1434'
        , TO_DATE('08-MAR-2000', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 129
        , 'Laura'
        , 'Bissot'
        , 'LBISSOT'
        , '650.124.5234'
        , TO_DATE('20-AUG-1997', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 130
        , 'Mozhe'
        , 'Atkinson'
        , 'MATKINSO'
        , '650.124.6234'
        , TO_DATE('30-OCT-1997', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2800
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 131
        , 'James'
        , 'Marlow'
        , 'JAMRLOW'
        , '650.124.7234'
        , TO_DATE('16-FEB-1997', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 132
        , 'TJ'
        , 'Olson'
        , 'TJOLSON'
        , '650.124.8234'
        , TO_DATE('10-APR-1999', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2100
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 133
        , 'Jason'
        , 'Mallin'
        , 'JMALLIN'
        , '650.127.1934'
        , TO_DATE('14-JUN-1996', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 134
        , 'Michael'
        , 'Rogers'
        , 'MROGERS'
        , '650.127.1834'
        , TO_DATE('26-AUG-1998', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 135
        , 'Ki'
        , 'Gee'
        , 'KGEE'
        , '650.127.1734'
        , TO_DATE('12-DEC-1999', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 136
        , 'Hazel'
        , 'Philtanker'
        , 'HPHILTAN'
        , '650.127.1634'
        , TO_DATE('06-FEB-2000', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 137
        , 'Renske'
        , 'Ladwig'
        , 'RLADWIG'
        , '650.121.1234'
        , TO_DATE('14-JUL-1995', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 3600
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 138
        , 'Stephen'
        , 'Stiles'
        , 'SSTILES'
        , '650.121.2034'
        , TO_DATE('26-OCT-1997', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 139
        , 'John'
        , 'Seo'
        , 'JSEO'
        , '650.121.2019'
        , TO_DATE('12-FEB-1998', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 140
        , 'Joshua'
        , 'Patel'
        , 'JPATEL'
        , '650.121.1834'
        , TO_DATE('06-APR-1998', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 141
        , 'Trenna'
        , 'Rajs'
        , 'TRAJS'
        , '650.121.8009'
        , TO_DATE('17-OCT-1995', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 3500
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 142
        , 'Curtis'
        , 'Davies'
        , 'CDAVIES'
        , '650.121.2994'
        , TO_DATE('29-JAN-1997', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 143
        , 'Randall'
        , 'Matos'
        , 'RMATOS'
        , '650.121.2874'
        , TO_DATE('15-MAR-1998', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 144
        , 'Peter'
        , 'Vargas'
        , 'PVARGAS'
        , '650.121.2004'
        , TO_DATE('09-JUL-1998', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 145
        , 'John'
        , 'Russell'
        , 'JRUSSEL'
        , '011.44.1344.429268'
        , TO_DATE('01-OCT-1996', 'dd-MON-yyyy')
        , 'SA_MAN'
        , 14000
        , .4
        , 100
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 146
        , 'Karen'
        , 'Partners'
        , 'KPARTNER'
        , '011.44.1344.467268'
        , TO_DATE('05-JAN-1997', 'dd-MON-yyyy')
        , 'SA_MAN'
        , 13500
        , .3
        , 100
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 147
        , 'Alberto'
        , 'Errazuriz'
        , 'AERRAZUR'
        , '011.44.1344.429278'
        , TO_DATE('10-MAR-1997', 'dd-MON-yyyy')
        , 'SA_MAN'
        , 12000
        , .3
        , 100
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 148
        , 'Gerald'
        , 'Cambrault'
        , 'GCAMBRAU'
        , '011.44.1344.619268'
        , TO_DATE('15-OCT-1999', 'dd-MON-yyyy')
        , 'SA_MAN'
        , 11000
        , .3
        , 100
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 149
        , 'Eleni'
        , 'Zlotkey'
        , 'EZLOTKEY'
        , '011.44.1344.429018'
        , TO_DATE('29-JAN-2000', 'dd-MON-yyyy')
        , 'SA_MAN'
        , 10500
        , .2
        , 100
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 150
        , 'Peter'
        , 'Tucker'
        , 'PTUCKER'
        , '011.44.1344.129268'
        , TO_DATE('30-JAN-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 10000
        , .3
        , 145
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 151
        , 'David'
        , 'Bernstein'
        , 'DBERNSTE'
        , '011.44.1344.345268'
        , TO_DATE('24-MAR-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 9500
        , .25
        , 145
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 152
        , 'Peter'
        , 'Hall'
        , 'PHALL'
        , '011.44.1344.478968'
        , TO_DATE('20-AUG-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 9000
        , .25
        , 145
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 153
        , 'Christopher'
        , 'Olsen'
        , 'COLSEN'
        , '011.44.1344.498718'
        , TO_DATE('30-MAR-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 8000
        , .2
        , 145
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 154
        , 'Nanette'
        , 'Cambrault'
        , 'NCAMBRAU'
        , '011.44.1344.987668'
        , TO_DATE('09-DEC-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7500
        , .2
        , 145
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 155
        , 'Oliver'
        , 'Tuvault'
        , 'OTUVAULT'
        , '011.44.1344.486508'
        , TO_DATE('23-NOV-1999', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7000
        , .15
        , 145
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 156
        , 'Janette'
        , 'King'
        , 'JKING'
        , '011.44.1345.429268'
        , TO_DATE('30-JAN-1996', 'dd-MON-yyyy')
        , 'SA_REP'
        , 10000
        , .35
        , 146
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 157
        , 'Patrick'
        , 'Sully'
        , 'PSULLY'
        , '011.44.1345.929268'
        , TO_DATE('04-MAR-1996', 'dd-MON-yyyy')
        , 'SA_REP'
        , 9500
        , .35
        , 146
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 158
        , 'Allan'
        , 'McEwen'
        , 'AMCEWEN'
        , '011.44.1345.829268'
        , TO_DATE('01-AUG-1996', 'dd-MON-yyyy')
        , 'SA_REP'
        , 9000
        , .35
        , 146
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 159
        , 'Lindsey'
        , 'Smith'
        , 'LSMITH'
        , '011.44.1345.729268'
        , TO_DATE('10-MAR-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 8000
        , .3
        , 146
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 160
        , 'Louise'
        , 'Doran'
        , 'LDORAN'
        , '011.44.1345.629268'
        , TO_DATE('15-DEC-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7500
        , .3
        , 146
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 161
        , 'Sarath'
        , 'Sewall'
        , 'SSEWALL'
        , '011.44.1345.529268'
        , TO_DATE('03-NOV-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7000
        , .25
        , 146
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 162
        , 'Clara'
        , 'Vishney'
        , 'CVISHNEY'
        , '011.44.1346.129268'
        , TO_DATE('11-NOV-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 10500
        , .25
        , 147
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 163
        , 'Danielle'
        , 'Greene'
        , 'DGREENE'
        , '011.44.1346.229268'
        , TO_DATE('19-MAR-1999', 'dd-MON-yyyy')
        , 'SA_REP'
        , 9500
        , .15
        , 147
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 164
        , 'Mattea'
        , 'Marvins'
        , 'MMARVINS'
        , '011.44.1346.329268'
        , TO_DATE('24-JAN-2000', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7200
        , .10
        , 147
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 165
        , 'David'
        , 'Lee'
        , 'DLEE'
        , '011.44.1346.529268'
        , TO_DATE('23-FEB-2000', 'dd-MON-yyyy')
        , 'SA_REP'
        , 6800
        , .1
        , 147
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 166
        , 'Sundar'
        , 'Ande'
        , 'SANDE'
        , '011.44.1346.629268'
        , TO_DATE('24-MAR-2000', 'dd-MON-yyyy')
        , 'SA_REP'
        , 6400
        , .10
        , 147
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 167
        , 'Amit'
        , 'Banda'
        , 'ABANDA'
        , '011.44.1346.729268'
        , TO_DATE('21-APR-2000', 'dd-MON-yyyy')
        , 'SA_REP'
        , 6200
        , .10
        , 147
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 168
        , 'Lisa'
        , 'Ozer'
        , 'LOZER'
        , '011.44.1343.929268'
        , TO_DATE('11-MAR-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 11500
        , .25
        , 148
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 169  
        , 'Harrison'
        , 'Bloom'
        , 'HBLOOM'
        , '011.44.1343.829268'
        , TO_DATE('23-MAR-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 10000
        , .20
        , 148
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 170
        , 'Tayler'
        , 'Fox'
        , 'TFOX'
        , '011.44.1343.729268'
        , TO_DATE('24-JAN-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 9600
        , .20
        , 148
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 171
        , 'William'
        , 'Smith'
        , 'WSMITH'
        , '011.44.1343.629268'
        , TO_DATE('23-FEB-1999', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7400
        , .15
        , 148
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 172
        , 'Elizabeth'
        , 'Bates'
        , 'EBATES'
        , '011.44.1343.529268'
        , TO_DATE('24-MAR-1999', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7300
        , .15
        , 148
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 173
        , 'Sundita'
        , 'Kumar'
        , 'SKUMAR'
        , '011.44.1343.329268'
        , TO_DATE('21-APR-2000', 'dd-MON-yyyy')
        , 'SA_REP'
        , 6100
        , .10
        , 148
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 174
        , 'Ellen'
        , 'Abel'
        , 'EABEL'
        , '011.44.1644.429267'
        , TO_DATE('11-MAY-1996', 'dd-MON-yyyy')
        , 'SA_REP'
        , 11000
        , .30
        , 149
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 175
        , 'Alyssa'
        , 'Hutton'
        , 'AHUTTON'
        , '011.44.1644.429266'
        , TO_DATE('19-MAR-1997', 'dd-MON-yyyy')
        , 'SA_REP'
        , 8800
        , .25
        , 149
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 176
        , 'Jonathon'
        , 'Taylor'
        , 'JTAYLOR'
        , '011.44.1644.429265'
        , TO_DATE('24-MAR-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 8600
        , .20
        , 149
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 177
        , 'Jack'
        , 'Livingston'
        , 'JLIVINGS'
        , '011.44.1644.429264'
        , TO_DATE('23-APR-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 8400
        , .20
        , 149
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 178
        , 'Kimberely'
        , 'Grant'
        , 'KGRANT'
        , '011.44.1644.429263'
        , TO_DATE('24-MAY-1999', 'dd-MON-yyyy')
        , 'SA_REP'
        , 7000
        , .15
        , 149
        , NULL
        );

INSERT INTO HR_employees VALUES 
        ( 179
        , 'Charles'
        , 'Johnson'
        , 'CJOHNSON'
        , '011.44.1644.429262'
        , TO_DATE('04-JAN-2000', 'dd-MON-yyyy')
        , 'SA_REP'
        , 6200
        , .10
        , 149
        , 80
        );

INSERT INTO HR_employees VALUES 
        ( 180
        , 'Winston'
        , 'Taylor'
        , 'WTAYLOR'
        , '650.507.9876'
        , TO_DATE('24-JAN-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 181
        , 'Jean'
        , 'Fleaur'
        , 'JFLEAUR'
        , '650.507.9877'
        , TO_DATE('23-FEB-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 182
        , 'Martha'
        , 'Sullivan'
        , 'MSULLIVA'
        , '650.507.9878'
        , TO_DATE('21-JUN-1999', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 183
        , 'Girard'
        , 'Geoni'
        , 'GGEONI'
        , '650.507.9879'
        , TO_DATE('03-FEB-2000', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 120
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 184
        , 'Nandita'
        , 'Sarchand'
        , 'NSARCHAN'
        , '650.509.1876'
        , TO_DATE('27-JAN-1996', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 4200
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 185
        , 'Alexis'
        , 'Bull'
        , 'ABULL'
        , '650.509.2876'
        , TO_DATE('20-FEB-1997', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 4100
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 186
        , 'Julia'
        , 'Dellinger'
        , 'JDELLING'
        , '650.509.3876'
        , TO_DATE('24-JUN-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3400
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 187
        , 'Anthony'
        , 'Cabrio'
        , 'ACABRIO'
        , '650.509.4876'
        , TO_DATE('07-FEB-1999', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 121
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 188
        , 'Kelly'
        , 'Chung'
        , 'KCHUNG'
        , '650.505.1876'
        , TO_DATE('14-JUN-1997', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3800
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 189
        , 'Jennifer'
        , 'Dilly'
        , 'JDILLY'
        , '650.505.2876'
        , TO_DATE('13-AUG-1997', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3600
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 190
        , 'Timothy'
        , 'Gates'
        , 'TGATES'
        , '650.505.3876'
        , TO_DATE('11-JUL-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 191
        , 'Randall'
        , 'Perkins'
        , 'RPERKINS'
        , '650.505.4876'
        , TO_DATE('19-DEC-1999', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 122
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 192
        , 'Sarah'
        , 'Bell'
        , 'SBELL'
        , '650.501.1876'
        , TO_DATE('04-FEB-1996', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 4000
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 193
        , 'Britney'
        , 'Everett'
        , 'BEVERETT'
        , '650.501.2876'
        , TO_DATE('03-MAR-1997', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3900
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 194
        , 'Samuel'
        , 'McCain'
        , 'SMCCAIN'
        , '650.501.3876'
        , TO_DATE('01-JUL-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 195
        , 'Vance'
        , 'Jones'
        , 'VJONES'
        , '650.501.4876'
        , TO_DATE('17-MAR-1999', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 123
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 196
        , 'Alana'
        , 'Walsh'
        , 'AWALSH'
        , '650.507.9811'
        , TO_DATE('24-APR-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 197
        , 'Kevin'
        , 'Feeney'
        , 'KFEENEY'
        , '650.507.9822'
        , TO_DATE('23-MAY-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 198
        , 'Donald'
        , 'OConnell'
        , 'DOCONNEL'
        , '650.507.9833'
        , TO_DATE('21-JUN-1999', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 199
        , 'Douglas'
        , 'Grant'
        , 'DGRANT'
        , '650.507.9844'
        , TO_DATE('13-JAN-2000', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO HR_employees VALUES 
        ( 200
        , 'Jennifer'
        , 'Whalen'
        , 'JWHALEN'
        , '515.123.4444'
        , TO_DATE('17-SEP-1987', 'dd-MON-yyyy')
        , 'AD_ASST'
        , 4400
        , NULL
        , 101
        , 10
        );

INSERT INTO HR_employees VALUES 
        ( 201
        , 'Michael'
        , 'Hartstein'
        , 'MHARTSTE'
        , '515.123.5555'
        , TO_DATE('17-FEB-1996', 'dd-MON-yyyy')
        , 'MK_MAN'
        , 13000
        , NULL
        , 100
        , 20
        );

INSERT INTO HR_employees VALUES 
        ( 202
        , 'Pat'
        , 'Fay'
        , 'PFAY'
        , '603.123.6666'
        , TO_DATE('17-AUG-1997', 'dd-MON-yyyy')
        , 'MK_REP'
        , 6000
        , NULL
        , 201
        , 20
        );

INSERT INTO HR_employees VALUES 
        ( 203
        , 'Susan'
        , 'Mavris'
        , 'SMAVRIS'
        , '515.123.7777'
        , TO_DATE('07-JUN-1994', 'dd-MON-yyyy')
        , 'HR_REP'
        , 6500
        , NULL
        , 101
        , 40
        );

INSERT INTO HR_employees VALUES 
        ( 204
        , 'Hermann'
        , 'Baer'
        , 'HBAER'
        , '515.123.8888'
        , TO_DATE('07-JUN-1994', 'dd-MON-yyyy')
        , 'PR_REP'
        , 10000
        , NULL
        , 101
        , 70
        );

INSERT INTO HR_employees VALUES 
        ( 205
        , 'Shelley'
        , 'Higgins'
        , 'SHIGGINS'
        , '515.123.8080'
        , TO_DATE('07-JUN-1994', 'dd-MON-yyyy')
        , 'AC_MGR'
        , 12000
        , NULL
        , 101
        , 110
        );

INSERT INTO HR_employees VALUES 
        ( 206
        , 'William'
        , 'Gietz'
        , 'WGIETZ'
        , '515.123.8181'
        , TO_DATE('07-JUN-1994', 'dd-MON-yyyy')
        , 'AC_ACCOUNT'
        , 8300
        , NULL
        , 205
        , 110
        );

REM ********* insert data into the HR_job_history table

Prompt ******  Populating HR_job_history table ....


INSERT INTO HR_job_history
VALUES (102
       , TO_DATE('13-JAN-1993', 'dd-MON-yyyy')
       , TO_DATE('24-JUL-1998', 'dd-MON-yyyy')
       , 'IT_PROG'
       , 60);

INSERT INTO HR_job_history
VALUES (101
       , TO_DATE('21-SEP-1989', 'dd-MON-yyyy')
       , TO_DATE('27-OCT-1993', 'dd-MON-yyyy')
       , 'AC_ACCOUNT'
       , 110);

INSERT INTO HR_job_history
VALUES (101
       , TO_DATE('28-OCT-1993', 'dd-MON-yyyy')
       , TO_DATE('15-MAR-1997', 'dd-MON-yyyy')
       , 'AC_MGR'
       , 110);

INSERT INTO HR_job_history
VALUES (201
       , TO_DATE('17-FEB-1996', 'dd-MON-yyyy')
       , TO_DATE('19-DEC-1999', 'dd-MON-yyyy')
       , 'MK_REP'
       , 20);

INSERT INTO HR_job_history
VALUES  (114
        , TO_DATE('24-MAR-1998', 'dd-MON-yyyy')
        , TO_DATE('31-DEC-1999', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO HR_job_history
VALUES  (122
        , TO_DATE('01-JAN-1999', 'dd-MON-yyyy')
        , TO_DATE('31-DEC-1999', 'dd-MON-yyyy')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO HR_job_history
VALUES  (200
        , TO_DATE('17-SEP-1987', 'dd-MON-yyyy')
        , TO_DATE('17-JUN-1993', 'dd-MON-yyyy')
        , 'AD_ASST'
        , 90
        );

INSERT INTO HR_job_history
VALUES  (176
        , TO_DATE('24-MAR-1998', 'dd-MON-yyyy')
        , TO_DATE('31-DEC-1998', 'dd-MON-yyyy')
        , 'SA_REP'
        , 80
        );

INSERT INTO HR_job_history
VALUES  (176
        , TO_DATE('01-JAN-1999', 'dd-MON-yyyy')
        , TO_DATE('31-DEC-1999', 'dd-MON-yyyy')
        , 'SA_MAN'
        , 80
        );

INSERT INTO HR_job_history
VALUES  (200
        , TO_DATE('01-JUL-1994', 'dd-MON-yyyy')
        , TO_DATE('31-DEC-1998', 'dd-MON-yyyy')
        , 'AC_ACCOUNT'
        , 90
        );

REM enable integrity constraint to HR_departments

ALTER TABLE HR_departments 
  ENABLE CONSTRAINT dept_mgr_fk;


insert into HR_job_grades (GRADE_LEVEL, LOWEST_SAL,HIGHEST_SAL)
values ('A',1000, 2999);
insert into HR_job_grades (GRADE_LEVEL, LOWEST_SAL,HIGHEST_SAL)
values ('B',3000, 5999);
insert into HR_job_grades (GRADE_LEVEL, LOWEST_SAL,HIGHEST_SAL)
values ('C',6000, 9999);
insert into HR_job_grades (GRADE_LEVEL, LOWEST_SAL,HIGHEST_SAL)
values ('D',10000, 14999);
insert into HR_job_grades (GRADE_LEVEL, LOWEST_SAL,HIGHEST_SAL)
values ('E',15000, 24999);
insert into HR_job_grades (GRADE_LEVEL, LOWEST_SAL,HIGHEST_SAL)
values ('F',25000, 40000);
commit;

COMMIT;

 