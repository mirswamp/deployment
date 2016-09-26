USE `tool_shed`;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `tool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tool` (
  `tool_uuid` varchar(45) NOT NULL COMMENT 'tool uuid',
  `tool_owner_uuid` varchar(45) DEFAULT NULL COMMENT 'tool owner uuid',
  `name` varchar(100) NOT NULL COMMENT 'tool name',
  `description` varchar(500) DEFAULT NULL COMMENT 'description',
  `tool_sharing_status` varchar(25) NOT NULL DEFAULT 'PRIVATE' COMMENT 'private, shared, public or retired',
  `is_build_needed` tinyint(4) DEFAULT NULL COMMENT 'Does tool analyze build output instead of source',
  `policy_code` varchar(100) DEFAULT NULL COMMENT 'if tool requires policy',
  `create_user` varchar(25) DEFAULT NULL COMMENT 'db user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(25) DEFAULT NULL COMMENT 'db user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last updated',
  PRIMARY KEY (`tool_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='contains all tools';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `tool` WRITE;
INSERT INTO `tool` VALUES ('0f668fb0-4421-11e4-a4f3-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Pylint','Pylint is a tool that checks for errors in Python code, tries to enforce a coding standard, and looks for bad code smells. <a href=\"http://www.pylint.org/\">http://www.pylint.org/</a>','PUBLIC',0,NULL,'root@localhost','2014-09-29 19:57:20','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('163d56a7-156e-11e3-a239-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Findbugs','FindBugs is a program to find bugs in Java code. It looks for \"bug patterns\" - code instances that are likely to be errors. <a href=\"http://findbugs.sourceforge.net/\">http://findbugs.sourceforge.net/</a>','PUBLIC',1,NULL,'pschell@pschell.mirsam.or','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('163e5d8c-156e-11e3-a239-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','cppcheck','Cppcheck is a static analysis tool for C/C++ code. Unlike C/C++ compilers and many other analysis tools, it does not detect syntax errors in the code. Cppcheck primarily detects the types of bugs that the compilers normally do not detect. The goal is to detect only real errors in the code (i.e. have zero false positives). <a href=\"http://cppcheck.sourceforge.net/\">http://cppcheck.sourceforge.net/</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('163f2b01-156e-11e3-a239-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','PMD','PMD is a Java source code analyzer. It finds common programming flaws like unused variables, empty catch blocks, and unnecessary object creation. <a href=\"http://pmd.sourceforge.net/\">http://pmd.sourceforge.net/</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('56872C2E-1D78-4DB0-B976-83ACF5424C52','80835e30-d527-11e2-8b8b-0800200c9a66','error-prone','Error-prone augments the compiler\'s type analysis to catch Java mistakes before they end up as bugs in production. <a href=\"http://errorprone.info/\">http://errorprone.info/</a>','PUBLIC',0,NULL,'root@localhost','2014-05-15 06:22:40','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('59612f24-0946-11e5-b6a7-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','ruby-lint','A linter and static code analysis tool for Ruby. <a href=\"https://rubygems.org/gems/ruby-lint\">https://rubygems.org/gems/ruby-lint</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2015-06-02 16:51:13','pschell@pschell.mirsam.or','2015-06-03 17:13:38');
INSERT INTO `tool` VALUES ('5cd726a5-4053-11e5-83f1-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Brakeman','An open source vulnerability scanner specifically designed for Ruby on Rails applications. <a href=\"http://brakemanscanner.org/\">http://brakemanscanner.org/</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2015-08-17 17:48:35','pschell@pschell.mirsam.or','2015-08-24 17:33:53');
INSERT INTO `tool` VALUES ('63695cd8-a73e-11e4-a335-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Flake8','Flake8 is a Python tool that glues together pep8, pyflakes, mccabe, and third-party plugins to check the style and quality of Python code. <a href=\"https://gitlab.com/pycqa/flake8\">https://gitlab.com/pycqa/flake8</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2015-01-30 18:23:23','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('738b81f0-a828-11e5-865f-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','RevealDroid','RevealDroid finds malware in Android applications.','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool` VALUES ('7A08B82D-3A3B-45CA-8644-105088741AF6','80835e30-d527-11e2-8b8b-0800200c9a66','GCC','The GNU Compiler Collection includes front ends for C & C++. GCC was originally written as the compiler for the GNU operating system. <a href=\"https://gcc.gnu.org/\">https://gcc.gnu.org/</a>','PUBLIC',0,NULL,'swim_dev@dboulineau.mirsa','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('7fbfa454-8f9f-11e4-829b-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Bandit','Bandit provides a framework for performing security analysis of Python source code. <a href=\"https://wiki.openstack.org/wiki/Security/Projects/Bandit\">https://wiki.openstack.org/wiki/Security/Projects/Bandit</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2014-12-29 21:54:29','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('8157e489-1fbc-11e5-b6a7-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Reek','Code smell detector for Ruby. <a href=\"https://github.com/troessner/reek\">https://github.com/troessner/reek</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2015-07-01 06:58:29',NULL,NULL);
INSERT INTO `tool` VALUES ('9289b560-8f8b-11e4-829b-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Android lint','Android Lint is a static code analysis tool that checks Android project source files for potential bugs and optimization improvements for correctness, security, performance, usability, accessibility, and internationalization. <a href=\"http://tools.android.com/tips/lint\">http://tools.android.com/tips/lint</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2014-12-29 21:54:29','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('992A48A5-62EC-4EE9-8429-45BB94275A41','80835e30-d527-11e2-8b8b-0800200c9a66','checkstyle','Checkstyle is a development tool to help programmers write Java code that adheres to a coding standard. <a href=\"http://checkstyle.sourceforge.net/\">http://checkstyle.sourceforge.net/</a>','PUBLIC',0,NULL,'root@localhost','2014-05-15 06:22:40','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
INSERT INTO `tool` VALUES ('b9560648-4057-11e5-83f1-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Dawn','A static analysis security scanner for ruby written web applications. It supports Sinatra, Padrino and Ruby on Rails frameworks. <a href=\"https://github.com/thesp0nge/dawnscanner\">https://github.com/thesp0nge/dawnscanner/</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2015-08-17 17:48:59','pschell@pschell.mirsam.or','2015-08-24 17:33:53');
INSERT INTO `tool` VALUES ('ebcab7f6-0935-11e5-b6a7-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','RuboCop','A Ruby static code analyzer, based on the community Ruby style guide. <a href=\"https://github.com/bbatsov/rubocop\">https://github.com/bbatsov/rubocop</a>','PUBLIC',0,NULL,'pschell@pschell.mirsam.or','2015-06-02 16:47:17','pschell@pschell.mirsam.or','2015-06-03 17:14:27');
INSERT INTO `tool` VALUES ('f212557c-3050-11e3-9a3e-001a4a81450b','80835e30-d527-11e2-8b8b-0800200c9a66','Clang Static Analyzer','The Clang Static Analyzer is a source code analysis tool that finds bugs in C & C++. <a href=\"http://clang-analyzer.llvm.org/\">http://clang-analyzer.llvm.org/</a>','public',0,NULL,'pschell@pschell.mirsam.or','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2015-03-02 21:13:25');
UNLOCK TABLES;
DROP TABLE IF EXISTS `tool_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tool_version` (
  `tool_version_uuid` varchar(45) NOT NULL COMMENT 'version uuid',
  `tool_uuid` varchar(45) NOT NULL COMMENT 'each version belongs to a tool; links to tool',
  `version_no` int(11) DEFAULT NULL COMMENT 'incremental integer version number',
  `version_string` varchar(100) DEFAULT NULL COMMENT 'eg version 5.0 stable release for Windows 7 64-bit',
  `release_date` timestamp NULL DEFAULT NULL COMMENT 'date version is released',
  `retire_date` timestamp NULL DEFAULT NULL COMMENT 'date version is retired',
  `comment_public` varchar(200) DEFAULT NULL COMMENT 'Comment visible to users.',
  `comment_private` varchar(200) DEFAULT NULL COMMENT 'comment for tool owner and admins only',
  `tool_path` varchar(200) DEFAULT NULL COMMENT 'cannonical path of tool in swamp storage',
  `checksum` varchar(200) DEFAULT NULL COMMENT 'checksum of tool',
  `tool_executable` varchar(200) DEFAULT NULL COMMENT 'command to invoke tool',
  `tool_arguments` varchar(200) DEFAULT NULL COMMENT 'command to deploy tool',
  `tool_directory` varchar(200) DEFAULT NULL COMMENT 'top level directory within the archive',
  `create_user` varchar(25) DEFAULT NULL COMMENT 'user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(25) DEFAULT NULL COMMENT 'user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last changed',
  PRIMARY KEY (`tool_version_uuid`),
  KEY `fk_version_tool` (`tool_uuid`),
  CONSTRAINT `fk_version_tool` FOREIGN KEY (`tool_uuid`) REFERENCES `tool` (`tool_uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tool can have many versions';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `tool_version` WRITE;
INSERT INTO `tool_version` VALUES ('04be7ddc-e099-11e5-ae56-001a4a81450b','163f2b01-156e-11e3-a239-001a4a81450b',4,'5.4.1','2016-03-02 17:16:53',NULL,'PMD v5.4.1',NULL,'/swamp/store/SCATools/pmd/pmd-5.4.1.tar.gz','d559586eb16b0e1d1d1f1f9ccfc60583ba8b35ca8776dce7b7c297b684e6197e94563ceae328af86a8e51fa64c698709ee85cb8fe1582a198f8727f83781ac75','net.sourceforge.pmd.PMD','','pmd-bin-5.4.1','pschell@pschell.mirsam.or','2016-03-02 17:16:53',NULL,NULL);
INSERT INTO `tool_version` VALUES ('0667d30a-a7f0-11e4-a335-001a4a81450b','992A48A5-62EC-4EE9-8429-45BB94275A41',2,'6.2','2015-01-30 18:23:43',NULL,'Checkstyle 6.2',NULL,'/swamp/store/SCATools/checkstyle/checkstyle-6.2-3.tar.gz','c497e59baf1f1008052bba0dcf176f1394429d156b911d910da6750fe925262ad75d34e778838a806bd3d501d6ef80f877880551658ca549e7c4e39bbce67b91','checkstyle-6.2-all.jar','','checkstyle-6.2','pschell@pschell.mirsam.or','2015-01-30 18:23:43','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('09449DE5-8E63-44EA-8396-23C64525D57C','992A48A5-62EC-4EE9-8429-45BB94275A41',1,'5.7','2014-05-15 06:22:40',NULL,'Checkstyle v5.7',NULL,'/swamp/store/SCATools/checkstyle/checkstyle-5.7-5.tar.gz','48e3fdd4d87077785fdc8c2d0344dc39d94d0ff5a561a75f7af0528d04e5cfd3d2479f496fad5c4666d4f386c5436b1e30dfb159c7e30db11d593b39899d5b7c','checkstyle','','checkstyle','root@localhost','2014-05-15 06:22:40','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('142e9a79-4425-11e4-a4f3-001a4a81450b','0f668fb0-4421-11e4-a4f3-001a4a81450b',1,'1.3.1','2014-09-29 19:57:20',NULL,'Pylint v1.3.1 for Python 2 & 3',NULL,NULL,NULL,NULL,NULL,NULL,'root@localhost','2014-09-29 19:57:20',NULL,NULL);
INSERT INTO `tool_version` VALUES ('163fe1e7-156e-11e3-a239-001a4a81450b','163d56a7-156e-11e3-a239-001a4a81450b',1,'2.0.2 (FindSecurityBugs 1.1.0)','2013-10-18 20:16:54',NULL,'FindBugs+FindSecurityBugs',NULL,'/swamp/store/SCATools/findbugs/findbugs-2.0.2-3.tar.gz','13c29fff911b7a9eb9e9670591263b89878b5321d49122689377f37790e8b9673d253f24d7c9d64161a8cb4a2ffdb135e4f0edf3f58d06f5e1d83b9415b4bbd7','bin/findbugs','','findbugs-2.0.2','pschell@pschell.mirsam.or','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('16414980-156e-11e3-a239-001a4a81450b','163f2b01-156e-11e3-a239-001a4a81450b',1,'5.0.4','2013-10-25 19:30:17',NULL,NULL,NULL,'/swamp/store/SCATools/pmd/pmd-5.0.4-4.tar.gz','f01675549772197a96ec85445f30622a5588a1d25ecc1e2be6485d3e722a2f15052979a3b83ab84c809156f543207ae1f00f9435f5053f82bc19f10e5db88ae4','bin/run.sh','','pmd-bin-5.0.4','pschell@pschell.mirsam.or','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('1ad625bd-71d5-11e5-865f-001a4a81450b','63695cd8-a73e-11e4-a335-001a4a81450b',2,'2.4.1','2015-10-13 21:25:27',NULL,'Flake8 v2.4.1 for Python 2 & 3',NULL,NULL,NULL,NULL,NULL,NULL,'pschell@pschell.mirsam.or','2015-10-13 21:25:27',NULL,NULL);
INSERT INTO `tool_version` VALUES ('1c9a1589-bf05-11e5-832a-001a4a81450b','163e5d8c-156e-11e3-a239-001a4a81450b',4,'1.72','2016-01-20 18:04:27',NULL,'Cppcheck 1.72',NULL,'/swamp/store/SCATools/cppcheck/cppcheck-1.72.tar','c35d6eaee59c43d315cf9f9766e9580d22160746883da03e0f5c783c2928118c55149c9f88d18c141e574c1cfccdfbdd124967b93e51a34b41259a86e6f6cb16','bin/cppcheck','','cppcheck-1.72','pschell@pschell.mirsam.or','2016-01-20 18:04:27',NULL,NULL);
INSERT INTO `tool_version` VALUES ('27ea7f63-a813-11e4-a335-001a4a81450b','163d56a7-156e-11e3-a239-001a4a81450b',3,'3.0.0 (FindSecurityBugs 1.3)','2015-01-30 18:23:57',NULL,'Findbugs 3.0.0 (with FindSecurityBugs-1.3.0 plugin)',NULL,'/swamp/store/SCATools/findbugs/findbugs-3.0.0-3.tar.gz','07df890ceeb48a409a98843513cf53db26ad3ed0d1af75965958872c460dddf50de4873564baaa98e98b21a1cc6f02e0ecc095ba51ebed696bd0bb9077204d47','lib/findbugs.jar','','findbugs-3.0.0','pschell@pschell.mirsam.or','2015-01-30 18:23:57','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('2a16b653-7449-11e5-865f-001a4a81450b','7fbfa454-8f9f-11e4-829b-001a4a81450b',2,'0.14.0','2015-10-16 21:07:45',NULL,'Bandit for Python 2 & 3',NULL,NULL,NULL,NULL,NULL,NULL,'pschell@pschell.mirsam.or','2015-10-16 21:07:45',NULL,NULL);
INSERT INTO `tool_version` VALUES ('325CA868-0D19-4B00-B034-3786887541AA','7A08B82D-3A3B-45CA-8644-105088741AF6',1,'current','2013-12-16 00:00:00',NULL,'GCC',NULL,'/swamp/store/SCATools/gcc/gcc-warn-0.9.tar.gz','d97c43bd44ca4ec9c58e7fba2baff0536261d633ad6d53f09f84aa4427cc5fae4f1d350c0de681b24d85f470c86b26dd812db0c41e9795729f1296cfae558d4d','','','','swim_dev@dboulineau.mirsa','2014-02-01 23:37:56','pschell@pschell.mirsam.or','2015-11-05 17:18:40');
INSERT INTO `tool_version` VALUES ('4c1ec754-cb53-11e3-8775-001a4a81450b','163d56a7-156e-11e3-a239-001a4a81450b',2,'2.0.3 (FindSecurityBugs 1.2)','2014-04-24 06:22:19',NULL,'FindBugs+FindSecurityBugs',NULL,'/swamp/store/SCATools/findbugs/findbugs-2.0.3-5.tar.gz','83a1e973a7a674e58c211432d5ac4977866d33edfb0d83e4e21c0f47271375c969934788fb246da13ea0a6aae7b69f9b42a806278ba59d60df37609e3279fa33','bin/findbugs','','findbugs-2.0.3','root@localhost','2014-04-24 06:22:19','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('4fcb04a8-e096-11e5-ae56-001a4a81450b','56872C2E-1D78-4DB0-B976-83ACF5424C52',2,'2.0.7','2016-03-02 17:16:53',NULL,'error-prone v2.0.7',NULL,'/swamp/store/SCATools/error-prone/error-prone-2.0.7-2.tar.gz','0df3f8d19b35c7276d51f5984223f16ad5d24a606b01d9a5662819f47d97ffea6ea3025d91e905f5ba259061ef804af48bb6968e3d47293f6bb36ee6c62bbe3a','error_prone_ant-2.0.7.jar','','error-prone-2.0.7','pschell@pschell.mirsam.or','2016-03-02 17:16:53',NULL,NULL);
INSERT INTO `tool_version` VALUES ('5230FE76-E658-4B3A-AD40-7D55F7A21955','56872C2E-1D78-4DB0-B976-83ACF5424C52',1,'1.1.1','2014-05-15 06:22:40',NULL,'error-prone v1.1.1',NULL,'/swamp/store/SCATools/error-prone/error-prone-1.1.1-5.tar.gz','3e083afea07ec714e9e107c17c1c9870b1d2bb6c01973ae904451be9ce0ad8595a35c71148ba84f90df519dbe0ead6fa041011adb052e27b85140724e1f7c65f','','','','root@localhost','2014-05-15 06:22:40','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('6b06aaa6-4053-11e5-83f1-001a4a81450b','5cd726a5-4053-11e5-83f1-001a4a81450b',1,'3.05','2015-08-17 17:48:37',NULL,'Brakeman 3.05 for Ruby',NULL,'/swamp/store/SCATools/brakeman/brakeman-3.0.5-2.tar.gz','778bd9ed4d3c4cdc875b6e464a2473ad617e14e8c734bad3280d7b8e1686b448d94e2a23158ddde535e3bcc44279ad1c949c44f9f9c74fab93ab5770d3fce058','brakeman','','brakeman-3.0.5','pschell@pschell.mirsam.or','2015-08-17 17:48:37','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('6b5624a0-0946-11e5-b6a7-001a4a81450b','59612f24-0946-11e5-b6a7-001a4a81450b',1,'2.0.4','2015-06-02 16:51:13',NULL,'ruby-lint 2.0.4 for Ruby',NULL,'/swamp/store/SCATools/ruby-lint/ruby-lint-2.0.4-2.tar.gz','09b445f60c94d96bd8f4a354a8d1574265210c1dfb3a95ca335a83ec9bba397a7bc5356308c9d10affbb9957e9251dd6cd9c2c79ef3ce24a016a12c1b7b12a97','ruby-lint','','ruby-lint-2.0.4','pschell@pschell.mirsam.or','2015-06-02 16:51:13','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('7059b296-4c14-11e5-83f1-001a4a81450b','8157e489-1fbc-11e5-b6a7-001a4a81450b',2,'3.1','2015-08-26 17:22:57',NULL,'Reek 3.1 for Ruby',NULL,'/swamp/store/SCATools/reek/reek-3.1-4.tar.gz','9596455db7985e5dc520034b6f4e01b9fb4a96885f5810ef2b4affa3e97e68473302918a4816e9126affd7d2d9822ddf6d1fad2f9d5749ae85eba55274e6b951','reek','','reek-3.1','pschell@pschell.mirsam.or','2015-08-26 17:22:57','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('7b504c42-bf06-11e5-832a-001a4a81450b','163e5d8c-156e-11e3-a239-001a4a81450b',3,'1.71','2016-01-20 18:04:17',NULL,'Cppcheck 1.71',NULL,'/swamp/store/SCATools/cppcheck/cppcheck-1.71.tar','906dab652b42ebf22170bb673e23bf1f73f1f8b64417e9aedaee3a483e63fc7f6f07fbbf42b4691091b3720c74a96b61a0bb187304cac7222d12e28b892acee5','bin/cppcheck','','cppcheck-1.71','pschell@pschell.mirsam.or','2016-01-20 18:04:17',NULL,NULL);
INSERT INTO `tool_version` VALUES ('8666e176-a828-11e5-865f-001a4a81450b','738b81f0-a828-11e5-865f-001a4a81450b',1,'2015.11.05','2015-12-21 21:41:58',NULL,'RevealDroid 2015.11.05',NULL,'/swamp/store/SCATools/revealdroid/revealdroid-2015.11.05-1.tar','1a0d4a9e0696db42a37fdba6dd0304b83c7450e1ef5a2873347ecc87320b9e24008a66c058fd9969eddbe5dd1b20eb61b705845ff49b69897946b3095ca3d4a8',NULL,NULL,NULL,'pschell@pschell.mirsam.or','2015-12-21 21:41:58','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('8ec206ff-f59b-11e3-8775-001a4a81450b','f212557c-3050-11e3-9a3e-001a4a81450b',1,'3.3','2014-06-19 20:02:33',NULL,'Clang Static Analyzer 3.3',NULL,'/swamp/store/SCATools/clang/clang-sa-3.3.tar','a543093d7fca3d3de419f4a742dd48657268f4616c45e71732fa8e3bf7816b5ad08aabbf118c1147d10435541a04247df0c6ac58a29eb5eefdfd6bf92d2c5e12','bin/scan-build/scan-build',NULL,'clang-sa-3.3','pschell@pschell.mirsam.or','2014-06-19 20:02:33','pschell@pschell.mirsam.or','2015-11-02 21:32:23');
INSERT INTO `tool_version` VALUES ('90554576-81a0-11e5-865f-001a4a81450b','f212557c-3050-11e3-9a3e-001a4a81450b',2,'3.7','2015-11-02 21:32:33',NULL,'Clang Static Analyzer 3.7',NULL,'/swamp/store/SCATools/clang/clang-sa-3.7.0.tar','2416e3bd67816098a7dcb29a080d61622e975675166ca788b3f944f91c6ff43c37fec5557f077058aec3a62c10581523c9a88b54d9f165dabd46054af8089de2','bin/scan-build/scan-build','','clang-sa-3.7.0','pschell@pschell.mirsam.or','2015-11-02 21:32:33',NULL,NULL);
INSERT INTO `tool_version` VALUES ('950734d0-f59b-11e3-8775-001a4a81450b','163e5d8c-156e-11e3-a239-001a4a81450b',1,'1.61','2014-06-19 20:02:33',NULL,'Cppcheck 1.61',NULL,'/swamp/store/SCATools/cppcheck/cppcheck-1.61.tar','7754de972e4489be2923269f06a875f55accceeb3a0eceb81a3ffbea49da3f032515447944595597dc20dea6b5e96164fed7740c4d9fff23fad27910899c999b','bin/cppcheck','','cppcheck-1.61','pschell@pschell.mirsam.or','2014-06-19 20:02:33','pschell@pschell.mirsam.or','2015-11-04 22:04:44');
INSERT INTO `tool_version` VALUES ('9c48c4ad-e098-11e5-ae56-001a4a81450b','163d56a7-156e-11e3-a239-001a4a81450b',4,'3.0.1','2016-03-02 17:16:53',NULL,'Findbugs 3.0.1 (with FindSecurityBugs-1.4.5 plugin)',NULL,'/swamp/store/SCATools/findbugs/findbugs-3.0.1.tar.gz','dafe7784c38038c8e38ca6e0ddb8882a99005da615cae0ee95734729484271b2dd4659142a612196941a080f39a73aac704c4047a9c14e01dbd0f13615ac9039','lib/findbugs.jar','','findbugs-3.0.1','pschell@pschell.mirsam.or','2016-03-02 17:16:53',NULL,NULL);
INSERT INTO `tool_version` VALUES ('9cbd0e60-8f9f-11e4-829b-001a4a81450b','7fbfa454-8f9f-11e4-829b-001a4a81450b',1,'8ba3536','2014-12-29 21:54:29',NULL,'Bandit for Python',NULL,'/swamp/store/SCATools/bandit/bandit-8ba3536-3.tar.gz','6097a4b9d5b2663c965d1e07bb96e54b75f05e81fc7370652470c6113045720239a428d2f21ea366912b77fb54e77f637a1d741b1cb676ce3d7c067b9209f762','','','','pschell@pschell.mirsam.or','2014-12-29 21:54:29','pschell@pschell.mirsam.or','2016-01-20 18:04:07');
INSERT INTO `tool_version` VALUES ('a2d949ef-cb53-11e3-8775-001a4a81450b','163f2b01-156e-11e3-a239-001a4a81450b',2,'5.1.0','2014-04-24 06:22:19',NULL,NULL,NULL,'/swamp/store/SCATools/pmd/pmd-5.1.0-4.tar.gz','97ef43dc4435c412cd7174745946e210b707b41064c33f14aba687b2bea7a477938aa6c1ac00e736fc2b8c6280ed6ef7b42dc3af3d1df9ead461803a6a0e74cb','bin/run.sh','','pmd-bin-5.1.0','root@localhost','2014-04-24 06:22:19','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('b5115bdd-e095-11e5-ae56-001a4a81450b','992A48A5-62EC-4EE9-8429-45BB94275A41',3,'6.14','2016-03-02 17:16:53',NULL,'Checkstyle v6.14',NULL,'/swamp/store/SCATools/checkstyle/checkstyle-6.14.1.tar.gz','ad202c24fe237ba352f36c1bdea9675b59479bf88300f3fb2847b10bda1024d08f7b0299ea95c6aa4902e19cd12aaba049bc3de154f24beb27f0c4d3b1e87b65','checkstyle-6.14.1-all.jar','','checkstyle-6.14.1','pschell@pschell.mirsam.or','2016-03-02 17:16:53',NULL,NULL);
INSERT INTO `tool_version` VALUES ('bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b','8157e489-1fbc-11e5-b6a7-001a4a81450b',1,'2.2.1','2015-07-01 06:58:49',NULL,'Reek 2.2.1 for Ruby',NULL,'/swamp/store/SCATools/reek/reek-2.2.1-5.tar.gz','c737e87c6383dd6a6f1582d2d02ec4caaf088541c2c61a2d5773a0da2fbe221f4122483f2ffa80aef1d0ad5e71df8cfa628923db9c7dff64ad16094ce019fe4a','reek','','reek-2.2.1','pschell@pschell.mirsam.or','2015-07-01 06:58:49','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('bdaf4b93-a811-11e4-a335-001a4a81450b','163f2b01-156e-11e3-a239-001a4a81450b',3,'5.2.3','2015-01-30 18:24:10',NULL,'PMD 5.2.3',NULL,'/swamp/store/SCATools/pmd/pmd-5.2.3-4.tar.gz','2c0a50aaa65c473368cdd018f4cf5dd9d2f69a3c604a241e6f5932d4e2107373e21c418308cf8af06de20dacd0c1f02db4d1a0b3211585154cb0776d0fd60293','net.sourceforge.pmd.PMD','','pmd-bin-5.2.3','pschell@pschell.mirsam.or','2015-01-30 18:24:10','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('c9126789-71d7-11e5-865f-001a4a81450b','0f668fb0-4421-11e4-a4f3-001a4a81450b',2,'1.4.4','2015-10-13 21:25:49',NULL,'Pylint v1.4.4 for Python 2 & 3',NULL,NULL,NULL,NULL,NULL,NULL,'pschell@pschell.mirsam.or','2015-10-13 21:25:49',NULL,NULL);
INSERT INTO `tool_version` VALUES ('ca1608e1-4057-11e5-83f1-001a4a81450b','b9560648-4057-11e5-83f1-001a4a81450b',1,'1.3.5','2015-08-17 17:48:59',NULL,'Dawn 1.3.5 for Ruby',NULL,'/swamp/store/SCATools/dawn/dawnscanner-1.3.5-2.tar.gz','1d5221c5a85dc3c243cf5860b5c53d6094987861eb1b44bb1ea1e5d3856287521cf9daa3b470d7b38333068b7ac71948651df16f7e183375bb98efa870e1e8af','dawn','','dawnscanner-1.3.5','pschell@pschell.mirsam.or','2015-08-17 17:48:59','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('dcbdab3c-4d8b-11e5-83f1-001a4a81450b','9289b560-8f8b-11e4-829b-001a4a81450b',1,'0.1.4','2015-09-02 20:49:50',NULL,'Android Lint 0.1.4',NULL,'/swamp/store/SCATools/lint/android-lint-0.1.4.tar.gz','c5c8e3cef7ecaab43090189e4a3b3dff45eb5e2909f375180784b041c14a8513cc15f27a505ef79a462536529ba4d5188e854f78afcb3e96773964d5a858082f','','','android-lint-0.1.4','pschell@pschell.mirsam.or','2015-09-02 20:49:50','web@10.129.65.61','2015-09-11 19:58:31');
INSERT INTO `tool_version` VALUES ('e9cea65f-833e-11e5-865f-001a4a81450b','163e5d8c-156e-11e3-a239-001a4a81450b',2,'1.70','2015-11-04 22:04:44',NULL,'Cppcheck 1.70',NULL,'/swamp/store/SCATools/cppcheck/cppcheck-1.70.tar','523d79429c87f5bde3c0eca8a4c641778860c32b0e8868adb104dcc28056d8d35524deadce9f19bf95f28cb8b92e1fbc4ec9a01b07d13e92f2bfcb06fbaf0751','bin/cppcheck','','cppcheck-1.70','pschell@pschell.mirsam.or','2015-11-04 22:04:44',NULL,NULL);
INSERT INTO `tool_version` VALUES ('ea1f9693-46ac-11e5-83f1-001a4a81450b','ebcab7f6-0935-11e5-b6a7-001a4a81450b',2,'0.33','2015-08-19 21:48:42',NULL,'RuboCop 0.33 for Ruby',NULL,'/swamp/store/SCATools/rubocop/rubocop-0.33.0-2.tar.gz','4ced934bbcfef8e08eef17fd4071337b073a7c00d370c3c4ed63aabeeeba2b843ee0cd0975e3b81850699c9b28575c5f5e49d20daff2356f0ed06ca4080395da','rubocop','','rubocop-0.33.0','pschell@pschell.mirsam.or','2015-08-19 21:48:42','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('f5c26a51-0935-11e5-b6a7-001a4a81450b','ebcab7f6-0935-11e5-b6a7-001a4a81450b',1,'0.31','2015-06-02 16:47:19',NULL,'RuboCop 0.31 for Ruby',NULL,'/swamp/store/SCATools/rubocop/rubocop-0.31.0-3.tar.gz','d4be964d430eee4dbbe63c8aa67d3ad55c520ed2bf1fd85d79a0dd53a0f35e1b3fdd29f2ff868addbc8ea6c9758e667098b4e4b811615080f8dab392b0ba837f','rubocop','','rubocop-0.31.0','pschell@pschell.mirsam.or','2015-06-02 16:47:19','pschell@pschell.mirsam.or','2016-03-02 17:28:03');
INSERT INTO `tool_version` VALUES ('fe360cd7-a7e3-11e4-a335-001a4a81450b','63695cd8-a73e-11e4-a335-001a4a81450b',1,'2.3.0','2015-01-30 18:23:23',NULL,'Flake8 v2.3.0 for Python 2 & 3',NULL,NULL,NULL,NULL,NULL,NULL,'pschell@pschell.mirsam.or','2015-01-30 18:23:23',NULL,NULL);
UNLOCK TABLES;
DROP TABLE IF EXISTS `specialized_tool_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `specialized_tool_version` (
  `specialized_tool_version_uuid` varchar(45) NOT NULL COMMENT 'internal id',
  `tool_uuid` varchar(45) NOT NULL COMMENT 'each version belongs to a tool; links to tool',
  `tool_version_uuid` varchar(45) NOT NULL COMMENT 'version uuid',
  `specialization_type` varchar(25) DEFAULT NULL COMMENT 'PLATFORM, LANGUAGE',
  `platform_version_uuid` varchar(45) DEFAULT NULL COMMENT 'platform version uuid',
  `package_type_id` int(11) DEFAULT NULL COMMENT 'references package_store.package_type',
  `tool_path` varchar(200) DEFAULT NULL COMMENT 'cannonical path of tool in swamp storage',
  `checksum` varchar(200) DEFAULT NULL COMMENT 'checksum of tool',
  `tool_executable` varchar(200) DEFAULT NULL COMMENT 'command to invoke tool',
  `tool_arguments` varchar(200) DEFAULT NULL COMMENT 'arguments to pass to the tool',
  `tool_directory` varchar(200) DEFAULT NULL COMMENT 'top level directory within the archive',
  `create_user` varchar(25) DEFAULT NULL COMMENT 'user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(25) DEFAULT NULL COMMENT 'user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last changed',
  PRIMARY KEY (`specialized_tool_version_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tools may require specialized files based on OS or language';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `specialized_tool_version` WRITE;
INSERT INTO `specialized_tool_version` VALUES ('134873d9-a7e4-11e4-a335-001a4a81450b','63695cd8-a73e-11e4-a335-001a4a81450b','fe360cd7-a7e3-11e4-a335-001a4a81450b','LANGUAGE',NULL,4,'/swamp/store/SCATools/flake/flake8-py2-2.3.0-2.tar.gz','dbc0833312f801640762cd927d795c28661840de11acdaf4b43de6b93f47bff3993dcafa0c75be8adc4efc2a9147cf5a5efa96cb68fb51248ed9f40e646d6b9b','flake8','--verbose --exit-zero --format=pylint','flake8-2.3.0','pschell@pschell.mirsam.or','2015-01-30 18:23:23','pschell@pschell.mirsam.or','2015-10-13 21:25:18');
INSERT INTO `specialized_tool_version` VALUES ('1e58fe0c-a7e4-11e4-a335-001a4a81450b','63695cd8-a73e-11e4-a335-001a4a81450b','fe360cd7-a7e3-11e4-a335-001a4a81450b','LANGUAGE',NULL,5,'/swamp/store/SCATools/flake/flake8-py3-2.3.0-2.tar.gz','81cfb2e63558cb8c7e469333eea2214e0f1d9546055a2e51703c54b413dca94080243c7eadf90a13b8300729b3781bc6505c2f776dcb13830ade354aa316c273','flake8','--verbose --exit-zero --format=pylint','flake8-2.3.0','pschell@pschell.mirsam.or','2015-01-30 18:23:23','pschell@pschell.mirsam.or','2015-10-13 21:25:18');
INSERT INTO `specialized_tool_version` VALUES ('364e8718-480a-11e4-a4f3-001a4a81450b','0f668fb0-4421-11e4-a4f3-001a4a81450b','142e9a79-4425-11e4-a4f3-001a4a81450b','LANGUAGE',NULL,4,'/swamp/store/SCATools/pylint/pylint-py2-1.3.1-2.tar.gz','d9168624d32f7988bd6c18e4d801888ce5e16298594dd3e7b01dec41f716bac05ec4014c58ea95e26f932284948a5c8e868ffbf4e824042ae49c4bd0c22a3e15','pylint','-f parseable --disable=C --disable=R','pylint-py2-1.3.1',NULL,'2014-09-29 19:57:20','pschell@pschell.mirsam.or','2015-10-13 21:25:40');
INSERT INTO `specialized_tool_version` VALUES ('5b7d6fde-71d5-11e5-865f-001a4a81450b','63695cd8-a73e-11e4-a335-001a4a81450b','1ad625bd-71d5-11e5-865f-001a4a81450b','LANGUAGE',NULL,4,'/swamp/store/SCATools/flake/flake8-py2-2.4.1.tar.gz','1887b97c5cd05ce4b280f3bbb569eea775732a0c89031e4173616fbdf44935e3aef0d604234ed4b89f90eb2ee69e2dcb5ca6d88d4836d061b55dd5f6e8b9986e','flake8','--verbose --exit-zero --format=pylint --output-file=${REPORTS_DIR}/report.txt','flake8-2.4.1','pschell@pschell.mirsam.or','2015-10-13 21:25:27',NULL,NULL);
INSERT INTO `specialized_tool_version` VALUES ('7774f01a-7449-11e5-865f-001a4a81450b','7fbfa454-8f9f-11e4-829b-001a4a81450b','2a16b653-7449-11e5-865f-001a4a81450b','LANGUAGE',NULL,4,'/swamp/store/SCATools/bandit/bandit-py2-0.14.0-2.tar.gz','7410c29f5c9b22dd7145642fabbe3153a5f1a97086ea010575ace7ee301f8fc0a0fbe8c1f761600a832741416fd7f708e34eb05eca2e83532e8ae813ab091f9b','bandit','--format json --output ${REPORTS_DIR}/report.json','bandit-py2-0.14.0','pschell@pschell.mirsam.or','2015-10-16 21:07:45','pschell@pschell.mirsam.or','2016-01-20 18:04:07');
INSERT INTO `specialized_tool_version` VALUES ('813b30f3-71d5-11e5-865f-001a4a81450b','63695cd8-a73e-11e4-a335-001a4a81450b','1ad625bd-71d5-11e5-865f-001a4a81450b','LANGUAGE',NULL,5,'/swamp/store/SCATools/flake/flake8-py3-2.4.1.tar.gz','a5b81d53b01aef9549f2c0a55e81561fa8d20034c02ae1ca6bc84725a896c8a1d1fd498124eb4cb5c441b5459434b69b52c91329b79473c269140839bbafab2e','flake8','--verbose --exit-zero --format=pylint --output-file=${REPORTS_DIR}/report.txt','flake8-2.4.1','pschell@pschell.mirsam.or','2015-10-13 21:25:27',NULL,NULL);
INSERT INTO `specialized_tool_version` VALUES ('88be0c6b-7449-11e5-865f-001a4a81450b','7fbfa454-8f9f-11e4-829b-001a4a81450b','2a16b653-7449-11e5-865f-001a4a81450b','LANGUAGE',NULL,5,'/swamp/store/SCATools/bandit/bandit-py3-0.14.0-2.tar.gz','88bc97b259ea41630be509100a7e88e3495a846b3cec2257900dc716eefc9405de1538a22363e53082bcf43e105ea4fdcb40bc2e1b6d33b408ad9cef3350f1e3','bandit','--format json --output ${REPORTS_DIR}/report.json','bandit-py3-0.14.0','pschell@pschell.mirsam.or','2015-10-16 21:07:45','pschell@pschell.mirsam.or','2016-01-20 18:04:07');
INSERT INTO `specialized_tool_version` VALUES ('dab2f27b-71d7-11e5-865f-001a4a81450b','0f668fb0-4421-11e4-a4f3-001a4a81450b','c9126789-71d7-11e5-865f-001a4a81450b','LANGUAGE',NULL,4,'/swamp/store/SCATools/pylint/pylint-py2-1.4.4.tar.gz','c4528e3c77cd255ae702821758560ea3f16344d745648e4bcb6cc10d9d3c3f41950bf88d5d5ed3b524b600609303a3633b28f0933ccd9b517026652bcc510f45','pylint','-f parseable --disable=C --disable=R','pylint-py2-1.4.4','pschell@pschell.mirsam.or','2015-10-13 21:25:49',NULL,NULL);
INSERT INTO `specialized_tool_version` VALUES ('e4fb2c6f-71d7-11e5-865f-001a4a81450b','0f668fb0-4421-11e4-a4f3-001a4a81450b','c9126789-71d7-11e5-865f-001a4a81450b','LANGUAGE',NULL,5,'/swamp/store/SCATools/pylint/pylint-py3-1.4.4.tar.gz','e26116f78b93cbfb16cab02a2779808b51d91587abb98cd56677eda6fc01d405e62c976cb00b43d3b3dd350b465fc8d4c8a247e3b977d7fe857190a841075929','pylint','-f parseable --disable=C --disable=R','pylint-py3-1.4.4','pschell@pschell.mirsam.or','2015-10-13 21:25:49',NULL,NULL);
INSERT INTO `specialized_tool_version` VALUES ('eccdd194-480a-11e4-a4f3-001a4a81450b','0f668fb0-4421-11e4-a4f3-001a4a81450b','142e9a79-4425-11e4-a4f3-001a4a81450b','LANGUAGE',NULL,5,'/swamp/store/SCATools/pylint/pylint-py3-1.3.1-2.tar.gz','052cd5949c76f2823046a9e9ec6669d958d1b273159ffa88968d6c37a6389eefb08afae76d44db509fa72f1d85328fd72d39aa9e17180e6e6cb62e9844fba930','pylint','-f parseable --disable=C --disable=R','pylint-py3-1.3.1',NULL,'2014-09-29 19:57:20','pschell@pschell.mirsam.or','2015-10-13 21:25:40');
UNLOCK TABLES;
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
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=latin1 COMMENT='Lists languages that each tool is capable of assessing';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `tool_language` WRITE;
INSERT INTO `tool_language` VALUES (19,'163d56a7-156e-11e3-a239-001a4a81450b','163fe1e7-156e-11e3-a239-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10');
INSERT INTO `tool_language` VALUES (20,'163d56a7-156e-11e3-a239-001a4a81450b','4c1ec754-cb53-11e3-8775-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10');
INSERT INTO `tool_language` VALUES (21,'163d56a7-156e-11e3-a239-001a4a81450b','163fe1e7-156e-11e3-a239-001a4a81450b',3,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10');
INSERT INTO `tool_language` VALUES (22,'163d56a7-156e-11e3-a239-001a4a81450b','4c1ec754-cb53-11e3-8775-001a4a81450b',3,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10');
INSERT INTO `tool_language` VALUES (23,'7A08B82D-3A3B-45CA-8644-105088741AF6','325CA868-0D19-4B00-B034-3786887541AA',1,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10');
INSERT INTO `tool_language` VALUES (24,'163f2b01-156e-11e3-a239-001a4a81450b','16414980-156e-11e3-a239-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10');
INSERT INTO `tool_language` VALUES (25,'163f2b01-156e-11e3-a239-001a4a81450b','a2d949ef-cb53-11e3-8775-001a4a81450b',2,'pschell@pschell.mirsam.org','2014-04-25 16:37:10','pschell@pschell.mirsam.org','2014-04-25 16:37:10');
INSERT INTO `tool_language` VALUES (26,'992A48A5-62EC-4EE9-8429-45BB94275A41','09449DE5-8E63-44EA-8396-23C64525D57C',2,'root@localhost','2014-05-15 06:22:40','pschell@pschell.mirsam.org','2014-05-19 19:33:31');
INSERT INTO `tool_language` VALUES (27,'56872C2E-1D78-4DB0-B976-83ACF5424C52','5230FE76-E658-4B3A-AD40-7D55F7A21955',2,'root@localhost','2014-05-15 06:22:40',NULL,NULL);
INSERT INTO `tool_language` VALUES (30,'f212557c-3050-11e3-9a3e-001a4a81450b','8ec206ff-f59b-11e3-8775-001a4a81450b',1,'pschell@pschell.mirsam.org','2014-06-23 11:46:41',NULL,NULL);
INSERT INTO `tool_language` VALUES (31,'163e5d8c-156e-11e3-a239-001a4a81450b','950734d0-f59b-11e3-8775-001a4a81450b',1,'pschell@pschell.mirsam.org','2014-06-23 11:46:41',NULL,NULL);
INSERT INTO `tool_language` VALUES (36,'0f668fb0-4421-11e4-a4f3-001a4a81450b','142e9a79-4425-11e4-a4f3-001a4a81450b',4,'root@localhost','2014-09-29 19:57:20',NULL,NULL);
INSERT INTO `tool_language` VALUES (38,'0f668fb0-4421-11e4-a4f3-001a4a81450b','142e9a79-4425-11e4-a4f3-001a4a81450b',5,'pschell@pschell.mirsam.org','2014-09-29 20:40:43',NULL,NULL);
INSERT INTO `tool_language` VALUES (44,'7fbfa454-8f9f-11e4-829b-001a4a81450b','9cbd0e60-8f9f-11e4-829b-001a4a81450b',4,'pschell@pschell.mirsam.org','2014-12-29 21:54:29',NULL,NULL);
INSERT INTO `tool_language` VALUES (45,'163d56a7-156e-11e3-a239-001a4a81450b','163fe1e7-156e-11e3-a239-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL);
INSERT INTO `tool_language` VALUES (46,'163d56a7-156e-11e3-a239-001a4a81450b','4c1ec754-cb53-11e3-8775-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL);
INSERT INTO `tool_language` VALUES (47,'163f2b01-156e-11e3-a239-001a4a81450b','16414980-156e-11e3-a239-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL);
INSERT INTO `tool_language` VALUES (48,'163f2b01-156e-11e3-a239-001a4a81450b','a2d949ef-cb53-11e3-8775-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL);
INSERT INTO `tool_language` VALUES (49,'992A48A5-62EC-4EE9-8429-45BB94275A41','09449DE5-8E63-44EA-8396-23C64525D57C',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL);
INSERT INTO `tool_language` VALUES (50,'56872C2E-1D78-4DB0-B976-83ACF5424C52','5230FE76-E658-4B3A-AD40-7D55F7A21955',6,'pschell@pschell.mirsam.org','2015-01-14 21:04:55',NULL,NULL);
INSERT INTO `tool_language` VALUES (52,'63695cd8-a73e-11e4-a335-001a4a81450b','fe360cd7-a7e3-11e4-a335-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-01-30 18:23:23',NULL,NULL);
INSERT INTO `tool_language` VALUES (53,'63695cd8-a73e-11e4-a335-001a4a81450b','fe360cd7-a7e3-11e4-a335-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-01-30 18:23:23',NULL,NULL);
INSERT INTO `tool_language` VALUES (54,'992A48A5-62EC-4EE9-8429-45BB94275A41','0667d30a-a7f0-11e4-a335-001a4a81450b',2,'pschell@pschell.mirsam.org','2015-01-30 18:23:43',NULL,NULL);
INSERT INTO `tool_language` VALUES (55,'992A48A5-62EC-4EE9-8429-45BB94275A41','0667d30a-a7f0-11e4-a335-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-30 18:23:43',NULL,NULL);
INSERT INTO `tool_language` VALUES (56,'163d56a7-156e-11e3-a239-001a4a81450b','27ea7f63-a813-11e4-a335-001a4a81450b',2,'pschell@pschell.mirsam.org','2015-01-30 18:23:57',NULL,NULL);
INSERT INTO `tool_language` VALUES (57,'163d56a7-156e-11e3-a239-001a4a81450b','27ea7f63-a813-11e4-a335-001a4a81450b',3,'pschell@pschell.mirsam.org','2015-01-30 18:23:57',NULL,NULL);
INSERT INTO `tool_language` VALUES (58,'163d56a7-156e-11e3-a239-001a4a81450b','27ea7f63-a813-11e4-a335-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-30 18:23:57',NULL,NULL);
INSERT INTO `tool_language` VALUES (59,'163f2b01-156e-11e3-a239-001a4a81450b','bdaf4b93-a811-11e4-a335-001a4a81450b',2,'pschell@pschell.mirsam.org','2015-01-30 18:24:10',NULL,NULL);
INSERT INTO `tool_language` VALUES (60,'163f2b01-156e-11e3-a239-001a4a81450b','bdaf4b93-a811-11e4-a335-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-01-30 18:24:10',NULL,NULL);
INSERT INTO `tool_language` VALUES (63,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-06-02 16:47:24',NULL,NULL);
INSERT INTO `tool_language` VALUES (64,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-06-02 16:51:13',NULL,NULL);
INSERT INTO `tool_language` VALUES (65,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-07-01 06:58:50',NULL,NULL);
INSERT INTO `tool_language` VALUES (67,'5cd726a5-4053-11e5-83f1-001a4a81450b','6b06aaa6-4053-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-17 17:48:40',NULL,NULL);
INSERT INTO `tool_language` VALUES (68,'b9560648-4057-11e5-83f1-001a4a81450b','ca1608e1-4057-11e5-83f1-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-17 17:48:59',NULL,NULL);
INSERT INTO `tool_language` VALUES (69,'b9560648-4057-11e5-83f1-001a4a81450b','ca1608e1-4057-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-17 17:48:59',NULL,NULL);
INSERT INTO `tool_language` VALUES (70,'b9560648-4057-11e5-83f1-001a4a81450b','ca1608e1-4057-11e5-83f1-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-17 17:48:59',NULL,NULL);
INSERT INTO `tool_language` VALUES (71,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL);
INSERT INTO `tool_language` VALUES (72,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL);
INSERT INTO `tool_language` VALUES (73,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','f5c26a51-0935-11e5-b6a7-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL);
INSERT INTO `tool_language` VALUES (74,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL);
INSERT INTO `tool_language` VALUES (75,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL);
INSERT INTO `tool_language` VALUES (76,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL);
INSERT INTO `tool_language` VALUES (77,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','ea1f9693-46ac-11e5-83f1-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-19 21:48:42',NULL,NULL);
INSERT INTO `tool_language` VALUES (78,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-26 17:17:04',NULL,NULL);
INSERT INTO `tool_language` VALUES (79,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-26 17:17:04',NULL,NULL);
INSERT INTO `tool_language` VALUES (80,'8157e489-1fbc-11e5-b6a7-001a4a81450b','bcbfc7d7-1fbc-11e5-b6a7-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-26 17:17:04',NULL,NULL);
INSERT INTO `tool_language` VALUES (81,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',7,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL);
INSERT INTO `tool_language` VALUES (82,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL);
INSERT INTO `tool_language` VALUES (83,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL);
INSERT INTO `tool_language` VALUES (84,'8157e489-1fbc-11e5-b6a7-001a4a81450b','7059b296-4c14-11e5-83f1-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-26 17:22:57',NULL,NULL);
INSERT INTO `tool_language` VALUES (87,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',8,'pschell@pschell.mirsam.org','2015-08-27 18:50:37',NULL,NULL);
INSERT INTO `tool_language` VALUES (88,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',9,'pschell@pschell.mirsam.org','2015-08-27 18:51:14',NULL,NULL);
INSERT INTO `tool_language` VALUES (89,'59612f24-0946-11e5-b6a7-001a4a81450b','6b5624a0-0946-11e5-b6a7-001a4a81450b',10,'pschell@pschell.mirsam.org','2015-08-27 18:51:14',NULL,NULL);
INSERT INTO `tool_language` VALUES (91,'9289b560-8f8b-11e4-829b-001a4a81450b','dcbdab3c-4d8b-11e5-83f1-001a4a81450b',6,'pschell@pschell.mirsam.org','2015-09-02 20:49:50',NULL,NULL);
INSERT INTO `tool_language` VALUES (92,'63695cd8-a73e-11e4-a335-001a4a81450b','1ad625bd-71d5-11e5-865f-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-10-13 21:25:27',NULL,NULL);
INSERT INTO `tool_language` VALUES (93,'63695cd8-a73e-11e4-a335-001a4a81450b','1ad625bd-71d5-11e5-865f-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-10-13 21:25:27',NULL,NULL);
INSERT INTO `tool_language` VALUES (94,'0f668fb0-4421-11e4-a4f3-001a4a81450b','c9126789-71d7-11e5-865f-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-10-13 21:25:49',NULL,NULL);
INSERT INTO `tool_language` VALUES (95,'0f668fb0-4421-11e4-a4f3-001a4a81450b','c9126789-71d7-11e5-865f-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-10-13 21:25:49',NULL,NULL);
INSERT INTO `tool_language` VALUES (97,'7fbfa454-8f9f-11e4-829b-001a4a81450b','2a16b653-7449-11e5-865f-001a4a81450b',4,'pschell@pschell.mirsam.org','2015-10-16 21:07:45',NULL,NULL);
INSERT INTO `tool_language` VALUES (98,'7fbfa454-8f9f-11e4-829b-001a4a81450b','2a16b653-7449-11e5-865f-001a4a81450b',5,'pschell@pschell.mirsam.org','2015-10-16 21:07:45',NULL,NULL);
INSERT INTO `tool_language` VALUES (99,'f212557c-3050-11e3-9a3e-001a4a81450b','90554576-81a0-11e5-865f-001a4a81450b',1,'pschell@pschell.mirsam.org','2015-11-02 21:32:33',NULL,NULL);
INSERT INTO `tool_language` VALUES (100,'163e5d8c-156e-11e3-a239-001a4a81450b','e9cea65f-833e-11e5-865f-001a4a81450b',1,'pschell@pschell.mirsam.org','2015-11-04 22:04:44',NULL,NULL);
INSERT INTO `tool_language` VALUES (101,'738b81f0-a828-11e5-865f-001a4a81450b','8666e176-a828-11e5-865f-001a4a81450b',11,'pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_language` VALUES (102,'163e5d8c-156e-11e3-a239-001a4a81450b','7b504c42-bf06-11e5-832a-001a4a81450b',1,'pschell@pschell.mirsam.org','2016-01-20 18:04:17',NULL,NULL);
INSERT INTO `tool_language` VALUES (103,'163e5d8c-156e-11e3-a239-001a4a81450b','1c9a1589-bf05-11e5-832a-001a4a81450b',1,'pschell@pschell.mirsam.org','2016-01-20 18:04:27',NULL,NULL);
INSERT INTO `tool_language` VALUES (111,'992A48A5-62EC-4EE9-8429-45BB94275A41','b5115bdd-e095-11e5-ae56-001a4a81450b',2,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (112,'992A48A5-62EC-4EE9-8429-45BB94275A41','b5115bdd-e095-11e5-ae56-001a4a81450b',6,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (113,'56872C2E-1D78-4DB0-B976-83ACF5424C52','4fcb04a8-e096-11e5-ae56-001a4a81450b',2,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (114,'56872C2E-1D78-4DB0-B976-83ACF5424C52','4fcb04a8-e096-11e5-ae56-001a4a81450b',6,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (115,'163d56a7-156e-11e3-a239-001a4a81450b','9c48c4ad-e098-11e5-ae56-001a4a81450b',2,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (116,'163d56a7-156e-11e3-a239-001a4a81450b','9c48c4ad-e098-11e5-ae56-001a4a81450b',3,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (117,'163d56a7-156e-11e3-a239-001a4a81450b','9c48c4ad-e098-11e5-ae56-001a4a81450b',6,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (118,'163f2b01-156e-11e3-a239-001a4a81450b','04be7ddc-e099-11e5-ae56-001a4a81450b',2,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
INSERT INTO `tool_language` VALUES (119,'163f2b01-156e-11e3-a239-001a4a81450b','04be7ddc-e099-11e5-ae56-001a4a81450b',6,'pschell@pschell.mirsam.org','2016-03-02 17:27:22',NULL,NULL);
UNLOCK TABLES;
DROP TABLE IF EXISTS `tool_platform`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tool_platform` (
  `tool_platform_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'internal id',
  `tool_uuid` varchar(45) DEFAULT NULL COMMENT 'tool uuid',
  `platform_uuid` varchar(45) DEFAULT NULL COMMENT 'platform uuid',
  `create_user` varchar(50) DEFAULT NULL COMMENT 'db user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(50) DEFAULT NULL COMMENT 'db user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last updated',
  PRIMARY KEY (`tool_platform_id`),
  KEY `fk_tool_platform_t` (`tool_uuid`),
  KEY `fk_tool_platform_p` (`platform_uuid`),
  CONSTRAINT `fk_tool_platform_p` FOREIGN KEY (`platform_uuid`) REFERENCES `platform_store`.`platform` (`platform_uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tool_platform_t` FOREIGN KEY (`tool_uuid`) REFERENCES `tool` (`tool_uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=latin1 COMMENT='Lists tool platform compatibilities';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `tool_platform` WRITE;
INSERT INTO `tool_platform` VALUES (1,'163e5d8c-156e-11e3-a239-001a4a81450b','1088c3ce-20aa-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (2,'163e5d8c-156e-11e3-a239-001a4a81450b','8a51ecea-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (3,'163e5d8c-156e-11e3-a239-001a4a81450b','a4f024eb-f317-11e3-8775-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (4,'163e5d8c-156e-11e3-a239-001a4a81450b','d531f0f0-f273-11e3-8775-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (5,'163e5d8c-156e-11e3-a239-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (6,'163e5d8c-156e-11e3-a239-001a4a81450b','ee2c1193-209b-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (7,'163e5d8c-156e-11e3-a239-001a4a81450b','fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (15,'7A08B82D-3A3B-45CA-8644-105088741AF6','1088c3ce-20aa-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (16,'7A08B82D-3A3B-45CA-8644-105088741AF6','8a51ecea-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (17,'7A08B82D-3A3B-45CA-8644-105088741AF6','a4f024eb-f317-11e3-8775-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (18,'7A08B82D-3A3B-45CA-8644-105088741AF6','d531f0f0-f273-11e3-8775-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (19,'7A08B82D-3A3B-45CA-8644-105088741AF6','d95fcb5f-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (20,'7A08B82D-3A3B-45CA-8644-105088741AF6','ee2c1193-209b-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (21,'7A08B82D-3A3B-45CA-8644-105088741AF6','fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (22,'f212557c-3050-11e3-9a3e-001a4a81450b','1088c3ce-20aa-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (23,'f212557c-3050-11e3-9a3e-001a4a81450b','8a51ecea-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (24,'f212557c-3050-11e3-9a3e-001a4a81450b','a4f024eb-f317-11e3-8775-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (25,'f212557c-3050-11e3-9a3e-001a4a81450b','d531f0f0-f273-11e3-8775-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (26,'f212557c-3050-11e3-9a3e-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (27,'f212557c-3050-11e3-9a3e-001a4a81450b','ee2c1193-209b-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (28,'f212557c-3050-11e3-9a3e-001a4a81450b','fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (29,'163d56a7-156e-11e3-a239-001a4a81450b','fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (30,'163f2b01-156e-11e3-a239-001a4a81450b','fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (31,'56872C2E-1D78-4DB0-B976-83ACF5424C52','fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (33,'992A48A5-62EC-4EE9-8429-45BB94275A41','fc55810b-09d7-11e3-a239-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (34,'0f668fb0-4421-11e4-a4f3-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (35,'63695cd8-a73e-11e4-a335-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (36,'7fbfa454-8f9f-11e4-829b-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (37,'9289b560-8f8b-11e4-829b-001a4a81450b','48f9a9b0-976f-11e4-829b-001a4a81450b',NULL,'2015-02-28 07:28:12',NULL,NULL);
INSERT INTO `tool_platform` VALUES (45,'163d56a7-156e-11e3-a239-001a4a81450b','48f9a9b0-976f-11e4-829b-001a4a81450b','pschell@pschell.mirsam.org','2015-03-03 17:31:03',NULL,NULL);
INSERT INTO `tool_platform` VALUES (46,'163f2b01-156e-11e3-a239-001a4a81450b','48f9a9b0-976f-11e4-829b-001a4a81450b','pschell@pschell.mirsam.org','2015-03-03 17:31:03',NULL,NULL);
INSERT INTO `tool_platform` VALUES (47,'56872C2E-1D78-4DB0-B976-83ACF5424C52','48f9a9b0-976f-11e4-829b-001a4a81450b','pschell@pschell.mirsam.org','2015-03-03 17:31:03',NULL,NULL);
INSERT INTO `tool_platform` VALUES (49,'992A48A5-62EC-4EE9-8429-45BB94275A41','48f9a9b0-976f-11e4-829b-001a4a81450b','pschell@pschell.mirsam.org','2015-03-03 17:31:03',NULL,NULL);
INSERT INTO `tool_platform` VALUES (65,'ebcab7f6-0935-11e5-b6a7-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-06-02 21:21:56',NULL,NULL);
INSERT INTO `tool_platform` VALUES (66,'59612f24-0946-11e5-b6a7-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-06-02 21:22:38',NULL,NULL);
INSERT INTO `tool_platform` VALUES (67,'8157e489-1fbc-11e5-b6a7-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-07-01 06:58:50',NULL,NULL);
INSERT INTO `tool_platform` VALUES (68,'5cd726a5-4053-11e5-83f1-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-08-17 17:48:42',NULL,NULL);
INSERT INTO `tool_platform` VALUES (69,'b9560648-4057-11e5-83f1-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-08-17 17:48:59',NULL,NULL);
INSERT INTO `tool_platform` VALUES (84,'738b81f0-a828-11e5-865f-001a4a81450b','48f9a9b0-976f-11e4-829b-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_platform` VALUES (85,'738b81f0-a828-11e5-865f-001a4a81450b','ee2c1193-209b-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_platform` VALUES (86,'738b81f0-a828-11e5-865f-001a4a81450b','8a51ecea-209d-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_platform` VALUES (87,'738b81f0-a828-11e5-865f-001a4a81450b','d531f0f0-f273-11e3-8775-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_platform` VALUES (88,'738b81f0-a828-11e5-865f-001a4a81450b','fc55810b-09d7-11e3-a239-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_platform` VALUES (89,'738b81f0-a828-11e5-865f-001a4a81450b','a4f024eb-f317-11e3-8775-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_platform` VALUES (90,'738b81f0-a828-11e5-865f-001a4a81450b','d95fcb5f-209d-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
INSERT INTO `tool_platform` VALUES (91,'738b81f0-a828-11e5-865f-001a4a81450b','1088c3ce-20aa-11e3-9a3e-001a4a81450b','pschell@pschell.mirsam.org','2015-12-21 21:41:58',NULL,NULL);
UNLOCK TABLES;
DROP TABLE IF EXISTS `tool_viewer_incompatibility`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tool_viewer_incompatibility` (
  `tool_viewer_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'internal id',
  `tool_uuid` varchar(45) DEFAULT NULL COMMENT 'tool uuid',
  `viewer_uuid` varchar(45) DEFAULT NULL COMMENT 'viewer uuid',
  `create_user` varchar(50) DEFAULT NULL COMMENT 'db user that inserted record',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date record inserted',
  `update_user` varchar(50) DEFAULT NULL COMMENT 'db user that last updated record',
  `update_date` timestamp NULL DEFAULT NULL COMMENT 'date record last updated',
  PRIMARY KEY (`tool_viewer_id`),
  KEY `fk_tool_viewer_t` (`tool_uuid`),
  KEY `fk_tool_viewer_v` (`viewer_uuid`),
  CONSTRAINT `fk_tool_viewer_t` FOREIGN KEY (`tool_uuid`) REFERENCES `tool` (`tool_uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tool_viewer_v` FOREIGN KEY (`viewer_uuid`) REFERENCES `viewer_store`.`viewer` (`viewer_uuid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='Lists tool viewer incompatibilities';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `tool_viewer_incompatibility` WRITE;
INSERT INTO `tool_viewer_incompatibility` VALUES (1,'b9560648-4057-11e5-83f1-001a4a81450b','4221533e-865a-11e3-88bb-001a4a81450b',NULL,'2016-03-02 22:44:02',NULL,NULL);
INSERT INTO `tool_viewer_incompatibility` VALUES (2,'738b81f0-a828-11e5-865f-001a4a81450b','4221533e-865a-11e3-88bb-001a4a81450b',NULL,'2016-03-02 22:44:02',NULL,NULL);
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

