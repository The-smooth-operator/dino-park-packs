CREATE TYPE group_type AS ENUM ('closed', 'reviewed', 'open');
CREATE TYPE role_type AS ENUM ('admin', 'curator', 'member');
CREATE TYPE capability_type AS ENUM ('gdrive', 'discourse');
CREATE TYPE permission_type AS ENUM ('invite_member', 'edit_description', 'add_curator', 'remove_curator', 'delete_group', 'remove_member', 'edit_terms');
CREATE TYPE trust_type AS ENUM ('public', 'authenticated', 'vouched', 'ndaed', 'staff');
CREATE TYPE rule_type AS ENUM ('staff', 'nda', 'group', 'custom');

CREATE TABLE groups (
    group_id SERIAL PRIMARY KEY,
    name VARCHAR UNIQUE NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    path VARCHAR NOT NULL,
    description TEXT NOT NULL,
    capabilities capability_type[] NOT NULL,
    typ group_type NOT NULL DEFAULT 'closed',
    trust trust_type NOT NULL DEFAULT 'ndaed',
    group_expiration INTEGER,
    created TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE terms (
    group_id SERIAL PRIMARY KEY REFERENCES groups,
    text TEXT NOT NULL
);

CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    group_id SERIAL REFERENCES groups,
    typ role_type NOT NULL DEFAULT 'member',
    name VARCHAR NOT NULL,
    permissions permission_type[] NOT NULL DEFAULT array[]::permission_type[],
    UNIQUE (group_id, typ)
);

CREATE TABLE memberships (
    user_uuid UUID NOT NULL,
    group_id SERIAL REFERENCES groups,
    role_id SERIAL REFERENCES roles,
    expiration TIMESTAMP,
    added_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    added_ts TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_uuid, group_id)
);

CREATE TABLE invitations (
    group_id SERIAL REFERENCES groups,
    user_uuid UUID NOT NULL,
    invitation_expiration TIMESTAMP DEFAULT (NOW() + INTERVAL '1 week'),
    group_expiration INTEGER,
    added_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    PRIMARY KEY (group_id, user_uuid)
);

CREATE TABLE rules (
    rule_id SERIAL PRIMARY KEY,
    typ rule_type NOT NULL,
    name VARCHAR NOT NULL,
    payload TEXT
);

CREATE TABLE group_rules (
    rule_id SERIAL REFERENCES rules,
    group_id SERIAL REFERENCES groups,
    PRIMARY KEY (rule_id, group_id)
);

CREATE TABLE profiles (
    user_uuid UUID PRIMARY KEY,
    user_id VARCHAR UNIQUE NOT NULL,
    email VARCHAR NOT NULL,
    username VARCHAR UNIQUE NOT NULL,
    profile JSONB NOT NULL
);

CREATE TABLE user_ids (
    user_id VARCHAR PRIMARY KEY,
    user_uuid UUID UNIQUE NOT NULL REFERENCES profiles
);

CREATE TABLE users_staff (
    user_uuid UUID PRIMARY KEY,
    picture VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    username VARCHAR NOT NULL,
    email VARCHAR,
    trust trust_type NOT NULL
);

CREATE TABLE users_ndaed (
    user_uuid UUID PRIMARY KEY,
    picture VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    username VARCHAR NOT NULL,
    email VARCHAR,
    trust trust_type NOT NULL
);

CREATE TABLE users_vouched (
    user_uuid UUID PRIMARY KEY,
    picture VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    username VARCHAR NOT NULL,
    email VARCHAR,
    trust trust_type NOT NULL
);

CREATE TABLE users_authenticated (
    user_uuid UUID PRIMARY KEY,
    picture VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    username VARCHAR NOT NULL,
    email VARCHAR,
    trust trust_type NOT NULL
);

CREATE TABLE users_public (
    user_uuid UUID PRIMARY KEY,
    picture VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    username VARCHAR NOT NULL,
    email VARCHAR,
    trust trust_type NOT NULL
);

CREATE VIEW hosts_staff AS SELECT user_uuid, first_name, last_name, username, email FROM users_staff;
CREATE VIEW hosts_ndaed AS SELECT user_uuid, first_name, last_name, username, email FROM users_ndaed;
CREATE VIEW hosts_vouched AS SELECT user_uuid, first_name, last_name, username, email FROM users_vouched;
CREATE VIEW hosts_authenticated AS SELECT user_uuid, first_name, last_name, username, email FROM users_authenticated;
CREATE VIEW hosts_public AS SELECT user_uuid, first_name, last_name, username, email FROM users_public;

INSERT INTO rules ("typ", "name") VALUES ('staff', 'staff user');
INSERT INTO rules ("typ", "name") VALUES ('nda', E'nda\'d user');

INSERT INTO users_staff ("user_uuid", "username", "trust") VALUES ('00000000-0000-0000-0000-000000000000', 'anonymous', 'public');
INSERT INTO users_ndaed ("user_uuid", "username", "trust") VALUES ('00000000-0000-0000-0000-000000000000', 'anonymous', 'public');
INSERT INTO users_vouched ("user_uuid", "username", "trust") VALUES ('00000000-0000-0000-0000-000000000000', 'anonymous', 'public');
INSERT INTO users_authenticated ("user_uuid", "username", "trust") VALUES ('00000000-0000-0000-0000-000000000000', 'anonymous', 'public');
INSERT INTO users_public ("user_uuid", "username", "trust") VALUES ('00000000-0000-0000-0000-000000000000', 'anonymous', 'public');