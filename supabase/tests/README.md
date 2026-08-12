# Database tests

`security_contract.sql` contains transactional pgTAP assertions for the shared schema
(authorization abuse cases, nationwide matching filters, admin wallet credit, and
lock-amount hardening). Run it against a disposable local Supabase database after
applying migrations:

```bash
supabase start
supabase db reset
supabase test db
```
