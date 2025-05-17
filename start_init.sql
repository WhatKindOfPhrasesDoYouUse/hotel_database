-- Active: 1742117862138@@127.0.0.1@5432

/*
    Этот SQL-скрипт инициализирует базу данных для системы управления гостиницей.
    Включает создание схемы, доменов и таблиц для хранения информации о клиентах,
    сотрудниках, отелях, бронированиях, платежах и отзывах.

    Описание таблиц:
    1. client – хранит данные о клиентах гостиницы;
    2. employee_type – справочник с типами сотрудников;
    3. work_schedule – расписание работы сотрудников;
    4. employee – хранит информацию о сотрудниках;
    5. bank – справочник банков, используемых для карт гостей;
    6. card – хранит данные банковских карт гостей;
    7. guest – хранит дополнительную информацию о клиентах, выступающих в роли гостей;
    8. hotel_type – справочник типов отелей;
    9. hotel – хранит информацию об отелях;
    10. room – хранит информацию о комнатах в отеле;
    11. comfort – справочник комфортабельных услуг;
    12. room_comfort – таблица связи номеров и комфортабельных услуг;
    13. amenity – дополнительные услуги в отеле;
    14. amenity_booking – бронирование дополнительных услуг гостями;
    15. payment_type – справочник типов оплаты;
    16. amenity_payment – хранит информацию об оплате дополнительных услуг;
    17. room_booking – хранит информацию о бронировании номеров гостями;
    18. room_payment – информация об оплате за проживание;
    19. hotel_review – отзывы на отели от гостей;
    20. amenity_review – отзывы на дополнительные услуги от гостей.
*/

-- CREATE DATABASE hotel_database;

CREATE SCHEMA IF NOT EXISTS core;

SET search_path = 'core';

-- домен исключающий все символы кроме буквенны, для имен длинной 50 символов
CREATE DOMAIN NAME AS VARCHAR(50)
    CHECK (VALUE ~ '^[A-Za-zА-Яа-я\-]+$');

-- домен для стандартного вида email, длинной 100 символов
CREATE DOMAIN EMAIL AS VARCHAR(100)
    CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- домен для номера телефона, длинной 12 символов, в формате +7922...
CREATE DOMAIN PHONE_NUMBER AS VARCHAR(12) 
    CHECK (VALUE ~ '^\+[0-9]{11}$');

-- домен для валидации номера карты
CREATE DOMAIN CARD_NUMBER AS VARCHAR(16)
    CHECK (VALUE ~ '^[0-9]{16}$');

-- домен для хранения даты действия карты
CREATE DOMAIN CARD_DATE AS VARCHAR(5)
    CHECK (VALUE ~ '^(0[1-9]|1[0-2])/[0-9]{2}$');

-- таблица пользователей
CREATE TABLE core.client (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL,
    surname NAME NOT NULL,
    patronymic NAME,
    email EMAIL NOT NULL UNIQUE, 
    phone_number PHONE_NUMBER NOT NULL UNIQUE,
    password_hash VARCHAR(150) NOT NULL
);

-- справочник тип сотрудника
CREATE TABLE core.employee_type (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL UNIQUE
);

-- таблица расписания работы сотрудников
CREATE TABLE core.work_schedule (
    id SERIAL PRIMARY KEY,
    work_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

-- таблица сотрудников
CREATE TABLE core.employee (
    id SERIAL PRIMARY KEY,  
    hire_date DATE NOT NULL, 
    base_salary DECIMAL(10, 2) NOT NULL,
    employee_type_id INT NOT NULL REFERENCES core.employee_type(id)
        ON DELETE RESTRICT  -- запретить удаление типа сотрудника, если есть сотрудники этого типа
        ON UPDATE CASCADE,  -- обновить employee_type_id, если изменится id в таблице employee_type
    work_schedule_id INT REFERENCES core.work_schedule(id)
        ON DELETE SET NULL  -- если график работы удален, установить work_schedule_id в NULL
        ON UPDATE CASCADE,  -- обновить work_schedule_id, если изменится id в таблице work_schedule
    client_id INT NOT NULL REFERENCES core.client(id)
        ON DELETE CASCADE  -- удалить сотрудника, если удален связанный клиент
        ON UPDATE CASCADE  -- обновить client_id, если изменится id в таблице client
);

-- справочник банков
CREATE TABLE core.bank (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL UNIQUE
);

-- таблица карт гостей
CREATE TABLE core.card (
    id SERIAL PRIMARY KEY,
    card_number CARD_NUMBER NOT NULL UNIQUE,
    card_date CARD_DATE NOT NULL,
    bank_id INT NOT NULL REFERENCES core.bank(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- таблица гостей
CREATE TABLE core.guest (
    id SERIAL PRIMARY KEY,
    city_of_residence NAME NOT NULL,
    date_of_birth DATE 
        CHECK (date_of_birth <= CURRENT_DATE) NOT NULL ,
    passport_series_hash VARCHAR(150) NOT NULL,
    passport_number_hash VARCHAR(150) NOT NULL,
    loyalty_status NAME NOT NULL DEFAULT 'Базовый',
    card_id INT REFERENCES core.card(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    client_id INT NOT NULL REFERENCES core.client(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- справочник типов отелей
CREATE TABLE core.hotel_type (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL UNIQUE,
    description TEXT
);

-- таблица отелей
CREATE TABLE core.hotel (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL UNIQUE,
    city NAME NOT NULL,
    address VARCHAR(100) NOT NULL,
    description TEXT,
    phone_number PHONE_NUMBER NOT NULL UNIQUE,
    email EMAIL NOT NULL UNIQUE,
    year_of_construction INT 
        CHECK (year_of_construction >= 1300 AND year_of_construction <= EXTRACT(YEAR FROM CURRENT_DATE)),
    rating FLOAT NOT NULL DEFAULT 1
        CHECK (rating >= 1 AND rating <= 5)
);

-- таблица комнат
CREATE TABLE core.room (
    id SERIAL PRIMARY KEY,
    room_number INT NOT NULL,
    description TEXT,
    capacity INT NOT NULL
        CHECK (capacity >= 0),
    unit_price INT NOT NULL
        CHECK (unit_price >= 0),
    hotel_id INT NOT NULL REFERENCES core.hotel(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- справочник комфортабельных услуг комнаты
CREATE TABLE core.comfort (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL UNIQUE
);

-- таблица M:M для связи комфорта и комнаты
CREATE TABLE core.room_comfort (
    room_id INT NOT NULL REFERENCES core.room(id)  
        ON DELETE CASCADE 
        ON UPDATE CASCADE, 
    comfort_id INT NOT NULL REFERENCES core.comfort(id) 
        ON DELETE CASCADE  
        ON UPDATE CASCADE, 
    PRIMARY KEY (room_id, comfort_id)
);

-- таблица сервисных услуг
CREATE TABLE core.amenity (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL,
    description TEXT,
    unit_price INT NOT NULL,
    room_id INT NOT NULL REFERENCES core.room(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- таблица бронирования дополнительных услуг
CREATE TABLE core.amenity_booking (
    id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL CHECK (order_date <= CURRENT_DATE),
    order_time TIME NOT NULL,
    ready_date DATE NOT NULL,
    ready_time TIME NOT NULL,
    completion_status VARCHAR(30) NOT NULL DEFAULT ('В ожидании подтверждения'),
    quantity INT NOT NULL CHECK (quantity > 0),
    amenity_id INT NOT NULL REFERENCES core.amenity(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    guest_id INT NOT NULL REFERENCES core.guest(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- справочник типов оплаты
CREATE TABLE core.payment_type (
    id SERIAL PRIMARY KEY,
    name NAME NOT NULL UNIQUE
);

-- таблица оплаты дополнительных услуг
CREATE TABLE core.amenity_payment (
    id SERIAL PRIMARY KEY,
    payment_date DATE NOT NULL,
    payment_time TIME NOT NULL,
    total_cost INT NOT NULL CHECK (total_cost >= 0),
    payment_status VARCHAR(30) DEFAULT NULL,
    payment_type_id INT NOT NULL REFERENCES core.payment_type(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    amenity_booking_id INT NOT NULL REFERENCES core.amenity_booking(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- таблица бронирования комнат
CREATE TABLE core.room_booking (
    id SERIAL PRIMARY KEY,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    check_in_time TIME NOT NULL,
    check_out_time TIME NOT NULL,
    quest_id INT NOT NULL REFERENCES core.guest(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    room_id INT NOT NULL REFERENCES core.room(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CHECK(check_in_date <= check_out_date)
);

-- таблица оплаты комнат
CREATE TABLE core.room_payment (
    id SERIAL PRIMARY KEY,
    payment_date DATE NOT NULL,
    payment_time TIME NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    payment_status VARCHAR(50) NOT NULL,
    payment_type_id INT NOT NULL REFERENCES core.payment_type(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    room_booking_id INT NOT NULL REFERENCES core.room_booking(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- таблица отзывов на гостиницу
CREATE TABLE core.hotel_review (
    id SERIAL PRIMARY KEY,  
    comment TEXT,  
    publication_date DATE NOT NULL,  
    publication_time TIME NOT NULL,  
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),  
    guest_id INT NOT NULL REFERENCES core.guest(id)  
        ON DELETE CASCADE  
        ON UPDATE CASCADE,  
    hotel_id INT NOT NULL REFERENCES core.hotel(id)  
        ON DELETE CASCADE  
        ON UPDATE CASCADE 
);

-- таблица отзывов на дополнительные услуги
CREATE TABLE core.amenity_review (
    id SERIAL PRIMARY KEY,  
    comment TEXT,  
    publication_date DATE NOT NULL, 
    publication_time TIME NOT NULL,  
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5), 
    guest_id INT NOT NULL REFERENCES core.guest(id) 
        ON DELETE CASCADE  
        ON UPDATE CASCADE,  
    amenity_id INT NOT NULL REFERENCES core.amenity(id)  
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
);

-- исправление статуса
ALTER TABLE core.amenity_booking
ALTER COLUMN completion_status SET DEFAULT 'Ожидается подтверждение';

-- добавил персонал в таблицу бронирования дополнительных услуг
ALTER TABLE core.amenity_booking 
ADD COLUMN employee_id INT REFERENCES core.employee(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

-- добавил жесткую связь между услугой и типом сотрудника
ALTER TABLE core.amenity
ADD COLUMN employee_type_id INT REFERENCES core.employee_type(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

-- добавил связь сотрудников с конкретной гостиницей
ALTER TABLE core.employee
ADD COLUMN hotel_id INT REFERENCES core.hotel(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- поле hotel_id не должно быть null в таблице сотрудников    
ALTER TABLE core.employee
ALTER COLUMN hotel_id SET NOT NULL;

-- общная стоимость оказанных дополнительных услуг должна быть типа numeric и иметь название total_amount
ALTER TABLE core.amenity_payment
    RENAME COLUMN total_cost TO total_amount;

ALTER TABLE core.amenity_payment
    ALTER COLUMN total_amount TYPE numeric(10,2) USING total_amount::numeric(10,2);

ALTER TABLE core.hotel
ADD COLUMN hotel_type_id INT REFERENCES core.hotel_type(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE core.guest
  ALTER COLUMN date_of_birth SET DATA TYPE timestamp with time zone;

INSERT INTO core.hotel_type (id, name, description) 
VALUES
    (1, 'Отель', 'Стандартный отель с полным спектром услуг, включая ресторан, бассейн и конференц-залы.'),
    (2, 'Гостиница', 'Небольшое заведение, предлагающее базовые услуги проживания и завтрак.'),
    (3, 'Курортный отель', 'Отель, расположенный в курортной зоне, предлагающий дополнительные услуги, такие как спа, экскурсии и развлечения.'),
    (4, 'Бутик-отель', 'Небольшой отель с уникальным дизайном и индивидуальным подходом к обслуживанию.'),
    (5, 'Хостел', 'Бюджетное жилье с общими комнатами и минимальным набором услуг.'),
    (6, 'Апартаменты', 'Жилье с отдельными комнатами и кухней, подходящее для длительного проживания.'),
    (7, 'Мотель', 'Отель, расположенный вдоль шоссе, предлагающий удобства для автомобилистов.'),
    (8, 'Эко-отель', 'Отель, ориентированный на экологическую устойчивость и минимальное воздействие на окружающую среду.'),
    (9, 'Глэмпинг', 'Комфортабельное проживание в палатках или юртах с элементами роскоши.'),
    (10, 'Спа-отель', 'Отель, специализирующийся на оздоровительных и спа-услугах.');

INSERT INTO core.bank (id, name) VALUES
    (1, 'СберБанк'),
    (2, 'ВТБ'),
    (3, 'Газпромбанк'),
    (4, 'Альфа-Банк'),
    (5, 'Россельхозбанк'),
    (6, 'Т-Банк'),
    (7, 'Открытие'),
    (8, 'Райффайзенбанк'),
    (10, 'Почта Банк'),
    (11, 'ЮниКредит Банк'),
    (12,'МКБ'),
    (13, 'Росбанк'),
    (14, 'Совкомбанк'),
    (15, 'Хоум Кредит Банк'),
    (16, 'Ак Барс Банк'),
    (17, 'Банк Уралсиб'),
    (18, 'Промсвязьбанк'),
    (19, 'РНКБ'),
    (20, 'Сетелем Банк'),
    (21, 'Банк Зенит'),
    (22, 'Банк Русский Стандарт'),
    (23, 'МТС Банк'),
    (24, 'Кубань Кредит'),
    (25, 'Банк Санкт-Петербург'),
    (26, 'Банк Возрождение'),
    (27, 'Новикомбанк'),
    (28, 'Точка Банк'),
    (29, 'Дом.РФ'),
    (30, 'СГБ Банк'),
    (31, 'Энерготрансбанк'),
    (32, 'Ozon Банк'),
    (33, 'Яндекс Банк');

INSERT INTO core.payment_type (id, name) VALUES
    (1, 'Банковская карта'),
    (2, 'Электронный кошелек'),
    (3, 'Онлайн-банкинг'),
    (4, 'ЮMoney'),
    (5, 'QIWI'),
    (6, 'WebMoney'),
    (7, 'СБП');

INSERT INTO core.hotel (id, name, city, address, description, phone_number, email, year_of_construction, rating, hotel_type_id)
VALUES
  (1, 
  'Три семерки', 
  'Советск', 
  'ул. Строителей, 25', 
  'Отель "Три семерки" — это уютное и комфортабельное место для отдыха, расположенное в живописном городе Советск. 
  Отель был построен в 1990 году и с тех пор радует своих гостей теплой атмосферой и высоким уровнем сервиса.', 
  '+79229203777', 
  'null@hotelparadise.com', 
  1990, 
  4.0,
  2);

ALTER TABLE guest
    DROP CONSTRAINT guest_client_id_fkey;

ALTER TABLE guest
    ADD CONSTRAINT unique_client_id UNIQUE (client_id);

ALTER TABLE guest
    ADD CONSTRAINT guest_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- тестовые данные для комнат

INSERT INTO room (room_number, description, capacity, unit_price, hotel_id) VALUES
    (1, 'Description room 1', 1, 2500, 1),
    (2, 'Description room 2', 2, 4000, 1),
    (3, 'Description room 3', 2, 7500, 1),
    (4, 'Description room 4', 4, 6000, 1),
    (5, 'Description room 5', 1, 1800, 1);

-- тестовые данные для комфортабельности комнаты
INSERT INTO comfort (name) VALUES 
('Wi-Fi'),
('Холодильник'),
('Телевизор'),
('Кондиционер'),
('Сейф'),
('Фен'),
('Чайник'),
('Микроволновка'),
('Гладильная доска'),
('Кофемашина'),
('Ванна'),
('Душевая кабина'),
('Рабочий стол'),
('Шумоизоляция'),
('Тапочки'),
('Полотенца'),
('Мини-бар'),
('Кухонный уголок');


-- Связь между комнатами и комфортабельными услугами
-- Бюджетный номер
INSERT INTO room_comfort (room_id, comfort_id) VALUES 
(9, 3),  -- Wi-Fi
(9, 5),  -- Телевизор
(9, 8),  -- Фен
(9, 18); -- Полотенца

-- Обычный одноместный
INSERT INTO room_comfort (room_id, comfort_id) VALUES 
(5, 3),  -- Wi-Fi
(5, 5),  -- Телевизор
(5, 8),  -- Фен
(5, 18), -- Полотенца
(5, 12); -- Кофемашина

-- Двухместный стандарт
INSERT INTO room_comfort (room_id, comfort_id) VALUES 
(6, 3),  -- Wi-Fi
(6, 4),  -- Холодильник
(6, 5),  -- Телевизор
(6, 6),  -- Кондиционер
(6, 8),  -- Фен
(6, 14), -- Душевая кабина
(6, 18), -- Полотенца
(6, 20); -- Кухонный уголок

-- Улучшенный двухместный
INSERT INTO room_comfort (room_id, comfort_id) VALUES 
(7, 3),  -- Wi-Fi
(7, 4),  -- Холодильник
(7, 5),  -- Телевизор
(7, 6),  -- Кондиционер
(7, 7),  -- Сейф
(7, 8),  -- Фен
(7, 12), -- Кофемашина
(7, 14), -- Душевая кабина
(7, 16), -- Шумоизоляция
(7, 18), -- Полотенца
(7, 19); -- Мини-бар

-- Семейный
INSERT INTO room_comfort (room_id, comfort_id) VALUES 
(8, 3),  -- Wi-Fi
(8, 4),  -- Холодильник
(8, 5),  -- Телевизор
(8, 6),  -- Кондиционер
(8, 7),  -- Сейф
(8, 8),  -- Фен
(8, 9),  -- Чайник
(8, 10), -- Микроволновка
(8, 11), -- Гладильная доска
(8, 12), -- Кофемашина
(8, 13), -- Ванна
(8, 14), -- Душевая кабина
(8, 15), -- Рабочий стол
(8, 16), -- Шумоизоляция
(8, 17), -- Тапочки
(8, 18), -- Полотенца
(8, 19), -- Мини-бар
(8, 20); -- Кухонный уголок

ALTER TABLE room_booking RENAME COLUMN quest_id TO guest_id;

-- изменение связи между картой и гостем
ALTER TABLE core.guest
DROP CONSTRAINT IF EXISTS guest_card_id_fkey;

ALTER TABLE core.guest
DROP COLUMN IF EXISTS card_id;

ALTER TABLE core.card
ADD COLUMN guest_id INT UNIQUE REFERENCES core.guest(id)
ON DELETE CASCADE;

ALTER TABLE core.room_booking
ADD COLUMN number_of_guests INTEGER NOT NULL DEFAULT 1;

INSERT INTO core.employee_type (id, name) VALUES
    (1, 'Администратор'),
    (2, 'Уборщик'),
    (3, 'Техник'),
    (4, 'Ресепшен');

INSERT INTO amenity (name, description, unit_price, room_id, employee_type_id) VALUES
    ('Уборка номера', 'Ежедневная базовая уборка', 0, 5, 2),
    ('Замена полотенец', 'Свежие полотенца по требованию', 0, 5, 2),
    ('Wi-Fi', 'Бесплатный интернет в номере', 0, 5, 4),
    ('Доставка воды', 'Бутылка воды по запросу', 0, 5, 4),
    ('Будильник', 'Услуга телефонного пробуждения', 0, 5, 1),
    ('Телевидение', 'Цифровое ТВ с основными каналами', 0, 5, 3),
    ('Мини-сейф', 'Использование сейфа в номере', 0, 5, 1);

INSERT INTO amenity (name, description, unit_price, room_id, employee_type_id) VALUES
    ('Уборка номера', 'Глубокая уборка раз в три дня', 0, 6, 2),
    ('Замена постельного белья', 'Раз в два дня', 0, 6, 2),
    ('Доп. подушка', 'По запросу гостя', 0, 6, 4),
    ('Чай и кофе', 'Комплект чая и кофе ежедневно', 0, 6, 4),
    ('Wi-Fi', 'Скоростной интернет', 0, 6, 4),
    ('Мини-бар', 'Оплачивается по факту использования', 500, 6, 1),
    ('Услуги прачечной', 'Стирка одежды по запросу', 300, 6, 2);

INSERT INTO amenity (name, description, unit_price, room_id, employee_type_id) VALUES
    ('Ежедневная уборка', 'Премиальная уборка каждый день', 0, 7, 2),
    ('Замена полотенец и халатов', 'Каждый день', 0, 7, 2),
    ('Room service', 'Еда и напитки в номер', 0, 7, 4),
    ('Спа-набор', 'Набор косметики и ухода', 0, 7, 2),
    ('Wi-Fi+', 'Усиленный интернет', 0, 7, 4),
    ('Персональный консьерж', 'Помощь в бронировании/покупках', 0, 7, 1),
    ('Услуги глажки', 'Глажка одежды', 250, 7, 2),
    ('Техобслуживание по требованию', 'Любые неполадки – быстрое реагирование', 0, 7, 3);

INSERT INTO amenity (name, description, unit_price, room_id, employee_type_id) VALUES
    ('Ежедневная уборка', 'Полная уборка и дезинфекция', 0, 8, 2),
    ('Уборка после животных', 'Для гостей с питомцами', 300, 8, 2),
    ('Wi-Fi', 'Бесплатный высокоскоростной интернет', 0, 8, 4),
    ('ТВ-пакет премиум', 'Каналы, кино, спорт', 400, 8, 3),
    ('Room service', '24/7 обслуживание', 0, 8, 4),
    ('Сменный халат', 'Чистый халат ежедневно', 0, 8, 2),
    ('Чистка обуви', 'Быстрая чистка обуви', 200, 8, 2),
    ('Мини-бар', 'Оплата по факту', 700, 8, 4),
    ('Техобслуживание', 'В любое время', 0, 8, 3);

INSERT INTO amenity (name, description, unit_price, room_id, employee_type_id) VALUES
    ('Уборка', 'Стандартная уборка', 0, 9, 2),
    ('Замена полотенец', 'По требованию', 0, 9, 2),
    ('Wi-Fi', 'Бесплатно', 0, 9, 4),
    ('Чайник и чай', 'Комплект в номере', 0, 9, 4),
    ('Телевизор', 'Стандартные каналы', 0, 9, 3),
    ('Будильник', 'По звонку', 0, 9, 1),
    ('Прачечная', 'Оплата за услугу', 200, 9, 2);

ALTER TABLE core.employee DROP COLUMN base_salary;
ALTER TABLE core.employee DROP COLUMN hire_date;
ALTER TABLE core.employee DROP COLUMN work_schedule_id;

INSERT INTO client (name, surname, patronymic, email, phone_number, password_hash) VALUES
    ('Анна', 'Иванова', 'Петровна', 'anna.ivanova@example.com', '+79270000001', 'hash1'),
    ('Игорь', 'Сидоров', 'Александрович', 'igor.sidorov@example.com', '+79270000002', 'hash2'),
    ('Елена', 'Кузнецова', 'Игоревна', 'elena.kuz@example.com', '+79270000003', 'hash3'),
    ('Максим', 'Смирнов', 'Дмитриевич', 'max.smirnov@example.com', '+79270000004', 'hash4'),
    ('Татьяна', 'Морозова', 'Сергеевна', 'tatiana.m@example.com', '+79270000005', 'hash5'),
    ('Олег', 'Васильев', 'Николаевич', 'oleg.vas@example.com', '+79270000006', 'hash6'),
    ('Светлана', 'Федорова', 'Евгеньевна', 'sveta.f@example.com', '+79270000007', 'hash7'),
    ('Алексей', 'Попов', 'Владимирович', 'alex.popov@example.com', '+79270000008', 'hash8');

INSERT INTO employee (employee_type_id, client_id, hotel_id) VALUES
    (1, 26, 1),  -- Анна Иванова – Администратор
    (1, 27, 1),  -- Игорь Сидоров – Администратор
    (2, 28, 1),  -- Елена Кузнецова – Уборщик
    (2, 29, 1),  -- Максим Смирнов – Уборщик
    (3, 30, 1),  -- Татьяна Морозова – Техник
    (3, 31, 1),  -- Олег Васильев – Техник
    (4, 32, 1),  -- Светлана Федорова – Ресепшен
    (4, 33, 1);  -- Алексей Попов – Ресепшен

ALTER TABLE core.amenity_booking
ALTER COLUMN ready_date DROP NOT NULL;

ALTER TABLE core.amenity_booking
ALTER COLUMN ready_time DROP NOT NULL;

-- таблица для хранения информации о дополнительных гостях комнаты
CREATE TABLE core.additional_guest (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    passport_series_hash VARCHAR(150) NOT NULL,
    passport_number_hash VARCHAR(150) NOT NULL,
    date_of_birth DATE NOT NULL,
    room_booking_id INT NOT NULL REFERENCES core.room_booking(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    guest_id INT REFERENCES core.guest (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- поля для подтверждения бронирования
ALTER TABLE core.room_booking
ADD COLUMN is_confirmed BOOLEAN DEFAULT FALSE,
ADD COLUMN confirmation_time TIMESTAMP DEFAULT NULL;

ALTER TABLE core.room_booking
ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE hotel_review
ADD room_booking_id INT NOT NULL;

ALTER TABLE hotel_review
ADD CONSTRAINT fk_hotel_review_booking
FOREIGN KEY (room_booking_id) REFERENCES room_booking(id)
ON UPDATE CASCADE
ON DELETE CASCADE;

CREATE UNIQUE INDEX ux_hotel_review_booking
ON hotel_review(room_booking_id);

UPDATE amenity 
SET unit_price = 
    CASE 
        WHEN name = 'Уборка номера' AND description = 'Ежедневная базовая уборка' THEN 200
        WHEN name = 'Уборка номера' AND description = 'Глубокая уборка раз в три дня' THEN 250
        WHEN name = 'Уборка номера' AND description = 'Премиальная уборка каждый день' THEN 300
        WHEN name = 'Уборка номера' AND description = 'Полная уборка и дезинфекция' THEN 350
        WHEN name = 'Уборка' AND description = 'Стандартная уборка' THEN 200
        WHEN name = 'Замена полотенец' THEN 100
        WHEN name = 'Замена полотенец и халатов' THEN 150
        WHEN name = 'Wi-Fi' AND description = 'Бесплатный интернет в номере' THEN 150
        WHEN name = 'Wi-Fi' AND description = 'Скоростной интернет' THEN 180
        WHEN name = 'Wi-Fi' AND description = 'Бесплатный высокоскоростной интернет' THEN 200
        WHEN name = 'Wi-Fi+' THEN 220
        WHEN name = 'Доставка воды' THEN 50
        WHEN name = 'Будильник' THEN 30
        WHEN name = 'Телевидение' THEN 180
        WHEN name = 'Телевизор' THEN 150
        WHEN name = 'Мини-сейф' THEN 80
        WHEN name = 'Замена постельного белья' THEN 120
        WHEN name = 'Доп. подушка' THEN 40
        WHEN name = 'Чай и кофе' THEN 70
        WHEN name = 'Room service' THEN 250
        WHEN name = 'Спа-набор' THEN 150
        WHEN name = 'Персональный консьерж' THEN 300
        WHEN name = 'Техобслуживание по требованию' THEN 220
        WHEN name = 'Техобслуживание' THEN 200
        WHEN name = 'ТВ-пакет премиум' THEN 400
        WHEN name = 'Сменный халат' THEN 90
        WHEN name = 'Чайник и чай' THEN 60
        WHEN name = 'Уборка после животных' THEN 300
        WHEN name = 'Чистка обуви' THEN 200
        WHEN name = 'Прачечная' THEN 200
        WHEN name = 'Услуги прачечной' THEN 300
        WHEN name = 'Услуги глажки' THEN 250
        WHEN name = 'Мини-бар' AND unit_price = 0 THEN 500
        ELSE unit_price 
    END
WHERE unit_price = 0 OR (unit_price IS NULL);

ALTER TABLE core.amenity_booking
ADD COLUMN room_booking_id INT REFERENCES core.room_booking(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

DROP TABLE work_schedule;

UPDATE employee_type SET name = 'Administrator' WHERE id = 1;
UPDATE employee_type SET name = 'Cleaner' WHERE id = 2;
UPDATE employee_type SET name = 'Technician' WHERE id = 3;
UPDATE employee_type SET name = 'Reception' WHERE id = 4;

ALTER TABLE amenity_review
ADD COLUMN amenity_booking_id INT;

ALTER TABLE amenity_review
ADD CONSTRAINT fk_amenity_review_amenity_booking
FOREIGN KEY (amenity_booking_id) REFERENCES amenity_booking(id)
ON DELETE CASCADE;

CREATE UNIQUE INDEX ux_amenity_review_amenity_booking_id
ON amenity_review(amenity_booking_id);

SELECT setval('core.bank_id_seq', (SELECT MAX(id) FROM core.bank));