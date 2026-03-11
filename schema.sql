CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE trains (
    train_id SERIAL PRIMARY KEY,
    train_name VARCHAR(100),
    source_station VARCHAR(50),
    destination_station VARCHAR(50),
    travel_date DATE,
    total_seats INT,
    available_seats INT CHECK (available_seats >= 0)
);

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    train_id INT REFERENCES trains(train_id),
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Confirmed', 'Waitlisted', 'Cancelled'))
);
