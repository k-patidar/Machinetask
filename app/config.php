<?php
// Database configuration
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_NAME', getenv('DB_NAME') ?: 'webapp_db');
define('DB_USER', getenv('DB_USER') ?: 'admin');
define('DB_PASS', getenv('DB_PASS') ?: 'password');

// Application configuration
define('APP_NAME', 'PHP Web Application');
define('APP_VERSION', '1.0.0');
?>