package DataManager::RSync::FSObject;

use Moose;
use PerlLib::SwissArmyKnife;

has ShouldBackup =>
  (
   is => 'rw',
   isa => 'Bool',
  );

has DerivedP =>
  (
   is => 'rw',
   isa => 'Bool',
  );

has Location =>
  (
   is => 'rw',
   isa => 'Str',
  );

has RSyncCommand =>
  (
   is => 'rw',
   isa => 'Str',
  );

has ParentDir =>
  (
   is => 'rw',
   isa => 'DataManager::RSync::FSObject',
  );

sub HasNoOughtNotBackupSubFSObjectP {

}

sub GetParentObject {
  my ($self) = @_;
  if ($self->Location eq '/') {
    print "ERROR, no parent dir for /\n";

  } else {
    
    return DataManager::RSync::FSObject->new
      (
       Location => dirname($self->Location),
       DerivedP => 1,
      );
  }
}

1;
