-- GTM Analytics Warehouse - SQLite Schema 

-- ===============================
-- RESET TABLES 
-- ===============================
DROP TABLE IF EXISTS product_usage;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS opportunities;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS accounts;

-- ===============================
-- TABLES
-- ===============================

-- 1) ACCOUNTS
CREATE TABLE accounts (
    account_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    account_name    TEXT NOT NULL,
    industry        TEXT,
    employee_count  INTEGER,
    annual_revenue  REAL,
    country         TEXT,
    segment         TEXT,      -- 'SMB','Mid','Enterprise'
    created_at      TEXT,      -- store dates as 'YYYY-MM-DD'
    is_customer     INTEGER    -- 0 = false, 1 = true
);

-- 2) CONTACTS
CREATE TABLE contacts (
    contact_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id      INTEGER NOT NULL,
    first_name      TEXT NOT NULL,
    last_name       TEXT NOT NULL,
    title           TEXT,
    role_group      TEXT,
    created_at      TEXT,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 3) CAMPAIGNS
CREATE TABLE campaigns (
    campaign_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    campaign_name   TEXT NOT NULL,
    type            TEXT,
    start_date      TEXT,
    end_date        TEXT,
    budget          REAL
);

-- 4) OPPORTUNITIES
CREATE TABLE opportunities (
    opp_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id      INTEGER NOT NULL,
    created_date    TEXT NOT NULL,
    close_date      TEXT,
    stage           TEXT NOT NULL,
    amount          REAL,
    source          TEXT,
    owner           TEXT,
    is_closed       INTEGER NOT NULL DEFAULT 0,
    is_won          INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 5) ACTIVITIES
CREATE TABLE activities (
    activity_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id      INTEGER NOT NULL,
    contact_id      INTEGER,
    activity_date   TEXT NOT NULL,
    activity_type   TEXT NOT NULL,
    channel         TEXT,
    campaign_id     INTEGER,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (contact_id) REFERENCES contacts(contact_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- 6) PRODUCT USAGE
CREATE TABLE product_usage (
    usage_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id      INTEGER NOT NULL,
    usage_date      TEXT NOT NULL,
    active_users    INTEGER NOT NULL,
    sessions        INTEGER NOT NULL,
    feature_events  INTEGER NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- ===============================
-- SAMPLE DATA
-- ===============================

-- ACCOUNTS
INSERT INTO accounts (account_name, industry, employee_count, annual_revenue, country, segment, created_at, is_customer)
VALUES
  ('Acme Retail Co',           'Retail',     120,  15000000, 'USA',    'SMB',        '2023-01-15', 1),
  ('Brightline Health',        'Healthcare', 850, 120000000, 'USA',    'Mid',        '2022-09-01', 1),
  ('Nimbus Technologies',      'Software',   4200, 650000000,'USA',    'Enterprise', '2021-06-10', 1),
  ('Global Freight Logistics', 'Logistics',  600,  95000000, 'Canada', 'Mid',        '2023-03-20', 0),
  ('Urban Eats Delivery',      'FoodTech',   220,  25000000, 'USA',    'SMB',        '2023-08-05', 0),
  ('SkyView Analytics',        'Software',   150,  30000000, 'UK',     'SMB',        '2022-11-12', 1);

-- CONTACTS
INSERT INTO contacts (account_id, first_name, last_name, title, role_group, created_at)
VALUES
  (1, 'Sarah', 'Lopez',   'VP Operations',       'Economic Buyer', '2023-01-20'),
  (1, 'Mike',  'Chen',    'Ops Manager',         'User',           '2023-01-22'),
  (2, 'Emily', 'Patel',   'Director of IT',      'Champion',       '2022-09-05'),
  (2, 'Robert','King',    'CFO',                 'Economic Buyer', '2022-09-10'),
  (3, 'Julia', 'Nguyen',  'VP Product',          'Champion',       '2021-06-15'),
  (3, 'David', 'Smith',   'Head of Procurement', 'Economic Buyer', '2021-06-18'),
  (4, 'Anna',  'Harris',  'Logistics Director',  'Champion',       '2023-03-22'),
  (5, 'Omar',  'Ali',     'Growth Lead',         'Champion',       '2023-08-08'),
  (6, 'Laura', 'Baker',   'Head of Analytics',   'Champion',       '2022-11-15');

-- CAMPAIGNS
INSERT INTO campaigns (campaign_name, type, start_date, end_date, budget)
VALUES
  ('Q1 2024 Product Launch Webinar', 'Event',       '2024-01-10', '2024-01-31', 15000),
  ('Healthcare Email Nurture',       'Email',       '2024-02-01', '2024-03-15', 10000),
  ('Logistics Paid Social Push',     'Paid Social', '2024-03-01', '2024-03-31',  8000),
  ('SMB Growth Email Series',        'Email',       '2024-04-01', '2024-04-30',  5000);

-- OPPORTUNITIES
INSERT INTO opportunities (account_id, created_date, close_date, stage, amount, source, owner, is_closed, is_won)
VALUES
  (1, '2024-01-05', '2024-02-10', 'Closed Won',   45000,  'Inbound',  'Alice', 1, 1),
  (1, '2024-03-01', '2024-03-25', 'Closed Lost',  30000,  'Outbound', 'Alice', 1, 0),
  (2, '2024-01-15', '2024-03-20', 'Closed Won',  120000,  'Event',    'Brian', 1, 1),
  (2, '2024-04-05', NULL,         'Negotiation',  60000,  'Partner',  'Brian', 0, 0),
  (3, '2023-11-20', '2024-02-28', 'Closed Lost', 250000,  'Outbound', 'Carla', 1, 0),
  (3, '2024-03-10', NULL,         'Proposal',    180000,  'Inbound',  'Carla', 0, 0),
  (4, '2024-02-01', '2024-03-10', 'Closed Lost',  80000,  'Event',    'Diana', 1, 0),
  (5, '2024-03-12', NULL,         'Qualified',    35000,  'Inbound',  'Evan',  0, 0),
  (6, '2024-01-25', '2024-02-20', 'Closed Won',   70000,  'Outbound', 'Alice', 1, 1);

-- ACTIVITIES
INSERT INTO activities (account_id, contact_id, activity_date, activity_type, channel, campaign_id)
VALUES
  (1, 1, '2024-01-03', 'Email',        'Marketing',  1),
  (1, 1, '2024-01-08', 'Demo',         'Sales',      NULL),
  (1, 2, '2024-01-15', 'Meeting',      'Sales',      NULL),
  (1, 2, '2024-02-01', 'Proposal Sent','Sales',      NULL),

  (2, 3, '2024-01-12', 'Email',        'Marketing',  1),
  (2, 3, '2024-01-20', 'Event',        'Marketing',  1),
  (2, 4, '2024-02-05', 'Demo',         'Sales',      NULL),
  (2, 4, '2024-02-25', 'Meeting',      'Sales',      NULL),

  (3, 5, '2023-11-25', 'Outbound Call','Sales',      NULL),
  (3, 5, '2023-12-05', 'Demo',         'Sales',      NULL),
  (3, 6, '2024-01-10', 'Proposal Sent','Sales',      NULL),

  (4, 7, '2024-02-03', 'Email',        'Marketing',  3),
  (4, 7, '2024-02-20', 'Demo',         'Sales',      NULL),

  (5, 8, '2024-03-15', 'Email',        'Marketing',  4),
  (5, 8, '2024-03-22', 'Meeting',      'Sales',      NULL),

  (6, 9, '2024-01-28', 'Email',        'Marketing',  2),
  (6, 9, '2024-02-05', 'Demo',         'Sales',      NULL),
  (6, 9, '2024-02-12', 'Meeting',      'Sales',      NULL);

-- PRODUCT USAGE
INSERT INTO product_usage (account_id, usage_date, active_users, sessions, feature_events)
VALUES
  (1, '2024-01-20', 25, 200, 60),
  (1, '2024-01-27', 27, 230, 70),
  (1, '2024-02-03', 30, 260, 85),

  (2, '2024-01-20', 80, 600, 180),
  (2, '2024-01-27', 85, 640, 190),
  (2, '2024-02-03', 90, 700, 210),

  (3, '2024-01-20', 300, 2200, 650),
  (3, '2024-01-27', 310, 2300, 670),
  (3, '2024-02-03', 320, 2400, 700),

  (6, '2024-01-20', 40, 300, 95),
  (6, '2024-01-27', 42, 320, 100),
  (6, '2024-02-03', 45, 340, 110);
