USE Coursera
GO
-- Bảng User
CREATE TABLE [user] (
    id INT PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL,
    FName NVARCHAR(100),
    Lname NVARCHAR(100),
    Date_of_birth DATE,
    Username NVARCHAR(100) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME DEFAULT GETDATE(),
    Phone_number NVARCHAR(20)
);
GO

-- Bảng follow
CREATE TABLE follow (
    User_id INT,
    Follower_id INT,
    PRIMARY KEY (User_id, Follower_id),
    FOREIGN KEY (User_id) REFERENCES [User](id),
    FOREIGN KEY (Follower_id) REFERENCES [User](id)
);
GO

-- Bảng user_address
CREATE TABLE user_address (
    User_id INT,
    User_addr NVARCHAR(255),
	PRIMARY KEY (User_id, User_addr),
    FOREIGN KEY (User_id) REFERENCES [User](id)
);
GO
-- Bảng user_address - Phụ thuộc mạnh vào User
ALTER TABLE user_address
ADD CONSTRAINT FK_UserAddress_User 
FOREIGN KEY (User_id) REFERENCES [User](id) ON DELETE CASCADE;

-- Bảng role
CREATE TABLE [role] (
    id INT PRIMARY KEY,
    RName NVARCHAR(100) NOT NULL,
    RDescription NVARCHAR(MAX)
);
GO

-- Bảng permission
CREATE TABLE permission (
    id INT PRIMARY KEY,
    PName NVARCHAR(100) NOT NULL,
    PDescription NVARCHAR(MAX)
);
GO

-- Bảng has_role
CREATE TABLE has_role (
    User_id INT NOT NULL,
    Role_id INT NOT NULL,
    PRIMARY KEY (User_id, Role_id),
    FOREIGN KEY (User_id) REFERENCES [User](id),
    FOREIGN KEY (Role_id) REFERENCES [role](id)
);
GO
-- Bảng has_role - Phụ thuộc mạnh vào User
ALTER TABLE has_role
ADD CONSTRAINT FK_HasRole_User 
FOREIGN KEY (User_id) REFERENCES [User](id) ON DELETE CASCADE;

-- Bảng has_permission
CREATE TABLE has_permission (
    Role_id INT NOT NULL,
    Permission_id INT NOT NULL,
    PRIMARY KEY (Role_id, Permission_id),
    FOREIGN KEY (Role_id) REFERENCES [role](id),
    FOREIGN KEY (Permission_id) REFERENCES permission(id)
);
GO

-- Bảng Subject
CREATE TABLE Subject (
    id INT PRIMARY KEY,
    SName NVARCHAR(100) NOT NULL,
    SDescription NVARCHAR(MAX)
);
GO
ALTER TABLE Subject
ADD CONSTRAINT UQ_SName UNIQUE (SName);
GO

-- Bảng Course
CREATE TABLE Course (
    id INT PRIMARY KEY,
    CName NVARCHAR(255) NOT NULL,
    CDescription NVARCHAR(MAX),
    Outcome_info NVARCHAR(MAX),
    Fee INT,
    Enrollment_count INT DEFAULT 0,
    Rating DECIMAL(3,1) DEFAULT 0.0,
);
GO
ALTER TABLE Course
ADD CONSTRAINT UQ_CName UNIQUE (CName);
GO

-- Bảng review_course
CREATE TABLE review_course (
    User_id INT NOT NULL,
    Course_id INT NOT NULL,
    Comment NVARCHAR(MAX),
    Date DATETIME DEFAULT GETDATE(),
    Rating_score DECIMAL(2,1) CHECK (Rating_score BETWEEN 0.0 AND 5.0),
    PRIMARY KEY (User_id, Course_id),
    FOREIGN KEY (User_id) REFERENCES [User](id),
    FOREIGN KEY (Course_id) REFERENCES Course(id)
);
GO
-- Bảng review_course - Phụ thuộc vừa phải, nhưng có thể cân nhắc CASCADE
-- Xóa ràng buộc FK hiện tại
ALTER TABLE review_course
ADD CONSTRAINT FK_ReviewCourse_User 
FOREIGN KEY (User_id) REFERENCES [User](id) ON DELETE CASCADE;

-- Bảng has_course (kết nối Course và Subject)
CREATE TABLE has_course (
    Subject_id INT NOT NULL,
    Course_id INT NOT NULL,
    PRIMARY KEY (Subject_id, Course_id),
    FOREIGN KEY (Subject_id) REFERENCES Subject(id),
    FOREIGN KEY (Course_id) REFERENCES Course(id)
);
GO

-- Bảng Offer
CREATE TABLE Offer (
    Course_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (Course_id) REFERENCES Course(id),
	FOREIGN KEY (user_id) REFERENCES [User](id)
);
GO


-- Bảng Chapter
CREATE TABLE Chapter (
    Chapter_id INT,
    Course_id INT NOT NULL,
	CName NVARCHAR(255) NOT NULL,
    CDescription NVARCHAR(MAX),
	PRIMARY KEY(Chapter_id, Course_id),
    FOREIGN KEY (Course_id) REFERENCES Course(id),
);
GO

-- Bảng Lesson (lưu trữ thông tin bài học)
CREATE TABLE Lesson (
    Course_id INT NOT NULL,
    Chapter_id INT NOT NULL,
    Lesson_id INT NOT NULL,
    LName NVARCHAR(255) NOT NULL,
    LDescription NVARCHAR(MAX),
    LType NVARCHAR(50) NOT NULL CHECK (LType IN ('Reading', 'Video', 'Assignment', 'Quiz')),
    PRIMARY KEY (Course_id, Chapter_id, Lesson_id),
    FOREIGN KEY (Chapter_id, Course_id) REFERENCES Chapter(Chapter_id, Course_id)
);
GO

-- Bảng Learn (lưu trữ tiến trình học tập của người dùng)
CREATE TABLE Learn (
    User_id INT NOT NULL,
    Course_id INT NOT NULL,
    Chapter_id INT NOT NULL,
    Lesson_id INT NOT NULL,
    status NVARCHAR(50) NOT NULL CHECK (status IN ('completed', 'in-progress', 'not-started')),
    score DECIMAL(5,1),
    attempt INT DEFAULT 1,
    PRIMARY KEY (User_id, Course_id, Chapter_id, Lesson_id),
    FOREIGN KEY (User_id) REFERENCES [User](id),
    FOREIGN KEY (Course_id, Chapter_id, Lesson_id) REFERENCES Lesson(Course_id, Chapter_id, Lesson_id)
);
GO
-- Bảng Learn - Phụ thuộc mạnh vào User
ALTER TABLE Learn
ADD CONSTRAINT FK_Learn_User 
FOREIGN KEY (User_id) REFERENCES [User](id) ON DELETE CASCADE;

-- Bảng Assignment (bài tập lớn)
CREATE TABLE Assignment (
    Course_id INT NOT NULL,
    Chapter_id INT NOT NULL,
    Lesson_id INT NOT NULL,
    Number_of_attempts INT DEFAULT 1,
    Number_of_days INT, -- Thời hạn nộp bài (số ngày)
    Passing_score DECIMAL(5,1),
    Instruction NVARCHAR(MAX),
    PRIMARY KEY (Course_id, Chapter_id, Lesson_id),
    FOREIGN KEY (Course_id, Chapter_id, Lesson_id) REFERENCES Lesson(Course_id, Chapter_id, Lesson_id)
);
GO



-- Bảng Quiz (bài kiểm tra)
CREATE TABLE Quiz (
    Course_id INT NOT NULL,
    Chapter_id INT NOT NULL,
    Lesson_id INT NOT NULL,
    Number_of_attempts INT DEFAULT 1,
    Passing_score DECIMAL(5,1),
    Time_limit INT, -- Thời gian làm bài (phút)
    Number_of_question INT,
    PRIMARY KEY (Course_id, Chapter_id, Lesson_id),
    FOREIGN KEY (Course_id, Chapter_id, Lesson_id) REFERENCES Lesson(Course_id, Chapter_id, Lesson_id)
);
GO

-- Bảng Video
CREATE TABLE Video (
    Course_id INT NOT NULL,
    Chapter_id INT NOT NULL,
    Lesson_id INT NOT NULL,
    Video_link NVARCHAR(MAX) NOT NULL,
    Duration INT, -- Thời lượng tính bằng phút
    PRIMARY KEY (Course_id, Chapter_id, Lesson_id),
    FOREIGN KEY (Course_id, Chapter_id, Lesson_id) REFERENCES Lesson(Course_id, Chapter_id, Lesson_id)
);
GO

-- Bảng Reading 
CREATE TABLE Reading (
    Course_id INT NOT NULL,
    Chapter_id INT NOT NULL,
    Lesson_id INT NOT NULL,
    Link NVARCHAR(MAX) NOT NULL,
    PRIMARY KEY (Course_id, Chapter_id, Lesson_id),
    FOREIGN KEY (Course_id, Chapter_id, Lesson_id) REFERENCES Lesson(Course_id, Chapter_id, Lesson_id)
);
GO

-- Bảng Question (câu hỏi)
CREATE TABLE Question (
    Question_id INT PRIMARY KEY,
    Qtext NVARCHAR(MAX) NOT NULL,
    Qtype NVARCHAR(50) NOT NULL CHECK (Qtype IN ('MCQS', 'TFQ')), -- Ví dụ: 'multiple-choice', 'true-false'
    Course_id INT NOT NULL,
    Chapter_id INT NOT NULL,
    Lesson_id INT NOT NULL,
    FOREIGN KEY (Course_id, Chapter_id, Lesson_id) REFERENCES Quiz(Course_id, Chapter_id, Lesson_id)
);
GO

-- Bảng Answer (đáp án)
CREATE TABLE Answer (
    Answer_id INT NOT NULL,
    Question_id INT NOT NULL,
    Answer_text NVARCHAR(MAX) NOT NULL,
    is_correct BIT DEFAULT 0, -- 0: Sai, 1: Đúng
    PRIMARY KEY (Answer_id, Question_id),
    FOREIGN KEY (Question_id) REFERENCES Question(Question_id)
);
GO

-- Bảng Certificate (lưu thông tin chứng chỉ)
CREATE TABLE Certificate (
    Certificate_id INT PRIMARY KEY,
    Cer_name NVARCHAR(255) NOT NULL,
    Awarding_institution NVARCHAR(255) NOT NULL,
    Certificate_url NVARCHAR(MAX) NOT NULL,
    Course_id INT NOT NULL,
    FOREIGN KEY (Course_id) REFERENCES Course(id)
);
GO

-- Bảng obtain_certificate (lưu thông tin người dùng nhận chứng chỉ)
CREATE TABLE obtain_certificate (
    Certificate_id INT NOT NULL,
    User_id INT NOT NULL,
    Issue_date DATE NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (Certificate_id, User_id),
    FOREIGN KEY (Certificate_id) REFERENCES Certificate(Certificate_id),
    FOREIGN KEY (User_id) REFERENCES [User](id)
);
GO
-- Bảng obtain_certificate - Phụ thuộc vừa phải, có thể cân nhắc CASCADE
ALTER TABLE obtain_certificate
ADD CONSTRAINT FK_ObtainCertificate_User 
FOREIGN KEY (User_id) REFERENCES [User](id) ON DELETE CASCADE;

-- Bảng Coupon
CREATE TABLE Coupon (
    Coupon_id INT PRIMARY KEY,
    Coupon_code NVARCHAR(50) NOT NULL UNIQUE,
    Start_date DATETIME NOT NULL,
    End_date DATETIME NOT NULL,
    Discount_type NVARCHAR(20) NOT NULL CHECK (Discount_type IN ('Percentage', 'Fixed')),
    Discount_value INT,
    Coupon_type NVARCHAR(50),
    Amount INT,
    Duration INT,
    CHECK (End_date > Start_date)
);
GO

-- Bảng Order
CREATE TABLE [Order] (
    Order_id INT PRIMARY KEY,
    User_id INT NOT NULL,
    Ord_status NVARCHAR(20) NOT NULL CHECK (Ord_status IN ('Pending', 'Completed', 'Cancelled', 'Refunded')),
    Ord_date DATETIME NOT NULL DEFAULT GETDATE(),
    Total_fee INT,
    Certificate_url NVARCHAR(MAX),
    FOREIGN KEY (User_id) REFERENCES [User](id)
);
GO
-- Bảng use_coupon (quan hệ giữa Order và Coupon)
CREATE TABLE use_coupon (
    Coupon_id INT NOT NULL,
    Order_id INT NOT NULL,
    PRIMARY KEY (Coupon_id, Order_id),
    FOREIGN KEY (Coupon_id) REFERENCES Coupon(Coupon_id),
    FOREIGN KEY (Order_id) REFERENCES [Order](Order_id)
);
GO

-- Bảng include_course (quan hệ giữa Order và Course)
CREATE TABLE include_course (
    Order_id INT NOT NULL,
    Course_id INT NOT NULL,
    PRIMARY KEY (Order_id, Course_id),
    FOREIGN KEY (Order_id) REFERENCES [Order](Order_id),
    FOREIGN KEY (Course_id) REFERENCES Course(id)
);
GO

-- Bảng Order_receipt 
CREATE TABLE Order_receipt (
	Receipt_id INT PRIMARY KEY,
    Export_date DATETIME NOT NULL DEFAULT GETDATE(),
    Total_fee INT NOT NULL CHECK (Total_fee >= 0),
    Order_id INT NOT NULL,
    FOREIGN KEY (Order_id) REFERENCES [Order](Order_id)
);
GO

-- 1. Người dùng phải đủ 13 tuổi
CREATE OR ALTER TRIGGER trg_check_min_age_13
ON [user]
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra tuổi
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATEADD(YEAR, 13, date_of_birth) > GETDATE()
    )
    BEGIN
        RAISERROR ('Người dùng phải đủ 13 tuổi trở lên.', 16, 1);
        RETURN;
    END;

    -- Nếu đủ tuổi thì thực hiện INSERT hoặc UPDATE
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Nếu là INSERT
        IF NOT EXISTS (SELECT * FROM deleted)
        BEGIN
            INSERT INTO [user] (id, email, fname, lname, date_of_birth, username, password, created_at, updated_at, phone_number)
            SELECT id, email, fname, lname, date_of_birth, username, password, created_at, updated_at, phone_number
            FROM inserted;
        END
        ELSE
        BEGIN
            -- Nếu là UPDATE
            UPDATE u
            SET u.email = i.email,
                u.fname = i.fname,
                u.lname = i.lname,
                u.date_of_birth = i.date_of_birth,
                u.username = i.username,
                u.password = i.password,
                u.created_at = i.created_at,
                u.updated_at = i.updated_at,
                u.phone_number = i.phone_number
            FROM [user] u
            JOIN inserted i ON u.id = i.id;
        END
    END
END;
GO

-- Thử insert sai
INSERT INTO [User] (id, Email, FName, LName, Date_of_birth, Username, Password, Phone_number)
VALUES
 (9999,'xxx@example.com','x','x','2020-05-15','x','Password123!','0123456789')
GO
-- Thử insert sai
UPDATE [user]
SET date_of_birth = '2015-05-01'
WHERE id = 1;
GO

select * from [user]

-- 2. Password phải có tối thiểu 8 kí tự
ALTER TABLE [user]
ADD CONSTRAINT CHK_Password_Length CHECK (LEN(Password) >= 8);
GO

-- Thử insert sai
INSERT INTO [User] (id, Email, FName, LName, Date_of_birth, Username, Password, Phone_number)
VALUES
 (999,'xxx@example.com','x','x','2000-05-15','x','1234567','0123456789')
GO

-- 3. Học phí khóa học ≥ 0
ALTER TABLE Course
ADD CONSTRAINT CHK_Course_Fee CHECK (Fee >= 0);
GO

-- 4. Điểm đánh giá mỗi khóa học được tính theo số sao từ 0 đến 5.
ALTER TABLE dbo.course
ADD CONSTRAINT chk_rating_range
CHECK (rating >= 0 AND rating <= 5);
GO

--5 Người dùng chỉ có thể đánh giá khóa học nếu họ đã hoàn thành hơn 50% nội dung.
--DROP TRIGGER trg_check_review_progress
CREATE OR ALTER TRIGGER trg_check_review_progress
ON review_course
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        CROSS APPLY (
            SELECT 
                -- Tổng số bài học duy nhất trong khóa học
                (SELECT COUNT(*) 
                 FROM (SELECT DISTINCT Chapter_id, Lesson_id
                       FROM Lesson
                       WHERE Course_id = i.Course_id) AS TotalLessons) AS total_lessons,

                -- Số bài học hoàn thành duy nhất của người dùng trong khóa học
                (SELECT COUNT(*) 
                 FROM (SELECT DISTINCT Chapter_id, Lesson_id
                       FROM Learn
                       WHERE Course_id = i.Course_id 
                         AND User_id = i.User_id
                         AND Status = 'completed') AS CompletedLessons) AS completed_lessons
        ) AS progress
		-- Chỉ tính những khóa học có bài học (Lesson)
        WHERE progress.total_lessons > 0
          AND (1.0 * progress.completed_lessons / NULLIF(progress.total_lessons, 0)) <= 0.5
    )
    BEGIN
        RAISERROR('Người dùng phải hoàn thành hơn 50%% nội dung khóa học để đánh giá.', 16, 1);
        RETURN;
    END;

    -- Chèn dữ liệu review nếu hợp lệ
    INSERT INTO review_course (User_id, Course_id, Comment, Date, Rating_score)
    SELECT User_id, Course_id, Comment, Date, Rating_score
    FROM inserted;
END;
GO

-- Kiểm tra user chưa hoàn thành 50% khóa học mà review
select * from Learn
select * from Lesson
select * from review_course
select * from Course
select * from [User]
INSERT INTO review_course (User_id, Course_id, Comment, Date, Rating_score)
VALUES
 (3,101,'Great introduction to programming!','2024-01-15',4.5)
GO
INSERT INTO review_course (User_id, Course_id, Comment, Date, Rating_score)
VALUES
  (2, 101, 'Solid content, but I wish there were more practical exercises.', '2024-01-16', 4.0),
  (5, 102, 'The course was very detailed and the instructor was clear. Highly recommended for advanced learners.', '2024-01-17', 5.0),
  (6, 103, 'Not engaging enough, I expected more interactivity.', '2024-01-18', 3.0),
  (3, 104, 'A comprehensive course, but some topics could be explained better.', '2024-01-19', 3.5),
  (7, 106, 'Great content, but the pace was a bit fast for beginners.', '2024-01-21', 4.2),
  (6, 107, 'I didn’t learn much from this course. The material wasn’t very up to date.', '2024-01-22', 2.5),
  (7, 108, 'Good course but lacks depth in certain areas. Could use more real-world examples.', '2024-01-23', 3.8),
  (100, 109, 'Loved it! The hands-on approach helped me understand the concepts better.', '2024-01-24', 5.0);
GO

DELETE FROM review_course WHERE user_id = 4 AND Course_id = 101;

-- 6. Mỗi user chỉ đánh giá mỗi course 1 lần
-- (Đã được đảm bảo bởi PRIMARY KEY (User_id, Course_id))
-- Không cần thêm ràng buộc

-- 7. Ngày hết hiệu lực của mã giảm giá phải sau ngày bắt đầu có hiệu lực.
-- (Đã check lúc tạo bảng)

-- 8. Điểm assignment và quiz ≥ 0
ALTER TABLE Assignment
ADD CONSTRAINT CHK_Assignment_Score CHECK (Passing_score >= 0);
GO

ALTER TABLE Quiz
ADD CONSTRAINT CHK_Quiz_Score CHECK (Passing_score >= 0);
GO

-- Thử insert sai
INSERT INTO Assignment (Course_id, Chapter_id, Lesson_id, Number_of_attempts, Number_of_days, Passing_score, Instruction)
VALUES
 (101,1,4,0,7,70,'Submit a console program that prints Hello World')
GO

-- 9. Number_of_attempts và Number_of_days của Assignment > 0

ALTER TABLE Assignment
ADD CONSTRAINT CHK_Assignment_Attempts CHECK (Number_of_attempts > 0),
    CONSTRAINT CHK_Assignment_Days CHECK (Number_of_days > 0)
GO


-- 10. Phải hoàn thành 100% các bài học trong thời gian 180 ngày kể 
	--từ ngày mua khóa học mới có thể đươc cấp chứng chỉ.

CREATE TRIGGER trg_check_certificate_eligibility
ON obtain_certificate
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted ic
        JOIN Certificate c ON ic.Certificate_id = c.Certificate_id
        JOIN include_course inc ON inc.Course_id = c.Course_id
        JOIN [Order] o ON o.Order_id = inc.Order_id AND o.User_id = ic.User_id
        JOIN Order_receipt r ON r.Order_id = o.Order_id
        CROSS APPLY (
            SELECT 
                COUNT(*) AS total_lessons,
                SUM(CASE 
                    WHEN l.status = 'completed' 
                         AND DATEDIFF(DAY, r.Export_date, GETDATE()) <= 180 
                    THEN 1 ELSE 0 END) AS completed_lessons
					-- completed_lessons: Số bài học người dùng đã hoàn thành trong vòng 180 ngày kể từ ngày bắt đầu học.
            FROM Lesson le
            JOIN Learn l ON l.Lesson_id = le.Lesson_id AND l.Course_id = le.Course_id
                         AND l.Chapter_id = le.Chapter_id AND l.User_id = ic.User_id
            WHERE le.Course_id = c.Course_id
        ) AS progress
        WHERE progress.completed_lessons < progress.total_lessons
    )
    BEGIN
        RAISERROR('Bạn phải hoàn thành 100%% bài học trong vòng 180 ngày để được cấp chứng chỉ.', 16, 1);
        RETURN;
    END;

    -- Nếu hợp lệ thì chèn vào
    INSERT INTO obtain_certificate (Certificate_id, User_id, Issue_date)
    SELECT Certificate_id, User_id, Issue_date
    FROM inserted;
END;
GO




USE Coursera;
GO

-- Bảng [User]
INSERT INTO [User] (id, Email, FName, LName, Date_of_birth, Username, Password, Phone_number)
VALUES
 (1,'alice@example.com','Alice','Nguyen','1990-05-15','alice90','Password123!','0123456789'),
 (2,'bob@example.com','Bob','Tran','1985-08-20','bob85','SecurePass456!','0987654321'),
 (3,'charlie@example.com','Charlie','Le','2000-12-01','charlie00','MyP@ssw0rd','0912345678'),
 (4,'david@example.com','David','Pham','1995-02-10','david95','PassWord789!','0901234567'),
 (5,'eve@example.com','Eve','Hoang','2002-07-25','eve02','EvePass321!','0932123456');
GO
INSERT INTO [User] (id, Email, FName, LName, Date_of_birth, Username, Password, Phone_number)
VALUES
(8, 'hannah@example.com', 'Hannah', 'Nguyen', '1991-04-12', 'hannah91', 'H@nnahPwd!', '0911001100'),
(9, 'ian@example.com', 'Ian', 'Le', '1994-09-08', 'ian94', 'IanSecure456$', '0911001101'),
(10, 'julia@example.com', 'Julia', 'Pham', '1989-01-22', 'julia89', 'Juli@1234', '0911001102'),
(11, 'kevin@example.com', 'Kevin', 'Ho', '1996-06-17', 'kevin96', 'K3vinStrong!', '0911001103'),
(12, 'lisa@example.com', 'Lisa', 'Tran', '2001-10-30', 'lisa01', 'Lis@Pwd99', '0911001104'),
(13, 'mike@example.com', 'Mike', 'Vo', '1993-08-13', 'mike93', 'MikeSecure!', '0911001105'),
(14, 'nina@example.com', 'Nina', 'Bui', '1990-03-25', 'nina90', 'N1naP@ss', '0911001106'),
(15, 'oliver@example.com', 'Oliver', 'Dang', '1995-12-04', 'oliver95', 'Ol!ver1234', '0911001107'),
(16, 'paula@example.com', 'Paula', 'Trinh', '1998-05-19', 'paula98', 'PaulaPwd@', '0911001108'),
(17, 'quang@example.com', 'Quang', 'Mai', '1992-07-01', 'quang92', 'Qu@ngSecure', '0911001109'),
(18, 'rachel@example.com', 'Rachel', 'Nguyen', '2000-11-11', 'rachel00', 'Rachel_2024!', '0911001110'),
(19, 'steve@example.com', 'Steve', 'Le', '1988-02-27', 'steve88', 'Stev3Pass', '0911001111'),
(20, 'tina@example.com', 'Tina', 'Pham', '1997-09-14', 'tina97', 'T!na_789', '0911001112'),
(21, 'ugo@example.com', 'Ugo', 'Doan', '1999-06-23', 'ugo99', 'UgoPass!23', '0911001113'),
(22, 'victoria@example.com', 'Victoria', 'Ha', '1990-08-18', 'vic90', 'Vict0r!aPwd', '0911001114'),
(23, 'will@example.com', 'Will', 'Hoang', '1994-04-03', 'will94', 'W1llStr0ng', '0911001115'),
(24, 'xuan@example.com', 'Xuan', 'Truong', '1996-12-12', 'xuan96', 'Xu@nSecure', '0911001116'),
(25, 'yvonne@example.com', 'Yvonne', 'Le', '1993-10-07', 'yvonne93', 'Yv0nnePwd', '0911001117'),
(26, 'zack@example.com', 'Zack', 'Pham', '2002-01-05', 'zack02', 'Z@ckPass123', '0911001118'),
(27, 'bao@example.com', 'Bao', 'Nguyen', '1995-03-16', 'bao95', 'Bao_StrongPwd', '0911001119');
GO
-- Bảng follow
INSERT INTO follow (User_id, Follower_id)
VALUES
 (1,2),
 (1,3),
 (2,4),
 (2,5),
 (3,4);
GO
INSERT INTO follow (User_id, Follower_id)
VALUES
  (1,  8),   
  (2,  9),   
  (3, 10),   
  (4, 11),   
  (5, 12),   
  (8,  1),   
  (9,  2),   
  (10, 3),   
  (11, 4),   
  (12, 5),   
  (13, 14),  
  (14, 13), 
  (15, 16),  
  (16, 15),  
  (17, 18), 
  (18, 17), 
  (19, 20), 
  (20, 19), 
  (21, 22)
GO

-- Bảng user_address
INSERT INTO user_address (User_id, User_addr)
VALUES
 (1,'123 Le Loi, District 1, HCMC'),
 (2,'456 Tran Hung Dao, District 5, HCMC'),
 (3,'789 Nguyen Trai, District 3, HCMC'),
 (4,'321 Pham Ngu Lao, District 1, HCMC'),
 (5,'654 Pasteur, District 3, HCMC');
GO

-- Bảng role
INSERT INTO role (id, RName, RDescription)
VALUES
 (1,'Admin','System administrator with full privileges'),
 (2,'Instructor','Can create and manage courses'),
 (3,'Student','Can enroll in and review courses'),
 (4,'Moderator','Can manage user comments and feedback'),
 (5,'Guest','Read-only access to public course catalog');
GO

-- Bảng permission
INSERT INTO permission (id, PName, PDescription)
VALUES
 (1,'create_course','Permission to create courses'),
 (2,'review_course','Permission to review courses'),
 (3,'enroll_course','Permission to enroll in courses'),
 (4,'manage_users','Permission to manage user accounts'),
 (5,'view_reports','Permission to view analytics reports');
GO

-- Bảng has_role
INSERT INTO has_role (User_id, Role_id)
VALUES
 (1,3),  -- Alice là Student
 (2,2),  -- Bob là Instructor
 (3,3),  -- Charlie là Student
 (4,4),  -- David là Moderator
 (5,5);  -- Eve là Guest
GO
INSERT INTO has_role (User_id, Role_id)
VALUES
 (3,2),
 (4,2),
 (5,2),
 (6,2),
 (7,2),
 (8,2),
 (9,2),
 (10,2),
 (11,2),
 (12,2),
 (13,2),
 (14,2),
 (15,2),
 (16,2),
 (17,2),
 (18,2),
 (19,2),
 (20,2),
 (21,2)
GO

-- Bảng has_permission
INSERT INTO has_permission (Role_id, Permission_id)
VALUES
 (1,1),
 (1,4),
 (2,1),
 (3,3),
 (4,2);
GO

-- Bảng Subject
INSERT INTO Subject (id, SName, SDescription)
VALUES
 (1,'Computer Science','Courses about algorithms, programming, and systems'),
 (2,'Data Science','Courses about data analysis, machine learning, and statistics'),
 (3,'Business','Courses about management, finance, and entrepreneurship'),
 (4,'Art','Courses about fine arts, design, and creativity'),
 (5,'Mathematics','Courses about algebra, calculus, and more');
GO
INSERT INTO Subject (id, SName, SDescription)
VALUES
(6, 'Web Development', 'Courses about building websites, front-end, and back-end development'),
(7, 'Machine Learning', 'Courses about AI, neural networks, and deep learning techniques'),
(8, 'Creative Writing', 'Courses about storytelling, novel writing, and literary analysis'),
(9, 'Cybersecurity', 'Courses about ethical hacking, network security, and data protection'),
(10, 'Project Management', 'Courses about managing projects, teams, and timelines');

-- Bảng Course
INSERT INTO Course (id, CName, CDescription, Outcome_info, Fee, Enrollment_count, Rating)
VALUES
(106, 'Web Development Bootcamp', 'Full-stack web development course', 'Build modern websites using HTML, CSS, JS, and Node.js', 180, 300, 4.8),
  (107, 'Machine Learning Basics', 'Introduction to machine learning concepts', 'Train and evaluate ML models using Python', 220, 210, 4.6),
  (108, 'Creative Writing Workshop', 'Improve your storytelling and writing style', 'Write compelling short stories and essays', 75, 130, 4.2),
  (109, 'Cybersecurity Fundamentals', 'Learn the principles of cybersecurity and ethical hacking', 'Identify and prevent common security threats', 160, 175, 4.5),
  (110, 'Project Management Essentials', 'Master the basics of project planning and execution', 'Manage small to medium-sized projects effectively', 140, 190, 4.3),
 (101,'Intro to Programming','Learn the basics of programming','Write simple programs',100,200,4.5),
 (102,'Data Analysis with Python','Analyze data using Python libraries','Create data visualizations',150,180,4.7),
 (103,'Financial Markets','Understand how financial markets operate','Evaluate investment opportunities',200,120,4.3),
 (104,'Digital Painting','Learn digital art techniques','Produce digital artwork',80,90,4.6),
 (105,'Calculus I','Fundamentals of differential calculus','Solve derivatives and limits',120,250,4.4);
GO
INSERT INTO Course (id, CName, CDescription, Outcome_info, Fee, Enrollment_count, Rating)
VALUES
(111, 'Advanced Java Programming', 'Master advanced concepts in Java', 'Build complex applications using Java', 210, 150, 4.2),
(112, 'Intro to Artificial Intelligence', 'Basics of AI and applications', 'Understand AI principles and simple models', 180, 170, 4.3),
(113, 'Photography Basics', 'Learn photography techniques', 'Take professional-looking photos', 90, 95, 4.1),
(114, 'UI/UX Design Fundamentals', 'Design user-friendly interfaces', 'Create wireframes and prototypes', 130, 180, 4.5),
(115, 'Blockchain Essentials', 'Understand blockchain and cryptocurrencies', 'Build smart contracts and apps', 220, 140, 4.4),
(116, 'Cloud Computing with AWS', 'Learn to use AWS services', 'Deploy scalable applications on the cloud', 200, 190, 4.6),
(117, 'Mobile App Development', 'Build apps for Android & iOS', 'Develop and deploy mobile apps', 160, 220, 4.3),
(118, 'Statistics for Data Science', 'Core statistics concepts for DS', 'Apply statistical analysis in Python', 140, 130, 4.2),
(119, 'Public Speaking Mastery', 'Boost communication skills', 'Deliver confident presentations', 100, 110, 4.7),
(120, 'Game Development with Unity', 'Create 2D/3D games in Unity', 'Build interactive games from scratch', 180, 160, 4.5),
(121, 'Python for Automation', 'Automate tasks using Python', 'Write scripts for real-life workflows', 120, 200, 4.6),
(122, 'Ethical Hacking Basics', 'Understand how hackers think', 'Defend against common vulnerabilities', 160, 150, 4.3),
(123, 'Graphic Design with Photoshop', 'Create amazing graphics', 'Use Photoshop tools like a pro', 110, 140, 4.2),
(124, 'SQL and Databases', 'Work with relational databases', 'Design schemas and write SQL queries', 130, 210, 4.4),
(125, 'Networking Fundamentals', 'Intro to computer networks', 'Configure basic network setups', 100, 120, 4.1),
(126, 'Digital Marketing Basics', 'Learn online marketing', 'Run effective ad campaigns', 90, 130, 4.3),
(127, '3D Modeling with Blender', 'Create 3D assets', 'Model and animate in Blender', 140, 90, 4.2),
(128, 'English for Professionals', 'Improve formal English skills', 'Write emails, reports, and speak clearly', 80, 160, 4.0),
(129, 'Agile Project Management', 'Manage projects with Agile/Scrum', 'Use Jira and sprints effectively', 150, 180, 4.4),
(130, 'Entrepreneurship 101', 'Start your own business', 'Build a startup from idea to launch', 200, 100, 4.5);
GO

-- Bảng review_course
INSERT INTO review_course (User_id, Course_id, Comment, Date, Rating_score)
VALUES
 (1,101,'Great introduction to programming!','2024-01-15',4.5),
 (2,102,'Very practical and hands‑on.','2024-02-10',4.7),
 (3,103,'Good coverage of markets.','2024-03-05',4.2),
 (1,105,'Challenging but rewarding.','2024-04-01',4.4),
 (5,104,'Loved the creative projects.','2024-04-10',4.6);
GO
select * from review_course
select * from Learn
INSERT INTO review_course (User_id, Course_id, Comment, Date, Rating_score)
VALUES
    (8, 109, 'Really enjoyed the hands-on labs!', '2024-05-01', 4.8),
    (9, 110, 'Clear explanations, but some videos were too long.', '2024-05-03', 4.0),
    (10, 111, 'Perfect for beginners, highly recommend!', '2024-05-05', 5.0),
    (11, 112, 'Content was outdated, needs more modern examples.', '2024-05-07', 2.8),
    (12, 113, 'Well-structured course with great assignments.', '2024-05-10', 4.5),
    (13, 114, 'Good intro, but I wanted more advanced topics.', '2024-05-12', 3.7),
    (14, 115, 'Instructor was engaging, but quizzes were too easy.', '2024-05-15', 4.2),
    (15, 116, 'Very practical, learned a lot!', '2024-05-20', 4.9),
    (16, 117, 'Some sections were confusing, needs better explanations.', '2024-06-01', 3.5),
    (17, 118, 'Loved the real-world projects!', '2024-06-05', 4.6),
    (18, 119, 'Too fast-paced for me, but content was solid.', '2024-06-10', 3.8),
    (19, 120, 'Not what I expected, too theoretical.', '2024-06-15', 2.5),
    (20, 121, 'Great course, but I wish it had more examples.', '2024-06-20', 4.0),
    (21, 122, 'Best course I’ve taken so far!', '2024-07-01', 5.0),
    (22, 123, 'Very interactive, kept me engaged.', '2024-07-05', 4.7),
    (23, 124, 'Good, but some topics were rushed.', '2024-07-10', 3.9),
    (24, 125, 'Excellent course, worth every penny!', '2024-07-15', 4.8),
    (25, 126, 'Could be better with more practical exercises.', '2024-08-01', 3.6),
    (26, 127, 'Fantastic instructor, very knowledgeable.', '2024-08-05', 4.9),
    (27, 128, 'Solid foundation for programming.', '2024-08-10', 4.3),
    (1, 129, 'Too many videos, needs more quizzes.', '2024-08-15', 3.7),
    (2, 130, 'Really helped me understand the basics.', '2024-09-01', 4.5),
    (3, 109, 'Content was great, but pacing was uneven.', '2024-09-05', 4.0),
    (4, 110, 'Challenging but very rewarding!', '2024-09-10', 4.6),
    (5, 111, 'Needs more real-world applications.', '2024-09-15', 3.4),
    (6, 112, 'Disappointing, not enough depth.', '2024-10-01', 2.7),
    (7, 113, 'Very well-designed course!', '2024-10-05', 4.8),
    (8, 114, 'Good but could use more interactive elements.', '2024-10-10', 4.1),
    (9, 115, 'Loved the practical approach!', '2024-11-01', 4.9),
    (10, 116, 'Okay, but I expected more.', '2024-11-05', 3.5);
GO

INSERT INTO review_course (User_id, Course_id, Comment, Date, Rating_score)
VALUES
    (11, 117, 'Very engaging, but some topics were rushed.', '2024-11-10', 4.0),
    (12, 118, 'Great practical exercises!', '2024-11-12', 4.7),
    (13, 119, 'Content was okay, but pacing was uneven.', '2024-11-15', 3.5),
    (14, 120, 'Loved the instructor’s teaching style!', '2024-11-20', 4.9),
    (15, 121, 'Needs more real-world examples.', '2024-11-25', 3.2),
    (16, 122, 'Amazing course, highly recommend!', '2024-12-01', 5.0),
    (17, 123, 'Good but could use more quizzes.', '2024-12-05', 4.1),
    (18, 124, 'Too theoretical for my taste.', '2024-12-10', 2.8),
    (19, 125, 'Well-structured and informative.', '2024-12-15', 4.5),
    (20, 126, 'Instructor was clear, but content was basic.', '2024-12-20', 3.7),
    (21, 127, 'Fantastic course for beginners!', '2024-12-25', 4.8),
    (22, 128, 'Needs more interactive elements.', '2025-01-01', 3.4),
    (23, 129, 'Really helped me grasp the concepts.', '2025-01-05', 4.6),
    (24, 130, 'Disappointing, not enough depth.', '2025-01-10', 2.7),
    (25, 101, 'Very practical and hands-on.', '2025-01-15', 4.9),
    (26, 102, 'Some videos were too long.', '2025-01-20', 3.8),
    (27, 103, 'Excellent course, worth it!', '2025-01-25', 4.7),
    (1, 104, 'Good but pacing was a bit fast.', '2025-02-01', 4.0),
    (2, 105, 'Loved the real-world applications!', '2025-02-05', 4.8),
    (3, 106, 'Content was outdated.', '2025-02-10', 2.9),
    (4, 107, 'Very engaging instructor!', '2025-02-15', 4.6),
    (5, 108, 'Needs more practical exercises.', '2025-02-20', 3.5),
    (6, 109, 'Best course I’ve taken!', '2025-02-25', 5.0),
    (7, 110, 'Okay, but I expected more depth.', '2025-03-01', 3.3),
    (8, 111, 'Really practical and well-explained.', '2025-03-05', 4.7),
    (9, 112, 'Too fast-paced for beginners.', '2025-03-10', 3.6),
    (10, 113, 'Fantastic, learned a lot!', '2025-03-15', 4.9),
    (11, 114, 'Content was good, but quizzes were too easy.', '2025-03-20', 4.0),
    (12, 115, 'Not very engaging.', '2025-03-25', 2.8),
    (13, 116, 'Well-structured, but needs more examples.', '2025-03-30', 4.2),
    (14, 117, 'Great course for intermediates!', '2025-04-01', 4.8),
    (15, 118, 'Some sections were confusing.', '2025-04-05', 3.4),
    (16, 119, 'Loved the hands-on projects!', '2025-04-10', 4.7),
    (17, 120, 'Too theoretical, needs more practice.', '2025-04-15', 3.0),
    (18, 121, 'Excellent instructor, very clear.', '2025-04-20', 4.9),
    (19, 122, 'Good but could be more interactive.', '2025-04-25', 4.1),
    (20, 123, 'Really helped me understand the material.', '2025-04-30', 4.6),
    (21, 124, 'Disappointing, not enough practical content.', '2025-05-01', 2.7),
    (22, 125, 'Very well-designed course!', '2025-05-05', 4.8),
    (23, 126, 'Okay, but pacing was uneven.', '2025-05-10', 3.5),
    (24, 127, 'Loved the practical approach!', '2025-05-15', 4.9),
    (25, 128, 'Needs more real-world applications.', '2025-05-20', 3.3),
    (26, 129, 'Fantastic course, highly recommend!', '2025-05-25', 5.0),
    (27, 130, 'Good but could use more quizzes.', '2025-05-30', 4.0),
    (1, 102, 'Very practical, but some topics were rushed.', '2025-06-01', 4.2),
    (2, 103, 'Content was outdated, needs updating.', '2025-06-05', 2.9),
    (3, 105, 'Challenging but rewarding!', '2025-06-10', 4.7),
    (4, 106, 'Instructor was engaging!', '2025-06-15', 4.5),
    (5, 107, 'Needs more depth in some areas.', '2025-06-20', 3.6);
GO

-- Bảng has_course
INSERT INTO has_course (Subject_id, Course_id)
VALUES
 (1,101),
 (2,102),
 (3,103),
 (4,104),
 (5,105);
GO
INSERT INTO has_course (Subject_id, Course_id)
VALUES
(1, 106),  -- Subject 1 với Course 106
(2, 108),  -- Subject 2 với Course 108
(3, 107),  -- Subject 3 với Course 107
(4, 110),  -- Subject 4 với Course 110
(5, 109),  -- Subject 5 với Course 109
(6, 106),  -- Subject 6 với Course 106
(6, 107),  -- Subject 6 với Course 107
(7, 101),  -- Subject 7 với Course 101
(7, 110),  -- Subject 7 với Course 110
(8, 108),  -- Subject 8 với Course 108
(8, 109),  -- Subject 8 với Course 109
(9, 103),  -- Subject 9 với Course 103
(9, 105);  -- Subject 9 với Course 105
INSERT INTO has_course (Subject_id, Course_id)
VALUES
(1, 111),  -- Advanced Java Programming → Computer Science
(1, 124),  -- SQL and Databases → Computer Science
(2, 112),  -- Intro to AI → Data Science
(2, 118),  -- Statistics for Data Science → Data Science
(2, 122),  -- Ethical Hacking Basics → Data Science (kỹ năng liên quan đến dữ liệu)
(3, 119),  -- Public Speaking Mastery → Business
(3, 126),  -- Digital Marketing Basics → Business
(3, 130),  -- Entrepreneurship 101 → Business
(4, 113),  -- Photography Basics → Art
(4, 123),  -- Graphic Design with Photoshop → Art
(4, 127),  -- 3D Modeling with Blender → Art
(5, 125),  -- Networking Fundamentals → Mathematics (liên quan logic mạng)
(5, 128),  -- English for Professionals → Mathematics (giao tiếp học thuật)
(6, 114),  -- UI/UX Design Fundamentals → Web Development
(6, 116),  -- Cloud Computing with AWS → Web Development
(6, 117),  -- Mobile App Development → Web Development
(6, 120),  -- Game Development with Unity → Web Development
(7, 115),  -- Blockchain Essentials → Machine Learning
(7, 121),  -- Python for Automation → Machine Learning
(7, 129);  -- Agile Project Management → Machine Learning / Technical teams
GO
-- Bảng Offer
INSERT INTO Offer (Course_id, User_id)
VALUES
 (101,2),
 (102,2),
 (103,3),
 (104,4),
 (105,3);
GO
INSERT INTO Offer (Course_id, User_id)
VALUES
 (106, 3),  -- Khóa học 106 được người dùng 3 cung cấp
 (107, 4),  -- Khóa học 107 được người dùng 4 cung cấp
 (108, 4),  -- Khóa học 108 được người dùng 4 cung cấp
 (109, 5),  -- Khóa học 109 được người dùng 5 cung cấp
 (110, 5)  -- Khóa học 110 được người dùng 5 cung cấp
GO
INSERT INTO Offer (Course_id, User_id)
VALUES
(111, 6),
(112, 6),
(113, 7),
(114, 8),
(115, 9),
(116, 10),
(117, 11),
(118, 11),
(119, 12),
(120, 13),
(121, 14),
(122, 15),
(123, 15),
(124, 16),
(125, 17),
(126, 18),
(127, 18),
(128, 19),
(129, 20),
(130, 21)
GO
select * from [user]
select * from Course
-- Bảng Chapter (5 chương cho Course 101)
INSERT INTO Chapter (Chapter_id, Course_id, CName, CDescription)
VALUES
 (1,101,'Getting Started','Introduction to the course and setup'),
 (2,101,'Basics','Core programming concepts'),
 (3,101,'Control Flow','Conditional statements and loops'),
 (4,101,'Data Structures','Arrays, lists, and dictionaries'),
 (5,101,'Functions','Writing reusable code');
GO

-- Bảng Lesson (4 bài mỗi chương của Course 101)
INSERT INTO Lesson (Course_id, Chapter_id, Lesson_id, LName, LDescription, LType)
VALUES
 -- Chương 1
 (101,1,1,'Welcome','Course overview','Reading'),
 (101,1,2,'Environment Setup','Install tools','Video'),
 (101,1,3,'Hello Assignment','Write your first program','Assignment'),
 (101,1,4,'Intro Quiz','Test basic concepts','Quiz'),
 -- Chương 2
 (101,2,1,'Variables','Understanding variables','Reading'),
 (101,2,2,'Data Types','Different data types','Video'),
 (101,2,3,'Variables Assignment','Practice with variables','Assignment'),
 (101,2,4,'Variables Quiz','Quiz on variables','Quiz'),
 -- Chương 3
 (101,3,1,'If Statements','Conditionals explained','Reading'),
 (101,3,2,'Loops','For and while loops','Video'),
 (101,3,3,'Control Flow Assignment','Use loops and if','Assignment'),
 (101,3,4,'Control Flow Quiz','Test control flow','Quiz'),
 -- Chương 4
 (101,4,1,'Lists','Working with lists','Reading'),
 (101,4,2,'Dictionaries','Key-value pairs','Video'),
 (101,4,3,'Data Struct Assignment','Practice data structures','Assignment'),
 (101,4,4,'Data Struct Quiz','Quiz on data structures','Quiz'),
 -- Chương 5
 (101,5,1,'Functions','Defining functions','Reading'),
 (101,5,2,'Parameters','Function parameters','Video'),
 (101,5,3,'Functions Assignment','Build functions','Assignment'),
 (101,5,4,'Functions Quiz','Quiz on functions','Quiz');
GO
-- Bảng Chapter (5 chương cho Course 102)
INSERT INTO Chapter (Chapter_id, Course_id, CName, CDescription)
VALUES
 (1,102,'Getting Started','Introduction to the course and setup'),
 (2,102,'Basics','Core programming concepts'),
 (3,102,'Control Flow','Conditional statements and loops'),
 (4,102,'Data Structures','Arrays, lists, and dictionaries'),
 (5,102,'Functions','Writing reusable code');
GO
-- Bảng Lesson (4 bài mỗi chương của Course 102)
INSERT INTO Lesson (Course_id, Chapter_id, Lesson_id, LName, LDescription, LType)
VALUES
 -- Chương 1
 (102,1,1,'Welcome','Course overview','Reading'),
 (102,1,2,'Environment Setup','Install tools','Video'),
 (102,1,3,'Hello Assignment','Write your first program','Assignment'),
 (102,1,4,'Intro Quiz','Test basic concepts','Quiz'),
 -- Chương 2
 (102,2,1,'Variables','Understanding variables','Reading'),
 (102,2,2,'Data Types','Different data types','Video'),
 (102,2,3,'Variables Assignment','Practice with variables','Assignment'),
 (102,2,4,'Variables Quiz','Quiz on variables','Quiz'),
 -- Chương 3
 (102,3,1,'If Statements','Conditionals explained','Reading'),
 (102,3,2,'Loops','For and while loops','Video'),
 (102,3,3,'Control Flow Assignment','Use loops and if','Assignment'),
 (102,3,4,'Control Flow Quiz','Test control flow','Quiz'),
 -- Chương 4
 (102,4,1,'Lists','Working with lists','Reading'),
 (102,4,2,'Dictionaries','Key-value pairs','Video'),
 (102,4,3,'Data Struct Assignment','Practice data structures','Assignment'),
 (102,4,4,'Data Struct Quiz','Quiz on data structures','Quiz'),
 -- Chương 5
 (102,5,1,'Functions','Defining functions','Reading'),
 (102,5,2,'Parameters','Function parameters','Video'),
 (102,5,3,'Functions Assignment','Build functions','Assignment'),
 (102,5,4,'Functions Quiz','Quiz on functions','Quiz');
GO

-- Bảng Assignment
INSERT INTO Assignment (Course_id, Chapter_id, Lesson_id, Number_of_attempts, Number_of_days, Passing_score, Instruction)
VALUES
 (101,1,3,3,7,70,'Submit a console program that prints Hello World'),
 (101,2,3,3,7,70,'Create and use variables in code'),
 (101,3,3,3,7,70,'Implement a loop that sums numbers'),
 (101,4,3,3,7,70,'Use lists and dictionaries to store data'),
 (101,5,3,3,7,70,'Write a function with parameters');
GO

-- Bảng Quiz
INSERT INTO Quiz (Course_id, Chapter_id, Lesson_id, Number_of_attempts, Passing_score, Time_limit, Number_of_question)
VALUES
 (101,1,4,2,80,15,5),
 (101,2,4,2,80,15,5),
 (101,3,4,2,80,15,5),
 (101,4,4,2,80,15,5),
 (101,5,4,2,80,15,5);
GO

-- Bảng Video
INSERT INTO Video (Course_id, Chapter_id, Lesson_id, Video_link, Duration)
VALUES
 (101,1,2,'https://example.com/videos/setup.mp4',10),
 (101,2,2,'https://example.com/videos/datatypes.mp4',12),
 (101,3,2,'https://example.com/videos/loops.mp4',15),
 (101,4,2,'https://example.com/videos/dicts.mp4',14),
 (101,5,2,'https://example.com/videos/parameters.mp4',13);
GO

-- Bảng Reading
INSERT INTO Reading (Course_id, Chapter_id, Lesson_id, Link)
VALUES
 (101,1,1,'https://example.com/readings/welcome.html'),
 (101,2,1,'https://example.com/readings/variables.html'),
 (101,3,1,'https://example.com/readings/if_statements.html'),
 (101,4,1,'https://example.com/readings/lists.html'),
 (101,5,1,'https://example.com/readings/functions.html');
GO

-- Bảng Learn
INSERT INTO Learn (User_id, Course_id, Chapter_id, Lesson_id, status, score, attempt)
VALUES
 (1,101,1,1,'completed',100,1),
 (1,101,1,2,'completed', 95,1),
 (2,101,1,1,'completed',100,1),
 (3,101,2,1,'in-progress',NULL,1),
 (4,101,3,4,'not-started', NULL,1);
GO
select * from Learn
select * from Chapter
INSERT INTO Learn (User_id, Course_id, Chapter_id, Lesson_id, status, score, attempt)
VALUES
 (3,102,2,2,'in-progress',NULL,1),
 (4,102,3,1,'not-started', NULL,1);
GO

INSERT INTO Learn (User_id, Course_id, Chapter_id, Lesson_id, status, score, attempt)
VALUES
 (1,103,1,1,'completed',100,1),
 (1,103,1,2,'in-progress', NULL,1),
 (2,103,2,1,'completed',100,1),
 (3,103,2,2,'in-progress',NULL,1),
 (4,103,3,1,'not-started', NULL,1);
GO

-- Bảng Question
INSERT INTO Question (Question_id, Qtext, Qtype, Course_id, Chapter_id, Lesson_id)
VALUES
 (1001,'What does GETDATE() return?','TFQ',101,1,4),
 (1002,'Which keyword defines a function in Python?','MCQS',101,5,4),
 (1003,'What symbol denotes a list?','MCQS',101,4,4),
 (1004,'True or False: Python is statically typed.','TFQ',101,2,4),
 (1005,'Choose the correct loop structure for repeating code.','MCQS',101,3,4);
GO

-- Bảng Answer
INSERT INTO Answer (Answer_id, Question_id, Answer_text, is_correct)
VALUES
 (1,1001,'Current date and time',1),
 (2,1001,'Current username',0),
 (1,1002,'def',1),
 (2,1002,'function',0),
 (1,1003,'[]',1),
 (2,1003,'{}',0),
 (1,1004,'True',0),
 (2,1004,'False',1),
 (1,1005,'while',1),
 (2,1005,'if',0);
GO

-- Bảng Certificate
INSERT INTO Certificate (Certificate_id, Cer_name, Awarding_institution, Certificate_url, Course_id)
VALUES
 (1,'Programming Basics Certificate','Coursera','https://certs.example.com/1',101),
 (2,'Python Data Analysis Certificate','Coursera','https://certs.example.com/2',102),
 (3,'Financial Markets Certificate','Coursera','https://certs.example.com/3',103),
 (4,'Digital Painting Certificate','Coursera','https://certs.example.com/4',104),
 (5,'Calculus I Certificate','Coursera','https://certs.example.com/5',105);
GO

-- Bảng obtain_certificate
INSERT INTO obtain_certificate (Certificate_id, User_id, Issue_date)
VALUES
 (1,1,'2024-05-01'),
 (2,2,'2024-06-15'),
 (3,3,'2024-07-20'),
 (4,5,'2024-08-10'),
 (5,4,'2024-09-05');
GO

-- Bảng Coupon
INSERT INTO Coupon (Coupon_id, Coupon_code, Start_date, End_date, Discount_type, Discount_value, Coupon_type, Amount, Duration)
VALUES
 (1,'WELCOME10','2024-01-01','2024-12-31','Percentage',10,'NewUser',100,30),
 (2,'SPRING20','2024-03-01','2024-06-30','Fixed',20,'Seasonal',50,15),
 (3,'STUDENT5','2024-01-01','2024-12-31','Percentage',5,'Loyalty',200,60),
 (4,'SUMMER15','2024-06-01','2024-08-31','Percentage',15,'Seasonal',80,30),
 (5,'BLACKFRI','2024-11-20','2024-11-30','Percentage',25,'Promotion',150,10);
GO

-- Bảng [Order]
INSERT INTO [Order] (Order_id, User_id, Ord_status, Ord_date, Total_fee, Certificate_url)
VALUES
(1006,1,'Completed','2024-05-02',100,'https://orders.example.com/1006'),
(1007,2,'Completed','2024-06-16',150,NULL),
(1008,3,'Completed','2024-07-21',200,'https://orders.example.com/1008'),
(1009,4,'Completed','2024-08-01',80,NULL),
(1010,5,'Completed','2024-09-06',120,'https://orders.example.com/1010'),
(1011,6,'Pending','2024-10-10',90,NULL),
(1012,7,'Cancelled','2024-11-05',0,NULL),
(1013,5,'Completed','2024-12-20',300,'https://orders.example.com/1013'),
(1014,6,'Completed','2025-01-14',250,NULL),
(1015,7,'Completed','2025-02-18',180,'https://orders.example.com/1015'),

 (1001,1,'Completed','2024-05-02',100,'https://orders.example.com/1001'),
 (1002,2,'Pending','2024-06-16',150,NULL),
 (1003,3,'Completed','2024-07-21',200,'https://orders.example.com/1003'),
 (1004,4,'Cancelled','2024-08-01',80,NULL),
 (1005,5,'Completed','2024-09-06',120,'https://orders.example.com/1005');
GO
INSERT INTO [Order] (Order_id, User_id, Ord_status, Ord_date, Total_fee, Certificate_url)
VALUES
(1016, 8, 'Completed', '2025-03-01', 130, 'https://orders.example.com/1016'),
(1017, 9, 'Completed', '2025-03-05', 95, NULL),
(1018, 10, 'Completed', '2025-03-07', 145, 'https://orders.example.com/1018'),
(1019, 11, 'Completed', '2025-03-10', 180, NULL),
(1020, 12, 'Completed', '2025-03-11', 220, 'https://orders.example.com/1020'),
(1021, 13, 'Completed', '2025-03-12', 105, NULL),
(1022, 14, 'Completed', '2025-03-13', 170, 'https://orders.example.com/1022'),
(1023, 15, 'Completed', '2025-03-14', 200, NULL),
(1024, 16, 'Completed', '2025-03-15', 190, 'https://orders.example.com/1024'),
(1025, 17, 'Completed', '2025-03-16', 160, NULL),
(1026, 18, 'Completed', '2025-03-17', 175, 'https://orders.example.com/1026'),
(1027, 19, 'Completed', '2025-03-18', 150, NULL),
(1028, 20, 'Completed', '2025-03-19', 135, 'https://orders.example.com/1028'),
(1029, 21, 'Completed', '2025-03-20', 140, NULL),
(1030, 22, 'Completed', '2025-03-21', 115, 'https://orders.example.com/1030'),
(1031, 23, 'Completed', '2025-03-22', 125, NULL),
(1032, 24, 'Completed', '2025-03-23', 185, 'https://orders.example.com/1032'),
(1033, 25, 'Completed', '2025-03-24', 195, NULL),
(1034, 26, 'Completed', '2025-03-25', 210, 'https://orders.example.com/1034'),
(1035, 27, 'Completed', '2025-03-26', 175, NULL),
(1036, 1, 'Completed', '2025-03-27', 160, 'https://orders.example.com/1036'),
(1037, 2, 'Completed', '2025-03-28', 170, NULL),
(1038, 3, 'Completed', '2025-03-29', 180, 'https://orders.example.com/1038'),
(1039, 4, 'Completed', '2025-03-30', 190, NULL),
(1040, 5, 'Completed', '2025-03-31', 200, 'https://orders.example.com/1040'),
(1041, 6, 'Completed', '2025-04-01', 120, NULL),
(1042, 7, 'Completed', '2025-04-02', 130, 'https://orders.example.com/1042'),
(1043, 8, 'Completed', '2025-04-03', 140, NULL),
(1044, 9, 'Completed', '2025-04-04', 150, 'https://orders.example.com/1044'),
(1045, 10, 'Completed', '2025-04-05', 160, NULL);
GO
-- Thêm các đơn hàng vào bảng [Order]
INSERT INTO [Order] (Order_id, User_id, Ord_status, Ord_date, Total_fee, Certificate_url)
VALUES
(1046, 11, 'Completed', '2025-04-06', 100, 'https://orders.example.com/1046'),
(1047, 12, 'Completed', '2025-04-07', 110, 'https://orders.example.com/1047'),
(1048, 13, 'Completed', '2025-04-08', 120, NULL),
(1049, 14, 'Completed', '2025-04-09', 130, 'https://orders.example.com/1049'),
(1050, 15, 'Completed', '2025-04-10', 140, NULL),
(1051, 16, 'Completed', '2025-04-11', 150, 'https://orders.example.com/1051'),
(1052, 17, 'Completed', '2025-04-12', 160, NULL),
(1053, 18, 'Completed', '2025-04-13', 170, 'https://orders.example.com/1053'),
(1054, 19, 'Completed', '2025-04-14', 180, NULL),
(1055, 20, 'Completed', '2025-04-15', 190, 'https://orders.example.com/1055'),
(1056, 21, 'Completed', '2025-04-16', 200, NULL),
(1057, 22, 'Completed', '2025-04-17', 210, 'https://orders.example.com/1057'),
(1058, 23, 'Completed', '2025-04-18', 220, NULL),
(1059, 24, 'Completed', '2025-04-19', 230, 'https://orders.example.com/1059'),
(1060, 25, 'Completed', '2025-04-20', 240, NULL),
(1061, 26, 'Completed', '2025-04-21', 250, 'https://orders.example.com/1061'),
(1062, 27, 'Completed', '2025-04-22', 260, NULL);
GO
-- Bảng use_coupon
INSERT INTO use_coupon (Coupon_id, Order_id)
VALUES
 (1,1001),
 (2,1002),
 (3,1003),
 (4,1004),
 (1,1005);
GO

-- Bảng include_course
INSERT INTO include_course (Order_id, Course_id)
VALUES
 (1001,101),(1002,102),(1003,103),(1004,104),(1005,105),(1001, 106),(1002, 108),
 (1003, 107),(1003, 109),(1004, 110),(1005, 101),(1006, 106),(1006, 108),(1006, 110),
 (1007, 107),(1007, 102),(1008, 108),(1008, 109),(1009, 109),(1009, 103),(1010, 110),(1010, 101),(1010, 104);
INSERT INTO include_course (Order_id, Course_id)
VALUES
(1011, 102), (1011, 103),(1012, 104), (1012, 105),(1013, 106), (1013, 107), (1013, 108),(1014, 109), (1014, 110),(1015, 101), (1015, 102), (1015, 103),
(1016, 104), (1016, 105),(1017, 106), (1017, 108), (1017, 110),(1018, 107), (1018, 109),(1019, 103), (1019, 105),(1020, 101), (1020, 108),
(1021, 104),(1022, 110), (1022, 106),(1023, 107), (1023, 105), (1023, 103),(1024, 102), (1024, 104),(1025, 101), (1025, 109), (1025, 110),
(1026, 106),(1027, 103), (1027, 104),(1028, 108), (1028, 105),(1029, 101), (1029, 102), (1029, 107),(1030, 110), (1030, 109),(1031, 104), (1031, 108),
(1032, 106), (1032, 102), (1032, 101),(1033, 105), (1033, 107),(1034, 103), (1034, 109),(1035, 110), (1035, 104),(1036, 102), (1036, 105),
(1037, 106), (1037, 101), (1037, 103),(1038, 107), (1038, 108),(1039, 104), (1039, 102),(1040, 105), (1040, 109), (1040, 110),
(1041, 101),(1042, 103), (1042, 106),(1043, 108), (1043, 104),(1044, 102), (1044, 110),(1045, 105), (1045, 107), (1045, 109);
GO
INSERT INTO include_course (Order_id, Course_id)
VALUES
-- Order 1045 -> Courses 111, 112, 113
(1045, 111), (1045, 112), (1045, 113),
-- Order 1044 -> Courses 114, 115
(1044, 114), (1044, 115),
-- Order 1043 -> Courses 116, 117, 118
(1043, 116), (1043, 117), (1043, 118),
-- Order 1042 -> Courses 119, 120
(1042, 119), (1042, 120),
-- Order 1041 -> Courses 121, 122, 123
(1041, 121), (1041, 122), (1041, 123),
-- Order 1040 -> Courses 124, 125
(1040, 124), (1040, 125),
-- Order 1039 -> Courses 126, 127, 128
(1039, 126), (1039, 127), (1039, 128),
-- Order 1038 -> Courses 129, 130
(1038, 129), (1038, 130),
-- Order 1037 -> Courses 111, 113, 115
(1037, 111), (1037, 113), (1037, 115),
-- Order 1036 -> Courses 112, 114
(1036, 112), (1036, 114);
GO
INSERT INTO include_course (Order_id, Course_id)
VALUES
(1046, 109), (1046, 114), (1046, 120), -- Order 1046 với các khóa học 109, 114, 120
(1047, 121), (1047, 116), (1047, 119), -- Order 1047 với các khóa học 121, 116, 119
(1048, 124), (1048, 115), (1048, 129), -- Order 1048 với các khóa học 124, 115, 129
(1049, 130), (1049, 109), (1049, 116), -- Order 1049 với các khóa học 130, 109, 116
(1050, 114), (1050, 115), (1050, 120), -- Order 1050 với các khóa học 114, 115, 120
(1051, 121), (1051, 129), (1051, 119), -- Order 1051 với các khóa học 121, 129, 119
(1052, 130), (1052, 124), (1052, 115), -- Order 1052 với các khóa học 130, 124, 115
(1053, 116), (1053, 109), (1053, 120), -- Order 1053 với các khóa học 116, 109, 120
(1054, 121), (1054, 115), (1054, 129); -- Order 1054 với các khóa học 121, 115, 129
GO

-- Bảng Order_receipt
INSERT INTO Order_receipt (Receipt_id, Export_date, Total_fee, Order_id)
VALUES
 (5001,'2024-05-02',100,1001),
 (5002,'2024-06-16',150,1002),
 (5003,'2024-07-21',200,1003),
 (5004,'2024-08-01',80,1004),
 (5005,'2024-09-06',120,1005);
GO

-------------------------------------------------------------------------------------------------------------
-- 2. Viết các trigger, thủ tục, hàm (4 điểm) 
select * from [user]
select * from user_address
GO
-- 2.1
-- Stored procedure to insert a new user
CREATE OR ALTER PROCEDURE sp_InsertUser
    @id INT,
    @Email NVARCHAR(255),
    @FName NVARCHAR(100),
    @LName NVARCHAR(100),
    @Date_of_birth DATE,
    @Username NVARCHAR(100),
    @Password NVARCHAR(255),
    @Phone_number NVARCHAR(20),
    @Address1 NVARCHAR(255) = NULL,
    @Address2 NVARCHAR(255) = NULL,
    @Address3 NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required fields
    IF @id IS NULL OR @id = ''
    BEGIN
        RAISERROR('User ID cannot be null or empty', 16, 1);
        RETURN;
    END
    
    IF @Email IS NULL OR @Email = ''
    BEGIN
        RAISERROR('Email cannot be null or empty', 16, 1);
        RETURN;
    END
    
    IF @Username IS NULL OR @Username = ''
    BEGIN
        RAISERROR('Username cannot be null or empty', 16, 1);
        RETURN;
    END
    
    IF @Password IS NULL OR @Password = ''
    BEGIN
        RAISERROR('Password cannot be null or empty', 16, 1);
        RETURN;
    END
    
    -- Check if ID already exists
    IF EXISTS (SELECT 1 FROM [User] WHERE id = @id)
    BEGIN
        RAISERROR('User with ID %d already exists', 16, 1, @id);
        RETURN;
    END
    
    -- Check if Username already exists
    IF EXISTS (SELECT 1 FROM [User] WHERE Username = @Username)
    BEGIN
        RAISERROR('Username "%s" is already taken', 16, 1, @Username);
        RETURN;
    END
    
    -- Check email format
    IF @Email NOT LIKE '%_@__%.__%'
    BEGIN
        RAISERROR('Invalid email format: %s', 16, 1, @Email);
        RETURN;
    END
    
    -- Check password length
    IF LEN(@Password) < 8
    BEGIN
        RAISERROR('Password must be at least 8 characters long', 16, 1);
        RETURN;
    END
    
    -- Check age constraint
    IF @Date_of_birth IS NOT NULL AND DATEDIFF(YEAR, @Date_of_birth, GETDATE()) < 13
    BEGIN
        RAISERROR('User must be at least 13 years old', 16, 1);
        RETURN;
    END
    
    -- Insert new user
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert user
        INSERT INTO [User] (id, Email, FName, LName, Date_of_birth, Username, Password, Phone_number)
        VALUES (@id, @Email, @FName, @LName, @Date_of_birth, @Username, @Password, @Phone_number);
        -- Insert addresses if provided
        IF @Address1 IS NOT NULL AND @Address1 <> ''
        BEGIN
            INSERT INTO user_address (User_id, User_addr) VALUES (@id, @Address1);
        END
        
        IF @Address2 IS NOT NULL AND @Address2 <> ''
        BEGIN
            INSERT INTO user_address (User_id, User_addr) VALUES (@id, @Address2);
        END
        
        IF @Address3 IS NOT NULL AND @Address3 <> ''
        BEGIN
            INSERT INTO user_address (User_id, User_addr) VALUES (@id, @Address3);
        END

        COMMIT TRANSACTION;
        PRINT 'User inserted successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
-- Stored procedure to update a user
CREATE OR ALTER PROCEDURE sp_UpdateUser
    @id INT,
    @Email NVARCHAR(255) = NULL,
    @FName NVARCHAR(100) = NULL,
    @LName NVARCHAR(100) = NULL,
    @Date_of_birth DATE = NULL,
    @Username NVARCHAR(100) = NULL,
    @Password NVARCHAR(255) = NULL,
    @Phone_number NVARCHAR(20) = NULL,
    @Address1 NVARCHAR(255) = NULL,
    @Address2 NVARCHAR(255) = NULL,
    @Address3 NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE id = @id)
    BEGIN
        RAISERROR('User with ID %d does not exist', 16, 1, @id);
        RETURN;
    END
    
    -- Validate username uniqueness if changing it
    IF @Username IS NOT NULL AND LTRIM(RTRIM(@Username)) <> '' AND EXISTS (SELECT 1 FROM [User] WHERE Username = @Username AND id <> @id)
    BEGIN
        RAISERROR('Username "%s" is already taken', 16, 1, @Username);
        RETURN;
    END
    
    -- Check email format if provided
    IF @Email IS NOT NULL AND LTRIM(RTRIM(@Email)) <> '' AND @Email NOT LIKE '%_@__%.__%'
    BEGIN
        RAISERROR('Invalid email format: %s', 16, 1, @Email);
        RETURN;
    END
    
    -- Check password length if provided
    IF @Password IS NOT NULL AND LTRIM(RTRIM(@Password)) <> '' AND LEN(@Password) < 8
    BEGIN
        RAISERROR('Password must be at least 8 characters long', 16, 1);
        RETURN;
    END
    
    -- Check age constraint if provided
    IF @Date_of_birth IS NOT NULL AND DATEDIFF(YEAR, @Date_of_birth, GETDATE()) < 13
    BEGIN
        RAISERROR('User must be at least 13 years old', 16, 1);
        RETURN;
    END

    -- Build dynamic SQL for update
    DECLARE @SQL NVARCHAR(MAX) = 'UPDATE [User] SET Updated_at = GETDATE()';
    
    IF @Email IS NOT NULL AND LTRIM(RTRIM(@Email)) <> ''
        SET @SQL = @SQL + ', Email = @Email';
    IF @FName IS NOT NULL AND LTRIM(RTRIM(@FName)) <> ''
        SET @SQL = @SQL + ', FName = @FName';
    IF @LName IS NOT NULL AND LTRIM(RTRIM(@LName)) <> ''
        SET @SQL = @SQL + ', LName = @LName';
    IF @Date_of_birth IS NOT NULL
        SET @SQL = @SQL + ', Date_of_birth = @Date_of_birth';
    IF @Username IS NOT NULL AND LTRIM(RTRIM(@Username)) <> ''
        SET @SQL = @SQL + ', Username = @Username';
    IF @Password IS NOT NULL AND LTRIM(RTRIM(@Password)) <> ''
        SET @SQL = @SQL + ', Password = @Password';
    IF @Phone_number IS NOT NULL AND LTRIM(RTRIM(@Phone_number)) <> ''
        SET @SQL = @SQL + ', Phone_number = @Phone_number';
    
    SET @SQL = @SQL + ' WHERE id = @id';
    
    -- Execute update
    BEGIN TRY
		BEGIN TRANSACTION

        EXEC sp_executesql @SQL, 
            N'@id INT, @Email NVARCHAR(255), @FName NVARCHAR(100), @LName NVARCHAR(100), 
              @Date_of_birth DATE, @Username NVARCHAR(100), @Password NVARCHAR(255), @Phone_number NVARCHAR(20)',
            @id, @Email, @FName, @LName, @Date_of_birth, @Username, @Password, @Phone_number;
        -- Delete existing addresses for this user
        DELETE FROM user_address WHERE User_id = @id;
        
        -- Add new addresses if provided
        IF @Address1 IS NOT NULL AND @Address1 <> ''
        BEGIN
            INSERT INTO user_address (User_id, User_addr) VALUES (@id, @Address1);
        END
        
        IF @Address2 IS NOT NULL AND @Address2 <> ''
        BEGIN
            INSERT INTO user_address (User_id, User_addr) VALUES (@id, @Address2);
        END
        
        IF @Address3 IS NOT NULL AND @Address3 <> ''
        BEGIN
            INSERT INTO user_address (User_id, User_addr) VALUES (@id, @Address3);
        END
        PRINT 'User updated successfully';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Stored procedure to delete a user
CREATE OR ALTER PROCEDURE sp_DeleteUser
    @id INT,
    @ForceDelete BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE id = @id)
    BEGIN
        RAISERROR('User with ID %d does not exist', 16, 1, @id);
        RETURN;
    END
    
    -- Chỉ cần kiểm tra các phụ thuộc còn lại không có CASCADE
    IF @ForceDelete = 0
    BEGIN
        -- Check for dependencies in Offer table
        IF EXISTS (SELECT 1 FROM Offer WHERE user_id = @id)
        BEGIN
            RAISERROR('Cannot delete user with ID %d: User has offered courses. Use force = 1 to delete anyway.', 16, 1, @id);
            RETURN;
        END
        
        -- Check for dependencies in Order table
        IF EXISTS (SELECT 1 FROM [Order] WHERE User_id = @id)
        BEGIN
            RAISERROR('Cannot delete user with ID %d: User has orders. Use force = 1 to delete anyway.', 16, 1, @id);
            RETURN;
        END
    END
    
    -- Delete user and handle dependencies
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Luôn xóa các bản ghi follow trước khi xóa User
        DELETE FROM follow WHERE User_id = @id OR Follower_id = @id;
        
        -- Xử lý các phụ thuộc không có CASCADE nếu ForceDelete = 1
        IF @ForceDelete = 1
        BEGIN
            -- Xử lý orders và các bảng liên quan
            DECLARE @OrderIds TABLE (OrderId INT);
            INSERT INTO @OrderIds SELECT Order_id FROM [Order] WHERE User_id = @id;
            
            -- Xóa liên kết với mã giảm giá
            DELETE FROM use_coupon WHERE Order_id IN (SELECT OrderId FROM @OrderIds);
            
            -- Xóa liên kết với khóa học
            DELETE FROM include_course WHERE Order_id IN (SELECT OrderId FROM @OrderIds);
            
            -- Xóa hóa đơn
            DELETE FROM Order_receipt WHERE Order_id IN (SELECT OrderId FROM @OrderIds);
            
            -- Xóa đơn hàng
            DELETE FROM [Order] WHERE User_id = @id;
            
            -- Xử lý khóa học do người dùng cung cấp
            DELETE FROM Offer WHERE user_id = @id;
        END
        
        -- Xóa người dùng - các phụ thuộc với CASCADE sẽ tự động bị xóa
        DELETE FROM [User] WHERE id = @id;
        
        COMMIT TRANSACTION;
        
        IF @ForceDelete = 1
            PRINT 'User and all associated data deleted successfully';
        ELSE
            PRINT 'User deleted successfully. All CASCADE related data was automatically removed.';
            
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Test Testcase cho sp_InsertUser
-- 1. Thêm người dùng mới thành công với đầy đủ thông tin
BEGIN TRANSACTION;
PRINT '-------------- TEST 1: Insert new user with all information --------------';
EXEC sp_InsertUser 
    @id = 10000, 
    @Email = 'jennifer.nguyen@example.com', 
    @FName = 'Jennifer', 
    @LName = 'Nguyen', 
    @Date_of_birth = '1992-08-25', 
    @Username = 'jennifer92', 
    @Password = 'Secure@Pass2025', 
    @Phone_number = '0912345678',
    @Address1 = '123 Riverview Apartments, District 2, HCMC',
    @Address2 = '45 Garden Street, District 7, HCMC',
    @Address3 = '78 Mountain Road, Dalat City';

-- Kiểm tra user đã được thêm thành công
SELECT * FROM [User] WHERE id = 10000;
SELECT * FROM user_address WHERE User_id = 10000;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 1 --------------';

-- 2. Thêm người dùng với thông tin tối thiểu (không có địa chỉ)
BEGIN TRANSACTION;
PRINT '-------------- TEST 2: Insert user with minimum information --------------';
EXEC sp_InsertUser 
    @id = 111, 
    @Email = 'thomas.le@example.com', 
    @FName = 'Thomas', 
    @LName = 'Le', 
    @Date_of_birth = '1995-05-10', 
    @Username = 'thomas95', 
    @Password = 'ThomasSecure@123', 
    @Phone_number = '0901234567';

-- Kiểm tra user đã được thêm thành công
SELECT * FROM [User] WHERE id = 111;
SELECT * FROM user_address WHERE User_id = 111;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 2 --------------';

-- 3. Thêm người dùng với ID đã tồn tại (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 3: Insert user with existing ID (expected error) --------------';
EXEC sp_InsertUser 
    @id = 1, -- ID này thuộc về Alice Nguyen
    @Email = 'linda.pham@example.com', 
    @FName = 'Linda', 
    @LName = 'Pham', 
    @Date_of_birth = '1993-12-15', 
    @Username = 'linda93', 
    @Password = 'LindaPa$$w0rd', 
    @Phone_number = '0912345678';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 3 --------------';

-- 4. Thêm người dùng với Username đã tồn tại (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 4: Insert user with existing username (expected error) --------------';
EXEC sp_InsertUser 
    @id = 121, 
    @Email = 'richard.tran@example.com', 
    @FName = 'Richard', 
    @LName = 'Tran', 
    @Date_of_birth = '1990-07-15', 
    @Username = 'alice9090', -- Username này đã tồn tại
    @Password = 'RichardP@ss123', 
    @Phone_number = '0945678901';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 4 --------------';

-- 5. Thêm người dùng với email không đúng định dạng (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 5: Insert user with invalid email format (expected error) --------------';
EXEC sp_InsertUser 
    @id = 133, 
    @Email = 'invalid-email', 
    @FName = 'Susan', 
    @LName = 'Hoang', 
    @Date_of_birth = '1998-03-25', 
    @Username = 'susan98', 
    @Password = 'Susan$ecurePass', 
    @Phone_number = '0956789012';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 5 --------------';

-- 6. Thêm người dùng với mật khẩu quá ngắn (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 6: Insert user with short password (expected error) --------------';
EXEC sp_InsertUser 
    @id = 144, 
    @Email = 'peter.nguyen@example.com', 
    @FName = 'Peter', 
    @LName = 'Nguyen', 
    @Date_of_birth = '1996-02-28', 
    @Username = 'peter96', 
    @Password = 'short', -- Mật khẩu quá ngắn
    @Phone_number = '0967890123';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 6 --------------';

-- 7. Thêm người dùng chưa đủ tuổi (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 7: Insert underage user (expected error) --------------';
EXEC sp_InsertUser 
    @id = 155, 
    @Email = 'young.student@example.com', 
    @FName = 'Young', 
    @LName = 'Student', 
    @Date_of_birth = '2015-01-01', -- Người dùng mới 10 tuổi vào năm 2025
    @Username = 'young_student', 
    @Password = 'StudentSecure@123', 
    @Phone_number = '0978901234';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 7 --------------';


-- Testcase cho sp_UpdateUser
-- 8. Cập nhật thông tin cơ bản của người dùng
BEGIN TRANSACTION;
PRINT '-------------- TEST 8: Update basic user information --------------';
EXEC sp_UpdateUser 
    @id = 3, 
    @Email = 'charlie.updated@example.com', 
    @Phone_number = '0923456789', 
    @FName = 'Charles';

-- Kiểm tra thông tin đã được cập nhật
SELECT id, Email, FName, Phone_number FROM [User] WHERE id = 3;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 8 --------------';

-- 9. Cập nhật thông tin và địa chỉ của người dùng
BEGIN TRANSACTION;
PRINT '-------------- TEST 9: Update user information and addresses --------------';
EXEC sp_UpdateUser 
    @id = 4, 
    @LName = 'Pham-Tran', 
    @Password = 'NewSecureP@ss456',
    @Address1 = '100 Park Avenue, District 1, HCMC',
    @Address2 = '25 Riverside Drive, District 2, HCMC';

-- Kiểm tra thông tin đã được cập nhật
SELECT id, LName, Password FROM [User] WHERE id = 4;
SELECT User_id, User_addr FROM user_address WHERE User_id = 4;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 9 --------------';

-- 10. Cập nhật người dùng không tồn tại (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 10: Update non-existent user (expected error) --------------';
EXEC sp_UpdateUser 
    @id = 99999, 
    @Email = 'nonexistent@example.com';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 10 --------------';

-- 11. Cập nhật username trùng với người dùng khác (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 11: Update to existing username (expected error) --------------';
EXEC sp_UpdateUser 
    @id = 5, 
    @Username = 'bob85'; -- Username này đã thuộc về Bob

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 11 --------------';

-- 12. Cập nhật email không hợp lệ (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 12: Update with invalid email (expected error) --------------';
EXEC sp_UpdateUser 
    @id = 1, 
    @Email = 'not-an-email';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 12 --------------';

-- 13. Cập nhật mật khẩu quá ngắn (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 13: Update with short password (expected error) --------------';
EXEC sp_UpdateUser 
    @id = 2, 
    @Password = '123';

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 13 --------------';

-- 14. Cập nhật ngày sinh khiến người dùng chưa đủ tuổi (kỳ vọng lỗi)
BEGIN TRANSACTION;
PRINT '-------------- TEST 14: Update to underage (expected error) --------------';
EXEC sp_UpdateUser 
    @id = 3, 
    @Date_of_birth = '2018-01-01'; -- Chỉ mới 7 tuổi vào năm 2025

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 14 --------------';



-- Testcase cho sp_DeleteUser
-- 15. Xóa người dùng cơ bản (không có phụ thuộc phức tạp)
BEGIN TRANSACTION;
PRINT '-------------- TEST 15: Delete basic user --------------';
-- Thêm người dùng mới để test xóa
EXEC sp_InsertUser 
    @id = 200, 
    @Email = 'temp.user@example.com', 
    @FName = 'Temp', 
    @LName = 'User', 
    @Date_of_birth = '1990-01-01', 
    @Username = 'tempuser', 
    @Password = 'Temporary@123', 
    @Phone_number = '0912345678',
    @Address1 = '123 Test Street, District 1, HCMC';
    
-- Kiểm tra người dùng đã được tạo
SELECT * FROM [User] WHERE id = 200;
SELECT * FROM user_address WHERE User_id = 200;

-- Xóa người dùng
EXEC sp_DeleteUser @id = 200;

-- Kiểm tra người dùng và dữ liệu liên quan đã bị xóa
SELECT * FROM [User] WHERE id = 200;
SELECT * FROM user_address WHERE User_id = 200;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 15 --------------';

-- 16. Xóa người dùng có khóa học đã cung cấp (kỳ vọng lỗi khi không có ForceDelete)
BEGIN TRANSACTION;
PRINT '-------------- TEST 16: Delete user with offered courses (expected error without ForceDelete) --------------';
-- Kiểm tra xem Bob (id = 2) có cung cấp khóa học nào không
SELECT * FROM Offer WHERE user_id = 2;

-- Thử xóa người dùng mà không dùng ForceDelete
EXEC sp_DeleteUser @id = 2;

-- Kiểm tra người dùng vẫn tồn tại
SELECT * FROM [User] WHERE id = 2;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 16 --------------';

-- 17. Xóa người dùng có đơn hàng (kỳ vọng lỗi khi không có ForceDelete)
BEGIN TRANSACTION;
PRINT '-------------- TEST 17: Delete user with orders (expected error without ForceDelete) --------------';
-- Kiểm tra xem Alice (id = 1) có đơn hàng nào không
SELECT * FROM [Order] WHERE User_id = 1;

-- Thử xóa người dùng mà không dùng ForceDelete
EXEC sp_DeleteUser @id = 1;

-- Kiểm tra người dùng vẫn tồn tại
SELECT * FROM [User] WHERE id = 1;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 17 --------------';

-- 18. Xóa người dùng có khóa học đã cung cấp với ForceDelete
BEGIN TRANSACTION;
PRINT '-------------- TEST 18: Delete user with offered courses using ForceDelete --------------';
-- Kiểm tra Bob và các khóa học của anh ấy trước khi xóa
SELECT * FROM [User] WHERE id = 2;
SELECT * FROM Offer WHERE user_id = 2;
SELECT * FROM follow WHERE User_id = 2 OR Follower_id = 2;

-- Xóa với ForceDelete
EXEC sp_DeleteUser @id = 2, @ForceDelete = 1;

-- Kiểm tra người dùng và dữ liệu liên quan đã bị xóa
SELECT * FROM [User] WHERE id = 2;
SELECT * FROM Offer WHERE user_id = 2;
SELECT * FROM follow WHERE User_id = 2 OR Follower_id = 2;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 18 --------------';

-- 19. Xóa người dùng có đơn hàng với ForceDelete
BEGIN TRANSACTION;
PRINT '-------------- TEST 19: Delete user with orders using ForceDelete --------------';
-- Kiểm tra Alice và các đơn hàng của cô ấy trước khi xóa
SELECT * FROM [User] WHERE id = 1;
SELECT * FROM [Order] WHERE User_id = 1;
SELECT o.Order_id, uc.Coupon_id FROM [Order] o
JOIN use_coupon uc ON o.Order_id = uc.Order_id
WHERE o.User_id = 1;

-- Xóa với ForceDelete
EXEC sp_DeleteUser @id = 1, @ForceDelete = 1;

-- Kiểm tra người dùng và dữ liệu liên quan đã bị xóa
SELECT * FROM [User] WHERE id = 1;
SELECT * FROM [Order] WHERE User_id = 1;
SELECT o.Order_id, uc.Coupon_id FROM [Order] o
JOIN use_coupon uc ON o.Order_id = uc.Order_id
WHERE o.User_id = 1;

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 19 --------------';

-- 20. Thử xóa người dùng không tồn tại
BEGIN TRANSACTION;
PRINT '-------------- TEST 20: Delete non-existent user (expected error) --------------';
EXEC sp_DeleteUser @id = 99999;
ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 20 --------------';

-- 21. Kiểm tra CASCADE tự động xóa dữ liệu phụ thuộc
BEGIN TRANSACTION;
PRINT '-------------- TEST 21: Verify CASCADE automatic deletion --------------';

-- Tạo dữ liệu test cho người dùng mới
EXEC sp_InsertUser 
    @id = 30, 
    @Email = 'cascade.test@example.com', 
    @FName = 'Cascade', 
    @LName = 'Test', 
    @Date_of_birth = '1995-05-05', 
    @Username = 'cascadetest', 
    @Password = 'Cascade@Test123', 
    @Phone_number = '0912345678',
    @Address1 = '123 Test Street, HCMC';

-- Thêm vai trò cho người dùng này (phụ thuộc CASCADE)
INSERT INTO has_role (User_id, Role_id) VALUES (30, 3);

-- Thêm đánh giá khóa học (phụ thuộc CASCADE)
--INSERT INTO review_course (User_id, Course_id, Comment, Date, Rating_score)
--VALUES (30, 101, 'This is a test review', GETDATE(), 4.5);

-- Kiểm tra dữ liệu đã được tạo
SELECT * FROM [User] WHERE id = 30;
SELECT * FROM user_address WHERE User_id = 30;
SELECT * FROM has_role WHERE User_id = 30;
SELECT * FROM review_course WHERE User_id = 30;

-- Xóa người dùng (không cần ForceDelete vì không có phụ thuộc phức tạp)
EXEC sp_DeleteUser @id = 30;

-- Kiểm tra người dùng và tất cả dữ liệu phụ thuộc đã bị xóa
SELECT * FROM [User] WHERE id = 30;
SELECT * FROM user_address WHERE User_id = 30; -- Nên bị xóa bởi CASCADE
SELECT * FROM has_role WHERE User_id = 30; -- Nên bị xóa bởi CASCADE
SELECT * FROM review_course WHERE User_id = 30; -- Nên bị xóa bởi CASCADE

ROLLBACK TRANSACTION;
PRINT '-------------- END TEST 21 --------------';

GO
-- 2.2
-- Trigger 1
-- update Rating from user --
CREATE OR ALTER TRIGGER trg_Update_Course_Rating
ON review_course
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @AffectedCourses TABLE (Course_id INT);

    INSERT INTO @AffectedCourses(Course_id)
    SELECT Course_id FROM INSERTED
    UNION
    SELECT Course_id FROM DELETED;

    UPDATE C
    SET C.Rating = (
        SELECT AVG(Rating_score)
        FROM review_course
        WHERE Course_id = C.id
    )
    FROM Course C
    WHERE C.id IN (SELECT Course_id FROM @AffectedCourses);
END;
GO

-- Test Trigger 1
-- STEP 0: Setup - Insert test user and course if not already present
IF NOT EXISTS (SELECT 1 FROM [User] WHERE id = 99)
    INSERT INTO [User] (id, Email, FName, LName, Date_of_birth, Username, Password)
    VALUES (99, 'testuser@example.com', 'Test', 'User', '2000-01-01', 'testuser99', 'TestPass99!');

IF NOT EXISTS (SELECT 1 FROM Course WHERE id = 999)
    INSERT INTO Course (id, CName, CDescription, Outcome_info, Fee, Enrollment_count, Rating)
    VALUES (999, 'Test Course', 'Test description', 'Test outcome', 100, 0, 0.0);

-- STEP 1: Add a single review
PRINT 'Step 1: Add 1st review - Expect rating = 4.0';
INSERT INTO review_course (User_id, Course_id, Comment, Rating_score)
VALUES (99, 999, 'Good course', 4.0);

SELECT Rating AS CurrentRating FROM Course WHERE id = 999;

-- STEP 2: Add another review to same course
PRINT 'Step 2: Add 2nd review - Expect rating = (4.0 + 5.0) / 2 = 4.5';
INSERT INTO review_course (User_id, Course_id, Comment, Rating_score)
VALUES (1, 999, 'Excellent', 5.0);

SELECT Rating AS CurrentRating FROM Course WHERE id = 999;

-- STEP 3: Update first review score
PRINT 'Step 3: Update 1st review to 3.0 - Expect rating = (3.0 + 5.0) / 2 = 4.0';
UPDATE review_course
SET Rating_score = 3.0
WHERE User_id = 99 AND Course_id = 999;

SELECT Rating AS CurrentRating FROM Course WHERE id = 999;

-- STEP 4: Delete second review
PRINT 'Step 4: Delete 2nd review - Expect rating = 3.0 (only one review left)';
DELETE FROM review_course
WHERE User_id = 1 AND Course_id = 999;

SELECT Rating AS CurrentRating FROM Course WHERE id = 999;

-- STEP 5: Delete last review - Expect rating = NULL
PRINT 'Step 5: Delete last review - Expect rating = NULL';
DELETE FROM review_course
WHERE User_id = 99 AND Course_id = 999;

SELECT Rating AS CurrentRating FROM Course WHERE id = 999;

GO
-- Trigger 2
-- update TotalFee from Course --
CREATE OR ALTER TRIGGER trg_Update_TotalFee
ON include_course
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @Order_id INT;
    DECLARE @TotalFee INT;

    -- Handle INSERT
    IF EXISTS (SELECT * FROM INSERTED)
        SELECT @Order_id = Order_id FROM INSERTED;
    ELSE
        SELECT @Order_id = Order_id FROM DELETED;

    SELECT @TotalFee = SUM(C.Fee)
    FROM include_course IC
    JOIN Course C ON IC.Course_id = C.id 
    WHERE IC.Order_id = @Order_id;

    SET @TotalFee = ISNULL(@TotalFee, 0);  

    DECLARE @FixedDiscount INT = 0;

    SELECT @FixedDiscount = ISNULL(SUM(c.Discount_value), 0)
    FROM use_coupon uc 
    JOIN Coupon c ON uc.Coupon_id = c.Coupon_id
    WHERE uc.Order_id = @Order_id
      AND c.End_date >= GETDATE()
      AND c.Discount_type = 'Fixed'
      AND c.Amount > 0;
    
    SET @TotalFee = @TotalFee - @FixedDiscount;

    IF @TotalFee < 0
        SET @TotalFee = 0;

    DECLARE @PercentageDiscount INT = 0;

    SELECT @PercentageDiscount = ISNULL(SUM(c.Discount_value), 0)
    FROM use_coupon uc 
    JOIN Coupon C ON uc.Coupon_id = c.Coupon_id
    WHERE uc.Order_id = @Order_id
      AND c.End_date >= GETDATE()
      AND c.Discount_type = 'Percentage'
      AND c.Amount > 0;

    IF @PercentageDiscount > 0
    BEGIN 
        SET @TotalFee = @TotalFee * (100 - @PercentageDiscount) / 100;
    END
    IF @TotalFee < 0 
        SET @TotalFee = 0;

    UPDATE [Order]
    SET Total_fee = @TotalFee
    WHERE Order_id = @Order_id;
END;
GO

-- Adding for use_coupon table --
CREATE OR ALTER TRIGGER trg_Update_TotalFee_UseCoupon
ON use_coupon
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @Order_id INT;
    DECLARE @TotalFee INT;

    -- Determine affected Order_id
    IF EXISTS (SELECT * FROM INSERTED)
        SELECT @Order_id = Order_id FROM INSERTED;
    ELSE
        SELECT @Order_id = Order_id FROM DELETED;

    -- Sum course fees for the order
    SELECT @TotalFee = SUM(C.Fee)
    FROM include_course IC
    JOIN Course C ON IC.Course_id = C.id 
    WHERE IC.Order_id = @Order_id;

    SET @TotalFee = ISNULL(@TotalFee, 0);  

    -- Apply fixed discounts
    DECLARE @FixedDiscount INT = 0;
    SELECT @FixedDiscount = ISNULL(SUM(c.Discount_value), 0)
    FROM use_coupon uc 
    JOIN Coupon c ON uc.Coupon_id = c.Coupon_id
    WHERE uc.Order_id = @Order_id
      AND c.End_date >= GETDATE()
      AND c.Discount_type = 'Fixed'
      AND c.Amount > 0;
    
    SET @TotalFee = @TotalFee - @FixedDiscount;
    IF @TotalFee < 0 SET @TotalFee = 0;

    -- Apply percentage discounts
    DECLARE @PercentageDiscount INT = 0;
    SELECT @PercentageDiscount = ISNULL(SUM(c.Discount_value), 0)
    FROM use_coupon uc 
    JOIN Coupon c ON uc.Coupon_id = c.Coupon_id
    WHERE uc.Order_id = @Order_id
      AND c.End_date >= GETDATE()
      AND c.Discount_type = 'Percentage'
      AND c.Amount > 0;

    IF @PercentageDiscount > 0
        SET @TotalFee = @TotalFee * (100 - @PercentageDiscount) / 100;

    IF @TotalFee < 0 SET @TotalFee = 0;

    -- Update total fee in Order
    UPDATE [Order]
    SET Total_fee = @TotalFee
    WHERE Order_id = @Order_id;
END;
GO
-- testing 2 triggers

INSERT INTO [Order] (Order_id, User_id, Ord_status, Total_fee)
VALUES (9999, 1, 'Pending', 0);

-- STEP 1: Insert test coupons if not already present
IF NOT EXISTS (SELECT 1 FROM Coupon WHERE Coupon_id = 8)
BEGIN
    INSERT INTO Coupon (Coupon_id, Coupon_code, Start_date, End_date, Discount_type, Discount_value, Coupon_type, Amount, Duration)
    VALUES (8, 'TESTFIXED', '2025-01-01', '2025-12-31', 'Fixed', 50, 'Manual', 100, 10);
END;

IF NOT EXISTS (SELECT 1 FROM Coupon WHERE Coupon_id = 9)
BEGIN
    INSERT INTO Coupon (Coupon_id, Coupon_code, Start_date, End_date, Discount_type, Discount_value, Coupon_type, Amount, Duration)
    VALUES (9, 'TESTPERCENT', '2025-01-01', '2025-12-31', 'Percentage', 20, 'Manual', 100, 10);
END;

select * from [Order] where Order_id = 9999

-- STEP 2: Add Course 101 ($100) to test order
PRINT 'Step 2 - Added Course 101';
INSERT INTO include_course (Order_id, Course_id) VALUES (9999, 101);
SELECT * FROM [Order] WHERE Order_id = 9999;

-- STEP 3: Add Course 102 ($150) => Total fee = 250
PRINT 'Step 3 - Added Course 102';
INSERT INTO include_course (Order_id, Course_id) VALUES (9999, 102);
SELECT * FROM [Order] WHERE Order_id = 9999;

-- STEP 4: Apply fixed coupon ($50 off) => Total fee = 200
PRINT 'Step 4 - Applied Fixed Coupon';
INSERT INTO use_coupon (Coupon_id, Order_id) VALUES (8, 9999);
SELECT * FROM [Order] WHERE Order_id = 9999;

-- STEP 5: Apply percentage coupon (20% off) => Total fee = 160
PRINT 'Step 5 - Applied Percentage Coupon';
INSERT INTO use_coupon (Coupon_id, Order_id) VALUES (9, 9999);
SELECT * FROM [Order] WHERE Order_id = 9999;

-- STEP 6: Remove Course 101 ($100) => Fee = (250 - 100) = 150 → -50 = 100 → *0.8 = 80
PRINT 'Step 6 - Removed Course 101';
DELETE FROM include_course WHERE Order_id = 9999 AND Course_id = 101;
SELECT * FROM [Order] WHERE Order_id = 9999;

-- STEP 7: Remove fixed coupon => Fee = 150 * 0.8 = 120
PRINT 'Step 7 - Removed Fixed Coupon';
DELETE FROM use_coupon WHERE Order_id = 9999 AND Coupon_id = 8;
SELECT * FROM [Order] WHERE Order_id = 9999;

-- STEP 8: Remove percentage coupon => Fee = 150
PRINT 'Step 8 - Removed Percentage Coupon';
DELETE FROM use_coupon WHERE Order_id = 9999 AND Coupon_id = 9;
SELECT * FROM [Order] WHERE Order_id = 9999;

SELECT * FROM [Order] WHERE Order_id = 1002;
select * from include_course
select * from Course
select * from Coupon
select * from use_coupon
delete from use_coupon where Order_id = 9999

GO
-- 2.3
-- Procedure 1
CREATE OR ALTER PROCEDURE sp_GetTopRatedCoursesWithFilter
    @SubjectKeyword NVARCHAR(100) = NULL,
    @CourseKeyword NVARCHAR(255) = NULL,
    @MinRating DECIMAL(2,1) = 0.0,
	@MinFee INT = 0,
    @MaxFee INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CName AS CourseName,
        c.Rating AS AvgRating,
        u.FName + ' ' + u.LName AS OfferedBy,
        c.Enrollment_count AS NumCompletedOrders,
        c.Fee,
        COUNT(DISTINCT rc.User_id) AS ReviewCount
    FROM 
        Course c
        INNER JOIN has_course hc ON hc.Course_id = c.id
        INNER JOIN Subject s ON hc.Subject_id = s.id
        INNER JOIN Offer ofr ON ofr.Course_id = c.id
        INNER JOIN [User] u ON ofr.user_id = u.id
        LEFT JOIN review_course rc ON rc.Course_id = c.id
    WHERE 
        (@SubjectKeyword IS NULL OR @SubjectKeyword = '' OR s.SName LIKE '%' + @SubjectKeyword + '%')
        AND (@CourseKeyword IS NULL OR @CourseKeyword = '' OR c.CName LIKE '%' + @CourseKeyword + '%')
        AND c.Rating >= @MinRating
		AND c.Fee >= @MinFee
        AND (@MaxFee IS NULL OR c.Fee <= @MaxFee)
    GROUP BY 
        c.CName, u.FName, u.LName, c.Rating, c.Enrollment_count, c.Fee
    ORDER BY 
        AvgRating DESC;
END;
GO


EXEC sp_GetTopRatedCoursesWithFilter;
EXEC sp_GetTopRatedCoursesWithFilter 
    @SubjectKeyword = 'Web Development',
    @CourseKeyword = 'UI',
    @MinRating = 3.7,
    @MinFee = 100,
    @MaxFee = 500;
EXEC sp_GetTopRatedCoursesWithFilter @MinRating = 4.0;
EXEC sp_GetTopRatedCoursesWithFilter 
    @SubjectKeyword = 'Cybersecurity', 
    @CourseKeyword = 'Calculus I',
    @MinRating = 3.5;


select * FROM Course
select * FROM has_course
select * FROM Subject
select * FROM [user]
select * FROM Offer
select * FROM include_course
select * FROM [Order]
select * FROM review_course


GO
-- Procedure 2
CREATE OR ALTER PROCEDURE sp_GetInstructorStats
    @MinFollowers   INT           = 0,      
    @MinAvgRating   DECIMAL(3,1)  = 0.0     
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.id                         AS InstructorId,
        u.Username                   AS InstructorName,
        COUNT(DISTINCT f.Follower_id)    AS FollowerCount,
        COUNT(DISTINCT o.Course_id)       AS NumCoursesOffered,
        ROUND(AVG(c.Rating),1)           AS AvgCourseRating
    FROM [User] u
    INNER JOIN has_role hr ON u.id = hr.User_id
    INNER JOIN role r ON hr.Role_id = r.id
    LEFT JOIN follow f ON u.id = f.User_id
    LEFT JOIN Offer o ON u.id = o.User_id
    LEFT JOIN Course c ON o.Course_id = c.id
    WHERE r.RName = 'Instructor'
    GROUP BY u.id, u.Username
    HAVING
        COUNT(DISTINCT f.Follower_id) >= @MinFollowers
        AND AVG(c.Rating)              >= @MinAvgRating
    ORDER BY
        AvgCourseRating   DESC,
        FollowerCount     DESC;
END;
GO

select * from has_role
select * from role
select distinct user_id from Offer
EXEC sp_GetInstructorStats
     @MinFollowers = 0,
     @MinAvgRating = 0.0;
GO

EXEC sp_GetInstructorStats
     @MinFollowers = 2,
     @MinAvgRating = 0.0;
GO

-- 2.4
-- Function 1

CREATE OR ALTER FUNCTION getComplete
(
    @user_id INT,
	@threshold FLOAT
)
RETURNS @Result TABLE
(
	u_id INT,
    course_id INT,
	current_process FLOAT
)
AS
BEGIN
	-- ktra id đúng format chưa
    IF @user_id <= 0 
        RETURN;

    DECLARE @course_id INT;
    DECLARE @total INT;
    DECLARE @done INT;
	DECLARE @cur_rate FLOAT;

    DECLARE cur CURSOR FOR
        SELECT DISTINCT course_id FROM Learn WHERE user_id = @user_id;

    OPEN cur;
    FETCH NEXT FROM cur INTO @course_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN

		SELECT @total = COUNT(*)
		FROM (SELECT DISTINCT Chapter_id, Lesson_id as total
					--FROM Learn
					FROM Lesson
					WHERE course_id = @course_id) as SUB;

		SELECT @done = COUNT(*)
		FROM (
			SELECT DISTINCT Course_id, Chapter_id, Lesson_id
			FROM Learn
			WHERE course_id = @course_id 
				AND user_id = @user_id 
				AND status = 'completed'
		) AS completed_lessons;

		SET @cur_rate = CAST(@done AS FLOAT) / @total;
        IF @cur_rate >= @threshold
        BEGIN
            INSERT INTO @Result(u_id, course_id, current_process) VALUES (@user_id, @course_id, @cur_rate);
        END

        FETCH NEXT FROM cur INTO @course_id;
    END

    CLOSE cur;
    DEALLOCATE cur;

    RETURN;
END;


GO
SELECT * FROM Learn
select * from lesson
--test 1: xét người dùng id 1, hoàn thành tối thiểu 0%, kết quả hình 2.4.3
SELECT * FROM getComplete(1, 0.0);
--test 2: xét người dùng id 1, hoàn thành tối thiểu 10%, kết quả hình 2.4.4
SELECT * FROM getComplete(1, 0.1);


GO 
-- Function 2
CREATE OR ALTER FUNCTION trendCourseSubject
(
	@date_desire DATETIME,
	@top INT,
	@subject_name NVARCHAR(100)
)
RETURNS @Result TABLE (
    c_id INT,
    cname NVARCHAR(100),
    Num_buy INT,
    rating DECIMAL(3,1)
)
AS
BEGIN
    IF @top <= 0 
        RETURN;

    DECLARE @Course_id INT, @Num_buy INT, @Rating DECIMAL(3,1), @Cname NVARCHAR(100);
    DECLARE @Counter INT = 0;

    DECLARE cur CURSOR FOR
        SELECT I.Course_id, C.CName, COUNT(*) AS Num_buy, C.Rating
        FROM [Order] O
            JOIN include_course I ON O.Order_id = I.Order_id
            JOIN Course C ON I.Course_id = C.id
            JOIN has_course H ON H.Course_id = C.id
            JOIN [Subject] S ON S.id = H.Subject_id
        WHERE O.Ord_status = 'Completed'
          AND (@date_desire IS NULL OR O.Ord_date > @date_desire)
          AND (@subject_name IS NULL OR S.SName = @subject_name)
        GROUP BY I.Course_id, C.Rating, C.CName
        ORDER BY COUNT(*) DESC, C.Rating DESC;

    OPEN cur;
    FETCH NEXT FROM cur INTO @Course_id, @Cname, @Num_buy, @Rating;

    WHILE @@FETCH_STATUS = 0 AND @Counter < @top
    BEGIN
        INSERT INTO @Result(c_id, cname, Num_buy, Rating)
        VALUES (@Course_id, @Cname, @Num_buy, @Rating);

        SET @Counter = @Counter + 1;
        FETCH NEXT FROM cur INTO @Course_id, @Cname, @Num_buy, @Rating;
    END

    CLOSE cur;
    DEALLOCATE cur;

    RETURN;
END;
GO

SELECT * FROM include_course
SELECT * FROM [Order]
SELECT * FROM has_course
SELECT * FROM trendCourseSubject('2025-04-01', 100, NULL); --yyyy/mm/dd
SELECT * FROM trendCourseSubject('2024-04-01', 100, NULL); --yyyy/mm/dd

--test 1: xét toàn bộ chủ đề, kết quả hình 2.4.5
SELECT * FROM trendCourseSubject('2024-04-01', 5, NULL);
--test 2: xét chỉ trên chủ đề ‘Machine Learning’, kết quả hình 2.4.6
SELECT * FROM trendCourseSubject('2024-04-01', 5, 'Machine Learning'); 






SELECT * FROM dbo.Answer;
SELECT * FROM dbo.Assignment;
SELECT * FROM dbo.Certificate;
SELECT * FROM dbo.Chapter;
SELECT * FROM dbo.Coupon;
SELECT * FROM dbo.Course;
SELECT * FROM dbo.follow;
SELECT * FROM dbo.has_course;
SELECT * FROM dbo.has_permission;
SELECT * FROM dbo.has_role;
SELECT * FROM dbo.include_course;
SELECT * FROM dbo.Learn;
SELECT * FROM dbo.Lesson;
SELECT * FROM dbo.obtain_certificate;
SELECT * FROM dbo.Offer;
SELECT * FROM dbo.[Order];
SELECT * FROM dbo.Order_receipt;
SELECT * FROM dbo.permission;
SELECT * FROM dbo.Question;
SELECT * FROM dbo.Quiz;
SELECT * FROM dbo.Reading;
SELECT * FROM dbo.review_course;
SELECT * FROM dbo.role;
SELECT * FROM dbo.Subject;
SELECT * FROM dbo.use_coupon;
SELECT * FROM dbo.[user]
SELECT * FROM dbo.user_address;
SELECT * FROM dbo.Video;