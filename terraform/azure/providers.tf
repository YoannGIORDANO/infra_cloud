terraform {
  required_providers {
    # Provider Azure utilisé par l'exemple alternatif de déploiement.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  # Le bloc features est obligatoire même sans réglages avancés.
  features {}
}
