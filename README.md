# Dossiers Ile Verte

Application du conseil syndical de la Résidence Ile Verte (Nouméa) pour suivre les travaux, les termites et les échanges avec le syndic et les entreprises.

- Connexion de chaque membre avec **son adresse e-mail et son mot de passe**.
- Cinq rubriques : AGO, dossiers travaux, demandes d'intervention, signalements, comptes rendus de réunion.
- Pour chaque dossier : discussion avec messages, photos, **enregistrements audio au micro**, PDF.
- Journal des appels et échanges : type, avec qui, jour, heure, durée, résumé, audio, suite à donner.
- Impression d'un dossier ou enregistrement en PDF.

## Comment c'est construit

| Élément | Rôle |
|---|---|
| **GitHub** | garde le code (`index.html`, `config.js`, `supabase/schema.sql`) |
| **Vercel** | publie le site à partir de GitHub, gratuitement |
| **Supabase** | comptes des membres, base de données, photos, audios et PDF |

Les données des copropriétaires ne sont **jamais** dans GitHub : elles sont dans Supabase.

---

## Mise en place (une seule fois)

### 1. Supabase : la base de données

1. Sur [supabase.com](https://supabase.com), créez un compte avec l'adresse du conseil, puis un projet nommé `dossiers-ile-verte` (région la plus proche : Sydney).
2. Menu **SQL Editor** > **New query** : collez tout le contenu de `supabase/schema.sql`, puis cliquez sur **Run**.
3. Menu **Project Settings** > **API** : copiez
   - **Project URL** (du type `https://abcdefgh.supabase.co`)
   - la clé **anon public**
4. Ouvrez `config.js` et remplacez `https://VOTRE-PROJET.supabase.co` et `VOTRE-CLE-ANON` par ces deux valeurs.

### 2. GitHub : le code

1. Sur [github.com](https://github.com), connectez-vous avec le compte du conseil.
2. **New repository** > nom `dossiers-ile-verte` > **Private** > **Create repository**.
3. Cliquez sur **uploading an existing file** et glissez : `index.html`, `config.js`, `README.md` et le dossier `supabase`.
4. Cliquez sur **Commit changes**.

### 3. Vercel : la mise en ligne

1. Sur [vercel.com](https://vercel.com), créez un compte avec **Continue with GitHub**.
2. **Add New** > **Project** > choisissez `dossiers-ile-verte` > **Deploy** (aucun réglage à changer).
3. Notez l'adresse du site, du type `https://dossiers-ile-verte.vercel.app`.

### 4. Relier Supabase au site

Dans Supabase, menu **Authentication** > **URL Configuration** :

- **Site URL** : l'adresse Vercel (ex. `https://dossiers-ile-verte.vercel.app`)
- **Redirect URLs** : ajoutez la même adresse suivie de `/**`

Sans ce réglage, les liens « confirmer mon adresse » et « mot de passe oublié » ne ramènent pas sur le site.

### 5. Reprendre les dossiers de l'ancienne application

Le dossier `dossiers-ile-verte-prive` (à côté de celui-ci, **à ne pas mettre sur GitHub**) contient :

1. `import-donnees.sql` : dans Supabase **SQL Editor**, collez son contenu et cliquez sur **Run**. Les 7 dossiers et leurs 43 échanges sont recréés.
2. `compte-rendu-cs-2026-11-16.pdf` : dans Supabase **Storage** > `pieces`, créez un dossier `migration` et déposez-y ce fichier, **sans le renommer**. Il réapparaît dans la réunion du 16 novembre.

---

## Ajouter un membre du conseil syndical

1. Connectez-vous au site avec un compte **administrateur** (au départ : conseil.syndical.ile.verte@gmail.com).
2. Bouton **Membres** en haut à droite > saisissez l'adresse e-mail du membre > **Ajouter**.
3. Prévenez le membre : il ouvre le site, clique sur **Créer mon mot de passe**, puis confirme son adresse avec le lien reçu par e-mail.

Une personne dont l'adresse n'est pas dans la liste peut créer un mot de passe, mais ne voit **aucun** dossier.

## Bon à savoir

- **Mot de passe oublié** : lien sur l'écran de connexion, un e-mail est envoyé.
- **Envoi d'e-mails** : le service gratuit de Supabase envoie peu d'e-mails par heure. Si plusieurs membres s'inscrivent le même jour, certains devront réessayer un peu plus tard.
- **Modifier l'application** : remplacez `index.html` sur GitHub ; Vercel republie le site tout seul en une minute.
- **Pour enregistrer un appel en cours**, prévenez votre interlocuteur et demandez son accord.

Contact : conseil.syndical.ile.verte@gmail.com
