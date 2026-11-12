-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 12, 2026 at 08:50 PM
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
('73669fc5-45f7-4ebb-86d3-b494a506e757', '2026-11-11 19:13:35', '2026-11-11 19:15:52'),
('7bcf4658-7f12-4d62-982b-8fa5fb10059b', '2026-11-11 19:19:32', '2026-11-11 19:21:04'),
('dd9651d4-9539-4572-82ac-bf773e997d7b', '2026-11-11 19:14:10', '2026-11-11 19:15:32');

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
(435, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Create a task for Lead Report generation priority is High and due date is 20th dec\"}', '2026-11-11 19:13:41'),
(436, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"function_call\",\"callId\":\"call_mJcPnLKaaFyNDVNI3GclRjsE\",\"name\":\"create_task\",\"status\":\"completed\",\"arguments\":\"{\\\"title\\\":\\\"Lead Report generation\\\",\\\"description\\\":null,\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\"}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:13:41'),
(437, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"function_call_result\",\"name\":\"create_task\",\"callId\":\"call_mJcPnLKaaFyNDVNI3GclRjsE\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"duplicate\\\":false,\\\"task_id\\\":53,\\\"message\\\":\\\"Task created successfully\\\"}\"}}', '2026-11-11 19:13:41'),
(438, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"id\":\"msg_041a1fc234d4a48d006af4be64a94c87d2a3f68c638242ebd9\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Created task #53: Lead Report generation.\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:13:41'),
(439, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Create a task for Listing inactive users on the portal\"}', '2026-11-11 19:13:53'),
(440, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"function_call\",\"callId\":\"call_DKougsCrjQsSrx6LSc4gWSFP\",\"name\":\"create_task\",\"status\":\"completed\",\"arguments\":\"{\\\"title\\\":\\\"Listing inactive users on the portal\\\",\\\"description\\\":null,\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:13:53'),
(441, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"function_call_result\",\"name\":\"create_task\",\"callId\":\"call_DKougsCrjQsSrx6LSc4gWSFP\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"duplicate\\\":false,\\\"task_id\\\":54,\\\"message\\\":\\\"Task created successfully\\\"}\"}}', '2026-11-11 19:13:53'),
(442, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"id\":\"msg_041a1fc234d4a48d006af4be7045a887d2844b0a67286f7645\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Created task #54: Listing inactive users on the portal.\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:13:53'),
(443, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Create a task for Mapping of Order with users\"}', '2026-11-11 19:14:13'),
(444, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call\",\"callId\":\"call_9SraX9f8MRRvgxOArOUIew3W\",\"name\":\"create_task\",\"status\":\"completed\",\"arguments\":\"{\\\"title\\\":\\\"Mapping of Order with users\\\",\\\"description\\\":null,\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:14:13'),
(445, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call_result\",\"name\":\"create_task\",\"callId\":\"call_9SraX9f8MRRvgxOArOUIew3W\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"duplicate\\\":false,\\\"task_id\\\":55,\\\"message\\\":\\\"Task created successfully\\\"}\"}}', '2026-11-11 19:14:13'),
(446, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"id\":\"msg_033029545d263380006af4be856a7887d2923f823d4070b723\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Task created successfully. ID: 55\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:14:13'),
(447, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Create a task for JWT integration on Login API\"}', '2026-11-11 19:14:26'),
(448, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call\",\"callId\":\"call_vOFM2c54aoqMTnNzNGJRTx9C\",\"name\":\"create_task\",\"status\":\"completed\",\"arguments\":\"{\\\"title\\\":\\\"JWT integration on Login API\\\",\\\"description\\\":null,\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:14:26'),
(449, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call_result\",\"name\":\"create_task\",\"callId\":\"call_vOFM2c54aoqMTnNzNGJRTx9C\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"duplicate\\\":false,\\\"task_id\\\":56,\\\"message\\\":\\\"Task created successfully\\\"}\"}}', '2026-11-11 19:14:26'),
(450, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"id\":\"msg_033029545d263380006af4be92515087d2b7d36641a95a9ad5\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Task created successfully. ID: 56\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:14:26'),
(451, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Update the task if 56 for task priority high and due date is 20th dec\"}', '2026-11-11 19:15:18'),
(452, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call\",\"callId\":\"call_McdjtbICiMxBMpcbBHhDXgxc\",\"name\":\"update_task\",\"status\":\"completed\",\"arguments\":\"{\\\"task_id\\\":56,\\\"title\\\":null,\\\"description\\\":null,\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\"}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:15:18'),
(453, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call_result\",\"name\":\"update_task\",\"callId\":\"call_McdjtbICiMxBMpcbBHhDXgxc\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"message\\\":\\\"Task updated successfully\\\",\\\"task\\\":{\\\"id\\\":56,\\\"title\\\":\\\"JWT integration on Login API\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\"}}\"}}', '2026-11-11 19:15:18'),
(454, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"id\":\"msg_033029545d263380006af4bec647fc87d280dc4980865771bc\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Task 56 updated successfully. Priority set to high, due date set to 2026-12-20.\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:15:18'),
(455, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"get the list of all the task\"}', '2026-11-11 19:15:32'),
(456, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call\",\"callId\":\"call_0Qo0ZVYVy4cxtxSEN4jPBbo1\",\"name\":\"get_tasks\",\"status\":\"completed\",\"arguments\":\"{\\\"status\\\":null,\\\"priority\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:15:32'),
(457, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"type\":\"function_call_result\",\"name\":\"get_tasks\",\"callId\":\"call_0Qo0ZVYVy4cxtxSEN4jPBbo1\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"count\\\":4,\\\"tasks\\\":[{\\\"id\\\":56,\\\"title\\\":\\\"JWT integration on Login API\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null},{\\\"id\\\":55,\\\"title\\\":\\\"Mapping of Order with users\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":54,\\\"title\\\":\\\"Listing inactive users on the portal\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":53,\\\"title\\\":\\\"Lead Report generation\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null}],\\\"limit\\\":20}\"}}', '2026-11-11 19:15:32'),
(458, 'dd9651d4-9539-4572-82ac-bf773e997d7b', '{\"id\":\"msg_033029545d263380006af4bed4448487d284253a1a95484bc1\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Here are your tasks:\\n\\n1. ID 56 — JWT integration on Login API | pending | high | due 2026-12-20\\n2. ID 55 — Mapping of Order with users | pending | medium\\n3. ID 54 — Listing inactive users on the portal | pending | medium\\n4. ID 53 — Lead Report generation | pending | high | due 2026-12-20\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:15:32'),
(459, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"get only high priority task\"}', '2026-11-11 19:15:52'),
(460, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"function_call\",\"callId\":\"call_JFIddHNG20VVyyuyW8mSBWOQ\",\"name\":\"get_tasks\",\"status\":\"completed\",\"arguments\":\"{\\\"status\\\":null,\\\"priority\\\":\\\"high\\\"}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:15:52'),
(461, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"type\":\"function_call_result\",\"name\":\"get_tasks\",\"callId\":\"call_JFIddHNG20VVyyuyW8mSBWOQ\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"count\\\":2,\\\"tasks\\\":[{\\\"id\\\":56,\\\"title\\\":\\\"JWT integration on Login API\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null},{\\\"id\\\":53,\\\"title\\\":\\\"Lead Report generation\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null}],\\\"limit\\\":20}\"}}', '2026-11-11 19:15:52'),
(462, '73669fc5-45f7-4ebb-86d3-b494a506e757', '{\"id\":\"msg_041a1fc234d4a48d006af4bee79ea087d2b841086dbc7a6bf3\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"High priority tasks:\\n- #56 JWT integration on Login API — pending\\n- #53 Lead Report generation — pending\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:15:52'),
(463, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Create task for User login and registration function development\"}', '2026-11-11 19:19:38'),
(464, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call\",\"callId\":\"call_w51Lq77uCvIbpPnAKs9qTy7E\",\"name\":\"create_task\",\"status\":\"completed\",\"arguments\":\"{\\\"title\\\":\\\"User login and registration function development\\\",\\\"description\\\":null,\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:19:38'),
(465, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call_result\",\"name\":\"create_task\",\"callId\":\"call_w51Lq77uCvIbpPnAKs9qTy7E\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"duplicate\\\":false,\\\"task_id\\\":57,\\\"message\\\":\\\"Task created successfully\\\"}\"}}', '2026-11-11 19:19:38'),
(466, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"id\":\"msg_0a383c2a30f9bf09006af4bfc9c4a487d2aa380b8b15840204\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Created task #57: User login and registration function development\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:19:38'),
(467, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Create task for JWT Authentication implement on login api\"}', '2026-11-11 19:20:02'),
(468, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call\",\"callId\":\"call_qlvDHcEj1NzZNPxTwHIVx5BV\",\"name\":\"create_task\",\"status\":\"completed\",\"arguments\":\"{\\\"title\\\":\\\"JWT Authentication implement on login api\\\",\\\"description\\\":null,\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:20:02'),
(469, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call_result\",\"name\":\"create_task\",\"callId\":\"call_qlvDHcEj1NzZNPxTwHIVx5BV\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"duplicate\\\":false,\\\"task_id\\\":58,\\\"message\\\":\\\"Task created successfully\\\"}\"}}', '2026-11-11 19:20:02'),
(470, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"id\":\"msg_0a383c2a30f9bf09006af4bfe25e1087d29d33f30f31e7305d\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Created task #58: JWT Authentication implement on login api\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:20:02'),
(471, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"Update the task 58 for priority high and due date is 20th dec\"}', '2026-11-11 19:20:34'),
(472, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call\",\"callId\":\"call_eq7qyEBFUREdoK2Wa3drWfBY\",\"name\":\"update_task\",\"status\":\"completed\",\"arguments\":\"{\\\"task_id\\\":58,\\\"title\\\":null,\\\"description\\\":null,\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\"}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:20:34'),
(473, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call_result\",\"name\":\"update_task\",\"callId\":\"call_eq7qyEBFUREdoK2Wa3drWfBY\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"message\\\":\\\"Task updated successfully\\\",\\\"task\\\":{\\\"id\\\":58,\\\"title\\\":\\\"JWT Authentication implement on login api\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\"}}\"}}', '2026-11-11 19:20:34'),
(474, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"id\":\"msg_0a383c2a30f9bf09006af4bffe57f087d2abc65a4b14ef61f7\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Updated task #58: priority set to high, due date set to 2026-12-20.\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:20:34'),
(475, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"get the list of all the task\"}', '2026-11-11 19:20:49'),
(476, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call\",\"callId\":\"call_Ax5pFi9d5DsaVQh6wUJfHEy6\",\"name\":\"get_tasks\",\"status\":\"completed\",\"arguments\":\"{\\\"status\\\":null,\\\"priority\\\":null}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:20:49'),
(477, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call_result\",\"name\":\"get_tasks\",\"callId\":\"call_Ax5pFi9d5DsaVQh6wUJfHEy6\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"count\\\":6,\\\"tasks\\\":[{\\\"id\\\":58,\\\"title\\\":\\\"JWT Authentication implement on login api\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null},{\\\"id\\\":57,\\\"title\\\":\\\"User login and registration function development\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":56,\\\"title\\\":\\\"JWT integration on Login API\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null},{\\\"id\\\":55,\\\"title\\\":\\\"Mapping of Order with users\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":54,\\\"title\\\":\\\"Listing inactive users on the portal\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"medium\\\",\\\"due_date\\\":null,\\\"completed_at\\\":null},{\\\"id\\\":53,\\\"title\\\":\\\"Lead Report generation\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null}],\\\"limit\\\":20}\"}}', '2026-11-11 19:20:49'),
(478, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"id\":\"msg_0a383c2a30f9bf09006af4c010452c87d28db749bd24506e76\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"Here are your tasks:\\n\\n- #58 — JWT Authentication implement on login api — pending — high — due 2026-12-20\\n- #57 — User login and registration function development — pending — medium\\n- #56 — JWT integration on Login API — pending — high — due 2026-12-20\\n- #55 — Mapping of Order with users — pending — medium\\n- #54 — Listing inactive users on the portal — pending — medium\\n- #53 — Lead Report generation — pending — high — due 2026-12-20\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:20:49'),
(479, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"message\",\"role\":\"user\",\"content\":\"get the list of high priority task\"}', '2026-11-11 19:21:04'),
(480, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call\",\"callId\":\"call_aZyHPCQXZoIG7QKPRcXvkhBR\",\"name\":\"get_tasks\",\"status\":\"completed\",\"arguments\":\"{\\\"status\\\":null,\\\"priority\\\":\\\"high\\\"}\",\"providerData\":{\"type\":\"function_call\"}}', '2026-11-11 19:21:04'),
(481, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"type\":\"function_call_result\",\"name\":\"get_tasks\",\"callId\":\"call_aZyHPCQXZoIG7QKPRcXvkhBR\",\"status\":\"completed\",\"output\":{\"type\":\"text\",\"text\":\"{\\\"success\\\":true,\\\"count\\\":3,\\\"tasks\\\":[{\\\"id\\\":58,\\\"title\\\":\\\"JWT Authentication implement on login api\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null},{\\\"id\\\":56,\\\"title\\\":\\\"JWT integration on Login API\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null},{\\\"id\\\":53,\\\"title\\\":\\\"Lead Report generation\\\",\\\"description\\\":null,\\\"status\\\":\\\"pending\\\",\\\"priority\\\":\\\"high\\\",\\\"due_date\\\":\\\"2026-12-20\\\",\\\"completed_at\\\":null}],\\\"limit\\\":20}\"}}', '2026-11-11 19:21:04'),
(482, '7bcf4658-7f12-4d62-982b-8fa5fb10059b', '{\"id\":\"msg_0a383c2a30f9bf09006af4c020140487d2b078fc38503c44dd\",\"type\":\"message\",\"role\":\"assistant\",\"content\":[{\"type\":\"output_text\",\"text\":\"High-priority tasks:\\n\\n- #58 — JWT Authentication implement on login api — pending — due 2026-12-20\\n- #56 — JWT integration on Login API — pending — due 2026-12-20\\n- #53 — Lead Report generation — pending — due 2026-12-20\",\"providerData\":{\"annotations\":[],\"logprobs\":[]}}],\"status\":\"completed\",\"phase\":\"final_answer\",\"providerData\":{\"phase\":\"final_answer\"}}', '2026-11-11 19:21:04');

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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `idempotency_key` varchar(100) DEFAULT NULL,
  `request_hash` char(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `title`, `description`, `status`, `priority`, `due_date`, `completed_at`, `created_at`, `updated_at`, `idempotency_key`, `request_hash`) VALUES
(53, 'Lead Report generation', NULL, 'pending', 'high', '2026-12-20', NULL, '2026-11-11 19:13:39', '2026-11-11 19:13:39', '2f2c7edf-9741-4c2b-b42e-6a43e1f98cbb', '47c7a7e5e35dfc0db5144b2a7c471c8b19079f317938adb2ead967ec2bc2b3ab'),
(54, 'Listing inactive users on the portal', NULL, 'pending', 'medium', NULL, NULL, '2026-11-11 19:13:51', '2026-11-11 19:13:51', '5a608815-1e17-4c22-83cc-8095e84b93ca', '7a8386f93c33e014540125be8d1c6b20dec61379612792ee6c68ee8099e6fa90'),
(55, 'Mapping of Order with users', NULL, 'pending', 'medium', NULL, NULL, '2026-11-11 19:14:12', '2026-11-11 19:14:12', 'e095f2d7-18fa-45f4-a656-7707a851dfb5', '3de902c10ca6710130ed170ef5f4dd67a82d426214722339d7ec499aa88b5c7a'),
(56, 'JWT integration on Login API', NULL, 'pending', 'high', '2026-12-20', NULL, '2026-11-11 19:14:24', '2026-11-11 19:15:17', '8608c499-1d38-4bbc-a490-4d540f2d6a21', '86af86b547927bcb5d379e5e6d705e85ef8e71824d1256c5b6a6414efc59d3ac'),
(57, 'User login and registration function development', NULL, 'pending', 'medium', NULL, NULL, '2026-11-11 19:19:36', '2026-11-11 19:19:36', 'c8e57a16-c8d8-4f63-b887-8b52a19278b2', 'b3a2c712cd4151113ac362d516cab691eb4593786447748ba65c65111e1fc5d8'),
(58, 'JWT Authentication implement on login api', NULL, 'pending', 'high', '2026-12-20', NULL, '2026-11-11 19:20:01', '2026-11-11 19:20:28', 'be3372a2-fa28-4ade-8067-d4b2929fcbea', 'e57524b7e4527ded79c8488c352e798996dc33cb57a26abc2ff416e1a267b194');

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
  ADD UNIQUE KEY `uq_task_idempotency` (`idempotency_key`),
  ADD KEY `idx_status_priority` (`status`,`priority`),
  ADD KEY `idx_due_date` (`due_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `conversation_items`
--
ALTER TABLE `conversation_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=483;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

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
