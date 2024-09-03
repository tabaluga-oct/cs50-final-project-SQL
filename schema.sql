-- Represent users who are or were members of this football club
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` BINARY(64) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    PRIMARY KEY(`id`)
);

-- Represent membership for users
CREATE TABLE `membership` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT,
    `status` ENUM('active', 'expired') NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE,
    PRIMARY KEY(`id`),
    FOREIGN KEY(`user_id`) REFERENCES `users`(`id`)
);

-- Represent matches
CREATE TABLE `matches` (
    `id` INT AUTO_INCREMENT,
    `stadium_id` INT,
    `date` DATETIME NOT NULL,
    `type` ENUM('away', 'home'),
    `opponent` VARCHAR(100) NOT NULL,
    PRIMARY KEY(`id`),
    FOREIGN KEY(`stadium_id`) REFERENCES `stadiums`(`id`)
);

-- Represent stadiums
CREATE TABLE `stadiums` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `capacity` INT NOT NULL,
    PRIMARY KEY(`id`)
);

--Represent tickets
CREATE TABLE `tickets` (
    `id` INT AUTO_INCREMENT,
    `user_id` INT,
    `match_id` INT,
    `ticket_type_id` INT,
    `transaction_id` INT,
    `status` ENUM('sold', 'reserved', 'available') NOT NULL,
    `location` VARCHAR(100) NOT NULL,
    `sold_date` DATETIME,
    `sold_price` DECIMAL(5,2)
    PRIMARY KEY(`id`),
    FOREIGN KEY(`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY(`match_id`) REFERENCES `matches`(`id`),
    FOREIGN KEY(`ticket_type_id`) REFERENCES `ticket_types`(`id`),
    FOREIGN KEY(`transaction_id`) REFERENCES `transactions`(`id`)
);

-- represent ticket types
CREATE TABLE `ticket_types` (
    `id` INT AUTO_INCREMENT,
    `type` ENUM('day', 'season', 'subscription', 'discount') NOT NULL,
    PRIMARY KEY(`id`)
);

-- represent inventory for the match tickets
CREATE TABLE `inventory` (
    `id` INT AUTO_INCREMENT,
    `match_id` INT,
    `total_tickets` INT NOT NULL,
    `remaining_tickets` INT NOT NULL,
    PRIMARY KEY(`id`),
    FOREIGN KEY(`match_id`) REFERENCES `matches`(`id`)
);

-- represent transactions for tickets selling
CREATE TABLE `transactions` (
    `id` INT AUTO_INCREMENT,
    `transaction_date` DATETIME NOT NULL,
    `transaction_amount` DECIMAL(5, 2) NOT NULL,
    `payment_method` ENUM('debit', 'visa', 'master', 'paypal') NOT NULL,
    PRIMARY KEY(`id`)
);

-- create index to speed up common queries
-- user related queries
CREATE INDEX `user_email` ON `users`(`email`);
CREATE INDEX `user_name` ON `users`(`name`);
CREATE INDEX `user_id_search` ON `matches`(`user_id`);
CREATE INDEX `user_id_search` ON `tickets`(`user_id`);
-- match related queries
CREATE INDEX `match_id_search` ON `inventory`(`match_id`);
CREATE INDEX `match_date` ON `matches`(`date`);
-- ticket related queries
CREATE INDEX `match_id_search` ON `tickets`(`match_id`);
-- transaction related queries
CREATE INDEX `transaction_date_search` ON `transactions`(`transaction_date`);
CREATE INDEX `transaction_id_search` ON `tickets`(`transaction_id`);


