--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA core;


ALTER SCHEMA core OWNER TO postgres;

--
-- Name: card_date; Type: DOMAIN; Schema: core; Owner: postgres
--

CREATE DOMAIN core.card_date AS character varying(5)
	CONSTRAINT card_date_check CHECK (((VALUE)::text ~ '^(0[1-9]|1[0-2])/[0-9]{2}$'::text));


ALTER DOMAIN core.card_date OWNER TO postgres;

--
-- Name: card_number; Type: DOMAIN; Schema: core; Owner: postgres
--

CREATE DOMAIN core.card_number AS character varying(16)
	CONSTRAINT card_number_check CHECK (((VALUE)::text ~ '^[0-9]{16}$'::text));


ALTER DOMAIN core.card_number OWNER TO postgres;

--
-- Name: email; Type: DOMAIN; Schema: core; Owner: postgres
--

CREATE DOMAIN core.email AS character varying(100)
	CONSTRAINT email_check CHECK (((VALUE)::text ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text));


ALTER DOMAIN core.email OWNER TO postgres;

--
-- Name: name; Type: DOMAIN; Schema: core; Owner: postgres
--

CREATE DOMAIN core.name AS character varying(50)
	CONSTRAINT name_check CHECK (((VALUE)::text ~ '^[A-Za-zЂ-џ -п\-]+$'::text));


ALTER DOMAIN core.name OWNER TO postgres;

--
-- Name: phone_number; Type: DOMAIN; Schema: core; Owner: postgres
--

CREATE DOMAIN core.phone_number AS character varying(12)
	CONSTRAINT phone_number_check CHECK (((VALUE)::text ~ '^\+[0-9]{11}$'::text));


ALTER DOMAIN core.phone_number OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: amenity; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.amenity (
    id integer NOT NULL,
    name name NOT NULL,
    description text,
    unit_price integer NOT NULL,
    room_id integer NOT NULL,
    employee_type_id integer
);


ALTER TABLE core.amenity OWNER TO postgres;

--
-- Name: amenity_booking; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.amenity_booking (
    id integer NOT NULL,
    order_date date NOT NULL,
    order_time time without time zone NOT NULL,
    ready_date date,
    ready_time time without time zone,
    completion_status character varying(30) DEFAULT 'Ожидается подтверждение'::character varying NOT NULL,
    quantity integer NOT NULL,
    amenity_id integer NOT NULL,
    guest_id integer NOT NULL,
    employee_id integer,
    CONSTRAINT amenity_booking_order_date_check CHECK ((order_date <= CURRENT_DATE)),
    CONSTRAINT amenity_booking_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE core.amenity_booking OWNER TO postgres;

--
-- Name: amenity_booking_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.amenity_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.amenity_booking_id_seq OWNER TO postgres;

--
-- Name: amenity_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.amenity_booking_id_seq OWNED BY core.amenity_booking.id;


--
-- Name: amenity_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.amenity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.amenity_id_seq OWNER TO postgres;

--
-- Name: amenity_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.amenity_id_seq OWNED BY core.amenity.id;


--
-- Name: amenity_payment; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.amenity_payment (
    id integer NOT NULL,
    payment_date date NOT NULL,
    payment_time time without time zone NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    payment_status character varying(30) DEFAULT NULL::character varying,
    payment_type_id integer NOT NULL,
    amenity_booking_id integer NOT NULL,
    CONSTRAINT amenity_payment_total_cost_check CHECK ((total_amount >= (0)::numeric))
);


ALTER TABLE core.amenity_payment OWNER TO postgres;

--
-- Name: amenity_payment_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.amenity_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.amenity_payment_id_seq OWNER TO postgres;

--
-- Name: amenity_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.amenity_payment_id_seq OWNED BY core.amenity_payment.id;


--
-- Name: amenity_review; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.amenity_review (
    id integer NOT NULL,
    comment text,
    publication_date date NOT NULL,
    publication_time time without time zone NOT NULL,
    rating integer NOT NULL,
    guest_id integer NOT NULL,
    amenity_id integer NOT NULL,
    CONSTRAINT amenity_review_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE core.amenity_review OWNER TO postgres;

--
-- Name: amenity_review_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.amenity_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.amenity_review_id_seq OWNER TO postgres;

--
-- Name: amenity_review_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.amenity_review_id_seq OWNED BY core.amenity_review.id;


--
-- Name: bank; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.bank (
    id integer NOT NULL,
    name name NOT NULL
);


ALTER TABLE core.bank OWNER TO postgres;

--
-- Name: bank_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.bank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.bank_id_seq OWNER TO postgres;

--
-- Name: bank_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.bank_id_seq OWNED BY core.bank.id;


--
-- Name: card; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.card (
    id integer NOT NULL,
    card_number core.card_number NOT NULL,
    card_date core.card_date NOT NULL,
    bank_id integer NOT NULL,
    guest_id integer
);


ALTER TABLE core.card OWNER TO postgres;

--
-- Name: card_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.card_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.card_id_seq OWNER TO postgres;

--
-- Name: card_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.card_id_seq OWNED BY core.card.id;


--
-- Name: client; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.client (
    id integer NOT NULL,
    name name NOT NULL,
    surname name NOT NULL,
    patronymic name,
    email core.email NOT NULL,
    phone_number core.phone_number NOT NULL,
    password_hash character varying(150) NOT NULL
);


ALTER TABLE core.client OWNER TO postgres;

--
-- Name: client_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.client_id_seq OWNER TO postgres;

--
-- Name: client_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.client_id_seq OWNED BY core.client.id;


--
-- Name: comfort; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.comfort (
    id integer NOT NULL,
    name name NOT NULL
);


ALTER TABLE core.comfort OWNER TO postgres;

--
-- Name: comfort_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.comfort_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.comfort_id_seq OWNER TO postgres;

--
-- Name: comfort_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.comfort_id_seq OWNED BY core.comfort.id;


--
-- Name: employee; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.employee (
    id integer NOT NULL,
    employee_type_id integer NOT NULL,
    client_id integer NOT NULL,
    hotel_id integer NOT NULL
);


ALTER TABLE core.employee OWNER TO postgres;

--
-- Name: employee_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.employee_id_seq OWNER TO postgres;

--
-- Name: employee_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.employee_id_seq OWNED BY core.employee.id;


--
-- Name: employee_type; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.employee_type (
    id integer NOT NULL,
    name name NOT NULL
);


ALTER TABLE core.employee_type OWNER TO postgres;

--
-- Name: employee_type_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.employee_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.employee_type_id_seq OWNER TO postgres;

--
-- Name: employee_type_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.employee_type_id_seq OWNED BY core.employee_type.id;


--
-- Name: guest; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.guest (
    id integer NOT NULL,
    city_of_residence name NOT NULL,
    date_of_birth date NOT NULL,
    passport_series_hash character varying(150) NOT NULL,
    passport_number_hash character varying(150) NOT NULL,
    loyalty_status name DEFAULT 'Ѓ §®ўл©'::name NOT NULL,
    client_id integer NOT NULL,
    CONSTRAINT guest_date_of_birth_check CHECK ((date_of_birth <= CURRENT_DATE))
);


ALTER TABLE core.guest OWNER TO postgres;

--
-- Name: guest_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.guest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.guest_id_seq OWNER TO postgres;

--
-- Name: guest_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.guest_id_seq OWNED BY core.guest.id;


--
-- Name: hotel; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.hotel (
    id integer NOT NULL,
    name name NOT NULL,
    city name NOT NULL,
    address character varying(100) NOT NULL,
    description text,
    phone_number core.phone_number NOT NULL,
    email core.email NOT NULL,
    year_of_construction integer,
    rating double precision DEFAULT 1 NOT NULL,
    hotel_type_id integer,
    CONSTRAINT hotel_rating_check CHECK (((rating >= (1)::double precision) AND (rating <= (5)::double precision))),
    CONSTRAINT hotel_year_of_construction_check CHECK (((year_of_construction >= 1300) AND ((year_of_construction)::numeric <= EXTRACT(year FROM CURRENT_DATE))))
);


ALTER TABLE core.hotel OWNER TO postgres;

--
-- Name: hotel_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.hotel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.hotel_id_seq OWNER TO postgres;

--
-- Name: hotel_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.hotel_id_seq OWNED BY core.hotel.id;


--
-- Name: hotel_review; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.hotel_review (
    id integer NOT NULL,
    comment text,
    publication_date date NOT NULL,
    publication_time time without time zone NOT NULL,
    rating integer NOT NULL,
    guest_id integer NOT NULL,
    hotel_id integer NOT NULL,
    CONSTRAINT hotel_review_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE core.hotel_review OWNER TO postgres;

--
-- Name: hotel_review_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.hotel_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.hotel_review_id_seq OWNER TO postgres;

--
-- Name: hotel_review_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.hotel_review_id_seq OWNED BY core.hotel_review.id;


--
-- Name: hotel_type; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.hotel_type (
    id integer NOT NULL,
    name name NOT NULL,
    description text
);


ALTER TABLE core.hotel_type OWNER TO postgres;

--
-- Name: hotel_type_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.hotel_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.hotel_type_id_seq OWNER TO postgres;

--
-- Name: hotel_type_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.hotel_type_id_seq OWNED BY core.hotel_type.id;


--
-- Name: payment_type; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.payment_type (
    id integer NOT NULL,
    name name NOT NULL
);


ALTER TABLE core.payment_type OWNER TO postgres;

--
-- Name: payment_type_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.payment_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.payment_type_id_seq OWNER TO postgres;

--
-- Name: payment_type_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.payment_type_id_seq OWNED BY core.payment_type.id;


--
-- Name: room; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.room (
    id integer NOT NULL,
    room_number integer NOT NULL,
    description text,
    capacity integer NOT NULL,
    unit_price integer NOT NULL,
    hotel_id integer NOT NULL,
    CONSTRAINT room_capacity_check CHECK ((capacity >= 0)),
    CONSTRAINT room_unit_price_check CHECK ((unit_price >= 0))
);


ALTER TABLE core.room OWNER TO postgres;

--
-- Name: room_booking; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.room_booking (
    id integer NOT NULL,
    check_in_date date NOT NULL,
    check_out_date date NOT NULL,
    check_in_time time without time zone NOT NULL,
    check_out_time time without time zone NOT NULL,
    guest_id integer NOT NULL,
    room_id integer NOT NULL,
    number_of_guests integer DEFAULT 1 NOT NULL,
    CONSTRAINT room_booking_check CHECK ((check_in_date <= check_out_date))
);


ALTER TABLE core.room_booking OWNER TO postgres;

--
-- Name: room_booking_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.room_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.room_booking_id_seq OWNER TO postgres;

--
-- Name: room_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.room_booking_id_seq OWNED BY core.room_booking.id;


--
-- Name: room_comfort; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.room_comfort (
    room_id integer NOT NULL,
    comfort_id integer NOT NULL
);


ALTER TABLE core.room_comfort OWNER TO postgres;

--
-- Name: room_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.room_id_seq OWNER TO postgres;

--
-- Name: room_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.room_id_seq OWNED BY core.room.id;


--
-- Name: room_payment; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.room_payment (
    id integer NOT NULL,
    payment_date date NOT NULL,
    payment_time time without time zone NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    payment_status character varying(50) NOT NULL,
    payment_type_id integer NOT NULL,
    room_booking_id integer NOT NULL,
    CONSTRAINT room_payment_total_amount_check CHECK ((total_amount >= (0)::numeric))
);


ALTER TABLE core.room_payment OWNER TO postgres;

--
-- Name: room_payment_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.room_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.room_payment_id_seq OWNER TO postgres;

--
-- Name: room_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.room_payment_id_seq OWNED BY core.room_payment.id;


--
-- Name: work_schedule; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.work_schedule (
    id integer NOT NULL,
    work_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL
);


ALTER TABLE core.work_schedule OWNER TO postgres;

--
-- Name: work_schedule_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE core.work_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE core.work_schedule_id_seq OWNER TO postgres;

--
-- Name: work_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE core.work_schedule_id_seq OWNED BY core.work_schedule.id;


--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Name: amenity id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity ALTER COLUMN id SET DEFAULT nextval('core.amenity_id_seq'::regclass);


--
-- Name: amenity_booking id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_booking ALTER COLUMN id SET DEFAULT nextval('core.amenity_booking_id_seq'::regclass);


--
-- Name: amenity_payment id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_payment ALTER COLUMN id SET DEFAULT nextval('core.amenity_payment_id_seq'::regclass);


--
-- Name: amenity_review id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_review ALTER COLUMN id SET DEFAULT nextval('core.amenity_review_id_seq'::regclass);


--
-- Name: bank id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.bank ALTER COLUMN id SET DEFAULT nextval('core.bank_id_seq'::regclass);


--
-- Name: card id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.card ALTER COLUMN id SET DEFAULT nextval('core.card_id_seq'::regclass);


--
-- Name: client id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.client ALTER COLUMN id SET DEFAULT nextval('core.client_id_seq'::regclass);


--
-- Name: comfort id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.comfort ALTER COLUMN id SET DEFAULT nextval('core.comfort_id_seq'::regclass);


--
-- Name: employee id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee ALTER COLUMN id SET DEFAULT nextval('core.employee_id_seq'::regclass);


--
-- Name: employee_type id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee_type ALTER COLUMN id SET DEFAULT nextval('core.employee_type_id_seq'::regclass);


--
-- Name: guest id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.guest ALTER COLUMN id SET DEFAULT nextval('core.guest_id_seq'::regclass);


--
-- Name: hotel id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel ALTER COLUMN id SET DEFAULT nextval('core.hotel_id_seq'::regclass);


--
-- Name: hotel_review id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel_review ALTER COLUMN id SET DEFAULT nextval('core.hotel_review_id_seq'::regclass);


--
-- Name: hotel_type id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel_type ALTER COLUMN id SET DEFAULT nextval('core.hotel_type_id_seq'::regclass);


--
-- Name: payment_type id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.payment_type ALTER COLUMN id SET DEFAULT nextval('core.payment_type_id_seq'::regclass);


--
-- Name: room id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room ALTER COLUMN id SET DEFAULT nextval('core.room_id_seq'::regclass);


--
-- Name: room_booking id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_booking ALTER COLUMN id SET DEFAULT nextval('core.room_booking_id_seq'::regclass);


--
-- Name: room_payment id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_payment ALTER COLUMN id SET DEFAULT nextval('core.room_payment_id_seq'::regclass);


--
-- Name: work_schedule id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.work_schedule ALTER COLUMN id SET DEFAULT nextval('core.work_schedule_id_seq'::regclass);


--
-- Data for Name: amenity; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.amenity (id, name, description, unit_price, room_id, employee_type_id) FROM stdin;
1	Уборка номера	Ежедневная базовая уборка	0	5	2
2	Замена полотенец	Свежие полотенца по требованию	0	5	2
3	Wi-Fi	Бесплатный интернет в номере	0	5	4
4	Доставка воды	Бутылка воды по запросу	0	5	4
5	Будильник	Услуга телефонного пробуждения	0	5	1
6	Телевидение	Цифровое ТВ с основными каналами	0	5	3
7	Мини-сейф	Использование сейфа в номере	0	5	1
8	Уборка номера	Глубокая уборка раз в три дня	0	6	2
9	Замена постельного белья	Раз в два дня	0	6	2
10	Доп. подушка	По запросу гостя	0	6	4
11	Чай и кофе	Комплект чая и кофе ежедневно	0	6	4
12	Wi-Fi	Скоростной интернет	0	6	4
13	Мини-бар	Оплачивается по факту использования	500	6	1
14	Услуги прачечной	Стирка одежды по запросу	300	6	2
15	Ежедневная уборка	Премиальная уборка каждый день	0	7	2
16	Замена полотенец и халатов	Каждый день	0	7	2
17	Room service	Еда и напитки в номер	0	7	4
18	Спа-набор	Набор косметики и ухода	0	7	2
19	Wi-Fi+	Усиленный интернет	0	7	4
20	Персональный консьерж	Помощь в бронировании/покупках	0	7	1
21	Услуги глажки	Глажка одежды	250	7	2
22	Техобслуживание по требованию	Любые неполадки – быстрое реагирование	0	7	3
23	Ежедневная уборка	Полная уборка и дезинфекция	0	8	2
24	Уборка после животных	Для гостей с питомцами	300	8	2
25	Wi-Fi	Бесплатный высокоскоростной интернет	0	8	4
26	ТВ-пакет премиум	Каналы, кино, спорт	400	8	3
27	Room service	24/7 обслуживание	0	8	4
28	Сменный халат	Чистый халат ежедневно	0	8	2
29	Чистка обуви	Быстрая чистка обуви	200	8	2
30	Мини-бар	Оплата по факту	700	8	4
31	Техобслуживание	В любое время	0	8	3
32	Уборка	Стандартная уборка	0	9	2
33	Замена полотенец	По требованию	0	9	2
34	Wi-Fi	Бесплатно	0	9	4
35	Чайник и чай	Комплект в номере	0	9	4
36	Телевизор	Стандартные каналы	0	9	3
37	Будильник	По звонку	0	9	1
38	Прачечная	Оплата за услугу	200	9	2
\.


--
-- Data for Name: amenity_booking; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.amenity_booking (id, order_date, order_time, ready_date, ready_time, completion_status, quantity, amenity_id, guest_id, employee_id) FROM stdin;
\.


--
-- Data for Name: amenity_payment; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.amenity_payment (id, payment_date, payment_time, total_amount, payment_status, payment_type_id, amenity_booking_id) FROM stdin;
\.


--
-- Data for Name: amenity_review; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.amenity_review (id, comment, publication_date, publication_time, rating, guest_id, amenity_id) FROM stdin;
\.


--
-- Data for Name: bank; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.bank (id, name) FROM stdin;
1	СберБанк
2	ВТБ
3	Газпромбанк
4	Альфа-Банк
5	Россельхозбанк
6	Т-Банк
7	Открытие
8	Райффайзенбанк
10	Почта Банк
11	ЮниКредит Банк
12	МКБ
13	Росбанк
14	Совкомбанк
15	Хоум Кредит Банк
16	Ак Барс Банк
17	Банк Уралсиб
18	Промсвязьбанк
19	РНКБ
20	Сетелем Банк
21	Банк Зенит
22	Банк Русский Стандарт
23	МТС Банк
24	Кубань Кредит
25	Банк Санкт-Петербург
26	Банк Возрождение
27	Новикомбанк
28	Точка Банк
29	Дом.РФ
30	СГБ Банк
31	Энерготрансбанк
32	Ozon Банк
33	Яндекс Банк
\.


--
-- Data for Name: card; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.card (id, card_number, card_date, bank_id, guest_id) FROM stdin;
78	1234567812345678	01/12	16	13
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.client (id, name, surname, patronymic, email, phone_number, password_hash) FROM stdin;
20	Дмитрий	Ошуев	Владимирович	mazafon64@gmail.com	+79229314150	AQAAAAIAAYagAAAAEDD+Yd4XqbvPjk3eXnjP/gQPSoaCZjYiaYY4oesd/a0v7+Qu2XdZ4jt6SSe5w2JKlg==
26	Анна	Иванова	Петровна	anna.ivanova@example.com	+79270000001	hash1
27	Игорь	Сидоров	Александрович	igor.sidorov@example.com	+79270000002	hash2
28	Елена	Кузнецова	Игоревна	elena.kuz@example.com	+79270000003	hash3
29	Максим	Смирнов	Дмитриевич	max.smirnov@example.com	+79270000004	hash4
30	Татьяна	Морозова	Сергеевна	tatiana.m@example.com	+79270000005	hash5
31	Олег	Васильев	Николаевич	oleg.vas@example.com	+79270000006	hash6
32	Светлана	Федорова	Евгеньевна	sveta.f@example.com	+79270000007	hash7
33	Алексей	Попов	Владимирович	alex.popov@example.com	+79270000008	hash8
\.


--
-- Data for Name: comfort; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.comfort (id, name) FROM stdin;
3	Wi-Fi
4	Холодильник
5	Телевизор
6	Кондиционер
7	Сейф
8	Фен
9	Чайник
10	Микроволновка
11	Гладильная доска
12	Кофемашина
13	Ванна
14	Душевая кабина
15	Рабочий стол
16	Шумоизоляция
17	Тапочки
18	Полотенца
19	Мини-бар
20	Кухонный уголок
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.employee (id, employee_type_id, client_id, hotel_id) FROM stdin;
9	1	26	1
10	1	27	1
11	2	28	1
12	2	29	1
13	3	30	1
14	3	31	1
15	4	32	1
16	4	33	1
\.


--
-- Data for Name: employee_type; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.employee_type (id, name) FROM stdin;
1	Администратор
2	Уборщик
3	Техник
4	Ресепшен
\.


--
-- Data for Name: guest; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.guest (id, city_of_residence, date_of_birth, passport_series_hash, passport_number_hash, loyalty_status, client_id) FROM stdin;
13	Киров	2003-06-01	4825	561239	Базовый	20
\.


--
-- Data for Name: hotel; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.hotel (id, name, city, address, description, phone_number, email, year_of_construction, rating, hotel_type_id) FROM stdin;
1	Три семерки	Советск	ул. Строителей, 25	Отель "Три семерки" — это уютное и комфортабельное место для отдыха, расположенное в живописном городе Советск. \n  Отель был построен в 1990 году и с тех пор радует своих гостей теплой атмосферой и высоким уровнем сервиса.	+79229203777	null@hotelparadise.com	1990	4	2
\.


--
-- Data for Name: hotel_review; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.hotel_review (id, comment, publication_date, publication_time, rating, guest_id, hotel_id) FROM stdin;
\.


--
-- Data for Name: hotel_type; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.hotel_type (id, name, description) FROM stdin;
1	Отель	Стандартный отель с полным спектром услуг, включая ресторан, бассейн и конференц-залы.
2	Гостиница	Небольшое заведение, предлагающее базовые услуги проживания и завтрак.
3	Курортный отель	Отель, расположенный в курортной зоне, предлагающий дополнительные услуги, такие как спа, экскурсии и развлечения.
4	Бутик-отель	Небольшой отель с уникальным дизайном и индивидуальным подходом к обслуживанию.
5	Хостел	Бюджетное жилье с общими комнатами и минимальным набором услуг.
6	Апартаменты	Жилье с отдельными комнатами и кухней, подходящее для длительного проживания.
7	Мотель	Отель, расположенный вдоль шоссе, предлагающий удобства для автомобилистов.
8	Эко-отель	Отель, ориентированный на экологическую устойчивость и минимальное воздействие на окружающую среду.
9	Глэмпинг	Комфортабельное проживание в палатках или юртах с элементами роскоши.
10	Спа-отель	Отель, специализирующийся на оздоровительных и спа-услугах.
\.


--
-- Data for Name: payment_type; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.payment_type (id, name) FROM stdin;
1	Банковская карта
2	Электронный кошелек
3	Онлайн-банкинг
4	ЮMoney
5	QIWI
6	WebMoney
7	СБП
\.


--
-- Data for Name: room; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.room (id, room_number, description, capacity, unit_price, hotel_id) FROM stdin;
5	1	Description room 1	1	2500	1
6	2	Description room 2	2	4000	1
7	3	Description room 3	2	7500	1
8	4	Description room 4	4	6000	1
9	5	Description room 5	1	1800	1
\.


--
-- Data for Name: room_booking; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.room_booking (id, check_in_date, check_out_date, check_in_time, check_out_time, guest_id, room_id, number_of_guests) FROM stdin;
9	2025-04-15	2025-04-16	10:00:00	10:00:00	13	5	1
\.


--
-- Data for Name: room_comfort; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.room_comfort (room_id, comfort_id) FROM stdin;
9	3
9	5
9	8
9	18
5	3
5	5
5	8
5	18
5	12
6	3
6	4
6	5
6	6
6	8
6	14
6	18
6	20
7	3
7	4
7	5
7	6
7	7
7	8
7	12
7	14
7	16
7	18
7	19
8	3
8	4
8	5
8	6
8	7
8	8
8	9
8	10
8	11
8	12
8	13
8	14
8	15
8	16
8	17
8	18
8	19
8	20
\.


--
-- Data for Name: room_payment; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.room_payment (id, payment_date, payment_time, total_amount, payment_status, payment_type_id, room_booking_id) FROM stdin;
1	2025-04-14	18:55:48.35597	2500.00	Оплачено	1	9
\.


--
-- Data for Name: work_schedule; Type: TABLE DATA; Schema: core; Owner: postgres
--

COPY core.work_schedule (id, work_date, start_time, end_time) FROM stdin;
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
\.


--
-- Name: amenity_booking_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.amenity_booking_id_seq', 1, true);


--
-- Name: amenity_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.amenity_id_seq', 38, true);


--
-- Name: amenity_payment_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.amenity_payment_id_seq', 1, false);


--
-- Name: amenity_review_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.amenity_review_id_seq', 1, false);


--
-- Name: bank_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.bank_id_seq', 1, false);


--
-- Name: card_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.card_id_seq', 81, true);


--
-- Name: client_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.client_id_seq', 33, true);


--
-- Name: comfort_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.comfort_id_seq', 20, true);


--
-- Name: employee_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.employee_id_seq', 16, true);


--
-- Name: employee_type_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.employee_type_id_seq', 1, false);


--
-- Name: guest_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.guest_id_seq', 17, true);


--
-- Name: hotel_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.hotel_id_seq', 2, true);


--
-- Name: hotel_review_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.hotel_review_id_seq', 1, false);


--
-- Name: hotel_type_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.hotel_type_id_seq', 1, true);


--
-- Name: payment_type_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.payment_type_id_seq', 7, true);


--
-- Name: room_booking_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.room_booking_id_seq', 14, true);


--
-- Name: room_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.room_id_seq', 9, true);


--
-- Name: room_payment_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.room_payment_id_seq', 2, true);


--
-- Name: work_schedule_id_seq; Type: SEQUENCE SET; Schema: core; Owner: postgres
--

SELECT pg_catalog.setval('core.work_schedule_id_seq', 1, false);


--
-- Name: amenity_booking amenity_booking_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_booking
    ADD CONSTRAINT amenity_booking_pkey PRIMARY KEY (id);


--
-- Name: amenity_payment amenity_payment_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_payment
    ADD CONSTRAINT amenity_payment_pkey PRIMARY KEY (id);


--
-- Name: amenity amenity_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity
    ADD CONSTRAINT amenity_pkey PRIMARY KEY (id);


--
-- Name: amenity_review amenity_review_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_review
    ADD CONSTRAINT amenity_review_pkey PRIMARY KEY (id);


--
-- Name: bank bank_name_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.bank
    ADD CONSTRAINT bank_name_key UNIQUE (name);


--
-- Name: bank bank_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.bank
    ADD CONSTRAINT bank_pkey PRIMARY KEY (id);


--
-- Name: card card_card_number_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.card
    ADD CONSTRAINT card_card_number_key UNIQUE (card_number);


--
-- Name: card card_guest_id_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.card
    ADD CONSTRAINT card_guest_id_key UNIQUE (guest_id);


--
-- Name: card card_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.card
    ADD CONSTRAINT card_pkey PRIMARY KEY (id);


--
-- Name: client client_email_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.client
    ADD CONSTRAINT client_email_key UNIQUE (email);


--
-- Name: client client_phone_number_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.client
    ADD CONSTRAINT client_phone_number_key UNIQUE (phone_number);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id);


--
-- Name: comfort comfort_name_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.comfort
    ADD CONSTRAINT comfort_name_key UNIQUE (name);


--
-- Name: comfort comfort_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.comfort
    ADD CONSTRAINT comfort_pkey PRIMARY KEY (id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: employee_type employee_type_name_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee_type
    ADD CONSTRAINT employee_type_name_key UNIQUE (name);


--
-- Name: employee_type employee_type_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee_type
    ADD CONSTRAINT employee_type_pkey PRIMARY KEY (id);


--
-- Name: guest guest_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.guest
    ADD CONSTRAINT guest_pkey PRIMARY KEY (id);


--
-- Name: hotel hotel_email_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel
    ADD CONSTRAINT hotel_email_key UNIQUE (email);


--
-- Name: hotel hotel_name_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel
    ADD CONSTRAINT hotel_name_key UNIQUE (name);


--
-- Name: hotel hotel_phone_number_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel
    ADD CONSTRAINT hotel_phone_number_key UNIQUE (phone_number);


--
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (id);


--
-- Name: hotel_review hotel_review_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel_review
    ADD CONSTRAINT hotel_review_pkey PRIMARY KEY (id);


--
-- Name: hotel_type hotel_type_name_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel_type
    ADD CONSTRAINT hotel_type_name_key UNIQUE (name);


--
-- Name: hotel_type hotel_type_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel_type
    ADD CONSTRAINT hotel_type_pkey PRIMARY KEY (id);


--
-- Name: payment_type payment_type_name_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.payment_type
    ADD CONSTRAINT payment_type_name_key UNIQUE (name);


--
-- Name: payment_type payment_type_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.payment_type
    ADD CONSTRAINT payment_type_pkey PRIMARY KEY (id);


--
-- Name: room_booking room_booking_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_booking
    ADD CONSTRAINT room_booking_pkey PRIMARY KEY (id);


--
-- Name: room_comfort room_comfort_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_comfort
    ADD CONSTRAINT room_comfort_pkey PRIMARY KEY (room_id, comfort_id);


--
-- Name: room_payment room_payment_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_payment
    ADD CONSTRAINT room_payment_pkey PRIMARY KEY (id);


--
-- Name: room room_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (id);


--
-- Name: guest unique_client_id; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.guest
    ADD CONSTRAINT unique_client_id UNIQUE (client_id);


--
-- Name: work_schedule work_schedule_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.work_schedule
    ADD CONSTRAINT work_schedule_pkey PRIMARY KEY (id);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: amenity_booking amenity_booking_amenity_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_booking
    ADD CONSTRAINT amenity_booking_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES core.amenity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: amenity_booking amenity_booking_employee_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_booking
    ADD CONSTRAINT amenity_booking_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES core.employee(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: amenity_booking amenity_booking_guest_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_booking
    ADD CONSTRAINT amenity_booking_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES core.guest(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: amenity amenity_employee_type_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity
    ADD CONSTRAINT amenity_employee_type_id_fkey FOREIGN KEY (employee_type_id) REFERENCES core.employee_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: amenity_payment amenity_payment_amenity_booking_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_payment
    ADD CONSTRAINT amenity_payment_amenity_booking_id_fkey FOREIGN KEY (amenity_booking_id) REFERENCES core.amenity_booking(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: amenity_payment amenity_payment_payment_type_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_payment
    ADD CONSTRAINT amenity_payment_payment_type_id_fkey FOREIGN KEY (payment_type_id) REFERENCES core.payment_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: amenity_review amenity_review_amenity_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_review
    ADD CONSTRAINT amenity_review_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES core.amenity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: amenity_review amenity_review_guest_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity_review
    ADD CONSTRAINT amenity_review_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES core.guest(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: amenity amenity_room_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.amenity
    ADD CONSTRAINT amenity_room_id_fkey FOREIGN KEY (room_id) REFERENCES core.room(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: card card_bank_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.card
    ADD CONSTRAINT card_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES core.bank(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: card card_guest_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.card
    ADD CONSTRAINT card_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES core.guest(id) ON DELETE CASCADE;


--
-- Name: employee employee_client_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee
    ADD CONSTRAINT employee_client_id_fkey FOREIGN KEY (client_id) REFERENCES core.client(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: employee employee_employee_type_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee
    ADD CONSTRAINT employee_employee_type_id_fkey FOREIGN KEY (employee_type_id) REFERENCES core.employee_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: employee employee_hotel_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.employee
    ADD CONSTRAINT employee_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES core.hotel(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: guest guest_client_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.guest
    ADD CONSTRAINT guest_client_id_fkey FOREIGN KEY (client_id) REFERENCES core.client(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hotel hotel_hotel_type_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel
    ADD CONSTRAINT hotel_hotel_type_id_fkey FOREIGN KEY (hotel_type_id) REFERENCES core.hotel_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: hotel_review hotel_review_guest_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel_review
    ADD CONSTRAINT hotel_review_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES core.guest(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hotel_review hotel_review_hotel_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.hotel_review
    ADD CONSTRAINT hotel_review_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES core.hotel(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: room_booking room_booking_quest_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_booking
    ADD CONSTRAINT room_booking_quest_id_fkey FOREIGN KEY (guest_id) REFERENCES core.guest(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: room_booking room_booking_room_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_booking
    ADD CONSTRAINT room_booking_room_id_fkey FOREIGN KEY (room_id) REFERENCES core.room(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: room_comfort room_comfort_comfort_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_comfort
    ADD CONSTRAINT room_comfort_comfort_id_fkey FOREIGN KEY (comfort_id) REFERENCES core.comfort(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: room_comfort room_comfort_room_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_comfort
    ADD CONSTRAINT room_comfort_room_id_fkey FOREIGN KEY (room_id) REFERENCES core.room(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: room room_hotel_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room
    ADD CONSTRAINT room_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES core.hotel(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: room_payment room_payment_payment_type_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_payment
    ADD CONSTRAINT room_payment_payment_type_id_fkey FOREIGN KEY (payment_type_id) REFERENCES core.payment_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: room_payment room_payment_room_booking_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.room_payment
    ADD CONSTRAINT room_payment_room_booking_id_fkey FOREIGN KEY (room_booking_id) REFERENCES core.room_booking(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

