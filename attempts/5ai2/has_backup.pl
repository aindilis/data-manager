%% 1. traverse the <REDACTED> directory and ensure everything is has a theoretical backed

%% 2. traverse the <REDACTED> directory and ensure everything has an actual backup, and then 3. a backup of the backup (all on separate drives)

%% 4. traverse the <REDACTED> directory and ensure everything is up to date

:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util').
:- ensure_loaded('auto_detect').
:- ensure_loaded('git_repos').

%% 1:

:- dynamic hasMetadata/2.
:- dynamic hasBackupGit/2.
:- dynamic hasBackup/2.

hasBackup(X) :-
	hasBackup(X,_).

flpFlag(debug).

ensure(backedUp(directory(ai2FrdcsaOrg,'<REDACTED>'))).

ensure_everything_backed_up :-
	foreach(ensure(backedUp(directory(ai2FrdcsaOrg,Directory))),ensure_backed_up_2(directory(ai2FrdcsaOrg,Directory))).

disk('ai2.frdcsa.org','<REDACTED DISK1>').
dirHasDisk(directory('ai2.frdcsa.org','<REDACTED DIR>'),disk('ai2.frdcsa.org','<REDACTED DISK1>')).
neg(deadDrive('<REDACTED DISK1>')).

driveHasSystem('<REDACTED DISK2>','<REDACTED SYSTEM2>').

neg(deadDrive('<REDACTED DISK2>')).

hasRsync('<REDACTED DIR2>','<REDACTED DIR3>',[before([2020-02-10,01:47:28])]).

hasBackup(directory(aiFrdcsaOrg,'<REDACTED DIR4>'),[symlink('<REDACTED DIR5>'),rsync('<REDACTED DIR6>')]).

hasBackup(directory(aiFrdcsaOrg,'<REDACTED DIR7>'),[isa(git),symlink('<REDACTED DIR8>'),rsync('<REDACTED DIR9>'),git('<REDACTED DIR10>.git')]).
hasBackup(directory(ai2FrdcsaOrg,'<REDACTED DIR11>')).

directory_files_no_hidden(Dir,Files) :-
	directory_files(Dir,TmpFiles),
	findall(File,(member(File,TmpFiles),not(atom_concat('.',_,File))),Files).

sorted_directory_files_no_hidden(directory(System,Dir),Files) :-
	System = ai2FrdcsaOrg, %% FIXME: remote execute on system in the future
	directory_files_no_hidden(Dir,TmpFiles),
	sort(TmpFiles,Files).

system_exists_directory(directory(System,SubDirectory)) :-
	System = ai2FrdcsaOrg,
	exists_directory(SubDirectory).

ensure_backed_up(directory(System,Directory)) :-
	ensure_backed_up(directory(System,Directory),0).

ensure_backed_up(directory(System,Directory),Depth) :-
	Depth < 3,
	sorted_directory_files_no_hidden(directory(System,Directory),FilesAndDirs),
	view(FilesAndDirs),
	forall(member(FileOrDir,FilesAndDirs),
	       (   
		   atomic_list_concat([Directory,FileOrDir],'/',SubDirectory),
		   (   system_exists_directory(directory(System,SubDirectory)) ->
		       (   
			   writeln([checking,SubDirectory]),
			   (   
			       hasBackup(directory(System,SubDirectory)) ;
			       (   
				   NewDepth is Depth + 1,
				   ensure_backed_up(directory(System,SubDirectory),NewDepth)
			       )
			   ) ->
			   true ;
			   (
			    writeln(['File or dir not backed up:',SubDirectory]),
			    fail
			   )
		       ) ;
		       writeln(['Not a directory:',SubDirectory])
		   )
	       )
	      ).

ensure_backed_up_2(directory(System,Directory)) :-
	(   ensure_backed_up_2(directory(System,Directory),0) -> true ; true),
	findall(hasBackupGit(X,Y),hasBackupGit(X,Y),List),
	write_list(List).

ensure_backed_up_2(directory(System,Directory),Depth) :-
	viewIf([ensure_backed_up_2,directory(System,Directory)]),     
	(   system_exists_directory(directory(System,Directory)) ->
	    (	
		Depth < 3,
		sorted_directory_files_no_hidden(directory(System,Directory),FilesAndDirs),
		view(FilesAndDirs),
		forall(member(FileOrDir,FilesAndDirs),
		       (   
			   atomic_list_concat([Directory,FileOrDir],'/',SubDirectory),
			   (   system_exists_directory(directory(System,SubDirectory)) ->
			       (   
				   writeln([checking,directory(System,SubDirectory)]),

				   (   check_for_backups(directory(System,SubDirectory),Depth) ->
				       true ;
				       (   
					   writeln(['File or dir not backed up:',SubDirectory]),
					   fail
				       )
				   )
			       ) ;
			       writeln(['Not a directory:',SubDirectory])
			   )
		       )
		      )
	    ) ; true).

my_is_git_directory(directory(System,Dir)) :-
	System = ai2FrdcsaOrg, %% FIXME
	is_git_directory(Dir).

check_for_backups(directory(System,SubDirectory),Depth) :-
	%% writeln([subDirectory,SubDirectory,depth,Depth]),
	(   my_is_git_directory(directory(System,SubDirectory)) ->
	    (	
		lookup_remotes(directory(System,SubDirectory),Remotes),
		foreach(member(Remote,Remotes),
			(
			 assert(hasBackupGit(directory(System,SubDirectory),Remote)),
			 writeln(['File or dir backed up:',directory(System,SubDirectory),Remote])
			))
	    
	    ) ;
	    (
	     hasBackup(directory(System,SubDirectory)) ;
	     (	 
		 NewDepth is Depth + 1,
		 ensure_backed_up_2(directory(System,SubDirectory),NewDepth)
	     )
	    )
	).

testMine :-
	find_all_copies(directory('ai.frdcsa.org','<REDACTED DIR12>'),Results),
	write_list(Results).

find_all_copies(directory(System,Directory),Results) :-
	findall(disk(System2,Disk),
		hasCopy(directory(System,Directory),disk(System2,Disk)),
		Results).

hasCopy(directory(System1,Dir),disk(System2,Disk)) :-
	(   get_disk_and_system_for_directory(directory(System1,Dir),disk(System2,Disk)) -> true ; true).
hasCopy(directory(System1,Dir),disk(System2,Disk)) :-
	get_all_backup_information_for_dir(directory(System,Dir)),
	findall(Metadata,(hasMetadata(Dir,List),member(Metadata,List)),AllMetadata),
	getCopies(System1,AllMetadata,disk(System2,Disk)).

getCopies(System1,AllMetadata,disk(System2,Disk)) :-
	member(symlink(CopyDir),AllMetadata),
	(   get_disk_and_system_for_directory(directory(System1,CopyDir),disk(System2,Disk)) -> true ; true).
getCopies(System1,AllMetadata,disk(System2,Disk)) :-
	member(rsync(CopyDir),AllMetadata),
	(   get_disk_and_system_for_directory(directory(System1,CopyDir),disk(System2,Disk)) -> true ; true).
getCopies(System1,AllMetadata,disk(System2,Disk)) :-
	member(git(RemoteURL),AllMetadata),
	parse_git_remote_url(RemoteURL,[Scheme,Username,Host,FSO]),
	view([Host,FSO]),
	hasCopy(directory(Host,FSO),disk(System2,Disk)).

get_disk_and_system_for_directory(directory(System1,Dir),disk(System2,Disk)) :-
	dirHasDisk(directory(System1,Dir2),disk(System2,Disk)),
	path_prepends(Dir2,Dir).

my_read_link(directory(System,Dir),_,TmpDereferencedLink) :-
	System = ai2FrdcsaOrg,
	read_link(Dir,_,TmpDereferencedLink).

get_all_backup_information_for_dir(directory(System,Dir)) :-
	%% is it a symlink?
	(   my_read_link(directory(System,Dir),_,TmpDereferencedLink) ->
	    (
	     chomp_trailing_slash_from_path(TmpDereferencedLink,DereferencedLink),
	     my_assert(hasMetadata(directory(System,Dir),[symlink(DereferencedLink)])),
	     get_all_backup_information_for_dir(directory(System,DereferencedLink))
	    ) ;
	    
	    %% is it a git repository?
	    (	my_is_git_directory(directory(System,Dir)) ->
		(   
		    lookup_remotes(directory(System,Dir),Remotes),
		    foreach(member(Remote,Remotes),
			   my_assert(hasMetadata(directory(System,Dir),[git(Remote)])))
		) ; true),
	    (	
		%% has it been backed up somewhere
		has_been_rync_backed_up(directory(System,Dir),BackupDir) ->
		(   
		    my_assert(hasMetadata(directory(System,Dir),[rsync(BackupDir)]))
		) ; true)
	    ).

my_assert(X) :-
	view([x,X]),
	\+ X,
	assert(X).
my_assert(_X).
		
has_been_rync_backed_up(directory(System,Dir),BackupDir) :-
	System = ai2FrdcsaOrg, %% FIXME
	hasRsync(OriginalLocation,BackupLocation,_Time),
	path_prepends(OriginalLocation,Dir),
	get_relative_path(OriginalLocation,Dir,RelativePath),
	atomic_list_concat([BackupLocation,RelativePath],'',BackupDir).

get_relative_path(OriginalLocation,Dir,RelativePath) :-
	atom_length(OriginalLocation,L1),
	atom_length(Dir,L2),
	L1a is L1,
	Diff is L2 - L1,
	sub_atom(Dir, L1, Diff, _, RelativePath).

path_prepends(CandidatePrefixDir,Dir) :-
	file_directory_name(Dir,PrefixDir),
	(   PrefixDir = CandidatePrefixDir ->
	    true ;
	    (	PrefixDir \= '/' ->
		path_prepends(CandidatePrefixDir,PrefixDir) ;
		fail)).

what_is_lost_if_these_drives_fail(Drives,Lost) :-
	true.

what_is_vulnerable_if_these_drives_fail(Drives,Vulnerable) :-
	true.

