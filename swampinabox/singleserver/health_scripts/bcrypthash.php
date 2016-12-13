#!/usr/bin/env php

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

<?php
	$clear_password = 'P@$$w0rd123';
	$hash_password = password_hash($clear_password, PASSWORD_BCRYPT);
	echo "clear: <$clear_password> hash: <$hash_password>\n";

	$result = password_verify($clear_password, $hash_password);
	echo "verify: <$result>\n";

	$hash_password = '$2y$10$iPlIe8zRGeB34sOnV7btW.b/8kzY/spztS7OWGxBg/o.CnHCzw5v6';
	$result = password_verify($clear_password, $hash_password);
	echo "verify: <$result>\n";
?>
