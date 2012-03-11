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
	
	# Wait 1 minute after starting kore before trying to relog.
	
	my $time = time();	
	$reconnect->{time} = $time + 60;
}

Plugins::register("Reconnect", "Version 0.1 r3", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop],
								['packet/received_character_ID_and_Map', \&connected],
								['disconnected', \&disconnected]);

								
sub unload
{
	Plugins::delHooks($hooks);
}

sub loop
{	
	my $time = time();	
	
	if(Network::DirectConnection::getState() == Network::NOT_CONNECTED and $config{XKore} == 0 and $reconnect->{time} < $time)
	{		
		my $relogTime = @{$reconnect->{timeout}}[$reconnect->{counter}];

		if($reconnect->{random}) {
			$relogTime += int(rand($reconnect->{random}));
		}

		# 10 seconds should be enough to initiate the connection with the server?
		$reconnect->{time} = $time + $relogTime + 10;
		Commands::run("relog $relogTime");
				
		my $sizeOf = @{$reconnect->{timeout}};	
		if($reconnect->{counter} < $sizeOf - 1) {
			$reconnect->{counter}++;
		}
	}
}

sub connected
{
	$reconnect->{counter} = 0;
}

sub disconnected
{
	my $time = time();

	# We have to wait a few seconds before sending the relog command,
	# otherwise kore will relog based on the value in timeouts.txt

	$reconnect->{time} = $time + 3;
}


1;