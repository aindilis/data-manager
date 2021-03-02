# okay so here is the procedure for synchronizing <REDACTED>

# should be able to automatically find this stuff out by format
# analysis - basically, reducing to some plaintext system, also, a
# syntax checker or something

# need to set up an experiment to test this

my $procedures =
  {
   "<REDACTED>" =>
   {
    FileType => "PGP message",
    Steps => [
	      "decrypt with gpg",
	      "gunzip",
	      "sync",
	      "syntax check",
	      "gzip",
	      "reencrypt",
	     ]
   },
   "BBDB" =>
   {
    FileType => "ASCII English text, with very long lines, with escape sequences",
    Steps => [
	      "sync",
	     ],
   },
   "GNUMERIC" =>
   {
    "gzip compressed data, from Unix",
   },
  };


sub AutoSync {
  # so I guess the model is this, we are passed two files, and need to
  # put out a single one that is synchronized

  # unravel the formats
  # copy the file to a temporary locaiton
  # iteratively unravel


}
