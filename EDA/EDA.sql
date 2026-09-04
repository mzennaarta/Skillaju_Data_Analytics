								--DATA EXPLORATION
----------------------------------
--EDA 1 : student
----------------------------------

--01. Total students
SELECT
	COUNT(*) students
FROM analytics.students

--02. Total students by city
SELECT
	city,
	COUNT(*) AS total_student
FROM analytics.students
	GROUP BY city
	ORDER BY total_student DESC;

--03. Total students by subc
SELECT
	plan_type,
	COUNT(*) AS  total_plan_students
FROM analytics.students
	GROUP BY plan_type
	ORDER BY total_plan_students DESC;

--04. Total students by acquisition_source
SELECT
	acquisition_source,
	COUNT(*) AS total_students
FROM analytics.students
	GROUP BY acquisition_source
	ORDER BY total_students DESC;

--05 Total age by students
SELECT
	age,
	COUNT(*) AS total_students
FROM analytics.students
	GROUP BY age
	ORDER BY total_students DESC;

--06 Cek duplicate berdasarkan student_id
SELECT
	student_id,
	COUNT(*) AS jumlah
FROM analytics.students
	GROUP BY student_id
	HAVING COUNT(*) > 1;

--07. Cek missing value
SELECT
    COUNT(*) AS total_data,
    COUNT(student_id) AS student_id_terisi,
    COUNT(name) AS name_terisi,
	COUNT(email) AS email_terisi,
	COUNT(age) AS age_terisi,
    COUNT(city) AS city_terisi,
    COUNT(registration_date) AS registration_terisi,
    COUNT(acquisition_source) AS acquisition_terisi,
	COUNT(plan_type) AS plane_terisi
FROM analytics.students;

--08 Cek rentang / distribusi tanggal registrasi
SELECT
	MIN(registration_date) AS tanggal_terlama,
	MAX(registration_date) AS tanggal_terbaru
FROM analytics.students;

SELECT * FROM analytics.students

----------------------------------
--EDA 2 : courses
----------------------------------

--01. Total courses
SELECT
	COUNT(*)
FROM analytics.courses;

--02. Cek duplikat id_course
SELECT
	course_id,
	COUNT(*) AS jumlah
FROM analytics.courses
	GROUP BY course_id
	HAVING COUNT(*) >1;

--03 Cek missing value
SELECT
	COUNT(*) AS total_data,
	COUNT(course_id) AS course_id_terisi,
	COUNT(title) AS title_terisi,
	COUNT(category) AS category_terisi,
	COUNT(instructor_id) AS intructor_terisi,
	COUNT(price_idr) AS price_idr_terisi,
	COUNT(duration_hours) AS duration_hours,
	COUNT(level) AS level_terisi,
	COUNT(avg_rating) AS avg_rating_terisi,
	COUNT(total_enrolled) AS total_enrolled_terisi,
	COUNT(created_date) AS created_date_terisi,
	COUNT(status) AS status_terisi
FROM analytics.courses;

--04 Cek distribusi by kategori
SELECT 
	category,
	COUNT(*) AS total
FROM analytics.courses
	GROUP BY category
	ORDER BY total DESC;

--05 Cek distribusi by level
SELECT
	level,
	COUNT(*) AS jumlah
FROM analytics.courses
	GROUP BY level
	ORDER BY jumlah DESC;

--06 Cek harga course
SELECT
	price_idr,
	COUNT(*) AS jumlah
FROM analytics.courses
	GROUP BY price_idr
	ORDER BY jumlah DESC;
	
--07 Cek rating course
SELECT
	avg_rating,
	COUNT(*) AS jumlah
FROM analytics.courses
	GROUP BY avg_rating
	ORDER BY jumlah DESC;

--08 Cek instructor yang terkait dengan course
SELECT
	category,
	instructor_id
FROM analytics.courses
	GROUP BY 
		category,
		instructor_id
	ORDER BY instructor_id ASC;

--09 Cek tanggal
SELECT 
	MAX(created_date) AS tanggal_terlama,
	MIN(created_date) AS tanggal_terbaru
FROM analytics.courses;

SELECT * FROM analytics.courses

----------------------------------
--EDA 3 : instructors
----------------------------------

--01 Cek jumlah seluruh instructor
SELECT
	COUNT(*) AS jumlah
FROM analytics.instructors;

--02 Cek duplikat instructor_id
SELECT
	instructor_id,
	COUNT(*) AS jumlah
FROM analytics.instructors
	GROUP BY instructor_id
	HAVING COUNT(*) > 1;

--03 Cek missing value
SELECT
	COUNT(*) AS total_data,
	COUNT(instructor_id) AS total_instructor_id,
	COUNT(name) AS total_name,
	COUNT(expertise) AS total_expertise,
	COUNT(city) AS total_city,
	COUNT(courses_count) AS total_courses_count,
	COUNT(avg_rating) AS total_avg_rating,
	COUNT(joined_date) AS total_joined_date
FROM analytics.instructors

--04 Cek distribusi by expertise
SELECT
	expertise,
	COUNT(*) AS jumlah
FROM analytics.instructors
	GROUP BY expertise
	ORDER BY jumlah DESC;

--05 Cek distribusi by city
SELECT
	city,
	COUNT(*) AS jumlah
FROM analytics.instructors
	GROUP BY city
	ORDER BY jumlah DESC;

--06 Cek distribusi by courses_count
SELECT
	courses_count,
	COUNT(*) AS jumlah
FROM analytics.instructors
	GROUP BY courses_count
	ORDER BY jumlah DESC;

--07 Cek distribusi by avg_rating
SELECT
	avg_rating,
	COUNT(*) AS jumlah
FROM analytics.instructors
	GROUP BY avg_rating
	ORDER BY jumlah DESC;

--08 Cek distribusi by
SELECT
	MAX(joined_date) AS tanggal_terlama,
	MIN(joined_date) AS tanggal_terbaru
FROM analytics.instructors;

SELECT * FROM analytics.instructors

----------------------------------
--EDA 4 : enrollments
----------------------------------

--01 total enrollments
SELECT
	COUNT(*) AS jumlah
FROM analytics.enrollments;

--02 cek duplikat enrollments_id
SELECT
	enrollment_id,
	COUNT(*) AS jumlah
FROM analytics.enrollments
	GROUP BY enrollment_id
	HAVING COUNT(*) >1;

--03 Distribusi enrollment by student_id
SELECT
	student_id,
	COUNT(*)AS jumlah
FROM analytics.enrollments
	GROUP BY student_id
	ORDER BY jumlah ASC;

--04 Distribusi enrollment by courses
SELECT
	c.title,
	e.course_id,
	COUNT(*) AS jumlah
FROM analytics.enrollments e
JOIN analytics.courses c
ON c.course_id = e.course_id
	GROUP BY 
		c.title,
		e.course_id
	ORDER BY jumlah DESC;

--05 Distribusi berdasarkan completion_date
SELECT
	CASE
		WHEN completion_date IS NULL THEN 'NULL'
		ELSE 'NOT NULL'
	END AS status_completion_date,
	COUNT(*) AS jumlah
FROM analytics.enrollments
	GROUP BY status_completion_date;

--06 Distribusi completion_pct
SELECT
	CASE
		WHEN completion_pct = 100 THEN 'completed'
		ELSE 'not complete'
	END AS status,
	CASE
		WHEN completion_pct = 100 THEN TRUE
		ELSE FALSE
	END AS certificate_issued_result,
	COUNT(*) AS jumlah
FROM analytics.enrollments
	GROUP BY 
	status,
	certificate_issued_result;

--07 Validitas completion_date
SELECT *
FROM analytics.enrollments
WHERE completion_date < enrolled_date;

--08 Konsistensi last_accessed
SELECT *
FROM analytics.enrollments
WHERE last_accessed < enrolled_date;

SELECT * FROM analytics.enrollments

----------------------------------
--EDA 5 : quiz_results
----------------------------------

--01 Jumlah seluruh quiz result
SELECT
	COUNT(*) AS jumlah
FROM analytics.quiz_result;

--02 Cek duplikat quiz_id
SELECT
	quiz_id,
	COUNT(*) AS jumlah_duplikat
FROM analytics.quiz_result
GROUP BY quiz_id
HAVING COUNT(*) <1;

--03 Cek missing value
SELECT
	COUNT(*) AS total_data,
	COUNT( quiz_id) AS total_quiz_id,
	COUNT(enrollment_id) AS total_enrollment_id,
	COUNT(student_id) AS total_student_id,
	COUNT(course_id) AS total_course_id,
	COUNT(quiz_number) AS total_quiz_number,
	COUNT(attempt_number) AS total_attempt_number,
	COUNT(score) AS total_score,
	COUNT(passed) AS total_passed,
	COUNT(attempt_date) AS total_attempt_date
FROM analytics.quiz_result;

--04 Distribusi berdasarkan student_id
SELECT
	attempt_number,
	COUNT(*) AS jumlah
FROM analytics.quiz_result
	GROUP BY attempt_number
	ORDER BY jumlah DESC;

--05 Distribusi by score
SELECT 
	CASE
		WHEN score <= 70 THEN TRUE
		ELSE FALSE
	END AS status,
	COUNT(*) jumlah
FROM analytics.quiz_result
GROUP BY status
ORDER BY jumlah DESC;

SELECT * FROM analytics.quiz_result
