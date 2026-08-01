.PHONY: web-check mobile-check db-check

web-check:
	cd corridorshare-website && npm run lint && npm test && npm run build

mobile-check:
	cd corridorshare-app && flutter analyze && flutter test

db-check:
	supabase db reset
	supabase test db
