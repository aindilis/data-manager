package DataManager::Serializer;

use Manager::Dialog qw(ApproveCommands);

use Data::Dumper;
use File::Basename;
use File::Temp qw(tempdir);
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ExtTable Procedures /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ExtTable
    ({
      "gnumeric" => "Gnumeric",
      "<REDACTED>" => "<REDACTED>",
     });
  $self->Procedures
    ({
      "Gnumeric" => [

		    ],
      Steps => [
		"gpg -d <FILE> --passphrase-file <PASSWDFILE>",
		"gunzip -d <FILE>",
		sub {$self->Merge(%ARGV)},
		# "syntax check",
		"gzip -c <FILE>",
		"??? gpg -e <FILE>",
	       ],
     });
}

sub SerializeFile {
  my ($self,%args) = @_;
  my $file = $args{File};
  if (! -f $file) {
    die "Cannot find file $file\n";
  }
  # find-or-create a temporary directory
  my $dir = dirname($args{File});
  my $basename = basename($args{File});

  my $newdir = "$dir/.dirs";
  my ($dirname) = tempdir( "data-manager-XXXX", DIR => $newdir );

  print $dirname."\n";
  my $commands = [
		  "cp ".shell_quote($args{File})." ".shell_quote($newdir."/$basename"),
		 ];
  ApproveCommands
    (
     Commands => $commands,
     Type => "parallel",
     AutoApprove => 1,
    );

  my $filename = $newdir."/$basename";

  # check file extensions because file types are not fine grained enough

  if () {
    # check the file extensions
    if ($basename =~ /\.(.+?)$/) {

    }
  } elsif (0) {
    # figure out what type of file it is and how to serialize it
    my $command = "file ".shell_quote($filename);
    my $res = `$command`;
    print $res."\n";
    if ($res =~ //) {

    } elsif ($res =~ //) {
      # gzip compressed data, from Unix

      # for now just manually apply what we know will work
      # ssconvert basic.gnumeric out.csv
      # ssconvert out.csv basic.gnumeric
    }
  }
  return $args{File};
}

sub DeSerializeFile {
  my ($self,%args) = @_;
  # have a temporary directory
  # figure out what type of file it is and how to serialize it

  # for now just manually apply what we know will work
  # ssconvert basic.gnumeric out.csv
  # ssconvert out.csv basic.gnumeric
  return $args{File};
}

1;
