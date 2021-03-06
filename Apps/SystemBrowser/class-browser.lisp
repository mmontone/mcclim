(in-package :clim-system-browser)

(define-application-frame clim-class-browser ()
  ((browser-class :initarg :class
                  :initform (error "Provide the class")
                  :accessor browser-class))
  (:panes
   (overview-pane :application-pane
                  :width 1000
                  :display-function #'display-class-overview)
   (graph-pane :application-pane
               :width 1000
               :display-function #'display-class-graph))
  (:layouts
   (default
       (vertically ()
         (1/2 overview-pane)
         (1/2 graph-pane)))))

(define-presentation-type class-presentation ())

(defun display-class-overview (frame pane)
  (flet ((render-attribute (attribute)
           (with-drawing-options (pane :text-style (make-text-style :sans-serif :bold :normal):ink +black+ :move-cursor nil)
             (surrounding-output-with-border (pane :shape :underline)
             
               (format pane attribute)))))

    (let ((class (browser-class frame)))
      (with-drawing-options (pane :text-style (make-text-style :sans-serif :bold :large) :ink +black+)
        (surrounding-output-with-border (pane :shape :underline
                                              :line-thickness 2
                                              :move-cursor nil)
          (format pane "~A" (class-name class))))
      (terpri pane)
      (terpri pane)
      (render-attribute "Description:")
;      (format pane "~A" (or (documentation class nil) "Not documented"))
      (terpri pane)
      (render-attribute "Slots:")
      (loop for slot in (sb-mop:class-direct-slots class)
         do
         (progn
           (format pane "~A" (sb-mop::slot-definition-name slot))
           (terpri pane)))
      (terpri pane)
      (render-attribute "Direct superclasses:")
      (if (not (sb-mop::class-direct-superclasses class))
          (format pane "None")
          (loop for superclass in (sb-mop::class-direct-superclasses class)
             do
               (progn
                 (with-output-as-presentation (pane superclass 'class-presentation)
                   (format pane "~A" (sb-mop::class-name superclass)))
                 (format pane " "))))
      (terpri pane)
      (terpri pane)
      (render-attribute "Direct subclasses:")
      (if (not (sb-mop::class-direct-subclasses class))
          (format pane "None")
          (loop for subclass in (sb-mop::class-direct-subclasses class)
             do
               (progn
                 (with-output-as-presentation (pane subclass 'class-presentation)
                   (format pane "~A" (sb-mop::class-name subclass)))
                 (format pane " "))))
      (terpri pane) (terpri pane)
      (render-attribute "Direct methods:")
      (if (not (sb-mop::specializer-direct-methods class))
          (format pane "None")
          (loop for method in (sb-mop::specializer-direct-methods class)
               do (progn
                    (format pane "~A" method)
                    (format pane " ")))))))

(define-clim-class-browser-command (com-inspect-superclasses :name "Superclasses" :menu t) ()
  (run-frame-top-level (make-application-frame 'clim-class-browser::class-browser
                                               :class (browser-class *application-frame*)
                                               :navigate :superclasses)))

(define-clim-class-browser-command (com-inspect-subclasses :name "Subclasses" :menu t) ()
  (run-frame-top-level (make-application-frame 'clim-class-browser::class-browser
                                               :class (browser-class *application-frame*)
                                               :navigate :subclasses)))

(define-clim-class-browser-command com-inspect-class ((class t))
  (run-frame-top-level
   (make-application-frame 'clim-class-browser :class class)))

(define-presentation-to-command-translator inspect-class
    (class-presentation
     com-inspect-class
     clim-class-browser
     :gesture :select
     :documentation "Inspect a class")
    (object)
  (list object))

(defun display-class-graph (frame pane)
  )

(defun run-class-browser (class)
  (run-frame-top-level
   (make-application-frame 'clim-class-browser :class class)))