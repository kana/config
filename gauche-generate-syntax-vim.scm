(define (main args)
  (unless (= (length args) (+ 1 3))
    (print "Usage: generate-gauche-syntax-vim modules-file symbols-file template-file")
    (exit))

  (with-input-from-file
    (cadr args)
    (lambda ()
      (for-each
          (lambda (symbol)
            (guard (e (else))
                (lambda () (eval `(use ,symbol) (interaction-environment)))))
        (port->sexp-list (current-input-port)))))

  (call-with-input-file
    (cadddr args)
    (lambda (template-port)
      (let loop ((line (read-line template-port)))
        (unless (eof-object? line)
          (if (#/##gauche-define##/ line)
            (call-with-input-file
              (caddr args)
                output-gauche-define)
            (print line))
          (loop (read-line template-port))))))
  
  0)


(use srfi-1)
(define (output-gauche-define symbols-port)
  (define (print-generic symbol)
    (print (format "syntax keyword gaucheGeneric ~a" symbol)))
  (define (print-macro symbol)
    (print (format "syntax keyword gaucheMacro ~a" symbol))
    (print (format "setlocal lispwords+=~a" symbol)))
  (define (print-module symbol)
    (print (format "syntax keyword gaucheModule ~a" symbol)))
  (define (print-procedure symbol)
    (print (format "syntax keyword gaucheProcedure ~a" symbol)))
  (define (print-syntax symbol)
    (print (format "syntax keyword gaucheSyntax ~a" symbol))
    (print (format "setlocal lispwords+=~a" symbol)))
  (define (print-error symbol)
    (print (format "\" ~a ==> ~a" symbol (class-of symbol))))

  (for-each
    (lambda (symbol)
      (let ((value (eval symbol (interaction-environment))))
        (cond
          ((is-a? value <generic>) (print-generic symbol))
          ((is-a? value <macro>) (print-macro symbol))
          ((is-a? value <module>) (print-module symbol))
          ((is-a? value <procedure>) (print-procedure symbol))
          ((is-a? value <syntax>) (print-syntax symbol))
          (else (print-error symbol)))))
    (filter
      (lambda (symbol)
        (and
	  (global-variable-bound? (current-module) symbol)
          (not (rxmatch #/^[|]/ (symbol->string symbol)))))
      (port->sexp-list symbols-port))))

; __END__
