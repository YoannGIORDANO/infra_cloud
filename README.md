# Infrastructure Wiki.js — Déploiement IaC

Déploiement automatisé et reproductible d'une infrastructure web (Wiki.js) sur Proxmox, via **cloud-init**, **Terraform/OpenTofu** et **Ansible**.

## Architecture

Deux machines virtuelles créées et configurées entièrement par le code :

| VM | Rôle | Logiciels |
| :-- | :-- | :-- |
| `wiki-web` | Serveur web | Wiki.js (Node.js) + Nginx (reverse proxy) |
| `wiki-db` | Base de données | PostgreSQL |

Le site est accessible publiquement via une redirection de port vers le port 80 de `wiki-web`.

## Prérequis

- OpenTofu (ou Terraform) et Ansible installés
- Un accès à un serveur Proxmox (API + SSH)
- Une paire de clés SSH

## Structure du dépôt

    infra-wiki/
    ├── terraform/        # création des VM (cloud-init + Terraform)
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── cloud-init/
    ├── ansible/          # configuration des applications
    │   ├── inventory.ini
    │   ├── playbook.yml
    │   ├── group_vars/
    │   └── roles/        # common, postgresql, wikijs, nginx
    └── screenshot/       # captures des déploiements réussis

## Déploiement

### 1. Configurer les accès

Créer `terraform/terraform.tfvars` (non versionné) à partir de `terraform.tfvars.example`, avec vos valeurs réelles (endpoint, token API, clé publique).

### 2. Créer les VM (Terraform)

    cd terraform
    tofu init
    tofu plan
    tofu apply

Les IP des VM s'affichent en sortie.

### 3. Configurer les applications (Ansible)

    cd ../ansible
    ansible-galaxy collection install community.postgresql
    ansible-playbook playbook.yml

Le mot de passe de la base est chiffré avec **Ansible Vault**. Le fichier `.vault_pass` (non versionné) doit contenir le mot de passe du vault, fourni séparément.

### 4. Accéder au site

Ouvrir dans un navigateur : `http://IP_PUBLIQUE:4080/`

## Sécurité

- Secrets (token, mots de passe, clés) exclus du dépôt via `.gitignore`
- Mot de passe de la base chiffré avec Ansible Vault
- PostgreSQL accessible uniquement depuis `wiki-web` (règle pg_hba)
- Wiki.js écoute en local (127.0.0.1), exposé uniquement via Nginx
