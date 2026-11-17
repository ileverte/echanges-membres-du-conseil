-- =====================================================================
--  Dossiers Ile Verte : base de données Supabase
--  À copier-coller UNE FOIS dans Supabase > SQL Editor > New query > Run
-- =====================================================================

-- 1. Liste des adresses e-mail autorisées (membres du conseil syndical)
create table if not exists public.acces (
  email      text primary key,
  admin      boolean not null default false,
  ajoute_le  timestamptz not null default now()
);

-- Premier administrateur : l'adresse du conseil syndical.
insert into public.acces (email, admin)
values ('conseil.syndical.ile.verte@gmail.com', true)
on conflict (email) do update set admin = true;

-- 2. Fonctions de contrôle d'accès
create or replace function public.est_membre() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.acces
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

create or replace function public.est_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.acces
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')) and admin
  );
$$;

-- 3. Profils des membres (nom affiché, lot, rôle)
create table if not exists public.membres (
  id      uuid primary key references auth.users (id) on delete cascade,
  email   text,
  nom     text,
  lot     text,
  role    text,
  maj_le  timestamptz not null default now()
);

-- 4. Dossiers
create table if not exists public.dossiers (
  id           text primary key default gen_random_uuid()::text,
  cat          text not null check (cat in ('ago','travaux','intervention','signalement','reunion')),
  titre        text not null,
  batiment     text,
  statut       text not null default 'ouvert',
  priorite     text not null default 'normale',
  date_ref     date,
  intervenant  text,
  reference    text,
  description  text,
  reunion      jsonb,
  auteur       uuid references auth.users (id) on delete set null,
  auteur_nom   text,
  cree_le      timestamptz not null default now(),
  maj_le       timestamptz not null default now(),
  dernier      jsonb
);

-- 5. Messages, appels et échanges (une ligne par entrée du fil)
create table if not exists public.messages (
  id          text primary key default gen_random_uuid()::text,
  dossier_id  text not null references public.dossiers (id) on delete cascade,
  type        text,                 -- null = message, 'contact' = appel/échange, 'statut'
  auteur      uuid references auth.users (id) on delete set null,
  auteur_nom  text,
  texte       text,
  pieces      jsonb not null default '[]'::jsonb,
  cree_le     timestamptz not null default now(),
  canal       text, sens text, quand timestamptz, duree int,
  qui         text, organisme text, tel text, suite text,
  de          text, a text
);
create index if not exists messages_dossier_idx on public.messages (dossier_id, cree_le);

-- 6. Sécurité : seuls les membres autorisés lisent et écrivent
alter table public.acces    enable row level security;
alter table public.membres  enable row level security;
alter table public.dossiers enable row level security;
alter table public.messages enable row level security;

drop policy if exists acces_lecture on public.acces;
create policy acces_lecture on public.acces for select to authenticated using (public.est_membre());
drop policy if exists acces_ajout on public.acces;
create policy acces_ajout on public.acces for insert to authenticated with check (public.est_admin());
drop policy if exists acces_modif on public.acces;
create policy acces_modif on public.acces for update to authenticated using (public.est_admin());
drop policy if exists acces_suppr on public.acces;
create policy acces_suppr on public.acces for delete to authenticated using (public.est_admin());

drop policy if exists membres_lecture on public.membres;
create policy membres_lecture on public.membres for select to authenticated using (public.est_membre());
drop policy if exists membres_soi on public.membres;
create policy membres_soi on public.membres for insert to authenticated with check (public.est_membre() and id = auth.uid());
drop policy if exists membres_soi_maj on public.membres;
create policy membres_soi_maj on public.membres for update to authenticated using (public.est_membre() and id = auth.uid());

drop policy if exists dossiers_lecture on public.dossiers;
create policy dossiers_lecture on public.dossiers for select to authenticated using (public.est_membre());
drop policy if exists dossiers_ajout on public.dossiers;
create policy dossiers_ajout on public.dossiers for insert to authenticated with check (public.est_membre());
drop policy if exists dossiers_modif on public.dossiers;
create policy dossiers_modif on public.dossiers for update to authenticated using (public.est_membre());
drop policy if exists dossiers_suppr on public.dossiers;
create policy dossiers_suppr on public.dossiers for delete to authenticated using (public.est_admin() or auteur = auth.uid());

drop policy if exists messages_lecture on public.messages;
create policy messages_lecture on public.messages for select to authenticated using (public.est_membre());
drop policy if exists messages_ajout on public.messages;
create policy messages_ajout on public.messages for insert to authenticated with check (public.est_membre() and auteur = auth.uid());
drop policy if exists messages_suppr on public.messages;
create policy messages_suppr on public.messages for delete to authenticated using (public.est_admin() or auteur = auth.uid());

-- 7. Stockage des photos, audios et PDF (privé)
insert into storage.buckets (id, name, public, file_size_limit)
values ('pieces', 'pieces', false, 52428800)
on conflict (id) do nothing;

drop policy if exists pieces_lecture on storage.objects;
create policy pieces_lecture on storage.objects for select to authenticated
  using (bucket_id = 'pieces' and public.est_membre());
drop policy if exists pieces_ajout on storage.objects;
create policy pieces_ajout on storage.objects for insert to authenticated
  with check (bucket_id = 'pieces' and public.est_membre());
drop policy if exists pieces_suppr on storage.objects;
create policy pieces_suppr on storage.objects for delete to authenticated
  using (bucket_id = 'pieces' and (public.est_admin() or owner = auth.uid()));

-- 8. Mises à jour en direct (les nouveaux messages apparaissent sans recharger)
do $$
begin
  begin alter publication supabase_realtime add table public.dossiers; exception when others then null; end;
  begin alter publication supabase_realtime add table public.messages; exception when others then null; end;
  begin alter publication supabase_realtime add table public.membres; exception when others then null; end;
end $$;
