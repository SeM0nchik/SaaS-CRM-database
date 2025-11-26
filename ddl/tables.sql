SET search_path TO saas_crm;

CREATE DOMAIN email_address AS VARCHAR(255)
    CHECK (VALUE ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$');

CREATE DOMAIN phone_number AS VARCHAR(16)
    CHECK (VALUE ~ '^\+[1-9][0-9]{9,14}');

CREATE TYPE Role AS ENUM ('manager', 'employee', 'admin');

CREATE TABLE company (
    company_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) UNIQUE,
    company_desc TEXT,
    registration_date TIMESTAMP DEFAULT current_timestamp
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    employee_full_name VARCHAR(100) NOT NULL ,
    employee_email email_address UNIQUE,
    registration_date TIMESTAMP DEFAULT current_timestamp,
    role Role NOT NULL,

    CONSTRAINT fk_company FOREIGN KEY (company_id)
    REFERENCES company(company_id) ON DELETE CASCADE
);

CREATE TABLE client (
    client_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    client_full_name VARCHAR(100) NOT NULL ,
    client_email email_address NOT NULL ,
    client_phone phone_number NOT NULL ,
    client_post VARCHAR(100),

    CONSTRAINT fk_company FOREIGN KEY (company_id)
    REFERENCES company(company_id) ON DELETE CASCADE
);

CREATE TYPE deal_status AS ENUM ('new', 'active', 'closed');

CREATE TABLE deal (
    deal_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    manager_id INT NOT NULL,
    deal_name VARCHAR(40) NOT NULL ,
    deal_desc TEXT,
    amount DECIMAL,
    deal_status deal_status DEFAULT 'new',
    creation_date DATE DEFAULT current_date,
    close_date DATE,

    CONSTRAINT fk_client FOREIGN KEY (client_id)
    REFERENCES client(client_id) ON DELETE CASCADE,

    CONSTRAINT fk_manager FOREIGN KEY (manager_id) -- Добавить триггер на проверку роли работника
    REFERENCES employee(employee_id) ON DELETE CASCADE
);

CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL ,
    product_name VARCHAR(100) NOT NULL ,
    product_desc TEXT,
    product_price DECIMAL NOT NULL CHECK ( product_price > 0 ),

    CONSTRAINT fk_company FOREIGN KEY (company_id)
    REFERENCES company(company_id) ON DELETE CASCADE
);

CREATE TYPE task_status AS ENUM ('new', 'in progress', 'completed');

CREATE TABLE task (
    task_id SERIAL PRIMARY KEY,
    deal_id INT NOT NULL,
    employee_id INT NOT NULL,
    task_desc TEXT,
    task_deadline TIMESTAMP NOT NULL ,
    task_status task_status NOT NULL ,
    task_result VARCHAR(100),

    CONSTRAINT fk_employee FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id) ON DELETE CASCADE,

    CONSTRAINT fk_deal FOREIGN KEY (deal_id)
    REFERENCES deal(deal_id) ON DELETE CASCADE
);


CREATE TABLE chat_message (
    message_id SERIAL PRIMARY KEY,
    deal_id INT NOT NULL,
    employee_id INT,
    direction VARCHAR NOT NULL,
    channel VARCHAR,
    body TEXT,
    send_at timestamp,

    CONSTRAINT fk_deal FOREIGN KEY (deal_id)
    REFERENCES deal(deal_id) ON DELETE CASCADE,

    CONSTRAINT fk_employee FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id) ON DELETE SET NULL
);

CREATE TABLE email_message (
    email_id SERIAL PRIMARY KEY,
    deal_id INT NOT NULL,
    employee_id INT NOT NULL,
    direction VARCHAR NOT NULL,
    subject VARCHAR NOT NULL,
    body TEXT   ,
    send_at TIMESTAMP,


    CONSTRAINT fk_deal FOREIGN KEY (deal_id)
    REFERENCES deal(deal_id) ON DELETE CASCADE,

    CONSTRAINT fk_employee FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id) ON DELETE SET NULL

);

CREATE TABLE call_logs (
    call_id SERIAL PRIMARY KEY,
    deal_id INT NOT NULL,
    employee_id INT NOT NULL,
    direction VARCHAR NOT NULL,
    phone phone_number NOT NULL,
    duration DECIMAL CHECK ( duration > 0 ),
    call_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_deal FOREIGN KEY (deal_id)
    REFERENCES deal(deal_id) ON DELETE CASCADE,

    CONSTRAINT fk_employee FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id) ON DELETE SET NULL
);

CREATE TABLE comment (
    comment_id SERIAL PRIMARY KEY,
    parent_comment_id INT,
    employee_id INT NOT NULL,
    task_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP,


    CONSTRAINT fk_employee FOREIGN KEY (employee_id)
    REFERENCES employee(employee_id) ON DELETE CASCADE,

    CONSTRAINT fk_comment FOREIGN KEY (parent_comment_id)
    REFERENCES comment(comment_id) ON DELETE SET NULL,

    CONSTRAINT fk_task_id FOREIGN KEY (task_id)
    REFERENCES task(task_id) ON DELETE CASCADE
);

CREATE TABLE activity_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    action_type VARCHAR,
    object_type VARCHAR,
    object_id INT NOT NULL,
    object_name VARCHAR,
    status VARCHAR NOT NULL ,
    message TEXT,

    CONSTRAINT fk_user FOREIGN KEY (user_id)
    REFERENCES employee(employee_id) ON DELETE SET NULL
);

CREATE TABLE client_review (
    review_id SERIAL PRIMARY KEY,
    deal_id INT NOT NULL,
    rating decimal default 5 check ( rating <= 5 AND rating >= 0 ),
    message TEXT,

    CONSTRAINT fk_deal FOREIGN KEY (deal_id)
    REFERENCES deal(deal_id) ON DELETE SET NULL
);

CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR UNIQUE,
    tag_desc TEXT
);

CREATE TABLE deal_by_tag (
    tag_id INT NOT NULL,
    deal_id INT NOT NULL,

    CONSTRAINT fk_deal FOREIGN KEY (deal_id)
    REFERENCES deal(deal_id) ON DELETE CASCADE,

    CONSTRAINT fk_tag FOREIGN KEY (tag_id)
    REFERENCES tags(tag_id) ON DELETE CASCADE
);

CREATE TABLE product_by_deal (
    deal_id INT NOT NULL,
    product_id INT,
    count INT NOT NULL DEFAULT 1 CHECK ( count > 0 ),
    price DECIMAL NOT NULL CHECK ( price > 0 ),

    CONSTRAINT fk_deal FOREIGN KEY (deal_id)
    REFERENCES deal(deal_id) ON DELETE CASCADE,

    CONSTRAINT fk_product FOREIGN KEY (product_id)
    REFERENCES product(product_id) ON DELETE SET NULL
)