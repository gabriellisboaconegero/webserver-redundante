CREATE TABLE IF NOT EXISTS infos (
    id SERIAL PRIMARY KEY,
    uso_cpu float,
    memoria INT,
    ip TEXT,
    time_collect TIMESTAMP default current_timestamp
);
