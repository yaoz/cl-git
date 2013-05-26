;;; -*- Mode: Lisp; Syntax: COMMON-LISP; Base: 10 -*-

;; cl-git an Common Lisp interface to git repositories.
;; Copyright (C) 2012-2013 Russell Sim <russell.sim@gmail.com>
;;
;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public
;; License along with this program.  If not, see
;; <http://www.gnu.org/licenses/>.

(in-package #:cl-git-tests)


(in-suite :cl-git)

(def-test list-remotes (:fixture repository-with-commits)
  "Create a new repository and check it's remotes."
  (is
   (eq
    (list-objects 'remote *test-repository*)
    nil)))

(def-test create-remote (:fixture repository-with-commits)
  "Create a remote and check it's details."
  (git-create 'remote "origin" *test-repository* :url "/dev/null" )
  (is
   (equal
    (list-objects 'remote *test-repository*)
    '("origin")))
  (is
   (equal
    (git-url (git-load 'remote "origin" *test-repository*))
    "/dev/null")))


(def-test fetch-remotes (:fixture repository-with-commits)
  "Create a new repository and check it's remotes."
  (let ((remote-repo-path (gen-temp-path)))
    (unwind-protect
	     (git-init 'repository remote-repo-path)
      (let ((remote-repo (git-open 'repository remote-repo-path)))
        (git-create 'remote "origin"
                    remote-repo
                    :url (concatenate 'string "file://" (namestring *repository-path*)))
        (let ((remote (git-load 'remote "origin" remote-repo)))
          (remote-connect remote)
          (remote-download remote)
          (is
           (equal
            (remote-fetchspec remote)
            '((:src "refs/heads/*"
               :dst "refs/remotes/origin/*"
               :flags (:force :pattern)))))))
      (progn
        (delete-directory-and-files remote-repo-path)))))
