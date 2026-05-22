-- ============================================================================
-- JOBIHA DEMO SEED DATA - Two Power Users for Teacher Demonstration
-- ============================================================================
-- This file creates TWO comprehensive demo accounts that showcase ALL features:
--
-- 🎯 DEMO ACCOUNTS:
-- 1. CANDIDAT: amina.demo@gmail.com / password123
--    - Complete profile with all fields filled
--    - Multiple candidatures in all statuses
--    - Active conversations and messages
--    - Interviews scheduled and completed
--    - Evaluations given and received
--    - Saved jobs and active alerts
--    - Recent searches
--    - Rich notification history
--
-- 2. RECRUTEUR: tech.demo@company.dz / password123
--    - Complete company profile
--    - Multiple published job offers
--    - Received candidatures to review
--    - Active conversations with candidates
--    - Interviews to manage
--    - Missions in progress
--    - Evaluations received
--    - Comprehensive notifications
--
-- Password for both: password123
-- Hashed: pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=
-- ============================================================================

-- ============================================================================
-- SECTION 1: DEMO USERS (IDs 100 & 101 to avoid conflicts)
-- ============================================================================

-- Demo Candidat (ID 100)
INSERT INTO utilisateur (id, nom, prenom, email, mot_de_passe, telephone, latitude, longitude, date_inscription, est_verifie, statut_compte, push_notif_enabled, avatar_url, location, bio, push_token) VALUES
(100, 'Benali', 'Amina', 'amina.demo@gmail.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0551234567', 36.7538, 3.0588, NOW() - INTERVAL '90 days', true, 'actif', true, '/media/avatars/demo_candidat.jpg', 'Alger, Algérie', 'Développeuse Full Stack passionnée avec 5 ans d''expérience. Spécialisée en React, Node.js, Python/Django et PostgreSQL. Diplômée de l''ESI Alger. Recherche CDI ou missions longue durée. Disponible immédiatement.', 'ExponentPushToken[demo_candidate_token]');

-- Demo Recruteur (ID 101)
INSERT INTO utilisateur (id, nom, prenom, email, mot_de_passe, telephone, latitude, longitude, date_inscription, est_verifie, statut_compte, push_notif_enabled, avatar_url, location, bio, push_token) VALUES
(101, 'Tech Innovate', 'Sarah', 'tech.demo@company.dz', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0661234567', 36.7538, 3.0588, NOW() - INTERVAL '180 days', true, 'actif', true, '/media/avatars/demo_recruteur.jpg', 'Alger, Algérie', 'Responsable RH chez Tech Innovate Algeria. Nous recrutons les meilleurs talents tech en Algérie.', 'ExponentPushToken[demo_recruiter_token]');

-- Demo Candidat Profile (ID 100)
INSERT INTO candidat (utilisateur_ptr_id, competences, experience, note_globale, titre_poste, domain) VALUES
(100, 
'["JavaScript", "TypeScript", "React", "React Native", "Node.js", "Express", "Python", "Django", "PostgreSQL", "MongoDB", "Redis", "Docker", "Git", "REST API", "GraphQL", "AWS", "CI/CD", "Agile/Scrum", "TDD", "Figma"]',
'💼 EXPÉRIENCE PROFESSIONNELLE

🔹 Senior Full Stack Developer - Digital Solutions DZ (2021-2024)
• Développement d''applications web et mobile pour clients nationaux et internationaux
• Stack: React, Node.js, PostgreSQL, Docker, AWS
• Lead technique sur 3 projets majeurs (e-commerce, fintech, SaaS)
• Mentorat de 2 développeurs juniors

🔹 Full Stack Developer - StartupHub Algiers (2019-2021)
• Développement MVP pour startups algériennes
• Stack: React, Django, PostgreSQL
• Participation à 5 lancements de produits réussis

🔹 Junior Developer - FreelanceAlgeria (2018-2019)
• Missions freelance variées
• Développement sites web et applications mobiles

🎓 FORMATION
• Master en Informatique - ESI Alger (2016-2018)
• Licence en Informatique - USTHB (2013-2016)

🏆 CERTIFICATIONS
• AWS Certified Developer Associate
• MongoDB Certified Developer
• Scrum Master Certified',
4.8,
'Senior Full Stack Developer',
'Informatique');

-- Demo Recruteur Profile (ID 101)
INSERT INTO recruteur (utilisateur_ptr_id, nom_structure, type_structure, description, note_globale, titre_poste, logo_url, domain) VALUES
(101,
'Tech Innovate Algeria',
'Entreprise privée - Tech',
'🚀 Tech Innovate Algeria est une entreprise leader dans le développement de solutions digitales innovantes en Algérie.

📊 NOTRE ACTIVITÉ:
• Développement d''applications web et mobile sur mesure
• Solutions SaaS pour entreprises
• Consulting et transformation digitale
• Formation et accompagnement tech

👥 NOTRE ÉQUIPE:
• 50+ développeurs et designers
• Présence à Alger, Oran et Constantine
• Clients nationaux et internationaux
• Environnement de travail moderne et agile

💡 NOTRE CULTURE:
• Innovation et excellence technique
• Work-life balance
• Formation continue
• Projets challengeants et variés

🎯 NOUS RECRUTONS:
Développeurs Full Stack, Mobile, DevOps, Designers UI/UX, Chefs de projet',
4.7,
'Responsable Recrutement & RH',
'/media/logos/demo_company.png',
'Informatique');

-- ============================================================================
-- SECTION 2: DEMO JOB OFFERS (5 offers from demo recruiter)
-- ============================================================================

INSERT INTO offre (id, titre, description, categorie, date_debut, date_fin, salaire, type_contrat, latitude, longitude, location, statut, candidate_count, view_count, is_published, created_at, image_url, schedule_label, recruteur_id, logo_url) VALUES
(200, 'Senior Full Stack Developer React/Node', 
'🎯 POSTE: Senior Full Stack Developer

📋 DESCRIPTION:
Nous recherchons un(e) développeur(se) Full Stack senior pour rejoindre notre équipe de développement produit. Vous travaillerez sur notre plateforme SaaS utilisée par 10,000+ utilisateurs.

💻 STACK TECHNIQUE:
• Frontend: React, TypeScript, Redux, Material-UI
• Backend: Node.js, Express, PostgreSQL, Redis
• DevOps: Docker, AWS, CI/CD
• Outils: Git, Jira, Slack

✅ MISSIONS:
• Développer de nouvelles fonctionnalités
• Optimiser les performances
• Code review et mentorat
• Participation à l''architecture technique

🎓 PROFIL RECHERCHÉ:
• 5+ ans d''expérience Full Stack
• Maîtrise React et Node.js
• Expérience PostgreSQL
• Bon niveau en anglais technique
• Esprit d''équipe et autonomie

💰 PACKAGE:
• Salaire: 150,000 - 180,000 DA/mois
• Assurance santé
• Formation continue
• Télétravail partiel (2j/semaine)
• Équipement fourni (MacBook Pro)',
'Informatique', NOW() + INTERVAL '3 days', NOW() + INTERVAL '60 days', 165000, 'CDI', 36.7538, 3.0588, 'Alger, Algérie', 'searching', 5, 127, true, NOW() - INTERVAL '7 days', '/media/jobs/demo_job_1.jpg', 'Temps plein - Hybride', 101, '/media/logos/demo_company.png'),

(201, 'Mobile Developer Flutter Senior',
'🎯 POSTE: Mobile Developer Flutter Senior

📋 DESCRIPTION:
Rejoignez notre équipe mobile pour développer des applications iOS/Android avec Flutter. Projets variés pour clients prestigieux.

💻 STACK TECHNIQUE:
• Flutter / Dart
• State Management: Riverpod / Bloc
• Firebase, REST API, GraphQL
• CI/CD: Codemagic, Fastlane
• Git, Figma

✅ MISSIONS:
• Développer applications mobiles Flutter
• Intégration API et services backend
• Optimisation performances et UX
• Tests unitaires et d''intégration
• Collaboration avec designers

🎓 PROFIL RECHERCHÉ:
• 3+ ans Flutter/Dart
• Apps publiées sur stores
• Maîtrise state management
• Sens du design et UX
• Passion pour le mobile

💰 PACKAGE:
• 120,000 - 150,000 DA/mois
• Assurance santé
• Formations Flutter
• Matériel fourni
• Ambiance startup',
'Informatique', NOW() + INTERVAL '5 days', NOW() + INTERVAL '45 days', 135000, 'CDI', 36.7538, 3.0588, 'Alger, Algérie', 'searching', 3, 89, true, NOW() - INTERVAL '5 days', '/media/jobs/demo_job_2.jpg', 'Temps plein', 101, '/media/logos/demo_company.png'),

(202, 'DevOps Engineer',
'🎯 POSTE: DevOps Engineer

📋 DESCRIPTION:
Nous cherchons un DevOps pour gérer notre infrastructure cloud et automatiser nos déploiements.

💻 STACK TECHNIQUE:
• AWS (EC2, RDS, S3, Lambda)
• Docker, Kubernetes
• CI/CD: GitHub Actions, Jenkins
• Terraform, Ansible
• Monitoring: Prometheus, Grafana
• Linux, Bash, Python

✅ MISSIONS:
• Gérer infrastructure AWS
• Automatiser déploiements
• Monitoring et alerting
• Optimisation coûts cloud
• Support équipes dev

🎓 PROFIL RECHERCHÉ:
• 3+ ans DevOps/SRE
• Maîtrise AWS
• Docker/Kubernetes
• Scripting (Bash/Python)
• Mindset automation

💰 PACKAGE:
• 140,000 - 170,000 DA/mois
• Certifications AWS payées
• Assurance santé
• Remote possible
• Équipement pro',
'Informatique', NOW() + INTERVAL '10 days', NOW() + INTERVAL '90 days', 155000, 'CDI', 36.7538, 3.0588, 'Alger, Algérie', 'searching', 2, 64, true, NOW() - INTERVAL '3 days', '/media/jobs/demo_job_3.jpg', 'Temps plein - Remote OK', 101, '/media/logos/demo_company.png'),

(203, 'UI/UX Designer Senior',
'🎯 POSTE: UI/UX Designer Senior

📋 DESCRIPTION:
Créez des expériences utilisateur exceptionnelles pour nos produits digitaux. Rejoignez notre équipe design.

🎨 OUTILS:
• Figma (principal)
• Adobe XD, Sketch
• Prototyping: Framer, Principle
• Design Systems
• User Research tools

✅ MISSIONS:
• Concevoir interfaces web/mobile
• Créer et maintenir design system
• User research et tests utilisateurs
• Prototypage interactif
• Collaboration dev et product

🎓 PROFIL RECHERCHÉ:
• 4+ ans UI/UX
• Portfolio solide
• Maîtrise Figma
• Expérience design systems
• Sens de l''esthétique et UX

💰 PACKAGE:
• 110,000 - 140,000 DA/mois
• Licence Figma Pro
• Formations design
• Matériel Apple
• Projets variés',
'Design', NOW() + INTERVAL '7 days', NOW() + INTERVAL '50 days', 125000, 'CDI', 36.7538, 3.0588, 'Alger, Algérie', 'searching', 4, 95, true, NOW() - INTERVAL '4 days', '/media/jobs/demo_job_4.jpg', 'Temps plein', 101, '/media/logos/demo_company.png'),

(204, 'Chef de Projet Digital',
'🎯 POSTE: Chef de Projet Digital

📋 DESCRIPTION:
Pilotez des projets digitaux de A à Z. Coordination équipes techniques et relation clients.

📊 RESPONSABILITÉS:
• Gestion projets web/mobile
• Coordination équipes (dev, design, QA)
• Relation client et suivi
• Planning et budget
• Méthodologies Agile/Scrum

🛠️ OUTILS:
• Jira, Trello, Asana
• Slack, Teams
• Google Workspace
• Gantt, Roadmaps

✅ MISSIONS:
• Cadrage et chiffrage projets
• Animation cérémonies Agile
• Reporting et suivi KPIs
• Gestion risques
• Amélioration continue

🎓 PROFIL RECHERCHÉ:
• 5+ ans gestion projets IT
• Certification Scrum Master
• Expérience web/mobile
• Leadership et communication
• Anglais professionnel

💰 PACKAGE:
• 130,000 - 160,000 DA/mois
• Formations PM
• Assurance santé
• Bonus performance
• Évolution rapide',
'Informatique', NOW() + INTERVAL '12 days', NOW() + INTERVAL '60 days', 145000, 'CDI', 36.7538, 3.0588, 'Alger, Algérie', 'searching', 2, 71, true, NOW() - INTERVAL '2 days', '/media/jobs/demo_job_5.jpg', 'Temps plein', 101, '/media/logos/demo_company.png');

-- ============================================================================
-- SECTION 3: CANDIDATURES (Demo candidat applies to all 5 jobs)
-- ============================================================================

INSERT INTO candidature (id, candidat_id, offre_id, date_postulation, message_personnalise, statut) VALUES
-- Accepted (for mission creation)
(300, 100, 200, NOW() - INTERVAL '15 days', 
'Bonjour,

Je suis très intéressée par le poste de Senior Full Stack Developer. Mon profil correspond parfaitement à vos besoins:

✅ 5 ans d''expérience Full Stack (React/Node.js)
✅ Expertise PostgreSQL et Redis
✅ Expérience architecture SaaS
✅ Mentorat et code review
✅ Disponible immédiatement

Mon portfolio démontre ma maîtrise de votre stack technique. J''ai notamment développé une plateforme SaaS similaire utilisée par 5000+ utilisateurs.

Je serais ravie d''échanger sur ce poste et vos projets.

Cordialement,
Amina Benali',
'acceptee'),

-- Pending (waiting response)
(301, 100, 201, NOW() - INTERVAL '3 days',
'Bonjour,

Développeuse passionnée par le mobile, je candidate pour le poste Flutter Senior.

Points forts:
• 3 ans Flutter/Dart
• 5 apps publiées (iOS/Android)
• Maîtrise Riverpod et Bloc
• Expérience Firebase et API REST

Mon dernier projet: app fintech avec 10k+ téléchargements.

Portfolio disponible sur mon profil.

Cordialement,
Amina',
'en_attente'),

-- Pending
(302, 100, 203, NOW() - INTERVAL '2 days',
'Bonjour,

Bien que mon expertise principale soit le développement, j''ai une forte sensibilité UX et je collabore régulièrement avec des designers.

Je candidate pour apporter ma vision technique au design et faciliter la collaboration dev-design.

Cordialement,
Amina',
'en_attente'),

-- Rejected (not enough DevOps experience)
(303, 100, 202, NOW() - INTERVAL '20 days',
'Bonjour,

Intéressée par le poste DevOps. J''ai des bases en Docker et AWS mais souhaite me spécialiser dans ce domaine.

Motivée pour apprendre et évoluer.

Cordialement,
Amina',
'refusee'),

-- Accepted (interview scheduled)
(304, 100, 204, NOW() - INTERVAL '10 days',
'Bonjour,

Chef de projet expérimentée cherchant nouvelle opportunité. 

Compétences:
• Gestion projets Agile
• Coordination équipes techniques
• Relation client
• Scrum Master certifiée

Disponible pour échange.

Cordialement,
Amina',
'acceptee');

-- ============================================================================
-- SECTION 4: MISSIONS (2 missions for demo candidat)
-- ============================================================================

INSERT INTO mission (id, candidature_id, date_debut, date_fin, duree_heures, statut, location, image_url, summary) VALUES
-- Active mission
(100, 300, NOW() - INTERVAL '10 days', NULL, NULL, 'en_cours', 
'Alger - Tech Innovate HQ', 
'/media/missions/demo_mission_1.jpg',
'🚀 Développement Plateforme SaaS - Module Analytics

📊 PROJET: Développement du module analytics de notre plateforme SaaS

✅ RÉALISATIONS:
• Architecture backend API REST (Node.js/Express)
• Dashboard React avec graphiques interactifs
• Intégration PostgreSQL + Redis pour cache
• Tests unitaires et d''intégration
• Documentation API complète

📈 IMPACT:
• Performance: temps de chargement -60%
• 15 endpoints API créés
• 20+ composants React développés
• Code coverage: 85%

🎯 PROCHAINES ÉTAPES:
• Optimisation requêtes SQL
• Ajout exports PDF/Excel
• Notifications temps réel
• Tests de charge'),

-- Completed mission with evaluation
(101, 304, NOW() - INTERVAL '60 days', NOW() - INTERVAL '15 days', 360, 'terminee',
'Alger - Remote',
'/media/missions/demo_mission_2.jpg',
'✅ Gestion Projet Mobile App - Fintech

📱 PROJET: Pilotage développement application mobile fintech

🎯 RÉALISATIONS:
• Coordination équipe de 6 personnes (4 dev, 2 designers)
• Planning et suivi sprints (8 sprints de 2 semaines)
• Gestion backlog et priorisation features
• Relation client et démos hebdomadaires
• Livraison dans les délais et budget

📊 RÉSULTATS:
• App livrée en 4 mois (vs 5 prévus)
• 0 bug critique en production
• Client très satisfait (NPS: 9/10)
• Équipe motivée et productive

🏆 SUCCÈS:
• Méthodologie Agile bien appliquée
• Communication fluide
• Qualité du livrable
• Respect des contraintes');

-- ============================================================================
-- SECTION 5: CONVERSATIONS (3 conversations for demo)
-- ============================================================================

INSERT INTO conversation (id, type, nom, created_by_id, created_at) VALUES
-- DM between candidat and recruteur
(100, 'direct', NULL, 100, NOW() - INTERVAL '15 days'),
-- Group conversation (project team)
(101, 'group', 'Équipe Projet SaaS Analytics', 101, NOW() - INTERVAL '10 days'),
-- DM for interview scheduling
(102, 'direct', NULL, 101, NOW() - INTERVAL '5 days');

-- Conversation members
INSERT INTO conversation_member (conversation_id, user_id, role, joined_at, left_at, is_invitation) VALUES
-- DM 100: candidat <-> recruteur
(100, 100, 'member', NOW() - INTERVAL '15 days', NULL, false),
(100, 101, 'member', NOW() - INTERVAL '15 days', NULL, false),
-- Group 101: project team
(101, 101, 'admin', NOW() - INTERVAL '10 days', NULL, false),
(101, 100, 'member', NOW() - INTERVAL '10 days', NULL, false),
-- DM 102: interview scheduling
(102, 100, 'member', NOW() - INTERVAL '5 days', NULL, false),
(102, 101, 'member', NOW() - INTERVAL '5 days', NULL, false);

-- ============================================================================
-- SECTION 6: MESSAGES (Rich conversation history)
-- ============================================================================

INSERT INTO message (id, contenu, date_envoi, conversation_id, expediteur_id, est_lu, destinataire_id, type) VALUES
-- Conversation 100: Initial contact and acceptance
(1000, 'Bonjour Sarah, merci d''avoir examiné ma candidature pour le poste de Senior Full Stack Developer. J''ai hâte d''en discuter avec vous !', NOW() - INTERVAL '15 days', 100, 100, true, NULL, 'text'),
(1001, 'Bonjour Amina ! Votre profil nous intéresse beaucoup. Votre expérience correspond parfaitement à nos besoins. Seriez-vous disponible pour un entretien cette semaine ?', NOW() - INTERVAL '15 days', 100, 101, true, NULL, 'text'),
(1002, 'Oui, je suis disponible ! Jeudi ou vendredi après-midi me conviendraient parfaitement.', NOW() - INTERVAL '14 days', 100, 100, true, NULL, 'text'),
(1003, 'Parfait ! Je vous propose jeudi à 14h en visio. Je vous envoie le lien par email. Ce sera un entretien technique avec notre CTO.', NOW() - INTERVAL '14 days', 100, 101, true, NULL, 'text'),
(1004, 'Excellent, merci ! J''ai bien reçu l''email. À jeudi !', NOW() - INTERVAL '14 days', 100, 100, true, NULL, 'text'),
(1005, 'Bonjour Amina, suite à votre excellent entretien, nous sommes ravis de vous proposer le poste ! 🎉', NOW() - INTERVAL '12 days', 100, 101, true, NULL, 'text'),
(1006, 'C''est une excellente nouvelle ! Merci beaucoup ! Quelles sont les prochaines étapes ?', NOW() - INTERVAL '12 days', 100, 100, true, NULL, 'text'),
(1007, 'Je vous envoie le contrat par email. Vous pourriez commencer lundi prochain si ça vous convient ?', NOW() - INTERVAL '11 days', 100, 101, true, NULL, 'text'),
(1008, 'Parfait ! Je signe le contrat aujourd''hui et je serai là lundi. Merci pour cette opportunité !', NOW() - INTERVAL '11 days', 100, 100, true, NULL, 'text'),

-- Conversation 101: Project team group chat
(1009, 'Bienvenue Amina dans l''équipe ! 👋 Nous sommes ravis de t''avoir parmi nous pour le projet Analytics.', NOW() - INTERVAL '10 days', 101, 101, true, NULL, 'text'),
(1010, 'Merci Sarah ! Très heureuse de rejoindre l''équipe. Hâte de commencer !', NOW() - INTERVAL '10 days', 101, 100, true, NULL, 'text'),
(1011, 'Premier sprint planning demain à 10h. On va définir les user stories ensemble.', NOW() - INTERVAL '9 days', 101, 101, true, NULL, 'text'),
(1012, 'Parfait ! J''ai déjà commencé à regarder l''architecture existante. Quelques questions à poser demain.', NOW() - INTERVAL '9 days', 101, 100, true, NULL, 'text'),
(1013, 'Update: Le module de graphiques est terminé ! 📊 Les performances sont excellentes. PR prête pour review.', NOW() - INTERVAL '5 days', 101, 100, true, NULL, 'text'),
(1014, 'Super travail Amina ! Je review ça cet après-midi. Les graphiques ont l''air magnifiques ! 🎨', NOW() - INTERVAL '5 days', 101, 101, true, NULL, 'text'),
(1015, 'Sprint review vendredi à 15h. Amina, tu pourras présenter le module analytics ?', NOW() - INTERVAL '2 days', 101, 101, true, NULL, 'text'),
(1016, 'Avec plaisir ! Je prépare une démo complète avec les métriques de performance.', NOW() - INTERVAL '2 days', 101, 100, true, NULL, 'text'),
(1017, 'Excellent sprint ! Le client est très impressionné par le module analytics. Bravo à toute l''équipe ! 🚀', NOW() - INTERVAL '1 day', 101, 101, true, NULL, 'text'),

-- Conversation 102: Interview scheduling for Flutter position
(1018, 'Bonjour Amina, nous avons examiné votre candidature pour le poste Flutter. Votre profil est intéressant ! Disponible pour un entretien ?', NOW() - INTERVAL '5 days', 102, 101, true, NULL, 'text'),
(1019, 'Bonjour Sarah ! Oui, je suis disponible. Quand vous convient-il ?', NOW() - INTERVAL '5 days', 102, 100, true, NULL, 'text'),
(1020, 'Que diriez-vous de mardi prochain à 10h ? Ce sera avec notre Lead Mobile Developer.', NOW() - INTERVAL '4 days', 102, 101, true, NULL, 'text'),
(1021, 'Parfait pour moi ! Merci. Ce sera en visio ou sur site ?', NOW() - INTERVAL '4 days', 102, 100, true, NULL, 'text'),
(1022, 'En visio pour commencer. Je vous envoie le lien Google Meet par email.', NOW() - INTERVAL '4 days', 102, 101, false, NULL, 'text');

-- ============================================================================
-- SECTION 7: INTERVIEWS (3 interviews for demo candidat)
-- ============================================================================

INSERT INTO interview (id, candidate_id, recruiter_id, job_id, scheduled_date, status, notes, created_at, candidature_id) VALUES
-- Completed interview (led to job offer)
(100, 100, 101, 200, NOW() - INTERVAL '13 days', 'completed',
'✅ ENTRETIEN TECHNIQUE - SENIOR FULL STACK

👤 CANDIDAT: Amina Benali
📅 DATE: ' || TO_CHAR(NOW() - INTERVAL '13 days', 'DD/MM/YYYY') || '
⏱️ DURÉE: 1h30

📊 ÉVALUATION:

🔹 Compétences Techniques (5/5):
• React/TypeScript: Excellente maîtrise
• Node.js/Express: Très solide
• PostgreSQL: Expertise confirmée
• Architecture: Vision claire et moderne
• Best practices: Code review impressionnant

🔹 Expérience (5/5):
• Projets SaaS pertinents
• Leadership technique démontré
• Mentorat et collaboration

🔹 Soft Skills (5/5):
• Communication claire et précise
• Esprit d''équipe
• Proactive et curieuse
• Passion évidente pour le dev

💡 POINTS FORTS:
• Expertise technique complète
• Expérience architecture SaaS
• Capacité à mentorer
• Alignement culturel parfait

🎯 DÉCISION: EMBAUCHE RECOMMANDÉE ✅

Le profil correspond exactement à nos besoins. Candidature exceptionnelle.',
NOW() - INTERVAL '14 days', 300),

-- Scheduled interview (upcoming)
(101, 100, 101, 201, NOW() + INTERVAL '3 days', 'scheduled',
'Entretien technique Flutter avec Lead Mobile Dev.
Prévoir: 
- Présentation portfolio apps
- Live coding Flutter
- Discussion architecture mobile
- Questions sur state management',
NOW() - INTERVAL '5 days', 301),

-- Completed interview for PM role
(102, 100, 101, 204, NOW() - INTERVAL '8 days', 'completed',
'✅ ENTRETIEN CHEF DE PROJET

👤 CANDIDAT: Amina Benali
📅 DATE: ' || TO_CHAR(NOW() - INTERVAL '8 days', 'DD/MM/YYYY') || '

📊 ÉVALUATION:

🔹 Gestion de Projet (4/5):
• Méthodologies Agile: Bien maîtrisées
• Outils PM: Jira, Trello OK
• Planning: Bonne organisation

🔹 Leadership (5/5):
• Communication excellente
• Gestion d''équipe démontrée
• Résolution de conflits

🔹 Expérience (4/5):
• Projets IT variés
• Coordination équipes tech
• Relation client

💡 PROFIL:
Candidat polyvalent avec double casquette tech/PM.
Atout: compréhension technique approfondie.

🎯 DÉCISION: ACCEPTÉE pour mission PM',
NOW() - INTERVAL '9 days', 304);

-- ============================================================================
-- SECTION 8: EVALUATIONS (2 evaluations showcasing the system)
-- ============================================================================

INSERT INTO evaluation (id, mission_id, note, commentaire, recruiter_reply, recruiter_reply_date, recruiter_name, evaluateur_id, evalue_id, date_evaluation) VALUES
-- Candidat evaluates Recruteur (completed mission)
(100, 101, 5,
'⭐⭐⭐⭐⭐ Excellente expérience !

🎯 MISSION: Gestion Projet Mobile Fintech

✅ POINTS POSITIFS:
• Briefing clair et complet
• Communication fluide tout au long du projet
• Équipe professionnelle et compétente
• Autonomie et confiance accordées
• Feedback constructif et régulier
• Paiement dans les délais
• Ambiance de travail agréable

💡 CE QUI M''A PLU:
• Méthodologie Agile bien appliquée
• Outils modernes et efficaces
• Culture d''entreprise positive
• Opportunités d''apprentissage

🚀 RÉSULTAT:
Projet réussi, client satisfait, équipe motivée !

Je recommande vivement Tech Innovate Algeria comme employeur. J''espère collaborer à nouveau sur de futurs projets !

Merci pour cette belle expérience. 🙏',
'Merci infiniment Amina pour ce retour ! 🙏

Nous sommes ravis d''avoir travaillé avec vous. Votre professionnalisme, votre expertise technique et votre leadership ont été des atouts majeurs pour la réussite du projet.

Le client a été impressionné par la qualité du livrable et votre capacité à gérer l''équipe efficacement.

Nous serions ravis de retravailler ensemble ! D''ailleurs, nous avons d''autres projets intéressants en pipeline. Restons en contact ! 😊

À très bientôt,
Sarah - Tech Innovate',
NOW() - INTERVAL '14 days',
'Sarah - Tech Innovate Algeria',
100, 101, NOW() - INTERVAL '15 days'),

-- Recruteur evaluates Candidat (completed mission)
(101, 101, 5,
'⭐⭐⭐⭐⭐ Collaboration exceptionnelle !

👤 TALENT: Amina Benali
🎯 MISSION: Chef de Projet - App Mobile Fintech

📊 ÉVALUATION:

🔹 Compétences Techniques (5/5):
• Excellente compréhension des enjeux techniques
• Capable de dialoguer avec les développeurs
• Choix technologiques pertinents

🔹 Gestion de Projet (5/5):
• Organisation impeccable
• Respect des délais et du budget
• Gestion des risques proactive
• Reporting clair et régulier

🔹 Leadership (5/5):
• Équipe motivée et productive
• Communication excellente
• Résolution de problèmes efficace
• Esprit d''équipe remarquable

🔹 Relation Client (5/5):
• Écoute et compréhension des besoins
• Gestion des attentes
• Présentation professionnelle
• Client très satisfait (NPS: 9/10)

💡 POINTS FORTS:
• Polyvalence tech/management
• Proactivité et autonomie
• Qualité du livrable
• Attitude positive

🎯 RÉSULTAT:
Mission réussie au-delà de nos attentes !

Nous recommandons Amina sans hésitation et espérons collaborer à nouveau très prochainement. Talent à suivre ! 🚀',
'Merci beaucoup Sarah et toute l''équipe ! 😊

Ce fut un réel plaisir de travailler sur ce projet. L''équipe était formidable et le projet très stimulant.

J''ai beaucoup appris et je suis fière du résultat obtenu ensemble.

Au plaisir de collaborer à nouveau !

Amina',
NOW() - INTERVAL '13 days',
'Amina Benali',
101, 100, NOW() - INTERVAL '14 days');

-- ============================================================================
-- SECTION 9: NOTIFICATIONS (Rich notification history for both users)
-- ============================================================================

INSERT INTO notification (id, utilisateur_id, contenu, type, date_envoi, est_lue, title, job_title, sender_name, avatar_url, count, context_image_url) VALUES
-- CANDIDAT NOTIFICATIONS (100)
(1000, 100, 'Votre candidature pour Senior Full Stack Developer a été acceptée ! 🎉', 'applicationAccepted', NOW() - INTERVAL '12 days', true, 'Candidature acceptée', 'Senior Full Stack Developer', 'Tech Innovate Algeria', '/media/logos/demo_company.png', NULL, '/media/jobs/demo_job_1.jpg'),
(1001, 100, 'Entretien confirmé pour le poste de Mobile Developer Flutter - Mardi 10h', 'interviewAccepted', NOW() - INTERVAL '4 days', false, 'Entretien programmé', 'Mobile Developer Flutter', 'Sarah - Tech Innovate', '/media/avatars/demo_recruteur.jpg', NULL, NULL),
(1002, 100, 'Nouveau message de Sarah (Tech Innovate)', 'newMessage', NOW() - INTERVAL '4 days', false, 'Nouveau message', NULL, 'Sarah', '/media/avatars/demo_recruteur.jpg', NULL, NULL),
(1003, 100, 'Votre candidature pour DevOps Engineer a été refusée', 'applicationRejected', NOW() - INTERVAL '18 days', true, 'Candidature refusée', 'DevOps Engineer', 'Tech Innovate Algeria', '/media/logos/demo_company.png', NULL, NULL),
(1004, 100, 'Tech Innovate Algeria a consulté votre profil', 'profileViewed', NOW() - INTERVAL '16 days', true, 'Profil consulté', NULL, 'Tech Innovate Algeria', '/media/logos/demo_company.png', NULL, NULL),
(1005, 100, 'Votre évaluation a été publiée avec succès', 'system', NOW() - INTERVAL '15 days', true, 'Évaluation publiée', NULL, NULL, NULL, NULL, NULL),
(1006, 100, 'Sarah a répondu à votre évaluation', 'newMessage', NOW() - INTERVAL '14 days', true, 'Réponse à évaluation', NULL, 'Sarah - Tech Innovate', '/media/avatars/demo_recruteur.jpg', NULL, NULL),
(1007, 100, 'Nouvelle offre correspondant à votre profil: Senior Full Stack Developer', 'jobMatchingPreferences', NOW() - INTERVAL '7 days', true, 'Offre recommandée', 'Senior Full Stack Developer', 'Tech Innovate Algeria', '/media/logos/demo_company.png', NULL, '/media/jobs/demo_job_1.jpg'),
(1008, 100, 'Mission "Développement SaaS Analytics" en cours - 10 jours', 'missionExpiring', NOW() - INTERVAL '5 days', true, 'Mission en cours', 'Développement SaaS Analytics', NULL, NULL, NULL, '/media/missions/demo_mission_1.jpg'),
(1009, 100, 'Félicitations ! Mission "Gestion Projet Mobile" terminée avec succès', 'missionCompleted', NOW() - INTERVAL '15 days', true, 'Mission complétée', 'Gestion Projet Mobile', NULL, NULL, NULL, '/media/missions/demo_mission_2.jpg'),

-- RECRUTEUR NOTIFICATIONS (101)
(1010, 101, 'Nouvelle candidature pour Senior Full Stack Developer', 'newApplicants', NOW() - INTERVAL '15 days', true, 'Nouvelle candidature', 'Senior Full Stack Developer', 'Amina Benali', '/media/avatars/demo_candidat.jpg', 1, NULL),
(1011, 101, '3 nouvelles candidatures cette semaine', 'newApplicants', NOW() - INTERVAL '5 days', false, 'Nouvelles candidatures', NULL, NULL, NULL, 3, NULL),
(1012, 101, 'Amina Benali a accepté l''invitation pour un entretien', 'interviewAccepted', NOW() - INTERVAL '14 days', true, 'Entretien accepté', 'Senior Full Stack Developer', 'Amina Benali', '/media/avatars/demo_candidat.jpg', NULL, NULL),
(1013, 101, 'Nouveau message de Amina Benali', 'newMessage', NOW() - INTERVAL '11 days', true, 'Nouveau message', NULL, 'Amina Benali', '/media/avatars/demo_candidat.jpg', NULL, NULL),
(1014, 101, 'Mission "Développement SaaS Analytics" démarrée', 'missionCompleted', NOW() - INTERVAL '10 days', true, 'Mission démarrée', 'Développement SaaS Analytics', 'Amina Benali', '/media/avatars/demo_candidat.jpg', NULL, NULL),
(1015, 101, 'Amina Benali a publié une évaluation 5⭐', 'system', NOW() - INTERVAL '15 days', true, 'Nouvelle évaluation', NULL, 'Amina Benali', '/media/avatars/demo_candidat.jpg', NULL, NULL),
(1016, 101, 'Votre annonce "Mobile Developer Flutter" a été publiée', 'announcementCreated', NOW() - INTERVAL '5 days', true, 'Annonce publiée', 'Mobile Developer Flutter', NULL, NULL, NULL, '/media/jobs/demo_job_2.jpg'),
(1017, 101, 'Question sur votre offre: Senior Full Stack Developer', 'jobQuestion', NOW() - INTERVAL '16 days', true, 'Question sur offre', 'Senior Full Stack Developer', 'Amina Benali', '/media/avatars/demo_candidat.jpg', NULL, NULL),
(1018, 101, 'Rappel: Entretien avec Amina Benali demain à 10h', 'system', NOW() - INTERVAL '1 day', false, 'Rappel entretien', 'Mobile Developer Flutter', 'Amina Benali', '/media/avatars/demo_candidat.jpg', NULL, NULL),
(1019, 101, 'Votre offre "Senior Full Stack Developer" a reçu 127 vues', 'system', NOW() - INTERVAL '3 days', true, 'Statistiques offre', 'Senior Full Stack Developer', NULL, NULL, NULL, NULL);

-- ============================================================================
-- SECTION 10: SAVED JOBS (Candidat saves interesting offers)
-- ============================================================================

INSERT INTO saved_job (id, candidat_id, offre_id, saved_at) VALUES
(100, 100, 200, NOW() - INTERVAL '16 days'),
(101, 100, 201, NOW() - INTERVAL '6 days'),
(102, 100, 203, NOW() - INTERVAL '4 days');

-- ============================================================================
-- SECTION 11: JOB ALERTS (Candidat active alerts)
-- ============================================================================

INSERT INTO alerte (id, candidat_id, titre, categorie, type_contrat, salaire_min, localisation, actif, cree_le) VALUES
(100, 100, 'Senior Full Stack Developer', 'Informatique', 'CDI', 140000, 'Alger', true, NOW() - INTERVAL '90 days'),
(101, 100, 'Mobile Developer', 'Informatique', 'CDI', 100000, 'Alger', true, NOW() - INTERVAL '60 days'),
(102, 100, 'Tech Lead / Architect', 'Informatique', 'CDI', 180000, 'Alger', true, NOW() - INTERVAL '30 days');

-- ============================================================================
-- SECTION 12: RECENT SEARCHES (Candidat search history)
-- ============================================================================

INSERT INTO recent_search (id, user_id, query, searched_at) VALUES
(100, 100, 'senior full stack react node', NOW() - INTERVAL '1 day'),
(101, 100, 'mobile developer flutter alger', NOW() - INTERVAL '2 days'),
(102, 100, 'tech lead', NOW() - INTERVAL '3 days'),
(103, 100, 'remote developer', NOW() - INTERVAL '5 days'),
(104, 100, 'cdi informatique alger', NOW() - INTERVAL '7 days');

-- ============================================================================
-- SECTION 13: READ CURSORS (Conversation read status)
-- ============================================================================

INSERT INTO read_cursor (id, conversation_id, user_id, last_read_message_id, updated_at) VALUES
(100, 100, 100, 1008, NOW() - INTERVAL '11 days'),
(101, 100, 101, 1008, NOW() - INTERVAL '11 days'),
(102, 101, 100, 1017, NOW() - INTERVAL '1 day'),
(103, 101, 101, 1017, NOW() - INTERVAL '1 day'),
(104, 102, 100, 1021, NOW() - INTERVAL '4 days'),
(105, 102, 101, 1021, NOW() - INTERVAL '4 days');

-- ============================================================================
-- UPDATE SEQUENCES
-- ============================================================================

-- Note: Adjust these if you have existing data
SELECT setval('utilisateur_id_seq', 101, true);
SELECT setval('offre_id_seq', 204, true);
SELECT setval('candidature_id_seq', 304, true);
SELECT setval('mission_id_seq', 101, true);
SELECT setval('conversation_id_seq', 102, true);
SELECT setval('message_id_seq', 1022, true);
SELECT setval('interview_id_seq', 102, true);
SELECT setval('evaluation_id_seq', 101, true);
SELECT setval('notification_id_seq', 1019, true);
SELECT setval('saved_job_id_seq', 102, true);
SELECT setval('alerte_id_seq', 102, true);
SELECT setval('recent_search_id_seq', 104, true);
SELECT setval('read_cursor_id_seq', 105, true);

-- ============================================================================
-- END OF DEMO SEED DATA
-- ============================================================================
-- 
-- 🎯 DEMO ACCOUNTS READY:
--
-- 👤 CANDIDAT:
--    Email: amina.demo@gmail.com
--    Password: password123
--    Features: Complete profile, 5 candidatures, 2 missions, interviews,
--              evaluations, conversations, notifications, saved jobs, alerts
--
-- 🏢 RECRUTEUR:
--    Email: tech.demo@company.dz
--    Password: password123
--    Features: Complete company profile, 5 job offers, received candidatures,
--              active missions, conversations, evaluations, notifications
--
-- ✅ All app features are demonstrated through these two accounts!
-- ============================================================================
