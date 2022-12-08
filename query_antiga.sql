-- phpMyAdmin SQL Dump
-- version 4.3.7
-- http://www.phpmyadmin.net
--
-- Host: mysql04-farm76.kinghost.net
-- Tempo de geração: 10/01/2018 às 21:07
-- Versão do servidor: 5.6.38-log
-- Versão do PHP: 5.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Banco de dados: `brgamescs02`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_addons_key`
--

CREATE TABLE IF NOT EXISTS `bail_addons_key` (
  `ID` int(10) NOT NULL,
  `SERVIDOR` varchar(60) NOT NULL,
  `ADDONS` varchar(60) NOT NULL,
  `KEY` varchar(40) NOT NULL,
  `STATUS` int(3) NOT NULL DEFAULT '1'
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Fazendo dump de dados para tabela `bail_addons_key`
--

INSERT INTO `bail_addons_key` (`ID`, `SERVIDOR`, `ADDONS`, `KEY`, `STATUS`) VALUES
(1, '177.234.150.181:27016', 'JailBreak', 'KYHJ-35IKH', 1),
(2, '177.11.54.67:28000', 'PUG Venc: 00/00/0000', 'KYHJQ-01TLD', 1);

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_codigo_promocao`
--

CREATE TABLE IF NOT EXISTS `bail_codigo_promocao` (
  `ID` int(50) NOT NULL,
  `CODIGO` varchar(150) NOT NULL,
  `RID_ITEM` int(50) NOT NULL,
  `TIPO_ITEM` int(5) NOT NULL DEFAULT '1',
  `PERIODO` varchar(32) NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=60 DEFAULT CHARSET=latin1;

--
-- Fazendo dump de dados para tabela `bail_codigo_promocao`
--

INSERT INTO `bail_codigo_promocao` (`ID`, `CODIGO`, `RID_ITEM`, `TIPO_ITEM`, `PERIODO`) VALUES
(59, 'DD431156-556D-11E4-91A8-1261A70E77CA', 0, 1, '');

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_comercio`
--

CREATE TABLE IF NOT EXISTS `bail_comercio` (
  `ID` int(150) NOT NULL,
  `MEMBRO_KEY` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `NICK` varchar(32) COLLATE latin1_general_ci NOT NULL,
  `ITEM_ID` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `ITEM_NAME` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `ITEM_PRECO` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `ITEM_TIPO` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `DATA_VENDA` date NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_count_rid`
--

CREATE TABLE IF NOT EXISTS `bail_count_rid` (
  `ID` int(150) NOT NULL,
  `REGISTRADOS` int(150) NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Fazendo dump de dados para tabela `bail_count_rid`
--

INSERT INTO `bail_count_rid` (`ID`, `REGISTRADOS`) VALUES
(1, 10005);

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_guilds`
--

CREATE TABLE IF NOT EXISTS `bail_guilds` (
  `ID` int(150) NOT NULL,
  `GUILD_NAME` varchar(32) CHARACTER SET latin1 NOT NULL,
  `GUILD_TAG` varchar(32) CHARACTER SET latin1 NOT NULL,
  `GUILD_EMBLEMA` int(150) NOT NULL,
  `SLOTS_INVENTARIO` int(150) NOT NULL DEFAULT '10',
  `KEY_LIDER` varchar(32) CHARACTER SET latin1 NOT NULL,
  `JAIL_MONEY` int(150) NOT NULL,
  `PONTOS` int(11) NOT NULL,
  `ZMXP_AMMOPACKS` int(11) NOT NULL,
  `STATUS` int(10) NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=24 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Fazendo dump de dados para tabela `bail_guilds`
--

INSERT INTO `bail_guilds` (`ID`, `GUILD_NAME`, `GUILD_TAG`, `GUILD_EMBLEMA`, `SLOTS_INVENTARIO`, `KEY_LIDER`, `JAIL_MONEY`, `PONTOS`, `ZMXP_AMMOPACKS`, `STATUS`) VALUES
(23, 'BRGaMeS!CS', 'BRGaMeS', 0, 10, 'BAIL_0:0:10002', 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_inventario`
--

CREATE TABLE IF NOT EXISTS `bail_inventario` (
  `ID` int(150) NOT NULL,
  `MEMBRO_KEY` varchar(64) COLLATE latin1_general_ci NOT NULL,
  `RID_ITEM` int(150) NOT NULL,
  `TIPO` int(15) NOT NULL,
  `ID_GUILD` int(15) NOT NULL,
  `DATA_CADASTRO` date DEFAULT NULL,
  `DATA_EXPIRA` date DEFAULT NULL
) ENGINE=MyISAM AUTO_INCREMENT=113 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_jailbreak`
--

CREATE TABLE IF NOT EXISTS `bail_jailbreak` (
  `ID` int(150) NOT NULL,
  `NICK` varchar(40) CHARACTER SET latin1 NOT NULL,
  `MEMBRO_KEY` varchar(150) CHARACTER SET latin1 NOT NULL,
  `JB_PACKS` int(150) NOT NULL,
  `POINTS` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `TOTAL_POINTS` int(150) NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=597 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_patentes`
--

CREATE TABLE IF NOT EXISTS `bail_patentes` (
  `ID` tinyint(20) NOT NULL,
  `PATENTE` varchar(150) NOT NULL,
  `ICON` varchar(50) NOT NULL,
  `EXP` varchar(150) NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=71 DEFAULT CHARSET=latin1;

--
-- Fazendo dump de dados para tabela `bail_patentes`
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

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_registro`
--

CREATE TABLE IF NOT EXISTS `bail_registro` (
  `ID` int(150) NOT NULL,
  `MEMBRO_KEY` varchar(32) CHARACTER SET latin1 NOT NULL,
  `STEAM` varchar(64) COLLATE latin1_general_ci NOT NULL,
  `NICK` varchar(60) CHARACTER SET latin1 NOT NULL,
  `LOGIN` varchar(60) CHARACTER SET latin1 NOT NULL,
  `PASSWORD` varchar(60) CHARACTER SET latin1 NOT NULL,
  `EMAIL` varchar(60) CHARACTER SET latin1 NOT NULL,
  `ALISTAMENTO` varchar(150) CHARACTER SET latin1 NOT NULL,
  `AUTO_LOGIN` varchar(32) COLLATE latin1_general_ci NOT NULL,
  `ULTIMO_LOGIN` varchar(150) CHARACTER SET latin1 NOT NULL,
  `MAX_INVENTARIO_ITENS` int(150) NOT NULL DEFAULT '10',
  `XPPATENTE` int(150) NOT NULL DEFAULT '1',
  `CASH` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `IP` varchar(60) CHARACTER SET latin1 NOT NULL,
  `PLATAFORMA` varchar(32) CHARACTER SET latin1 NOT NULL COMMENT '1 - STEAM  |  2 - NO-STEAM',
  `COMPAT` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `PREMIUM` int(10) NOT NULL,
  `ID_GUILD` int(150) NOT NULL,
  `LIDER_GUILD` int(10) NOT NULL,
  `PONTOS_GUILD` varchar(150) COLLATE latin1_general_ci NOT NULL,
  `STATUS` int(10) NOT NULL DEFAULT '1' COMMENT '0 - BANIDO  |  1 - DESBANIDO'
) ENGINE=MyISAM AUTO_INCREMENT=38 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Fazendo dump de dados para tabela `bail_registro`
--

INSERT INTO `bail_registro` (`ID`, `MEMBRO_KEY`, `STEAM`, `NICK`, `LOGIN`, `PASSWORD`, `EMAIL`, `ALISTAMENTO`, `AUTO_LOGIN`, `ULTIMO_LOGIN`, `MAX_INVENTARIO_ITENS`, `XPPATENTE`, `CASH`, `IP`, `PLATAFORMA`, `COMPAT`, `PREMIUM`, `ID_GUILD`, `LIDER_GUILD`, `PONTOS_GUILD`, `STATUS`) VALUES
(36, 'BAIL_0:0:10004', '', 'BRGaMes || Giovanni ;)', 'gihcs', 'gihcs321', 'giovanni-santos95@outlook.com', '2018.01.07', '1', '2018.01.07', 10, 1, '', '179.55.189.144', '2', '', 0, 0, 0, '', 1),
(35, 'BAIL_0:0:10003', '', '.{ Th ~@BRGaMes', 'thiago', 'a10y12a28', 'thiagociavolelab@gmail.com', '2018.01.07', '1', '2018.01.07', 10, 1, '', '177.181.21.162', '2', '', 0, 0, 0, '', 1),
(34, 'BAIL_0:0:10002', '', 'DeMoN', 'demon', '33752318', 'marcusbh1980@gmail.com', '2018.01.06', '1', '2018.01.06', 10, 0, '', '187.58.0.124', '2', '', 0, 23, 1, '', 1),
(33, 'BAIL_0:0:10001', 'STEAM_0:0:41266471', 'Satelite', 'megabail', 'wtsgames12314k', 'djeduardobail@gmail.com', '2018.01.06', '1', '2018.01.06', 10, 12000, '', '177.220.172.20', '2', '', 0, 0, 0, '', 1),
(37, 'BAIL_0:0:10005', '', 'DeMoN', 'demo', '33752318', 'marcuswerneck@live.com', '2018.01.07', '0', '2018.01.07', 10, 0, '', '187.59.190.152', '2', '', 0, 0, 0, '', 1);

-- --------------------------------------------------------

--
-- Estrutura para tabela `bail_zombiexp`
--

CREATE TABLE IF NOT EXISTS `bail_zombiexp` (
  `ID` varchar(150) NOT NULL,
  `MEMBRO_KEY` varchar(32) NOT NULL,
  `NICK` varchar(32) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL DEFAULT '',
  `XP` int(10) NOT NULL DEFAULT '0',
  `XP_TOTAL` int(10) NOT NULL DEFAULT '0',
  `UPGRADES` varchar(32) NOT NULL DEFAULT '',
  `AMMOPACKS` int(10) NOT NULL DEFAULT '0',
  `PERSONAGEM` varchar(32) NOT NULL DEFAULT '',
  `FANTASIA` varchar(150) NOT NULL DEFAULT '0 0 0 0',
  `AURA` varchar(150) NOT NULL,
  `HAND` int(150) NOT NULL,
  `XP_SEMANAL` int(11) DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='ZombieXP Saving Table';

--
-- Fazendo dump de dados para tabela `bail_zombiexp`
--

INSERT INTO `bail_zombiexp` (`ID`, `MEMBRO_KEY`, `NICK`, `XP`, `XP_TOTAL`, `UPGRADES`, `AMMOPACKS`, `PERSONAGEM`, `FANTASIA`, `AURA`, `HAND`, `XP_SEMANAL`) VALUES
('', 'BAIL_0:0:10002', 'DeMoN', 6200, 6200, '0 0 0 0 0 0 0 0 0 0 0 0', 887657, '0 0', '0 0 0 0', '', 0, 0),
('', 'BAIL_0:0:10005', 'DeMoN', 6200, 6200, '0 0 0 0 0 0 0 0 0 0 0 0', 16, '0 0', '0 0 0 0', '', 0, 0),
('', 'BAIL_0:0:10001', 'Satelite', 6200, 6200, '0 0 0 0 0 0 0 0 0 0 0 0', 25, '0 0', '0 0 0 0', '', 0, 0);

--
-- Índices de tabelas apagadas
--

--
-- Índices de tabela `bail_addons_key`
--
ALTER TABLE `bail_addons_key`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_codigo_promocao`
--
ALTER TABLE `bail_codigo_promocao`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_comercio`
--
ALTER TABLE `bail_comercio`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_count_rid`
--
ALTER TABLE `bail_count_rid`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_guilds`
--
ALTER TABLE `bail_guilds`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_inventario`
--
ALTER TABLE `bail_inventario`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_jailbreak`
--
ALTER TABLE `bail_jailbreak`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_patentes`
--
ALTER TABLE `bail_patentes`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_registro`
--
ALTER TABLE `bail_registro`
  ADD PRIMARY KEY (`ID`);

--
-- Índices de tabela `bail_zombiexp`
--
ALTER TABLE `bail_zombiexp`
  ADD PRIMARY KEY (`MEMBRO_KEY`);

--
-- AUTO_INCREMENT de tabelas apagadas
--

--
-- AUTO_INCREMENT de tabela `bail_addons_key`
--
ALTER TABLE `bail_addons_key`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de tabela `bail_codigo_promocao`
--
ALTER TABLE `bail_codigo_promocao`
  MODIFY `ID` int(50) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=60;
--
-- AUTO_INCREMENT de tabela `bail_comercio`
--
ALTER TABLE `bail_comercio`
  MODIFY `ID` int(150) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de tabela `bail_count_rid`
--
ALTER TABLE `bail_count_rid`
  MODIFY `ID` int(150) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de tabela `bail_guilds`
--
ALTER TABLE `bail_guilds`
  MODIFY `ID` int(150) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=24;
--
-- AUTO_INCREMENT de tabela `bail_inventario`
--
ALTER TABLE `bail_inventario`
  MODIFY `ID` int(150) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=113;
--
-- AUTO_INCREMENT de tabela `bail_jailbreak`
--
ALTER TABLE `bail_jailbreak`
  MODIFY `ID` int(150) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=597;
--
-- AUTO_INCREMENT de tabela `bail_patentes`
--
ALTER TABLE `bail_patentes`
  MODIFY `ID` tinyint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=71;
--
-- AUTO_INCREMENT de tabela `bail_registro`
--
ALTER TABLE `bail_registro`
  MODIFY `ID` int(150) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=38;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
