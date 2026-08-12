-- When a member uploads/changes their NID photo, mark status pending for admin review.
-- Members cannot set verified/suspended themselves (column grant stays limited).

create or replace function public.profiles_nid_photo_sets_pending()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  if new.nid_photo_url is distinct from old.nid_photo_url
     and coalesce(new.nid_photo_url, '') <> ''
     and coalesce(old.nid_status, 'unverified') in ('unverified', 'pending')
  then
    new.nid_status := 'pending';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_nid_photo_sets_pending on public.profiles;
create trigger profiles_nid_photo_sets_pending
before update of nid_photo_url on public.profiles
for each row
execute function public.profiles_nid_photo_sets_pending();
