-- ============================================================
-- File Drop: one-time setup for a fresh Supabase project
-- ============================================================

-- 1. Public storage bucket named "files"
insert into storage.buckets (id, name, public)
values ('files', 'files', true)
on conflict (id) do update set public = true;

-- 2. Storage policies (anyone with the page can list, view, upload, delete)
drop policy if exists "public read"   on storage.objects;
drop policy if exists "public upload" on storage.objects;
drop policy if exists "public delete" on storage.objects;

create policy "public read"   on storage.objects for select to anon, authenticated using (bucket_id = 'files');
create policy "public upload" on storage.objects for insert to anon, authenticated with check (bucket_id = 'files');
create policy "public delete" on storage.objects for delete to anon, authenticated using (bucket_id = 'files');

-- 3. Saved links table
create table if not exists public.links (
  id         bigint generated always as identity primary key,
  url        text not null check (url ~* '^https?://' and char_length(url) <= 2048),
  title      text check (char_length(title) <= 200),
  created_at timestamptz not null default now()
);

alter table public.links enable row level security;

drop policy if exists "public read links"   on public.links;
drop policy if exists "public add links"    on public.links;
drop policy if exists "public delete links" on public.links;

create policy "public read links"   on public.links for select to anon, authenticated using (true);
create policy "public add links"    on public.links for insert to anon, authenticated with check (true);
create policy "public delete links" on public.links for delete to anon, authenticated using (true);

-- 4. Permissions for the public (anon) key
grant usage on schema public to anon, authenticated;
grant select, insert, delete on public.links to anon, authenticated;
