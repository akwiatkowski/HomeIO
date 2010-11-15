CREATE TABLE IF NOT EXISTS `cities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `city` varchar(48) COLLATE utf8_polish_ci NOT NULL,
  `lat` decimal(9,6) NOT NULL,
  `lon` decimal(9,6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ind_cities_coord_uniq` (`lat`,`lon`),
  UNIQUE KEY `ind_cities_city_uniq` (`city`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci AUTO_INCREMENT=1 ;

ALTER TABLE weather_metar_archives ADD city_id int(10) unsigned not null;

ALTER TABLE weather_metar_archives
    ADD INDEX
    (city_id)


ALTER TABLE `weather_metar_archives`
    ADD FOREIGN KEY
    (`city_id`)
    REFERENCES `cities` (`id`)
    ON DELETE restrict
    ON UPDATE cascade
SHOW ENGINE INNODB STATUS

101107 10:04:37 Error in foreign key constraint of table wiatrak2/#sql-86b_11c:
FOREIGN KEY
   (`city_id`)
   REFERENCES `cities` (`id`)
   ON DELETE restrict
   ON UPDATE cascade:
Cannot resolve table name close to:
(`id`)
   ON DELETE restrict
   ON UPDATE cascade

-- INDEX (`city_id`),
-- foreign key (fk_test1) references test1(pk_alias)) type=innodb;


insert into cities(city,lat,lon)
select distinct city, lat, lon from weather_metar_archives

