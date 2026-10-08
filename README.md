<div align="center">
  <img src="https://raw.githubusercontent.com/ortipik/ortipik/refs/heads/main/docs/assets/orti-file.png" alt="Orti-file" width="384">
</div>
# 📂 orti-file — Analyseur de dossiers local & distant

[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20Debian%20%7C%20Arch-FCC624?logo=linux&logoColor=black)](https://www.kernel.org/)
[![SSH](https://img.shields.io/badge/SSH-Remote-4EAA25?style=for-the-badge&labelColor=0a0e1a)](#)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](#-licence)
[![Version](https://img.shields.io/badge/version-1.0-00d4ff.svg)](#)

> **Analyse exhaustive d'un site web ou d'un dossier** — inventaire, statistiques, liens internes/externes, détection des liens cassés.

---

## 📖 Sommaire

- [Présentation](#-présentation)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Exemple de sortie](#-exemple-de-sortie)
- [Détails techniques](#-détails-techniques)
- [Sécurité](#-sécurité)
- [FAQ](#-faq)
- [Licence](#-licence)

---

## 🎯 Présentation

**orti-file** est un script Bash qui produit un **rapport détaillé** sur la structure d'un site web statique (ou de n'importe quel répertoire) : nombre de fichiers par extension, taille totale, inventaire des liens (internes, externes, cassés) et bien plus.

Il fonctionne aussi bien sur un **dossier local** qu'en **mode distant** via SSH (à venir).

> 💡 Idéal pour auditer un site avant migration, détecter les liens morts, ou simplement comprendre l'architecture d'un projet existant.

---

## ✨ Fonctionnalités

### 📁 Inventaire des fichiers
- Nombre total de fichiers (toutes extensions)
- Répartition par extension : `.html`, `.php`, `.css`, `.js`, `.txt`, `.pdf`, images, autres
- Taille totale (bytes → Ko/Mo/Go lisible)

### 🔗 Analyse des liens
- Extraction de tous les liens depuis `href`, `src`, `action`
- Comptage liens internes vs externes (avec pourcentages)
- Détail des liens internes : absolus (`/`), relatifs, `.html`, `.pdf`, `.txt`, images
- Top 10 des domaines externes (classés par fréquence)
- Top 10 des fichiers HTML contenant le plus de liens

### ❌ Détection des liens cassés (404)
- Vérification de l'existence des fichiers cibles pour les liens internes
- Gestion des chemins absolus et relatifs
- Recherche par nom de fichier si le chemin exact échoue
- Affichage des 20 premiers liens cassés + total

### 🔎 Autres statistiques
- Ancres (`#`), `mailto:`, `tel:`, `javascript:`
- Liens vides (`href=""`)
- Taux de liens cassés

---

## 📋 Prérequis

- **Bash** 5.0 ou supérieur
- Utilitaires standards : `find`, `grep`, `sed`, `awk`, `wc`, `du`
- `numfmt` (optionnel — utilisé pour formater les tailles)

### Installation des dépendances

**Debian / Ubuntu :**
```bash
sudo apt install coreutils findutils grep sed gawk
```

**Arch Linux :**
```bash
sudo pacman -S coreutils findutils grep sed gawk
```

**Fedora / RHEL :**
```bash
sudo dnf install coreutils findutils grep sed gawk
```

---

## 🚀 Installation

```bash
# Cloner le dépôt
git clone https://github.com/Ortipik/orti-file.git
cd orti-file

# Rendre le script exécutable
chmod +x orti-file.sh
```

**Installation globale (optionnelle) :**
```bash
sudo cp orti-file.sh /usr/local/bin/orti-file
sudo chmod +x /usr/local/bin/orti-file
```

---

## 🎮 Utilisation

Placez-vous à la **racine** du site ou du répertoire à analyser, puis exécutez :

```bash
bash orti-file.sh
```

### Rediriger la sortie vers un fichier

```bash
bash orti-file.sh > rapport.txt
```

### Utilisation avec un dossier spécifique

```bash
cd /var/www/mon-site && bash /chemin/vers/orti-file.sh
```

> ⚠️ **Attention** : le script parcourt **tous** les fichiers du répertoire courant et de ses sous-répertoires. Pour un site de grande taille, l'exécution peut prendre quelques secondes.

---

## 📊 Exemple de sortie

```
📊 STATISTIQUES COMPLÈTES DU SITE
==================================

📁 Total fichiers (toutes extensions): 142

📄 DÉTAIL PAR EXTENSION
----------------------
   HTML: 45
   PHP: 12
   CSS: 8
   JS: 22
   TXT: 3
   PDF: 5
   Images: 32
   Autres: 15

💾 Taille totale: 1.2G

🔗 STATISTIQUES DES LIENS
-------------------------
Total liens trouvés: 684
   ✅ Liens internes: 523
   🌐 Liens externes: 161
   📊 % interne: 76%
   📊 % externe: 24%

📁 DÉTAIL DES LIENS INTERNES
---------------------------
   - Chemins absolus (commencent par /): 87
   - Chemins relatifs: 436

   - Liens vers .html: 312
   - Liens vers .pdf: 24
   - Liens vers .txt: 8
   - Liens vers images: 178

🌐 TOP 10 DOMAINES EXTERNES
--------------------------
   - github.com: 42 liens
   - stackoverflow.com: 28 liens
   - ...

❌ LIENS CASSÉS (404)
---------------------
Total liens cassés: 14

🔴 Exemples de liens cassés (20 premiers):
   - /old-page.html
   - images/logo-old.png
   - ...

🔗 AUTRES STATISTIQUES
----------------------
   - Liens vers ancres (#): 67
   - Liens mailto: 3
   - Liens tel: 1
   - Liens javascript: 0
   - Liens vides (href=""): 2

📃 TOP 10 FICHIERS AVEC LE PLUS DE LIENS
----------------------------------------
   - 145 liens: ./index.html
   - 89 liens: ./blog/index.html
   - ...

📊 RÉSUMÉ FINAL
================
✅ Fichiers total: 142
✅ Fichiers HTML: 45
✅ Liens internes: 523
✅ Liens externes: 161
❌ Liens cassés: 14
📊 Taux de liens cassés: 2.68%
```

---

## 🔧 Détails techniques

### Commandes système utilisées

| Commande | Usage |
|----------|-------|
| `find` | Lister les fichiers et filtrer par extension |
| `grep` | Extraire les attributs HTML via regex |
| `sed` | Nettoyer les valeurs d'attributs |
| `awk` | Sommer les tailles, calculer des pourcentages |
| `numfmt` | Formater la taille totale (fallback : bytes) |
| `mktemp` | Fichiers temporaires pour liens et liens cassés |

### Algorithme de détection des liens cassés

1. Extraction de tous les liens internes (non `http(s)://` et non `//`)
2. Pour chaque lien :
   - **Chemin absolu** (`/quelque-chose`) → recherche à la racine du répertoire d'exécution
   - **Chemin relatif** → test exact, puis recherche par nom dans tout l'arborescence
3. Comptage et affichage des 20 premiers liens manquants

### Fichiers temporaires

Le script crée deux fichiers temporaires (via `mktemp`) pour stocker :
- La liste de tous les liens extraits
- La liste des liens cassés

Ils sont **automatiquement supprimés** à la fin du script.

---

## 🔐 Sécurité

> ✅ **Ce script ne modifie AUCUN fichier.** Il se contente de lire et d'analyser. Vous pouvez l'exécuter en toute confiance.

**Bonnes pratiques :**

1. Exécuter le script sur un répertoire dédié (pas sur `/` ou `/home` entier !)
2. Rediriger la sortie vers un fichier pour un site volumineux :
   ```bash
   bash orti-file.sh > rapport-$(date +%Y%m%d).txt
   ```
3. Pour les très gros sites (>10 000 fichiers), prévoir plusieurs minutes d'exécution

---

## ❓ FAQ

<details>
<summary><strong>Le script fonctionne-t-il sur un site dynamique (WordPress, etc.) ?</strong></summary>

Oui, mais l'analyse des liens se limite aux fichiers HTML statiques trouvés dans le répertoire. Les liens générés dynamiquement (par PHP, JS) ne sont pas détectés.

</details>

<details>
<summary><strong>Puis-je analyser un dossier distant via SSH ?</strong></summary>

La version actuelle analyse uniquement en local. Le support distant est **prévu dans une prochaine version** — vous pouvez en attendant utiliser :
```bash
ssh user@serveur "cd /var/www/site && bash -s" < orti-file.sh > rapport-distant.txt
```

</details>

<details>
<summary><strong>Comment le script détecte-t-il les liens cassés ?</strong></summary>

Il vérifie l'existence des fichiers cibles pour les liens internes uniquement (les liens externes ne sont pas testés pour éviter de faire des requêtes HTTP). Pour les chemins relatifs, il recherche par nom dans tout l'arborescence si le chemin exact échoue.

</details>

<details>
<summary><strong>Puis-je exclure certains dossiers (node_modules, .git) ?</strong></summary>

Oui, modifiez les appels à `find` dans le script pour ajouter :
```bash
find . -type f -not -path "./node_modules/*" -not -path "./.git/*"
```

</details>

<details>
<summary><strong>Le script gère-t-il l'UTF-8 et les caractères spéciaux ?</strong></summary>

Oui, tant que votre terminal est en UTF-8 (par défaut sur la plupart des distributions modernes).

</details>

---

## 🤝 Contribuer

1. Forkez le projet
2. Créez votre branche : `git checkout -b feature/ma-fonctionnalite`
3. Committez : `git commit -m 'Ajout de ma fonctionnalité'`
4. Pushez : `git push origin feature/ma-fonctionnalite`
5. Ouvrez une Pull Request

---

## 📜 Licence

Distribué sous licence **MIT**. Voir [LICENSE](LICENSE).

---

## 👤 Auteur

**Ortipik** — pour [OMEGA-server](https://kraynux.snake-mackarel.ts.net)

- 🌐 Page : [orti-file](https://kraynux.snake-mackarel.ts.net/orti-file)
- 🐙 GitHub : [@Ortipik](https://github.com/Ortipik)

---

<div align="center">

**⭐ Si ce projet vous est utile, n'oubliez pas de lui mettre une étoile ! ⭐**

`© 2026 – Ortipik – Scripts & outils pour développeurs`

</div>
