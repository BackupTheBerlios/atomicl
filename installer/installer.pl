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
		} elsif ($temp =~ /^ide-cdrom/) {
			push @cdroms, $_;
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
@parts = ();
while(<PARTITIONS>) {
	#print "$_\n";
	if(!/^\s+\d\s+0/ && !/^\s*$/) {
		/\s+(\w+)$/;
		#print "$1\n";
		push @parts, $1
	}
}
@mPoints = ("/etc","/boot","/home","/lib","/tmp","/usr","/var");

# Choose mount locations
#print "Where do you want to mount the root directory?\n";
$choice = menu("Where do you want to mount the root directory?",@parts);
print "You chose @parts[$choice]\n";
$root = @parts[$choice];
@parts = (@parts[0..($choice-1)],@parts[$choice+1..$#parts]);
%fs = ("/",$root);

$choice = menu("Where do you want to mount the swap file?",@parts);
$swap = @parts[$choice];
print "You chose @parts[$choice]\n";
@parts = (@parts[0..($choice-1)],@parts[$choice+1..$#parts]);

$finished = 0;
if($#parts < 0) {
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
		$part = menu("Where do you want to mount @mPoints[$choice-1]",@parts);
		$fs{@mPoints[$choice-1]} = @parts[$part];
		@parts = (@parts[0..$part-1],@parts[$part+1..$#parts]);
		@mPoints = (@mPoints[0..$choice-2],@mPoints[$choice..$#mPoints]);
		if($#parts < 0 || $#mPoints < 0) {
			$finished=1;
		}
	}
}

# Format partitions as required
@fileSystems = ("ext2", "ext3", "xfs","Reiser");
$choice = menu("Which file system do you wish to use?",@fileSystems);
$drivetype;
foreach(%fs) {
	if(@fileSystems[$choice] eq "ext2") {
		#`mkfs.ext2 $fs{$_}`;
		$drivetype = "ext2";
	} elsif(@fileSystems[$choice] eq "ext3") {
		#`mkfs.ext3 $fs{$_}`;
		$drivetype = "ext3";
	} elsif(@fileSystems[$choice] eq "xfs") {
		#`mkfs.xfs $fs{$_}`;
		$drivetype = "xfs";
	} else {
		#`mkreiserfs $fs{$_}`;
		$drivetype = "reiser";
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
		`mount /dev/$fs{$key} /mnt/root$key` 
	}
}

# Extract base system tarball into new system
# $tarfile = <Enter tar file here>
# `tar -xjf $tarfile -C /mnt/root

# Setup the root password
#`chroot /mnt/root passwd root`; 

# Add extra users as required. The loop should be:
# create username
# create home directory
# set password for user
$done = 0;
until ($done) {
	$choice = 0;
	while($choice < 1 || $choice > 2) {
		print "Do you want to add another user?\n";
		print "1 - Yes\n";
		print "2 - No\n";
		print "(1 or 2):";
		$choice = <STDIN>;
	}
	if($choice == 2) {
		$done = 1;
	} else {
		print "Enter user name:";
		$username = <STDIN>;
		# `groupadd $username`;
		# `useradd  -g $username -k -m -s /bin/bash`;
		# `chroot /mnt/root passwd $username`; 
	}
}

# Setup fstab
# Assume proc, etc. is already added
open FSTAB, ">>/mnt/root/etc/fstab";
print FSTAB "/dev/$swap\tswap\tswap\tdefaults\t0\t0\n";
foreach $key (sort keys %fs) {
	if($key ne "/") {
		print FSTAB "/dev/$fs{$key}\t$key\t$drivetype\tdefaults\t0\t0\n";
	} else {
		print FSTAB "/dev/$fs{$key}\t$key\t$drivetype\tdefaults\t1\t1\n";
	}
}
foreach (@cdroms) {
	print FSTAB "/dev/$_\t/mnt/$_\tiso9660\tnoauto,user,ro\t0\t0\n";
}
close FSTAB;

# Setup lilo boot loader
# `liloconfig`;

# Setup network

# Setup bootscripts
# $bsdir = <Enter boot script directory on the cd>
# $bstarget = <Enter boot script directory on destination>
# `cp $bsdir/* $bstarget`;

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
