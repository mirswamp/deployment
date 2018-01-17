# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

# Enable
# Threadfix: Add viewer and viewer_version records
# List as incompatible with all installed tools except clang
INSERT INTO viewer_store.viewer (viewer_uuid, viewer_owner_uuid, name, viewer_sharing_status)
  VALUES ('a0e1d0fb-bfb2-11e5-bf72-001a4a814413', '80835e30-d527-11e2-8b8b-0800200c9a66', 'ThreadFix', 'PUBLIC');
INSERT INTO viewer_store.viewer_version (viewer_version_uuid, viewer_uuid, version_string)
  VALUES ('b0e931d7-bfb2-11e5-bf72-001a4a814413', 'a0e1d0fb-bfb2-11e5-bf72-001a4a814413', '1');
INSERT INTO tool_shed.tool_viewer_incompatibility (tool_uuid, viewer_uuid)
  SELECT tool_uuid, 'a0e1d0fb-bfb2-11e5-bf72-001a4a814413' FROM tool_shed.tool WHERE tool_uuid != 'f212557c-3050-11e3-9a3e-001a4a81450b';
				 
