cat << EOF
commit :  commande permetant de formatter le message de commit pour l'associer au module / service
          example : depuis le repertoire module/ansible/ldap
                    $ pbt commit "ajout de la fonctionnalité X"
                    donnera le message de log dans git => "[ldap] ajout de la fonctionnalité X"
release: commande de release de module s'appuyant sur la version passe enargument
         pbt release <version> [message optionnel]
         example : depuis le repertoire module/ansible/ldap
                   $pbt release 1.0.1 "c'est un breaking change"
                   met à jour le fichier version et donnera le message de log dans git => "[ldap] RELEASE 1.0.1  c'est un breaking change"

dependency : liste les dépendances d'un service ou d'un cvomposant de plateforme
          example : depuis le repertoire plateforme
                    $ pbt dependency zps-back-services

                    depuis le repertoire service/ansible/ps-common
                    $ pbt dependency requirements

help : Affiche ce message d'aide

init-ansible-config :

package :

plateforme-dependency :

publish-docker : commande permettant de pousser une image docker vers la registry $PI_BUILD_SCRIPT_DML_FDQN
                 $ pbt publish-docker <image_name> <tag>
get-docker : commande permettant de recuperer une image deocker de la registry $PI_BUILD_SCRIPT_DML_FDQN
             $ pbt get-docker  <image_name> <tag>	
publish :

requirements-cleaner :

requirements-generator :

scaffold : Permet d'échaffauder (générer un squelette) pour un module ou un service
           pbt scaffold <module|service> name
           génère un répertoire contenant
                - le role
                - les tests de base (lint, idempotence, syntax)
                - le conteneur docker de base permetant de valider l'execution du rôle
                - un Makefile pour lancer la construction du conteneur, les tests, le cleaning ...
           example : $ pbt scaffold module apache

search-dependency : Permets depuis le repertoire services d'identifier les services utilisant un role et sa version
           example : $ pbt search-dependency ldap
                     proxy-ldap  ->  openldap:1.1.0rc2
                     ps-common   ->  ldap:1.0.0rc4

sem-dependency-version :

test-parameters :
EOF
