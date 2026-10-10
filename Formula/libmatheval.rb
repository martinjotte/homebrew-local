class Libmatheval < Formula
  desc "Library for parsing and evaluating symbolic expressions"
  homepage "https://www.gnu.org/software/libmatheval/"
  url "http://ftp.gnu.org/gnu/libmatheval/libmatheval-1.1.11.tar.gz"
  sha256 "474852d6715ddc3b6969e28de5e1a5fbaff9e8ece6aebb9dc1cc63e9e88e89ab"
  license "GPL"

  depends_on "bison" => :build
  depends_on "pkg-config" => :build
  depends_on "guile"

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff"
    sha256 "83af02f2aa2b746bb7225872cab29a253264be49db0ecebb12f841562d9a2923"
  end

  patch :DATA

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    system "./configure", *std_configure_args, "--disable-silent-rules", "--disable-static"
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test libmatheval`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
--- libmatheval-1.1.11-v/configure	2018-07-13 11:16:19.115719477 +0200
+++ libmatheval-1.1.11/configure	2018-07-13 11:33:07.914093005 +0200
@@ -640,6 +640,7 @@
 GUILE_CFLAGS
 GUILE_TOOLS
 GUILE_CONFIG
+GUILE_EFFECTIVE_VERSION
 GUILE
 AUTOM4TE
 YFLAGS
@@ -4831,21 +4832,6 @@
 
 
 
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
 # Check whether --with-gnu-ld was given.
 if test "${with_gnu_ld+set}" = set; then :
   withval=$with_gnu_ld; test "$withval" = no || with_gnu_ld=yes
@@ -12267,8 +12253,9 @@
  break
 fi
 done
+# start patch
 
-
+CPPFLAGS="$GUILE_CFLAGS  -DSCM_ENABLE_DEPRECATED=0 $CPPFLAGS"
 ac_fn_c_check_type "$LINENO" "scm_t_bits" "ac_cv_type_scm_t_bits" "#include <libguile.h>
 "
 if test "x$ac_cv_type_scm_t_bits" = xyes; then :
@@ -12276,14 +12263,15 @@
 $as_echo "#define HAVE_SCM_T_BITS 1" >>confdefs.h
 
 fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for scm_c_define_gsubr in -lguile" >&5
-$as_echo_n "checking for scm_c_define_gsubr in -lguile... " >&6; }
-if ${ac_cv_lib_guile_scm_c_define_gsubr+:} false; then :
+GUILE_EFFECTIVE_VERSION=3.0
+as_ac_Lib=`$as_echo "ac_cv_lib_guile-$GUILE_EFFECTIVE_VERSION''_scm_c_define_gsubr" | $as_tr_sh`
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for scm_c_define_gsubr in -lguile-$GUILE_EFFECTIVE_VERSION" >&5
+$as_echo_n "checking for scm_c_define_gsubr in -lguile-$GUILE_EFFECTIVE_VERSION... " >&6; }
+if eval \${$as_ac_Lib+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
-LIBS="-lguile $GUILE_LDFLAGS $LIBS"
+LIBS="-lguile-$GUILE_EFFECTIVE_VERSION $GUILE_LDFLAGS $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
@@ -12303,29 +12291,31 @@
 }
 _ACEOF
 if ac_fn_c_try_link "$LINENO"; then :
-  ac_cv_lib_guile_scm_c_define_gsubr=yes
+  eval "$as_ac_Lib=yes"
 else
-  ac_cv_lib_guile_scm_c_define_gsubr=no
+  eval "$as_ac_Lib=no"
 fi
 rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_guile_scm_c_define_gsubr" >&5
-$as_echo "$ac_cv_lib_guile_scm_c_define_gsubr" >&6; }
-if test "x$ac_cv_lib_guile_scm_c_define_gsubr" = xyes; then :
+eval ac_res=\$$as_ac_Lib
+	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+if eval test \"x\$"$as_ac_Lib"\" = x"yes"; then :
 
 $as_echo "#define HAVE_SCM_C_DEFINE_GSUBR 1" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for scm_make_gsubr in -lguile" >&5
-$as_echo_n "checking for scm_make_gsubr in -lguile... " >&6; }
-if ${ac_cv_lib_guile_scm_make_gsubr+:} false; then :
+as_ac_Lib=`$as_echo "ac_cv_lib_guile-$GUILE_EFFECTIVE_VERSION''_scm_make_gsubr" | $as_tr_sh`
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for scm_make_gsubr in -lguile-$GUILE_EFFECTIVE_VERSION" >&5
+$as_echo_n "checking for scm_make_gsubr in -lguile-$GUILE_EFFECTIVE_VERSION... " >&6; }
+if eval \${$as_ac_Lib+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
-LIBS="-lguile $GUILE_LDFLAGS $LIBS"
+LIBS="-lguile-$GUILE_EFFECTIVE_VERSION $GUILE_LDFLAGS $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
@@ -12345,29 +12335,31 @@
 }
 _ACEOF
 if ac_fn_c_try_link "$LINENO"; then :
-  ac_cv_lib_guile_scm_make_gsubr=yes
+  eval "$as_ac_Lib=yes"
 else
-  ac_cv_lib_guile_scm_make_gsubr=no
+  eval "$as_ac_Lib=no"
 fi
 rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_guile_scm_make_gsubr" >&5
-$as_echo "$ac_cv_lib_guile_scm_make_gsubr" >&6; }
-if test "x$ac_cv_lib_guile_scm_make_gsubr" = xyes; then :
+eval ac_res=\$$as_ac_Lib
+	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+if eval test \"x\$"$as_ac_Lib"\" = x"yes"; then :
 
 $as_echo "#define HAVE_SCM_MAKE_GSUBR 1" >>confdefs.h
 
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for scm_num2dbl in -lguile" >&5
-$as_echo_n "checking for scm_num2dbl in -lguile... " >&6; }
-if ${ac_cv_lib_guile_scm_num2dbl+:} false; then :
+as_ac_Lib=`$as_echo "ac_cv_lib_guile-$GUILE_EFFECTIVE_VERSION''_scm_num2dbl" | $as_tr_sh`
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for scm_num2dbl in -lguile-$GUILE_EFFECTIVE_VERSION" >&5
+$as_echo_n "checking for scm_num2dbl in -lguile-$GUILE_EFFECTIVE_VERSION... " >&6; }
+if eval \${$as_ac_Lib+:} false; then :
   $as_echo_n "(cached) " >&6
 else
   ac_check_lib_save_LIBS=$LIBS
-LIBS="-lguile $GUILE_LDFLAGS $LIBS"
+LIBS="-lguile-$GUILE_EFFECTIVE_VERSION $GUILE_LDFLAGS $LIBS"
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
@@ -12387,22 +12379,25 @@
 }
 _ACEOF
 if ac_fn_c_try_link "$LINENO"; then :
-  ac_cv_lib_guile_scm_num2dbl=yes
+  eval "$as_ac_Lib=yes"
 else
-  ac_cv_lib_guile_scm_num2dbl=no
+  eval "$as_ac_Lib=no"
 fi
 rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_guile_scm_num2dbl" >&5
-$as_echo "$ac_cv_lib_guile_scm_num2dbl" >&6; }
-if test "x$ac_cv_lib_guile_scm_num2dbl" = xyes; then :
+eval ac_res=\$$as_ac_Lib
+	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+if eval test \"x\$"$as_ac_Lib"\" = x"yes"; then :
 
 $as_echo "#define HAVE_SCM_NUM2DBL 1" >>confdefs.h
 
 fi
 
+# end patch
+# end patch
 
 ac_config_files="$ac_config_files Makefile doc/Makefile lib/Makefile"
 
--- libmatheval-1.1.11-v/tests/matheval.c.bak	2018-07-13 12:43:21.718862366 +0200
+++ libmatheval-1.1.11/tests/matheval.c	2018-07-13 12:46:34.162597100 +0200
@@ -51,7 +51,7 @@
 
 /* Guile interface for libmatheval library.  Procedures below are simple
  * wrappers for corresponding libmatheval procedures. */
-static scm_sizet evaluator_destroy_scm(SCM evaluator_smob);
+static size_t    evaluator_destroy_scm(SCM evaluator_smob);
 static SCM      evaluator_create_scm(SCM string);
 static SCM      evaluator_evaluate_scm(SCM evaluator_smob, SCM count,
 				       SCM names, SCM values);
@@ -122,7 +122,7 @@
 }
 
 /* Wrapper for evaluator_destroy() procedure from libmatheval library. */
-static          scm_sizet
+static          size_t
 evaluator_destroy_scm(SCM evaluator_smob)
 {
 	SCM_ASSERT((SCM_NIMP(evaluator_smob)
--- libmatheval-1.1.11/Makefile.in.orig	2018-07-13 17:42:03.426339145 +0200
+++ libmatheval-1.1.11/Makefile.in	2018-07-13 17:42:24.190310979 +0200
@@ -316,7 +316,7 @@
 MAINTAINERCLEANFILES = Makefile.in aclocal.m4 configure config.h.in	\
 config.log config.status stamp-h.in $(AUX_DIST)
 
-SUBDIRS = doc lib tests
+SUBDIRS = doc lib 
 pkgconfigdir = $(libdir)/pkgconfig
 pkgconfig_DATA = libmatheval.pc
 all: config.h
@@ -863,7 +863,7 @@
 .PHONY: beauty dist-hook
 
 beauty:
-	-for dir in lib tests; do cd $$dir; $(MAKE) $@; cd ..; done
+	-for dir in lib ; do cd $$dir; $(MAKE) $@; cd ..; done
 
 dist-hook:
 	for file in $(AUX_DIST); do \
