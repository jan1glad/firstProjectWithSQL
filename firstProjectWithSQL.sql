-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 10, 2024 at 12:21 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `niewiem`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `aes` ()   BEGIN
START TRANSACTION;

select imie, AES_ENCRYPT(imie,222) as encription
from haslo 

COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cena > 10k` ()   BEGIN
SELECT * FROM zamowienia WHERE cena>10000;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete from modele` (IN `nazwa` VARCHAR(255))   BEGIN
START TRANSACTION;

DELETE FROM modele WHERE Model=nazwa;

COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `fail` (IN `ide` INT(55), IN `modelik` VARCHAR(55))   BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    START TRANSACTION;
    INSERT INTO `modele` (`id`,`model`) VALUES (ide,modelik);
    IF `_rollback` THEN
        SET
        @msg = 'An error SQL has occurred, the stored procedure was terminated' ; GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT ;
    SELECT
        @msg,
        @sqlstate,
        @errno,
        @text ;
        ROLLBACK;
    ELSE
    INSERT INTO `modele` (`id`,`model`) VALUES (ide,modelik);
    SELECT
    'Insert procedure has been executed.' ;
        COMMIT;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert into hasla` (IN `passwor` VARCHAR(255), IN `name` VARCHAR(255), IN `surname` VARCHAR(255))   BEGIN
START TRANSACTION;

INSERT INTO haslo(imie,pseud,pass)
VALUES(name,surname,md5(passwor));

COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertIntoModeleWithError` (IN `Identyfikator` INT, IN `Model` VARCHAR(255), IN `Rocznik` INT(4), IN `Typ` VARCHAR(255), IN `Paliwo` VARCHAR(20))   BEGIN
    DECLARE EXIT
HANDLER FOR SQLEXCEPTION
SELECT * From modele;
BEGIN

    SET
        @msg = 'An error SQL has occurred, the stored procedure was terminated' ; GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
        @errno = MYSQL_ERRNO,
        @text = MESSAGE_TEXT ;
    SELECT
        @msg,
        @sqlstate,
        @errno,
        @text ;
        ROLLBACK;
END ;
INSERT INTO modele(Identyfikator,Model,
    Rocznik,
    Typ,
    Paliwo
)
VALUES(Identyfikator,Model, Rocznik, Typ, Paliwo) ;
SELECT
    'Insert procedure has been executed.' ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertModeleTrans` (IN `tablica` VARCHAR(50), IN `inZamId` INT, IN `inProduct` VARCHAR(20))   BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
     	SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
  		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
    	SELECT @sqlstate, @errno, @text;
        --
		ROLLBACK;
     END;
     START TRANSACTION;
     
     -- insert a new row into the Zamówienia
     INSERT INTO modele (Identyfikator, Model) VALUES (inZamId , inProduct);
    
    SET @t1 = CONCAT('SELECT * FROM ', tablica);
    PREPARE statement FROM @t1;
    select @t1;
    EXECUTE statement;
    DEALLOCATE PREPARE statement;
    
    SELECT COUNT(*) INTO @v1
    FROM modele
    WHERE Identyfikator = inZamId; 
    select @v1;
    
    SET @msg = 'Transaction has been committed';
    SELECT @msg;
  
    COMMIT;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `klienci miasto na W lub G` ()   BEGIN
SELECT * FROM klienci WHERE miasto LIKE "W%" OR miasto LIKE "G%";
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `miasta_klientow cursor` (INOUT `miasto_list` VARCHAR(100))   BEGIN
    DECLARE is_end INTEGER DEFAULT 0; 
    DECLARE s_miasto VARCHAR(50) DEFAULT ""; 
    DECLARE miasto_cursor CURSOR FOR SELECT DISTINCT miasto FROM klienci; 
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1 ; 
    OPEN miasto_cursor; 
    get_list: LOOP 
    FETCH miasto_cursor INTO s_miasto; 
    IF is_end = 1 THEN 
    LEAVE get_list;
	END IF;
	SET miasto_list = CONCAT(s_miasto, " ; ", miasto_list);
    END LOOP get_list; 
    CLOSE miasto_cursor; 
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Wiecej niz 2 zamowienia` ()   SELECT Firma
  FROM zamowienia
 GROUP BY Firma
HAVING COUNT(Firma) > 2$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `zaliczenie` ()   BEGIN
ANALYZE FORMAT=JSON
SELECT * FROM zamowienia USE INDEX() WHERE cena>10000;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `zaliczenie2` ()   ANALYZE FORMAT=JSON
SELECT Firma
  FROM zamowienia USE INDEX()
 GROUP BY Firma
HAVING COUNT(Firma) > 2$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `zaliczenie3` ()   BEGIN
ANALYZE FORMAT=JSON
SELECT * FROM klienci USE INDEX() WHERE miasto LIKE "W%" OR miasto LIKE "G%";
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `Liczba zamowionych modeli` (`car` VARCHAR(50)) RETURNS INT(11)  BEGIN

DECLARE numCar INT(10) DEFAULT 0;

SELECT COUNT(Identyfikator) INTO numCar FROM zamowienia WHERE Model = car;

RETURN numCar;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Rodzaj Paliwa` (`gas` VARCHAR(50)) RETURNS INT(11)  BEGIN

DECLARE numGas INT(10) DEFAULT 0;

SELECT COUNT(Identyfikator) INTO numGas FROM zamowienia WHERE Paliwo = gas;

RETURN numGas;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Stan` (`type` VARCHAR(50)) RETURNS INT(11)  BEGIN

DECLARE numType INT(10) DEFAULT 0;

SELECT COUNT(Identyfikator) INTO numType FROM zamowienia WHERE Stan = type;

RETURN numType;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ceo`
--

CREATE TABLE `ceo` (
  `I_D` int(2) DEFAULT NULL,
  `Firma` varchar(16) NOT NULL,
  `Imie` varchar(7) DEFAULT NULL,
  `Nazwisko` varchar(7) DEFAULT NULL,
  `Telefon` varchar(20) DEFAULT NULL,
  `Email` varchar(34) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `ceo`
--

INSERT INTO `ceo` (`I_D`, `Firma`, `Imie`, `Nazwisko`, `Telefon`, `Email`) VALUES
(4, 'Acer Sp.z.o.o', 'Marcin', 'Chleb', '12(6279)184-63-1511', 'bretacrollouja-8190@yopmail.com'),
(12, 'Babka S.A.', 'Luis', 'Piec', '9(375)526-35-8148', 'crupeutrelommu-8371@yopmail.com'),
(13, 'CS SOURCE', 'Piotr', 'Rzylak', '005(690)947-48-9574', 'woiwoimeloupre-7045@yopmail.com'),
(1, 'Edge S.A.', 'Jan', 'Glad', '5(433)289-20-2789', 'deibrilokeufrou-9483@yopmail.com'),
(7, 'HDMI S.A.', 'Gunther', 'Fam', '587(6407)244-71-1467', 'quoucoprettauquoi-6370@yopmail.com'),
(5, 'Intel S.A.', 'Kylian', 'Mekambe', '2(66)377-01-9270', 'boprekijoipri-2443@yopmail.com'),
(10, 'Macintosh S.A.', 'Patrick', 'Stewart', '85(949)172-55-9543', 'dovedeibrawoi-4062@yopmail.com'),
(8, 'Morris Sp.z.o.o', 'Sophie', 'Semp', '22(4022)922-68-0487', 'botaqueiseke-4386@yopmail.com'),
(14, 'Muszynianka S.A.', 'Chris', 'Pys', '401(38)865-24-4349', 'leiroillequossoi-5949@yopmail.com'),
(6, 'Nvidia Sp.z.o.o.', 'Bartek', 'Chrust', '66(4685)328-58-9692', 'rifohojeime-1741@yopmail.com'),
(9, 'Philips S.A.', 'Alex', 'Polak', '843(97)082-66-6983', 'gusotuxesou-6421@yopmail.com'),
(11, 'Ropucha S.A.', 'Leo ', 'Messi', '075(65)357-03-3432', 'dagrezegageu-3627@yopmail.com'),
(3, 'Shift Enter S.A.', 'James', 'Milner', '69(0518)397-17-6312', 'preloditrifra-6393@yopmail.com'),
(2, 'Tracer S.A.', 'Tomasz', 'Bonk', '3(299)507-29-3925', 'quonaubizolou-4575@yopmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `haslo`
--

CREATE TABLE `haslo` (
  `id` int(11) NOT NULL,
  `imie` varchar(255) DEFAULT NULL,
  `pseud` varchar(255) DEFAULT NULL,
  `pass` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `haslo`
--

INSERT INTO `haslo` (`id`, `imie`, `pseud`, `pass`) VALUES
(1, 'jan', 'tom', '5e918bd6ee75772e5869569cd628d1fa'),
(2, 'Janusz', 'bom', 'maslo'),
(3, NULL, NULL, NULL),
(4, 'izabela', 'iza', 'tak'),
(5, NULL, NULL, NULL),
(6, 'jan', 'glad', '5db1a1c5b5f04a226780422e018219be');

-- --------------------------------------------------------

--
-- Table structure for table `klienci`
--

CREATE TABLE `klienci` (
  `id` int(2) NOT NULL,
  `nazwa` varchar(16) NOT NULL,
  `branza` varchar(11) DEFAULT NULL,
  `miasto` varchar(9) DEFAULT NULL,
  `ulica` varchar(12) DEFAULT NULL,
  `ilosc` int(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `klienci`
--

INSERT INTO `klienci` (`id`, `nazwa`, `branza`, `miasto`, `ulica`, `ilosc`) VALUES
(4, 'Acer Sp.z.o.o', 'Napoje', 'Warszawa', 'Abrahama 12', 122),
(12, 'Babka S.A.', 'Telefony', 'Suwalki', '', 62),
(13, 'CS SOURCE', 'Nakarska', 'Bialystok', 'Szklana 30', 32),
(1, 'Edge S.A.', 'Picie', 'Poznan', 'Mala 8', 77),
(7, 'HDMI S.A.', 'Jedzenie', 'Gdansk', 'Miejska 5', 59),
(5, 'Intel S.A.', 'Obuwie', 'Gdansk', 'Zielona 56', 47),
(10, 'Macintosh S.A.', 'Elektronika', 'Lodz', 'Biala 21', 52),
(8, 'Morris Sp.z.o.o', 'Budownictwo', 'Katowice', 'Wiejska 19', 92),
(14, 'Muszynianka S.A.', 'Wodna', 'Muszyna', '', 2),
(6, 'Nvidia Sp.z.o.o.', 'IT', 'Katowice', 'Czarna 3', 82),
(9, 'Philips S.A.', 'Elektronika', 'Poznan', 'Duza 18', 102),
(11, 'Ropucha S.A.', 'Spozywcza', 'Wroclaw', 'Miedziana 10', 222),
(3, 'Shift Enter S.A.', 'Obuwie', 'Lodz', 'Wspolna 4', 52),
(2, 'Tracer S.A.', 'Budownictwo', 'Krakow', 'Polna 13', 42);

-- --------------------------------------------------------

--
-- Table structure for table `modele`
--

CREATE TABLE `modele` (
  `Identyfikator` int(1) NOT NULL,
  `Model` varchar(255) NOT NULL,
  `Rocznik` int(4) DEFAULT NULL,
  `Typ` varchar(255) DEFAULT NULL,
  `Paliwo` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `modele`
--

INSERT INTO `modele` (`Identyfikator`, `Model`, `Rocznik`, `Typ`, `Paliwo`) VALUES
(1, 'Tiguan', 2019, 'SUV', 'Diesel'),
(2, 'Passat', 2021, 'Kombi', 'Benzyna'),
(3, 'Golf', 2020, 'Hatchback', 'Benzyna'),
(4, 'Polo', 2022, 'Kompakt', 'Benzyna'),
(5, 'Eos', 2017, 'Kabriolet', 'Diesel'),
(6, 'Compact', 2018, 'Sedan', 'Benzyna'),
(7, 'samolot', 2023, 'kompakt', 'Diesel');

-- --------------------------------------------------------

--
-- Stand-in structure for view `viewofceo`
-- (See below for the actual view)
--
CREATE TABLE `viewofceo` (
`Firma` varchar(16)
,`Imie` varchar(7)
,`Nazwisko` varchar(7)
,`Email` varchar(34)
,`branza` varchar(11)
,`miasto` varchar(9)
);

-- --------------------------------------------------------

--
-- Table structure for table `zamowienia`
--

CREATE TABLE `zamowienia` (
  `Identyfikator` int(2) NOT NULL,
  `Firma` varchar(16) DEFAULT NULL,
  `Model` varchar(7) DEFAULT NULL,
  `Stan` varchar(7) DEFAULT NULL,
  `Paliwo` varchar(7) DEFAULT NULL,
  `cena` decimal(11,2) DEFAULT NULL,
  `Nazwisko` varchar(7) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `zamowienia`
--

INSERT INTO `zamowienia` (`Identyfikator`, `Firma`, `Model`, `Stan`, `Paliwo`, `cena`, `Nazwisko`) VALUES
(1, 'Shift Enter S.A.', 'Eos', 'Nowy', 'Diesel', 12000.00, 'Milner'),
(2, 'Shift Enter S.A.', 'Passat', 'Nowy', 'Benzyna', 15000.00, 'Milner'),
(3, 'CS SOURCE', 'Polo', 'Nowy', 'Benzyna', 16000.00, 'Rzylak'),
(4, 'CS SOURCE', 'Compact', 'Uzywany', 'Benzyna', 8000.00, 'Rzylak'),
(5, 'Tracer S.A.', 'Tiguan', 'Uzywany', 'Diesel', 9000.00, 'Bonk'),
(6, 'Tracer S.A.', 'Passat', 'Uzywany', 'Benzyna', 8000.00, 'Bonk'),
(7, 'Edge S.A.', 'Golf', 'Nowy', 'Benzyna', 16000.00, 'Glad'),
(8, 'Edge S.A.', 'Eos', 'Nowy', 'Diesel', 20000.00, 'Glad'),
(9, 'Intel S.A.', 'Passat', 'Uzywany', 'Benzyna', 3000.00, 'Mekambe'),
(10, 'Intel S.A.', 'Golf', 'Uzywany', 'Benzyna', 5433.00, 'Mekambe'),
(11, 'Acer Sp.z.o.o', 'Compact', 'Uzywany', 'Benzyna', 7777.00, 'Chleb'),
(12, 'Acer Sp.z.o.o', 'Eos', 'Uzywany', 'Diesel', 9000.00, 'Chleb'),
(13, 'Philips S.A.', 'Passat', 'Nowy', 'Benzyna', 19000.00, 'Polak'),
(14, 'Philips S.A.', 'Polo', 'Uzywany', 'Benzyna', 5600.00, 'Polak'),
(15, 'Nvidia Sp.z.o.o.', 'Polo', 'Uzywany', 'Benzyna', 8000.00, 'Chrust'),
(16, 'Nvidia Sp.z.o.o.', 'Compact', 'Uzywany', 'Benzyna', 8700.00, 'Chrust'),
(17, 'Morris Sp.z.o.o', 'Golf', 'Uzywany', 'Benzyna', 9600.00, 'Semp'),
(18, 'Morris Sp.z.o.o', 'Eos', 'Nowy', 'Diesel', 12450.00, 'Semp'),
(19, 'HDMI S.A.', 'Tiguan', 'Uzywany', 'Diesel', 5600.00, 'Fam'),
(20, 'HDMI S.A.', 'Eos', 'Nowy', 'Diesel', 22350.00, 'Fam'),
(21, 'Acer Sp.z.o.o', 'Passat', 'Nowy', 'Benzyna', 14500.00, 'Chleb'),
(22, 'Acer Sp.z.o.o', 'Compact', 'Nowy', 'Benzyna', 10000.00, 'Chleb'),
(23, 'Macintosh S.A.', 'Tiguan', 'Uzywany', 'Diesel', 9600.00, 'Stewart'),
(24, 'Macintosh S.A.', 'Golf', 'Nowy', 'Benzyna', 11000.00, 'Stewart'),
(25, 'Ropucha S.A.', 'Passat', 'Uzywany', 'Benzyna', 7800.00, 'Messi'),
(26, 'Ropucha S.A.', 'Polo', 'Nowy', 'Benzyna', 15000.00, 'Messi');

-- --------------------------------------------------------

--
-- Stand-in structure for view `zamowieniawithcity`
-- (See below for the actual view)
--
CREATE TABLE `zamowieniawithcity` (
`Firma` varchar(16)
,`Nazwisko` varchar(7)
,`cena` decimal(11,2)
,`branza` varchar(11)
,`miasto` varchar(9)
,`ilosc` int(3)
);

-- --------------------------------------------------------

--
-- Structure for view `viewofceo`
--
DROP TABLE IF EXISTS `viewofceo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `viewofceo`  AS SELECT `ceo`.`Firma` AS `Firma`, `ceo`.`Imie` AS `Imie`, `ceo`.`Nazwisko` AS `Nazwisko`, `ceo`.`Email` AS `Email`, `klienci`.`branza` AS `branza`, `klienci`.`miasto` AS `miasto` FROM (`ceo` join `klienci` on(`ceo`.`Firma` = `klienci`.`nazwa`)) ;

-- --------------------------------------------------------

--
-- Structure for view `zamowieniawithcity`
--
DROP TABLE IF EXISTS `zamowieniawithcity`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `zamowieniawithcity`  AS SELECT `zamowienia`.`Firma` AS `Firma`, `zamowienia`.`Nazwisko` AS `Nazwisko`, `zamowienia`.`cena` AS `cena`, `klienci`.`branza` AS `branza`, `klienci`.`miasto` AS `miasto`, `klienci`.`ilosc` AS `ilosc` FROM (`zamowienia` join `klienci` on(`zamowienia`.`Firma` = `klienci`.`nazwa`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ceo`
--
ALTER TABLE `ceo`
  ADD PRIMARY KEY (`Firma`),
  ADD UNIQUE KEY `Nazwisko` (`Nazwisko`);

--
-- Indexes for table `haslo`
--
ALTER TABLE `haslo`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `klienci`
--
ALTER TABLE `klienci`
  ADD PRIMARY KEY (`nazwa`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `modele`
--
ALTER TABLE `modele`
  ADD PRIMARY KEY (`Identyfikator`),
  ADD KEY `Model` (`Model`);

--
-- Indexes for table `zamowienia`
--
ALTER TABLE `zamowienia`
  ADD PRIMARY KEY (`Identyfikator`),
  ADD KEY `Firma` (`Firma`),
  ADD KEY `Firma_2` (`Firma`),
  ADD KEY `Model` (`Model`),
  ADD KEY `Nazwisko` (`Nazwisko`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `haslo`
--
ALTER TABLE `haslo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `modele`
--
ALTER TABLE `modele`
  MODIFY `Identyfikator` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
