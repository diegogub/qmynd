;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                  ;;;
;;; Free Software published under an MIT-like license. See LICENSE   ;;;
;;;                                                                  ;;;
;;; Copyright (c) 2012 Google, Inc.  All rights reserved.            ;;;
;;;                                                                  ;;;
;;; Original author: Alejandro Sedeño                                ;;;
;;;                                                                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :mysqlnd)

;;; 15.1.1.2. String

;;; Protocol::FixedLengthString
;;; A string with a known length

(defun parse-fixed-length-string (stream length &key (encoding :utf-8))
  (let ((octets (make-sequence '(vector (unsigned-byte 8))length)))
    (read-sequence octets stream)
    #+nil
    (dotimes (i length)
      (setf (aref octets i)
            (read-byte stream)))
    (babel:octets-to-string octets :encoding encoding)))

;;; Protocol::NulTerminatedString
;;; A string terminated by a NUL byte.

(defun parse-null-terminated-string (stream &key (encoding :utf-8))
  (let* ((length 16)
         (octets (make-array length
                             :element-type '(unsigned-byte 8)
                             :adjustable t
                             :initial-element 0)))
    (loop
       for i fixnum from 0
       as b fixnum = (read-byte stream)
       unless (< i length) do
         (incf length length) and do
         (adjust-array octets length)
       do (setf (aref octets i) b)
       when (= b 0) return (babel:octets-to-string octets :encoding encoding :start 0 :end i))))

;;; Protocol::VariableLengthString
;;; A string with a length determine by another field
;;; This will be implemented at a higher level using fixed-length-strings and knowledge of the other field.

;;; Protocol::LengthEncodedString
;;; A string prefixed by its length as a length-encoded integer

(defun parse-length-encoded-string (stream &key (encoding :utf-8))
  (parse-fixed-length-string stream
                             (parse-length-encoded-integer stream)
                             :encoding encoding))

;;; Protocol::RestOfPacketString
;;; Just read the rest of the packet
;;; This will be implemented at a higher level using fixed-length-strings and knowledge of packet length.
