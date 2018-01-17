# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

# Add Code DX
INSERT INTO viewer_store.viewer (viewer_uuid, viewer_owner_uuid, name, viewer_sharing_status)
  VALUES ('4221533e-865a-11e3-88bb-001a4a81450b', '80835e30-d527-11e2-8b8b-0800200c9a66', 'CodeDX', 'PUBLIC');
INSERT INTO viewer_store.viewer_version (viewer_version_uuid, viewer_uuid,
                    version_string,
                    invocation_cmd, sign_in_cmd, add_user_cmd, add_result_cmd,
                    viewer_path, viewer_checksum,
                    viewer_db_path, viewer_db_checksum)
            VALUES ('5d0fb63c-865a-11e3-88bb-001a4a81450b', '4221533e-865a-11e3-88bb-001a4a81450b',
                    '1',
                    'invocation_cmd', 'sign_in_cmd', 'add_user_cmd', 'add_result_cmd',
                    'viewer_path', 'viewer_checksum',
                    'viewer_db_path', 'viewer_db_checksum');
