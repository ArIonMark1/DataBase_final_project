
CREATE DATABASE IF NOT EXISTS `shop_progect_gb`;
USE `shop_progect_gb` ;

-- -----------------------------------------------------
-- Table `shop_progect_gb`.`workers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`workers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(40) NOT NULL,
  `last_name` VARCHAR(40) NOT NULL,
  `gender` TINYINT(1) NOT NULL COMMENT 'пол товарища\n0 - жен\n1 - муж',
  `age` SMALLINT(2) UNSIGNED NOT NULL COMMENT 'возраст работника',
  `phone` BIGINT(13) NOT NULL,
  `email` VARCHAR(50) NULL DEFAULT NULL,
  `adres` VARCHAR(150) NOT NULL,
  `experience` SMALLINT(2) UNSIGNED NULL DEFAULT NULL,
  `education` VARCHAR(100) NULL DEFAULT NULL,
  `start_date` DATETIME NULL DEFAULT NULL,
  `finish_date` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `phone_UNIQUE` (`phone` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`auto_park`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`auto_park` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `marka` VARCHAR(40) NOT NULL,
  `type` VARCHAR(40) NOT NULL,
  `id_responsible` INT NOT NULL,
  `data_service` DATE NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `auto_park_id_responsible-workers_id` (`id_responsible` ASC),
  CONSTRAINT `auto_park_id_responsible-workers_id`
    FOREIGN KEY (`id_responsible`)
    REFERENCES `shop_progect_gb`.`workers` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'автопарк супермаркета\nмашина -> id работника закрепленного за ней';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`buyer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`buyer` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(40) NOT NULL,
  `last_name` VARCHAR(40) NOT NULL,
  `gender` TINYINT(1) NOT NULL COMMENT 'пол покупателя\n0 - жен\n1 - муж\n',
  `phone` BIGINT(13) NOT NULL,
  `email` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'бланк покупателя';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`product` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `code_product` BIGINT(12) UNSIGNED NOT NULL,
  `name_of_product` VARCHAR(40) NOT NULL,
  `description` VARCHAR(100) NOT NULL,
  `quantity` MEDIUMINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `code_product_UNIQUE` (`code_product` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'продукция для реализации';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`provider`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`provider` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title_provider` VARCHAR(50) NOT NULL,
  `adres_provider` VARCHAR(100) NOT NULL,
  `phone` BIGINT(13) NOT NULL,
  `site_provider` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'поставщики товаров';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`shop`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`shop` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `shop_name` VARCHAR(100) NOT NULL,
  `adres_shop` VARCHAR(100) NOT NULL,
  `phone` BIGINT(13) NOT NULL,
  `shop_site` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'магазин/сеть магазинов';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`purchase_products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`purchase_products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `shop_id` INT NOT NULL,
  `responsabile_worker_id` INT NOT NULL,
  `provider_id` INT NOT NULL,
  `id_product` INT NOT NULL,
  `price_one` DECIMAL(10,2) UNSIGNED NOT NULL,
  `quantity` INT UNSIGNED NOT NULL,
  `total_sum` DECIMAL(10,2) GENERATED ALWAYS AS (`price_one` * `quantity`) VIRTUAL,
  `date_order` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`id`),
  INDEX `purchase_products_id_product-product_id` (`id_product` ASC),
  INDEX `purchase_products_shop_id-shop_id` (`shop_id` ASC),
  INDEX `purchase_products_responsabile_worker_id-workers_id` (`responsabile_worker_id` ASC),
  INDEX `purchase_products_provider_id-provider_id` (`provider_id` ASC),
  CONSTRAINT `purchase_products_id_product-product_id`
    FOREIGN KEY (`id_product`)
    REFERENCES `shop_progect_gb`.`product` (`id`),
  CONSTRAINT `purchase_products_provider_id-provider_id`
    FOREIGN KEY (`provider_id`)
    REFERENCES `shop_progect_gb`.`provider` (`id`),
  CONSTRAINT `purchase_products_responsabile_worker_id-workers_id`
    FOREIGN KEY (`responsabile_worker_id`)
    REFERENCES `shop_progect_gb`.`workers` (`id`),
  CONSTRAINT `purchase_products_shop_id-shop_id`
    FOREIGN KEY (`shop_id`)
    REFERENCES `shop_progect_gb`.`shop` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'покупка/заказ товаров\n';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`term_action`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`term_action` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(40) NOT NULL,
  `description` VARCHAR(150) NOT NULL,
  `discount_percents` SMALLINT(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'акции скидки на товар и их условия \nзависит от товара, акции не на все товары\n';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`sale`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`sale` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_buyer` INT NOT NULL,
  `id_workers` INT NOT NULL,
  `id_product` INT NOT NULL,
  `id_action` INT NOT NULL,
  `quantity` SMALLINT UNSIGNED NULL DEFAULT 0,
  `price_for_one` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `total_price` DECIMAL(10,2) GENERATED ALWAYS AS (`quantity` * `price_for_one`) VIRTUAL,
  `transportation` TINYINT(1) NULL DEFAULT 0 COMMENT 'транспортировка\n0 - не нужна\n1 - нужна',
  `instalation` TINYINT(1) NULL DEFAULT 0 COMMENT 'установка\n0 - не нужна\n1 - нужна',
  `processing` TINYINT(1) NULL DEFAULT 0 COMMENT 'обработка товара\n0 - не нужна\n1 - нужна',
  `pay_installments` TINYINT(1) NULL DEFAULT 0 COMMENT 'рассрочка\n0 - не нужна\n1 - нужна\n',
  `date_sale` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`id`),
  INDEX `sale_id_buyer-buyer_id` (`id_buyer` ASC),
  INDEX `sale_id_product-product_id` (`id_product` ASC),
  INDEX `sale_id_action-action_id` (`id_action` ASC),
  INDEX `sale_id_workers-workers_id` (`id_workers` ASC),
  CONSTRAINT `sale_id_buyer-buyer_id`
    FOREIGN KEY (`id_buyer`)
    REFERENCES `shop_progect_gb`.`buyer` (`id`),
  CONSTRAINT `sale_id_product-product_id`
    FOREIGN KEY (`id_product`)
    REFERENCES `shop_progect_gb`.`product` (`id`),
  CONSTRAINT `sale_id_workers-workers_id`
    FOREIGN KEY (`id_workers`)
    REFERENCES `shop_progect_gb`.`workers` (`id`),
  CONSTRAINT `sale_id_action-action_id`
    FOREIGN KEY (`id_action`)
    REFERENCES `shop_progect_gb`.`term_action` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'форма продажи товаров';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`shop_staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`shop_staff` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `profession` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'штат работников супермаркета';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`tupe_prod`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`tupe_prod` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `type_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'категории товаров';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`manufacturer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`manufacturer` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name_manufacturer` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'произволитель товара';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`relation_action_product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`relation_action_product` (
  `term_action_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  PRIMARY KEY (`term_action_id`, `product_id`),
  INDEX `fk_term_action_has_product_product1_idx` (`product_id` ASC),
  INDEX `fk_term_action_has_product_term_action1_idx` (`term_action_id` ASC),
  CONSTRAINT `fk_term_action_has_product_term_action`
    FOREIGN KEY (`term_action_id`)
    REFERENCES `shop_progect_gb`.`term_action` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_term_action_has_product_product`
    FOREIGN KEY (`product_id`)
    REFERENCES `shop_progect_gb`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`relation_workers_staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`relation_workers_staff` (
  `workers_id` INT NOT NULL,
  `shop_staff_id` INT NOT NULL,
  PRIMARY KEY (`workers_id`, `shop_staff_id`),
  INDEX `fk_workers_has_shop_staff_shop_staff1_idx` (`shop_staff_id` ASC),
  INDEX `fk_workers_has_shop_staff_workers1_idx` (`workers_id` ASC),
  CONSTRAINT `fk_workers_has_shop_staff_workers`
    FOREIGN KEY (`workers_id`)
    REFERENCES `shop_progect_gb`.`workers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_workers_has_shop_staff_shop_staff`
    FOREIGN KEY (`shop_staff_id`)
    REFERENCES `shop_progect_gb`.`shop_staff` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'отношение \nработник - штат(профессия)';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`relation_product_manufacturer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`relation_product_manufacturer` (
  `product_id` INT NOT NULL,
  `manufacturer_id` INT NOT NULL,
  PRIMARY KEY (`product_id`, `manufacturer_id`),
  INDEX `fk_product_has_manufacturer_manufacturer1_idx` (`manufacturer_id` ASC),
  INDEX `fk_product_has_manufacturer_product1_idx` (`product_id` ASC),
  CONSTRAINT `fk_product_has_manufacturer_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES `shop_progect_gb`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_product_has_manufacturer_manufacturer1`
    FOREIGN KEY (`manufacturer_id`)
    REFERENCES `shop_progect_gb`.`manufacturer` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'отношение товар-производитель\n';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`relation_tupe_prod_product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`relation_tupe_prod_product` (
  `tupe_prod_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  PRIMARY KEY (`tupe_prod_id`, `product_id`),
  INDEX `fk_tupe_prod_has_product_product1_idx` (`product_id` ASC),
  INDEX `fk_tupe_prod_has_product_tupe_prod1_idx` (`tupe_prod_id` ASC),
  CONSTRAINT `fk_tupe_prod_has_product_tupe_prod1`
    FOREIGN KEY (`tupe_prod_id`)
    REFERENCES `shop_progect_gb`.`tupe_prod` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tupe_prod_has_product_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES `shop_progect_gb`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'отношение товар-тип\n';


-- -----------------------------------------------------
-- Table `shop_progect_gb`.`relation_shop_auto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shop_progect_gb`.`relation_shop_auto` (
  `auto_park_id` INT NOT NULL,
  `shop_id` INT NOT NULL,
  PRIMARY KEY (`auto_park_id`, `shop_id`),
  INDEX `fk_auto_park_has_shop_shop1_idx` (`shop_id` ASC),
  INDEX `fk_auto_park_has_shop_auto_park1_idx` (`auto_park_id` ASC),
  CONSTRAINT `fk_auto_park_has_shop_auto_park1`
    FOREIGN KEY (`auto_park_id`)
    REFERENCES `shop_progect_gb`.`auto_park` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_auto_park_has_shop_shop1`
    FOREIGN KEY (`shop_id`)
    REFERENCES `shop_progect_gb`.`shop` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'отношение автомобиля к супермаркету\n\n';
