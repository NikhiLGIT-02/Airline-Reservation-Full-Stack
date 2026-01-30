-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 30, 2025 at 04:11 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `airline_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `account_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `aircraft`
--

CREATE TABLE `aircraft` (
  `aircraft_id` int(11) NOT NULL,
  `aircraft_type_id` int(11) NOT NULL,
  `registration_no` varchar(20) NOT NULL,
  `manufacture_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `aircraft_types`
--

CREATE TABLE `aircraft_types` (
  `aircraft_type_id` int(11) NOT NULL,
  `model` varchar(50) NOT NULL,
  `manufacturer` varchar(50) NOT NULL,
  `seating_capacity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `airport`
--

CREATE TABLE `airport` (
  `airport_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(50) NOT NULL,
  `airport_code` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `boarding_passes`
--

CREATE TABLE `boarding_passes` (
  `boarding_pass_id` int(11) NOT NULL,
  `booking_item_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL,
  `passenger_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `booking_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `booking_status` enum('Confirmed','Cancelled') DEFAULT 'Confirmed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `booking_items`
--

CREATE TABLE `booking_items` (
  `item_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `passenger_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cancellations`
--

CREATE TABLE `cancellations` (
  `cancellation_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `cancelled_at` datetime NOT NULL,
  `cancellation_reason` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crew`
--

CREATE TABLE `crew` (
  `crew_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crew_assignments`
--

CREATE TABLE `crew_assignments` (
  `assignment_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `crew_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delays`
--

CREATE TABLE `delays` (
  `delay_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `delay_minutes` int(11) NOT NULL CHECK (`delay_minutes` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `flights`
--

CREATE TABLE `flights` (
  `flight_id` int(11) NOT NULL,
  `flight_no` varchar(10) NOT NULL,
  `route_id` int(11) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `scheduled_departure` datetime NOT NULL,
  `scheduled_arrival` datetime NOT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `passengers`
--

CREATE TABLE `passengers` (
  `passenger_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL,
  `age` int(11) NOT NULL CHECK (`age` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `routes`
--

CREATE TABLE `routes` (
  `route_id` int(11) NOT NULL,
  `origin_airport_id` int(11) NOT NULL,
  `destination_airport_id` int(11) NOT NULL,
  `distance_km` int(11) NOT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `seats`
--

CREATE TABLE `seats` (
  `seat_id` int(11) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `seat_number` varchar(5) NOT NULL,
  `seat_class` enum('Economy','Business','First') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seat_reservations`
--

CREATE TABLE `seat_reservations` (
  `seat_reservation_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ticket_payments`
--

CREATE TABLE `ticket_payments` (
  `payment_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` enum('Card','UPI','NetBanking') NOT NULL,
  `payment_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`account_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `aircraft`
--
ALTER TABLE `aircraft`
  ADD PRIMARY KEY (`aircraft_id`),
  ADD UNIQUE KEY `registration_no` (`registration_no`),
  ADD KEY `aircraft_type_id` (`aircraft_type_id`);

--
-- Indexes for table `aircraft_types`
--
ALTER TABLE `aircraft_types`
  ADD PRIMARY KEY (`aircraft_type_id`);

--
-- Indexes for table `airport`
--
ALTER TABLE `airport`
  ADD PRIMARY KEY (`airport_id`),
  ADD UNIQUE KEY `airport_code` (`airport_code`);

--
-- Indexes for table `boarding_passes`
--
ALTER TABLE `boarding_passes`
  ADD PRIMARY KEY (`boarding_pass_id`),
  ADD KEY `booking_item_id` (`booking_item_id`),
  ADD KEY `flight_id` (`flight_id`),
  ADD KEY `seat_id` (`seat_id`),
  ADD KEY `passenger_id` (`passenger_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `account_id` (`account_id`);

--
-- Indexes for table `booking_items`
--
ALTER TABLE `booking_items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `flight_id` (`flight_id`),
  ADD KEY `passenger_id` (`passenger_id`);

--
-- Indexes for table `cancellations`
--
ALTER TABLE `cancellations`
  ADD PRIMARY KEY (`cancellation_id`),
  ADD KEY `flight_id` (`flight_id`);

--
-- Indexes for table `crew`
--
ALTER TABLE `crew`
  ADD PRIMARY KEY (`crew_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `crew_assignments`
--
ALTER TABLE `crew_assignments`
  ADD PRIMARY KEY (`assignment_id`),
  ADD UNIQUE KEY `flight_id` (`flight_id`,`crew_id`),
  ADD KEY `crew_id` (`crew_id`);

--
-- Indexes for table `delays`
--
ALTER TABLE `delays`
  ADD PRIMARY KEY (`delay_id`),
  ADD KEY `flight_id` (`flight_id`);

--
-- Indexes for table `flights`
--
ALTER TABLE `flights`
  ADD PRIMARY KEY (`flight_id`),
  ADD KEY `route_id` (`route_id`),
  ADD KEY `aircraft_id` (`aircraft_id`);

--
-- Indexes for table `passengers`
--
ALTER TABLE `passengers`
  ADD PRIMARY KEY (`passenger_id`);

--
-- Indexes for table `routes`
--
ALTER TABLE `routes`
  ADD PRIMARY KEY (`route_id`),
  ADD KEY `origin_airport_id` (`origin_airport_id`),
  ADD KEY `destination_airport_id` (`destination_airport_id`);

--
-- Indexes for table `seats`
--
ALTER TABLE `seats`
  ADD PRIMARY KEY (`seat_id`),
  ADD UNIQUE KEY `aircraft_id` (`aircraft_id`,`seat_number`);

--
-- Indexes for table `seat_reservations`
--
ALTER TABLE `seat_reservations`
  ADD PRIMARY KEY (`seat_reservation_id`),
  ADD UNIQUE KEY `flight_id` (`flight_id`,`seat_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `seat_id` (`seat_id`);

--
-- Indexes for table `ticket_payments`
--
ALTER TABLE `ticket_payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `account_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `aircraft`
--
ALTER TABLE `aircraft`
  MODIFY `aircraft_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `aircraft_types`
--
ALTER TABLE `aircraft_types`
  MODIFY `aircraft_type_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `airport`
--
ALTER TABLE `airport`
  MODIFY `airport_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `boarding_passes`
--
ALTER TABLE `boarding_passes`
  MODIFY `boarding_pass_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `booking_items`
--
ALTER TABLE `booking_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cancellations`
--
ALTER TABLE `cancellations`
  MODIFY `cancellation_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crew`
--
ALTER TABLE `crew`
  MODIFY `crew_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crew_assignments`
--
ALTER TABLE `crew_assignments`
  MODIFY `assignment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delays`
--
ALTER TABLE `delays`
  MODIFY `delay_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `flights`
--
ALTER TABLE `flights`
  MODIFY `flight_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `passengers`
--
ALTER TABLE `passengers`
  MODIFY `passenger_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `routes`
--
ALTER TABLE `routes`
  MODIFY `route_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seats`
--
ALTER TABLE `seats`
  MODIFY `seat_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seat_reservations`
--
ALTER TABLE `seat_reservations`
  MODIFY `seat_reservation_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ticket_payments`
--
ALTER TABLE `ticket_payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `aircraft`
--
ALTER TABLE `aircraft`
  ADD CONSTRAINT `aircraft_ibfk_1` FOREIGN KEY (`aircraft_type_id`) REFERENCES `aircraft_types` (`aircraft_type_id`);

--
-- Constraints for table `boarding_passes`
--
ALTER TABLE `boarding_passes`
  ADD CONSTRAINT `boarding_passes_ibfk_1` FOREIGN KEY (`booking_item_id`) REFERENCES `booking_items` (`item_id`),
  ADD CONSTRAINT `boarding_passes_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`),
  ADD CONSTRAINT `boarding_passes_ibfk_3` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`seat_id`),
  ADD CONSTRAINT `boarding_passes_ibfk_4` FOREIGN KEY (`passenger_id`) REFERENCES `passengers` (`passenger_id`);

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`);

--
-- Constraints for table `booking_items`
--
ALTER TABLE `booking_items`
  ADD CONSTRAINT `booking_items_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  ADD CONSTRAINT `booking_items_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`),
  ADD CONSTRAINT `booking_items_ibfk_3` FOREIGN KEY (`passenger_id`) REFERENCES `passengers` (`passenger_id`);

--
-- Constraints for table `cancellations`
--
ALTER TABLE `cancellations`
  ADD CONSTRAINT `cancellations_ibfk_1` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`);

--
-- Constraints for table `crew_assignments`
--
ALTER TABLE `crew_assignments`
  ADD CONSTRAINT `crew_assignments_ibfk_1` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`),
  ADD CONSTRAINT `crew_assignments_ibfk_2` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`crew_id`);

--
-- Constraints for table `delays`
--
ALTER TABLE `delays`
  ADD CONSTRAINT `delays_ibfk_1` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`);

--
-- Constraints for table `flights`
--
ALTER TABLE `flights`
  ADD CONSTRAINT `flights_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`route_id`),
  ADD CONSTRAINT `flights_ibfk_2` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`aircraft_id`);

--
-- Constraints for table `routes`
--
ALTER TABLE `routes`
  ADD CONSTRAINT `routes_ibfk_1` FOREIGN KEY (`origin_airport_id`) REFERENCES `airport` (`airport_id`),
  ADD CONSTRAINT `routes_ibfk_2` FOREIGN KEY (`destination_airport_id`) REFERENCES `airport` (`airport_id`);

--
-- Constraints for table `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`aircraft_id`);

--
-- Constraints for table `seat_reservations`
--
ALTER TABLE `seat_reservations`
  ADD CONSTRAINT `seat_reservations_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `booking_items` (`item_id`),
  ADD CONSTRAINT `seat_reservations_ibfk_2` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`seat_id`),
  ADD CONSTRAINT `seat_reservations_ibfk_3` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`);

--
-- Constraints for table `ticket_payments`
--
ALTER TABLE `ticket_payments`
  ADD CONSTRAINT `ticket_payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
