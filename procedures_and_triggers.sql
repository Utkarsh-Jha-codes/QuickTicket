-- 1. Anti-Double Booking Logic
CREATE OR REPLACE FUNCTION book_ticket(p_user_id INT, p_train_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_available_seats INT;
    v_status VARCHAR(20);
BEGIN
    SELECT available_seats INTO v_available_seats
    FROM trains WHERE train_id = p_train_id FOR UPDATE;

    IF v_available_seats > 0 THEN
        UPDATE trains SET available_seats = available_seats - 1 WHERE train_id = p_train_id;
        v_status := 'Confirmed';
    ELSE
        v_status := 'Waitlisted';
    END IF;

    INSERT INTO bookings (user_id, train_id, status) VALUES (p_user_id, p_train_id, v_status);
    RETURN v_status;
END;
$$ LANGUAGE plpgsql;

-- 2. Automated Waitlist Management
CREATE OR REPLACE FUNCTION process_cancellation()
RETURNS TRIGGER AS $$
DECLARE
    next_booking_id INT;
BEGIN
    IF OLD.status = 'Confirmed' AND NEW.status = 'Cancelled' THEN
        SELECT booking_id INTO next_booking_id
        FROM bookings
        WHERE train_id = OLD.train_id AND status = 'Waitlisted'
        ORDER BY booking_time ASC LIMIT 1;

        IF FOUND THEN
            UPDATE bookings SET status = 'Confirmed' WHERE booking_id = next_booking_id;
        ELSE
            UPDATE trains SET available_seats = available_seats + 1 WHERE train_id = OLD.train_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cancel_ticket
AFTER UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION process_cancellation();
