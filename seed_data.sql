-- ============================================================================
-- JOBIHA SEED DATA - Complete SQL Seed File for Neon PostgreSQL
-- ============================================================================
-- This file adds realistic Algerian test data to your Jobiha database
-- 
-- IMPORTANT: IDs start from existing max IDs to avoid conflicts:
-- - Users (utilisateur): Start from ID 7 (existing max: 5)
-- - Offres: Start from ID 5 (existing max: 4)
-- - Candidatures: Start from ID 6 (existing max: 5)
-- - Missions: Start from ID 3 (existing max: 2)
-- - All other tables start from ID 1 (no existing data)
--
-- Password for all users: password123
-- Hashed with Django's pbkdf2_sha256
-- ============================================================================

-- ============================================================================
-- SECTION 1: USERS (15 new users - mix of candidats and recruteurs)
-- ============================================================================
-- Password hash: pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=

-- Utilisateur base records (IDs 7-21)
INSERT INTO utilisateur (id, nom, prenom, email, mot_de_passe, telephone, latitude, longitude, date_inscription, est_verifie, statut_compte, push_notif_enabled, avatar_url, location, bio, push_token) VALUES
-- Candidats (7-15)
(7, 'Benali', 'Amina', 'amina.benali@gmail.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0551234567', 36.7538, 3.0588, NOW() - INTERVAL '45 days', true, 'actif', true, '/media/avatars/user_7.jpg', 'Alger', 'Développeuse web passionnée avec 3 ans d''expérience', NULL),
(8, 'Khelifi', 'Yacine', 'yacine.khelifi@outlook.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0661234567', 36.1900, 5.4139, NOW() - INTERVAL '30 days', true, 'actif', true, '/media/avatars/user_8.jpg', 'Bejaia', 'Designer UI/UX créatif, spécialisé en applications mobiles', NULL),
(9, 'Meziane', 'Salima', 'salima.meziane@yahoo.fr', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0771234567', 35.6969, -0.6331, NOW() - INTERVAL '60 days', true, 'actif', true, '/media/avatars/user_9.jpg', 'Oran', 'Architecte avec 5 ans d''expérience en projets résidentiels', NULL),
(10, 'Boudiaf', 'Karim', 'karim.boudiaf@gmail.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0551234568', 36.3650, 6.6147, NOW() - INTERVAL '20 days', true, 'actif', true, '/media/avatars/user_10.jpg', 'Constantine', 'Ingénieur en génie civil, expert en infrastructures', NULL),
(11, 'Hamidi', 'Nadia', 'nadia.hamidi@hotmail.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0661234568', 36.7538, 3.0588, NOW() - INTERVAL '15 days', true, 'actif', true, '/media/avatars/user_11.jpg', 'Alger', 'Data analyst avec expertise en Python et SQL', NULL),
(12, 'Saidi', 'Mehdi', 'mehdi.saidi@gmail.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0771234568', 35.6969, -0.6331, NOW() - INTERVAL '50 days', true, 'actif', true, '/media/avatars/user_12.jpg', 'Oran', 'Graphiste freelance, spécialisé en branding', NULL),
(13, 'Larbi', 'Fatima', 'fatima.larbi@yahoo.fr', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0551234569', 36.1900, 5.4139, NOW() - INTERVAL '25 days', true, 'actif', true, '/media/avatars/user_13.jpg', 'Bejaia', 'Chef de projet IT avec 4 ans d''expérience', NULL),
(14, 'Cherif', 'Riad', 'riad.cherif@outlook.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0661234569', 36.3650, 6.6147, NOW() - INTERVAL '35 days', true, 'actif', true, '/media/avatars/user_14.jpg', 'Constantine', 'Développeur mobile Flutter et React Native', NULL),
(15, 'Bouzid', 'Leila', 'leila.bouzid@gmail.com', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0771234569', 36.7538, 3.0588, NOW() - INTERVAL '10 days', true, 'actif', true, '/media/avatars/user_15.jpg', 'Alger', 'Marketing digital et community management', NULL),
-- Recruteurs (16-21)
(16, 'Tech Solutions', 'Ahmed', 'ahmed@techsolutions.dz', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0551234570', 36.7538, 3.0588, NOW() - INTERVAL '90 days', true, 'actif', true, '/media/avatars/user_16.jpg', 'Alger', 'Responsable RH chez Tech Solutions', NULL),
(17, 'Design Studio', 'Samira', 'samira@designstudio.dz', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0661234570', 35.6969, -0.6331, NOW() - INTERVAL '120 days', true, 'actif', true, '/media/avatars/user_17.jpg', 'Oran', 'Directrice créative', NULL),
(18, 'BTP Algérie', 'Rachid', 'rachid@btpalgerie.dz', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0771234570', 36.3650, 6.6147, NOW() - INTERVAL '150 days', true, 'actif', true, '/media/avatars/user_18.jpg', 'Constantine', 'Chef de projet construction', NULL),
(19, 'Digital Agency', 'Yasmine', 'yasmine@digitalagency.dz', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0551234571', 36.7538, 3.0588, NOW() - INTERVAL '80 days', true, 'actif', true, '/media/avatars/user_19.jpg', 'Alger', 'CEO de Digital Agency', NULL),
(20, 'Construction Plus', 'Sofiane', 'sofiane@constructionplus.dz', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0661234571', 36.1900, 5.4139, NOW() - INTERVAL '100 days', true, 'actif', true, '/media/avatars/user_20.jpg', 'Bejaia', 'Directeur des opérations', NULL),
(21, 'Web Innovate', 'Meriem', 'meriem@webinnovate.dz', 'pbkdf2_sha256$720000$UwnrPl7cieEZqzyUvUELGH$0EMJsNrpg1u6zOmEEX+XZoC51qYUSYDVwqmujcYRaME=', '0771234571', 35.6969, -0.6331, NOW() - INTERVAL '70 days', true, 'actif', true, '/media/avatars/user_21.jpg', 'Oran', 'Responsable recrutement', NULL);

-- Candidat profiles (IDs 7-15)
INSERT INTO candidat (utilisateur_ptr_id, competences, experience, note_globale, titre_poste, domain) VALUES
(7, '["JavaScript", "React", "Node.js", "MongoDB", "Git"]', '3 ans d''expérience en développement web full-stack. Projets e-commerce et applications SaaS.', 4.5, 'Développeuse Full Stack', 'Informatique'),
(8, '["Figma", "Adobe XD", "Sketch", "UI Design", "Prototyping"]', '2 ans en design UI/UX pour applications mobiles et web. Portfolio varié.', 4.2, 'Designer UI/UX', 'Design'),
(9, '["AutoCAD", "Revit", "SketchUp", "Gestion de projet"]', '5 ans en architecture résidentielle et commerciale. Plusieurs projets livrés.', 4.7, 'Architecte', 'BTP'),
(10, '["Génie civil", "AutoCAD", "Gestion chantier", "Normes construction"]', '4 ans en infrastructures routières et bâtiments publics.', 4.3, 'Ingénieur Génie Civil', 'BTP'),
(11, '["Python", "SQL", "Power BI", "Excel", "Data Visualization"]', '2 ans en analyse de données pour secteur bancaire et retail.', 4.0, 'Data Analyst', 'Informatique'),
(12, '["Photoshop", "Illustrator", "InDesign", "Branding", "Print Design"]', '3 ans en design graphique freelance. Identités visuelles et supports print.', 4.4, 'Graphiste', 'Design'),
(13, '["Gestion projet", "Scrum", "Jira", "Leadership", "Budgétisation"]', '4 ans en gestion de projets IT. Équipes de 5-10 personnes.', 4.6, 'Chef de Projet IT', 'Informatique'),
(14, '["Flutter", "React Native", "Firebase", "REST API", "Git"]', '3 ans en développement mobile cross-platform. Apps iOS et Android.', 4.1, 'Développeur Mobile', 'Informatique'),
(15, '["SEO", "Google Ads", "Social Media", "Content Marketing", "Analytics"]', '2 ans en marketing digital. Gestion réseaux sociaux et campagnes publicitaires.', 3.9, 'Spécialiste Marketing Digital', 'Design');

-- Recruteur profiles (IDs 16-21)
INSERT INTO recruteur (utilisateur_ptr_id, nom_structure, type_structure, description, note_globale, titre_poste, logo_url, domain) VALUES
(16, 'Tech Solutions DZ', 'Entreprise privée', 'Société de développement logiciel spécialisée en solutions d''entreprise et applications web.', 4.5, 'Responsable RH', '/media/logos/tech_solutions.png', 'Informatique'),
(17, 'Design Studio Algérie', 'Agence créative', 'Agence de design graphique et branding pour PME et startups algériennes.', 4.3, 'Directrice Créative', '/media/logos/design_studio.png', 'Design'),
(18, 'BTP Algérie Construction', 'Entreprise BTP', 'Entreprise de construction spécialisée en bâtiments résidentiels et commerciaux.', 4.6, 'Chef de Projet', '/media/logos/btp_algerie.png', 'BTP'),
(19, 'Digital Agency DZ', 'Agence digitale', 'Agence de marketing digital et développement web pour entreprises algériennes.', 4.4, 'CEO', '/media/logos/digital_agency.png', 'Informatique'),
(20, 'Construction Plus', 'Entreprise BTP', 'Entreprise de construction d''infrastructures et travaux publics.', 4.2, 'Directeur Opérations', '/media/logos/construction_plus.png', 'BTP'),
(21, 'Web Innovate', 'Startup tech', 'Startup spécialisée en développement d''applications web innovantes.', 4.1, 'Responsable Recrutement', '/media/logos/web_innovate.png', 'Informatique');

-- ============================================================================
-- SECTION 2: JOB OFFERS (15 new offres covering all categories)
-- ============================================================================

INSERT INTO offre (id, titre, description, categorie, date_debut, date_fin, salaire, type_contrat, latitude, longitude, location, statut, candidate_count, view_count, is_published, created_at, image_url, schedule_label, recruteur_id, logo_url) VALUES
-- Informatique (5-9)
(5, 'Développeur Backend Python/Django', 'Nous recherchons un développeur backend expérimenté en Python/Django pour rejoindre notre équipe. Vous travaillerez sur des projets d''envergure pour des clients nationaux et internationaux.', 'Informatique', NOW() + INTERVAL '5 days', NOW() + INTERVAL '60 days', 80000, 'CDI', 36.7538, 3.0588, 'Alger', 'searching', 2, 45, true, NOW() - INTERVAL '5 days', '/media/jobs/job_5.jpg', 'Temps plein', 16, '/media/logos/tech_solutions.png'),
(6, 'Chef de Projet IT', 'Recherche chef de projet IT pour coordonner équipes de développement. Expérience en méthodologies agiles requise.', 'Informatique', NOW() + INTERVAL '10 days', NOW() + INTERVAL '45 days', 120000, 'CDI', 36.7538, 3.0588, 'Alger', 'searching', 1, 32, true, NOW() - INTERVAL '3 days', '/media/jobs/job_6.jpg', 'Temps plein', 19, '/media/logos/digital_agency.png'),
(7, 'Développeur Mobile Flutter', 'Développeur mobile Flutter pour créer applications iOS/Android. Portfolio requis.', 'Informatique', NOW() + INTERVAL '7 days', NOW() + INTERVAL '30 days', 60000, 'CDD', 35.6969, -0.6331, 'Oran', 'searching', 3, 67, true, NOW() - INTERVAL '2 days', '/media/jobs/job_7.jpg', 'Temps plein', 21, '/media/logos/web_innovate.png'),
(8, 'Data Analyst', 'Analyste de données pour projets BI. Maîtrise Python, SQL et Power BI indispensable.', 'Informatique', NOW() + INTERVAL '15 days', NOW() + INTERVAL '90 days', 70000, 'CDI', 36.3650, 6.6147, 'Constantine', 'searching', 1, 28, true, NOW() - INTERVAL '7 days', '/media/jobs/job_8.jpg', 'Temps plein', 16, '/media/logos/tech_solutions.png'),
(9, 'Développeur Full Stack React/Node', 'Mission de développement full stack pour application SaaS. Stack moderne React/Node/PostgreSQL.', 'Informatique', NOW() + INTERVAL '3 days', NOW() + INTERVAL '20 days', 45000, 'Mission', 36.1900, 5.4139, 'Bejaia', 'searching', 2, 51, true, NOW() - INTERVAL '1 day', '/media/jobs/job_9.jpg', 'Mission 3 mois', 19, '/media/logos/digital_agency.png'),

-- Design (10-13)
(10, 'Designer UI/UX Senior', 'Designer UI/UX pour refonte complète de notre plateforme web. Expérience Figma et design systems.', 'Design', NOW() + INTERVAL '8 days', NOW() + INTERVAL '40 days', 65000, 'CDD', 36.7538, 3.0588, 'Alger', 'searching', 2, 39, true, NOW() - INTERVAL '4 days', '/media/jobs/job_10.jpg', 'Temps plein', 17, '/media/logos/design_studio.png'),
(11, 'Graphiste Print et Digital', 'Graphiste polyvalent pour supports print et digital. Identités visuelles et campagnes marketing.', 'Design', NOW() + INTERVAL '12 days', NOW() + INTERVAL '50 days', 55000, 'CDI', 35.6969, -0.6331, 'Oran', 'searching', 1, 44, true, NOW() - INTERVAL '6 days', '/media/jobs/job_11.jpg', 'Temps plein', 17, '/media/logos/design_studio.png'),
(12, 'Motion Designer', 'Motion designer pour créer animations et vidéos promotionnelles. After Effects et Premiere Pro.', 'Design', NOW() + INTERVAL '5 days', NOW() + INTERVAL '25 days', 40000, 'Freelance', 36.7538, 3.0588, 'Alger', 'searching', 3, 56, true, NOW() - INTERVAL '8 days', '/media/jobs/job_12.jpg', 'Freelance', 19, '/media/logos/digital_agency.png'),
(13, 'Designer Produit', 'Designer produit pour application mobile fintech. Recherche UX et tests utilisateurs.', 'Design', NOW() + INTERVAL '20 days', NOW() + INTERVAL '60 days', 75000, 'CDI', 36.3650, 6.6147, 'Constantine', 'searching', 1, 31, true, NOW() - INTERVAL '2 days', '/media/jobs/job_13.jpg', 'Temps plein', 21, '/media/logos/web_innovate.png'),

-- BTP (14-19)
(14, 'Ingénieur Génie Civil', 'Ingénieur génie civil pour supervision chantiers. Expérience infrastructures routières.', 'BTP', NOW() + INTERVAL '10 days', NOW() + INTERVAL '45 days', 90000, 'CDI', 36.7538, 3.0588, 'Alger', 'searching', 2, 37, true, NOW() - INTERVAL '5 days', '/media/jobs/job_14.jpg', 'Temps plein', 18, '/media/logos/btp_algerie.png'),
(15, 'Architecte Projet Résidentiel', 'Architecte pour projet résidentiel haut standing. Maîtrise Revit et AutoCAD.', 'BTP', NOW() + INTERVAL '15 days', NOW() + INTERVAL '90 days', 100000, 'CDI', 35.6969, -0.6331, 'Oran', 'searching', 1, 29, true, NOW() - INTERVAL '3 days', '/media/jobs/job_15.jpg', 'Temps plein', 20, '/media/logos/construction_plus.png'),
(16, 'Chef de Chantier BTP', 'Chef de chantier expérimenté pour projet commercial. Gestion équipes et planning.', 'BTP', NOW() + INTERVAL '7 days', NOW() + INTERVAL '30 days', 70000, 'CDD', 36.3650, 6.6147, 'Constantine', 'searching', 2, 42, true, NOW() - INTERVAL '4 days', '/media/jobs/job_16.jpg', 'Temps plein', 18, '/media/logos/btp_algerie.png'),
(17, 'Conducteur de Travaux', 'Conducteur de travaux pour infrastructures publiques. Coordination sous-traitants.', 'BTP', NOW() + INTERVAL '12 days', NOW() + INTERVAL '60 days', 85000, 'CDI', 36.1900, 5.4139, 'Bejaia', 'searching', 1, 33, true, NOW() - INTERVAL '6 days', '/media/jobs/job_17.jpg', 'Temps plein', 20, '/media/logos/construction_plus.png'),
(18, 'Dessinateur Projeteur BTP', 'Dessinateur projeteur pour plans d''exécution. AutoCAD et lecture plans techniques.', 'BTP', NOW() + INTERVAL '5 days', NOW() + INTERVAL '20 days', 35000, 'Mission', 36.7538, 3.0588, 'Alger', 'searching', 3, 48, true, NOW() - INTERVAL '1 day', '/media/jobs/job_18.jpg', 'Mission 2 mois', 18, '/media/logos/btp_algerie.png'),
(19, 'Métreur Vérificateur', 'Métreur pour quantitatifs et devis. Expérience bâtiment et travaux publics.', 'BTP', NOW() + INTERVAL '18 days', NOW() + INTERVAL '50 days', 60000, 'CDD', 35.6969, -0.6331, 'Oran', 'searching', 1, 26, true, NOW() - INTERVAL '7 days', '/media/jobs/job_19.jpg', 'Temps plein', 20, '/media/logos/construction_plus.png');

-- ============================================================================
-- SECTION 3: CANDIDATURES (20 applications in all statuses)
-- ============================================================================

INSERT INTO candidature (id, candidat_id, offre_id, date_postulation, message_personnalise, statut) VALUES
-- en_attente (6-12)
(6, 7, 5, NOW() - INTERVAL '2 days', 'Bonjour, je suis très intéressée par ce poste. J''ai 3 ans d''expérience en Django et je maîtrise PostgreSQL et Redis. Mon portfolio est disponible sur mon profil.', 'en_attente'),
(7, 11, 8, NOW() - INTERVAL '3 days', 'Candidature pour le poste de Data Analyst. J''ai travaillé 2 ans dans le secteur bancaire avec Python et Power BI.', 'en_attente'),
(8, 14, 7, NOW() - INTERVAL '1 day', 'Développeur Flutter avec 3 ans d''expérience. J''ai publié plusieurs apps sur Play Store et App Store.', 'en_attente'),
(9, 8, 10, NOW() - INTERVAL '4 days', 'Designer UI/UX passionné avec expérience en design systems. Maîtrise Figma et Adobe XD.', 'en_attente'),
(10, 12, 11, NOW() - INTERVAL '5 days', 'Graphiste freelance avec portfolio varié. Spécialisé en identités visuelles et supports print.', 'en_attente'),
(11, 9, 14, NOW() - INTERVAL '2 days', 'Architecte avec 5 ans d''expérience. J''ai supervisé plusieurs projets d''infrastructures routières.', 'en_attente'),
(12, 10, 16, NOW() - INTERVAL '3 days', 'Ingénieur génie civil expérimenté en gestion de chantier. Disponible immédiatement.', 'en_attente'),

-- acceptee (13-17)
(13, 7, 9, NOW() - INTERVAL '10 days', 'Développeuse full stack React/Node avec expérience en applications SaaS.', 'acceptee'),
(14, 13, 6, NOW() - INTERVAL '12 days', 'Chef de projet IT avec 4 ans d''expérience en méthodologies agiles (Scrum, Kanban).', 'acceptee'),
(15, 8, 12, NOW() - INTERVAL '15 days', 'Motion designer créatif. Portfolio disponible avec animations After Effects.', 'acceptee'),
(16, 9, 15, NOW() - INTERVAL '8 days', 'Architecte spécialisée en projets résidentiels haut standing. Maîtrise Revit.', 'acceptee'),
(17, 10, 17, NOW() - INTERVAL '14 days', 'Conducteur de travaux avec expérience en coordination de sous-traitants.', 'acceptee'),

-- refusee (18-25)
(18, 11, 5, NOW() - INTERVAL '20 days', 'Intéressée par le poste de développeur backend.', 'refusee'),
(19, 12, 6, NOW() - INTERVAL '18 days', 'Candidature pour chef de projet IT.', 'refusee'),
(20, 14, 8, NOW() - INTERVAL '22 days', 'Data analyst avec compétences Python.', 'refusee'),
(21, 15, 10, NOW() - INTERVAL '25 days', 'Designer UI/UX junior cherchant opportunité.', 'refusee'),
(22, 7, 14, NOW() - INTERVAL '19 days', 'Développeuse intéressée par le secteur BTP.', 'refusee'),
(23, 8, 16, NOW() - INTERVAL '21 days', 'Designer avec intérêt pour gestion de chantier.', 'refusee'),
(24, 11, 11, NOW() - INTERVAL '17 days', 'Analyste cherchant poste en design graphique.', 'refusee'),
(25, 13, 14, NOW() - INTERVAL '23 days', 'Chef de projet avec expérience variée.', 'refusee');

-- ============================================================================
-- SECTION 4: MISSIONS (5 missions with different statuses)
-- ============================================================================

INSERT INTO mission (id, candidature_id, date_debut, date_fin, duree_heures, statut, location, image_url, summary) VALUES
-- en_cours (3-4)
(3, 13, NOW() - INTERVAL '5 days', NULL, NULL, 'en_cours', 'Alger', '/media/missions/mission_3.jpg', 'Développement application SaaS - Module de gestion utilisateurs'),
(4, 14, NOW() - INTERVAL '8 days', NULL, NULL, 'en_cours', 'Alger', '/media/missions/mission_4.jpg', 'Coordination équipe développement - Sprint planning et suivi'),

-- terminee (5-6)
(5, 15, NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days', 200, 'terminee', 'Alger', '/media/missions/mission_5.jpg', 'Création animations promotionnelles - 5 vidéos livrées'),
(6, 16, NOW() - INTERVAL '45 days', NOW() - INTERVAL '10 days', 280, 'terminee', 'Oran', '/media/missions/mission_6.jpg', 'Conception architecturale projet résidentiel - Plans validés'),

-- en_attente (7)
(7, 17, NULL, NULL, NULL, 'en_attente', 'Bejaia', '/media/missions/mission_7.jpg', 'Supervision travaux infrastructure - Démarrage prévu prochainement');

-- ============================================================================
-- SECTION 5: CONVERSATIONS (10 conversations - DM and group)
-- ============================================================================

INSERT INTO conversation (id, type, nom, created_by_id, created_at) VALUES
-- Direct messages (1-7)
(1, 'direct', NULL, 7, NOW() - INTERVAL '10 days'),
(2, 'direct', NULL, 8, NOW() - INTERVAL '8 days'),
(3, 'direct', NULL, 9, NOW() - INTERVAL '15 days'),
(4, 'direct', NULL, 11, NOW() - INTERVAL '5 days'),
(5, 'direct', NULL, 13, NOW() - INTERVAL '12 days'),
(6, 'direct', NULL, 14, NOW() - INTERVAL '7 days'),
(7, 'direct', NULL, 10, NOW() - INTERVAL '20 days'),

-- Group conversations (8-10)
(8, 'group', 'Équipe Projet SaaS', 16, NOW() - INTERVAL '6 days'),
(9, 'group', 'Designers Algérie', 17, NOW() - INTERVAL '18 days'),
(10, 'group', 'BTP Constantine', 18, NOW() - INTERVAL '25 days');

-- Conversation members
INSERT INTO conversation_member (conversation_id, user_id, role, joined_at, left_at, is_invitation) VALUES
-- Direct message members
(1, 7, 'member', NOW() - INTERVAL '10 days', NULL, false),
(1, 16, 'member', NOW() - INTERVAL '10 days', NULL, false),
(2, 8, 'member', NOW() - INTERVAL '8 days', NULL, false),
(2, 17, 'member', NOW() - INTERVAL '8 days', NULL, false),
(3, 9, 'member', NOW() - INTERVAL '15 days', NULL, false),
(3, 18, 'member', NOW() - INTERVAL '15 days', NULL, false),
(4, 11, 'member', NOW() - INTERVAL '5 days', NULL, false),
(4, 16, 'member', NOW() - INTERVAL '5 days', NULL, false),
(5, 13, 'member', NOW() - INTERVAL '12 days', NULL, false),
(5, 19, 'member', NOW() - INTERVAL '12 days', NULL, false),
(6, 14, 'member', NOW() - INTERVAL '7 days', NULL, false),
(6, 21, 'member', NOW() - INTERVAL '7 days', NULL, false),
(7, 10, 'member', NOW() - INTERVAL '20 days', NULL, false),
(7, 18, 'member', NOW() - INTERVAL '20 days', NULL, false),

-- Group members
(8, 16, 'admin', NOW() - INTERVAL '6 days', NULL, false),
(8, 7, 'member', NOW() - INTERVAL '6 days', NULL, false),
(8, 13, 'member', NOW() - INTERVAL '6 days', NULL, false),
(8, 14, 'member', NOW() - INTERVAL '5 days', NULL, false),
(9, 17, 'admin', NOW() - INTERVAL '18 days', NULL, false),
(9, 8, 'member', NOW() - INTERVAL '18 days', NULL, false),
(9, 12, 'member', NOW() - INTERVAL '17 days', NULL, false),
(9, 15, 'member', NOW() - INTERVAL '16 days', NULL, false),
(10, 18, 'admin', NOW() - INTERVAL '25 days', NULL, false),
(10, 9, 'member', NOW() - INTERVAL '25 days', NULL, false),
(10, 10, 'member', NOW() - INTERVAL '24 days', NULL, false);

-- ============================================================================
-- SECTION 6: MESSAGES (30 messages in conversations)
-- ============================================================================

INSERT INTO message (id, contenu, date_envoi, conversation_id, expediteur_id, est_lu, destinataire_id, type) VALUES
-- Conversation 1 (Amina <-> Tech Solutions)
(1, 'Bonjour, j''ai postulé pour le poste de développeur backend. Quand puis-je espérer une réponse ?', NOW() - INTERVAL '10 days', 1, 7, true, NULL, 'text'),
(2, 'Bonjour Amina, merci pour votre candidature. Nous l''examinons actuellement. Vous aurez une réponse sous 48h.', NOW() - INTERVAL '10 days', 1, 16, true, NULL, 'text'),
(3, 'Parfait, merci beaucoup !', NOW() - INTERVAL '9 days', 1, 7, true, NULL, 'text'),

-- Conversation 2 (Yacine <-> Design Studio)
(4, 'Bonjour, je suis intéressé par le poste de designer UI/UX. Mon portfolio est disponible sur Behance.', NOW() - INTERVAL '8 days', 2, 8, true, NULL, 'text'),
(5, 'Bonjour Yacine, excellent portfolio ! Seriez-vous disponible pour un entretien cette semaine ?', NOW() - INTERVAL '7 days', 2, 17, true, NULL, 'text'),
(6, 'Oui, je suis disponible jeudi ou vendredi après-midi.', NOW() - INTERVAL '7 days', 2, 8, true, NULL, 'text'),
(7, 'Parfait, je vous propose jeudi à 14h. Je vous envoie le lien de visio par email.', NOW() - INTERVAL '6 days', 2, 17, true, NULL, 'text'),

-- Conversation 3 (Salima <-> BTP Algérie)
(8, 'Bonjour, concernant le poste d''architecte, quels sont les projets en cours ?', NOW() - INTERVAL '15 days', 3, 9, true, NULL, 'text'),
(9, 'Bonjour Salima, nous avons 3 projets résidentiels et 1 commercial. Tous à Oran.', NOW() - INTERVAL '14 days', 3, 18, true, NULL, 'text'),
(10, 'Intéressant ! J''ai justement de l''expérience sur ce type de projets.', NOW() - INTERVAL '14 days', 3, 9, true, NULL, 'text'),

-- Conversation 4 (Nadia <-> Tech Solutions)
(11, 'Bonjour, le poste de data analyst est-il toujours disponible ?', NOW() - INTERVAL '5 days', 4, 11, true, NULL, 'text'),
(12, 'Oui, nous recrutons toujours. Avez-vous de l''expérience avec Power BI ?', NOW() - INTERVAL '4 days', 4, 16, true, NULL, 'text'),
(13, 'Oui, 2 ans d''expérience en BI dans le secteur bancaire.', NOW() - INTERVAL '4 days', 4, 11, false, NULL, 'text'),

-- Conversation 5 (Fatima <-> Digital Agency)
(14, 'Bonjour, j''ai été acceptée pour la mission ! Quand puis-je commencer ?', NOW() - INTERVAL '12 days', 5, 13, true, NULL, 'text'),
(15, 'Félicitations Fatima ! Vous pouvez commencer lundi prochain. Je vous envoie le contrat.', NOW() - INTERVAL '11 days', 5, 19, true, NULL, 'text'),
(16, 'Parfait, merci ! J''ai hâte de commencer.', NOW() - INTERVAL '11 days', 5, 13, true, NULL, 'text'),

-- Conversation 6 (Riad <-> Web Innovate)
(17, 'Bonjour, concernant le poste Flutter, utilisez-vous des packages spécifiques ?', NOW() - INTERVAL '7 days', 6, 14, true, NULL, 'text'),
(18, 'Oui, nous utilisons Riverpod pour le state management et Dio pour les requêtes HTTP.', NOW() - INTERVAL '6 days', 6, 21, true, NULL, 'text'),
(19, 'Parfait, je maîtrise ces deux packages.', NOW() - INTERVAL '6 days', 6, 14, true, NULL, 'text'),

-- Conversation 7 (Karim <-> BTP Algérie)
(20, 'Bonjour, j''aimerais en savoir plus sur le projet d''infrastructure.', NOW() - INTERVAL '20 days', 7, 10, true, NULL, 'text'),
(21, 'C''est un projet routier de 15km. Démarrage prévu dans 2 mois.', NOW() - INTERVAL '19 days', 7, 18, true, NULL, 'text'),

-- Group 8 (Équipe Projet SaaS)
(22, 'Bienvenue dans le groupe projet ! Premier sprint planning demain à 10h.', NOW() - INTERVAL '6 days', 8, 16, true, NULL, 'text'),
(23, 'Merci ! J''ai hâte de commencer.', NOW() - INTERVAL '6 days', 8, 7, true, NULL, 'text'),
(24, 'Pareil, ça va être un super projet !', NOW() - INTERVAL '5 days', 8, 13, true, NULL, 'text'),
(25, 'Je prépare les maquettes pour demain.', NOW() - INTERVAL '5 days', 8, 14, true, NULL, 'text'),

-- Group 9 (Designers Algérie)
(26, 'Salut à tous ! Groupe pour partager ressources et opportunités design.', NOW() - INTERVAL '18 days', 9, 17, true, NULL, 'text'),
(27, 'Super initiative ! Merci Samira.', NOW() - INTERVAL '17 days', 9, 8, true, NULL, 'text'),
(28, 'Content de rejoindre le groupe !', NOW() - INTERVAL '16 days', 9, 12, true, NULL, 'text'),

-- Group 10 (BTP Constantine)
(29, 'Groupe pour coordination projets BTP Constantine.', NOW() - INTERVAL '25 days', 10, 18, true, NULL, 'text'),
(30, 'Parfait, on pourra échanger sur les chantiers en cours.', NOW() - INTERVAL '24 days', 10, 9, true, NULL, 'text');

-- ============================================================================
-- SECTION 7: INTERVIEWS (10 interviews in all statuses)
-- ============================================================================

INSERT INTO interview (id, candidate_id, recruiter_id, job_id, scheduled_date, status, notes, created_at, candidature_id) VALUES
-- scheduled (1-4)
(1, 7, 16, 5, NOW() + INTERVAL '3 days', 'scheduled', 'Entretien technique Django/PostgreSQL. Prévoir 1h.', NOW() - INTERVAL '2 days', 6),
(2, 8, 17, 10, NOW() + INTERVAL '5 days', 'scheduled', 'Présentation portfolio et discussion design systems.', NOW() - INTERVAL '4 days', 9),
(3, 11, 16, 8, NOW() + INTERVAL '7 days', 'scheduled', 'Test technique Python et SQL. Cas pratique BI.', NOW() - INTERVAL '3 days', 7),
(4, 9, 18, 14, NOW() + INTERVAL '10 days', 'scheduled', 'Entretien sur site. Visite chantier en cours.', NOW() - INTERVAL '2 days', 11),

-- completed (5-7)
(5, 13, 19, 6, NOW() - INTERVAL '5 days', 'completed', 'Excellent profil. Expérience agile confirmée. Recommandé pour embauche.', NOW() - INTERVAL '12 days', 14),
(6, 8, 19, 12, NOW() - INTERVAL '8 days', 'completed', 'Portfolio impressionnant. Bonnes compétences After Effects. Accepté.', NOW() - INTERVAL '15 days', 15),
(7, 9, 20, 15, NOW() - INTERVAL '3 days', 'completed', 'Très bonne maîtrise Revit. Projets similaires réalisés. Validé.', NOW() - INTERVAL '8 days', 16),

-- cancelled (8-10)
(8, 11, 16, 5, NOW() - INTERVAL '15 days', 'cancelled', 'Candidat a trouvé un autre poste.', NOW() - INTERVAL '20 days', 18),
(9, 12, 19, 6, NOW() - INTERVAL '12 days', 'cancelled', 'Recruteur a annulé - poste pourvu.', NOW() - INTERVAL '18 days', 19),
(10, 14, 16, 8, NOW() - INTERVAL '18 days', 'cancelled', 'Candidat non disponible aux dates proposées.', NOW() - INTERVAL '22 days', 20);

-- ============================================================================
-- SECTION 8: EVALUATIONS (8 evaluations with varied ratings)
-- ============================================================================

INSERT INTO evaluation (id, mission_id, note, commentaire, recruiter_reply, recruiter_reply_date, recruiter_name, evaluateur_id, evalue_id, date_evaluation) VALUES
-- 5 stars (1-2)
(1, 5, 5, 'Excellent travail ! Les animations sont créatives et de haute qualité. Livraison dans les délais. Je recommande vivement.', 'Merci beaucoup pour votre retour positif ! Ce fut un plaisir de travailler avec vous.', NOW() - INTERVAL '3 days', 'Yasmine - Digital Agency', 8, 19, NOW() - INTERVAL '4 days'),
(2, 6, 5, 'Architecte très professionnelle. Plans détaillés et conformes aux normes. Communication excellente tout au long du projet.', 'Merci pour votre confiance. Hâte de collaborer sur de futurs projets !', NOW() - INTERVAL '8 days', 'Sofiane - Construction Plus', 9, 20, NOW() - INTERVAL '9 days'),

-- 4 stars (3-5)
(3, 3, 4, 'Bon développeur, code propre et bien documenté. Quelques retards mineurs mais résultats satisfaisants.', NULL, NULL, NULL, 7, 19, NOW() - INTERVAL '2 days'),
(4, 4, 4, 'Chef de projet compétent. Bonne gestion d''équipe. Pourrait améliorer la communication avec les stakeholders.', 'Merci pour vos retours constructifs. Je vais travailler sur ces points.', NOW() - INTERVAL '6 days', 'Yasmine - Digital Agency', 13, 19, NOW() - INTERVAL '7 days'),
(5, 5, 4, 'Très créatif mais quelques révisions nécessaires. Résultat final excellent.', NULL, NULL, NULL, 19, 8, NOW() - INTERVAL '5 days'),

-- 3 stars (6-8)
(6, 3, 3, 'Travail correct mais manque d''autonomie. Nécessite beaucoup de supervision.', NULL, NULL, NULL, 19, 7, NOW() - INTERVAL '1 day'),
(7, 4, 3, 'Compétences techniques OK mais communication à améliorer. Délais respectés.', NULL, NULL, NULL, 16, 13, NOW() - INTERVAL '3 days'),
(8, 6, 3, 'Bon travail dans l''ensemble. Quelques erreurs dans les plans initiaux mais corrigées rapidement.', 'Merci pour vos retours. J''ai pris note des points à améliorer.', NOW() - INTERVAL '10 days', 'Salima Meziane', 20, 9, NOW() - INTERVAL '11 days');

-- ============================================================================
-- SECTION 9: NOTIFICATIONS (25 notifications covering all types)
-- ============================================================================

INSERT INTO notification (id, utilisateur_id, contenu, type, date_envoi, est_lue, title, job_title, sender_name, avatar_url, count, context_image_url) VALUES
-- Recruiter notifications (1-10)
(1, 16, '2 nouvelles candidatures pour le poste de Développeur Backend Python/Django', 'newApplicants', NOW() - INTERVAL '2 days', false, 'Nouvelles candidatures', 'Développeur Backend Python/Django', NULL, NULL, 2, '/media/jobs/job_5.jpg'),
(2, 17, 'Yacine Khelifi a accepté votre invitation pour un entretien', 'interviewAccepted', NOW() - INTERVAL '6 days', true, 'Entretien accepté', 'Designer UI/UX Senior', 'Yacine Khelifi', '/media/avatars/user_8.jpg', NULL, NULL),
(3, 19, 'Nouveau message de Fatima Larbi', 'newMessage', NOW() - INTERVAL '11 days', true, 'Nouveau message', NULL, 'Fatima Larbi', '/media/avatars/user_13.jpg', NULL, NULL),
(4, 18, 'La mission de Salima Meziane expire dans 7 jours', 'missionExpiring', NOW() - INTERVAL '3 days', false, 'Mission bientôt terminée', 'Architecte Projet Résidentiel', 'Salima Meziane', '/media/avatars/user_9.jpg', NULL, '/media/missions/mission_6.jpg'),
(5, 20, 'Mission terminée par Karim Boudiaf', 'missionCompleted', NOW() - INTERVAL '10 days', true, 'Mission complétée', 'Conducteur de Travaux', 'Karim Boudiaf', '/media/avatars/user_10.jpg', NULL, NULL),
(6, 16, 'Question sur votre offre: Développeur Backend Python/Django', 'jobQuestion', NOW() - INTERVAL '5 days', true, 'Question sur une offre', 'Développeur Backend Python/Django', 'Amina Benali', '/media/avatars/user_7.jpg', NULL, NULL),
(7, 19, 'Votre annonce "Chef de Projet IT" a été publiée avec succès', 'announcementCreated', NOW() - INTERVAL '3 days', true, 'Annonce publiée', 'Chef de Projet IT', NULL, NULL, NULL, '/media/jobs/job_6.jpg'),
(8, 17, '3 nouvelles candidatures cette semaine', 'newApplicants', NOW() - INTERVAL '1 day', false, 'Nouvelles candidatures', NULL, NULL, NULL, 3, NULL),
(9, 21, 'Nouveau message de Riad Cherif', 'newMessage', NOW() - INTERVAL '6 days', true, 'Nouveau message', NULL, 'Riad Cherif', '/media/avatars/user_14.jpg', NULL, NULL),
(10, 18, 'Nouvelle candidature pour Ingénieur Génie Civil', 'newApplicants', NOW() - INTERVAL '2 days', false, 'Nouvelle candidature', 'Ingénieur Génie Civil', 'Salima Meziane', '/media/avatars/user_9.jpg', 1, NULL),

-- Candidate notifications (11-23)
(11, 7, 'Votre candidature pour Développeur Backend Python/Django a été acceptée !', 'applicationAccepted', NOW() - INTERVAL '10 days', true, 'Candidature acceptée', 'Développeur Backend Python/Django', 'Tech Solutions DZ', '/media/logos/tech_solutions.png', NULL, '/media/jobs/job_5.jpg'),
(12, 11, 'Votre candidature pour Développeur Backend Python/Django a été refusée', 'applicationRejected', NOW() - INTERVAL '15 days', true, 'Candidature refusée', 'Développeur Backend Python/Django', 'Tech Solutions DZ', '/media/logos/tech_solutions.png', NULL, NULL),
(13, 8, 'Tech Solutions DZ a consulté votre profil', 'applicationViewed', NOW() - INTERVAL '4 days', true, 'Profil consulté', NULL, 'Tech Solutions DZ', '/media/logos/tech_solutions.png', NULL, NULL),
(14, 9, 'Nouvelle offre près de chez vous: Architecte Projet Résidentiel à Oran', 'newNearbyOffer', NOW() - INTERVAL '3 days', false, 'Offre à proximité', 'Architecte Projet Résidentiel', 'Construction Plus', '/media/logos/construction_plus.png', NULL, '/media/jobs/job_15.jpg'),
(15, 10, 'Nouvelle offre correspondant à vos préférences: Conducteur de Travaux', 'jobMatchingPreferences', NOW() - INTERVAL '6 days', true, 'Offre recommandée', 'Conducteur de Travaux', 'BTP Algérie Construction', '/media/logos/btp_algerie.png', NULL, '/media/jobs/job_17.jpg'),
(16, 12, 'L''offre "Graphiste Print et Digital" que vous avez sauvegardée expire dans 5 jours', 'savedJobExpiring', NOW() - INTERVAL '2 days', false, 'Offre bientôt expirée', 'Graphiste Print et Digital', 'Design Studio Algérie', '/media/logos/design_studio.png', NULL, NULL),
(17, 13, 'Nouvelle offre en Informatique: Développeur Full Stack React/Node', 'newJobInCategory', NOW() - INTERVAL '1 day', false, 'Nouvelle offre', 'Développeur Full Stack React/Node', 'Digital Agency DZ', '/media/logos/digital_agency.png', NULL, '/media/jobs/job_9.jpg'),
(18, 14, 'Nouveau message de Web Innovate', 'newMessage', NOW() - INTERVAL '6 days', true, 'Nouveau message', NULL, 'Meriem - Web Innovate', '/media/avatars/user_21.jpg', NULL, NULL),
(19, 15, 'Votre candidature pour Designer UI/UX Senior a été consultée', 'applicationViewed', NOW() - INTERVAL '4 days', true, 'Candidature consultée', 'Designer UI/UX Senior', 'Design Studio Algérie', '/media/logos/design_studio.png', NULL, NULL),
(20, 7, 'Tech Solutions DZ a consulté votre profil', 'profileViewed', NOW() - INTERVAL '8 days', true, 'Profil consulté', NULL, 'Tech Solutions DZ', '/media/logos/tech_solutions.png', NULL, NULL),
(21, 11, 'Complétez votre profil pour augmenter vos chances', 'profileIncomplete', NOW() - INTERVAL '5 days', false, 'Profil incomplet', NULL, NULL, NULL, NULL, NULL),
(22, 8, 'Votre candidature pour Motion Designer a été acceptée !', 'applicationAccepted', NOW() - INTERVAL '15 days', true, 'Candidature acceptée', 'Motion Designer', 'Digital Agency DZ', '/media/logos/digital_agency.png', NULL, '/media/jobs/job_12.jpg'),
(23, 9, 'Votre candidature pour Architecte Projet Résidentiel a été acceptée !', 'applicationAccepted', NOW() - INTERVAL '8 days', true, 'Candidature acceptée', 'Architecte Projet Résidentiel', 'Construction Plus', '/media/logos/construction_plus.png', NULL, '/media/jobs/job_15.jpg'),

-- System notifications (24-25)
(24, 12, 'Mise à jour de l''application disponible', 'system', NOW() - INTERVAL '7 days', true, 'Mise à jour', NULL, NULL, NULL, NULL, NULL),
(25, 14, 'Bienvenue sur Jobiha ! Complétez votre profil pour commencer', 'system', NOW() - INTERVAL '35 days', true, 'Bienvenue', NULL, NULL, NULL, NULL, NULL);

-- ============================================================================
-- SECTION 10: SAVED JOBS (10 saved jobs)
-- ============================================================================

INSERT INTO saved_job (id, candidat_id, offre_id, saved_at) VALUES
(1, 7, 5, NOW() - INTERVAL '5 days'),
(2, 7, 6, NOW() - INTERVAL '8 days'),
(3, 8, 10, NOW() - INTERVAL '6 days'),
(4, 8, 12, NOW() - INTERVAL '10 days'),
(5, 9, 14, NOW() - INTERVAL '4 days'),
(6, 9, 15, NOW() - INTERVAL '7 days'),
(7, 11, 8, NOW() - INTERVAL '3 days'),
(8, 12, 11, NOW() - INTERVAL '9 days'),
(9, 13, 6, NOW() - INTERVAL '12 days'),
(10, 14, 7, NOW() - INTERVAL '2 days');

-- ============================================================================
-- SECTION 11: ALERTES (Job alerts - 8 alerts)
-- ============================================================================

INSERT INTO alerte (id, candidat_id, titre, categorie, type_contrat, salaire_min, localisation, actif, cree_le) VALUES
(1, 7, 'Développeur Backend', 'Informatique', 'CDI', 70000, 'Alger', true, NOW() - INTERVAL '30 days'),
(2, 8, 'Designer UI/UX', 'Design', 'CDI', 60000, 'Alger', true, NOW() - INTERVAL '25 days'),
(3, 9, 'Architecte', 'BTP', 'CDI', 90000, 'Oran', true, NOW() - INTERVAL '40 days'),
(4, 10, 'Ingénieur BTP', 'BTP', 'CDI', 80000, 'Constantine', true, NOW() - INTERVAL '15 days'),
(5, 11, 'Data Analyst', 'Informatique', 'CDI', 65000, 'Alger', true, NOW() - INTERVAL '10 days'),
(6, 12, 'Graphiste', 'Design', 'Freelance', 40000, 'Oran', true, NOW() - INTERVAL '35 days'),
(7, 13, 'Chef de Projet IT', 'Informatique', 'CDI', 100000, 'Alger', false, NOW() - INTERVAL '50 days'),
(8, 14, 'Développeur Mobile', 'Informatique', 'CDD', 55000, 'Bejaia', true, NOW() - INTERVAL '20 days');

-- ============================================================================
-- SECTION 12: RECENT SEARCHES (15 recent searches)
-- ============================================================================

INSERT INTO recent_search (id, user_id, query, searched_at) VALUES
(1, 7, 'développeur python django', NOW() - INTERVAL '1 day'),
(2, 7, 'backend alger', NOW() - INTERVAL '3 days'),
(3, 8, 'designer ui ux', NOW() - INTERVAL '2 days'),
(4, 8, 'figma remote', NOW() - INTERVAL '5 days'),
(5, 9, 'architecte oran', NOW() - INTERVAL '1 day'),
(6, 9, 'btp résidentiel', NOW() - INTERVAL '4 days'),
(7, 10, 'ingénieur génie civil', NOW() - INTERVAL '2 days'),
(8, 11, 'data analyst python', NOW() - INTERVAL '1 day'),
(9, 11, 'business intelligence', NOW() - INTERVAL '6 days'),
(10, 12, 'graphiste freelance', NOW() - INTERVAL '3 days'),
(11, 13, 'chef de projet agile', NOW() - INTERVAL '2 days'),
(12, 14, 'flutter react native', NOW() - INTERVAL '1 day'),
(13, 15, 'marketing digital', NOW() - INTERVAL '4 days'),
(14, 7, 'full stack react node', NOW() - INTERVAL '7 days'),
(15, 8, 'motion designer', NOW() - INTERVAL '8 days');

-- ============================================================================
-- SECTION 13: READ CURSORS (for conversation read status)
-- ============================================================================

INSERT INTO read_cursor (id, conversation_id, user_id, last_read_message_id, updated_at) VALUES
(1, 1, 7, 3, NOW() - INTERVAL '9 days'),
(2, 1, 16, 3, NOW() - INTERVAL '9 days'),
(3, 2, 8, 7, NOW() - INTERVAL '6 days'),
(4, 2, 17, 7, NOW() - INTERVAL '6 days'),
(5, 3, 9, 10, NOW() - INTERVAL '14 days'),
(6, 3, 18, 10, NOW() - INTERVAL '14 days'),
(7, 4, 11, 12, NOW() - INTERVAL '4 days'),
(8, 4, 16, 12, NOW() - INTERVAL '4 days'),
(9, 5, 13, 16, NOW() - INTERVAL '11 days'),
(10, 5, 19, 16, NOW() - INTERVAL '11 days'),
(11, 6, 14, 19, NOW() - INTERVAL '6 days'),
(12, 6, 21, 19, NOW() - INTERVAL '6 days'),
(13, 7, 10, 21, NOW() - INTERVAL '19 days'),
(14, 7, 18, 21, NOW() - INTERVAL '19 days'),
(15, 8, 16, 25, NOW() - INTERVAL '5 days'),
(16, 8, 7, 25, NOW() - INTERVAL '5 days'),
(17, 8, 13, 25, NOW() - INTERVAL '5 days'),
(18, 8, 14, 25, NOW() - INTERVAL '5 days'),
(19, 9, 17, 28, NOW() - INTERVAL '16 days'),
(20, 9, 8, 28, NOW() - INTERVAL '16 days'),
(21, 9, 12, 28, NOW() - INTERVAL '16 days'),
(22, 10, 18, 30, NOW() - INTERVAL '24 days'),
(23, 10, 9, 30, NOW() - INTERVAL '24 days'),
(24, 10, 10, 30, NOW() - INTERVAL '24 days');

-- ============================================================================
-- UPDATE SEQUENCES TO CONTINUE FROM CORRECT IDs
-- ============================================================================

SELECT setval('utilisateur_id_seq', 21, true);
SELECT setval('offre_id_seq', 19, true);
SELECT setval('candidature_id_seq', 25, true);
SELECT setval('mission_id_seq', 7, true);
SELECT setval('conversation_id_seq', 10, true);
SELECT setval('message_id_seq', 30, true);
SELECT setval('interview_id_seq', 10, true);
SELECT setval('evaluation_id_seq', 8, true);
SELECT setval('notification_id_seq', 25, true);
SELECT setval('saved_job_id_seq', 10, true);
SELECT setval('alerte_id_seq', 8, true);
SELECT setval('recent_search_id_seq', 15, true);
SELECT setval('read_cursor_id_seq', 24, true);

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
-- Summary:
-- - 15 new users (9 candidats, 6 recruteurs) with IDs 7-21
-- - 15 new job offers covering Informatique, Design, and BTP categories
-- - 20 candidatures in all statuses (en_attente, acceptee, refusee)
-- - 5 missions in different statuses (en_cours, terminee, en_attente)
-- - 10 conversations (7 direct, 3 group) with 30 messages
-- - 10 interviews in all statuses (scheduled, completed, cancelled)
-- - 8 evaluations with ratings from 3 to 5 stars
-- - 25 notifications covering all notification types
-- - 10 saved jobs
-- - 8 job alerts
-- - 15 recent searches
-- - 24 read cursors for conversation tracking
--
-- All passwords: password123
-- All IDs start from existing max IDs to avoid conflicts
-- Realistic Algerian data: names, cities, phone numbers, companies
-- ============================================================================
