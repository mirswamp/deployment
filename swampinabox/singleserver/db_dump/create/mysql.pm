package mysql;
use strict;
use warnings;

sub service_status { my ($service, $verbose) = @_ ;
        my $result = `service $service status`;
        if ($result =~ m/MySQL running|is running/) {
                print "status - $service running\n" if ($verbose);
                return 'running';
        }
        if ($result =~ m/not running|stopped/) {
                print "status - $service stopped\n" if ($verbose);
                return 'stopped';
        }
        return 'error';
}

sub start_service { my ($service, $verbose) = @_ ;
        my $status = service_status($service, $verbose);
        if ($status eq 'running') {
                print "start - $service already running\n" if ($verbose);
                return 1;
        }
        elsif ($status eq 'stopped') {
                my $result = `service $service start`;
                if ($result =~ m/OK|SUCCESS/) {
                        print "start - $service started\n" if ($verbose);
                        return 1;
                }
                print "start - $service failed to start\n";
                return 0;
        }
        print "start - $service status failed\n";
        return 0;
}

sub stop_service { my ($service, $verbose) = @_ ;
        my $status = service_status($service, $verbose);
        if ($status eq 'stopped') {
                print "stop - $service already stopped\n" if ($verbose);
                return 1;
        }
        elsif ($status eq 'running') {
                my $result = `service $service stop`;
                if ($result =~ m/OK|SUCCESS/) {
                        print "stop - $service stopped\n" if ($verbose);
                        return 1;
                }
                print "stop - $service failed to stop\n";
                return 0;
        }
        print "stop - $service status failed\n";
        return 0;
}

1;
