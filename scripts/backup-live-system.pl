#!/usr/bin/perl -w

use Data::Dumper;

# CONFIG
my $debug = 0;

my $backuplocations =
  {
   '<REDACTED>' => {
		       '<REDACTED>' => 1,
		      },
  };

# note that backuplocations are not backed up, so they don't need to
# be specified in dontbackup, but that is the format
my $dontbackup =
  {
   '<REDACTED>' => {
   		       '<REDACTED>' => 1,
   		      },
  };

my $hostname = `hostname -f`;
chomp $hostname;

my $mountresult = `mount`;
chomp $mountresult;

my $mounts = {};
foreach my $line (split /\n/, $mountresult) {
  if ($line =~ /^(\S+) on (\S+) type (\S+) \((.+)\)$/) {
    my ($dev, $mntpoint, $type, $tmp) = ($1,$2,$3,$4);
    my $options = {};
    foreach my $option (split /,/,$tmp) {
      $options->{$option} = 1;
    }
    $mounts->{$mntpoint} = {
			    Dev => $dev,
			    MntPoint => $mntpoint,
			    Type => $type,
			    Options => $options,
			   };
  } else {
    die "Line doesn't match: $line\n";
  }
}

print Dumper($mounts) if $debug;

# should we also look at /etc/fstab?

# now determine whether to backup the various mountpoints

my $backup = {};
foreach my $mountpoint (keys %$mounts) {
  my $tmp = 0;
  my $hash = $mounts->{$mountpoint};

  # RULES
  ++$tmp if $mountpoint =~ /^(\/)$/; # backup root
  $tmp *= 0 if $hash->{Type} =~ /^(tmpfs|sysfs|proc|devtmpfs|usbfs)$/; # skip certain filesystems
  $tmp *= 0 if $backuplocations->{$hostname}{$mountpoint}; # skip the backup locations themselves
  $tmp *= 0 if $dontbackup->{$hostname}{$mountpoint}; # skip the items specifically supposed to not be backed up

  $backup->{$mountpoint} = !!$tmp ? 1 : 0;
}

print Dumper({Backup => $backup}) if $debug;

# now strip redundant labels

# backup:
# '/' => 1,
# '/dev' => 0,
# '/proc' => 0,
# '/proc/sys/fs/binfmt_misc' => 0,


# what to skip based on which directories should be backed up
#
#               /proc
#      backup   1         0
#             +---------+-------+
# /proc/a   1 |         | /proc |
#             |---------+-------+
#           0 | /proc/a | /proc |
#             +---------+-------+


my $skip = {};
foreach my $mountpoint1 (keys %$mounts) {
  foreach my $mountpoint2 (keys %$mounts) {
    if ($mountpoint1 ne $mountpoint2) {
      if ($mountpoint2 =~ /^$mountpoint1/) {
	# mountpoint1 = /proc, $mountpoint2 = /proc/a
	if ($backup->{$mountpoint1}) {
	  if ($backup->{$mountpoint2}) {
	    # nothing to skip
	  } else {
	    $skip->{$mountpoint2} = 1;
	  }
	} else {
	  $skip->{$mountpoint1} = 1;
	}
      }
    }
  }
}

print Dumper({Skip => $skip}) if $debug;
my $remove = {};
foreach my $mountpoint1 (keys %$skip) {
  foreach my $mountpoint2 (keys %$skip) {
    if ($mountpoint1 ne $mountpoint2) {
      if ($mountpoint2 =~ /^$mountpoint1/) {
	$remove->{$mountpoint2} = 1;
      }
    }
  }
}

# get the most general block list, so if proc and proc/sys are
# blocked, drop the proc/sys because it is subsumed

print Dumper({Remove => $remove}) if $debug;
my $finalskip = {};
foreach my $mountpoint (keys %$skip) {
  $finalskip->{$mountpoint} = 1 unless $remove->{$mountpoint};
}
print Dumper({FinalSkip => $finalskip});


# # then, for this for instance /var/lib/nfs/rpc_pipefs, do:

# ls /var
# ls /var/lib
# ls /var/lib/nfs

# # pretend there is also /var/lib/myfrdcsa should not be backed up, then flag it

# ls /var
# ls /var/lib



# # so that you get all the directories outside


# # do a listing of all the directories, then back them up one at a time

# rsync --progress -av /

# bin
# boot
# dev
# etc
# home
# initrd.img
# lib
# lib32
# lib64
# lost+found
# media
# mnt
# opt
# proc
# root
# run
# sbin
# selinux
# srv
# sys
# tmp
# usr
# var
# vmlinuz


