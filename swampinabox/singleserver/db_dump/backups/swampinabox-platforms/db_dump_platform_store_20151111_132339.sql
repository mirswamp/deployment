-- MySQL dump 10.13  Distrib 5.6.27, for Linux (x86_64)
--
-- Host: swa-csaper-dt-01    Database: platform_store
-- ------------------------------------------------------
-- Server version	5.5.40-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `platform_store`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `platform_store` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `platform_store`;

--
-- Table structure for table `platform`
--

DROP TABLE IF EXISTS `platform`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `platform` (
  `platform_uuid` varchar(45) NOT NULL COMMENT 'platform uuid',
  `platform_owner_uuid` varchar(45) DEFAULT NULL COMMENT 'platform owner uuid',
  `name` varchar(100) NOT NULL COMMENT 'Platform name',
  `description` varchar(500) DEFAULT NULL COMMENT 'description',
  `platform_sharing_status` varchar(25) NOT NULL DEFAULT 'PRIVATE' COMMENT 'private, shared, public or retired',
  `create_user` varchar(25) DEFAULT NULL COMMENT 'db user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(25) DEFAULT NULL COMMENT 'db user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last updated',
  PRIMARY KEY (`platform_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='contains all platforms';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform`
--

LOCK TABLES `platform` WRITE;
/*!40000 ALTER TABLE `platform` DISABLE KEYS */;
INSERT INTO `platform` VALUES ('1088c3ce-20aa-11e3-9a3e-001a4a81450b',NULL,'Ubuntu Linux',NULL,'PUBLIC',NULL,'2014-02-01 23:37:56',NULL,NULL),('48f9a9b0-976f-11e4-829b-001a4a81450b',NULL,'Android',NULL,'PUBLIC','pschell@pschell.mirsam.or','2015-01-08 19:53:41',NULL,NULL),('8a51ecea-209d-11e3-9a3e-001a4a81450b',NULL,'Fedora Linux',NULL,'PUBLIC',NULL,'2014-02-01 23:37:56',NULL,NULL),('a4f024eb-f317-11e3-8775-001a4a81450b',NULL,'Scientific Linux 32-bit',NULL,'PUBLIC','pschell@pschell.mirsam.or','2014-06-13 16:38:10',NULL,NULL),('d531f0f0-f273-11e3-8775-001a4a81450b',NULL,'Red Hat Enterprise Linux 32-bit',NULL,'PUBLIC','pschell@pschell.mirsam.or','2014-06-13 16:30:13',NULL,NULL),('d95fcb5f-209d-11e3-9a3e-001a4a81450b',NULL,'Scientific Linux 64-bit',NULL,'PUBLIC',NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-06-13 16:38:12'),('ee2c1193-209b-11e3-9a3e-001a4a81450b',NULL,'Debian Linux',NULL,'PUBLIC',NULL,'2014-02-01 23:37:56',NULL,NULL),('fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'Red Hat Enterprise Linux 64-bit',NULL,'PUBLIC',NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-06-13 16:30:17');
/*!40000 ALTER TABLE `platform` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_owner_history`
--

DROP TABLE IF EXISTS `platform_owner_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `platform_owner_history` (
  `platform_owner_history_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'internal id',
  `platform_uuid` varchar(45) NOT NULL COMMENT 'platform uuid',
  `old_platform_owner_uuid` varchar(45) DEFAULT NULL COMMENT 'platform owner uuid',
  `new_platform_owner_uuid` varchar(45) DEFAULT NULL COMMENT 'platform owner uuid',
  `change_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record changed',
  PRIMARY KEY (`platform_owner_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='platform owner history';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_owner_history`
--

LOCK TABLES `platform_owner_history` WRITE;
/*!40000 ALTER TABLE `platform_owner_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `platform_owner_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_sharing`
--

DROP TABLE IF EXISTS `platform_sharing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `platform_sharing` (
  `platform_sharing_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'internal id',
  `platform_uuid` varchar(45) NOT NULL COMMENT 'platform uuid',
  `project_uuid` varchar(45) DEFAULT NULL COMMENT 'project uuid',
  PRIMARY KEY (`platform_sharing_id`),
  UNIQUE KEY `platform_sharing_uc` (`platform_uuid`,`project_uuid`),
  CONSTRAINT `fk_platform_sharing` FOREIGN KEY (`platform_uuid`) REFERENCES `platform` (`platform_uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='contains platforms shared with specific projects';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_sharing`
--

LOCK TABLES `platform_sharing` WRITE;
/*!40000 ALTER TABLE `platform_sharing` DISABLE KEYS */;
/*!40000 ALTER TABLE `platform_sharing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_version`
--

DROP TABLE IF EXISTS `platform_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `platform_version` (
  `platform_version_uuid` varchar(45) NOT NULL COMMENT 'version uuid',
  `platform_uuid` varchar(45) NOT NULL COMMENT 'each version belongs to a platform; links to platform',
  `version_no` int(11) DEFAULT NULL COMMENT 'incremental integer version number',
  `version_string` varchar(100) DEFAULT NULL COMMENT 'eg version 5.0 stable release for Windows 7 64-bit',
  `release_date` timestamp NULL DEFAULT NULL COMMENT 'date version is released',
  `retire_date` timestamp NULL DEFAULT NULL COMMENT 'date version is retired',
  `comment_public` varchar(200) DEFAULT NULL COMMENT 'Comment visible to users.',
  `comment_private` varchar(200) DEFAULT NULL COMMENT 'comment for platform owner and admins only',
  `platform_path` varchar(200) DEFAULT NULL COMMENT 'cannonical path of platform',
  `checksum` varchar(200) DEFAULT NULL COMMENT 'checksum of platform',
  `invocation_cmd` varchar(200) DEFAULT NULL COMMENT 'command to invoke platform',
  `deployment_cmd` varchar(200) DEFAULT NULL COMMENT 'command to deploy platform',
  `create_user` varchar(25) DEFAULT NULL COMMENT 'user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(25) DEFAULT NULL COMMENT 'user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last changed',
  PRIMARY KEY (`platform_version_uuid`),
  KEY `fk_version_platform` (`platform_uuid`),
  CONSTRAINT `fk_version_platform` FOREIGN KEY (`platform_uuid`) REFERENCES `platform` (`platform_uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Platform can have many versions';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_version`
--

LOCK TABLES `platform_version` WRITE;
/*!40000 ALTER TABLE `platform_version` DISABLE KEYS */;
INSERT INTO `platform_version` VALUES ('00f3ff35-209c-11e3-9a3e-001a4a81450b','ee2c1193-209b-11e3-9a3e-001a4a81450b',1,'7.0 64-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'debian-7.0-64',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-02-02 01:11:42'),('051f9447-209e-11e3-9a3e-001a4a81450b','d531f0f0-f273-11e3-8775-001a4a81450b',1,'RHEL6.4 32-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'rhel-6.4-32',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-06-13 16:30:19'),('18f66e9a-20aa-11e3-9a3e-001a4a81450b','1088c3ce-20aa-11e3-9a3e-001a4a81450b',1,'12.04 LTS Lucid Lynx 64-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'ubuntu-12.04-64',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-02-02 01:11:42'),('27f0588b-209e-11e3-9a3e-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b',1,'5.9 64-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'scientific-5.9-64',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-06-13 16:40:16'),('35bc77b9-7d3e-11e3-88bb-001a4a81450b','a4f024eb-f317-11e3-8775-001a4a81450b',1,'5.9 32-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'scientific-5.9-32',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-06-13 16:38:15'),('8f4878ec-976f-11e4-829b-001a4a81450b','48f9a9b0-976f-11e4-829b-001a4a81450b',1,'Android on Ubuntu 12.04 64-bit','2015-01-08 19:53:43',NULL,NULL,NULL,'android-ubuntu-12.04-64',NULL,NULL,NULL,'pschell@pschell.mirsam.or','2015-01-08 19:53:43',NULL,NULL),('a9cfe21f-209d-11e3-9a3e-001a4a81450b','8a51ecea-209d-11e3-9a3e-001a4a81450b',1,'18 64-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'fedora-18.0-64',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-02-02 01:11:42'),('aebc38c3-209d-11e3-9a3e-001a4a81450b','8a51ecea-209d-11e3-9a3e-001a4a81450b',2,'19 64-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'fedora-19.0-64',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-02-02 01:11:42'),('e16f4023-209d-11e3-9a3e-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b',2,'6.4 64-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'scientific-6.4-64',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-06-13 16:40:16'),('fc5737ef-09d7-11e3-a239-001a4a81450b','fc55810b-09d7-11e3-a239-001a4a81450b',1,'RHEL6.4 64-bit','2014-02-01 23:37:56',NULL,NULL,NULL,'rhel-6.4-64',NULL,NULL,NULL,NULL,'2014-02-01 23:37:56','pschell@pschell.mirsam.or','2014-06-13 16:34:04');
/*!40000 ALTER TABLE `platform_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'platform_store'
--
/*!50003 DROP PROCEDURE IF EXISTS `select_all_pub_platforms_and_vers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `select_all_pub_platforms_and_vers`()
BEGIN
        select platform.platform_uuid,
               platform_version.platform_version_uuid,
               platform.name as platform_name,
               platform.platform_sharing_status,
               platform_version.version_string,
               platform_version.comment_public as public_version_comment,
               platform_version.comment_private as private_version_comment,
               platform_version.platform_path,
               platform_version.checksum,
               platform_version.invocation_cmd,
               platform_version.deployment_cmd
          from platform
         inner join platform_version on platform.platform_uuid = platform_version.platform_uuid
         where platform.platform_sharing_status = 'PUBLIC'
           and platform_version.release_date is not null;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `select_platform_version` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `select_platform_version`(
        IN platform_version_uuid_in VARCHAR(45)
    )
BEGIN
        select platform.platform_uuid,
               platform_version.platform_version_uuid,
               platform.name as platform_name,
               platform.platform_sharing_status,
               platform_version.version_string,
               platform_version.comment_public as public_version_comment,
               platform_version.comment_private as private_version_comment,
               platform_version.platform_path,
               platform_version.checksum,
               platform_version.invocation_cmd,
               platform_version.deployment_cmd
          from platform
         inner join platform_version on platform.platform_uuid = platform_version.platform_uuid
         where platform_version.platform_version_uuid = platform_version_uuid_in;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-11-11 13:23:39
