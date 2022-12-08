SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Estrutura da tabela `bail_codigo_promocao`
--
CREATE TABLE IF NOT EXISTS `bail_codigo_promocao` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(150) NOT NULL,
  `RID_ITEM` int NOT NULL,
  `TIPO_ITEM` int NOT NULL DEFAULT '1',
  `PERIODO` varchar(32) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `bail_codigo_promocao`
--
INSERT INTO `bail_codigo_promocao` (`ID`, `CODIGO`, `RID_ITEM`, `TIPO_ITEM`, `PERIODO`) VALUES (1, 'DD431156-556D-11E4-91A8-1261A70E77CA', 0, 1, '');

--
-- Estrutura da tabela `bail_comercio`
--
CREATE TABLE IF NOT EXISTS `bail_comercio` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `MEMBRO_KEY` varchar(150) NOT NULL,
  `NICK` varchar(32) NOT NULL,
  `ITEM_ID` varchar(150) NOT NULL,
  `ITEM_NAME` varchar(150) NOT NULL,
  `ITEM_PRECO` varchar(150) NOT NULL,
  `ITEM_TIPO` varchar(150) NOT NULL,
  `DATA_VENDA` date NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Estrutura da tabela `bail_count_rid`
--
CREATE TABLE IF NOT EXISTS `bail_count_rid` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `REGISTRADOS` int NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `bail_count_rid`
--
INSERT INTO `bail_count_rid` (`ID`, `REGISTRADOS`) VALUES (1, 1);

--
-- Estrutura da tabela `bail_guilds`
--
CREATE TABLE IF NOT EXISTS `bail_guilds` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `GUILD_NAME` varchar(32) NOT NULL,
  `GUILD_TAG` varchar(32) NOT NULL,
  `GUILD_EMBLEMA` int NOT NULL,
  `SLOTS_INVENTARIO` int NOT NULL DEFAULT '10',
  `KEY_LIDER` varchar(32) NOT NULL,
  `JAIL_MONEY` int NOT NULL,
  `PONTOS` int NOT NULL,
  `ZMXP_AMMOPACKS` int NOT NULL,
  `STATUS` int NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Estrutura da tabela `bail_inventario`
--
CREATE TABLE IF NOT EXISTS `bail_inventario` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `MEMBRO_KEY` varchar(64) NOT NULL,
  `RID_ITEM` int NOT NULL,
  `TIPO` int NOT NULL,
  `ID_GUILD` int NOT NULL,
  `DATA_CADASTRO` date DEFAULT NULL,
  `DATA_EXPIRA` date DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Estrutura da tabela `bail_jailbreak`
--
CREATE TABLE IF NOT EXISTS `bail_jailbreak` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `NICK` varchar(40) NOT NULL,
  `MEMBRO_KEY` varchar(150) NOT NULL,
  `JB_PACKS` int NOT NULL,
  `POINTS` varchar(150) NOT NULL,
  `TOTAL_POINTS` int NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

-- Estrutura da tabela `bail_patentes`
--
CREATE TABLE IF NOT EXISTS `bail_patentes` (
  `ID` tinyint NOT NULL AUTO_INCREMENT,
  `PATENTE` varchar(150) NOT NULL,
  `ICON` varchar(50) NOT NULL,
  `EXP` varchar(150) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `bail_patentes`
--
INSERT INTO `bail_patentes` (`ID`, `PATENTE`, `ICON`, `EXP`) VALUES
(1, 'Trainee', '1', '0'),
(2, 'Cadete JÃºnior', '2', '700'),
(3, 'Cadete', '3', '1400'),
(4, 'Cadete SÃªnior', '4', '2400'),
(5, 'Cadete de 1Âª Classe', '5', '3900'),
(6, 'Recruta', '6', '5800'),
(7, 'Soldado', '7', '8100'),
(8, 'Soldado Raso de 2Âª Classe', '8', '11000'),
(9, 'Soldado Raso', '9', '14600'),
(10, 'Soldado Raso de 1Âª Classe', '10', '18800'),
(11, 'Especialista', '11', '23800'),
(12, 'Especialista de Artilharia', '12', '29600'),
(13, 'Especialista TÃ©cnico', '13', '36300'),
(14, 'Especialista de 1Âª Classe', '14', '44100'),
(15, 'Patrulheiro', '15', '53000'),
(16, 'Soldado EP', '16', '63000'),
(17, 'Cabo', '17', '74500'),
(18, 'LÃ­der de Tiro', '18', '87400'),
(19, 'Sargento de 3Âª Classe', '19', '102000'),
(20, 'Sargento de 2Âª Classe', '20', '118400'),
(21, 'Sargento', '21', '136700'),
(22, 'Sargento de 1Âª Classe', '22', '157200'),
(23, 'Sargento de Apoio', '23', '180000'),
(24, 'Sargento de Artilharia', '24', '205200'),
(25, 'Sargento Mestre', '25', '233300'),
(26, 'Primeiro Sargento', '26', '264400'),
(27, 'Sargento Comandante', '27', '298700'),
(28, 'Sargento de Artilharia Mestre', '28', '336500'),
(29, 'Sargento Maior', '29', '378000'),
(30, 'Sargento de Companhia', '30', '423700'),
(31, 'Candidato a Sargento Oficial', '31', '473700'),
(32, 'Sargento Oficial', '32', '528400'),
(33, 'Sargento Oficial Chefe', '33', '588100'),
(34, 'Sargento Oficial Chefe de 1Âª Classe', '34', '653400'),
(35, 'Sargento Oficial Mestre', '35', '724400'),
(36, 'Intendente', '36', '801600'),
(37, 'Cadete-Oficial JÃºnior', '37', '885500'),
(38, 'Cadete-Oficial SÃªnior', '38', '976400'),
(39, 'Aspirante', '39', '1074800'),
(40, 'Segundo Tenente', '40', '1181100'),
(41, 'Primeiro Tenente', '41', '1296000'),
(42, 'Subtenente', '42', '1416700'),
(43, 'Tenente', '43', '1552900'),
(44, 'Tenente-Coronel', '44', '1696200'),
(45, 'Tenente-CapitÃ£o', '45', '1849900'),
(46, 'CapitÃ£o', '46', '2014800'),
(47, 'CapitÃ£o 1', '47', '2191200'),
(48, 'CapitÃ£o 2', '48', '2380000'),
(49, 'CapitÃ£o 3', '49', '2581500'),
(50, 'Coronel', '50', '2796400'),
(51, 'Brigadeiro', '51', '3025300'),
(52, 'Marechal de Campo', '52', '3268800'),
(53, 'Comandante', '53', '3527500'),
(54, 'Alto-Comandante', '54', '3801900'),
(55, 'Supremo Comandante', '55', '4092800'),
(56, 'Major-General', '56', '4400600'),
(57, 'Tenente-General', '57', '4726000'),
(58, 'General-Marechal de Campo', '58', '5069500'),
(59, 'Segundo Tenente SF', '59', '5431800'),
(60, 'Primeiro Tenente SF', '60', '6000000'),
(61, 'Subtenente SF', '61', '6568200'),
(62, 'Tenente SF', '62', '7136400'),
(63, 'Tenente-Coronel SF', '63', '7704600'),
(64, 'Tenente-CapitÃ£o SF', '64', '8272800'),
(65, 'CapitÃ£o SF', '65', '8841000'),
(66, 'CapitÃ£o 1 SF', '66', '9409200'),
(67, 'CapitÃ£o 2 SF', '67', '9977400'),
(68, 'CapitÃ£o 3 SF', '68', '10545600'),
(69, 'Coronel SF', '69', '11113800'),
(70, 'King Size da Mafia Chinesa', '70', '11682000');

--
-- Estrutura da tabela `bail_registro`
--
CREATE TABLE IF NOT EXISTS `bail_registro` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `MEMBRO_KEY` varchar(32) NOT NULL,
  `NICK` varchar(60) NOT NULL,
  `LOGIN` varchar(60) NOT NULL,
  `PASSWORD` varchar(60) NOT NULL,
  `EMAIL` varchar(60) NOT NULL,
  `STEAM` varchar(60) NOT NULL,
  `ALISTAMENTO` varchar(150) NOT NULL,
  `AUTO_LOGIN` varchar(32) NOT NULL,
  `ULTIMO_LOGIN` varchar(150) NOT NULL,
  `MAX_INVENTARIO_ITENS` int NOT NULL DEFAULT '10',
  `XPPATENTE` int NOT NULL DEFAULT '1',
  `CASH` varchar(150) NOT NULL DEFAULT '0',
  `IP` varchar(60) NOT NULL,
  `PLATAFORMA` varchar(32) NOT NULL COMMENT '1 - STEAM  |  2 - NO-STEAM',
  `COMPAT` varchar(150) NOT NULL DEFAULT '0',
  `PREMIUM` int NOT NULL DEFAULT 0,
  `ID_GUILD` int NOT NULL DEFAULT 0,
  `LIDER_GUILD` int NOT NULL DEFAULT 0,
  `PONTOS_GUILD` varchar(150) NOT NULL DEFAULT '0',
  `STATUS` int NOT NULL DEFAULT '1' COMMENT '0 - BANIDO  |  1 - DESBANIDO',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=1 ;

--
-- Estrutura da tabela `bail_zombiexp`
--
CREATE TABLE IF NOT EXISTS `bail_zombiexp` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `MEMBRO_KEY` varchar(32) NOT NULL,
  `NICK` varchar(32) NOT NULL DEFAULT '',
  `XP` int NOT NULL DEFAULT 0,
  `XP_TOTAL` int NOT NULL DEFAULT 0,
  `UPGRADES` varchar(32) NOT NULL DEFAULT '',
  `AMMOPACKS` int NOT NULL DEFAULT 0,
  `PERSONAGEM` varchar(32) NOT NULL DEFAULT '',
  `FANTASIA` varchar(150) NOT NULL DEFAULT '0 0 0 0',
  `AURA` varchar(150) NOT NULL DEFAULT '',
  `HAND` int NOT NULL DEFAULT 0,
  `XP_SEMANAL` int DEFAULT 0,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ZombieXP Saving Table' AUTO_INCREMENT=1;