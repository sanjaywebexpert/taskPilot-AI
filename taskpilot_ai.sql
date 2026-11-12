-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 09, 2026 at 12:16 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `taskpilot_ai`
--

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` char(36) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `conversations`
--

INSERT INTO `conversations` (`id`, `created_at`, `updated_at`) VALUES
('48850ab1-80b3-4654-8857-a0546f0bc21a', '2026-11-09 04:27:24', '2026-11-09 04:31:57'),
('ccdc15e1-64f7-4e76-b27c-92aac4aa330e', '2026-11-09 04:33:25', '2026-11-09 04:36:04');

-- --------------------------------------------------------

--
-- Table structure for table `conversation_items`
--

CREATE TABLE `conversation_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` char(36) NOT NULL,
  `item_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`item_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `conversation_items`
--

INSERT INTO `conversation_items` (`id`, `conversation_id`, `item_data`, `created_at`) VALUES
(1, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Show me my pending tasks and include task IDs.\"}', '2026-11-09 04:27:27'),
(2, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"type\":\"function_call\",\"callId\":\"call_MvUmhT3W40ryBxEuk5TQ7uV4\",\"name\":\"get_tasks\",\"status\":\"completed\",\"arguments\":\"{\\\"status\\\":\\\"pending\\\",\\\"priority\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-09 04:27:27'),
(3, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"type\":\"function_call_result\",\"name\":\"get_tasks\",\"callId\":\"call_MvUmhT3W40ryBxEuk5TQ7uV4\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"count\\\":4,\\\"tasks\\\":[{\\\"id\\\":8,\\\"title\\\":\\\"Deep testing of Login ai and JWT\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"low\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":7,\\\"title\\\":\\\"Apply JWT User Authentication on Login API\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":4,\\\"title\\\":\\\"Implement JWT Authentication\\\",\\\"description\\\":\\\"Add JWT authentication to the login API\\\",\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-11-15\\\",\\\"completed_at\\\":null},{\\\"id\\\":3,\\\"title\\\":\\\"Write API Documentation\\\",\\\"description\\\":\\\"Document all REST API endpoints\\\",\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"low\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null}],\\\"limit\\\":20}\"}}', '2026-11-09 04:27:27'),
(4, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"id\":\"msg_09b7bfa257e9b5c0006af14baedf2c87d28e9a287ed2dabe57\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Pending tasks:\\n\\n- ID 8 — Deep testing of Login ai and JWT\\n- ID 7 — Apply JWT User Authentication on Login API\\n- ID 4 — Implement JWT Authentication\\n- ID 3 — Write API Documentation\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-09 04:27:27'),
(5, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"What is the task ID of the second task you listed?\"}', '2026-11-09 04:28:22'),
(6, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"id\":\"msg_09b7bfa257e9b5c0006af14be5a78c87d2a9cc8dafbbe99eb8\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"7\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-09 04:28:22'),
(7, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"What was the first task you listed earlier?\"}', '2026-11-09 04:30:16'),
(8, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"id\":\"msg_09b7bfa257e9b5c0006af14c573b9c87d28d439c7e9ad29aa2\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"ID 8 — Deep testing of Login ai and JWT\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-09 04:30:16'),
(9, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"What was the first task you listed earlier?\"}', '2026-11-09 04:31:57'),
(10, '48850ab1-80b3-4654-8857-a0546f0bc21a', '{\"id\":\"msg_09b7bfa257e9b5c0006af14cbc80ec87d299b2c8a299bcdbf0\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"ID 8 — Deep testing of Login ai and JWT\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-09 04:31:57'),
(11, 'ccdc15e1-64f7-4e76-b27c-92aac4aa330e', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Show me my pending tasks and include task IDs.\"}', '2026-11-09 04:33:29'),
(12, 'ccdc15e1-64f7-4e76-b27c-92aac4aa330e', '{\"type\":\"function_call\",\"callId\":\"call_fBIWh39XsaFveYEF6AESZAJe\",\"name\":\"get_tasks\",\"status\":\"completed\",\"arguments\":\"{\\\"status\\\":\\\"pending\\\",\\\"priority\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-09 04:33:29'),
(13, 'ccdc15e1-64f7-4e76-b27c-92aac4aa330e', '{\"type\":\"function_call_result\",\"name\":\"get_tasks\",\"callId\":\"call_fBIWh39XsaFveYEF6AESZAJe\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"count\\\":4,\\\"tasks\\\":[{\\\"id\\\":8,\\\"title\\\":\\\"Deep testing of Login ai and JWT\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"low\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":7,\\\"title\\\":\\\"Apply JWT User Authentication on Login API\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":4,\\\"title\\\":\\\"Implement JWT Authentication\\\",\\\"description\\\":\\\"Add JWT authentication to the login API\\\",\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-11-15\\\",\\\"completed_at\\\":null},{\\\"id\\\":3,\\\"title\\\":\\\"Write API Documentation\\\",\\\"description\\\":\\\"Document all REST API endpoints\\\",\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"low\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null}],\\\"limit\\\":20}\"}}', '2026-11-09 04:33:29'),
(14, 'ccdc15e1-64f7-4e76-b27c-92aac4aa330e', '{\"id\":\"msg_0fe225f43171dc4b006af14d18194c87d298b088e7978ac8b7\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Pending tasks:\\n\\n- ID 8 — Deep testing of Login ai and JWT\\n- ID 7 — Apply JWT User Authentication on Login API\\n- ID 4 — Implement JWT Authentication\\n- ID 3 — Write API Documentation\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-09 04:33:29'),
(15, 'ccdc15e1-64f7-4e76-b27c-92aac4aa330e', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"What is the task ID of the second task you listed?.\"}', '2026-11-09 04:36:04'),
(16, 'ccdc15e1-64f7-4e76-b27c-92aac4aa330e', '{\"id\":\"msg_0fe225f43171dc4b006af14db3578c87d29bb2dc049a3dcbfb\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"7\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-09 04:36:04');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('pending','in_progress','completed') NOT NULL DEFAULT 'pending',
  `priority` enum('low','medium','high') NOT NULL DEFAULT 'medium',
  `due_date` date DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `title`, `description`, `status`, `priority`, `due_date`, `completed_at`, `created_at`, `updated_at`) VALUES
(1, 'Complete Login API', 'Implement JWT authentication', 'completed', 'high', '2026-11-15', '2026-11-09 09:26:59', '2026-11-07 12:36:16', '2026-11-09 03:56:59'),
(2, 'Optimize MySQL Queries', 'Review slow queries and add indexes', 'in_progress', 'medium', '2026-11-18', NULL, '2026-11-07 12:36:16', '2026-11-07 12:36:16'),
(3, 'Write API Documentation', 'Document all REST API endpoints', 'pending', 'low', NULL, NULL, '2026-11-07 12:36:16', '2026-11-07 12:36:16'),
(4, 'Implement JWT Authentication', 'Add JWT authentication to the login API', 'pending', 'high', '2026-11-15', NULL, '2026-11-07 13:43:12', '2026-11-07 13:43:12'),
(5, 'Review Node.js Backend Code', NULL, 'completed', 'low', '2026-11-20', '2026-11-07 20:25:08', '2026-11-07 13:52:35', '2026-11-07 14:57:15'),
(7, 'Apply JWT User Authentication on Login API', NULL, 'pending', 'high', NULL, NULL, '2026-11-09 03:52:44', '2026-11-09 03:52:44'),
(8, 'Deep testing of Login ai and JWT', NULL, 'pending', 'low', NULL, NULL, '2026-11-09 03:55:20', '2026-11-09 03:55:20');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `conversation_items`
--
ALTER TABLE `conversation_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation_items` (`conversation_id`,`id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status_priority` (`status`,`priority`),
  ADD KEY `idx_due_date` (`due_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `conversation_items`
--
ALTER TABLE `conversation_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `conversation_items`
--
ALTER TABLE `conversation_items`
  ADD CONSTRAINT `fk_conversation_items` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
