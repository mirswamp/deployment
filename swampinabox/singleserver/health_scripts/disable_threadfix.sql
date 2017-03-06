# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

# Disable
# Remove ThreadFix
DELETE FROM tool_shed.tool_viewer_incompatibility WHERE viewer_uuid = 'a0e1d0fb-bfb2-11e5-bf72-001a4a814413';
DELETE FROM viewer_store.viewer_version WHERE viewer_uuid = 'a0e1d0fb-bfb2-11e5-bf72-001a4a814413';
DELETE FROM viewer_store.viewer WHERE viewer_uuid = 'a0e1d0fb-bfb2-11e5-bf72-001a4a814413';
