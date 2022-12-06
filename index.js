const path = require('path')
const express = require('express')
const hbs = require('hbs')
const swig = require('swig')
const bodyParser = require('body-parser');
const getConnection = require('./lib/connection');
const getRsp = require('./lib/caller')


const app = express()

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Define paths for Express config
//const publicDirectoryPath = path.join(__dirname, '../public')
const viewsPath = path.join(__dirname, 'templates/views')
//const partialsPath = path.join(__dirname, '../templates/partials')

// Setup handlebars engine and views location
app.engine('html', swig.renderFile);
app.set('view engine', 'html');
app.set('views', viewsPath)
app.set('view cache', false);
swig.setDefaults({cache:false})
//hbs.registerPartials(partialsPath)
// Setup static directory to serve
//app.use(express.static(publicDirectoryPath))

//app.get("")

app.get('/about', (req, res) => {
    res.send({ "App" : "CCPS610 Assignment 2"})
})

app.get('/getManagers', (req, res) => {
    getConnection().query(`select distinct e.employee_id, e.first_name, e.last_name from hr_employees e
                            INNER JOIN hr_employees m ON e.employee_id = m.manager_id`,
    function (error, results, fields) {
        if (error) throw error;
        res.setHeader('Content-Type', 'application/json');
        res.send(results)
      });
})

app.get('/getJobs', (req, res) => {
    getConnection().query(`select job_id, job_title from hr_jobs`,
    function (error, results, fields) {
        if (error) throw error;
        res.setHeader('Content-Type', 'application/json');
        res.send(results)
      });
})

app.get('/getDepartments', (req, res) => {
    getConnection().query(`select department_id, department_name from hr_departments`,
    function (error, results, fields) {
        if (error) throw error;
        res.setHeader('Content-Type', 'application/json');
        res.send(results)
      });
})

app.post('/insertEmployee', (req, res) => {
    var data = req.body;
    getConnection().query(`CALL Employee_hire_sp('${data.first_name}', '${data.last_name}', 
    '${data.email}', ${data.salary}, '${data.hire_date}', '${data.phone_NUMERIC}', '${data.job_id}',
     ${data.manager_id}, ${data.department_id})`,
    function (error, results, fields) {
        if (error)  res.send({"err" : error.sqlMessage});
        res.render('index')
      });
})

app.get('/listAllEmployees', (req, res) => {
    getConnection().query(`select * from hr_employees`,
    function (error, results, fields) {
        if (error) throw error;
        //res.setHeader('Content-Type', 'application/json');
        res.send(results)
      });
})


app.post('/updateEmployee', async (req, res) => {
    var data = req.body;
    var connection = getConnection();
    //res.setHeader('Content-Type', 'application/json');
    connection.beginTransaction(function(err) {
        //if (err) { throw err; }
        if (data.salary){
            connection.query(`UPDATE hr_employees SET salary = ${data.salary} WHERE employee_id = ${data.employee_id};`,
            function (error, results, fields) {    
                if (error) res.send({"err" : error.sqlMessage});
            });
        }
        if (data.phone_NUMERIC){
            connection.query(`UPDATE hr_employees SET phone_NUMERIC = '${data.phone_NUMERIC}' WHERE employee_id = ${data.employee_id};`,
            function (error, results, fields) {
                if (error) res.send({"err" : error.sqlMessage});
            });
        }
        if (data.email){
            connection.query(`UPDATE hr_employees SET email = '${data.email}' WHERE employee_id = ${data.employee_id};`,
            function (error, results, fields) {
                if (error) res.send({"err" : error.sqlMessage});
            });
        }
        connection.commit(function(err) {
            if (err) {
            return connection.rollback(function() {
               // throw err;
            });
            }
            console.log('success!');
        });
    })
    var employeeData = await getRsp('http://localhost:4000/listAllEmployees', 'GET');
    employeeData = JSON.parse(employeeData);
    employeeData.forEach(element => {
        element.hire_date = element.hire_date.substring(0, 10)
    });
    res.render('update_employee_records', { layout: false, employees : employeeData})
})

app.get('/getJobTitle', async (req, res) => {
    var data = req.query;
    getConnection().query(`select job_title from hr_jobs where job_id = '${data.job_id}'`,
    async function (error, results, fields) {
        if (error) throw error;
        var jobData = await getRsp('http://localhost:4000/getJobs', 'GET');
        jobData = JSON.parse(jobData);
        res.render('identify_job_description', {job_desc : results[0].job_title, jobs: jobData})
      });
})

app.get('/getAllJobs', (req, res) => {
    var data = req.query;
    getConnection().query(`select * from hr_jobs`,
    function (error, results, fields) {
        if (error) throw error;
        res.send(results)
      });
})

app.post('/updateJob', async (req, res) => {
    var data = req.body;
    var connection = getConnection();
    connection.beginTransaction( async function(err) {
        if (err) { throw err; }
        if (data.job_title){
            connection.query(`UPDATE hr_jobs SET job_title = '${data.job_title}' WHERE job_id = '${data.job_id}'`,
            function (error, results, fields) {
                if (error) throw error;
            });
        }
        if (data.min_salary){
            connection.query(`UPDATE hr_jobs SET min_salary = ${data.min_salary} WHERE job_id = '${data.job_id}'`,
            function (error, results, fields) {
                if (error) throw error;
            });
        }
        if (data.max_salary){
            connection.query(`UPDATE hr_jobs SET max_salary = ${data.max_salary} WHERE job_id = '${data.job_id}'`,
            function (error, results, fields) {
                if (error) throw error;
            });
        }
        connection.commit(function(err) {
            if (err) {
            return connection.rollback(function() {
                throw err;
            });
            }
            console.log('success!');
        });
    })
    var jobData = await getRsp('http://localhost:4000/getAllJobs', 'GET');
    jobData = JSON.parse(jobData);
    res.render('changejob', { layout: false, jobs : jobData})
})

app.post('/addJob', (req, res) => {
    var data = req.body;
    getConnection().query(`CALL new_job('${data.job_id}', '${data.job_title}', 
    ${data.min_salary})`,
    function (error, results, fields) {
        if (error) throw error;
        res.render('index')
      });
})

app.get('/', (req, res) => {
    res.render('index', {layout: false})
})

app.get('/employee_hiring_form', async (req, res) => {
    var jobData = await getRsp('http://localhost:4000/getJobs', 'GET');
    var managerData = await getRsp('http://localhost:4000/getManagers', 'GET');
    var departmentData = await getRsp('http://localhost:4000/getDepartments', 'GET');
    res.render('employee_hiring_form', { layout: false, jobs : JSON.parse(jobData), 
                                        managers : JSON.parse(managerData),
                                        departments: JSON.parse(departmentData)})
})

app.get('/update_employee_records', async (req, res) => {
    var employeeData = await getRsp('http://localhost:4000/listAllEmployees', 'GET');

    employeeData = JSON.parse(employeeData);
    employeeData.forEach(element => {
        element.hire_date = element.hire_date.substring(0, 10)
    });
    res.render('update_employee_records', { layout: false, employees : employeeData})
})

app.get('/identify_job_description', async (req, res) => {
    var jobData = await getRsp('http://localhost:4000/getJobs', 'GET');
    jobData = JSON.parse(jobData);
    res.render('identify_job_description', { layout: false, jobs : jobData})
})

app.get('/changejob', async (req, res) => {
    var jobData = await getRsp('http://localhost:4000/getAllJobs', 'GET');
    jobData = JSON.parse(jobData);
    res.render('changejob', { layout: false, jobs : jobData})
})

app.get('/createjob', async (req, res) => {
    res.render('createjob')
})


app.listen(4000, () => {
    console.log('Server is up on port 4000.')
})