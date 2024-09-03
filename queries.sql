-- retieve user details by their name
SELECT * FROM `users`
WHERE `name` = 'Kevin Müller';

-- list all users who are current members
SELECT `name` FROM `users`
WHERE `id` in (
    SELECT `user_id` FROM `membership`
    WHERE `status` = 'active'
);

-- getting a user's purchase history, including which seats in which matches
SELECT t.`location`, m.`date`
FROM `tickets` t
JOIN `matches` m ON t.`match_id` = m.`id`
JOIN `users` u ON t.`user_id` = u.`id`
WHERE u.`name` = 'Kevin Müller';

-- list all upcoming matches
SELECT *
FROM `matches`
WHERE `date` > NOW();

-- retrieve match details by type
SELECT * FROM `matches`
WHERE `type` = 'home';

-- count sold/reserved tickets for a certain match
SELECT COUNT(*)
FROM `tickets`
JOIN `matches` ON `tickets`.`match_id` = `matches`.`id`
WHERE `matches`.`date` = '2024-01-01'
AND `tickets`.`status` IN ('sold', 'reserved');

-- checking the availability of a specific ticket in a specific area like block 4A for a match
SELECT `location`, `status`
FROM `tickets`
JOIN `matches` ON `tickets`.`match_id` = `matches`.`id`
WHERE `matches`.`date` = '2024-01-01'
AND `tickets`.`location` LIKE '4A%';

-- list all transactions within a data range
SELECT *
FROM `transactions`
WHERE `transaction_date` BETWEEN '2024-01-01' AND '2024-01-31';

-- retrieve transactions made by a specific user
SELECT *
FROM `transactions`
JOIN `tickets` ON `transactions`.`id` = `tickets`.`transaction_id`
JOIN `users` ON `tickets`.`user_id` = `users`.`id`
WHERE `users`.`name` = 'Kevin Müller';

-- add a new user
INSERT INTO `users` (`name`, `email`, `password`, `address`)
VALUES ('Kevin Müller', 'kevin.mueller@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Donrnestrasse 50, 23669, Luebeck, Germany');

-- grant a user membership
INSERT INTO `membership` (`user_id`, `status`, `start_date`)
VALUES ((SELECT `id` FROM `users` WHERE `name` = 'Kevin Müller'), 'active', '2024-01-01');

-- first stage sale of tickets
UPDATE tickets
SET status = 'available';

-- season and subscription tickets holders can reserve their tickets
DELIMITER //
CREATE PROCEDURE `reserve_tickets` (IN `user_id_to_reserve_ticket` INT, IN `location_to_reserve` VARCHAR(100))
BEGIN
UPDATE `tickets`
JOIN `ticket_types` ON `tickets`.`ticket_type_id` = `ticket_types`.`id`
JOIN `matches` ON `tickets`.`match_id` = `matches`.`id`
JOIN `users` ON  `users`.`id` = `tickets`.`user_id`
SET `tickets`.`status` = 'reserved', `tickets`.`user_id` = `user_id_to_reserve_ticket`
WHERE (`ticket_types`.`type` = 'season' OR `ticket_types`.`type` = 'subscription')
AND `tickets`.`location` = `location_to_reserve`
AND `matches`. `date` = '2024-01-01';
END//
DELIMITER ;

-- Second stage sale of tickets
-- users with active membership can buy tickets
DELIMITER //
CREATE PROCEDURE `buy_tickets` (IN `user_id_to_buy_ticket` INT, IN `location_to_reserve` VARCHAR(100))
BEGIN
UPDATE `tickets`
JOIN `matches` ON `tickets`.`match_id` = `matches`.`id`
JOIN `users` ON  `users`.`id` = `tickets`.`user_id`
SET `tickets`.`status` = 'sold', `tickets`.`user_id` = `user_id_to_buy_ticket`
WHERE `users`.`id` IN (SELECT `user_id` FROM `membership` WHERE `status` = 'active')
AND `tickets`.`status` = 'available'
AND `tickets`.`location` = `location_to_reserve`
AND `matches`. `date` = '2024-01-01';
END//
DELIMITER ;

-- third stage sale of tickets
-- users who are former members can purchase tickets
DELIMITER //
CREATE PROCEDURE `buy_tickets_for_former_members` (IN `user_id_to_buy_ticket` INT, IN `location_to_reserve` VARCHAR(100))
BEGIN
UPDATE `tickets`
JOIN `matches` ON `tickets`.`match_id` = `matches`.`id`
JOIN `users` ON  `users`.`id` = `tickets`.`user_id`
SET `tickets`.`status` = 'sold', `tickets`.`user_id` = `user_id_to_buy_ticket`
WHERE `users`.`id` NOT IN (SELECT `user_id` FROM `membership` WHERE `status` = 'expired')
AND `tickets`.`status` = 'available'
AND `tickets`.`location` = `location_to_reserve`
AND `matches`. `date` = '2024-01-01';
END//
DELIMITER ;

-- final stage sale of tickets
-- users who are not members can purchase tickets
DELIMITER //
CREATE PROCEDURE `buy_tickets_for_non_members` (IN `user_id_to_buy_ticket` INT, IN `location_to_reserve` VARCHAR(100))
BEGIN
UPDATE `tickets`
JOIN `matches` ON `tickets`.`match_id` = `matches`.`id`
JOIN `users` ON  `users`.`id` = `tickets`.`user_id`
SET `tickets`.`status` = 'sold', `tickets`.`user_id` = `user_id_to_buy_ticket`
WHERE `users`.`id` NOT IN (SELECT `user_id` FROM `membership`)
AND `tickets`.`status` = 'available'
AND `tickets`.`location` = `location_to_reserve`
AND `matches`. `date` = '2024-01-01';
END//
DELIMITER ;

-- create a trigger to update the inventory after a ticket is sold or reserved
DELIMITER //
CREATE TRIGGER `update_inventory`
AFTER UPDATE ON `tickets`
FOR EACH ROW
BEGIN
    IF NEW.status = 'sold' OR NEW.status = 'reserved' THEN
        UPDATE `inventory`
        SET `remaining_tickets` = `remaining_tickets` - 1
        WHERE `match_id` = (SELECT `match_id` FROM `tickets` WHERE `id` = NEW.id);
    END IF;
END//
DELIMITER ;

-- delete a user
DELETE FROM `users` WHERE `id` = 1;
