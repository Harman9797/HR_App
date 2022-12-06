DROP PROCEDURE IF EXISTS Employee_hire_sp;
DELIMITER &&
CREATE PROCEDURE Employee_hire_sp 
(IN p_first_name VARCHAR(20) , IN p_last_name VARCHAR(25),
IN p_email VARCHAR(25), IN p_salary NUMERIC(8,2), IN p_hire_date DATE, 
IN p_phone VARCHAR(20), IN p_job_id VARCHAR(10), IN p_manager_id NUMERIC(6), IN p_department_id NUMERIC(4)) 
BEGIN
	DECLARE v_id INT;
	SELECT max(employee_id) + 1 into v_id FROM hr_employees;
	INSERT INTO hr_employees (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMERIC, HIRE_DATE, JOB_ID, SALARY, MANAGER_ID, DEPARTMENT_ID )
	VALUES (v_id, p_first_name, p_last_name, p_email, p_phone,  p_hire_date, p_job_id, p_salary, p_manager_id, p_department_id);
	SELECT concat('Added firstname: ', p_first_name, ' lastname: ', p_last_name);
    commit;
END&&

DROP PROCEDURE IF EXISTS new_job;
DELIMITER &&
CREATE PROCEDURE new_job( IN p_jobid VARCHAR(10)
    , IN p_title VARCHAR(35), IN v_minsal NUMERIC(6) )
BEGIN
    SET @v_maxsal := v_minsal * 2;
    INSERT INTO hr_jobs(job_id, job_title, min_salary, max_salary)
    VALUES(p_jobid, p_title, v_minsal, @v_maxsal);
    SELECT ('A new job has been created');
	commit;
END&&

DROP PROCEDURE IF EXISTS check_salary;
DELIMITER &&
CREATE PROCEDURE check_salary( IN p_the_job VARCHAR(10)
    , IN p_the_salary NUMERIC(6) )
BEGIN
	DECLARE v_minsal NUMERIC(6);
    DECLARE v_maxsal NUMERIC(6);
    SELECT min_salary, max_salary into v_minsal, v_maxsal from hr_jobs where job_id = UPPER(p_the_job);
    IF p_the_salary NOT BETWEEN v_minsal AND v_maxsal THEN 
		set @message_text = concat('Invalid salary $', p_the_salary, '. Salaries for job ', p_the_job, ' must be between $',
        v_minsal, ' and $', v_maxsal);
		signal sqlstate '21000' set message_text = @message_text; 
	END IF;
END&&

DROP TRIGGER IF EXISTS check_salary_trg_insert;
DELIMITER &&
CREATE TRIGGER check_salary_trg_insert BEFORE INSERT ON hr_employees
FOR EACH ROW
BEGIN
	CALL check_salary(new.job_id, new.salary);
END&&


DROP TRIGGER IF EXISTS check_salary_trg_update;
DELIMITER &&
CREATE TRIGGER check_salary_trg_update BEFORE UPDATE ON hr_employees
FOR EACH ROW
BEGIN
	IF !(NEW.job_id <=> OLD.job_id AND NEW.salary <=> OLD.salary) THEN
		CALL check_salary(new.job_id, new.salary);
	END IF;
END&&