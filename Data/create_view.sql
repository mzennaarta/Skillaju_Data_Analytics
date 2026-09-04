-- =========================================================
-- 08_CREATE_VIEWS.SQL
-- SKILLAJA E-LEARNING ANALYTICS
-- =========================================================


-- =========================================================
-- 1. STUDENT OVERVIEW
-- Demographic + basic enrollment information per student
-- =========================================================

CREATE OR REPLACE VIEW analytics.vw_student_overview AS
SELECT
    s.student_id,
    s.name,
    s.email,
    s.age,
    s.city,
    s.registration_date,
    s.acquisition_source,
    s.plan_type,
    COUNT(e.enrollment_id) AS total_enrollments
FROM analytics.students s
LEFT JOIN analytics.enrollments e
    ON s.student_id = e.student_id
GROUP BY
    s.student_id,
    s.name,
    s.email,
    s.age,
    s.city,
    s.registration_date,
    s.acquisition_source,
    s.plan_type;


-- =========================================================
-- 2. STUDENT ENGAGEMENT
-- Enrollment + completion + engagement segmentation
-- =========================================================

CREATE OR REPLACE VIEW analytics.vw_student_engagement AS
SELECT
    s.student_id,
    s.name,
    COUNT(e.enrollment_id) AS total_enrollments,
    ROUND(
        COALESCE(AVG(e.completion_pct), 0),
        2
    ) AS avg_completion_pct,

    CASE
        WHEN COUNT(e.enrollment_id) = 0
            THEN 'Inactive'

        WHEN COUNT(e.enrollment_id) >= 8
             AND AVG(e.completion_pct) >= 80
            THEN 'Highly Engaged'

        WHEN COUNT(e.enrollment_id) >= 8
             AND AVG(e.completion_pct) < 80
            THEN 'At Risk'

        WHEN COUNT(e.enrollment_id) < 8
             AND AVG(e.completion_pct) >= 80
            THEN 'Focused Learner'

        ELSE 'Low Engagement'
    END AS engagement_segment

FROM analytics.students s
LEFT JOIN analytics.enrollments e
    ON s.student_id = e.student_id

GROUP BY
    s.student_id,
    s.name;


-- =========================================================
-- 3. ENROLLMENT TREND
-- Monthly enrollment + previous month + change
-- =========================================================

CREATE OR REPLACE VIEW analytics.vw_enrollment_trend AS
WITH monthly_enrollment AS (
    SELECT
        DATE_TRUNC('month', enrolled_date) AS month,
        COUNT(*) AS total_enrollment
    FROM analytics.enrollments
    GROUP BY
        DATE_TRUNC('month', enrolled_date)
)

SELECT
    month,
    total_enrollment,

    LAG(total_enrollment) OVER (
        ORDER BY month
    ) AS previous_month_enrollment,

    total_enrollment
    - LAG(total_enrollment) OVER (
        ORDER BY month
    ) AS enrollment_change,

    ROUND(
        (
            total_enrollment
            - LAG(total_enrollment) OVER (
                ORDER BY month
            )
        ) * 100.0
        / NULLIF(
            LAG(total_enrollment) OVER (
                ORDER BY month
            ),
            0
        ),
        2
    ) AS enrollment_growth_pct

FROM monthly_enrollment
ORDER BY month;


-- =========================================================
-- 4. COURSE PERFORMANCE
-- Enrollment + completion + rating + quiz score per course
-- =========================================================

CREATE OR REPLACE VIEW analytics.vw_course_performance AS
WITH course_enrollment AS (
    SELECT
        course_id,
        COUNT(enrollment_id) AS total_enrollment,

        ROUND(
            COUNT(
                CASE
                    WHEN completion_pct = 100 THEN 1
                END
            ) * 100.0
            / NULLIF(COUNT(enrollment_id), 0),
            2
        ) AS completion_rate

    FROM analytics.enrollments
    GROUP BY course_id
),

course_quiz AS (
    SELECT
        course_id,
        ROUND(AVG(score), 2) AS average_quiz_score
    FROM analytics.quiz_result
    GROUP BY course_id
)

SELECT
    c.course_id,
    c.title,
    c.category,
    c.level,
    c.avg_rating,

    COALESCE(
        ce.total_enrollment,
        0
    ) AS total_enrollment,

    COALESCE(
        ce.completion_rate,
        0
    ) AS completion_rate,

    cq.average_quiz_score

FROM analytics.courses c

LEFT JOIN course_enrollment ce
    ON c.course_id = ce.course_id

LEFT JOIN course_quiz cq
    ON c.course_id = cq.course_id;


-- =========================================================
-- 5. INSTRUCTOR PERFORMANCE
-- Course + enrollment + rating + completion
-- =========================================================

CREATE OR REPLACE VIEW analytics.vw_instructor_performance AS
WITH instructor_data AS (
    SELECT
        i.instructor_id,
        i.name,

        COUNT(DISTINCT c.course_id) AS total_courses,

        COUNT(e.enrollment_id) AS total_enrollments,

        ROUND(
            AVG(c.avg_rating),
            2
        ) AS average_rating,

        ROUND(
            COUNT(
                CASE
                    WHEN e.completion_pct = 100 THEN 1
                END
            ) * 100.0
            / NULLIF(
                COUNT(e.enrollment_id),
                0
            ),
            2
        ) AS completion_rate

    FROM analytics.instructors i

    LEFT JOIN analytics.courses c
        ON i.instructor_id = c.instructor_id

    LEFT JOIN analytics.enrollments e
        ON c.course_id = e.course_id

    GROUP BY
        i.instructor_id,
        i.name
)

SELECT
    *,
    RANK() OVER (
        ORDER BY completion_rate DESC
    ) AS performance_rank

FROM instructor_data

WHERE total_enrollments > 0;


-- =========================================================
-- 6. QUIZ PERFORMANCE
-- Score + attempts + pass rate per course
-- Passing score = 70
-- =========================================================

CREATE OR REPLACE VIEW analytics.vw_quiz_performance AS
SELECT
    q.course_id,
    c.title,

    COUNT(*) AS total_quiz_results,

    ROUND(
        AVG(q.score),
        2
    ) AS average_score,

    MAX(q.score) AS highest_score,

    MIN(q.score) AS lowest_score,

    ROUND(
        AVG(q.attempt),
        2
    ) AS average_attempt,

    COUNT(
        CASE
            WHEN q.score >= 70 THEN 1
        END
    ) AS passed_quiz,

    ROUND(
        COUNT(
            CASE
                WHEN q.score >= 70 THEN 1
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS pass_rate

FROM analytics.quiz_result q

JOIN analytics.courses c
    ON q.course_id = c.course_id

GROUP BY
    q.course_id,
    c.title;


SELECT *
FROM analytics.vw_student_overview;

SELECT *
FROM analytics.vw_student_engagement;

SELECT *
FROM analytics.vw_enrollment_trend;

SELECT *
FROM analytics.vw_course_performance;

SELECT *
FROM analytics.vw_instructor_performance;

SELECT *
FROM analytics.vw_quiz_performance;