CREATE DATABASE contractor_scheduler;
CREATE DATABASE contractor_scheduler_test;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS contractors (
  id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  phone_number TEXT NOT NULL UNIQUE,
  street_address TEXT NOT NULL,
  city TEXT NOT NULL,
  state_abbr VARCHAR(2) NOT NULL,
  zip_code VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IX_contractors_state_abbr
ON contractors (state_abbr);

CREATE INDEX IX_contractors_city
ON contractors (city);

CREATE INDEX IX_contractors_zip_code
ON contractors (zip_code);
    
CREATE TABLE IF NOT EXISTS schedules (
  contractor_id UUID NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  duration INTERVAL NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (contractor_id, start_time),
  PRIMARY KEY (contractor_id, start_time),
  FOREIGN KEY (contractor_id) REFERENCES contractors(id)
  ON DELETE CASCADE
);

CREATE INDEX IX_schedules_start_time
ON schedules (start_time);
    
CREATE TABLE IF NOT EXISTS users (
  id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  google_id TEXT NOT NULL UNIQUE,
  username TEXT NOT NULL UNIQUE,
  phone_number TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  contractor_id UUID DEFAULT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (contractor_id) REFERENCES contractors(id)
  ON DELETE CASCADE
);

CREATE INDEX IX_users_cID
ON users (contractor_id);
 
CREATE TABLE IF NOT EXISTS services (
  id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  price MONEY DEFAULT NULL,
  contractor_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (contractor_id) REFERENCES contractors(id)
  ON DELETE CASCADE
);

CREATE INDEX IX_services_name
ON services (name ASC);

CREATE INDEX IX_services_price
ON services (price ASC);
    
CREATE TABLE IF NOT EXISTS appointments (
  id UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4() PRIMARY KEY,
  contractor_id UUID NOT NULL,
  user_id UUID NOT NULL,
  service_id UUID NOT NULL,
  appointment_datetime TIMESTAMPTZ NOT NULL,
  duration INTERVAL NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(contractor_id, user_id, service_id, appointment_datetime),
  FOREIGN KEY (contractor_id) REFERENCES contractors(id)
  ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE CASCADE,
  FOREIGN KEY (service_id) REFERENCES services(id)
  ON DELETE SET NULL
);

CREATE INDEX IX_appointments_datetime
ON appointments (appointment_datetime);
    
CREATE TABLE feedback (
  id UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL,
  contractor_id UUID NOT NULL,
  stars INT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE SET NULL,
  FOREIGN KEY (contractor_id) REFERENCES contractors(id)
  ON DELETE SET NULL
); 

-- SELECT * FROM schedules -- Query to check if appointment falls within availability 
-- WHERE contractor_id = ${contractor_id}
-- AND (start_time <= (${start_time} + ${duration}) AND (start_time + duration) >= ${start_time};

-- SELECT * FROM appointments -- Query to check existing appointments 
-- WHERE contractor_id = ${contractor_id}
-- AND NOT (start_time <= (${start_time} + ${duration}) AND (start_time + duration) >= ${start_time});

DELETE FROM appointments -- Run on a schedule, cron job?
    WHERE appointment_datetime < (NOW() - INTERVAL '30 DAYS')
