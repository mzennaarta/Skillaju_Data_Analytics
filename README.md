# SkillAja-Data-Analytics

**Problem:**  
  Tim manajemen Skillaju kesulitan memantau performa bisnis dan retensi belajar siswa secara terpusat karena data pendaftaran (*enrollment*), kuis, dan keterlibatan siswa masih terisolasi di berbagai tabel terpisah tanpa visualisasi yang intuitif.

* **Action:**  
  * Merancang dan menstrukturkan arsitektur data dengan mengombinasikan **6 SQL Views** dari Google Sheets ke **Looker Studio**.
  * Membangun *interactive 3-page executive dashboard* (*Executive Overview*, *Course & Instructor Performance*, serta *Student & Learning Analysis*).
  * Memformulasikan metrik bisnis khusus seperti **Overall Completion Rate** berbobot pendaftaran untuk menghindari bias kalkulasi rata-rata.

* **Result:**  
  * Menyajikan visibilitas *real-time* untuk **3.000 siswa** dan **10.400 pendaftaran** di seluruh kategori materi.
  * Memungkinkan tim eksekutif mengidentifikasi secara presisi segmen siswa berisiko tinggi (*Low Engagement/At Risk*) serta kursus dengan tingkat penyelesaian rendah (27,6%) untuk pengambilan keputusan berbasis data.

---

## 📐 Data Architecture & Methodology

Data bersumber dari platform e-learning SkillAja yang dikelola melalui Google Sheets dan ditransformasikan ke dalam **6 SQL Views** modular sebelum dihubungkan ke Looker Studio:

```text
[ Raw Data / Google Sheets ] 
           │
           ▼
[ SQL Transformations (6 Views) ]
 ├── 1. vw_student_overview
 ├── 2. vw_student_engagement
 ├── 3. vw_enrollment_trend
 ├── 4. vw_course_performance
 ├── 5. vw_instructor_performance
 └── 6. vw_quiz_performance
           │
           ▼
[ Looker Studio Interactive Dashboard ]
