# Tooling pour le scaffolding, l'assemblage, la publication des composants de Plateform Integrator

# Installation

Après avoir cloné le dépot l'installer via install.sh
Il faut régulièrement, sur sa machine penser à mettre à jour les outils via un git pull

# Contenu

|
| - bin : commandes offertes par pibuild-tools
| - tpl : contient un repertoire tpl contenant les differents templates utilisés par l'outil pour le scaffolding de module et de service

## Liste des commmandes
* commit
```
commande permetant de formatter le message de commit pour l'associer au module / service
depuis le repertoire module/ansible/ldap
$ pbt commit "ajout de la fonctionnalité X"
donnera le message de log dans git => "[ldap] ajout de la fonctionnalité X" 
```

* release
```
commande de release de module s'appuyant sur la version passe enargument
pbt release <version> [message optionnel]          
example : depuis le repertoire module/ansible/ldap
$pbt release 1.0.1 "c'est un breaking change"
met à jour le fichier version et donnera le message de log dans git => "[ldap] RELEASE 1.0.1  c'est un breaking change"
```

* dependency
```
liste les dépendances d'un service ou d'un composant de plateforme
             depuis le repertoire plateforme
             $ pbt dependency group-back-services
             depuis le repertoire service/ansible/ps-common
             $ pbt dependency requirements 
```

* help
```
Affiche le message d'aide
```

* init-ansible-config
```
gènere le fichier ansible.cg pour les tests
```

* plateforme-dependency :
```
invoqué avec les options <import|check|package|clean>
permet d'importer les dépendances de la plateforme
permet de valider l'existance des dépendances de la plateforme
permet de packager les dépendances de la plateforme
permet de nettoyer les dépendances de la plateforme
```

* publish-docker :
```
commande permettant de pousser une image docker vers la registry $PI_BUILD_SCRIPT_DML_FDQN
$ pbt publish-docker <image_name> <tag> get-docker : commande permettant de recuperer une image deocker de la registry $PI_BUILD_SCRIPT_DML_FDQN
$ pbt get-docker  <image_name> <tag>	
```

* publish
```
commande de publication d'un artefact vers la DML
```

* requirements-cleaner
```
nettoie les dépendances ansible pour les services et la plaateforme
```

* requirements-generator
```
genère les dépendances ansible pour les services et la plaateforme
```
* scaffold
```
Permet d'échaffauder (générer un squelette) pour un module ou un service
pbt scaffold <module|service> name
génère un répertoire contenant
  - le role
  - les tests de base (lint, idempotence, syntax)
  - le conteneur docker de base permetant de valider l'execution du rôle
  - un Makefile pour lancer la construction du conteneur, les tests, le cleaning ...
example : $ pbt scaffold module apache 
```

* search-dependency
```
Permets depuis le repertoire services d'identifier les services utilisant un role et sa version
    example : $ pbt search-dependency ldap
    proxy-ldap  ->  openldap:1.1.0rc2
    ps-common   ->  ldap:1.0.0rc4 
```

* sem-dependency-version : 
* test-parameters :
