#!/usr/bin/perl

# Detect hard drives, and load any extra modules required (Eg. SCSI)
chdir "/proc/ide";
# Obtains a list of the ide channels on the board
@ide = glob "ide*";
# Obtains a list of the devices running on each channel
foreach $ide (@ide) {
	# print "$ide\n`"
	chdir $ide;
	@devices = glob "hd*";
	# Check each device to see if it's a hard drive
	foreach (@devices) {
		chdir $_;
		$temp = `cat driver`;
		if($temp =~ /^ide-disk/) {
			# print "$_ is a hard drive\n";
			push @drives, $_;
		}
		# else {
		# 	print "$_ is not a hard drive\n";
		# }
		chdir "..";
	}
	chdir "..";
}

# Load up a menu, giving user option of fdisk, cfdisk, or parted for
# partitioning
$prog = 0;
while ($prog < 1 || $prog > 3)
{
	print "Which partitioning program do you wish to use?\n";
	print "1 - fdisk\n";
	print "2 - cfdisk\n";
	print "3 - parted\n";
	print "Enter a number (1,2 or 3):";
	$prog = <STDIN>;
}
if($prog == 1)
{
	print scalar @drives,"\n";
	if(scalar @drives == 1) {
		print "/dev/@drives[0]\n";
		system "fdisk", "/dev/@drives[0]";
	}
	else {
		$i = 1;
		$choice = 2;
		while($i != $choice) {
			$i=1;
			print "Select a disk to partition:\n";
			foreach (@drives) {
				print "$i - /dev/$_\n";
				$i++;
			}
			print "$i - Finished partitioning\n";
			print "Make choice (1-$i):";
			$choice = <STDIN>;
			if($choice < $i) {
				system "fdisk", "/dev/@drives[$choice-1]";
			}
		}
		system "fdisk";
	}
}
elsif($prog == 2)
{
	system "cfdisk";
}
elsif($prog == 3)
{
	system "parted";
}

# Get partition list
open PARTITIONS, "/proc/partitions" or die "Problem with proc filesystem ($!)";
$header = <PARTITIONS>;
#print "Header:$header\n";
@devices = ();
while(<PARTITIONS>) {
	#print "$_\n";
	if(!/^\s+\d\s+0/ && !/^\s*$/) {
		/\s+(\w+)$/;
		#print "$1\n";
		push @devices, $1
	}
}
@mPoints = ("/etc","/boot","/home","/lib","/tmp","/usr","/var");

# Choose mount locations
#print "Where do you want to mount the root directory?\n";
$choice = menu("Where do you want to mount the root directory?",@devices);
print "You chose @devices[$choice]\n";
$root = @devices[$choice];
@devices = (@devices[0..($choice-1)],@devices[$choice+1..$#devices]);
%fs = ("/",$root);

$choice = menu("Where do you want to mount the swap file?",@devices);
$swap = @devices[$choice];
print "You chose @devices[$choice]\n";
@devices = (@devices[0..($choice-1)],@devices[$choice+1..$#devices]);

$finished = 0;
if($#devices < 0) {
	$finished = 1;
}
while(!$finished) {
	$i = 0;
	print "Select a directory to mount, or f to finish\n";
	foreach (@mPoints) {
		$i++;
		print "$i - $_\n";
	}
	print "(1-$i, or f):";
	$choice = <STDIN>;
	chomp($choice);
	if($choice eq "f") {
		$finished = 1;
	}
	if($choice > 0 && $choice <= $i) {
		# Choose where you want to mount the folder
		$part = menu("Where do you want to mount @mPoints[$choice-1]",@devices);
		$fs{@mPoints[$choice-1]} = @devices[$part];
		@devices = (@devices[0..$part-1],@devices[$part+1..$#devices]);
		@mPoints = (@mPoints[0..$choice-2],@mPoints[$choice..$#mPoints]);
		if($#devices < 0 || $#mPoints < 0) {
			$finished=1;
		}
	}
}

# Format partitions as required
@fileSystems = ("ext2", "ext3", "xfs","Reiser");
$choice = menu("Which file system do you wish to use?",@fileSystems);
foreach(%fs) {
	if(@fileSystems[$choice] eq "ext2") {
		#`mkfs.ext2 $fs{$_}`;
	} elsif(@fileSystems[$choice] eq "ext3") {
		#`mkfs.ext3 $fs{$_}`;
	} elsif(@fileSystems[$choice] eq "xfs") {
		#`mkfs.xfs $fs{$_}`;
	} else {
		#`mkreiserfs $fs{$_}`;
	}
}
#`mkswap $swap`

# Mount partitions under /mnt
`mount /dev/$fs{"/"} /mnt/root`;
#Create root directory structure
#`mkrootfs`;
chdir "/mnt/root";
foreach $key (sort keys %fs) {
	if($key ne "/") {
		`mount /dev/$fs{$key} /mnt$key` 
	}
}

# Extract base system tarball into new system


# Setup the root password
$done = 0;
until $done {
	print "Enter your root password:";
	$pw1 = chomp <STDIN>;
	print "Enter the password again:";
	$pw2 = chomp <STDIN>;
	if($pw1 eq $pw2){
		$done = 1;
		#$pw = `crypt $
		#`chroot /mnt/root usermod -
	}
}
#`chroot /mnt/root passwd root`; 

# Add extra users as required. The loop should be:
# create username
# create home directory
# set password for user
$done = 0;
until $done {
	$choice = 0;
	while($choice < 1 && $choice > 2) {
		print "Do you want to add another user?\n";
		print "1 - Yes\n";
		print "2 - No\n";
		print "(1 or 2):";
		$choice = <STDIN>;
	}
	if($choice == 2)
		$done = true;
	else {
		print "Enter user name:";
		$username = <STDIN>;
		# `useradd 
	}
}

# Add Users to appropriate groups

# Setup fstab

# Setup lilo boot loader

# Setup network

# Setup bootscripts

0;


sub menu {
	my $title = shift @_;
	my @options = @_;
	my $i = 0;
	my $choice = 0;
	while($choice < 1 || $choice > $i) {
		$i=0;
		print "$title\n";
		foreach (@options) {
			$i++;
			print "$i - $_\n";
		}
		print "(1-$i):";
		$choice = <STDIN>;
	}
	$choice-1;
}
