# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

# A function that can be called to show output that failed f
# from a bats test (e.g. run test;[ $status -ne 0] || flunk $output)
flunk() {
    { 
		if [ "$#" -eq 0 ]; then cat -
			else echo "$@"
        fi
  }
  return 1
}

