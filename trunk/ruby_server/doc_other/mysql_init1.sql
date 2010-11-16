START TRANSACTION;

-- those city weather is stored in DB
CREATE TABLE IF NOT EXISTS cities (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  country varchar(32) DEFAULT NULL,
  metar char(4) DEFAULT NULL,
  `lat` decimal(9,6) NOT NULL,
  `lon` decimal(9,6) NOT NULL,
  `calculated_distance` int(12) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY idx_cities_lat_lon_uniq (lat,lon)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;

-- not processed metars
CREATE TABLE IF NOT EXISTS raw_metars (
  id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  city_id int(11) unsigned NOT NULL,
  raw_metar varchar(255) NOT NULL,
  `year` int(10) NOT NULL, -- when fetched
  `month` smallint NOT NULL, -- when fetched
  PRIMARY KEY (`id`),
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY idx_raw_metars_uniq(`raw_metar`, `year`, `month`)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `weather_metar_archives` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  raw_metar_id bigint(20) unsigned NOT NULL,
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
  FOREIGN KEY (raw_metar_id) REFERENCES raw_metars(id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `idx_uniq_data` (`city_id`,`time_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;

-- processed metars
CREATE TABLE IF NOT EXISTS processed_metars (
  id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  weather_metar_archive_id bigint(20) unsigned NOT NULL,
  city_id int(11) unsigned NOT NULL,
  raw_metar varchar(255) NOT NULL,
  `year` int(10) NOT NULL, -- when fetched
  `month` smallint NOT NULL, -- when fetched
  PRIMARY KEY (`id`),
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (weather_metar_archive_id) REFERENCES weather_metar_archives(id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY idx_raw_metars_uniq(raw_metar,`year`,`month`)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;

-- not processed metars
CREATE TABLE IF NOT EXISTS additional_metar_informations (
  id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  weather_metar_archive_id bigint(20) unsigned NOT NULL,
  city_id int(11) unsigned NOT NULL,
  precipitation_raw varchar(6) DEFAULT NULL,
  obscuration_raw varchar(6) DEFAULT NULL,
  misc_raw varchar(6) DEFAULT NULL,
  intensity_raw varchar(6) DEFAULT NULL,
  descriptor_raw varchar(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (weather_metar_archive_id) REFERENCES weather_metar_archives(id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY idx_raw_metars_uniq(raw_metar,`year`,`month`)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;

COMMIT;

-- then insert cities from 'metar_generate_insert_cities'

BEGIN TRANSACTION;
INSERT INTO raw_metars (city_id,raw_metar,`year`,`month`)
VALUES (
 (SELECT id FROM cities where metar = 'EPPO'),
 'EPPO 151600Z 32004KT CAVOK 10/06 Q1014',
 2010,
 11 );

INSERT INTO weather_metar_archives (raw_metar_id, city_id)
VALUES (
 (SELECT id FROM raw_metars where raw_metar = 'EPPO 151600Z 32004KT CAVOK 10/06 Q1014'),
 (SELECT id FROM cities where metar = 'EPPO'),
)

  (20) unsigned NOT NULL,
   int(11) unsigned NOT NULL,
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
  FOREIGN KEY (raw_metar_id) REFERENCES raw_metars(id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `idx_uniq_data` (`city_id`,`time_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1;



COMMIT;



-- table_name, created_at, city_id, time_from, time_to, temperature, wind_metps, pressure, rain, snow
PREPARE insert_metar FROM "
INSERT INTO ?(
`created_at` ,
`city_id` ,
`time_from` ,
`time_to` ,
`temperature` ,
`wind` ,
`pressure` ,
`rain` ,
`snow`
)
VALUES (
 ?, ?,
 ?, ?,
 ?, ?, ?, ?, ?
);"
"