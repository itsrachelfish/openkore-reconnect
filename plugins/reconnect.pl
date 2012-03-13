package Reconnect;

# Perl includes
use strict;

# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;


our $reconnect;

# We need to check if these variables haven't been defined yet.
# Otherwise Kore will overwrite them if the plugin is ever reloaded.
if(ref($reconnect) ne 'HASH')
{
	$reconnect = {};
	
	$reconnect->{timeout} = [30,	# 30 seconds
							 60,	# 1 minute
							 60,	# 1 minute
							 180,	# 3 minutes
							 180,	# 3 minutes
							 300,	# 5 minutes
							 300,	# 5 minutes
							 900, 	# 15 minutes
							 900, 	# 15 minutes
							 1800,	# 30 minutes
							 3600];	# 1 hour


	$reconnect->{random} = 30;
	$reconnect->{counter} = 0;	
}

Plugins::register("Reconnect", "Version 0.1 r5", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop],
								['packet/received_character_ID_and_Map', \&connected]);

								
sub unload
{
	Plugins::delHooks($hooks);
}

sub loop
{	
	my $time = time();	
	
	if(Network::DirectConnection::getState() == Network::NOT_CONNECTED and $reconnect->{time} < $time)
	{
		print("NOT CONNECTED?!?!?!\n");
		my $reconnectTime = @{$reconnect->{timeout}}[$reconnect->{counter}];

		if($reconnect->{random}) {
			$reconnectTime += int(rand($reconnect->{random}));
		}

		print("RECONNECT TIME SET TO $timeout{reconnect}->{timeout} !!!!!!!!!!!!!!!!!!!!!!\n");
		$reconnect->{time} = $time + $timeout{reconnect}->{timeout};
		$timeout{reconnect} = {'timeout' => $reconnectTime};
		print("SET TIMEOUT TO $reconnectTime !!!!!!!!!!!!!!!!!!!!!!!!!\n");
		
		my $sizeOf = @{$reconnect->{timeout}};	
		if($reconnect->{counter} < $sizeOf - 1) {
			$reconnect->{counter}++;
		}
	}
}

sub connected
{
	my $time = time();	
	print("COUNTER RESET!!!!!!!!!!!!!!!!!!!!!!!!!!1\n");
	$reconnect->{counter} = 0;
	
	my $reconnectTime = @{$reconnect->{timeout}}[$reconnect->{counter}];

	if($reconnect->{random}) {
		$reconnectTime += int(rand($reconnect->{random}));
	}

	$timeout{reconnect} = {'timeout' => $reconnectTime};
	print("SET TIMEOUT TO $reconnectTime !!!!!!!!!!!!!!!!!!!!!!!!!\n");
}

1;