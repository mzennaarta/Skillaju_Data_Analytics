-- =========================================
-- 07. ADVANCED SQL ANALYSIS
-- =========================================

-- 01. Ranking student berdasarkan total enrollment
-- Tujuan:
-- Mengetahui urutan student berdasarkan jumlah course yang diikuti.
WITH student_enrollment AS (
    SELECT
        s.student_id,
        s.name,
        COUNT(e.enrollment_id) AS total_enrollments
    FROM analytics.students s
    LEFT JOIN analytics.enrollments e
        ON s.student_id = e.student_id
    GROUP BY
        s.student_id,
        s.name
)

SELECT
    student_id,
    name,
    total_enrollments,
    RANK() OVER (
        ORDER BY total_enrollments DESC
    ) AS enrollment_rank
FROM student_enrollment
ORDER BY enrollment_rank;

-- 02. Top 3 course pada setiap category
-- Tujuan:
-- Mengetahui 3 course dengan enrollment tertinggi
-- di masing-masing category.
WITH course_enrollment AS (
    SELECT
        c.course_id,
        c.title,
        c.category,
        COUNT(e.enrollment_id) AS total_enrollment
    FROM analytics.courses c
    LEFT JOIN analytics.enrollments e
        ON c.course_id = e.course_id
    GROUP BY
        c.course_id,
        c.title,
        c.category
),

ranked_courses AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_enrollment DESC
        ) AS rank_in_category
    FROM course_enrollment
)

SELECT
    course_id,
    title,
    category,
    total_enrollment,
    rank_in_category
FROM ranked_courses
WHERE rank_in_category <= 3
ORDER BY
    category,
    rank_in_category;

-- 03. Student dengan enrollment di atas rata-rata
-- Tujuan:
-- Mengidentifikasi student yang memiliki aktivitas
-- enrollment lebih tinggi dibanding rata-rata student.
WITH student_enrollment AS (
    SELECT
        s.student_id,
        s.name,
        COUNT(e.enrollment_id) AS total_enrollments
    FROM analytics.students s
    LEFT JOIN analytics.enrollments e
        ON s.student_id = e.student_id
    GROUP BY
        s.student_id,
        s.name
),

average_enrollment AS (
    SELECT
        AVG(total_enrollments) AS avg_enrollment
    FROM student_enrollment
)

SELECT
    se.student_id,
    se.name,
    se.total_enrollments,
    ROUND(ae.avg_enrollment, 2) AS avg_all_students
FROM student_enrollment se
CROSS JOIN average_enrollment ae
WHERE se.total_enrollments > ae.avg_enrollment
ORDER BY se.total_enrollments DESC;


-- 04. Ranking instructor berdasarkan performance
-- Tujuan:
-- Mengurutkan instructor berdasarkan completion rate
-- dan metric performance lainnya.
WITH instructor_performance AS (
    SELECT
        i.instructor_id,
        i.name,
        COUNT(DISTINCT c.course_id) AS total_courses,
        COUNT(e.enrollment_id) AS total_enrollments,
        ROUND(AVG(c.avg_rating), 2) AS average_rating,
        ROUND(
            COUNT(
                CASE
                    WHEN e.completion_pct = 100 THEN 1
                END
            ) * 100.0
            / NULLIF(COUNT(e.enrollment_id), 0),
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
FROM instructor_performance
WHERE total_enrollments > 0
ORDER BY performance_rank;


-- 05. Analisis completion rate vs average quiz score
-- Tujuan:
-- Melihat hubungan antara keberhasilan menyelesaikan course
-- dengan performa quiz student/course.
WITH completion AS (
    SELECT
        course_id,
        ROUND(
            COUNT(
                CASE
                    WHEN completion_pct = 100 THEN 1
                END
            ) * 100.0
            / COUNT(*),
            2
        ) AS completion_rate
    FROM analytics.enrollments
    GROUP BY course_id
),

quiz AS (
    SELECT
        course_id,
        ROUND(AVG(score), 2) AS average_quiz_score
    FROM analytics.quiz_result
    GROUP BY course_id
)

SELECT
    c.course_id,
    c.title,
    co.completion_rate,
    q.average_quiz_score
FROM analytics.courses c
LEFT JOIN completion co
    ON c.course_id = co.course_id
LEFT JOIN quiz q
    ON c.course_id = q.course_id
ORDER BY co.completion_rate DESC;


-- 06. Analisis pertumbuhan enrollment secara bulanan
-- Tujuan:
-- Menghitung jumlah enrollment setiap bulan
-- dan perubahan dibandingkan bulan sebelumnya.
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
    ) AS previous_month,
    total_enrollment
    - LAG(total_enrollment) OVER (
        ORDER BY month
    ) AS enrollment_change
FROM monthly_enrollment
ORDER BY month;