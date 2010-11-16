START TRANSACTION;

-- those city weather is stored in DB
CREATE TABLE IF NOT EXISTS cities (
  id int(11) unsigned NOT NULL,
  `name` varchar(32) NOT NULL,
  country varchar(32) DEFAULT NULL,
  metar char(4) DEFAULT NULL,
  `lat` decimal(9,6) NOT NULL,
  `lon` decimal(9,6) NOT NULL,
  `calculated_distance` int(12) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY idx_cities_lat_lon_uniq (lat,lon)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `weather_metar_archives` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  city_id int(11) unsigned NOT NULL,
  `created_at` decimal(11,0) NOT NULL, -- when metar was 1 processed
  `updated_ad` decimal(11,0) NOT NULL, -- when metar was updated
  `time_from` decimal(11,0) NOT NULL,
  `time_to` decimal(11,0) NOT NULL,
  `temperature` decimal(5,1) DEFAULT NULL,
  `wind` decimal(5,1) DEFAULT NULL,
  `pressure` decimal(6,0) DEFAULT NULL,
  `rain` decimal(5,1) DEFAULT NULL,
  `snow` decimal(5,1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY `idx_uniq_data` (`city_id`,`time_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `weather_archives` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` decimal(11,0) NOT NULL,
  `provider` varchar(32) COLLATE utf8_polish_ci NOT NULL,
  `city` varchar(48) COLLATE utf8_polish_ci NOT NULL,
  `lat` decimal(9,6) NOT NULL,
  `lon` decimal(9,6) NOT NULL,
  `time_from` decimal(11,0) NOT NULL,
  `time_to` decimal(11,0) NOT NULL,
  `temperature` decimal(5,1) DEFAULT NULL,
  `wind` decimal(5,1) DEFAULT NULL,
  `pressure` decimal(6,0) DEFAULT NULL,
  `rain` decimal(5,1) DEFAULT NULL,
  `snow` decimal(5,1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_uniq_data` (`provider`,`city`,`time_from`,`time_to`),
  KEY `city` (`city`),
  KEY `time_from` (`time_from`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1 ;

COMMIT;

--

START TRANSACTION;
insert into cities (id,name,metar,lat,lon) values (1,'Poznań','EPPO',52.421,16.8263);
insert into cities (id,name,metar,lat,lon) values (2,'Muenster/Osnabrueck','EDDG',52.1346,7.6848);
insert into cities (id,name,metar,lat,lon) values (3,'Petropavlovsk-Kamchatskij','UHPP',53.0833,158.5833);
insert into cities (id,name,metar,lat,lon) values (4,'Tokyo','RJTT',35.5523,139.7797);
insert into cities (id,name,metar,lat,lon) values (5,'Khabarovsk','UHHH',48.5167,135.1667);
insert into cities (id,name,metar,lat,lon) values (6,'Vancouver','CYVR',49.1939,-123.1844);
insert into cities (id,name,metar,lat,lon) values (7,'Portland','KPDX',45.5908,-122.6003);
insert into cities (id,name,metar,lat,lon) values (8,'New York','KNYC',40.779,-73.9692);
insert into cities (id,name,metar,lat,lon) values (9,'London','EGLL',51.470969,-0.45393);
insert into cities (id,name,metar,lat,lon) values (80,'Rome [USA]','KRMG',34.351458,-85.163326);
insert into cities (id,name,metar,lat,lon) values (10,'Dubai','OMDB',25.252971,55.364714);
insert into cities (id,name,metar,lat,lon) values (11,'Los Angeles','KLAX',33.946251,-118.408442);
insert into cities (id,name,metar,lat,lon) values (12,'Cairo','HECA',30.111448,31.4139);
insert into cities (id,name,metar,lat,lon) values (13,'Warszawa','EPWA',52.164909,20.964117);
insert into cities (id,name,metar,lat,lon) values (14,'Katowice','EPKT',50.241968,19.032927);
insert into cities (id,name,metar,lat,lon) values (15,'Kraków','EPKK',50.0777,19.7848);
insert into cities (id,name,metar,lat,lon) values (16,'Hailuoto [Finland]','EFHL',65.096198,24.733886);
insert into cities (id,name,metar,lat,lon) values (17,'Ivolo [Finland]','EFIV',68.674941,27.572021);
insert into cities (id,name,metar,lat,lon) values (18,'Cape Tobin [Greenland]','BGKT',70.40016,-21.966662);
insert into cities (id,name,metar,lat,lon) values (19,'Godhavn [Greenland]','BGGN',69.253425,-53.505249);
insert into cities (id,name,metar,lat,lon) values (20,'Auckland [New Zealand]','NZAA',-37.005058,174.784025);
insert into cities (id,name,metar,lat,lon) values (21,'Laayoune/hassan Isl [Morocco]','GMML',27.1667,-13.2167);
insert into cities (id,name,metar,lat,lon) values (22,'Honolulu [Hawaii]','PHNL',21.333065,-157.918282);
insert into cities (id,name,metar,lat,lon) values (23,'Amundsen-Scott [Antarctica]','NZSP',-89.983333,179.983333);
insert into cities (id,name,metar,lat,lon) values (24,'Williams Field [Antarctica]','NZCM',-77.866667,166.966667);
insert into cities (id,name,metar,lat,lon) values (25,'Williams Field 2 [Antarctica]','NZWD',-77.8674,167.0566);
insert into cities (id,name,metar,lat,lon) values (26,'Ice Runway [Antarctica]','NZIR',-77.8521,166.5692);
insert into cities (id,name,metar,lat,lon) values (27,'Pegasus Field [Antarctica]','NZPG',-77.9634,166.5246);
insert into cities (id,name,metar,lat,lon) values (28,'Arctic Bay [Canada]','CXAT',73.0,-85.0167);
insert into cities (id,name,metar,lat,lon) values (29,'Qaanaaq [Greenland]','BGQQ',77.4667,-69.2167);
insert into cities (id,name,metar,lat,lon) values (30,'Alert Airport [Greenland]','CYLR',82.5178,-62.2806);
insert into cities (id,name,metar,lat,lon) values (31,'Alert [Greenland]','CZLT',82.5,-62.3333);
insert into cities (id,name,metar,lat,lon) values (32,'Grise Fiord [Greenland]','CWGZ',76.4228,-82.9022);
insert into cities (id,name,metar,lat,lon) values (33,'Eureka [Greenland]','CWEU',79.9833,-85.9333);
insert into cities (id,name,metar,lat,lon) values (34,'Sharjah International [UAE]','OMSJ',25.3286,55.5172);
insert into cities (id,name,metar,lat,lon) values (35,'Jakarta [Java]','WIID',-6.15,106.85);
insert into cities (id,name,metar,lat,lon) values (36,'Maradi [Niger]','DRRM',13.4667,7.0833);
insert into cities (id,name,metar,lat,lon) values (37,'Isla De Pascua','SCIP',-27.1648,-109.4218);
insert into cities (id,name,metar,lat,lon) values (38,'Porto Velho [Brazil]','SBPV',-8.7667,-63.9167);
insert into cities (id,name,metar,lat,lon) values (39,'Kathmandu [Nepal]','VNKT',27.6966,85.3591);
insert into cities (id,name,metar,lat,lon) values (40,'London Stansted','EGSS',51.885,0.235);
insert into cities (id,name,metar,lat,lon) values (41,'Southend-On-Sea','EGMC',51.5714,0.6956);
insert into cities (id,name,metar,lat,lon) values (42,'Helsinki-vantaa [Finland]','EFHK',60.3172,24.9633);
insert into cities (id,name,metar,lat,lon) values (43,'Enontekio','EFET',68.3626,23.4243);
insert into cities (id,name,metar,lat,lon) values (44,'Kittila [Finland]','EFKT',67.701,24.8468);
insert into cities (id,name,metar,lat,lon) values (45,'Oulu [Finland]','EFOU',64.9301,25.3546);
insert into cities (id,name,metar,lat,lon) values (46,'Khatanga [Russia]','UOHH',71.9833,102.4667);
insert into cities (id,name,metar,lat,lon) values (47,'Saskylakh [Russia]','UERS',71.9667,114.0833);
insert into cities (id,name,metar,lat,lon) values (48,'Alykel [Russia]','UOOO',69.3111,87.3322);
insert into cities (id,name,metar,lat,lon) values (49,'Tiksi [Russia]','UEST',71.5833,128.9167);
insert into cities (id,name,metar,lat,lon) values (50,'St. Peterburg [Russia]','ULLI',59.9667,30.3);
insert into cities (id,name,metar,lat,lon) values (51,'Pago Pago [Samoa]','NSTU',-14.331,-170.7105);
insert into cities (id,name,metar,lat,lon) values (52,'Honiara [Solomon Islands]','NSTU',-9.428,160.0548);
insert into cities (id,name,metar,lat,lon) values (53,'Luhansk [Ukraine]','UKCW',48.4174,39.3741);
insert into cities (id,name,metar,lat,lon) values (54,'Sanaa [Yemen]','VNPK',15.5167,44.1833);
insert into cities (id,name,metar,lat,lon) values (55,'Maseru [Lesotho]','FXMU',-29.4623,27.5525);
insert into cities (id,name,metar,lat,lon) values (56,'Grootfontein [Namibia]','FXMM',-19.6022,18.1227);
insert into cities (id,name,metar,lat,lon) values (57,'Tamatave [Madagascar]','FYGF',-18.1095,49.3925);
insert into cities (id,name,metar,lat,lon) values (58,'S. Tome','FPPR',0.3782,6.7122);
insert into cities (id,name,metar,lat,lon) values (59,'Plaisance Mauritius','FIMP',-20.4302,57.6836);
insert into cities (id,name,metar,lat,lon) values (60,'Bujumbura [Burundi]','HBBA',-3.324,29.3185);
insert into cities (id,name,metar,lat,lon) values (61,'S. Pedro [Cape Verde]','GVSV',16.8332,-25.0555);
insert into cities (id,name,metar,lat,lon) values (62,'Samedan [Switzerland]','LSZS',46.5341,9.8841);
insert into cities (id,name,metar,lat,lon) values (63,'Ercan [Cyprus]','LSZS',35.1489,33.4997);
insert into cities (id,name,metar,lat,lon) values (64,'Stockholm','ESCM',59.6167,17.95);
insert into cities (id,name,metar,lat,lon) values (65,'Bydgoszcz','EPBY',53.0968,17.9777);
insert into cities (id,name,metar,lat,lon) values (66,'Svalbard Lufthavn [Norway]','ENBJ',78.2461,15.4656);
insert into cities (id,name,metar,lat,lon) values (67,'Bardufoss [Norway]','ENDU',69.0558,18.5404);
insert into cities (id,name,metar,lat,lon) values (68,'Heidrun [Norway]','ENHE',65.33,2.33);
insert into cities (id,name,metar,lat,lon) values (69,'Hammerfest [Norway]','ENHF',70.6797,23.6686);
insert into cities (id,name,metar,lat,lon) values (70,'Honningsvag [Norway]','ENHV',71.0167,25.9833);
insert into cities (id,name,metar,lat,lon) values (71,'Kirkenes Lufthavn [Norway]','ENKR',69.7258,29.8913);
insert into cities (id,name,metar,lat,lon) values (72,'D15-fa-1 [Netherlands]','EHDV',54.3167,2.9333);
insert into cities (id,name,metar,lat,lon) values (73,'K14-fa-1c [Netherlands]','EHKV',53.2667,3.6333);
insert into cities (id,name,metar,lat,lon) values (74,'Sumburgh Cape [UK]','EGPB',59.8789,-1.2956);
insert into cities (id,name,metar,lat,lon) values (75,'Kardla [Estonia]','EEKA',58.9908,22.8307);
insert into cities (id,name,metar,lat,lon) values (76,'Akureyri [Iceland]','BIAR',65.6856,-18.1002);
insert into cities (id,name,metar,lat,lon) values (77,'Mount Pleasant [Falkland Islands]','EGYP',-51.8228,-58.4472);
insert into cities (id,name,metar,lat,lon) values (78,'E. T. Joshua Airport','TVSV',13.1435,-61.2124);
insert into cities (id,name,metar,lat,lon) values (79,'Wake Island','PWAK',19.2821,166.6364);
COMMIT;


-- TODO: funkcja do obliczania odleglosci
--

