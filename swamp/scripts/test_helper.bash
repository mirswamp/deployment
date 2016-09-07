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

