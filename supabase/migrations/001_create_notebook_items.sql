create table if not exists public.notebook_items (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('subject', 'note')),
  subject_id uuid references public.notebook_items(id) on delete cascade,
  title text not null default '',
  content text not null default '',
  note_number integer not null default 0,
  favorite boolean not null default false,
  trashed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint notebook_item_parent_check check (
    (type = 'subject' and subject_id is null)
    or
    (type = 'note' and subject_id is not null)
  )
);

create index if not exists notebook_items_user_type_idx
  on public.notebook_items (user_id, type, trashed);

create index if not exists notebook_items_subject_idx
  on public.notebook_items (user_id, subject_id);

alter table public.notebook_items enable row level security;

create policy "Users read their own notebook"
  on public.notebook_items
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users create their own notebook"
  on public.notebook_items
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users update their own notebook"
  on public.notebook_items
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users delete their own notebook"
  on public.notebook_items
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);

revoke all on public.notebook_items from anon;
grant select, insert, update, delete on public.notebook_items to authenticated;

alter publication supabase_realtime add table public.notebook_items;
