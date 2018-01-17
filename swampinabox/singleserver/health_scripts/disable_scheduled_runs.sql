# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

USE assessment;
SHOW events;
ALTER EVENT assessment.scheduler DISABLE; # disables scheduled runs
ALTER EVENT assessment.process_execution_records DISABLE; # disables A-Runs
