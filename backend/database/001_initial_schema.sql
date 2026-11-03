-- Shajareh initial PostgreSQL schema.
-- Apply manually after reviewing the target database and taking a backup.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE families (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(160) NOT NULL CHECK (length(trim(name)) > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz NULL
);

CREATE TABLE persons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  given_name varchar(100) NOT NULL CHECK (length(trim(given_name)) > 0),
  family_name varchar(100),
  father_name_snapshot varchar(100),
  mother_name_snapshot varchar(100),
  birth_date date,
  birth_date_precision varchar(16) NOT NULL DEFAULT 'unknown'
    CHECK (birth_date_precision IN ('exact','year','approximate','unknown')),
  life_status varchar(16) NOT NULL DEFAULT 'unknown'
    CHECK (life_status IN ('living','deceased','unknown')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE user_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id uuid NOT NULL UNIQUE REFERENCES persons(id) ON DELETE RESTRICT,
  phone_number varchar(20) NOT NULL UNIQUE,
  phone_verified boolean NOT NULL DEFAULT false,
  password_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_login_at timestamptz
);

CREATE TABLE family_persons (
  family_id uuid NOT NULL REFERENCES families(id) ON DELETE RESTRICT,
  person_id uuid NOT NULL REFERENCES persons(id) ON DELETE RESTRICT,
  record_status varchar(16) NOT NULL DEFAULT 'active'
    CHECK (record_status IN ('active','memorial','archived')),
  added_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (family_id, person_id)
);

CREATE TABLE family_memberships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid NOT NULL,
  person_id uuid NOT NULL,
  role varchar(24) NOT NULL DEFAULT 'member'
    CHECK (role IN ('member','admin','owner')),
  status varchar(16) NOT NULL DEFAULT 'active'
    CHECK (status IN ('invited','active','suspended','left')),
  joined_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (family_id, person_id),
  FOREIGN KEY (family_id, person_id) REFERENCES family_persons(family_id, person_id) ON DELETE RESTRICT
);

CREATE TABLE relationships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid NOT NULL,
  person_id uuid NOT NULL,
  related_person_id uuid NOT NULL,
  relationship_type varchar(24) NOT NULL
    CHECK (relationship_type IN ('parent_child','spouse')),
  parent_role varchar(12) NULL CHECK (parent_role IN ('father','mother')),
  status varchar(16) NOT NULL DEFAULT 'proposed'
    CHECK (status IN ('proposed','confirmed','rejected','disputed')),
  source varchar(24) NOT NULL DEFAULT 'member_input',
  created_by_person_id uuid NOT NULL REFERENCES persons(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (person_id <> related_person_id),
  CHECK (
    (relationship_type = 'parent_child' AND parent_role IS NOT NULL)
    OR (relationship_type = 'spouse' AND parent_role IS NULL)
  ),
  FOREIGN KEY (family_id, person_id) REFERENCES family_persons(family_id, person_id) ON DELETE RESTRICT,
  FOREIGN KEY (family_id, related_person_id) REFERENCES family_persons(family_id, person_id) ON DELETE RESTRICT
);

CREATE TABLE relationship_approvals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  relationship_id uuid NOT NULL REFERENCES relationships(id) ON DELETE RESTRICT,
  approver_person_id uuid NOT NULL REFERENCES persons(id) ON DELETE RESTRICT,
  decision varchar(16) NOT NULL CHECK (decision IN ('confirmed','rejected','disputed')),
  reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (relationship_id, approver_person_id)
);

CREATE INDEX ix_relationships_family_person ON relationships(family_id, person_id);
CREATE INDEX ix_relationships_family_related ON relationships(family_id, related_person_id);
CREATE INDEX ix_relationships_status ON relationships(family_id, status);
CREATE INDEX ix_family_memberships_person ON family_memberships(person_id, status);

-- Enforce at most one confirmed father and one confirmed mother per child in each family.
CREATE UNIQUE INDEX ux_confirmed_father_per_child
  ON relationships(family_id, person_id)
  WHERE relationship_type = 'parent_child' AND parent_role = 'father' AND status = 'confirmed';
CREATE UNIQUE INDEX ux_confirmed_mother_per_child
  ON relationships(family_id, person_id)
  WHERE relationship_type = 'parent_child' AND parent_role = 'mother' AND status = 'confirmed';

CREATE TABLE schema_migrations (
  version varchar(64) PRIMARY KEY,
  applied_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO schema_migrations(version) VALUES ('001_initial_schema');
