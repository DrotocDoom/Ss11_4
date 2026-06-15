CREATE TABLE accounts (
                          account_id SERIAL PRIMARY KEY,
                          customer_name VARCHAR(100),
                          balance NUMERIC(12,2)
);

CREATE TABLE transactions (
                              trans_id SERIAL PRIMARY KEY,
                              account_id INT REFERENCES accounts(account_id),
                              amount NUMERIC(12,2),
                              trans_type VARCHAR(20), -- 'WITHDRAW' hoặc 'DEPOSIT'
                              created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO accounts (customer_name, balance)
VALUES
    ('Nguyen Van A', 5000),
    ('Tran Thi B', 3000);

CREATE OR REPLACE PROCEDURE perform_transaction(p_account_id INT, p_amount NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    current_balance NUMERIC(12,2);
BEGIN
    SELECT accounts.balance INTO current_balance FROM accounts WHERE account_id = p_account_id;
    IF current_balance IS NULL THEN
        RAISE EXCEPTION 'Account not found';
    END IF;

    IF current_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;

    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_account_id;
    INSERT INTO transactions (account_id, amount, trans_type)
    VALUES (p_account_id, p_amount, 'WITHDRAW');
END;
$$;

BEGIN;

CALL perform_transaction(1, 1000);

COMMIT;

SELECT * FROM accounts;
SELECT * FROM transactions;

INSERT INTO transactions(account_id, amount, trans_type)
VALUES (999,  1000, 'WITHDRAW');

BEGIN;

CALL perform_transaction(999, 1000);

COMMIT;

ROLLBACK;