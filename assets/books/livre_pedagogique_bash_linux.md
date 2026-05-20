# Livre Pédagogique Bash Linux

# Chapitre 1 : Les Bases de la Ligne de Commande

commande : Le nom du programme à exécuter (ex: ls).

-options : Modifie le comportement de la commande (ex: -l pour un affichage détaillé). Les options peuvent être courtes (-h) ou longues (--help).

arguments : Ce sur quoi la commande s'applique (ex: un nom de fichier ou de dossier).

## 1.3 Obtenir de l'aide : L'art du "RTFM"
En Linux, l'aide est toujours à portée de main. Il est inutile d'apprendre par cœur toutes les options.

man <commande> : Affiche le manuel complet d'une commande (Quitter avec la touche q).

whatis <commande> : Donne une description très brève d'une commande.

<commande> --help ou <commande> -h : Affiche une aide rapide de la syntaxe.

Exemple:

```bash
man ls
whatis grep
```

# Chapitre 2 : Navigation et Gestion du Système de Fichiers
## 2.1 L'arborescence Linux
Contrairement à Windows où chaque disque a sa lettre (C:, D:), Linux utilise une arborescence unique sous forme d'arbre inversé, dont la base est la racine notée /.

/bin et /sbin : Programmes et exécutables essentiels.

/home : Dossiers personnels des utilisateurs (ex: /home/jean).

/root : Le répertoire personnel du super-utilisateur (administrateur).

/etc : Fichiers de configuration du système.

/var : Données variables (fichiers de logs, bases de données).

/tmp : Fichiers temporaires (effacés au redémarrage).

## 2.2 Les commandes de navigation
pwd (Print Working Directory) : Affiche le chemin complet du dossier où vous vous trouvez.

cd <chemin> (Change Directory) : Permet de se déplacer.

cd / : Aller à la racine.

cd ~ ou simplement cd : Retourner dans votre dossier personnel (/home/utilisateur).

cd .. : Remonter au dossier parent.

cd - : Retourner au dossier précédent.

ls (List) : Liste le contenu du dossier actuel.

ls -l : Format long (affiche les permissions, la taille, la date).

ls -a : Affiche tous les fichiers, y compris les fichiers cachés (ceux qui commencent par un point .).

ls -lh : Format long avec des tailles lisibles par l'humain (Ko, Mo, Go).

## 2.3 Manipulation des fichiers et dossiers
mkdir <nom> (Make Directory) : Crée un dossier.

mkdir -p dossier1/dossier2/dossier3 : Crée toute la structure de dossiers imbriqués d'un coup.

touch <fichier> : Crée un fichier vide (ou met à jour sa date de modification).

cp <source> <destination> (Copy) : Copie un fichier.

cp -r <source_dossier> <dest_dossier> : Copie récursive (obligatoire pour les dossiers).

mv <source> <destination> (Move) : Déplace ou renomme un fichier/dossier.

rm <fichier> (Remove) : Supprime un fichier. Attention : il n'y a pas de corbeille en ligne de commande !

rm -r <dossier> : Supprime un dossier et tout son contenu.

rm -rf <dossier> : Force la suppression sans demander de confirmation (à manipuler avec une extrême prudence).

# Chapitre 3 : Visualisation et Édition de Fichiers Textes
## 3.1 Affichage de contenu
cat <fichier> : Affiche l'intégralité du contenu d'un fichier à l'écran.

less <fichier> : Permet de naviguer dans un long fichier texte page par page (Flèches pour défiler, q pour quitter).

head -n X <fichier> : Affiche les X premières lignes d'un fichier.

tail -n X <fichier> : Affiche les X dernières lignes d'un fichier.

tail -f <fichier> : Observe en temps réel l'évolution d'un fichier (très utilisé pour surveiller les logs système).

## 3.2 Édition de fichiers dans le terminal
nano : L'éditeur le plus simple pour débuter. Les raccourcis sont affichés en bas (^O pour enregistrer veut dire Ctrl + O, ^X pour quitter).

vim / vi : L'éditeur ultra-puissant mais complexe. Il possède plusieurs modes :

Mode Commande (par défaut) : pour copier, coller, se déplacer.

Mode Insertion (appuyer sur i) : pour écrire du texte.

Pour quitter : Appuyer sur Échap, taper :wq pour sauvegarder et quitter, ou :q! pour quitter sans sauvegarder.

# Chapitre 4 : Flux, Redirections et Tubes (Pipes)
C'est ici que réside la véritable puissance de la philosophie Unix : "Faire une seule chose, et la faire bien, et permettre aux programmes de collaborer".

## 4.1 Entrée et sorties standards
Chaque commande possède 3 flux par défaut :

Champs standard d'entrée (stdin) : Clavier (représenté par le chiffre 0).

Sortie standard (stdout) : Écran pour les résultats (représenté par 1).

Erreur standard (stderr) : Écran pour les messages d'erreur (représenté par 2).

## 4.2 Les Redirections
> : Redirige la sortie standard vers un fichier (écrase le fichier s'il existe).

echo "Bonjour" > salut.txt

>> : Redirige la sortie standard en l'ajoutant à la fin du fichier (sans l'écraser).

2> : Redirige uniquement les erreurs vers un fichier.

commande_inconnue 2> erreurs.log

2>&1 : Fusionne les erreurs et la sortie standard.

< : Redirige l'entrée standard (lit le contenu d'un fichier comme si on le tapait).

## 4.3 Le Tube / Pipe (|)
Le symbole | permet d'envoyer la sortie (stdout) d'une commande directement dans l'entrée (stdin) d'une autre commande. On peut ainsi enchaîner les traitements.

Exemple:

```bash
ls -lh /etc | less
# Envoie la liste des fichiers de /etc dans l'outil de lecture pas à pas
# Chapitre 5 : Gestion des Utilisateurs et des Permissions
Linux est un système multi-utilisateur et sécurisé. Chaque fichier appartient à un utilisateur et à un groupe, avec des droits d'accès bien précis.

## 5.1 Comprendre la structure des permissions
Lorsque vous faites ls -l, vous voyez une chaîne de 10 caractères comme -rwxr-xr--.

Le 1er caractère indique le type : - (fichier), d (dossier), l (lien symbolique).

Les 9 caractères suivants sont divisés en 3 groupes de 3 :

Propriétaire (User - u) : Les 3 premiers caractères.

Groupe (Group - g) : Les 3 caractères du milieu.

Autres (Others - o) : Les 3 derniers caractères.

Chaque groupe de 3 peut contenir :

r (Read) : Lecture (valeur numérique = 4)

w (Write) : Écriture/Modification (valeur numérique = 2)

x (Execute) : Exécution de programme ou traversée de dossier (valeur numérique = 1)

- : Aucun droit (valeur numérique = 0)

## 5.2 Modifier les permissions : chmod
On peut modifier les permissions de deux manières :

Méthode Symbolique
Bash
chmod u+x fichier.sh      # Ajoute le droit d'exécution au propriétaire
chmod g-w fichier.txt     # Enlève le droit d'écriture au groupe
chmod o=r fichier.txt     # Donne uniquement le droit de lecture aux autres
Méthode Numérique (Octale)
On additionne les valeurs des droits souhaités pour chaque entité (User, Group, Other).

7 = 4 + 2 + 1 (rwx)

6 = 4 + 2 (rw-)

4 = 4 (r--)

Bash
chmod 755 script.sh       # u=rwx (7), g=rx (5), o=rx (5)
chmod 644 document.txt    # u=rw (6), g=r (4), o=r (4)
## 5.3 Changer de propriétaire : chown et chgrp
Ces commandes nécessitent souvent les privilèges d'administrateur.

chown utilisateur fichier : Change le propriétaire.

chown utilisateur:groupe fichier : Change le propriétaire ET le groupe.

chgrp groupe fichier : Change le groupe uniquement.

## 5.4 Devenir Super-Utilisateur : sudo et su
Le compte root a tous les droits sur la machine. Pour des raisons de sécurité, on ne se connecte pas directement en root.

sudo <commande> : Exécute une commande unique avec les privilèges root.

sudo -i ou sudo su : Ouvre une session shell interactive en tant que root.

# Chapitre 6 : Gestion des Processus et du Système
Un processus est un programme en cours d'exécution.

## 6.1 Surveiller les processus
ps : Liste les processus de la session en cours.

ps aux ou ps -ef : Liste l'intégralité des processus en cours sur le système, tous utilisateurs confondus.

top : Affiche en temps réel l'utilisation du processeur, de la mémoire et les processus actifs (Touche q pour quitter).

htop : Une version moderne, colorée et interactive de top (souvent à installer via le gestionnaire de paquets).

## 6.2 Contrôler les processus
Chaque processus possède un identifiant unique appelé PID (Process ID).

kill <PID> : Envoie un signal d'arrêt doux au processus (Signal 15 - SIGTERM).

kill -9 <PID> : Force l'arrêt immédiat et brutal du processus (Signal 9 - SIGKILL).

killall <nom_du_programme> : Tue tous les processus portant ce nom.

## 6.3 Gestion des tâches en arrière-plan (Job Control)
Ajouter & à la fin d'une commande pour la lancer directement en arrière-plan.

sleep 100 &

Ctrl + Z : Met en pause le processus en cours au premier plan.

jobs : Liste les tâches en cours ou suspendues dans la session.

bg %ID : Relance une tâche suspendue en arrière-plan (background).

fg %ID : Ramène une tâche d'arrière-plan au premier plan (foreground).

## 6.4 Informations système utiles
df -h : Affiche l'espace disque disponible sur les différentes partitions.

free -h : Affiche l'utilisation de la mémoire vive (RAM) et du Swap.

uname -a : Donne les informations sur le noyau Linux utilisé.

uptime : Indique depuis combien de temps la machine est allumée.

# Chapitre 7 : Recherche de Fichiers et Filtrage de Texte
## 7.1 Trouver des fichiers avec find
La commande find parcourt l'arborescence pour chercher des fichiers selon des critères précis.

Bash
find /chemin -name "nom_du_fichier"
Exemples :

Bash
find /home/jean -name "*.pdf"                 # Trouve tous les PDF de Jean
find /var/log -type f -mtime -7               # Fichiers (-type f) modifiés ces 7 derniers jours
find . -size +100M                            # Fichiers de plus de 100 Mo dans le dossier actuel
## 7.2 L'indispensable grep : Filtrer le texte
grep permet de chercher un motif (une chaîne de caractères) à l'intérieur d'un fichier ou d'un flux.

Bash
grep "motif" fichier
Options courantes :

grep -i : Ignore la casse (majuscules/minuscules).

grep -v : Inverse la recherche (affiche les lignes qui ne contiennent PAS le motif).

grep -r : Recherche récursive dans tous les fichiers d'un répertoire.

grep -n : Affiche les numéros de ligne du résultat.

Combinaison magique avec un Pipe :

Bash
ps aux | grep "nginx"      # Cherche si le serveur web nginx est en cours d'exécution
# Chapitre 8 : Introduction au Scripting Bash
Un script Bash est simplement un fichier texte contenant une suite de commandes Linux exécutées séquentiellement.

## 8.1 Structure de base d'un script
Créez un fichier nommé mon_script.sh :

Bash
#!/bin/bash
# Ceci est un commentaire

echo "Début du script de démonstration"
echo "L'utilisateur actuel est : $USER"
Explications importantes :

#!/bin/bash : Appelée le Shebang, cette première ligne indique au système quel interpréteur utiliser pour exécuter le script.

Pour exécuter le script, il faut lui donner les droits d'exécution et spécifier son chemin :

Bash
chmod +x mon_script.sh
./mon_script.sh
## 8.2 Les Variables
En Bash, il ne faut pas mettre d'espaces autour du signe = lors de la déclaration. Pour appeler une variable, on utilise le symbole $.

Bash
prenom="Alice"
age=25

echo "Je m'appelle $prenom et j'ai $age ans."
## 8.3 Les Variables Spéciales (Arguments)
Quand vous passez des paramètres à un script (./script.sh param1 param2) :

$0 : Le nom du script lui-même.

$1, $2, $3... : Le premier, deuxième, troisième argument.

$# : Le nombre total d'arguments passés au script.

$? : Le code de retour de la dernière commande exécutée (0 = succès, autre chose = erreur).

## 8.4 Les Structures Conditionnelles (if)
La syntaxe des tests en Bash exige des espaces stricts à l'intérieur des crochets [ ].

Bash
#!/bin/bash

note=15

if [ $note -ge 10 ]; then
    echo "Félicitations, tu as la moyenne !"
else
    echo "Désolé, tu as échoué."
fi
Opérateurs de comparaison d'entiers :

-eq : Égal à (Equal)

-ne : Différent de (Not Equal)

-gt : Strictement supérieur (Greater Than)

-ge : Supérieur ou égal (Greater or Equal)

-lt : Strictement inférieur (Less Than)

-le : Inférieur ou égal (Less or Equal)

## 8.5 Les Boucles (for et while)
La boucle for (itérer sur une liste)
Bash
#!/bin/bash

for fruit in Pomme Poire Banane; do
    echo "J'aime manger des ${fruit}s."
done
La boucle while (tant que la condition est vraie)
Bash
#!/bin/bash

compteur=1
while [ $compteur -le 5 ]; do
    echo "Numéro : $compteur"
    compteur=$((compteur + 1)) # Syntaxe pour le calcul arithmétique
done
# Chapitre 9 : Commandes Avancées et Outils de Réseau
## 9.1 Compression et Archivage
tar : L'outil d'archivage standard.

tar -cvf archive.tar dossier/ : Crée (c) une archive au format tar de manière verbeuse (v) dans le fichier (f) spécifié.

tar -xvf archive.tar : Extrait (x) l'archive.

tar -zcvf archive.tar.gz dossier/ : Crée une archive compressée avec Gzip (z).

tar -zxvf archive.tar.gz : Décompresse une archive .tar.gz.

zip / unzip : Pour le format standard d'interopérabilité avec Windows.

## 9.2 Réseau et Téléchargement
ping <adresse_IP_ou_domaine> : Teste la connectivité réseau avec une machine distante.

curl -O <URL> : Télécharge un fichier depuis le web via son URL.

wget <URL> : Autre outil populaire pour télécharger des fichiers.

ip a (ou l'ancien ifconfig) : Affiche les interfaces réseau et les adresses IP de votre machine.

netstat -tulpen ou ss -tulpen : Liste tous les ports réseau ouverts et à l'écoute sur la machine.

## 9.3 Connexion à distance sécurisée : ssh
Le protocole SSH (Secure Shell) permet de prendre le contrôle d'une machine Linux à distance via une liaison chiffrée.

Bash
ssh utilisateur@adresse_ip_du_serveur
# Exemple : ssh debian@192.168.1.50
Annexe : Tableau récapitulatif des commandes indispensables
Commande	Rôle	Exemple d'utilisation
pwd	Affiche le répertoire de travail actuel	pwd
ls	Liste les fichiers et dossiers	ls -lah
cd	Change de répertoire	cd /var/log
mkdir	Crée un dossier	mkdir -p projet/src
touch	Crée un fichier vide	touch index.html
cp	Copie des fichiers/dossiers	cp -r source/ dest/
mv	Déplace ou renomme	mv ancien_nom.txt nouveau_nom.txt
rm	Supprime un fichier ou dossier	rm -rf /tmp/test
cat	Affiche le contenu d'un fichier	cat /etc/hostname
grep	Cherche un texte dans un flux/fichier	grep "error" /var/log/syslog
chmod	Modifie les permissions	chmod 755 script.sh
chown	Modifie le propriétaire/groupe	chown root:root fichier
ps	Liste les processus	ps aux
kill	Arrête un processus via son PID	kill -9 1234
df	Espace disque des partitions	df -h
history	Liste les anciennes commandes tapées	history
Félicitations ! Vous possédez maintenant les bases fondamentales et intermédiaires pour administrer un système Linux et automatiser vos tâches grâce au script Bash.
"""

file_name = "livre_pedagogique_bash_linux.md"

with open(file_name, "w", encoding="utf-8") as f:
f.write(markdown_content)

print(f"Fichier généré avec succès : {file_name}")

Votre livre pédagogique complet sur Linux et le Bash a été généré avec succès au format Markdown.

[file-tag: code-generated-file-0-1779306794217476882]

Ce manuel complet a été conçu de manière très progressive pour vous accompagner du terminal de base jusqu'aux concepts de scripting avancés. Voici un aperçu de la structure du document inclus dans le fichier Markdown :

1. **Chapitre 1 : Les Fondations de Linux et du Terminal**
   * Introduction au noyau, aux distributions et au fonctionnement fondamental du Shell.
   * Décryptage de la syntaxe d'une commande (options, arguments).
   * Comment utiliser efficacement l'aide intégrée (`man`, `--help`).

2. **Chapitre 2 : Navigation et Gestion du Système de Fichiers**
   * Compréhension de l'arborescence Linux unique (`/`, `/home`, `/etc`, `/var`, etc.).
   * Commandes indispensables de déplacement et de listing (`pwd`, `cd`, `ls`).
   * Manipulation sécurisée de fichiers et dossiers (`mkdir`, `touch`, `cp`, `mv`, `rm`).

3. **Chapitre 3 : Visualisation et Édition de Fichiers Textes**
   * Lecture de fichiers (`cat`, `less`, `head`, `tail` avec l'option de surveillance `-f`).
   * Prise en main des éditeurs textuels en console (`nano` et une initiation à `vim`).

4. **Chapitre 4 : Flux, Redirections et Tubes (Pipes)**
   * La philosophie Unix.
   * Entrée (`stdin`), Sortie (`stdout`) et Erreur (`stderr`) standards.
   * Redirections (`>`, `>>`, `2>`) et l'utilisation de l'outil ultra-puissant qu'est le tube (`|`).

5. **Chapitre 5 : Gestion des Utilisateurs et des Permissions**
   * Explication détaillée des droits d'accès (`-rwxr-xr--`).
   * Modification via la méthode symbolique ou numérique octale (`chmod`).
   * Attribution de propriété (`chown`, `chgrp`) et privilèges administrateur (`sudo`).

6. **Chapitre 6 : Gestion des Processus et du Système**
   * Surveillance de l'état système et des ressources (`ps`, `top`, `df`, `free`).
   * Contrôle et arrêt forcé des processus (`kill`, `killall`).
   * Gestion du premier plan et arrière-plan (`&`, `jobs`, `fg`, `bg`).

7. **Chapitre 7 : Recherche de Fichiers et Filtrage de Texte**
   * Exploration de l'arborescence avec des critères précis via `find`.
   * Recherche de chaînes de caractères et filtrage avec l'incontournable `grep`.

8. **Chapitre 8 : Introduction au Scripting Bash**
   * Écriture d'un script propre (Shebang `#!/bin/bash`).
   * Variables standard et variables d'arguments (`$1`, `$#`, `$?`).
   * Structures conditionnelles (`if` avec les comparateurs `-eq`, `-lt`, etc.).
   * Boucles itératives (`for`) et conditionnelles (`while`).

9. **Chapitre 9 : Commandes Avancées et Outils de Réseau**
   * Compression (`tar`, `gzip`, `zip`).
   * Analyse réseau et téléchargement web (`ping`, `ip a`, `curl`, `wget`).
   * Administration à distance sécurisée avec `ssh`.

10. **Annexe : Tableau récapitulatif**
    * Un tableau de synthèse regroupant les commandes indispensables, leurs rôles et des exemples concrets pour servir de fiche de triche (*cheat sheet*).

Vous pouvez ouvrir ce fichier `.md` avec n'importe quel éditeur de texte (VS Code, Obsidian, Notion, ou directement dans votre terminal avec `less` ou `nano`) pour commencer votre apprentissage !
# Atelier pratique Bash Linux

## Exercices pratiques
1. Crée l'arborescence `atelier/linux/{logs,data,backup}` puis crée 3 fichiers texte dans `data`.
2. Copie tous les `.txt` vers `backup` en conservant les permissions.
3. Trouve tous les fichiers modifiés dans les 24 dernières heures sous `/var/log`.
4. Redirige la sortie de `ls -la /etc` dans `etat_etc.txt` et les erreurs dans `erreurs_etc.log`.
5. Lance `tail -f` sur un log et interrompt proprement le processus.

## Checklist terrain (admin Linux)
- Vérifier l'espace disque (`df -h`).
- Vérifier la RAM (`free -h`).
- Lister les processus anormaux (`ps aux`, `top`).
- Contrôler les permissions sensibles (`/etc`, `/var`, scripts). 
- Sauvegarder avant toute opération à risque.
- Tracer les commandes importantes dans un journal d'intervention.

## Mini-quiz
1. Quelle différence entre `>` et `>>` ?
2. À quoi sert `2>` ?
3. Quelle commande affiche les 20 dernières lignes d'un fichier ?
4. Quelle est la différence entre `kill` et `kill -9` ?
5. Que fait `chmod 755 script.sh` ?

## Corrigé rapide
1. `>` écrase, `>>` ajoute en fin de fichier.
2. `2>` redirige le flux d'erreur (stderr).
3. `tail -n 20 fichier`.
4. `kill` envoie SIGTERM (arrêt propre), `kill -9` force SIGKILL.
5. `u=rwx`, `g=rx`, `o=rx`.
