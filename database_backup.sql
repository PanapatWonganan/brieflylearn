-- MySQL dump 10.13  Distrib 9.2.0, for macos15.2 (arm64)
--
-- Host: localhost    Database: fitness_lms
-- ------------------------------------------------------
-- Server version	9.2.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `achievements`
--

DROP TABLE IF EXISTS `achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievements` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `badge_icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rarity` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'common',
  `criteria` json NOT NULL,
  `xp_reward` int NOT NULL DEFAULT '100',
  `star_seeds_reward` int NOT NULL DEFAULT '50',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `achievements_category_rarity_index` (`category`,`rarity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES ('0198b397-29c0-702e-bad0-e34a667f520a','นักปลูกมือใหม่','learning','ปลูกพืชแรกในสวนของคุณ','🌱','common','\"{\\\"type\\\":\\\"lessons_completed\\\",\\\"threshold\\\":1}\"',100,50,1,1,'2025-08-16 08:54:45','2025-08-16 09:53:25'),('0198b397-29c8-72bb-aeea-ca2d90c25024','นักเรียนขยัน','learning','เรียนคอร์สจบ 1 คอร์ส','📚','common','\"{\\\"type\\\":\\\"lessons_completed\\\",\\\"threshold\\\":10}\"',200,100,1,2,'2025-08-16 08:54:45','2025-08-16 09:53:25'),('0198b397-29cb-73d3-8a9d-b3086b8e814c','ปราชญ์แห่งสุขภาพ','learning','เรียนคอร์สจบครบ 5 คอร์ส','🎓','rare','\"{\\\"type\\\":\\\"courses_completed\\\",\\\"threshold\\\":3}\"',500,300,1,10,'2025-08-16 08:54:45','2025-08-16 09:53:25'),('0198b397-29ce-70b9-bda2-d0677af6527c','นักสู้ยามเช้า','fitness','ออกกำลังกายเช้าตรู่ติดต่อกัน 7 วัน','🌅','common','{\"days\": 7, \"type\": \"consecutive_days\", \"activity\": \"exercise\"}',300,150,1,3,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29d0-71d2-b503-e8d6a4e6fd5e','มาราธอนเนอร์','fitness','ออกกำลังกายสะสม 100 ชั่วโมง','🏃‍♀️','epic','{\"type\": \"activity_hours\", \"hours\": 100, \"activity\": \"exercise\"}',1000,500,1,15,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29d4-720f-8dca-2aba97e1b661','จิตสงบ','mental','ฝึกสมาธิครบ 30 วัน','🧘‍♀️','common','{\"days\": 30, \"type\": \"consecutive_days\", \"activity\": \"meditation\"}',400,200,1,4,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29d6-739a-b734-efa128169a47','ชีวิตสมดุล','mental','ทำกิจกรรมผ่อนคลายทุกประเภท','⚖️','rare','{\"type\": \"activity_variety\", \"activities\": [\"meditation\", \"yoga\", \"relaxation\"]}',600,350,1,12,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29d8-7399-ad28-559411751bb2','เพื่อนที่ดี','social','ช่วยเหลือเพื่อนในสวนครบ 10 ครั้ง','🤝','common','{\"type\": \"help_friends\", \"count\": 10}',250,125,1,5,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29da-7112-b4e4-74d56b95db29','ผู้นำชุมชน','social','มีเพื่อนในสวนมากกว่า 20 คน','👑','epic','{\"type\": \"friend_count\", \"count\": 20}',800,400,1,18,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29dd-7004-8264-1682c0d57a6e','นักสวนระดับ 5','special','เลื่อนระดับสวนถึง Level 5','🏆','rare','{\"type\": \"level_reach\", \"level\": 5}',500,250,1,20,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29de-71f4-8a81-b0bae0abc5d9','มาสเตอร์การ์เดนเนอร์','special','เลื่อนระดับสวนถึง Level 20','🌟','legendary','{\"type\": \"level_reach\", \"level\": 20}',2000,1000,1,50,'2025-08-16 08:54:45','2025-08-16 08:54:45');
/*!40000 ALTER TABLE `achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('boostme-admin-cache-c530c3f4079a09f7804259002307b5e50c656d52','i:1;',1755344887),('boostme-admin-cache-c530c3f4079a09f7804259002307b5e50c656d52:timer','i:1755344887;',1755344887);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certificates`
--

DROP TABLE IF EXISTS `certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificates` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `certificate_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `issued_at` timestamp NOT NULL,
  `pdf_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificates_user_id_course_id_unique` (`user_id`,`course_id`),
  UNIQUE KEY `certificates_certificate_number_unique` (`certificate_number`),
  KEY `certificates_course_id_foreign` (`course_id`),
  CONSTRAINT `certificates_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `certificates_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `instructor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thumbnail_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` enum('beginner','intermediate','advanced') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'beginner',
  `duration` int NOT NULL DEFAULT '0',
  `is_published` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courses_instructor_id_foreign` (`instructor_id`),
  KEY `courses_category_id_foreign` (`category_id`),
  CONSTRAINT `courses_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `courses_instructor_id_foreign` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES ('0198b253-9405-705d-bd25-8a0a5b787401','โยคะเริ่มต้น','คอร์สโยคะสำหรับผู้เริ่มต้น',1000.00,'0198acf4-a689-73d9-9a9d-3cda38eb7382',NULL,NULL,'beginner',0,0,'2025-08-16 03:01:18','2025-08-16 03:01:18');
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_challenges`
--

DROP TABLE IF EXISTS `daily_challenges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_challenges` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `challenge_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirements` json NOT NULL,
  `xp_reward` int NOT NULL DEFAULT '50',
  `star_seeds_reward` int NOT NULL DEFAULT '25',
  `available_date` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `daily_challenges_available_date_is_active_index` (`available_date`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_challenges`
--

LOCK TABLES `daily_challenges` WRITE;
/*!40000 ALTER TABLE `daily_challenges` DISABLE KEYS */;
INSERT INTO `daily_challenges` VALUES ('0198b397-29e5-71da-bbbc-a0cc76c70f82','รดน้ำสวนประจำวัน','รดน้ำพืชในสวนของคุณอย่างน้อย 3 ต้น','plant_care','{\"type\": \"water_plants\", \"count\": 3}',100,50,'2025-08-16',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29ec-71cd-80dc-75a59ee0bd43','นักเรียนขยัน','เรียนบทเรียนจบ 1 บทเรียน','course_complete','{\"type\": \"complete_lesson\", \"count\": 1}',150,75,'2025-08-16',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29ef-700e-9cfc-7fdd4828e88a','เข้าสู่ระบบประจำวัน','เข้าใช้ระบบอย่างน้อย 1 ครั้ง','login','{\"type\": \"daily_login\", \"count\": 1}',50,25,'2025-08-16',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29f1-71a4-aa96-175321f2fb0e','รดน้ำสวนประจำวัน','รดน้ำพืชในสวนของคุณอย่างน้อย 3 ต้น','plant_care','{\"type\": \"water_plants\", \"count\": 3}',100,50,'2025-08-17',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29f2-7358-83c9-b35b2b892061','นักเรียนขยัน','เรียนบทเรียนจบ 1 บทเรียน','course_complete','{\"type\": \"complete_lesson\", \"count\": 1}',150,75,'2025-08-17',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29f4-7200-bc9d-72d554b4493b','เข้าสู่ระบบประจำวัน','เข้าใช้ระบบอย่างน้อย 1 ครั้ง','login','{\"type\": \"daily_login\", \"count\": 1}',50,25,'2025-08-17',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29f6-73fc-ad7d-29857e01308e','รดน้ำสวนประจำวัน','รดน้ำพืชในสวนของคุณอย่างน้อย 3 ต้น','plant_care','{\"type\": \"water_plants\", \"count\": 3}',100,50,'2025-08-18',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29f7-70db-91c8-fdfa3b576cec','นักเรียนขยัน','เรียนบทเรียนจบ 1 บทเรียน','course_complete','{\"type\": \"complete_lesson\", \"count\": 1}',150,75,'2025-08-18',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29f7-70db-91c8-fdfa3ba622e0','เข้าสู่ระบบประจำวัน','เข้าใช้ระบบอย่างน้อย 1 ครั้ง','login','{\"type\": \"daily_login\", \"count\": 1}',50,25,'2025-08-18',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29f8-7241-946f-0a21efffd11b','รดน้ำสวนประจำวัน','รดน้ำพืชในสวนของคุณอย่างน้อย 3 ต้น','plant_care','{\"type\": \"water_plants\", \"count\": 3}',100,50,'2025-08-19',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29fb-7223-87ad-f7c997f1150b','นักเรียนขยัน','เรียนบทเรียนจบ 1 บทเรียน','course_complete','{\"type\": \"complete_lesson\", \"count\": 1}',150,75,'2025-08-19',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29ff-70f5-bdfb-163f0659966e','เข้าสู่ระบบประจำวัน','เข้าใช้ระบบอย่างน้อย 1 ครั้ง','login','{\"type\": \"daily_login\", \"count\": 1}',50,25,'2025-08-19',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a01-712c-8744-b952675c8b4a','รดน้ำสวนประจำวัน','รดน้ำพืชในสวนของคุณอย่างน้อย 3 ต้น','plant_care','{\"type\": \"water_plants\", \"count\": 3}',100,50,'2025-08-20',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a02-71cc-a67a-12a8ff39d2b9','นักเรียนขยัน','เรียนบทเรียนจบ 1 บทเรียน','course_complete','{\"type\": \"complete_lesson\", \"count\": 1}',150,75,'2025-08-20',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a04-70ef-a9d7-b118b8c6fda7','เข้าสู่ระบบประจำวัน','เข้าใช้ระบบอย่างน้อย 1 ครั้ง','login','{\"type\": \"daily_login\", \"count\": 1}',50,25,'2025-08-20',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a06-727e-b772-a3b470bd4f80','รดน้ำสวนประจำวัน','รดน้ำพืชในสวนของคุณอย่างน้อย 3 ต้น','plant_care','{\"type\": \"water_plants\", \"count\": 3}',100,50,'2025-08-21',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a07-7396-bf2a-87084610c123','นักเรียนขยัน','เรียนบทเรียนจบ 1 บทเรียน','course_complete','{\"type\": \"complete_lesson\", \"count\": 1}',150,75,'2025-08-21',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a08-70f6-90df-840f027aac1d','เข้าสู่ระบบประจำวัน','เข้าใช้ระบบอย่างน้อย 1 ครั้ง','login','{\"type\": \"daily_login\", \"count\": 1}',50,25,'2025-08-21',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a0a-7018-8161-b83d03da938d','รดน้ำสวนประจำวัน','รดน้ำพืชในสวนของคุณอย่างน้อย 3 ต้น','plant_care','{\"type\": \"water_plants\", \"count\": 3}',100,50,'2025-08-22',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a0b-709f-87b1-25190bf0cfd1','นักเรียนขยัน','เรียนบทเรียนจบ 1 บทเรียน','course_complete','{\"type\": \"complete_lesson\", \"count\": 1}',150,75,'2025-08-22',1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-2a0c-73b8-9927-f0eb5c84b669','เข้าสู่ระบบประจำวัน','เข้าใช้ระบบอย่างน้อย 1 ครั้ง','login','{\"type\": \"daily_login\", \"count\": 1}',50,25,'2025-08-22',1,'2025-08-16 08:54:45','2025-08-16 08:54:45');
/*!40000 ALTER TABLE `daily_challenges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollments`
--

DROP TABLE IF EXISTS `enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollments` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `payment_status` enum('pending','completed','failed','refunded') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `amount_paid` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_date` timestamp NULL DEFAULT NULL,
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `progress` decimal(5,2) NOT NULL DEFAULT '0.00',
  `enrolled_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `enrollments_user_id_course_id_unique` (`user_id`,`course_id`),
  KEY `enrollments_course_id_foreign` (`course_id`),
  CONSTRAINT `enrollments_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `enrollments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollments`
--

LOCK TABLES `enrollments` WRITE;
/*!40000 ALTER TABLE `enrollments` DISABLE KEYS */;
INSERT INTO `enrollments` VALUES ('0198b3c9-4abd-72fb-a306-e9db1a1db837','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b253-9405-705d-bd25-8a0a5b787401','active','pending',0.00,NULL,NULL,NULL,100.00,'2025-08-16 09:51:18','2025-08-16 09:51:18','2025-08-16 09:49:30',NULL);
/*!40000 ALTER TABLE `enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
INSERT INTO `failed_jobs` VALUES (1,'9441a671-ce34-4524-95c2-ed68fe1492ae','database','default','{\"uuid\":\"9441a671-ce34-4524-95c2-ed68fe1492ae\",\"displayName\":\"App\\\\Jobs\\\\ProcessVideoJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":3600,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\ProcessVideoJob\",\"command\":\"O:24:\\\"App\\\\Jobs\\\\ProcessVideoJob\\\":1:{s:8:\\\"\\u0000*\\u0000video\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Video\\\";s:2:\\\"id\\\";s:36:\\\"0198b29d-4b5d-71f8-9ebd-d6bc54772b66\\\";s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}}\"},\"createdAt\":1755343309,\"delay\":null}','Exception: Video file not found: /Users/panapat/khun_bebe/fitness-lms-admin/storage/app/private/private/temp-videos/gi.gi_1989_1754151920_1835449457.mp4 in /Users/panapat/khun_bebe/fitness-lms-admin/app/Jobs/ProcessVideoJob.php:58\nStack trace:\n#0 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): App\\Jobs\\ProcessVideoJob->handle()\n#1 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#2 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#3 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#4 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Container.php(797): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#5 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(132): Illuminate\\Container\\Container->call(Array)\n#6 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():129}(Object(App\\Jobs\\ProcessVideoJob))\n#7 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessVideoJob))\n#8 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(136): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#9 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(134): Illuminate\\Bus\\Dispatcher->dispatchNow(Object(App\\Jobs\\ProcessVideoJob), false)\n#10 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():127}(Object(App\\Jobs\\ProcessVideoJob))\n#11 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessVideoJob))\n#12 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(127): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#13 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(68): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(App\\Jobs\\ProcessVideoJob))\n#14 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Jobs/Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Array)\n#15 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(444): Illuminate\\Queue\\Jobs\\Job->fire()\n#16 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(394): Illuminate\\Queue\\Worker->process(\'database\', Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(Illuminate\\Queue\\WorkerOptions))\n#17 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(180): Illuminate\\Queue\\Worker->runJob(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), \'database\', Object(Illuminate\\Queue\\WorkerOptions))\n#18 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon(\'database\', \'default\', Object(Illuminate\\Queue\\WorkerOptions))\n#19 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker(\'database\', \'default\')\n#20 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#21 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#22 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#23 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#24 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Container.php(797): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#25 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Console/Command.php(211): Illuminate\\Container\\Container->call(Array)\n#26 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Command/Command.php(318): Illuminate\\Console\\Command->execute(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#27 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Console/Command.php(180): Symfony\\Component\\Console\\Command\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#28 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Application.php(1092): Illuminate\\Console\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#29 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Application.php(341): Symfony\\Component\\Console\\Application->doRunCommand(Object(Illuminate\\Queue\\Console\\WorkCommand), Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#30 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Application.php(192): Symfony\\Component\\Console\\Application->doRun(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#31 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Foundation/Console/Kernel.php(197): Symfony\\Component\\Console\\Application->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#32 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Foundation/Application.php(1234): Illuminate\\Foundation\\Console\\Kernel->handle(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#33 /Users/panapat/khun_bebe/fitness-lms-admin/artisan(16): Illuminate\\Foundation\\Application->handleCommand(Object(Symfony\\Component\\Console\\Input\\ArgvInput))\n#34 {main}','2025-08-16 04:21:56'),(2,'6e20df41-8795-46a8-9fbb-cbce0962ffb6','database','default','{\"uuid\":\"6e20df41-8795-46a8-9fbb-cbce0962ffb6\",\"displayName\":\"App\\\\Jobs\\\\ProcessVideoJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":3,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":3600,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\ProcessVideoJob\",\"command\":\"O:24:\\\"App\\\\Jobs\\\\ProcessVideoJob\\\":1:{s:8:\\\"\\u0000*\\u0000video\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:16:\\\"App\\\\Models\\\\Video\\\";s:2:\\\"id\\\";s:36:\\\"0198b29d-4b76-7382-baee-cd116968a3df\\\";s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}}\"},\"createdAt\":1755343309,\"delay\":null}','Exception: Video file not found: /Users/panapat/khun_bebe/fitness-lms-admin/storage/app/private/private/temp-videos/kkawxin_1754917194_3696835105864523954_4554574300.mp4 in /Users/panapat/khun_bebe/fitness-lms-admin/app/Jobs/ProcessVideoJob.php:58\nStack trace:\n#0 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): App\\Jobs\\ProcessVideoJob->handle()\n#1 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#2 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#3 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#4 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Container.php(797): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#5 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(132): Illuminate\\Container\\Container->call(Array)\n#6 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():129}(Object(App\\Jobs\\ProcessVideoJob))\n#7 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessVideoJob))\n#8 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(136): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#9 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(134): Illuminate\\Bus\\Dispatcher->dispatchNow(Object(App\\Jobs\\ProcessVideoJob), false)\n#10 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():127}(Object(App\\Jobs\\ProcessVideoJob))\n#11 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessVideoJob))\n#12 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(127): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#13 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(68): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(App\\Jobs\\ProcessVideoJob))\n#14 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Jobs/Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Array)\n#15 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(444): Illuminate\\Queue\\Jobs\\Job->fire()\n#16 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(394): Illuminate\\Queue\\Worker->process(\'database\', Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(Illuminate\\Queue\\WorkerOptions))\n#17 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(180): Illuminate\\Queue\\Worker->runJob(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), \'database\', Object(Illuminate\\Queue\\WorkerOptions))\n#18 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(148): Illuminate\\Queue\\Worker->daemon(\'database\', \'default\', Object(Illuminate\\Queue\\WorkerOptions))\n#19 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(131): Illuminate\\Queue\\Console\\WorkCommand->runWorker(\'database\', \'default\')\n#20 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#21 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#22 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#23 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#24 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Container/Container.php(797): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#25 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Console/Command.php(211): Illuminate\\Container\\Container->call(Array)\n#26 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Command/Command.php(318): Illuminate\\Console\\Command->execute(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#27 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Console/Command.php(180): Symfony\\Component\\Console\\Command\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#28 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Application.php(1092): Illuminate\\Console\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#29 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Application.php(341): Symfony\\Component\\Console\\Application->doRunCommand(Object(Illuminate\\Queue\\Console\\WorkCommand), Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#30 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/symfony/console/Application.php(192): Symfony\\Component\\Console\\Application->doRun(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#31 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Foundation/Console/Kernel.php(197): Symfony\\Component\\Console\\Application->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#32 /Users/panapat/khun_bebe/fitness-lms-admin/vendor/laravel/framework/src/Illuminate/Foundation/Application.php(1234): Illuminate\\Foundation\\Console\\Kernel->handle(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#33 /Users/panapat/khun_bebe/fitness-lms-admin/artisan(16): Illuminate\\Foundation\\Application->handleCommand(Object(Symfony\\Component\\Console\\Input\\ArgvInput))\n#34 {main}','2025-08-16 04:21:56');
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `garden_activities`
--

DROP TABLE IF EXISTS `garden_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `garden_activities` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `garden_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activity_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `xp_earned` int NOT NULL DEFAULT '0',
  `star_seeds_earned` int NOT NULL DEFAULT '0',
  `activity_data` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `garden_activities_garden_id_foreign` (`garden_id`),
  KEY `garden_activities_user_id_activity_type_created_at_index` (`user_id`,`activity_type`,`created_at`),
  CONSTRAINT `garden_activities_garden_id_foreign` FOREIGN KEY (`garden_id`) REFERENCES `user_gardens` (`id`) ON DELETE CASCADE,
  CONSTRAINT `garden_activities_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `garden_activities`
--

LOCK TABLES `garden_activities` WRITE;
/*!40000 ALTER TABLE `garden_activities` DISABLE KEYS */;
INSERT INTO `garden_activities` VALUES ('0198b39a-986b-73b8-8498-2d201f8e919d','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','plant','plant','0198b39a-9866-724b-90b0-4c1a309cae41',10,0,'{\"cost\": 10, \"category\": \"fitness\", \"plant_name\": \"My First Rose\", \"plant_type\": \"กุหลาบ\"}','2025-08-16 08:58:29','2025-08-16 08:58:29'),('0198b3b1-a2d5-7396-8185-f6fbd8a165c9','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29e5-71da-bbbc-a0cc76c70f82',100,50,'{\"completed_at\": \"2025-08-16T16:23:39.000000Z\", \"challenge_name\": \"รดน้ำสวนประจำวัน\", \"challenge_type\": \"plant_care\"}','2025-08-16 09:23:39','2025-08-16 09:23:39'),('0198b3b1-a492-72a3-9f3a-1b2870fb61ac','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29ec-71cd-80dc-75a59ee0bd43',150,75,'{\"completed_at\": \"2025-08-16T16:23:40.000000Z\", \"challenge_name\": \"นักเรียนขยัน\", \"challenge_type\": \"course_complete\"}','2025-08-16 09:23:40','2025-08-16 09:23:40'),('0198b3b1-bf91-7035-9af3-660c2ce54825','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29ef-700e-9cfc-7fdd4828e88a',50,25,'{\"completed_at\": \"2025-08-16T16:23:47.000000Z\", \"challenge_name\": \"เข้าสู่ระบบประจำวัน\", \"challenge_type\": \"login\"}','2025-08-16 09:23:47','2025-08-16 09:23:47'),('0198b3b6-b548-7171-8e0f-67008ae220da','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','plant','plant','0198b3b6-b543-73bf-ba38-88bccd546ff7',10,0,'{\"cost\": 10, \"category\": \"fitness\", \"plant_name\": \"My Beautiful Rose Garden\", \"plant_type\": \"กุหลาบ\"}','2025-08-16 09:29:12','2025-08-16 09:29:12'),('0198b3b6-da78-711c-84ee-b2fc1dab7516','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','garden','0198b397-aae9-716e-a117-bee1299b3ad4',20,5,'{\"watered_at\": \"2025-08-16T16:29:21.911835Z\"}','2025-08-16 09:29:21','2025-08-16 09:29:21'),('0198b8d1-e18c-7064-b5dd-4fb8abf363d7','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198b39a-9866-724b-90b0-4c1a309cae41',5,2,'{\"plant_name\": \"My First Rose\", \"stage_after\": 0}','2025-08-17 09:16:59','2025-08-17 09:16:59'),('0198b8d2-2a6b-732e-8fd1-8bf924e6ae19','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29f1-71a4-aa96-175321f2fb0e',100,50,'{\"completed_at\": \"2025-08-17T16:17:17.000000Z\", \"challenge_name\": \"รดน้ำสวนประจำวัน\", \"challenge_type\": \"plant_care\"}','2025-08-17 09:17:17','2025-08-17 09:17:17'),('0198b8d2-40d4-724a-acb9-f0021453abcf','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29f2-7358-83c9-b35b2b892061',150,75,'{\"completed_at\": \"2025-08-17T16:17:23.000000Z\", \"challenge_name\": \"นักเรียนขยัน\", \"challenge_type\": \"course_complete\"}','2025-08-17 09:17:23','2025-08-17 09:17:23'),('0198b8d2-4b91-7081-a94d-368e140223db','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29f4-7200-bc9d-72d554b4493b',50,25,'{\"completed_at\": \"2025-08-17T16:17:26.000000Z\", \"challenge_name\": \"เข้าสู่ระบบประจำวัน\", \"challenge_type\": \"login\"}','2025-08-17 09:17:26','2025-08-17 09:17:26'),('0198b8df-187c-729a-826a-5ee563445749','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198b3b6-b543-73bf-ba38-88bccd546ff7',5,2,'{\"plant_name\": \"My Beautiful Rose Garden\", \"stage_after\": 0}','2025-08-17 09:31:25','2025-08-17 09:31:25'),('0198bcfd-cd2f-706c-ae2b-36e090108631','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29f6-73fc-ad7d-29857e01308e',100,50,'{\"completed_at\": \"2025-08-18T11:43:26.000000Z\", \"challenge_name\": \"รดน้ำสวนประจำวัน\", \"challenge_type\": \"plant_care\"}','2025-08-18 04:43:26','2025-08-18 04:43:26'),('0198bcfd-dc78-7241-b594-cc1ebaf6d63d','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29f7-70db-91c8-fdfa3b576cec',150,75,'{\"completed_at\": \"2025-08-18T11:43:30.000000Z\", \"challenge_name\": \"นักเรียนขยัน\", \"challenge_type\": \"course_complete\"}','2025-08-18 04:43:30','2025-08-18 04:43:30'),('0198bcfd-eeec-713d-81d8-3da67ddab223','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-29f7-70db-91c8-fdfa3ba622e0',50,25,'{\"completed_at\": \"2025-08-18T11:43:35.000000Z\", \"challenge_name\": \"เข้าสู่ระบบประจำวัน\", \"challenge_type\": \"login\"}','2025-08-18 04:43:35','2025-08-18 04:43:35'),('0198bd13-e8dc-7235-b9ea-de16da5fb507','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','plant','plant','0198bd13-e8d9-70de-86e0-b8911bdab3c0',10,0,'{\"cost\": 50, \"category\": \"nutrition\", \"plant_name\": \"ต้นแอปเปิ้ล\", \"plant_type\": \"ต้นแอปเปิ้ล\"}','2025-08-18 05:07:35','2025-08-18 05:07:35'),('0198bd13-fca2-7193-8b7a-0b0773813b19','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','plant','plant','0198bd13-fc9f-709c-9ee0-8a2ba25a84d7',10,0,'{\"cost\": 50, \"category\": \"mental\", \"plant_name\": \"ลาเวนเดอร์\", \"plant_type\": \"ลาเวนเดอร์\"}','2025-08-18 05:07:40','2025-08-18 05:07:40'),('0198bd14-0a81-7365-bc24-deca48cef21f','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','plant','plant','0198bd14-0a7f-726e-9328-c481a6ec7eb8',10,0,'{\"cost\": 50, \"category\": \"fitness\", \"plant_name\": \"กุหลาบ\", \"plant_type\": \"กุหลาบ\"}','2025-08-18 05:07:44','2025-08-18 05:07:44'),('0198bd14-1527-7326-b335-c945ad38b6a1','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','plant','plant','0198bd14-1525-708b-900b-60c0759e05fd',10,0,'{\"cost\": 50, \"category\": \"mental\", \"plant_name\": \"ลาเวนเดอร์\", \"plant_type\": \"ลาเวนเดอร์\"}','2025-08-18 05:07:46','2025-08-18 05:07:46'),('0198cbc4-631c-71df-aa66-2af4bda8d5aa','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198bd14-1525-708b-900b-60c0759e05fd',5,2,'{\"plant_name\": \"ลาเวนเดอร์\", \"stage_after\": 0}','2025-08-21 01:35:02','2025-08-21 01:35:02'),('0198cbc4-66d6-7323-aa8c-c681eb4a9d1c','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198bd14-0a7f-726e-9328-c481a6ec7eb8',5,2,'{\"plant_name\": \"กุหลาบ\", \"stage_after\": 0}','2025-08-21 01:35:02','2025-08-21 01:35:02'),('0198cbc4-6abd-7095-8626-815268d371f9','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198bd13-fc9f-709c-9ee0-8a2ba25a84d7',5,2,'{\"plant_name\": \"ลาเวนเดอร์\", \"stage_after\": 0}','2025-08-21 01:35:03','2025-08-21 01:35:03'),('0198cbc4-6dad-7137-b313-ad74ed3daa2f','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198bd13-e8d9-70de-86e0-b8911bdab3c0',5,2,'{\"plant_name\": \"ต้นแอปเปิ้ล\", \"stage_after\": 0}','2025-08-21 01:35:04','2025-08-21 01:35:04'),('0198cbc4-706b-7120-91b3-bbf83a8d5c75','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','grow','plant','0198b3b6-b543-73bf-ba38-88bccd546ff7',25,10,'{\"new_stage\": 1, \"old_stage\": 0, \"plant_name\": \"My Beautiful Rose Garden\", \"stage_name\": \"ใบอ่อน\"}','2025-08-21 01:35:05','2025-08-21 01:35:05'),('0198cbc4-706c-724e-a83c-25976f44fff8','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198b3b6-b543-73bf-ba38-88bccd546ff7',5,2,'{\"plant_name\": \"My Beautiful Rose Garden\", \"stage_after\": 1}','2025-08-21 01:35:05','2025-08-21 01:35:05'),('0198cbc4-74e6-70a7-bb6e-3915f12afdb8','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','grow','plant','0198b39a-9866-724b-90b0-4c1a309cae41',25,10,'{\"new_stage\": 1, \"old_stage\": 0, \"plant_name\": \"My First Rose\", \"stage_name\": \"ใบอ่อน\"}','2025-08-21 01:35:06','2025-08-21 01:35:06'),('0198cbc4-74e7-7017-995e-8acb4d84daa0','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','water','plant','0198b39a-9866-724b-90b0-4c1a309cae41',5,2,'{\"plant_name\": \"My First Rose\", \"stage_after\": 1}','2025-08-21 01:35:06','2025-08-21 01:35:06'),('0198cbc6-84a4-7301-bbce-ff034ba7c76b','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-2a06-727e-b772-a3b470bd4f80',100,50,'{\"completed_at\": \"2025-08-21T08:37:21.000000Z\", \"challenge_name\": \"รดน้ำสวนประจำวัน\", \"challenge_type\": \"plant_care\"}','2025-08-21 01:37:21','2025-08-21 01:37:21'),('0198cbc6-b21c-719c-9ea8-06d01612599e','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-2a07-7396-bf2a-87084610c123',150,75,'{\"completed_at\": \"2025-08-21T08:37:33.000000Z\", \"challenge_name\": \"นักเรียนขยัน\", \"challenge_type\": \"course_complete\"}','2025-08-21 01:37:33','2025-08-21 01:37:33'),('0198cbc6-b43f-72e6-bd19-44c9705d3d52','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','challenge_complete','challenge','0198b397-2a08-70f6-90df-840f027aac1d',50,25,'{\"completed_at\": \"2025-08-21T08:37:33.000000Z\", \"challenge_name\": \"เข้าสู่ระบบประจำวัน\", \"challenge_type\": \"login\"}','2025-08-21 01:37:33','2025-08-21 01:37:33');
/*!40000 ALTER TABLE `garden_activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `garden_friends`
--

DROP TABLE IF EXISTS `garden_friends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `garden_friends` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `friend_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','accepted','blocked') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `requested_at` timestamp NOT NULL,
  `accepted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `garden_friends_user_id_friend_id_unique` (`user_id`,`friend_id`),
  KEY `garden_friends_friend_id_foreign` (`friend_id`),
  KEY `garden_friends_user_id_status_index` (`user_id`,`status`),
  CONSTRAINT `garden_friends_friend_id_foreign` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `garden_friends_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `garden_friends`
--

LOCK TABLES `garden_friends` WRITE;
/*!40000 ALTER TABLE `garden_friends` DISABLE KEYS */;
/*!40000 ALTER TABLE `garden_friends` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
INSERT INTO `jobs` VALUES (7,'default','{\"uuid\":\"7cfb8ae7-5ccb-44fe-b8b6-d8ec22c9c88d\",\"displayName\":\"App\\\\Listeners\\\\AwardGardenRewardsForLesson\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Events\\\\CallQueuedListener\",\"command\":\"O:36:\\\"Illuminate\\\\Events\\\\CallQueuedListener\\\":20:{s:5:\\\"class\\\";s:41:\\\"App\\\\Listeners\\\\AwardGardenRewardsForLesson\\\";s:6:\\\"method\\\";s:6:\\\"handle\\\";s:4:\\\"data\\\";a:1:{i:0;O:26:\\\"App\\\\Events\\\\LessonCompleted\\\":3:{s:4:\\\"user\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";s:36:\\\"0198acf4-a689-73d9-9a9d-3cda38eb7382\\\";s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:6:\\\"lesson\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:17:\\\"App\\\\Models\\\\Lesson\\\";s:2:\\\"id\\\";s:36:\\\"0198b255-70b6-70e0-b85e-8815faa3cb7e\\\";s:9:\\\"relations\\\";a:1:{i:0;s:6:\\\"course\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:14:\\\"lessonProgress\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:25:\\\"App\\\\Models\\\\LessonProgress\\\";s:2:\\\"id\\\";s:36:\\\"0198b3c9-4ad5-7364-8632-af139eeab6c2\\\";s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}}}s:5:\\\"tries\\\";N;s:13:\\\"maxExceptions\\\";N;s:7:\\\"backoff\\\";N;s:10:\\\"retryUntil\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"failOnTimeout\\\";b:0;s:17:\\\"shouldBeEncrypted\\\";b:0;s:3:\\\"job\\\";N;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\"},\"createdAt\":1755362970,\"delay\":null}',0,NULL,1755362970,1755362970),(8,'default','{\"uuid\":\"598100d0-ff89-4ad3-a858-22f0574b8803\",\"displayName\":\"App\\\\Listeners\\\\AwardGardenRewardsForLesson\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Events\\\\CallQueuedListener\",\"command\":\"O:36:\\\"Illuminate\\\\Events\\\\CallQueuedListener\\\":20:{s:5:\\\"class\\\";s:41:\\\"App\\\\Listeners\\\\AwardGardenRewardsForLesson\\\";s:6:\\\"method\\\";s:6:\\\"handle\\\";s:4:\\\"data\\\";a:1:{i:0;O:26:\\\"App\\\\Events\\\\LessonCompleted\\\":3:{s:4:\\\"user\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:15:\\\"App\\\\Models\\\\User\\\";s:2:\\\"id\\\";s:36:\\\"0198acf4-a689-73d9-9a9d-3cda38eb7382\\\";s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:6:\\\"lesson\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:17:\\\"App\\\\Models\\\\Lesson\\\";s:2:\\\"id\\\";s:36:\\\"0198b255-70b6-70e0-b85e-8815faa3cb7e\\\";s:9:\\\"relations\\\";a:1:{i:0;s:6:\\\"course\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:14:\\\"lessonProgress\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:25:\\\"App\\\\Models\\\\LessonProgress\\\";s:2:\\\"id\\\";s:36:\\\"0198b3c9-4ad5-7364-8632-af139eeab6c2\\\";s:9:\\\"relations\\\";a:0:{}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}}}s:5:\\\"tries\\\";N;s:13:\\\"maxExceptions\\\";N;s:7:\\\"backoff\\\";N;s:10:\\\"retryUntil\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"failOnTimeout\\\";b:0;s:17:\\\"shouldBeEncrypted\\\";b:0;s:3:\\\"job\\\";N;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\"},\"createdAt\":1755362970,\"delay\":null}',0,NULL,1755362970,1755362970);
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lesson_progress`
--

DROP TABLE IF EXISTS `lesson_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lesson_progress` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lesson_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enrollment_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT '0',
  `completed_at` timestamp NULL DEFAULT NULL,
  `watch_time` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lesson_progress_user_id_lesson_id_unique` (`user_id`,`lesson_id`),
  KEY `lesson_progress_lesson_id_foreign` (`lesson_id`),
  KEY `lesson_progress_enrollment_id_foreign` (`enrollment_id`),
  CONSTRAINT `lesson_progress_enrollment_id_foreign` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lesson_progress_lesson_id_foreign` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lesson_progress_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lesson_progress`
--

LOCK TABLES `lesson_progress` WRITE;
/*!40000 ALTER TABLE `lesson_progress` DISABLE KEYS */;
INSERT INTO `lesson_progress` VALUES ('0198b3c9-4ad5-7364-8632-af139eeab6c2','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b255-70b6-70e0-b85e-8815faa3cb7e','0198b3c9-4abd-72fb-a306-e9db1a1db837',1,'2025-08-16 09:49:30',10,'2025-08-16 09:49:30','2025-08-16 09:49:30'),('0198b3ca-2e19-7067-8f6f-b5c522ffb80b','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b25a-0787-739c-aa62-2841ee3b84dd','0198b3c9-4abd-72fb-a306-e9db1a1db837',1,'2025-08-16 09:50:28',5,'2025-08-16 09:50:28','2025-08-16 09:50:28'),('0198b3ca-efa7-731b-97ca-54c98641118a','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b25b-ccc3-71a2-b7be-b8693edd86a3','0198b3c9-4abd-72fb-a306-e9db1a1db837',1,'2025-08-16 09:51:18',5,'2025-08-16 09:51:18','2025-08-16 09:51:18'),('0198b3ca-efff-7118-bb85-1b68cc4a4b28','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b25c-2920-7080-895d-05359419ee2b','0198b3c9-4abd-72fb-a306-e9db1a1db837',1,'2025-08-16 09:51:18',4,'2025-08-16 09:51:18','2025-08-16 09:51:18');
/*!40000 ALTER TABLE `lesson_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lessons`
--

DROP TABLE IF EXISTS `lessons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lessons` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `duration_minutes` int NOT NULL DEFAULT '0',
  `order_index` int NOT NULL DEFAULT '0',
  `is_free` tinyint(1) NOT NULL DEFAULT '0',
  `content` text COLLATE utf8mb4_unicode_ci,
  `video_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order` int NOT NULL DEFAULT '0',
  `duration` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lessons_course_id_foreign` (`course_id`),
  CONSTRAINT `lessons_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lessons`
--

LOCK TABLES `lessons` WRITE;
/*!40000 ALTER TABLE `lessons` DISABLE KEYS */;
INSERT INTO `lessons` VALUES ('0198b255-70b6-70e0-b85e-8815faa3cb7e','0198b253-9405-705d-bd25-8a0a5b787401','โยคะ','บทเรียนฟรีสำหรับทดลองดู - รู้จักกับโยคะพื้นฐาน',10,1,1,NULL,NULL,0,0,'2025-08-16 03:03:20','2025-08-16 04:20:24'),('0198b25a-0787-739c-aa62-2841ee3b84dd','0198b253-9405-705d-bd25-8a0a5b787401','โยคะ',NULL,5,2,0,NULL,NULL,0,0,'2025-08-16 03:08:21','2025-08-16 03:08:21'),('0198b25b-ccc3-71a2-b7be-b8693edd86a3','0198b253-9405-705d-bd25-8a0a5b787401','โยคะ',NULL,5,3,0,NULL,NULL,0,0,'2025-08-16 03:10:17','2025-08-16 03:10:17'),('0198b25c-2920-7080-895d-05359419ee2b','0198b253-9405-705d-bd25-8a0a5b787401','โยคะ',NULL,4,4,0,NULL,NULL,0,0,'2025-08-16 03:10:41','2025-08-16 03:10:41');
/*!40000 ALTER TABLE `lessons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (8,'0001_01_01_000000_create_users_table',1),(9,'0001_01_01_000001_create_cache_table',1),(10,'0001_01_01_000002_create_jobs_table',1),(11,'2025_08_11_145726_add_remember_token_to_users_table',1),(12,'2025_08_15_create_proper_users_table',2),(13,'2025_08_15_create_all_tables',3),(14,'2025_08_15_add_payment_status_to_enrollments',4),(15,'2025_08_16_093924_create_videos_table',5),(16,'2025_08_16_094010_create_video_access_logs_table',5),(17,'2025_08_16_094934_add_replaced_status_to_videos_table',6),(18,'2025_08_16_095341_add_description_to_lessons_table',7),(19,'2025_08_16_095635_add_duration_minutes_to_lessons_table',8),(20,'2025_08_16_095801_add_order_index_to_lessons_table',9),(21,'2025_08_16_095900_add_is_free_to_lessons_table',10),(22,'2025_08_16_153832_create_wellness_garden_tables',11),(23,'2025_08_17_161224_add_last_visited_at_to_user_gardens_table',12);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plant_types`
--

DROP TABLE IF EXISTS `plant_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plant_types` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rarity` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'common',
  `growth_stages` json NOT NULL,
  `care_requirements` json NOT NULL,
  `icon_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `base_xp_reward` int NOT NULL DEFAULT '50',
  `unlock_level` int NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `plant_types_category_rarity_index` (`category`,`rarity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plant_types`
--

LOCK TABLES `plant_types` WRITE;
/*!40000 ALTER TABLE `plant_types` DISABLE KEYS */;
INSERT INTO `plant_types` VALUES ('0198b397-28d4-712c-b6df-ea917315d8e6','กุหลาบ','fitness','common','[{\"name\": \"เมล็ดกุหลาบ\", \"duration_hours\": 12}, {\"name\": \"ใบอ่อน\", \"duration_hours\": 48}, {\"name\": \"ต้นอ่อน\", \"duration_hours\": 168}, {\"name\": \"กิ่งแรก\", \"duration_hours\": 336}, {\"name\": \"ดอกบาน\", \"duration_hours\": 720}]','{\"special_care\": \"ต้องการการออกกำลังกายสม่ำเสมอ\", \"sunlight_hours\": 6, \"water_frequency\": \"daily\", \"fertilizer_needed\": true}','🌹','สัญลักษณ์ของความแข็งแกร่งและการออกกำลังกายหัวใจ เหมาะสำหรับผู้ที่รักการ Cardio',50,1,1,'2025-08-16 08:54:44','2025-08-16 08:54:44'),('0198b397-29a3-717e-bb49-8b163de1d94b','ทานตะวัน','fitness','common','[{\"name\": \"เมล็ดทานตะวัน\", \"duration_hours\": 8}, {\"name\": \"หน่อแรก\", \"duration_hours\": 24}, {\"name\": \"ต้นอ่อน\", \"duration_hours\": 120}, {\"name\": \"โตเต็มที่\", \"duration_hours\": 240}, {\"name\": \"ดอกบาน\", \"duration_hours\": 480}]','{\"special_care\": \"ชอบแสงแดดเยอะ\", \"sunlight_hours\": 8, \"water_frequency\": \"daily\", \"fertilizer_needed\": false}','🌻','สร้างพลังงานและความแข็งแกร่งเหมือนดวงอาทิตย์ เสริมพลังกาย',60,2,1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29a5-735c-a865-e9b3615b956c','ไผ่','fitness','rare','[{\"name\": \"หน่อไผ่\", \"duration_hours\": 6}, {\"name\": \"ต้นอ่อน\", \"duration_hours\": 24}, {\"name\": \"เจริญเติบโต\", \"duration_hours\": 72}, {\"name\": \"แกนแข็ง\", \"duration_hours\": 168}, {\"name\": \"ไผ่โต\", \"duration_hours\": 360}]','{\"special_care\": \"ต้องการการฝึกยืดหยุ่น\", \"sunlight_hours\": 4, \"water_frequency\": \"daily\", \"fertilizer_needed\": true}','🎋','สัญลักษณ์ของความยืดหยุ่นและสมดุล เสริมความแข็งแกร่งภายใน',80,5,1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29a8-7284-b08a-b03c92b1c7c1','ต้นแอปเปิ้ล','nutrition','common','[{\"name\": \"เมล็ดแอปเปิ้ล\", \"duration_hours\": 24}, {\"name\": \"ใบแรก\", \"duration_hours\": 72}, {\"name\": \"ต้นเล็ก\", \"duration_hours\": 240}, {\"name\": \"ต้นโต\", \"duration_hours\": 720}, {\"name\": \"ติดผล\", \"duration_hours\": 1440}]','{\"special_care\": \"ต้องการอาหารที่มีคุณภาพ\", \"sunlight_hours\": 6, \"water_frequency\": \"daily\", \"fertilizer_needed\": true}','🍎','ผลไม้แห่งสุขภาพที่ให้สารอาหารครบครัน บำรุงร่างกาย',70,1,1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29aa-7317-8e5b-3fded63e6ebe','สวนสมุนไพร','nutrition','rare','[{\"name\": \"เมล็ดสมุนไพร\", \"duration_hours\": 12}, {\"name\": \"หน่อเล็ก\", \"duration_hours\": 36}, {\"name\": \"ใบเริ่มออก\", \"duration_hours\": 120}, {\"name\": \"โตเต็มที่\", \"duration_hours\": 480}, {\"name\": \"สวนครบ\", \"duration_hours\": 960}]','{\"special_care\": \"ความรู้ด้านสมุนไพร\", \"sunlight_hours\": 5, \"water_frequency\": \"daily\", \"fertilizer_needed\": true}','🌿','รวมสมุนไพรไทยเพื่อสุขภาพ เสริมสร้างภูมิคุ้มกัน',90,7,1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29ac-737e-8880-99a38d2ab3d0','ลาเวนเดอร์','mental','common','[{\"name\": \"เมล็ดลาเวนเดอร์\", \"duration_hours\": 18}, {\"name\": \"หน่อใหม่\", \"duration_hours\": 48}, {\"name\": \"ใบเจริญ\", \"duration_hours\": 144}, {\"name\": \"ก่อนออกดอก\", \"duration_hours\": 360}, {\"name\": \"ดอกม่วง\", \"duration_hours\": 720}]','{\"special_care\": \"การฝึกสมาธิ\", \"sunlight_hours\": 6, \"water_frequency\": \"daily\", \"fertilizer_needed\": false}','💜','ดอกไม้แห่งความสงบ ช่วยลดความเครียดและผ่อนคลาย',55,1,1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29ae-70ab-85c1-590e462c514a','มะลิ','mental','rare','[{\"name\": \"เมล็ดมะลิ\", \"duration_hours\": 24}, {\"name\": \"ใบอ่อน\", \"duration_hours\": 72}, {\"name\": \"ต้นเล็ก\", \"duration_hours\": 216}, {\"name\": \"ก่อนบาน\", \"duration_hours\": 504}, {\"name\": \"ดอกบาน\", \"duration_hours\": 1080}]','{\"special_care\": \"บรรยากาศสงบ\", \"sunlight_hours\": 4, \"water_frequency\": \"daily\", \"fertilizer_needed\": true}','🤍','ดอกไม้แห่งความบริสุทธิ์ ช่วยทำจิตใจให้สงบและใส',85,6,1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29b1-715b-9a92-8d4510dd0fbd','ต้นโอ๊ก','learning','epic','[{\"name\": \"โอ๊กเมล็ด\", \"duration_hours\": 48}, {\"name\": \"หน่อแรก\", \"duration_hours\": 168}, {\"name\": \"ต้นเล็ก\", \"duration_hours\": 720}, {\"name\": \"ต้นใหญ่\", \"duration_hours\": 2160}, {\"name\": \"โอ๊กใหญ่\", \"duration_hours\": 4320}]','{\"special_care\": \"การเรียนรู้อย่างสม่ำเสมอ\", \"sunlight_hours\": 8, \"water_frequency\": \"daily\", \"fertilizer_needed\": true}','🌳','ต้นไม้แห่งปัญญา สัญลักษณ์ของความรู้และการเรียนรู้',120,10,1,'2025-08-16 08:54:45','2025-08-16 08:54:45'),('0198b397-29b4-7222-b494-8039969ede37','ซากุระ','learning','legendary','[{\"name\": \"เมล็ดซากุระ\", \"duration_hours\": 72}, {\"name\": \"หน่ออ่อน\", \"duration_hours\": 240}, {\"name\": \"ต้นเล็ก\", \"duration_hours\": 1080}, {\"name\": \"ก่อนบาน\", \"duration_hours\": 2880}, {\"name\": \"ดอกซากุระ\", \"duration_hours\": 7200}]','{\"special_care\": \"ความอดทนและมุ่งมั่น\", \"sunlight_hours\": 6, \"water_frequency\": \"daily\", \"fertilizer_needed\": true}','🌸','ดอกไม้แห่งการเริ่มต้นใหม่ สื่อถึงการพัฒนาตนเองอย่างต่อเนื่อง',200,20,1,'2025-08-16 08:54:45','2025-08-16 08:54:45');
/*!40000 ALTER TABLE `plant_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` int NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reviews_user_id_course_id_unique` (`user_id`,`course_id`),
  KEY `reviews_course_id_foreign` (`course_id`),
  CONSTRAINT `reviews_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_settings_key_unique` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_achievements`
--

DROP TABLE IF EXISTS `user_achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_achievements` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `achievement_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `earned_at` timestamp NOT NULL,
  `progress_data` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_achievements_user_id_achievement_id_unique` (`user_id`,`achievement_id`),
  KEY `user_achievements_achievement_id_foreign` (`achievement_id`),
  KEY `user_achievements_user_id_earned_at_index` (`user_id`,`earned_at`),
  CONSTRAINT `user_achievements_achievement_id_foreign` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_achievements_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_achievements`
--

LOCK TABLES `user_achievements` WRITE;
/*!40000 ALTER TABLE `user_achievements` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_challenge_progress`
--

DROP TABLE IF EXISTS `user_challenge_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_challenge_progress` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `challenge_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `progress` int NOT NULL DEFAULT '0',
  `target` int NOT NULL DEFAULT '1',
  `is_completed` tinyint(1) NOT NULL DEFAULT '0',
  `completed_at` timestamp NULL DEFAULT NULL,
  `progress_data` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_challenge_progress_user_id_challenge_id_unique` (`user_id`,`challenge_id`),
  KEY `user_challenge_progress_challenge_id_foreign` (`challenge_id`),
  KEY `user_challenge_progress_user_id_is_completed_index` (`user_id`,`is_completed`),
  CONSTRAINT `user_challenge_progress_challenge_id_foreign` FOREIGN KEY (`challenge_id`) REFERENCES `daily_challenges` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_challenge_progress_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_challenge_progress`
--

LOCK TABLES `user_challenge_progress` WRITE;
/*!40000 ALTER TABLE `user_challenge_progress` DISABLE KEYS */;
INSERT INTO `user_challenge_progress` VALUES ('0198b3b1-a2a0-7053-9ff8-18af3e8b75d0','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29e5-71da-bbbc-a0cc76c70f82',1,1,1,'2025-08-16 09:23:39','[]','2025-08-16 09:23:39','2025-08-16 09:23:39'),('0198b3b1-a48b-72e0-a1d5-8ca26dd74cab','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29ec-71cd-80dc-75a59ee0bd43',1,1,1,'2025-08-16 09:23:40','[]','2025-08-16 09:23:40','2025-08-16 09:23:40'),('0198b3b1-bf8c-73d8-a087-7dd112f31d6e','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29ef-700e-9cfc-7fdd4828e88a',1,1,1,'2025-08-16 09:23:47','[]','2025-08-16 09:23:47','2025-08-16 09:23:47'),('0198b8d2-2a65-7178-a46c-ee57ca84cbc0','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29f1-71a4-aa96-175321f2fb0e',1,1,1,'2025-08-17 09:17:17','[]','2025-08-17 09:17:17','2025-08-17 09:17:17'),('0198b8d2-40cf-7101-9a26-cdcc056b70dc','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29f2-7358-83c9-b35b2b892061',1,1,1,'2025-08-17 09:17:23','[]','2025-08-17 09:17:23','2025-08-17 09:17:23'),('0198b8d2-4b8c-70af-9461-e36b04d38b33','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29f4-7200-bc9d-72d554b4493b',1,1,1,'2025-08-17 09:17:26','[]','2025-08-17 09:17:26','2025-08-17 09:17:26'),('0198bcfd-cd19-72d8-a2d4-9d32487c0c87','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29f6-73fc-ad7d-29857e01308e',1,1,1,'2025-08-18 04:43:26','[]','2025-08-18 04:43:26','2025-08-18 04:43:26'),('0198bcfd-dc72-71f2-9149-55bd3e423456','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29f7-70db-91c8-fdfa3b576cec',1,1,1,'2025-08-18 04:43:30','[]','2025-08-18 04:43:30','2025-08-18 04:43:30'),('0198bcfd-eee8-70c0-8b58-56a1b3c0fd24','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-29f7-70db-91c8-fdfa3ba622e0',1,1,1,'2025-08-18 04:43:35','[]','2025-08-18 04:43:35','2025-08-18 04:43:35'),('0198cbc6-849e-7032-a372-bad9325098ba','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-2a06-727e-b772-a3b470bd4f80',1,1,1,'2025-08-21 01:37:21','[]','2025-08-21 01:37:21','2025-08-21 01:37:21'),('0198cbc6-b216-7112-97ab-66395b86dc9a','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-2a07-7396-bf2a-87084610c123',1,1,1,'2025-08-21 01:37:33','[]','2025-08-21 01:37:33','2025-08-21 01:37:33'),('0198cbc6-b43b-70c1-9828-00c446c38e0a','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-2a08-70f6-90df-840f027aac1d',1,1,1,'2025-08-21 01:37:33','[]','2025-08-21 01:37:33','2025-08-21 01:37:33');
/*!40000 ALTER TABLE `user_challenge_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_gardens`
--

DROP TABLE IF EXISTS `user_gardens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_gardens` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` int NOT NULL DEFAULT '1',
  `xp` int NOT NULL DEFAULT '0',
  `star_seeds` int NOT NULL DEFAULT '100',
  `theme` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'tropical',
  `garden_layout` json DEFAULT NULL,
  `last_watered_at` timestamp NULL DEFAULT NULL,
  `last_visited_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_gardens_user_id_level_index` (`user_id`,`level`),
  CONSTRAINT `user_gardens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_gardens`
--

LOCK TABLES `user_gardens` WRITE;
/*!40000 ALTER TABLE `user_gardens` DISABLE KEYS */;
INSERT INTO `user_gardens` VALUES ('0198b397-aae9-716e-a117-bee1299b3ad4','0198acf4-a689-73d9-9a9d-3cda38eb7382',2,-670,500,'tropical',NULL,'2025-08-16 09:29:21',NULL,'2025-08-16 08:55:18','2025-08-21 01:37:33');
/*!40000 ALTER TABLE `user_gardens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_plants`
--

DROP TABLE IF EXISTS `user_plants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_plants` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `garden_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plant_type_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `custom_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stage` int NOT NULL DEFAULT '0',
  `health` int NOT NULL DEFAULT '100',
  `growth_points` int NOT NULL DEFAULT '0',
  `position` json DEFAULT NULL,
  `planted_at` timestamp NOT NULL,
  `last_watered_at` timestamp NULL DEFAULT NULL,
  `next_water_at` timestamp NULL DEFAULT NULL,
  `harvested_at` timestamp NULL DEFAULT NULL,
  `is_fully_grown` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_plants_plant_type_id_foreign` (`plant_type_id`),
  KEY `user_plants_user_id_stage_index` (`user_id`,`stage`),
  KEY `user_plants_garden_id_is_fully_grown_index` (`garden_id`,`is_fully_grown`),
  CONSTRAINT `user_plants_garden_id_foreign` FOREIGN KEY (`garden_id`) REFERENCES `user_gardens` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_plants_plant_type_id_foreign` FOREIGN KEY (`plant_type_id`) REFERENCES `plant_types` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_plants_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_plants`
--

LOCK TABLES `user_plants` WRITE;
/*!40000 ALTER TABLE `user_plants` DISABLE KEYS */;
INSERT INTO `user_plants` VALUES ('0198b39a-9866-724b-90b0-4c1a309cae41','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','0198b397-28d4-712c-b6df-ea917315d8e6','My First Rose',1,100,0,NULL,'2025-08-16 08:58:29','2025-08-21 01:35:06','2025-08-22 01:35:06',NULL,0,'2025-08-16 08:58:29','2025-08-21 01:35:06'),('0198b3b6-b543-73bf-ba38-88bccd546ff7','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','0198b397-28d4-712c-b6df-ea917315d8e6','My Beautiful Rose Garden',1,100,0,NULL,'2025-08-16 09:29:12','2025-08-21 01:35:05','2025-08-22 01:35:05',NULL,0,'2025-08-16 09:29:12','2025-08-21 01:35:05'),('0198bd13-e8d9-70de-86e0-b8911bdab3c0','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','0198b397-29a8-7284-b08a-b03c92b1c7c1',NULL,0,100,10,NULL,'2025-08-18 05:07:35','2025-08-21 01:35:04','2025-08-22 01:35:04',NULL,0,'2025-08-18 05:07:35','2025-08-21 01:35:04'),('0198bd13-fc9f-709c-9ee0-8a2ba25a84d7','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','0198b397-29ac-737e-8880-99a38d2ab3d0',NULL,0,100,10,NULL,'2025-08-18 05:07:40','2025-08-21 01:35:03','2025-08-22 01:35:03',NULL,0,'2025-08-18 05:07:40','2025-08-21 01:35:03'),('0198bd14-0a7f-726e-9328-c481a6ec7eb8','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','0198b397-28d4-712c-b6df-ea917315d8e6',NULL,0,100,10,NULL,'2025-08-18 05:07:43','2025-08-21 01:35:02','2025-08-22 01:35:02',NULL,0,'2025-08-18 05:07:43','2025-08-21 01:35:02'),('0198bd14-1525-708b-900b-60c0759e05fd','0198acf4-a689-73d9-9a9d-3cda38eb7382','0198b397-aae9-716e-a117-bee1299b3ad4','0198b397-29ac-737e-8880-99a38d2ab3d0',NULL,0,100,10,NULL,'2025-08-18 05:07:46','2025-08-21 01:35:02','2025-08-22 01:35:02',NULL,0,'2025-08-18 05:07:46','2025-08-21 01:35:02');
/*!40000 ALTER TABLE `user_plants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('admin','instructor','student') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student',
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('0198acf4-a689-73d9-9a9d-3cda38eb7382','admin@example.com','$2y$12$n6EtEzpqSbVxqfmwTHiZI.KY/Tg9HG0WHNo6cROSLoH7RKM7N7iCO','Admin User',NULL,'admin',1,'+66 1423 9994','K8Qutcone9Y30x5Dfk0r2wPjNkvxPFoXcYGN2HGy7XYFhGWU0r2eth6fZyKF','2025-08-15 01:59:31','2025-08-15 01:59:31'),('0198acf4-a68d-7121-bc12-e497fe3dd560','test@example.com','$2y$12$n6EtEzpqSbVxqfmwTHiZI.KY/Tg9HG0WHNo6cROSLoH7RKM7N7iCO','Test User',NULL,'student',1,'085983078','K1Q9DihoLT','2025-08-15 01:59:31','2025-08-15 01:59:31'),('0198b397-9773-72ba-bd24-fae4088ca8ab','demo@garden.com','$2y$12$0U5se1xQ946P8yc9PCJKa.vFvDCWKqsNAO4LcUuYnd5AYxt6nDWRe','Demo Garden User',NULL,'student',1,NULL,NULL,'2025-08-16 08:55:13','2025-08-16 08:55:13');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `video_access_logs`
--

DROP TABLE IF EXISTS `video_access_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `video_access_logs` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `device_fingerprint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `started_at` timestamp NOT NULL,
  `ended_at` timestamp NULL DEFAULT NULL,
  `watch_duration` int NOT NULL DEFAULT '0',
  `seek_count` int NOT NULL DEFAULT '0',
  `speed_changes` int NOT NULL DEFAULT '0',
  `suspicious_activity` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `video_access_logs_video_id_foreign` (`video_id`),
  KEY `video_access_logs_user_id_video_id_index` (`user_id`,`video_id`),
  KEY `video_access_logs_device_fingerprint_index` (`device_fingerprint`),
  KEY `video_access_logs_ip_address_index` (`ip_address`),
  CONSTRAINT `video_access_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `video_access_logs_video_id_foreign` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_access_logs`
--

LOCK TABLES `video_access_logs` WRITE;
/*!40000 ALTER TABLE `video_access_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `video_access_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videos`
--

DROP TABLE IF EXISTS `videos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `videos` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lesson_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `original_filename` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hls_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `encryption_key` text COLLATE utf8mb4_unicode_ci,
  `duration_seconds` int DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `mime_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','processing','ready','failed','replaced') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `processing_error` text COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `videos_status_index` (`status`),
  KEY `videos_lesson_id_index` (`lesson_id`),
  CONSTRAINT `videos_lesson_id_foreign` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videos`
--

LOCK TABLES `videos` WRITE;
/*!40000 ALTER TABLE `videos` DISABLE KEYS */;
INSERT INTO `videos` VALUES ('0198b29e-db4f-7180-9eb0-20d51f5136f5','โยคะ - Video (gi.gi_1989_1754151920_1835449457.mp4)','0198b255-70b6-70e0-b85e-8815faa3cb7e','gi.gi_1989_1754151920_1835449457.mp4','temp-videos/gi.gi_1989_1754151920_1835449457.mp4','videos/0198b29e-db4f-7180-9eb0-20d51f5136f5/gi.gi_1989_1754151920_1835449457.mp4',NULL,0,636803,'video/mp4','ready','Video file not found: /Users/panapat/khun_bebe/fitness-lms-admin/storage/app/private/private/temp-videos/gi.gi_1989_1754151920_1835449457.mp4','{\"processed_at\": \"2025-08-16T11:24:35.437279Z\", \"ffmpeg_available\": false, \"processing_method\": \"direct_copy\"}','2025-08-16 04:23:32','2025-08-16 04:24:35'),('0198b29e-dbfe-716b-907e-b76c09aa9c02','โยคะ - Video (kkawxin_1754917194_3696835105864523954_4554574300.mp4)','0198b255-70b6-70e0-b85e-8815faa3cb7e','kkawxin_1754917194_3696835105864523954_4554574300.mp4','temp-videos/kkawxin_1754917194_3696835105864523954_4554574300.mp4','videos/0198b29e-dbfe-716b-907e-b76c09aa9c02/kkawxin_1754917194_3696835105864523954_4554574300.mp4',NULL,0,797134,'video/mp4','ready','Video file not found: /Users/panapat/khun_bebe/fitness-lms-admin/storage/app/private/private/temp-videos/kkawxin_1754917194_3696835105864523954_4554574300.mp4','{\"processed_at\": \"2025-08-16T11:24:43.415246Z\", \"ffmpeg_available\": false, \"processing_method\": \"direct_copy\"}','2025-08-16 04:23:32','2025-08-16 04:24:43');
/*!40000 ALTER TABLE `videos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-22 14:23:01
