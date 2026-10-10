class H4h5tools < Formula
  desc "HDF4 to HDF5 conversion tools"
  homepage "https://support.hdfgroup.org/downloads/h4h5tools/h4h5tools_2_2_5.html"
  url "https://support.hdfgroup.org/ftp/HDF5/releases/h4toh5/h4toh5-2.2.5/src/h4h5tools-2.2.5.tar.gz"
  sha256 "79f6505c1df3ad0c2cc1a19b9b433b5d955dfd7d2dffefc080d89fdde01fd6f2"
  license "Permissive"

  depends_on "hdf4"
  depends_on "hdf5"
  depends_on "hdfeos2"

  patch :DATA

  def install
    ENV["LIBS"] = "-L#{Formula["hdf4"].opt_prefix}/lib -ldf -lmfhdf"
    ENV.append "CFLAGS", "-Wno-error=incompatible-function-pointer-types"
    ENV.append "CFLAGS", "-Wno-error=implicit-function-declaration"
    ENV.append "CFLAGS", "-Wno-error=int-conversion"
    ENV.append "CFLAGS", "-Wno-error=implicit-int"
    system "./configure", *std_configure_args, "--disable-silent-rules", "--with-hdfeos2=#{Formula["hdfeos2"].opt_prefix}", "--with-hdf5=#{Formula["hdf5"].opt_prefix}"
    system "make", "install" # if this fails, try separate make/make install steps
    rm_rf "#{lib}"
    rm_rf "#{include}"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test h4h5tools`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__

diff -up h4h5tools-2.2.5/configure.orig h4h5tools-2.2.5/configure
--- h4h5tools-2.2.5/configure.orig	2021-06-14 23:49:52.000000000 -0400
+++ h4h5tools-2.2.5/configure	2021-06-15 02:52:29.000000000 -0400
@@ -4929,10 +4929,8 @@ fi
     ;;
 esac

- HDF4_VERSION_STRING=""
-hdf4_lib=`$CC -show | awk '{ i=1; regex="^-L"; while ($i != $NF) { if (match($i,regex)) { print substr($i,RSTART+RLENGTH);} i = i+1; } }'`
-HDF4_VERSION_STRING=`grep "HDF4 Version:" $hdf4_lib/libhdf4.settings | awk '{ FS=":"; print $NF; }'`
-
+HDF4_VERSION_STRING=""
+HDF4_VERSION_STRING=`grep "HDF4 Version:" /usr/local/lib/libhdf4.settings | awk '{ FS=":"; print $NF; }'`

  H5_USE_FILTER_ZLIB="no"

@@ -4951,6 +4949,7 @@ else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
+   #include <stdlib.h>
    #include <hdf5.h>
 
    int main(void)
@@ -5004,6 +5003,7 @@ else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
+   #include <stdlib.h>
    #include <hdf5.h>
 
    int main(void)
@@ -5053,6 +5053,7 @@ else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
+       #include <stdlib.h>
        #include <hdf5.h>
 
        int main(void)
@@ -5106,6 +5107,7 @@ else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
+    #include <stdlib.h>
     #include <hdf.h>
 
     int main(void)
--- h4h5tools-2.2.5/lib/src/h4toh5main.h
+++ h4h5tools-2.2.5/lib/src/h4toh5main.h
@@ -43,6 +43,9 @@ Author:  Kent Yang(myang6@hdfgroup.org)
 
 #endif
 
+#include <unistd.h>
+#include <sys/stat.h>
+
 /* For windows support.*/
 #ifdef WIN32
 typedef unsigned int mode_t;
--- h4h5tools-2.2.5/lib/src/h4toh5util.h
+++ h4h5tools-2.2.5/lib/src/h4toh5util.h
@@ -47,8 +47,10 @@ Author:  Kent Yang(myang6@hdfgroup.org)
 #include "mfhdf.h"
 #include "H4TOH5Ipublic.h"
 #include "H4TOH5Iprivate.h"
+#include "H5DSpublic.h"
 #include "h4toh5.h"
 #include <string.h>
+#define HDstrdup(s) ((char *)strdup((const char *)(s)))
 
 /**********************************************/
 /*************** section I *******************/
--- h4h5tools-2.2.5/utils/h5toh4/h5toh4.c
+++ h4h5tools-2.2.5/utils/h5toh4/h5toh4.c
@@ -29,6 +29,8 @@
 #include <errno.h>
 #include <string.h>
 #include <fcntl.h>
+#include <unistd.h>
+#define HDstrdup(s) ((char *)strdup((const char *)(s)))

 #include <stdarg.h>
 #include <stdio.h>
--- h4h5tools-2.2.5/utils/h4toh5/h4toh5main.h.struc	2025-05-13 09:59:47.017575385 -0400
+++ h4h5tools-2.2.5/utils/h4toh5/h4toh5main.h	2025-05-13 10:00:43.039016858 -0400
@@ -46,6 +46,10 @@ Author:  Kent Yang(myang6@hdfgroup.org)
 #include <sys/types.h>
 #ifndef WIN32
 #include <unistd.h>
+#include <stdlib.h>
+#include <sys/stat.h>
+#include <string.h>
+#define HDstrdup(s) ((char *)strdup((const char *)(s)))
 #endif

 /* For windows support.*/
diff -up h4h5tools-2.2.5/lib/src/h4toh5util.c.orig h4h5tools-2.2.5/lib/src/h4toh5util.c
--- h4h5tools-2.2.5/lib/src/h4toh5util.c.orig	2026-10-02 12:40:10.913590881 -0400
+++ h4h5tools-2.2.5/lib/src/h4toh5util.c	2026-10-02 13:05:53.982041833 -0400
@@ -2826,7 +2826,7 @@ char* H4toH5get_group_name(hid_t h4toh5i
     char* vgroup_name;
     char* h5_vgroupname = NULL;
     int  check_vgroupname;
-    uint16  vgroupnamelen;
+    size_t vgroupnamelen = VGNAMELENMAX*10;
 
     /* define h4toh5 temporary variable. */
     h4toh5id_t* temph4toh5id;  
@@ -2834,14 +2834,15 @@ char* H4toH5get_group_name(hid_t h4toh5i
     /* obtain global table*/
     temph4toh5id = H4TOH5I_object(h4toh5id);
     
-/*  h4toh5_ZeroMemory(vgroup_name,VGNAMELENMAX*10);*/
+/*  h4toh5_ZeroMemory(vgroup_name,VGNAMELENMAX*10)
     if(Vgetnamelen(vgroup_id,&vgroupnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                             __FILE__,__LINE__);
         return NULL;
     }
+ */
 
-    vgroup_name = (char*) malloc((vgroupnamelen+1)*sizeof(char));
+    vgroup_name = (char*) malloc((vgroupnamelen)*sizeof(char));
 
     if(vgroup_name == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
@@ -2850,7 +2851,7 @@ char* H4toH5get_group_name(hid_t h4toh5i
     }
 
     check_vgroupname=0;
-    if(Vgetname(vgroup_id,vgroup_name)==FAIL){
+    if(Vgetname(vgroup_id,vgroup_name,&vgroupnamelen)==FAIL){
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name",
              __FILE__,__LINE__);
 	free(vgroup_name);
diff -up h4h5tools-2.2.5/lib/src/h4toh5vgroup.c.orig h4h5tools-2.2.5/lib/src/h4toh5vgroup.c
--- h4h5tools-2.2.5/lib/src/h4toh5vgroup.c.orig	2026-10-02 12:40:20.715390138 -0400
+++ h4h5tools-2.2.5/lib/src/h4toh5vgroup.c	2026-10-02 14:31:22.694007288 -0400
@@ -105,8 +105,8 @@ int H4toH5bas_vgroup(hid_t h4toh5_id,
     int32       vgroup_ref; /* Vgroup reference number */
     char*        vgroup_class; /* Vgroup class name */
     char*        vgroup_name; /* Vgroup name */
-    uint16  vclassnamelen; /*Vgroup class name length */
-    uint16  vgroupnamelen; /*Vgroup name length */
+    size_t  vclassnamelen = VGNAMELENMAX*10; /*Vgroup class name length */
+    size_t  vgroupnamelen = VGNAMELENMAX*10; ; /*Vgroup name length */
 
     char*       h5c_groupname; /* The absolute path of HDF5 group name */
     char*       ori_h5cgroup_name; /* The original path of HDF5 group name */
@@ -131,27 +131,29 @@ int H4toH5bas_vgroup(hid_t h4toh5_id,
     /* obtain h4toh5 id handler*/
     temph4toh5id = H4TOH5I_object(h4toh5_id);
 
-    if(Vgetnamelen(vgroup_id,&vgroupnamelen) == FAIL) {
+/*  if(Vgetnamelen(vgroup_id,&vgroupnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                      __FILE__,__LINE__);
         return FAIL;
     }
-
-    vgroup_name = (char*) malloc((int)(vgroupnamelen+1)*sizeof(char));
+ */
+    
+    vgroup_name = (char*) malloc((int)(vgroupnamelen)*sizeof(char));
     if(vgroup_name == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                          __FILE__,__LINE__);
         return FAIL;
     }
 
-    if(Vgetclassnamelen(vgroup_id,&vclassnamelen) == FAIL) {
+/*  if(Vgetclassnamelen(vgroup_id,&vclassnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                          __FILE__,__LINE__);
         free(vgroup_name);
         return FAIL;
     }
+ */
 
-    vgroup_class = (char*) malloc((int)(vclassnamelen+1)*sizeof(char));
+    vgroup_class = (char*) malloc((int)(vclassnamelen)*sizeof(char));
     if(vgroup_class == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                           __FILE__,__LINE__);
@@ -180,7 +182,7 @@ int H4toH5bas_vgroup(hid_t h4toh5_id,
         return FAIL;
     }
 
-    if(Vgetname(vgroup_id,vgroup_name) == FAIL) {
+    if(Vgetname(vgroup_id,vgroup_name,&vgroupnamelen) == FAIL) {
         free(vgroup_name);
         free(vgroup_class);
         H4toH5error_set(temph4toh5id,2,
@@ -189,7 +191,7 @@ int H4toH5bas_vgroup(hid_t h4toh5_id,
         return FAIL;
     }
 
-    if(Vgetclass(vgroup_id,vgroup_class) == FAIL) {
+    if(Vgetclass(vgroup_id,vgroup_class,&vclassnamelen) == FAIL) {
         free(vgroup_name);
         free(vgroup_class);
         H4toH5error_set(temph4toh5id,2,
@@ -525,8 +527,8 @@ int H4toH5adv_group(hid_t h4toh5_id,
     int32       vgroup_ref;  /* Vgroup reference number */
     char*        vgroup_class; /* Vgroup class name */
     char*        vgroup_name;  /* Vgroup name */
-    uint16  vclassnamelen; /*Vgroup class name length */
-    uint16  vgroupnamelen; /*Vgroup name length */
+    size_t  vclassnamelen = VGNAMELENMAX*10; /*Vgroup class name length */
+    size_t  vgroupnamelen = VGNAMELENMAX*10; /*Vgroup name length */
     char*       h5c_groupname; /* The absolute path of HDF5 group name */
     char*       ori_h5cgroup_name; /* The original path of HDF5 group name */
 
@@ -554,27 +556,27 @@ int H4toH5adv_group(hid_t h4toh5_id,
 
     /*zeroing out memory for vgroup_class and vgroup_name */
 
-    if(Vgetnamelen(vgroup_id,&vgroupnamelen) == FAIL) {
+/*  if(Vgetnamelen(vgroup_id,&vgroupnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                                        __FILE__,__LINE__);
         return FAIL;
     }
-
-    vgroup_name = (char*) malloc((int)(vgroupnamelen+1)*sizeof(char));
+ */
+    vgroup_name = (char*) malloc((int)(vgroupnamelen)*sizeof(char));
     if(vgroup_name == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                                         __FILE__,__LINE__);
         return FAIL;
     }
 
-    if(Vgetclassnamelen(vgroup_id,&vclassnamelen) == FAIL) {
+/*  if(Vgetclassnamelen(vgroup_id,&vclassnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                                        __FILE__,__LINE__);
         free(vgroup_name);
         return FAIL;
     }
-
-    vgroup_class = (char*) malloc((int)(vclassnamelen+1)*sizeof(char));
+ */
+    vgroup_class = (char*) malloc((int)(vclassnamelen)*sizeof(char));
     if(vgroup_class == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                                 __FILE__,__LINE__);
@@ -602,7 +604,7 @@ int H4toH5adv_group(hid_t h4toh5_id,
         return FAIL;
     }
 
-    if(Vgetname(vgroup_id,vgroup_name) == FAIL) {
+    if(Vgetname(vgroup_id,vgroup_name,&vgroupnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,
              "unable to obtain Vgroup name",
              __FILE__,__LINE__);
@@ -611,7 +613,7 @@ int H4toH5adv_group(hid_t h4toh5_id,
         return FAIL;
     }
 
-    if(Vgetclass(vgroup_id,vgroup_class) == FAIL) {
+    if(Vgetclass(vgroup_id,vgroup_class,&vclassnamelen) == FAIL) {
          H4toH5error_set(temph4toh5id,2,
              "unable to obtain Vgroup class name",
              __FILE__,__LINE__);
@@ -912,7 +914,7 @@ int convert_vgroup(hid_t h4toh5_id,
     int32       vgroup_cid; /* Vgroup id */
     int32       istat; /* The flag to check the return status of HDF4 APIs */
     char*        cvgroup_name; /* the child vgroup name */
-    uint16  vgroupnamelen; /*Vgroup name length */ 
+    size_t  vgroupnamelen = VGNAMELENMAX*10; /*Vgroup name length */ 
 
     h4toh5id_t* temph4toh5id; /*    pointer to h4toh5 id struct for 
                 passing parameters of error handlings */
@@ -926,13 +928,13 @@ int convert_vgroup(hid_t h4toh5_id,
         return FAIL;
     }
 
-    if(Vgetnamelen(vgroup_cid,&vgroupnamelen) == FAIL) {
+/*  if(Vgetnamelen(vgroup_cid,&vgroupnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                                       __FILE__,__LINE__);
         return FAIL;
     }
-    
-    cvgroup_name = (char*) malloc((int)(vgroupnamelen+1)*sizeof(char));
+ */ 
+    cvgroup_name = (char*) malloc((int)(vgroupnamelen)*sizeof(char));
     if(cvgroup_name == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                                       __FILE__,__LINE__);
@@ -941,7 +943,7 @@ int convert_vgroup(hid_t h4toh5_id,
  
     /* recursively obtain information from the group*/
     /* check whether it is looked up, if yes, create a hard link.*/
-    istat = Vgetname(vgroup_cid,cvgroup_name);
+    istat = Vgetname(vgroup_cid,cvgroup_name,&vgroupnamelen);
     if(istat == FAIL) {
         H4toH5error_set(temph4toh5id,2,
              "fail to get the name of vgroup ",
@@ -1306,8 +1308,8 @@ int vg_transattrs(hid_t h4toh5_id,
     /* define variables for hdf4. */
     char*            vgroup_name; /* vgroup name */
     char*            vgroup_class; /* vgroup class name */
-    uint16  vclassnamelen; /*Vgroup class name length */
-    uint16  vgroupnamelen; /*Vgroup name length */
+    size_t  vclassnamelen = VGNAMELENMAX*10; /*Vgroup class name length */
+    size_t  vgroupnamelen = VGNAMELENMAX*10; /*Vgroup name length */
 
     char            vgattr_name[H4H5_MAX_NC_NAME]; /* vgroup attribute name */
     char            objtype[H4H5_MAX_NC_NAME]; /* object type name */
@@ -1339,27 +1341,27 @@ int vg_transattrs(hid_t h4toh5_id,
     /* obtain global table*/
     temph4toh5id = H4TOH5I_object(h4toh5_id);
 
-    if(Vgetnamelen(h4vg,&vgroupnamelen) == FAIL) {
+/*  if(Vgetnamelen(h4vg,&vgroupnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                                             __FILE__,__LINE__);
         return FAIL;
     }
-
-    vgroup_name = (char*) malloc((int)(vgroupnamelen+1)*sizeof(char));
+ */
+    vgroup_name = (char*) malloc((int)(vgroupnamelen)*sizeof(char));
     if(vgroup_name == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                               __FILE__,__LINE__);
         return FAIL;
     }
 
-    if(Vgetclassnamelen(h4vg,&vclassnamelen) == FAIL) {
+/*  if(Vgetclassnamelen(h4vg,&vclassnamelen) == FAIL) {
         H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                               __FILE__,__LINE__);
         free(vgroup_name);
         return FAIL;
     }
-
-    vgroup_class = (char*) malloc((int)(vclassnamelen+1)*sizeof(char));
+ */
+    vgroup_class = (char*) malloc((int)(vclassnamelen)*sizeof(char));
     if(vgroup_class == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                               __FILE__,__LINE__);
@@ -1368,7 +1370,7 @@ int vg_transattrs(hid_t h4toh5_id,
     }
 
     /* ignore CDF0.0 and RIG0.0 vgroups. */
-    if(Vgetclass(h4vg,vgroup_class) == SUCCEED){
+    if(Vgetclass(h4vg,vgroup_class,&vclassnamelen) == SUCCEED){
         if(vgroup_class[0] != '\0') {
             if(!strcmp(vgroup_class,_HDF_CDF)||
                 !strcmp(vgroup_class,GR_NAME)) {
@@ -1586,7 +1588,7 @@ int vg_transattrs(hid_t h4toh5_id,
             return FAIL;
         }
    
-        if(Vgetname(h4vg,vgroup_name) == SUCCEED){
+        if(Vgetname(h4vg,vgroup_name,&vgroupnamelen) == SUCCEED){
             if(vgroup_name[0] != '\0') {
                 if(h4_transpredattrs(h4toh5_id,h5g,HDF4_OBJECT_NAME,vgroup_name)==FAIL){
                     H4toH5error_set(temph4toh5id,5,
@@ -1697,7 +1699,7 @@ int H4toH5vgroup_attr_index(hid_t h4toh5
 
     /* define variables for hdf4. */
     char*          vgroup_name; /* vgroup name */
-    uint16         vgroupnamelen; /*Vgroup name length */
+    size_t         vgroupnamelen = VGNAMELENMAX*10; /*Vgroup name length */
     char*       cor_vgroup_name;
     char            vgattr_name[H4H5_MAX_NC_NAME]; /* vgroup attribute name */
     char            refstr[MAXREF_LENGTH]; /* string format of HDF4 vgroup reference
@@ -1732,13 +1734,13 @@ int H4toH5vgroup_attr_index(hid_t h4toh5
 
     temph4toh5id = H4TOH5I_object(h4toh5_id);
 
-    if(Vgetnamelen(h4vg,&vgroupnamelen) == FAIL) {
+/*  if(Vgetnamelen(h4vg,&vgroupnamelen) == FAIL) {
          H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                                          __FILE__,__LINE__);
          return FAIL;
     }
-
-    vgroup_name = (char*) malloc((int)(vgroupnamelen+1)*sizeof(char));
+ */
+    vgroup_name = (char*) malloc((int)(vgroupnamelen)*sizeof(char));
     if(vgroup_name == NULL) {
         H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                               __FILE__,__LINE__);
@@ -1755,7 +1757,7 @@ int H4toH5vgroup_attr_index(hid_t h4toh5
         return FAIL;
     }
 
-    if(Vgetname(h4vg,vgroup_name)==FAIL){
+    if(Vgetname(h4vg,vgroup_name,&vgroupnamelen)==FAIL){
         H4toH5error_set(temph4toh5id,2,
                  "cannot obtain HDF4 vgroup name",
                  __FILE__,__LINE__);
@@ -2055,8 +2057,8 @@ int checkvloneobject(hid_t h4toh5_id,int
     int32  istat; /* flag to check the "return" status of HDF4 interfaces */
     char*       vgroup_name = NULL; /* vgroup name */
     char*       vgroup_class = NULL; /* vgroup class name */
-    uint16  vclassnamelen; /*Vgroup class name length */
-    uint16  vgroupnamelen; /*Vgroup name length */
+    size_t  vclassnamelen = VGNAMELENMAX*10; /*Vgroup class name length */
+    size_t  vgroupnamelen = VGNAMELENMAX*10; /*Vgroup name length */
     int      check_vgroup; /* flag to check the vgroup status */
     int      lone_vg_number; /* index to represent the lone vgroup number */
 
@@ -2114,15 +2116,15 @@ int checkvloneobject(hid_t h4toh5_id,int
             return FAIL;
         }
 
-        if(Vgetnamelen(vgroup_id,&vgroupnamelen) == FAIL) {
+     /* if(Vgetnamelen(vgroup_id,&vgroupnamelen) == FAIL) {
             H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                                           __FILE__,__LINE__);
             free(ref_array);
             Vdetach(vgroup_id);
             return FAIL;
         }
-
-        vgroup_name = (char*) malloc((int)(vgroupnamelen+1)*sizeof(char));
+     */
+        vgroup_name = (char*) malloc((int)(vgroupnamelen)*sizeof(char));
         if(vgroup_name == NULL) {
             H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                                         __FILE__,__LINE__);
@@ -2131,9 +2133,9 @@ int checkvloneobject(hid_t h4toh5_id,int
             return FAIL;
         }
 
-        h4toh5_ZeroMemory(vgroup_name,(int)(vgroupnamelen+1)*sizeof(char));
+        h4toh5_ZeroMemory(vgroup_name,(int)(vgroupnamelen)*sizeof(char));
 
-        if(Vgetclassnamelen(vgroup_id,&vclassnamelen) == FAIL) {
+     /* if(Vgetclassnamelen(vgroup_id,&vclassnamelen) == FAIL) {
             H4toH5error_set(temph4toh5id,2,"cannot obtain vgroup name length",
                                                             __FILE__,__LINE__);
             free(ref_array);
@@ -2141,8 +2143,8 @@ int checkvloneobject(hid_t h4toh5_id,int
             Vdetach(vgroup_id);
             return FAIL;
         }
-
-        vgroup_class = (char*) malloc((int)(vclassnamelen+1)*sizeof(char));
+     */
+        vgroup_class = (char*) malloc((int)(vclassnamelen)*sizeof(char));
         if(vgroup_class == NULL) {
             H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                                            __FILE__,__LINE__);
@@ -2152,10 +2154,10 @@ int checkvloneobject(hid_t h4toh5_id,int
             return FAIL;
         }
          
-        h4toh5_ZeroMemory(vgroup_class,(int)(vclassnamelen+1)*sizeof(char));
+        h4toh5_ZeroMemory(vgroup_class,(int)(vclassnamelen)*sizeof(char));
 
         /*obtain group name and class name.*/
-        istat = Vgetclass(vgroup_id,vgroup_class);
+        istat = Vgetclass(vgroup_id,vgroup_class,&vclassnamelen);
         if(istat == FAIL) {
             H4toH5error_set(temph4toh5id,2,
                             "fail to obtain vgroup class name",
@@ -2167,7 +2169,7 @@ int checkvloneobject(hid_t h4toh5_id,int
             return FAIL;
         }
 
-        istat = Vgetname(vgroup_id,vgroup_name);
+        istat = Vgetname(vgroup_id,vgroup_name,&vgroupnamelen);
         if(istat == FAIL ) {
             H4toH5error_set(temph4toh5id,2,
                             "fail to obtain vgroup name",
@@ -2245,11 +2247,11 @@ int checkvringobject(hid_t h4toh5id,int3
 #if 0
     char*       vgroup_name; /* vgroup name */
     char*       vgroup_class;/* vgroup class name */
-    uint16  vclassnamelen; /*Vgroup class name length */
-    uint16  vgroupnamelen; /*Vgroup name length */
 #endif
-    char        vgroup_name[VGNAMELENMAX*4];
-    char        vgroup_class[VGNAMELENMAX*4];
+    size_t  vclassnamelen = VGNAMELENMAX*4; /*Vgroup class name length */
+    size_t  vgroupnamelen = VGNAMELENMAX*4; /*Vgroup name length */
+    char        vgroup_name[vgroupnamelen];
+    char        vgroup_class[vclassnamelen];
     int      check_vgroup; /* flag to check the vgroup */
     int32  istat; /* The flag to check the return status of HDF4 APIs */
     h4toh5id_t* temph4toh5id; /*    pointer to h4toh5 id struct for 
@@ -2265,7 +2267,7 @@ int checkvringobject(hid_t h4toh5id,int3
             return FAIL;
      }
 
-     vgroup_name = (char*) malloc((int)(vgroupnamelen+1)*sizeof(char));
+     vgroup_name = (char*) malloc((int)(vgroupnamelen)*sizeof(char));
      if(vgroup_name == NULL) {
             H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                                            __FILE__,__LINE__);
@@ -2278,7 +2280,7 @@ int checkvringobject(hid_t h4toh5id,int3
                                     return FAIL;
     }
 
-    vgroup_class = (char*) malloc((int)(vclassnamelen+1)*sizeof(char));
+    vgroup_class = (char*) malloc((int)(vclassnamelen)*sizeof(char));
     if(vgroup_class == NULL) {
                          H4toH5error_set(temph4toh5id,1,"cannot allocate memory",
                                                                __FILE__,__LINE__);
@@ -2307,8 +2309,8 @@ int checkvringobject(hid_t h4toh5id,int3
                 return FAIL;
             }
 
-            h4toh5_ZeroMemory(vgroup_name,VGNAMELENMAX*4);
-            istat = Vgetname(vgroup_id,vgroup_name);
+            h4toh5_ZeroMemory(vgroup_name,vgroupnamelen);
+            istat = Vgetname(vgroup_id,vgroup_name,&vgroupnamelen);
             if(istat ==FAIL) {
                 H4toH5error_set(temph4toh5id,2,
                          "fail to get vgroup name",
@@ -2317,8 +2319,8 @@ int checkvringobject(hid_t h4toh5id,int3
                 return FAIL;
             }
 
-            h4toh5_ZeroMemory(vgroup_class,VGNAMELENMAX*4);
-            if(Vgetclass(vgroup_id,vgroup_class) == FAIL) {
+            h4toh5_ZeroMemory(vgroup_class,vclassnamelen);
+            if(Vgetclass(vgroup_id,vgroup_class,&vclassnamelen) == FAIL) {
                 H4toH5error_set(temph4toh5id,2,
                          "fail to get vgroup class name",
                          __FILE__,__LINE__);
diff -up h4h5tools-2.2.5/lib/test/h4h5apitestadvgroup.c.orig h4h5tools-2.2.5/lib/test/h4h5apitestadvgroup.c
--- h4h5tools-2.2.5/lib/test/h4h5apitestadvgroup.c.orig	2026-10-02 12:40:30.355050586 -0400
+++ h4h5tools-2.2.5/lib/test/h4h5apitestadvgroup.c	2026-10-02 14:35:49.191808841 -0400
@@ -12,6 +12,7 @@
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
 #include "h4toh5.h"
+#include <stdlib.h>
 #define _HDF_CHK_TBL_CLASST "_HDF_CHK_TBL_"
 /* There are 12 test cases for h4toh5 library.*/
 /* h4h5apitestdefault,
@@ -65,7 +66,8 @@ int main() {
     int                     lone_vd_number;/* lone vdata number. */
     int32                *ref_vgroup_array; /* array of vgroup reference */
     int                     lone_vg_number; /* lone vgroup number. */
-    char                    vgroup_class[VGNAMELENMAX];/* vgroup class name */
+    size_t                  vclassnamelen = VGNAMELENMAX;
+    char                    vgroup_class[vclassnamelen];/* vgroup class name */
 
 
     /** open H(DF4) interface **/
@@ -134,7 +136,7 @@ int main() {
         }
         
            /*obtain vgroup name and vgroup class name.*/
-        status = Vgetclass(vgroup_id,vgroup_class);
+        status = Vgetclass(vgroup_id,vgroup_class,&vclassnamelen);
         if(status == FAIL) {
             printf("error in attaching lone vgroup.\n");
             free(ref_vgroup_array);
diff -up h4h5tools-2.2.5/utils/h5toh4/h5toh4.c.orig h4h5tools-2.2.5/utils/h5toh4/h5toh4.c
--- h4h5tools-2.2.5/utils/h5toh4/h5toh4.c.orig	2026-10-02 12:41:18.875986498 -0400
+++ h4h5tools-2.2.5/utils/h5toh4/h5toh4.c	2026-10-02 14:39:09.150985740 -0400
@@ -3005,7 +3005,8 @@ convert_shared_group (hid_t group, int i
     int32 status = SUCCEED;
     char *group_name=NULL;
     char *group_name2=NULL;
-    char vgroup_name[VGNAMELENMAX];
+    size_t vgroupnamelen = VGNAMELENMAX;
+    char vgroup_name[vgroupnamelen];
 
     hfile_id = op_data->hfile_id;
 
@@ -3023,7 +3024,7 @@ convert_shared_group (hid_t group, int i
         group_name2 = group_name2 + sizeof(char);          /* 1 character past last "/" */
     }
 
-    if ((status = Vgetname(op_data->vgroup_id,vgroup_name)) < 0 ) {
+    if ((status = Vgetname(op_data->vgroup_id,vgroup_name,&vgroupnamelen)) < 0 ) {
         fprintf (stderr,"Error: Problem with Vfind().\n");
         DEBUG_PRINT("Error detected in %s() [%s line %d]\n",
                     "convert_shared_group", __FILE__, __LINE__);
