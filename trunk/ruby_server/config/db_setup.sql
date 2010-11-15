-- standard version
CREATE TABLE IF NOT EXISTS `meas_archives` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(16) NOT NULL,
  `time_from` decimal(14,3) NOT NULL,
  `time_to` decimal(14,3) NOT NULL,
  `value` double NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- future version
DROP TABLE IF EXISTS `meas_types`;
CREATE TABLE IF NOT EXISTS `meas_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(16) NOT NULL
  PRIMARY KEY (`id`),
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

DROP TABLE IF EXISTS `meas_archives`;
CREATE TABLE IF NOT EXISTS `meas_archives` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `meas_type_id` int unsigned NOT NULL, -- zmienic na bajt
  `time_from` decimal(14,3) NOT NULL,
  `time_to` decimal(14,3) NOT NULL,
  `value` double NOT NULL,
  PRIMARY KEY (`id`),
	FOREIGN KEY (`meas_type_id`) REFERENCES `meas_types`(`id`) ON DELETE RESTRICT ON UPDATE CASDADE,
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
