-- MySQL dump 10.14  Distrib 5.5.46-MariaDB, for Linux (x86_64)
--
-- Host: swa-csaper-dt-01    Database: tool_shed
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

USE `tool_shed`;

--
-- Table structure for table `tool_language`
--

DROP TABLE IF EXISTS `tool_language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tool_language` (
  `tool_language_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'internal id',
  `tool_uuid` varchar(45) DEFAULT NULL COMMENT 'tool uuid',
  `tool_version_uuid` varchar(45) DEFAULT NULL COMMENT 'version uuid',
  `package_type_id` int(11) DEFAULT NULL COMMENT 'references package_store.package_type',
  `create_user` varchar(50) DEFAULT NULL COMMENT 'db user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(50) DEFAULT NULL COMMENT 'db user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last updated',
  PRIMARY KEY (`tool_language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=latin1 COMMENT='Lists languages that each tool is capable of assessing';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tool_language`
--

LOCK TABLES `tool_language` WRITE;
/*!40000 ALTER TABLE `tool_language` DISABLE KEYS */;
INSERT INTO `tool_language` VALUES (19,'163d56a7-156e-11e3-a239-001a4a81450b','163fe1e7-156e-11e3-a239-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10'),(20,'163d56a7-156e-11e3-a239-001a4a81450b','4c1ec754-cb53-11e3-8775-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10'),(21,'163d56a7-156e-11e3-a239-001a4a81450b','163fe1e7-156e-11e3-a239-001a4a81450b',3,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10'),(22,'163d56a7-156e-11e3-a239-001a4a81450b','4c1ec754-cb53-11e3-8775-001a4a81450b',3,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10'),(23,'7A08B82D-3A3B-45CA-8644-105088741AF6','325CA868-0D19-4B00-B034-3786887541AA',1,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10'),(24,'163f2b01-156e-11e3-a239-001a4a81450b','16414980-156e-11e3-a239-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10'),(25,'163f2b01-156e-11e3-a239-001a4a81450b','a2d949ef-cb53-11e3-8775-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10'),(26,'992A48A5-62EC-4EE9-8429-45BB94275A41','09449DE5-8E63-44EA-8396-23C64525D57C',2,'root@localhost','2014-05-15 06:22:40','pschell@pschell.mirsam.org','2014-05-19 19:33:31'),(27,'56872C2E-1D78-4DB0-B976-83ACF5424C52','5230FE76-E658-4B3A-AD40-7D55F7A21955',2,'root@localhost','2014-05-15 06:22:40',NULL,NULL),(30,'f212557c-3050-11e3-9a3e-001a4a81450b','8ec206ff-f59b-11e3-8775-001a4a81450b',1,'pschell@pschell.mirsam.org','2014-06-23 11:46:41',NULL,NULL),(31,'163e5d8c-156e-11e3-a239-001a4a81450b','950734d0-f59b-11e3-8775-001a4a81450b',1,'pschell@pschell.mirsam.org','2014-06-23 11:46:41',NULL,NULL),(36,'0f668fb0-4421-11e4-a4f3-001a4a81450b','142e9a79-4425-11e4-a4f3-001a4a81450b',4,'root@localhost','2014-09-29 19:57:20',NULL,NULL),(38,'0f668fb0-4421-11e4-a4f3-001a4a81450b','142e9a79-4425-11e4-a4f3-001a4a81450b',5,'pschell@pschell.mirsam.org','2014-09-29 20:40:43',NULL,NULL),(41,'4bb2644d-6440-11e4-a282-001a4a81450b','0b384dc1-6441-11e4-a282-001a4a81450b',1,'pschell@pschell.mirsam.org','2014-11-14 15:28:25',NULL,NULL),(42,'6197a593-6440-11e4-a282-001a4a81450b','18532f08-6441-11e4-a282-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-11-14 15:28:25',NULL,NULL),(44,'7fbfa454-8f9f-11e4-829b-001a4a81450b','9cbd0e60-8f9f-11e4-829b-001a4a81450b',4,'pschell@pschell.mirsam.org','2014-12-29 21:54:29',NULL,NULL),(45,'163d56a7-156e-11e3-a239-001a4a81450b','163fe1e7-156e-11e3-a239-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL),(46,'163d56a7-156e-11e3-a239-001a4a81450b','4c1ec754-cb53-11e3-8775-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL),(47,'163f2b01-156e-11e3-a239-001a4a81450b','16414980-156e-11e3-a239-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL),(48,'163f2b01-156e-11e3-a239-001a4a81450b','a2d949ef-cb53-11e3-8775-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL),(49,'992A48A5-62EC-4EE9-8429-45BB94275A41','09449DE5-8E63-44EA-8396-23C64525D57C',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL),(50,'56872C2E-1D78-4DB0-B976-83ACF5424C52','5230FE76-E658-4B3A-AD40-7D55F7A21955',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL),(51,'6197a593-6440-11e4-a282-001a4a81450b','18532f08-6441-11e4-a282-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL),(52,'63695cd8-a73e-11e4-a335-001a4a81450b','fe360cd7-a7e3-11e4-a335-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-01-30 18:23:23',NULL,NULL),(53,'63695cd8-a73e-11e4-a335-001a4a81450b','fe360cd7-a7e3-11e4-a335-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-01-30 18:23:23',NULL,NULL),(54,'992A48A5-62EC-4EE9-8429-45BB94275A41','0667d30a-a7f0-11e4-a335-001a4a81450b',2,'pschell@pschell.mirsam.org','2015-01-30 18:23:43',NULL,NULL),(55,'992A48A5-62EC-4EE9-8429-45BB94275A41','0667d30a-a7f0-11e4-a335-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-30 18:23:43',NULL,NULL),(56,'163d56a7-156e-11e3-a239-001a4a81450b','27ea7f63-a813-11e4-a335-001a4a81450b',2,'pschell@pschell.mirsam.org','2015-01-30 18:23:57',NULL,NULL),(57,'163d56a7-156e-11e3-a239-001a4a81450b','27ea7f63-a813-11e4-a335-001a4a81450b',3,'pschell@pschell.mirsam.org','2015-01-30 18:23:57',NULL,NULL),(58,'163d56a7-156e-11e3-a239-001a4a81450b','27ea7f63-a813-11e4-a335-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-30 18:23:57',NULL,NULL),(59,'163f2b01-156e-11e3-a239-001a4a81450b','bdaf4b93-a811-11e4-a335-001a4a81450b',2,'pschell@pschell.mirsam.org','2015-01-30 18:24:10',NULL,NULL),(60,'163f2b01-156e-11e3-a239-001a4a81450b','bdaf4b93-a811-11e4-a335-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-30 18:24:10',NULL,NULL),(61,'563e30f6-cdae-11e4-b6a7-001a4a81450b','83fa93bb-cdae-11e4-b6a7-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-03-18 20:40:20',NULL,NULL),(62,'563e30f6-cdae-11e4-b6a7-001a4a81450b','83fa93bb-cdae-11e4-b6a7-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-03-18 20:40:21',NULL,NULL),(63,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-06-02 16:47:24',NULL,NULL),(64,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-06-02 16:51:13',NULL,NULL),(65,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-07-01 06:58:50',NULL,NULL),(67,'5cd726a5-4053-11e5-83f1-001a4a81450b','6b06aaa6-4053-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-17 17:48:40',NULL,NULL),(68,'b9560648-4057-11e5-83f1-001a4a81450b','ca1608e1-4057-11e5-83f1-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-17 17:48:59',NULL,NULL),(69,'b9560648-4057-11e5-83f1-001a4a81450b','ca1608e1-4057-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-17 17:48:59',NULL,NULL),(70,'b9560648-4057-11e5-83f1-001a4a81450b','ca1608e1-4057-11e5-83f1-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-17 17:48:59',NULL,NULL),(71,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL),(72,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL),(73,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL),(74,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL),(75,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL),(76,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL),(77,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL),(78,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-26 17:17:04',NULL,NULL),(79,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-26 17:17:04',NULL,NULL),(80,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-26 17:17:04',NULL,NULL),(81,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL),(82,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL),(83,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL),(84,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL),(85,'0fac7ff8-4c2e-11e5-83f1-001a4a81450b','16dac397-4c2e-11e5-83f1-001a4a81450b',1,'pschell@pschell.mirsam.org','2015-08-26 20:53:11',NULL,NULL),(86,'0fac7ff8-4c2e-11e5-83f1-001a4a81450b','e6501548-1a4f-4e6b-8f01-550b2f23679e',1,'swim_dev@10.129.65.52','2015-08-26 20:59:09',NULL,NULL),(87,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-27 18:50:37',NULL,NULL),(88,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-27 18:51:14',NULL,NULL),(89,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-27 18:51:14',NULL,NULL),(91,'9289b560-8f8b-11e4-829b-001a4a81450b','dcbdab3c-4d8b-11e5-83f1-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-09-02 20:49:50',NULL,NULL),(92,'63695cd8-a73e-11e4-a335-001a4a81450b','1ad625bd-71d5-11e5-865f-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-10-13 21:25:27',NULL,NULL),(93,'63695cd8-a73e-11e4-a335-001a4a81450b','1ad625bd-71d5-11e5-865f-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-10-13 21:25:27',NULL,NULL),(94,'0f668fb0-4421-11e4-a4f3-001a4a81450b','c9126789-71d7-11e5-865f-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-10-13 21:25:49',NULL,NULL),(95,'0f668fb0-4421-11e4-a4f3-001a4a81450b','c9126789-71d7-11e5-865f-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-10-13 21:25:49',NULL,NULL),(96,'5540d2be-72b2-11e5-865f-001a4a81450b','68f4a0c7-72b2-11e5-865f-001a4a81450b',1,'pschell@pschell.mirsam.org','2015-10-14 21:03:47',NULL,NULL),(97,'7fbfa454-8f9f-11e4-829b-001a4a81450b','2a16b653-7449-11e5-865f-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-10-16 21:07:45',NULL,NULL),(98,'7fbfa454-8f9f-11e4-829b-001a4a81450b','2a16b653-7449-11e5-865f-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-10-16 21:07:45',NULL,NULL),(99,'f212557c-3050-11e3-9a3e-001a4a81450b','90554576-81a0-11e5-865f-001a4a81450b',1,'pschell@pschell.mirsam.org','2015-11-02 21:32:33',NULL,NULL),(100,'163e5d8c-156e-11e3-a239-001a4a81450b','e9cea65f-833e-11e5-865f-001a4a81450b',1,'pschell@pschell.mirsam.org','2015-11-04 22:04:44',NULL,NULL),(101,'738b81f0-a828-11e5-865f-001a4a81450b','8666e176-a828-11e5-865f-001a4a81450b',11,'pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
/*!40000 ALTER TABLE `tool_language` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'tool_shed'
--
/*!50003 DROP PROCEDURE IF EXISTS `download_tool` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `download_tool`(
    IN tool_version_uuid_in VARCHAR(45),
    OUT return_url varchar(200),
    OUT return_success_flag char(1),
    OUT return_msg varchar(100)
  )
BEGIN
    DECLARE row_count_int INT;
    DECLARE tool_path_var VARCHAR(200);

    
    select count(1)
      into row_count_int
     from tool_version
     where tool_version_uuid = tool_version_uuid_in;

    if row_count_int = 1 then
      BEGIN
        
        select tool_path
          into tool_path_var
         from tool_version
         where tool_version_uuid = tool_version_uuid_in;

        
        call assessment.download(tool_path_var, return_url, return_success_flag, return_msg);

      END;
    else set return_success_flag = 'N', return_msg = 'ERROR: RECORD NOT FOUND';
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `test` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`pschell`@`%` PROCEDURE `test`()
begin
select blah from tool;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_tool_cksum` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_tool_cksum`(
    IN tool_version_uuid_in VARCHAR(45),
    IN checksum_in VARCHAR(200),
    OUT return_string varchar(100)
)
BEGIN
    DECLARE row_count_int int;
    set return_string = 'ERROR';

    select count(1)
      into row_count_int
      from tool_version
     where tool_version_uuid = tool_version_uuid_in;

   if row_count_int > 1 then
     set return_string = 'ERROR: TOO MANY ROWS';
   elseif row_count_int = 0 then
     set return_string = 'ERROR: NO RECORD FOUND';
   elseif row_count_int = 1 then
     BEGIN
       update tool_version
          set checksum = checksum_in
        where tool_version_uuid = tool_version_uuid_in;
       commit;

       set return_string = 'SUCCESS';
     END;
   end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_tool_path` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_tool_path`(
    IN tool_version_uuid_in VARCHAR(45),
    IN path_in VARCHAR(200),
    OUT return_string varchar(100)
)
BEGIN
    DECLARE row_count_int int;
    set return_string = 'ERROR';

    select count(1)
      into row_count_int
      from tool_version
     where tool_version_uuid = tool_version_uuid_in;

   if row_count_int > 1 then
     set return_string = 'ERROR: TOO MANY ROWS';
   elseif row_count_int = 0 then
     set return_string = 'ERROR: NO RECORD FOUND';
   elseif row_count_int = 1 then
     BEGIN
       update tool_version
          set tool_path = path_in
        where tool_version_uuid = tool_version_uuid_in;
       commit;

       set return_string = 'SUCCESS';
     END;
   end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_tool_version` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_tool_version`(
    IN tool_version_uuid_in VARCHAR(45),
    IN tool_path_in VARCHAR(200),
    OUT return_status varchar(12),
    OUT return_msg varchar(100)
)
BEGIN
    DECLARE dir_name_only VARCHAR(500);
    DECLARE incoming_dir VARCHAR(500);
    DECLARE dest_dir VARCHAR(500);
    DECLARE dest_full_path VARCHAR(200);
    DECLARE cmd1 VARCHAR(500);
    DECLARE file_move_return_code INT;
    DECLARE chmod_return_code INT;
    DECLARE rm_return_code INT;
    DECLARE test_count INT;
    DECLARE cksum VARCHAR(200);

    set dir_name_only = substr(tool_path_in,1,instr(tool_path_in,'/')-1);  
    set incoming_dir = concat('/swamp/incoming/',dir_name_only);
    set dest_dir = concat('/swamp/store/SCATools/', dir_name_only);
    set dest_full_path = concat('/swamp/store/SCATools/',tool_path_in);

    
    select count(1)
      into test_count
     from tool_version
     where tool_version_uuid = tool_version_uuid_in;

    
    set cmd1 = CONCAT('cp -r ', incoming_dir, ' ', dest_dir);
    set file_move_return_code = sys_exec(cmd1);

    
    
    
    
    if (incoming_dir != '/') and (incoming_dir not like '/ %') then
      begin
        set cmd1 = null;
        set cmd1 = CONCAT('rm -rf ', incoming_dir);
        set rm_return_code = sys_exec(cmd1);
      end;
    end if;

    
    set cmd1 = null;
    set cmd1 = CONCAT('chmod -R 755 ', dest_dir);
    set chmod_return_code = sys_exec(cmd1);
    

    
    set cksum = sys_eval(concat('sha512sum ',dest_full_path));
    set cksum = substr(cksum,1,instr(cksum,' ')-1);

    if test_count != 1 then
      set return_status = 'ERROR', return_msg = 'Tool version not found';
    elseif file_move_return_code != 0 then
      set return_status = 'ERROR', return_msg = 'Error moving tool to storage';
    elseif chmod_return_code != 0 then
      set return_status = 'ERROR', return_msg = 'Error setting tool permissions';
    elseif cksum is null then
      set return_status = 'ERROR', return_msg = 'Error calculating checksum';
    else
      begin
        update tool_version
           set tool_path = dest_full_path,
               checksum = cksum
         where tool_version_uuid = tool_version_uuid_in;
        set return_status = 'SUCCESS', return_msg = 'Tool sucessfully moved to storage';
      end;
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `list_tools_by_owner` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_tools_by_owner`(
    IN user_uuid_in VARCHAR(45),
    OUT return_string varchar(100)
)
BEGIN
    DECLARE user_account_valid_flag CHAR(1);

    
    select distinct 'Y'
      into user_account_valid_flag
      from project.user_account ua
     where ua.user_uid = user_uuid_in
       and ua.enabled_flag = 1;

    if user_account_valid_flag = 'Y'
    then
      begin
        select t.tool_uuid,
               tv.tool_version_uuid,
               t.name,
               t.tool_sharing_status,
               tv.version_string,
               tv.comment_public,
               tv.comment_private,
               tv.tool_path,
               tv.checksum,
               t.is_build_needed,
               tv.tool_executable,
               tv.tool_arguments,
               tv.tool_directory,
               tv.create_date
          from tool t
         inner join tool_version tv on t.tool_uuid = tv.tool_uuid
         where t.tool_owner_uuid = user_uuid_in;
        set return_string = 'SUCCESS';
      end;
    elseif ifnull(user_account_valid_flag,'N') != 'Y' THEN set return_string = 'ERROR: USER ACCOUNT NOT VALID';
    else set return_string = 'ERROR: UNSPECIFIED ERROR';
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `list_tools_by_project_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_tools_by_project_user`(
    IN user_uuid_in VARCHAR(45),
    IN project_uuid_in VARCHAR(45),
    OUT return_string varchar(100)
)
BEGIN
    DECLARE user_account_valid_flag CHAR(1);
    DECLARE project_user_valid_flag CHAR(1);

    
    select distinct 'Y'
      into user_account_valid_flag
      from project.user_account ua
     where ua.user_uid = user_uuid_in
       and ua.enabled_flag = 1;


    
    select distinct 'Y'
      into project_user_valid_flag
      from project.project_user
     where project_uid = project_uuid_in
       and user_uid = user_uuid_in
       and delete_date is null
       and (expire_date > now() or expire_date is null);

    if user_account_valid_flag = 'Y' and project_user_valid_flag = 'Y'
    then
      begin
        select t.tool_uuid,
               tv.tool_version_uuid,
               t.name,
               t.tool_sharing_status,
               tv.version_string,
               tv.comment_public,
               tv.comment_private,
               
               
               
               
               
               
               group_concat(tl.package_type_id) as package_type_ids,
               group_concat(pt.name) as package_type_names
          from tool t
         inner join tool_version tv on t.tool_uuid = tv.tool_uuid
         left outer join tool_language tl on tv.tool_version_uuid = tl.tool_version_uuid
         left outer join package_store.package_type pt on tl.package_type_id = pt.package_type_id
         where upper(t.tool_sharing_status) = 'PUBLIC'
          or ( upper(t.tool_sharing_status) = 'PROTECTED'
               and exists (select 1 from tool_sharing ts
                            where ts.tool_uuid = t.tool_uuid and ts.project_uuid = project_uuid_in)
              )
        group by t.tool_uuid, tv.tool_version_uuid, t.name, t.tool_sharing_status, tv.version_string, tv.comment_public, tv.comment_private;
        set return_string = 'SUCCESS';
      end;
    elseif ifnull(user_account_valid_flag,'N') != 'Y' THEN set return_string = 'ERROR: USER ACCOUNT NOT VALID';
    elseif ifnull(project_user_valid_flag,'N') != 'Y' THEN set return_string = 'ERROR: USER PROJECT PERMISSION NOT VALID';
    else set return_string = 'ERROR: UNSPECIFIED ERROR';
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `select_all_pub_tools_and_vers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `select_all_pub_tools_and_vers`()
BEGIN
    select tool.tool_uuid,
           tool_version.tool_version_uuid,
           tool.name as tool_name,
           tool.tool_sharing_status,
           tool_version.version_string,
           null as platform_id,
           tool_version.comment_public as public_version_comment,
           tool_version.comment_private as private_version_comment,
           tool_version.tool_path,
           tool_version.checksum,
           tool.is_build_needed as IsBuildNeeded,
           tool_version.tool_executable,
           tool_version.tool_arguments,
           tool_version.tool_directory,
           tl.package_type_id,
           pt.name as package_type_name
      from tool
     inner join tool_version on tool.tool_uuid = tool_version.tool_uuid
     inner join tool_language tl on tool_version.tool_version_uuid = tl.tool_version_uuid
     inner join package_store.package_type pt on tl.package_type_id = pt.package_type_id
     where tool.tool_sharing_status = 'PUBLIC'
       and tool_version.release_date is not null;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `select_tool_version` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `select_tool_version`(
    IN tool_version_uuid_in VARCHAR(45),
    IN platform_version_uuid_in VARCHAR(45),
    IN package_version_uuid_in VARCHAR(45)
)
BEGIN
    DECLARE row_count_int int;
    DECLARE package_type_id_var int;

    
    select p.package_type_id
      into package_type_id_var
      from package_store.package p
     inner join package_store.package_version pv on pv.package_uuid = p.package_uuid
     where pv.package_version_uuid = package_version_uuid_in;

    
    select count(1)
      into row_count_int
      from specialized_tool_version stv
       where stv.tool_version_uuid = tool_version_uuid_in
         and (
              (stv.specialization_type = 'PLATFORM' and stv.platform_version_uuid = platform_version_uuid_in)
              or
              (stv.specialization_type = 'LANGUAGE' and stv.package_type_id = package_type_id_var)
             );

    if row_count_int = 1 then
      select t.tool_uuid,
             tv.tool_version_uuid,
             t.name as tool_name,
             t.tool_sharing_status,
             tv.version_string,
             null as platform_id,
             tv.comment_public as public_version_comment,
             tv.comment_private as private_version_comment,
             stv.tool_path,
             stv.checksum,
             t.is_build_needed as IsBuildNeeded,
             stv.tool_executable,
             stv.tool_arguments,
             stv.tool_directory
        from tool t
       inner join tool_version tv on t.tool_uuid = tv.tool_uuid
       inner join specialized_tool_version stv on tv.tool_version_uuid = stv.tool_version_uuid
       where stv.tool_version_uuid = tool_version_uuid_in
         and (
              (stv.specialization_type = 'PLATFORM' and stv.platform_version_uuid = platform_version_uuid_in)
              or
              (stv.specialization_type = 'LANGUAGE' and stv.package_type_id = package_type_id_var)
             );
    else
      select tool.tool_uuid,
             tool_version.tool_version_uuid,
             tool.name as tool_name,
             tool.tool_sharing_status,
             tool_version.version_string,
             null as platform_id,
             tool_version.comment_public as public_version_comment,
             tool_version.comment_private as private_version_comment,
             tool_version.tool_path,
             tool_version.checksum,
             tool.is_build_needed as IsBuildNeeded,
             tool_version.tool_executable,
             tool_version.tool_arguments,
             tool_version.tool_directory
        from tool
       inner join tool_version on tool.tool_uuid = tool_version.tool_uuid
       where tool_version.tool_version_uuid = tool_version_uuid_in;
    end if;
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

-- Dump completed on 2016-01-15  0:21:33
