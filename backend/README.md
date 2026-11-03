# Shajareh backend foundation

ASP.NET Core 8 API + PostgreSQL 16. This is the first infrastructure milestone, not a production deployment.

## Run locally

1. Install Docker Desktop or Docker Engine with Compose.
2. Copy `.env.example` to `.env` and set a long random `POSTGRES_PASSWORD`.
3. From this directory run `docker compose up --build`.
4. Check `http://localhost:8080/health`.

The SQL schema is applied automatically only when PostgreSQL creates a brand-new empty data volume. Existing volumes are not modified. To apply schema changes later, use reviewed versioned migrations and take a backup first.

## Current scope

- PostgreSQL schema for families, people, accounts, family records, memberships, relationships and approvals.
- Family-scoped relationships, confirmed-parent uniqueness, and separation of family-tree presence from account membership.
- API health/readiness endpoint and container build.

## Not enabled yet

Authentication, SMS verification, family/person write endpoints, authorization policies, file storage, backups and production hosting. Do not put real family or personal data into this initial build. The API intentionally exposes no unauthenticated write endpoints.

## Production requirements before real data

Use a private network and HTTPS reverse proxy, managed secrets, restricted database access, tested encrypted backups with restore drills, monitoring, rate limits, authentication, authorization and security review. Do not expose PostgreSQL publicly.
