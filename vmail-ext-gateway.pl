#!/usr/bin/perl

# Copyright 2012 Marcin Adamowicz <martin.adamowicz@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


##### Description #####
# This AGI script verifies external access to voicemail boxes.
# Configuration file /etc/asterisk/voicemail-external.conf. 
# Dialplan part required.

use Asterisk::AGI;

my $AGI = new Asterisk::AGI;
my %input = $AGI->ReadParse();

my $vmail_ext = "./voicemail-external.conf";
my $mobile = $ARGV[0];                                  # External CallerID.

# Check if mobile number.
if ( $mobile !~ /^\d\d\d\d\d\d\d\d\d$/) {
	$AGI->set_variables('VmailAccount',"locked");   # Lock if not mobile.
	exit 0;                                         # Interrupt script.
}

# Configuration into @vmails.
open FILE, "< $vmail_ext" or die "Cannot open file: $vmail_ext";
	my @vmails = <FILE>;
	close FILE;

foreach (@vmails) {

	next if $_ !~ /^mobile/;                        # Drop non-mobile line.
	next if $_ !~ /$mobile/; # Next iteration if it isn't number we're looking for.
                                 # This part has to be tested against incorrect numbers in conf file.

	$_ =~ s/\s//iog;                                # Remove space.
	$_ =~ s/mobile=>//iog;                          # Remove "mobile=>"


	(my @vmail_user) = split (/\,/, $_);
	
		# If $vmail_user[1] is 4 digits number send it dialplan.
                # Otherwise lock.  
		if ( $vmail_user[1] !~ /^\d\d\d\d$/) {
			$AGI->set_variables('VmailAccount',"locked");
			exit 0;
		} else {
			$AGI->set_variable('VmailAccount',$vmail_user[1]);
			exit 0;
		}
}

# This is executed each time when $vmail_ext doesn't contain mobile number.
$AGI->set_variables('VmailAccount',"locked");
exit 0;
