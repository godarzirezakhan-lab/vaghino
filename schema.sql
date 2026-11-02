-- Vaghino initial schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'کاربر ورقینو',
  phone text,
  role text not null default 'reader' check (role in ('reader','author','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  subtitle text,
  description text not null check (char_length(description) between 1 and 3000),
  category text not null default 'عمومی',
  cover_url text,
  content text,
  file_url text,
  price numeric(12,0) not null default 0 check (price >= 0),
  is_free boolean not null default true,
  status text not null default 'pending' check (status in ('draft','pending','published','rejected')),
  moderation_note text,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists books_status_created_idx on public.books(status, created_at desc);
create index if not exists books_category_idx on public.books(category);
create index if not exists books_author_idx on public.books(author_id);

create table if not exists public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  book_id uuid not null references public.books(id) on delete cascade,
  location integer not null default 0 check (location >= 0),
  note text,
  created_at timestamptz not null default now(),
  unique(user_id, book_id)
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references public.profiles(id) on delete set null,
  book_id uuid not null references public.books(id) on delete cascade,
  reason text not null,
  details text,
  status text not null default 'open' check (status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
 insert into public.profiles(id, display_name, phone)
 values (new.id, coalesce(new.raw_user_meta_data->>'display_name','کاربر ورقینو'), new.raw_user_meta_data->>'phone')
 on conflict (id) do nothing;
 return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists books_updated_at on public.books;
create trigger books_updated_at before update on public.books
for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.books enable row level security;
alter table public.bookmarks enable row level security;
alter table public.reports enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
 select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

drop policy if exists "profiles visible" on public.profiles;
create policy "profiles visible" on public.profiles for select using (true);
drop policy if exists "profile self update" on public.profiles;
create policy "profile self update" on public.profiles for update using (auth.uid() = id or public.is_admin()) with check (auth.uid() = id or public.is_admin());
-- Users cannot promote themselves: column-level grants can be tightened in production.
revoke update on public.profiles from authenticated;
grant update(display_name, phone) on public.profiles to authenticated;
grant select on public.profiles to anon, authenticated;

drop policy if exists "published books public" on public.books;
create policy "published books public" on public.books for select using (status = 'published' or author_id = auth.uid() or public.is_admin());
drop policy if exists "author insert own pending book" on public.books;
create policy "author insert own pending book" on public.books for insert to authenticated with check (author_id = auth.uid() and status in ('draft','pending'));
drop policy if exists "author edit own not published" on public.books;
create policy "author edit own not published" on public.books for update to authenticated using (author_id = auth.uid() and status in ('draft','rejected')) with check (author_id = auth.uid() and status in ('draft','pending','rejected'));
drop policy if exists "admin review books" on public.books;
create policy "admin review books" on public.books for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admin delete books" on public.books;
create policy "admin delete books" on public.books for delete to authenticated using (public.is_admin());

drop policy if exists "bookmark own rows" on public.bookmarks;
create policy "bookmark own rows" on public.bookmarks for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "reports create" on public.reports;
create policy "reports create" on public.reports for insert to authenticated with check (reporter_id = auth.uid());
drop policy if exists "reports own or admin read" on public.reports;
create policy "reports own or admin read" on public.reports for select to authenticated using (reporter_id = auth.uid() or public.is_admin());
drop policy if exists "admin update reports" on public.reports;
create policy "admin update reports" on public.reports for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- Storage buckets. Set book-covers public, book-files private in production.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('book-covers','book-covers',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('book-files','book-files',false,52428800,array['text/plain','application/pdf','application/epub+zip','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document'])
on conflict (id) do nothing;

drop policy if exists "cover upload own folder" on storage.objects;
create policy "cover upload own folder" on storage.objects for insert to authenticated with check (bucket_id = 'book-covers' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "cover update own folder" on storage.objects;
create policy "cover update own folder" on storage.objects for update to authenticated using (bucket_id = 'book-covers' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "cover public read" on storage.objects;
create policy "cover public read" on storage.objects for select using (bucket_id = 'book-covers');
drop policy if exists "book file upload own folder" on storage.objects;
create policy "book file upload own folder" on storage.objects for insert to authenticated with check (bucket_id = 'book-files' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "book file owner read" on storage.objects;
create policy "book file owner read" on storage.objects for select to authenticated using (bucket_id = 'book-files' and (storage.foldername(name))[1] = auth.uid()::text);
