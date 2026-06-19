# Infrastructure Wiki.js — Déploiement IaC

Déploiement automatisé et reproductible d'une infrastructure web (Wiki.js) sur Proxmox, via **cloud-init**, **Terraform/OpenTofu** et **Ansible**. Conçu pour être multi-environnement (dev/prod) et multi-fournisseur (Proxmox/Azure).

## Architecture

| VM | Rôle | Logiciels |
| :-- | :-- | :-- |
| `wiki-web` | Serveur web | Wiki.js (Node.js) + Nginx |
| `wiki-db` | Base de données | PostgreSQL |

Site exposé publiquement via une redirection de port vers le port 80 de `wiki-web`.

## Prérequis

- OpenTofu (ou Terraform) et Ansible
- Un accès à un serveur Proxmox (API + SSH)
- Une paire de clés SSH

## Structure du dépôt

    infra-wiki/
    ├── terraform/            # déploiement Proxmox
    │   ├── cloud-init/       # bootstrap des VM (partagé)
    │   ├── environments/     # dev.tfvars, prod.tfvars
    │   ├── templates/        # modèle d'inventaire Ansible
    │   └── azure/            # déploiement Azure (multi-fournisseur)
    ├── ansible/              # configuration applicative
    │   ├── playbook.yml
    │   ├── group_vars/       # variables + secret chiffré (Vault)
    │   └── roles/            # common, postgresql, wikijs, nginx, firewall
    └── screenshot/           # preuves de déploiement

## Déploiement

### 1. Configurer les accès

Créer `terraform/terraform.tfvars` à partir de `terraform.tfvars.example` (endpoint, token API, clé SSH publique).

### 2. Créer les VM (Terraform)

    cd terraform
    tofu init
    tofu workspace new prod        # ou: tofu workspace select prod
    tofu apply -var-file=environments/prod.tfvars

L'inventaire Ansible (`ansible/inventory-prod.ini`) est **généré automatiquement** avec les IP des VM.

### 3. Configurer les applications (Ansible)

    cd ../ansible
    ansible-galaxy collection install community.postgresql community.general
    ansible-playbook -i inventory-prod.ini playbook.yml

Le mot de passe de la base est chiffré avec **Ansible Vault** (`.vault_pass` non versionné, fourni séparément).

### 4. Accéder au site

Ouvrir : `http://IP_PUBLIQUE:4080/`

## Environnements (dev / prod)

Le même code déploie plusieurs environnements via les **workspaces** Terraform :

    tofu workspace select dev
    tofu apply -var-file=environments/dev.tfvars

Chaque environnement a son propre état et ses propres VM (IDs distincts).

## Sécurité

- Secrets (token, mots de passe, clés) exclus du dépôt via `.gitignore`
- Mot de passe de la base chiffré avec Ansible Vault
- Pare-feu **ufw** : seuls SSH et HTTP exposés ; PostgreSQL joignable uniquement depuis `wiki-web`
- Wiki.js écoute en `127.0.0.1`, exposé uniquement via Nginx

## Multi-fournisseur (Proxmox / Azure)

- `terraform/` : déploiement **Proxmox** (production)
- `terraform/azure/` : déploiement équivalent **Azure** (module azurerm), même cloud-init
- `ansible/` : configuration **identique** quel que soit le fournisseur

Seul le module Terraform change selon le fournisseur. Ansible ne connaît que des IP et du SSH.

## Collaborateur
Giordano Yoann, Souri Ayoub, Bouchouareb Eddy, Inkari Johan.
