// Configuration de l'application Dossiers Ile Verte.
// Remplacez les deux valeurs ci-dessous par celles de votre projet Supabase :
// Supabase > Project Settings > API (ou "Data API").
// Ces deux valeurs sont publiques : elles peuvent être mises sur GitHub.
// La sécurité est assurée par la base (seuls les membres autorisés voient les dossiers).
window.ILE_VERTE_CONFIG = {
  supabaseUrl: "https://ykcmdtrfagvmhgbsxjwm.supabase.co",
  supabaseAnonKey: "sb_publishable__6rdzKQf15j62l7SayLIyw_yxD8bzgD",

  // Bouton « Gmail » : identifiant client OAuth Google (type « Application Web »).
  // Il se termine par .apps.googleusercontent.com. Il est public : il peut aller sur GitHub.
  // Voir la partie « Connexion Gmail » du README. Laissez vide tant qu'il n'est pas créé.
  googleClientId: "101133902674-qdflllkumibpno0vdrktsk6a2t613srd.apps.googleusercontent.com",
  // Facultatif : adresse Gmail proposée par défaut dans la fenêtre de connexion Google.
  gmailAccount: ""
};
