#!/usr/bin/perl -w

use DataManager::RSync;

my $rsync = DataManager::RSync->new();
$rsync->CalculateRSyncCommands();
