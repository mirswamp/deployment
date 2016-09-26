-- MySQL dump 10.14  Distrib 5.5.46-MariaDB, for Linux (x86_64)
--
-- Host: swa-csaper-dt-01    Database: package_store
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

USE `package_store`;

--
-- Table structure for table `package_type`
--

DROP TABLE IF EXISTS `package_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `package_type` (
  `package_type_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'internal id',
  `name` varchar(50) DEFAULT NULL COMMENT 'display name',
  `create_user` varchar(50) DEFAULT NULL COMMENT 'db user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(50) DEFAULT NULL COMMENT 'db user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last updated',
  PRIMARY KEY (`package_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COMMENT='package types';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `package_type`
--

LOCK TABLES `package_type` WRITE;
/*!40000 ALTER TABLE `package_type` DISABLE KEYS */;
INSERT INTO `package_type` VALUES (1,'C/C++','root@localhost','2014-02-11 21:03:09','swim_dev@10.129.65.52','2015-05-14 21:14:51'),(2,'Java Source Code','root@localhost','2014-02-11 21:03:09','swim_dev@10.129.65.52','2015-05-14 21:14:50'),(3,'Java Bytecode','root@localhost','2014-02-11 21:03:09','swim_dev@10.129.65.52','2015-05-14 21:14:48'),(4,'Python2','root@localhost','2014-09-29 19:57:20','pschell@pschell.mirsam.org','2014-09-29 20:40:08'),(5,'Python3','root@localhost','2014-09-29 19:57:20','pschell@pschell.mirsam.org','2014-09-29 20:40:08'),(6,'Android Java Source Code','root@localhost','2014-12-29 21:54:29','swim_dev@10.129.65.52','2015-05-14 21:14:47'),(7,'Ruby','root@localhost','2015-05-14 21:14:15','pschell@pschell.mirsam.org','2015-08-18 18:56:56'),(8,'Ruby Sinatra','pschell@pschell.mirsam.org','2015-08-11 17:13:49',NULL,NULL),(9,'Ruby on Rails','pschell@pschell.mirsam.org','2015-08-11 17:13:49',NULL,NULL),(10,'Ruby Padrino','pschell@pschell.mirsam.org','2015-08-11 17:13:49',NULL,NULL),(11,'Android .apk','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
/*!40000 ALTER TABLE `package_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'package_store'
--
/*!50003 DROP PROCEDURE IF EXISTS `add_package` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`pschell`@`%` PROCEDURE `add_package`(
    IN package_owner_uuid_in VARCHAR(45),
    IN package_name_in VARCHAR(100),
    OUT return_string varchar(100)
)
BEGIN
    DECLARE row_count_int int;
    set return_string = 'ERROR';

    insert into package_store.package (
        package_uuid,
        package_owner_uuid,
        name)
      values (
        uuid(), #package_uuid,
        package_owner_uuid_in, #package_owner_uuid,
        package_name_in #name
        );

    set return_string = 'SUCCESS';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_package_version_failboat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`pschell`@`%` PROCEDURE `add_package_version_failboat`(
    IN package_version_uuid_in VARCHAR(45),
    IN package_path_in VARCHAR(200),
    OUT return_status varchar(12),
    OUT return_msg varchar(100)
)
BEGIN
    set return_status = 'ERROR', return_msg = 'Package version not found';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `download_package` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `download_package`(
    IN package_version_uuid_in VARCHAR(45),
    OUT return_url varchar(200),
    OUT return_success_flag char(1),
    OUT return_msg varchar(100)
  )
BEGIN
    DECLARE row_count_int INT;
    DECLARE package_path_var VARCHAR(200);

    
    select count(1)
      into row_count_int
     from package_version
     where package_version_uuid = package_version_uuid_in;

    if row_count_int = 1 then
      BEGIN
        
        select package_path
          into package_path_var
         from package_version
         where package_version_uuid = package_version_uuid_in;

        
        call assessment.download(package_path_var, return_url, return_success_flag, return_msg);

      END;
    else set return_success_flag = 'N', return_msg = 'ERROR: RECORD NOT FOUND';
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_package_version` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_package_version`(
    IN package_version_uuid_in VARCHAR(45),
    IN package_path_in VARCHAR(200),
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

    set dir_name_only = substr(package_path_in,1,instr(package_path_in,'/')-1);  
    set incoming_dir = concat('/swamp/incoming/',dir_name_only);
    set dest_dir = concat('/swamp/store/SCAPackages/', dir_name_only);
    set dest_full_path = concat('/swamp/store/SCAPackages/',package_path_in);

    
    select count(1)
      into test_count
     from package_version
     where package_version_uuid = package_version_uuid_in;

    
    set cmd1 = CONCAT('cp -r ', incoming_dir, ' ', dest_dir);
    set file_move_return_code = sys_exec(cmd1);

    
    

    
    set cmd1 = null;
    set cmd1 = CONCAT('chmod -R 755 ', dest_dir);
    set chmod_return_code = sys_exec(cmd1);
    

    
    set cksum = sys_eval(concat('sha512sum ',dest_full_path));
    set cksum = substr(cksum,1,instr(cksum,' ')-1);

    if test_count != 1 then
      set return_status = 'ERROR', return_msg = 'Package version not found';
    elseif file_move_return_code != 0 then
      set return_status = 'ERROR', return_msg = 'Error moving package to storage';
    elseif chmod_return_code != 0 then
      set return_status = 'ERROR', return_msg = 'Error setting package permissions';
    elseif cksum is null then
      set return_status = 'ERROR', return_msg = 'Error calculating checksum';
    else
      begin
        update package_version
           set package_path = dest_full_path,
               checksum = cksum
         where package_version_uuid = package_version_uuid_in;
        set return_status = 'SUCCESS', return_msg = 'Package sucessfully moved to storage';
      end;
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fetch_pkg_dependency` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fetch_pkg_dependency`(
    IN package_version_uuid_in VARCHAR(45),
    IN platform_version_uuid_in VARCHAR(45),
    OUT dependency_found_flag CHAR(1),
    OUT dependency_list_out VARCHAR(8000)

)
BEGIN
    select dependency_list
      into dependency_list_out
      from package_store.package_version_dependency
     where package_version_uuid = package_version_uuid_in
       and platform_version_uuid = platform_version_uuid_in;

    if dependency_list_out is null
    then set dependency_found_flag = 'N';
    else set dependency_found_flag = 'Y';
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `list_pkgs_by_owner` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_pkgs_by_owner`(
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
        select p.package_uuid,
               p.name, p.description,
               (select pt.name from package_type pt where pt.package_type_id = p.package_type_id) as package_type
          from package p
         
         where p.package_owner_uuid = user_uuid_in;
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
/*!50003 DROP PROCEDURE IF EXISTS `update_package_cksum` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_package_cksum`(
    IN package_version_uuid_in VARCHAR(45),
    IN checksum_in VARCHAR(200),
    OUT return_string varchar(100)
)
BEGIN
    DECLARE row_count_int int;
    set return_string = 'ERROR';

    select count(1)
      into row_count_int
      from package_version
     where package_version_uuid = package_version_uuid_in;

   if row_count_int > 1 then
     set return_string = 'ERROR: TOO MANY ROWS';
   elseif row_count_int = 0 then
     set return_string = 'ERROR: NO RECORD FOUND';
   elseif row_count_int = 1 then
     BEGIN
       update package_version
          set checksum = checksum_in
        where package_version_uuid = package_version_uuid_in;
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
/*!50003 DROP PROCEDURE IF EXISTS `update_package_path` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_package_path`(
    IN package_version_uuid_in VARCHAR(45),
    IN path_in VARCHAR(200),
    OUT return_string varchar(100)
)
BEGIN
    DECLARE row_count_int int;
    set return_string = 'ERROR';

    select count(1)
      into row_count_int
      from package_version
     where package_version_uuid = package_version_uuid_in;

   if row_count_int > 1 then
     set return_string = 'ERROR: TOO MANY ROWS';
   elseif row_count_int = 0 then
     set return_string = 'ERROR: NO RECORD FOUND';
   elseif row_count_int = 1 then
     BEGIN
       update package_version
          set package_path = path_in
        where package_version_uuid = package_version_uuid_in;
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
/*!50003 DROP PROCEDURE IF EXISTS `list_pkgs_by_project_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_pkgs_by_project_user`(
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
        select distinct p.package_uuid, p.name, p.description,
               (select pt.name from package_type pt where pt.package_type_id = p.package_type_id) as package_type
          from package p
         inner join package_version pv on p.package_uuid = pv.package_uuid
         where upper(pv.version_sharing_status) = 'PUBLIC'
          or ( upper(pv.version_sharing_status) = 'PROTECTED'
               and exists (select 1 from package_version_sharing pvs
                            where pvs.package_version_uuid = pv.package_version_uuid and pvs.project_uuid = project_uuid_in)
              );
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
/*!50003 DROP PROCEDURE IF EXISTS `list_pkg_by_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_pkg_by_user`(
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
        select p2.name, p2.description, p2.package_uuid, pv2.version_string, pv2.package_version_uuid, pv2.comment_public, pv2.create_date version_create_date
        from
        (
        select p.package_uuid, max(pv.version_no) as version_no
          from package p
         inner join package_version pv on p.package_uuid = pv.package_uuid
         where p.package_owner_uuid = user_uuid_in 
            or upper(pv.version_sharing_status) = 'PUBLIC' 
            or (upper(pv.version_sharing_status) = 'PROTECTED'
                and exists (select 1 from package_version_sharing pvs
                            inner join project.project_user pu on pu.project_uid = pvs.project_uuid
                            where pvs.package_version_uuid = pv.package_version_uuid
                              and pu.user_uid = user_uuid_in
                              and pu.delete_date is null
                              and (pu.expire_date > now() or pu.expire_date is null))
               )
        group by p.package_uuid
        ) as x
        inner join package p2 on x.package_uuid = p2.package_uuid
        inner join package_version pv2 on x.package_uuid = pv2.package_uuid and x.version_no = pv2.version_no;
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
/*!50003 DROP PROCEDURE IF EXISTS `list_pkg_vers_by_owner` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_pkg_vers_by_owner`(
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
        select p.package_uuid,
               pv.package_version_uuid,
               p.name,
               (select pt.name from package_type pt where pt.package_type_id = p.package_type_id) as package_type,
               p.package_sharing_status,
               pv.version_sharing_status,
               pv.version_string,
               
               pv.notes,
               pv.package_path,
               pv.checksum,
               pv.source_path,
               pv.build_file,
               pv.build_system,
               pv.build_cmd,
               pv.build_target,
               pv.build_dir,
               pv.build_opt,
               pv.config_cmd,
               pv.config_opt,
               pv.config_dir,
               pv.create_date
          from package p
         inner join package_version pv on p.package_uuid = pv.package_uuid
         where p.package_owner_uuid = user_uuid_in;
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
/*!50003 DROP PROCEDURE IF EXISTS `list_pkg_vers_by_project_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_pkg_vers_by_project_user`(
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
        select p.package_uuid,
               pv.package_version_uuid,
               p.name,
               (select pt.name from package_type pt where pt.package_type_id = p.package_type_id) as package_type,
               p.package_sharing_status,
               pv.version_sharing_status,
               pv.version_string,
               
               pv.notes
               
               
               
               
               
               
               
               
               
               
               
               
          from package p
         inner join package_version pv on p.package_uuid = pv.package_uuid
         where upper(pv.version_sharing_status) = 'PUBLIC'
          or ( upper(pv.version_sharing_status) = 'PROTECTED'
               and exists (select 1 from package_version_sharing pvs
                            where pvs.package_version_uuid = pv.package_version_uuid and pvs.project_uuid = project_uuid_in)
              );
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
/*!50003 DROP PROCEDURE IF EXISTS `list_protected_pkgs_by_project_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `list_protected_pkgs_by_project_user`(
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
        select distinct p.package_uuid, p.name, p.description,
               (select pt.name from package_type pt where pt.package_type_id = p.package_type_id) as package_type
          from package p
         inner join package_version pv on p.package_uuid = pv.package_uuid
         where upper(pv.version_sharing_status) = 'PROTECTED'
               and exists (select 1 from package_version_sharing pvs
                            where pvs.package_version_uuid = pv.package_version_uuid and pvs.project_uuid = project_uuid_in);
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
/*!50003 DROP PROCEDURE IF EXISTS `select_all_pub_pkgs_and_vers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `select_all_pub_pkgs_and_vers`()
BEGIN
    select package.package_uuid,
           package_version.package_version_uuid,
           package.name as package_name,
           (select pt.name from package_type pt where pt.package_type_id = package.package_type_id) as package_type,
           package_version.version_sharing_status,
           package_version.version_string,
           package_version.platform_id,
           package_version.notes as public_version_comment,
           null as private_version_comment,
           package_version.package_path,
           package_version.checksum,
           package_version.source_path,
           package_version.build_file,
           package_version.build_system,
           package_version.build_cmd,
           package_version.build_target,
           package_version.build_dir,
           package_version.build_opt,
           package_version.config_cmd,
           package_version.config_opt,
           package_version.config_dir,
           package_version.bytecode_class_path,
           package_version.bytecode_aux_class_path,
           package_version.bytecode_source_path
      from package
     inner join package_version on package.package_uuid = package_version.package_uuid;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `select_pkg_version` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `select_pkg_version`(
    IN package_version_uuid_in VARCHAR(45)
)
BEGIN
    select package.package_uuid,
           package_version.package_version_uuid,
           package.name as package_name,
           (select pt.name from package_type pt where pt.package_type_id = package.package_type_id) as package_type,
           package_version.version_sharing_status,
           package_version.version_string,
           package_version.platform_id,
           package_version.notes as public_version_comment,
           null as private_version_comment,
           package_version.package_path,
           package_version.checksum,
           package_version.source_path,
           package_version.build_file,
           package_version.build_system,
           package_version.build_cmd,
           package_version.build_target,
           package_version.build_dir,
           package_version.build_opt,
           package_version.config_cmd,
           package_version.config_opt,
           package_version.config_dir,
           package_version.bytecode_class_path,
           package_version.bytecode_aux_class_path,
           package_version.bytecode_source_path,
           package_version.android_sdk_target,
           package_version.android_lint_target,
           package_version.android_redo_build,
           package_version.use_gradle_wrapper,
           package_version.language_version,
           package_version.maven_version,
           package_version.android_maven_plugin
      from package
     inner join package_version on package.package_uuid = package_version.package_uuid
     where package_version.package_version_uuid = package_version_uuid_in;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `store_package_version` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `store_package_version`(
    IN package_uuid_in VARCHAR(45),
    IN package_path_in VARCHAR(200),
    OUT package_path_out VARCHAR(200),
    OUT cksum_out VARCHAR(200),
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

    set dir_name_only = substr(package_path_in,1,instr(package_path_in,'/')-1);  
    set incoming_dir = concat('/swamp/incoming/',dir_name_only);
    set dest_dir = concat('/swamp/store/SCAPackages/', dir_name_only);
    set dest_full_path = concat('/swamp/store/SCAPackages/',package_path_in);

    
    select count(1)
      into test_count
     from package
     where package_uuid = package_uuid_in;

    
    set cmd1 = CONCAT('cp -r ', incoming_dir, ' ', dest_dir);
    set file_move_return_code = sys_exec(cmd1);

    
    

    
    set cmd1 = null;
    set cmd1 = CONCAT('chmod -R 755 ', dest_dir);
    set chmod_return_code = sys_exec(cmd1);
    

    
    set cksum = sys_eval(concat('sha512sum ',dest_full_path));
    set cksum = substr(cksum,1,instr(cksum,' ')-1);

    if test_count != 1 then
      set return_status = 'ERROR', return_msg = 'Package record not found';
    elseif file_move_return_code != 0 then
      set return_status = 'ERROR', return_msg = 'Error moving package to storage';
    elseif chmod_return_code != 0 then
      set return_status = 'ERROR', return_msg = 'Error setting package permissions';
    elseif cksum is null then
      set return_status = 'ERROR', return_msg = 'Error calculating checksum';
    else
      set package_path_out = dest_full_path,
          cksum_out = cksum,
          return_status = 'SUCCESS',
          return_msg = 'Package sucessfully moved to storage';
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_execution_run_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`pschell`@`%` PROCEDURE `update_execution_run_status`(
    IN execution_record_uuid_in VARCHAR(45),
    IN status_in VARCHAR(25),
    IN run_start_time_in TIMESTAMP,
    IN run_end_time_in TIMESTAMP,
    IN exec_node_architecture_id_in VARCHAR(128),
    IN lines_of_code_in INT,
    IN cpu_utilization_in VARCHAR(32),
    IN vm_hostname_in VARCHAR(100),
    IN vm_username_in VARCHAR(50),
    IN vm_password_in VARCHAR(50),
    IN vm_ip_address_in VARCHAR(50),
    OUT return_string varchar(100)
  )
BEGIN
    DECLARE queued_duration_var VARCHAR(12);
    DECLARE execution_duration_var VARCHAR(12);
    DECLARE row_count_int int;

    # verify exists 1 matching execution_record
    select count(1)
      into row_count_int
      from assessment.execution_record
     where execution_record_uuid = execution_record_uuid_in;

    if row_count_int = 1 then
      BEGIN
/*
create table assessment.execution_run_status_log (
execution_run_status_log_id  INT  NOT NULL AUTO_INCREMENT COMMENT 'internal id',
execution_record_uuid_in                         VARCHAR(45),
status_in                         VARCHAR(25),
run_start_time_in                         DATETIME,
run_end_time_in                         DATETIME,
exec_node_architecture_id_in                         VARCHAR(128),
lines_of_code_in                         INT,
cpu_utilization_in                         VARCHAR(32),
vm_hostname_in                         VARCHAR(100),
vm_username_in                         VARCHAR(50),
vm_password_in                         VARCHAR(50),
vm_ip_address_in                         VARCHAR(50),
create_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
PRIMARY KEY (execution_run_status_log_id)
 );
*/
insert into assessment.execution_run_status_log
  (execution_record_uuid_in,status_in,run_start_time_in,run_end_time_in,exec_node_architecture_id_in,
   lines_of_code_in,cpu_utilization_in,vm_hostname_in,vm_username_in,vm_password_in,vm_ip_address_in)
  values
  (execution_record_uuid_in,status_in,run_start_time_in,run_end_time_in,exec_node_architecture_id_in,
   lines_of_code_in,cpu_utilization_in,vm_hostname_in,vm_username_in,vm_password_in,vm_ip_address_in);

# vm_ip_address is reported seperately
# So, if vm_ip_address_in is not null, then update only vm_ip_address
# else do the "regular" update
        if (vm_ip_address_in != '' and vm_ip_address_in is not null) then
          update assessment.execution_record
             set vm_ip_address = vm_ip_address_in
           where execution_record_uuid = execution_record_uuid_in;
        else
          update assessment.execution_record
             set status = status_in,
                 run_date = run_start_time_in,
                 completion_date = run_end_time_in,
                 queued_duration = timediff(run_start_time_in, create_date),
                 execution_duration = timediff(run_end_time_in, run_start_time_in),
                 execute_node_architecture_id = exec_node_architecture_id_in,
                 lines_of_code = lines_of_code_in,
                 cpu_utilization = cpu_utilization_in,
                 vm_password = vm_password_in,
                 vm_hostname   = case when vm_hostname_in = '' then vm_hostname else vm_hostname_in end, #dont overwrite if incoming value is blank
                 vm_username   = case when vm_username_in = '' then vm_username else vm_username_in end  #dont overwrite if incoming value is blank
           where execution_record_uuid = execution_record_uuid_in;
        end if;

        set return_string = 'SUCCESS';
      END;
    else
      set return_string = 'ERROR: Record Not Found';
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

-- Dump completed on 2016-01-15  0:11:27
