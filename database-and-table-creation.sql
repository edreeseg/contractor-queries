CREATE DATABASE contractor_scheduler;
CREATE DATABASE contractor_scheduler_test;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE contractors (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    street_address VARCHAR(50) NOT NULL,
    city VARCHAR(25) NOT NULL,
    state_abbr VARCHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE schedules (
    contractor_id UUID NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    duration INTERVAL NOT NULL,
    UNIQUE (contractor_id, start_time),
    created_at TIMESTAMP DEFAULT now(),
    FOREIGN KEY (contractor_id) REFERENCES contractors(id)
        ON DELETE CASCADE
);

CREATE TABLE users (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(170) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    contractor_id UUID DEFAULT NULL,
    created_at TIMESTAMP DEFAULT now(),
    FOREIGN KEY (contractor_id) REFERENCES contractors(id)
        ON DELETE CASCADE
);

CREATE TABLE services (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price MONEY DEFAULT NULL,
    contractor_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    FOREIGN KEY (contractor_id) REFERENCES contractors(id)
        ON DELETE CASCADE
);

CREATE TABLE appointments (
    id UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4() PRIMARY KEY,
    contractor_id UUID NOT NULL,
    user_id UUID NOT NULL,
    service_id UUID NOT NULL,
    appointment_datetime TIMESTAMPTZ NOT NULL,
    duration INTERVAL NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    UNIQUE(contractor_id, user_id, service_id, appointment_datetime),
    FOREIGN KEY (contractor_id) REFERENCES contractors(id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id)
        ON DELETE SET NULL -- Do not delete scheduled appointment if a service is removed - potential for abuse
);

SELECT * FROM schedules -- Query to check if appointment falls within availability 
WHERE contractor_id = ${contractor_id}
AND (start_time <= (${start_time} + ${duration}) AND (start_time + duration) >= ${start_time};

SELECT * FROM appointments -- Query to check existing appointments 
WHERE contractor_id = ${contractor_id}
AND NOT (start_time <= (${start_time} + ${duration}) AND (start_time + duration) >= ${start_time});

DELETE FROM appointments -- Run on a schedule, cron job?
    WHERE appointment_datetime < (now() - INTERVAL '30 DAYS')