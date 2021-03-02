package DataManager::Merge;

use DataManager::Serializer;

use Data::Dumper;
use File::Basename;
use File::Temp qw(tempdir);
use String::ShellQuote;


@debianmoddepends = qw(rcs);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySerializer /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MySerializer
    (DataManager::Serializer->new);
}

sub Execute {
  my ($self,%args) = @_;
  # make sure any applications using this file are shutdown
  # lsof
  my $conf = $UNIVERSAL::datamanager->Config->CLIConfig;
  $self->Merge
    (
     OrigFile => $conf->{-o},
     BranchLeft => $conf->{-l},
     BranchRight => $conf->{-r},
     Merged => $conf->{'-m'},
     ExpectedMergeResultFile => $conf->{-t},
    );
}

sub Merge {
  my ($self,%args) = @_;
  # check to see if they are already bytewise similar, if not try to
  # resolve
  my $dir = dirname($args{OrigFile});
  print "$dir\n";
  if (-d $dir) {
    if (! -d "$dir/.dirs") {
      mkdir "$dir/.dirs";
    }
  } else {
    die "ERROR\n";
  }

  my $orig = $self->MySerializer->SerializeFile(File => $args{OrigFile});
  my $left = $self->MySerializer->SerializeFile(File => $args{BranchLeft});
  my $right = $self->MySerializer->SerializeFile(File => $args{BranchRight});
  my $merged = $self->MySerializer->SerializeFile(File => $args{Merged});

  # in order to merge them you  do this
  my $commands =
    [
     "cp ".shell_quote($orig)." ".shell_quote($merged),
     "merge ".shell_quote($merged)." ".shell_quote($orig)." ".shell_quote($left),
     "merge ".shell_quote($merged)." ".shell_quote($orig)." ".shell_quote($right),
    ];
  print Dumper($commands);

  # now, clean up
  $self->MySerializer->DeSerializeFile
    (
     File => $merged,
    );

  if ($args{ExpectedMergeResultFile}) {
    my $commands2 =
      [
       "diff ".shell_quote($args{Merged})." ".shell_quote($args{ExpectedMergeResultFile}),
      ];
    print Dumper($commands2);
  }
}

sub RunTest {
  my ($self,%args) = @_;
  my $dir = $args{Dir};
  my $ext = $dir;		# for now
  my $base = "/var/lib/myfrdcsa/codebases/minor/data-manager/data/test";
  my $basedir = "$base/$dir";
  if (-d $basedir) {
    $self->Merge
      (
       OrigFile => "$basedir/orig.$ext",
       BranchLeft => "$basedir/A.$ext",
       BranchRight => "$basedir/B.$ext",
       Merged => "$basedir/merged.$ext",
       ExpectedMergeResultFile => "$basedir/expected-merged.$ext",
       Ext => $ext,
      );
  }
}

1;
