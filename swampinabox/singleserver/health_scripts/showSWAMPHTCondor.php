<?php
function get_condor_submit_node() {
	$command = "condor_status -schedd -af Name";
	exec($command, $output, $returnVar);
	$submit_node = "";
	if (($returnVar == 0) && (! empty($output))) {
		$submit_node = str_replace('"', '', $output[0]);
	}
	return $submit_node;
}

function get_condor_exec_nodes() {
	$command = "condor_status -af Machine -constraint 'SlotType == \"Partitionable\"'";
	exec($command, $output, $returnVar);
	$exec_nodes = [];
	if (($returnVar == 0) && (! empty($output))) {
		for ($i = 0; $i < sizeof($output); $i++) {
			$exec_nodes[$i] = str_replace('"', '', $output[$i]);
		}
	}
	return $exec_nodes;
}

function get_swamp_data_node() {
	// FIXME how should this be obtained in the multi host instance of swamp
	$data_node = gethostname();
	return $data_node;
}

function get_condor_collector_host() {
	// FIXME how should this be obtained in the multi host instance of swamp
	$collector_host = gethostname();
	return $collector_host;
}

$collector_host = get_condor_collector_host();

$global_fields['assessment'] = [
	'Name', 
	'SWAMP_vmu_assessment_vmhostname', 
	'SWAMP_vmu_assessment_status'
];
$global_constraint['assessment'] = "-constraint \"isString(SWAMP_vmu_assessment_status)\"";
$global_fields['viewer'] = [
	'Name',
	'SWAMP_vmu_viewer_vmhostname',
	'SWAMP_vmu_viewer_name',
	'SWAMP_vmu_viewer_state',
	'SWAMP_vmu_viewer_status',
	'SWAMP_vmu_viewer_vmip',
	'SWAMP_vmu_viewer_project',
	'SWAMP_vmu_viewer_instance_uuid',
	'SWAMP_vmu_viewer_apikey',
	'SWAMP_vmu_viewer_url_uuid'
];
$global_constraint['viewer'] = "-constraint \"isString(SWAMP_vmu_viewer_status)\"";

function get_collector_records($collector_host, $title) {
	global $global_fields, $global_constraint;
	$fieldnames = [];
	$crecords = [];
	$fields = $global_fields[$title];
	$constraint = $global_constraint[$title];
	$sortfield = "SWAMP_vmu_" . $title . "_vmhostname";
	$command = "condor_status -pool $collector_host -sort $sortfield -generic -af:V, ";
	foreach ($fields as $field) {
		$command .= ' ' . $field;
	}
	if (! empty($constraint)) {
		$command .= ' ' . $constraint;
	}
	exec($command, $output, $returnVar);
	if (($returnVar == 0) && (! empty($output))) {
		$prefix = "SWAMP_vmu_" . $title . "_";
		$fieldnames[0] = 'execrunuid';
		for ($i = 1; $i < sizeof($fields); $i++) {
			$fieldnames[$i] = str_replace($prefix, '', $fields[$i]);
		}
		for ($i = 0; $i < sizeof($output); $i++) {
			$crecord = [];
			$temp = preg_split("/[\s]+/", $output[$i], sizeof($fieldnames), PREG_SPLIT_NO_EMPTY);
			for ($n = 0; $n < sizeof($fieldnames); $n++) {
				$fieldname = $fieldnames[$n];
				$crecord[$fieldname] = str_replace('"', '',  $temp[$n]);
			}
			$crecords[] = $crecord;
		}
	}
	$ra =  array('fieldnames' => $fieldnames, 'data' => $crecords);
	return $ra;
}

function get_condor_queue() {
	$fieldnames = [];
	$jobs = [];
	$summary = [];
	$command = "condor_q";
	exec($command, $output, $returnVar);
	if (($returnVar == 0) && (! empty($output))) {
		$start = 0;
		for ($i = 0; $i < sizeof($output); $i++) {
			// skip empty lines
			if (empty($output[$i])) {
				continue;
			}
			// collect fieldnames
			if (preg_match('/ID/', $output[$i])) {
				$start = 1;
				$fieldnames = preg_split("/[\s]+/", $output[$i], -1, PREG_SPLIT_NO_EMPTY);
			}
			// collect job summary
			elseif (preg_match('/jobs;/', $output[$i])) {
				$start = 0;
				$temp = preg_split("/[\s]+/", $output[$i], -1, PREG_SPLIT_NO_EMPTY);
				for ($n = 0; $n < sizeof($temp); $n += 2) {
					$name = str_replace('"', '', $temp[$n+1]);
					$name = str_replace(';', '', $name);
					$name = str_replace(',', '', $name);
					$summary[$name] = $temp[$n];
				}
			}
			// collect job records
			elseif ($start == 1) {
				$job = [];
				$temp = preg_split("/[\s]+/", $output[$i], -1, PREG_SPLIT_NO_EMPTY);
				$j = 0;
				for ($n = 0; $n < sizeof($fieldnames); $n++) {
					$fieldname = $fieldnames[$n];
					if ($fieldname == "SUBMITTED") {
						$job[$fieldname] = $temp[$j] . " " . $temp[$j+1];
						$j += 1;
					}
					else {
						$job[$fieldname] = $temp[$j];
					}
					$j += 1;
				}
				$jobs[] = $job; 
			}
		}
	}
	$ra = array('fieldnames' => $fieldnames, 'data' => $jobs, 'summary' => $summary);
	return $ra;
}

function _sort_on_clusterid($commandfield) {
	return function($a, $b) use ($commandfield) {
		$acommand = $a[$commandfield];
		$bcommand = $b[$commandfield];
		$aparts = preg_split("/[\s]+/", $acommand, -1, PREG_SPLIT_NO_EMPTY);
		$bparts = preg_split("/[\s]+/", $bcommand, -1, PREG_SPLIT_NO_EMPTY);
		if (sizeof($aparts) >= 3) {
			// either clusterid procid or clusterid procid [a|v|m]swamp-clusterid-procid
			// sort on clusterid
			list($acid, $apid, $aname) = array_slice($aparts, -3);
			if (is_numeric($aname)) {
				$acid = $apid;
			}
		}
		else {
			// sort on last element
			$temp = array_slice($aparts, -1);
			$acid = array_pop($temp);
		}
		if (sizeof($bparts) >= 3) {
			list($bcid, $bpid, $bname) = array_slice($bparts, -3);
			if (is_numeric($bname)) {
				$bcid = $bpid;
			}
		}
		else {
			$temp = array_slice($bparts, -1);
			$bcid = array_pop($temp);
		}
		if (is_numeric($acid) && is_numeric($bcid)) {
			if ($acid < $bcid) {
				return -1;
			}
			elseif ($acid > $bcid) {
				return 1;
			}
			return 0;
		}
		else {
			return strcmp($acid, $bcid); 
		}
	};
}

function get_swamp_processes() {
	$fieldnames = [];
	$vmuA = [];
	$vmuV = [];
	$vmu = [];
	$java = [];
	$other = [];
	$command = "ps aux | egrep 'PID|vmu_|java' | grep -v grep";
	exec($command, $output, $returnVar);
	if (($returnVar == 0) && (! empty($output))) {
		$commandfield = "";
		for ($i = 0; $i < sizeof($output); $i++) {
			// skip empty lines
			if (empty($output[$i])) {
				continue;
			}
			// collect field names
			if (preg_match('/PID/', $output[$i])) {
				$fieldnames = preg_split("/[\s]+/", $output[$i], -1, PREG_SPLIT_NO_EMPTY);
			}
			else {
				$process = [];
				// collect all of the COMMAND field in the last element of the split
				$temp = preg_split("/[\s]+/", $output[$i], sizeof($fieldnames), PREG_SPLIT_NO_EMPTY);
				for ($n = 0; $n < sizeof($fieldnames); $n++) {
					$fieldname = $fieldnames[$n];
					$process[$fieldname] = $temp[$n];
					$commandfield = $fieldname;
				}
				if (preg_match("/vmu_.*Assessment/", $process[$commandfield])) {
					$vmuA[] = $process;
				}
				elseif (preg_match("/vmu_.*Viewer/", $process[$commandfield])) {
					$vmuV[] = $process;
				}
				elseif (preg_match("/vmu_.*.pl/", $process[$commandfield])) {
					$vmu[] = $process;
				}
				elseif (preg_match("/java/", $process[$commandfield])) {
					$java[] = $process;
				}
				else {
					$other[] = $process;
				}
			}
		}
		// sort vmuA and vmuV on clusterid at end of COMMAND field
		usort($vmuA, _sort_on_clusterid($commandfield));
		usort($vmuV, _sort_on_clusterid($commandfield));
		$processes = array_merge($vmuA, $vmuV, $vmu, $java, $other);
	}
	$ra = array('fieldnames' => $fieldnames, 'data' => $processes);
	return $ra;
}

function get_virtual_machines() {
	$fieldnames = [];
	$machines = [];
	$command = "virsh list --all";
	exec($command, $output, $returnVar);
	if (($returnVar == 0) && (! empty($output))) {
		for ($i = 0; $i < sizeof($output); $i++) {
			// skipt empty lines
			if (empty($output[$i])) {
				continue;
			}
			// skip --- lines
			if (preg_match('/--/', $output[$i])) {
				continue;
			}
			// collect field names
			if (preg_match('/Id/', $output[$i])) {
				$fieldnames = preg_split("/[\s]+/", $output[$i], -1, PREG_SPLIT_NO_EMPTY);
			}
			// collect machines
			else {
				$machine = [];
				$temp = preg_split("/[\s]+/", $output[$i], -1, PREG_SPLIT_NO_EMPTY);
				for ($n = 0; $n < sizeof($fieldnames); $n++) {
					$fieldname = $fieldnames[$n];
					$machine[$fieldname] = $temp[$n];
				}
				$machines[] = $machine;
			}
		}
		// this is a bit of a hack to assume there is a field called Name to sort on
		usort($machines, function($a, $b) { return strcmp($a['Name'], $b['Name']); });
	}
	$ra =  array('fieldnames' => $fieldnames, 'data' => $machines);
	return $ra;
}

function get_submit_job_dirs() {
	// this is a hack because unix/linux ls command does not display field names
	// ls -lrt is presumably guaranteed to produce exactly the following columns
	// log field is added after the ls command by finding the *swamp-<clusterid>-<procid>.log file
	$fieldnames = ['permissions', 'links', 'owner', 'group', 'size', 'modtime', 'dir', 'log'];
	$jobdirs = [];
	$command = "ls -lrt /opt/swamp/run";
	exec($command, $output, $returnVar);
	if (($returnVar == 0) && (! empty($output))) {
		for ($i = 0; $i < sizeof($output); $i++) {
			if (empty($output[$i])) {
				continue;
			}
			if (preg_match('/total/', $output[$i])) {
				continue;
			}
			if (preg_match('/swamp_monitor/', $output[$i])) {
				continue;
			}
			$jobdir = [];
			// modtime parts and dir are in part1[5]
			$part1 = preg_split("/[\s]+/", $output[$i], 6, PREG_SPLIT_NO_EMPTY);
			// modtime = part2[0,1,2]
			// dir = part2[3]
			$part2 = preg_split("/[\s]+/", $part1[5], -1, PREG_SPLIT_NO_EMPTY);
			for ($n = 0; $n < sizeof($fieldnames); $n++) {
				$fieldname = $fieldnames[$n];
				if ($n <= 4) {
					$jobdir[$fieldname] = $part1[$n];
				}
				elseif ($n == 5) {
					$jobdir[$fieldname] = $part2[0] . ' ' . $part2[1] . ' ' . $part2[2];
				}
				else {
					$jobdir[$fieldname] = $part2[3];
				}
			}
			// look in dir for *swamp-<clusterid>-<procid>.log
			$jobdir['log'] = 'n/a';
			if (($dh = opendir('/opt/swamp/run/' . $jobdir['dir'])) !== false) {
				while (false !== ($file = readdir($dh))) {
					if (preg_match('/^[a|m|v]swamp\-\d+\-\d+\.log$/', $file)) {
						$log = str_replace('.log', '', $file);
						if (! $log) {
							$log = 'n/m';
						}
						$jobdir['log'] = $log;
						break;
					}
				}
				closedir($dh);	
			}
			else {
				$jobdir['log'] = 'opendir failed';
			}
			$jobdirs[] = $jobdir;
		}
	}
	$ra = array('fieldnames' => $fieldnames, 'data' => $jobdirs);
	return $ra;
}

function show_result($title, $ra) {
	if (empty($ra)) {
		return;
	}
	print "$title fieldnames: ";
	$fieldnames = $ra['fieldnames'];
	for ($i = 0; $i < sizeof($fieldnames); $i++) {
		print "$fieldnames[$i] ";
	}
	print "\n";
	print "$title data:\n";
	$data = $ra['data'];
	for ($i = 0; $i < sizeof($data); $i++) {
		$datum = $data[$i];
		foreach ($datum as $key => $value) {
			print "$value ";
		}
		print "\n";
	}
	print "\n";
	return $ra;
}

function show_results($ra) {
	$s = show_result("condor queue", $ra['condorqueue']);
	// condor queue summary
	$summary = $s['summary'];
	print "condor queue summary: ";
	foreach ($summary as $key => $value) {
		print "$key $value ";
	}
	print "\n\n";
	show_result("swamp processes", $ra['swampprocesses']);
	show_result("virsh list", $ra['virtualmachines']);
	show_result("submit job directories", $ra['submitjobdirs']);
	show_result("assessment collector", $ra['assessments']);
	show_result("viewer collector", $ra['viewers']);
}

function get_results() {
	global $collector_host;
	// condor queue
	$cq = get_condor_queue();
	// swamp processes
	$sp = get_swamp_processes();
	// virsh list
	$vm = get_virtual_machines();
	// submit job dirs
	$sjd = get_submit_job_dirs();
	// assessment collector	
	$acr = get_collector_records($collector_host, 'assessment');
	// viewer collector	
	$vcr = get_collector_records($collector_host, 'viewer');
	$ra = array(
		'condorqueue' => $cq, 
		'swampprocesses' => $sp, 
		'virtualmachines' => $vm,
		'submitjobdirs' => $sjd,
		'assessments' => $acr,
		'viewers' => $vcr
	);
	return $ra;
}

$ra = get_results();
show_results($ra);

?>
