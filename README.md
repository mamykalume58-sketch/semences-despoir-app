# Les Semences d'Espoir — app Flutter

Adaptation mobile du site web (Vite + HTML/CSS/JS). Même charte (vert #0B6B3A / or #FFC107, Poppins), mêmes contenus.

## Navigation

Barre de navigation basse (5 onglets) : **Accueil · Projets · Don · Actualités · Plus**.
Les autres pages s'ouvrent par-dessus : détail projet, détail actualité, Qui sommes-nous, Actions,
Galerie, Bénévolat, Contact. Le bouton retour système ramène d'abord à l'Accueil.

## Où est passé le footer

| Bloc du footer web | Emplacement dans l'app |
|---|---|
| Logo + slogan + phrase de présentation | Carte d'en-tête de l'onglet **Plus** |
| Colonne « Navigation » | Remplacée par la barre du bas + menu « Découvrir » de **Plus** |
| Colonne « Nous contacter » (tél, WhatsApp, email, adresse) | Section « Nous contacter » de **Plus** + écran **Contact** (mêmes tuiles, widget `ContactTiles`) |
| Colonne « Faire la différence » | Onglet **Don** + entrées « Devenir bénévole » / « Nous écrire » de **Plus** |
| Réseaux sociaux (FB, WA, IG, TT, YT) | Rangée d'icônes en bas de **Plus** (`SocialRow`) |
| © année — Tous droits réservés | Bas de **Plus** |

Toutes ces données viennent d'un seul fichier : `lib/data/app_info.dart` (numéro, email, adresse, liens sociaux).
Les liens Facebook / Instagram / TikTok / YouTube sont vides comme dans le site (`#`) : renseigner l'URL
dans `AppInfo.socials`, sinon un message « Lien bientôt disponible » s'affiche.

## Données

- `lib/data/demo_data.dart` : contenus de démonstration repris du site (projets, actualités, actions, galerie, stats).
- `lib/services/submissions.dart` : formulaires (don, bénévolat, contact, newsletter) — simulés, comme sur le site
  avant branchement Firebase. Le schéma Firestore du README web s'applique tel quel quand on branchera.
- Photos : encadrés placeholders. Renseigner `imageUrl` (projets, actualités) ou `url` (galerie) pour afficher
  une vraie image réseau.

## Build de l'APK (GitHub Actions, sans SDK local)

Le dépôt contient uniquement `lib/`, `pubspec.yaml` et le workflow `.github/workflows/build-apk.yml`.
Le workflow génère `android/` à la volée, ajoute la permission INTERNET (nécessaire aux polices Google et aux
images) et publie l'APK en artefact (`semences-despoir-apk`, 90 jours).

```bash
git init && git add . && git commit -m "Init app Flutter Semences d'Espoir"
# puis push sur le dépôt GitHub (branche main) → onglet Actions → Build APK
```
