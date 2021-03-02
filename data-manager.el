(global-set-key "\C-crerd" 'data-manager-edit-backup-information)
(global-set-key "\C-c\C-kup" 'data-manager-update-frdcsa-repositories)

(defun data-manager-edit-backup-information ()
 "Edit the file containing the rules for NLU to use when processing text"
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/data-manager/backups/backups.pl"))

(defun data-manager-update-frdcsa-repositories ()
 ""
 (interactive)
 (kmax-server-restart)
 (run-in-shell "update-frdcsa-git"))

(provide 'data-manager)
