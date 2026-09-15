drop index if exists public.notebook_items_subject_idx;

create index if not exists notebook_items_subject_fk_idx
  on public.notebook_items (subject_id)
  where subject_id is not null;
