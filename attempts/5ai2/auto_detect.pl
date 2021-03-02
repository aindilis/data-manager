:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util').

%% https://www.swi-prolog.org/pldoc/doc/_SWI_/library/git.pl

:- use_module(library(git)).

hasSymlink(File,Target) :-
	read_link(File,Link,Target).

:- use_module(library(ugraphs)).

hasSymlinkChain(File,Chain) :-
	true.

symlinkDanglingP(File) :-
	hasSymlink(File,Target),
	not(exists_file(Target) ; exists_directory(Target)).

%% detectGitRepository(Dir,GitRepository) :-
%% 	atomic_list_concat([Dir,'.git'],'/',GitDir),
%% 	exists_directory().

%% need to write rock solid libraries for mapping out the filesystem
%% (noting symlinks + symlink chains, getting timestamps, dealing with
%% relative and absolute paths, different machines, hard drives, etc),
%% git repos (getting the revision information, config information
%% such as origin master), etc.  Then compile to PDDL or BTs or
%% something, and execute


%% is_git_directory(FSO).

fsoIsGitRepoP(FSO) :-
	absolute_file_name(FSO,FSO2),
	concat_dir(FSO2,'.git/config',FSO3),
	exists_file(FSO3),
	read_data_from_file(FSO3,Data),
	view([data,Data]).

concat_dir(FSO1,FSO2,FSO3) :-
	file_directory_name(FSO1,DirName1),
	file_base_name(FSO1,BaseName1),
	file_directory_name(FSO2,TmpDirName2),
	(   TmpDirName2 = '.' -> DirName2 = '' ; DirName2 = TmpDirName2),
	file_base_name(FSO2,BaseName2),
	atomic_list_concat([DirName1,BaseName1,DirName2,BaseName2],'/',FSO3).

%% lookup_remote(FSO,RemoteURL) :- 
%% 	is_git_directory(FSO),
%% 	git([remote,'-v'],[directory(FSO),output(A)]),
%% 	atom_string(B,A),
%% 	view([b,B]),
%% 	regex_atom('^([^\t]+)\t(.*) .fetch.\n([^\t]+)\t(.*) .push.\n$',[],B,Results),
%% 	findall(Converted,(member(Result,Results),atom_string(Converted,Result)),All),
%% 	All = [_,RemoteURL,_,_].

lookup_remotes(directory(System,FSO),RemoteURLs) :- 
	System = ai2FrdcsaOrg, %% FIXME 
	my_is_git_directory(directory(System,FSO)),
	git([remote,'-v'],[directory(FSO),output(A)]),
	atom_string(B,A),
	view([b,B]),
	re_split("(push)",B, Parts, []),
	findall(RemoteURL,
		(   
		    member(Part,Parts),
		    regex('([^\t]+)\t(.*) .fetch.\n([^\t]+)\t(.*) .',[],Part,[_,StringRemoteURL,_,_]),
		    atom_string(RemoteURL,StringRemoteURL)
		),
		RemoteURLs).

string_atom(String,Atom) :-
	atom_string(Atom,String).

%% /var/lib/myfrdcsa/codebases/external/.git/config

parse_git_remote_url(RemoteURL,[Scheme,Username,Host,FSO]) :-
	regex_atom('^(.+)://([^:]+)@([^/]+)(.+)$',[],RemoteURL,List),
	findall(B,(member(A,List),atom_string(B,A)),[Scheme,Username,Host,FSO]).

parse_git_remote_url(RemoteURL,[Scheme,'',Host,FSO]) :-
	regex_atom('^(.+)://([^/]+)(.+)$',[],RemoteURL,List),
	findall(B,(member(A,List),atom_string(B,A)),[Scheme,Host,FSO]).


%% we want to get a timestamp associated with git and rsync backups

