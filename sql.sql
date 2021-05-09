CREATE TABLE `pajak_kendaraan` (
	`owner` VARCHAR(60) NOT NULL,
	`plate` VARCHAR(12) NOT NULL,
	`vehicle` longtext,
	`type` VARCHAR(20) NOT NULL DEFAULT 'car',
	`job` VARCHAR(20) NULL DEFAULT 'civ',
	`stored` TINYINT NOT NULL DEFAULT '0',
	`pajak` INT(20) NOT NULL DEFAULT '0',

	PRIMARY KEY (`plate`)
);

ALTER TABLE `owned_vehicles`
  ADD `pajak` INT(20) NOT NULL DEFAULT '0'
;