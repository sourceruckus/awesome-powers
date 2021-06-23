;; .emacs

;; set colors to white on black
(set-background-color "black")
(set-foreground-color "white")

;; set cursor color
(set-cursor-color "orange")

(set-frame-font "Monospace 14")

;; display column numbers
(column-number-mode t)

;; we want to make sure files end in a newline
(setq require-final-newline t)

;; don't bother us with the startup screen, ever
(setq inhibit-startup-screen t)

;; email settings (needs gnutls-cli executable)
(setq
 send-mail-function 'smtpmail-send-it
 message-send-mail-function 'smtpmail-send-it
 user-full-name "My Full Name"
 user-mail-address "my.full.name@gmail.com"
 smtpmail-starttls-credentials '(("smtp.gmail.com" "587" nil nil))
 smtpmail-default-smtp-server "smtp.gmail.com"
 smtpmail-smtp-server "smtp.gmail.com"
 smtpmail-smtp-service 587
 )

;; c-mode-common hook
(defun my-c-mode-common-hook ()
  (setq fill-column 79
   c-cleanup-list '(scope-operator
          ;;empty-defun-braces
          defun-close-semi
          list-close-comma
          )
   ;; this sets up our hanging braces list
   c-hanging-braces-alist '()
   )
  )
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;; c-mode hook
(defun my-c-mode-hook ()
  (c-set-style "linux")
  (setq indent-tabs-mode 1)
  )
(add-hook 'c-mode-hook 'my-c-mode-hook)

;; c++-mode hook
(defun my-c++-mode-hook ()
  (c-set-style "stroustrup")
  (setq indent-tabs-mode nil)
  )
(add-hook 'c++-mode-hook 'my-c++-mode-hook)

;; sh-mode hook
(defun my-sh-mode-hook ()
  (setq fill-column 79
   indent-tabs-mode nil
   )
  )
(add-hook 'sh-mode-hook 'my-sh-mode-hook)

;; python-mode hook
(defun my-python-mode-hook ()
  (setq fill-column 79
   indent-tabs-mode nil
   )
  )
(add-hook 'python-mode-hook 'my-python-mode-hook)

;; outline-mode hook
(defun my-outline-mode-hook ()
  (setq fill-column 79
   indent-tabs-mode 1
   )
  )
(add-hook 'outline-mode-hook 'my-outline-mode-hook)
(add-hook 'conf-mode-hook 'my-outline-mode-hook)



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-switches "-u")
 '(inhibit-startup-screen t)
 '(send-mail-function (quote smtpmail-send-it)))

;;; uncomment for CJK utf-8 support for non-Asian users
;; (require 'un-define)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
