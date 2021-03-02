package DataManager::RSync;

use DataManager::RSync::FSObject;

use Data::Dumper;
use Moose;

has FSObjects =>
  (
   is => 'rw',
   isa => 'HashRef',
   lazy => 1,
   default => sub { {} },
  );

has Backup =>
  (
   is => 'ro',
   isa => 'HashRef',
   default => sub {
     return {
	     '/' => 1,
	     '/var' => 0,
	     '/var/lib' => 1,
	     '/var/lib/myfrdcsa' => 0,
	     '/var/lib/vim' => 0,
	     '/var/lib/usbutils' => 1,
	     '/var/lib/myfrdcsa/codebases' => 0,
	     '/var/lib/myfrdcsa/codebases/internal' => 1,
	    };
   },
  );

# rsync /var/lib/myfrdcsa/codebases/internal
# rsync /var/lib/(all dirs that are not myfrdcsa or vim)
# rsync /(all dirs that are not var)

sub CalculateRSyncCommands {
  my ($self) = @_;
  foreach my $mountpoint (sort {length($a) <=> length($b)} keys %{$self->Backup}) {
    my $fsobject = DataManager::RSync::FSObject->new
      (
       Location => $mountpoint,
       DerivedP => 0,
       ShouldBackup => $self->Backup->{$mountpoint},
      );
    $self->FSObjects->{$fsobject->Location} = $fsobject;
  }
  $self->ComputeClosureOfParentDirs();
}

sub ComputeClosureOfParentDirs {
  my ($self) = @_;
  foreach my $fsobject (values %{$self->FSObjects}) {
    print $fsobject->Location."\n";
    print "<<<".$fsobject->GetParentObject.">>>\n";
  }
}

1;
