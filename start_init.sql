CREATE DATABASE hotel_db;
CREATE SCHEMA IF NOT EXISTS core;

-- домен исключающий все символы кроме буквенны, для имен длинной 50 символов
CREATE DOMAIN NAME AS VARCHAR(50)
    CHECK (VALUES ~ '^[A-Za-zА-Яа-я\-]+$');

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
    base_salary DECIMAL(10, 2) NOT NULL,  -
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
    bank_id INT NOT NULL FOREIGN KEY (bank_id) REFERENCES core.bank(id)
        ON DELETE CASCADE,
        ON UPDATE CASCADE
);

-- таблица гостей
CREATE TABLE core.guest (
    id SERIAL PRIMARY KEY,
    city_​of_residence NAME NOT NULL,
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
    address NOT NULL,
    description TEXT,
    phone_number PHONE_NUMBER NOT NULL UNIQUE,
    email EMAIL NOT NULL UNIQUE,
    year_of_construction INT 
        CHECK (year_of_construction >= 1300 AND year_of_construction <= CURRENT_DATE),
    rating INT NOT NULL DEFAULT 0
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
        ON DELETE CASCADE,
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
        ON DELETE NULL
        ON UPDATE NULL
);

-- таблица бронирования дополнительных услуг
CREATE TABLE core.amenity_booking (
    id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL CHECK (order_date <= CURRENT_DATE),
    order_time TIME NOT NULL,
    ready_date DATA NOT NULL,
    ready_time TIME NOT NULL,
    completion_status VARCHAR(30) NOT NULL DEFAULT ('В ожидании подтверждения'),
    qunatity INT NOT NULL CHECK (qunatity > 0),
    amenity_id INT NOT NULL REFERENCES core.amenity(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    quest_id INT NOT NULL REFERENCES core.quest(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- справочник типов оплаты
CREATE TABLE payment_type (
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
        ON DELETE RESTRICT,
        ON UPDATE CASCADE
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
    quest_id INT NOT NULL REFERENCES core.quest(id)
        ON DELETE CASCADE,
        ON UPDATE CASCADE
    room_id INT NOT NULL REFERENCES core.room(id)
        ON DELETE RESTRICT,
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
    payment_type_id INT NOT NULL REFERENCES core.payment_method(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    room_booking_id INT NOT NULL REFERENCES core.room_booking(id)
        ON DELETE RESTRICT,
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