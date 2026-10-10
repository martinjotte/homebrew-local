class Hdfeos2 < Formula
  desc "HDF-EOS library built on HDF4"
  homepage "https://hdfeos.org/software/library.php"
  url "https://git.earthdata.nasa.gov/projects/DAS/repos/hdfeos/raw/hdf-eos2-3.0-src.tar.gz?at=3128a738021501c821549955f6c78348e5f33850"
  sha256 "3a5564b4d69b541139ff7dfdad948696cf31d9d1a6ea8af290c91a4c0ee37188"
  license "public-domain"
  version "3.0"

  depends_on "hdf4"
  depends_on "jpeg-turbo"
  depends_on "libaec"
  depends_on "gcc"
  depends_on "hdfeos5"

  patch :DATA

  def install
    ENV["FC"] = "gfortran"
    ENV["FCFLAGS"] = "-fallow-argument-mismatch"
    ENV["CPPFLAGS"] = "-Dunix -Df2cFortran -DMACINTEL"
    ENV.append "CFLAGS", "-Wno-error=implicit-function-declaration"
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version
    system "sed", "-i", "-e", "s|gctp ||", "Makefile.in"
    system "sed", "-i", "-e", "s|stddef|stdlib|", "configure"
    system "./configure", *std_configure_args, "--disable-silent-rules", "--with-szlib=#{Formula["libaec"].opt_prefix}", "--enable-shared", "--disable-static"
    system "make", "install", "libhdfeos_la_LIBADD=-lGctp" # if this fails, try separate make/make install steps
    include.install Dir["include/*.h"]
    include.install Dir["include/*.f"]
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test hdfeos2`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
diff -up hdf-eos2-3.0/src/EHapi.c.orig hdf-eos2-3.0/src/EHapi.c
--- hdf-eos2-3.0/src/EHapi.c.orig	2026-10-01 14:34:51.895168762 -0400
+++ hdf-eos2-3.0/src/EHapi.c	2026-10-01 14:36:38.505241326 -0400
@@ -1327,11 +1327,11 @@ EHgetid(int32 fid, int32 vgid, const cha
 		/* ----------------------- */
 		if (*(tags + i) == DFTAG_VG)
 		{
-
+                    size_t bsize = sizeof( name );
 		    /* Get ID and name */
 		    /* --------------- */
 		    id = Vattach(fid, *(refs + i), l_access);
-		    Vgetname(id, name);
+		    Vgetname(id, name, &bsize);
 
 		    /* If name equals desired object name get ID */
 		    /* ----------------------------------------- */
@@ -3512,6 +3512,7 @@ EHinquire(const char *filename, const ch
     /* ------------------------ */
     while (1)
     {
+        size_t bsize = sizeof( tempname );
 	/* Get Vgroup reference number */
 	/* --------------------------- */
 	vgRef = Vgetid(HDFfid, vgRef);
@@ -3525,8 +3526,8 @@ EHinquire(const char *filename, const ch
 	/* Get Vgroup ID, name, and class */
 	/* ------------------------------ */
 	vGrpID = Vattach(HDFfid, vgRef, "r");
-	Vgetname(vGrpID, tempname);
-	Vgetclass(vGrpID, a_class);
+	Vgetname(vGrpID, tempname, &bsize);
+	Vgetclass(vGrpID, a_class, &bsize);
 
 
 	/* If object of desired type (SWATH, POINT, GRID) ... */
@@ -3828,4 +3829,4 @@ FORTRAN_API_FN(INT, EHidinfo, EHIDINFO,
 FORTRAN_API_FN(FLOAT64, EHconvAng, EHCONVANG, ehconvang, FLOAT64, INT)
 FORTRAN_API_FN(INT, EHHEisHE2, EHHEISHE2, ehheishe2, STRING)
 FORTRAN_API_FN(INT, EHgetversion, EHGETVER, ehgetver, INT32, OUT STRING)
-#endif // FORTRAN_API
\ No newline at end of file
+#endif // FORTRAN_API
diff -up hdf-eos2-3.0/src/GDapi.c.orig hdf-eos2-3.0/src/GDapi.c
--- hdf-eos2-3.0/src/GDapi.c.orig	2026-10-01 13:56:24.383071255 -0400
+++ hdf-eos2-3.0/src/GDapi.c	2026-10-01 14:48:26.329527548 -0400
@@ -158,6 +158,10 @@ struct gridRegion *GDXRegion[NGRIDREGN];
 
 #define UTLSTR_MAX_SIZE 512
 
+static size_t buf_max = UTLSTR_MAX_SIZE;
+static size_t buf_siz = 80;
+static size_t buf_vgm = VGNAMELENMAX + 1;
+
 /* Static projection table */
 static struct {
     int32 projcode;
@@ -402,8 +406,8 @@ GDcreate(int32 fid, char *gridname, int3
 		/* Get name and class of Vgroup */
 		/* ---------------------------- */
 		vgid[0] = Vattach(HDFfid, vgRef, "r");
-		Vgetname(vgid[0], name);
-		Vgetclass(vgid[0], a_class);
+		Vgetname(vgid[0], name, &buf_max);
+		Vgetclass(vgid[0], a_class, &buf_max);
 		Vdetach(vgid[0]);
 
 
@@ -656,8 +660,8 @@ GDattach(int32 fid, char *gridname)
 		/* Get name and class of Vgroup */
 		/* ---------------------------- */
 		vgid[0] = Vattach(HDFfid, vgRef, "r");
-		Vgetname(vgid[0], name);
-		Vgetclass(vgid[0], a_class);
+		Vgetname(vgid[0], name, &buf_max);
+		Vgetclass(vgid[0], a_class, &buf_max);
 
 
 		/*
@@ -968,7 +972,7 @@ GDdefdim(int32 gridID, const char *dimna
     /* -------------------------------------- */
     if (status == 0)
     {
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 	tmpdimname = (char *)malloc(((int)strlen(dimname)+1)*sizeof(char));
 	strcpy(tmpdimname, dimname);
 	status = EHinsertmeta(sdInterfaceID, gridname, "g", 0L,
@@ -1125,7 +1129,7 @@ GDdefproj(int32 gridID, int32 projcode,
 
 	/* Insert in structural metadata */
 	/* ----------------------------- */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 	status = EHinsertmeta(sdInterfaceID, gridname, "g", 101L,
 			      utlbuf, NULL);
     }
@@ -1199,7 +1203,7 @@ GDblkSOMoffset(int32 gridID, float32 off
 	/* If SOM projection with projparm[11] non-zero ... */
 	if (projcode == GCTP_SOM && projparm[11] != 0)
 	{
-	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 	    snprintf(utlbuf, sizeof(utlbuf), "%s%s", "_BLKSOM:", gridname);
 
 	    /* Write offset values as attribute */
@@ -1560,7 +1564,7 @@ GDdeforigin(int32 gridID, int32 originco
 	    snprintf(utlbuf, sizeof(utlbuf), "%s%s%s",
 		    "\t\tGridOrigin=", originNames[origincode], "\n");
 
-	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 	    status = EHinsertmeta(sdInterfaceID, gridname, "g", 101L,
 				  utlbuf, NULL);
 	}
@@ -1635,7 +1639,7 @@ GDdefpixreg(int32 gridID, int32 pixregco
 	    snprintf(utlbuf, sizeof(utlbuf), "%s%s%s",
 		    "\t\tPixelRegistration=", pixregNames[pixregcode], "\n");
 
-	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 	    status = EHinsertmeta(sdInterfaceID, gridname, "g", 101L,
 				  utlbuf, NULL);
 	}
@@ -1726,7 +1730,7 @@ GDdiminfo(int32 gridID, const char *dimn
     {
 	/* Get grid name */
 	/* ------------- */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 
 	/* Get pointers to "Dimension" section within SM */
@@ -1849,7 +1853,7 @@ GDgridinfo(int32 gridID, int32 * xdimsiz
     {
 	/* Get grid name */
 	/* ------------- */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 
 	/* Get pointers to grid structure section within SM */
@@ -2043,7 +2047,7 @@ GDprojinfo(int32 gridID, int32 * projcod
     {
 	/* Get grid name */
 	/* ------------- */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 
 	/* Get pointers to grid structure section within SM */
@@ -2281,7 +2285,7 @@ GDorigininfo(int32 gridID, int32 * origi
 
 	/* Get grid name */
 	/* ------------- */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 
 	/* Get pointers to grid structure section within SM */
@@ -2407,7 +2411,7 @@ GDpixreginfo(int32 gridID, int32 * pixre
 	*pixregcode = 0;
 
 	/* Get grid name */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 	/* Get pointers to grid structure section within SM */
 	metabuf = (char *) EHmetagroup(sdInterfaceID, gridname, "g",
@@ -2537,7 +2541,7 @@ GDcompinfo(int32 gridID, const char *fie
     if (status == 0)
     {
 	/* Get grid name */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 	/* Get pointers to "DataField" section within SM */
 	metabuf = (char *) EHmetagroup(sdInterfaceID, gridname, "g",
@@ -2869,7 +2873,7 @@ GDfieldinfo(int32 gridID, const char *fi
     if (status == 0)
     {
 
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 	metabuf = (char *) EHmetagroup(sdInterfaceID, gridname, "g",
 				       "DataField", metaptrs);
@@ -3293,7 +3297,7 @@ GDdeffield(int32 gridID, const char *fie
     {
 	/* Remove offset from grid ID & get gridname */
 	gID = gridID % idOffset;
-	Vgetname(GDXGrid[gID].IDTable, gridname);
+	Vgetname(GDXGrid[gID].IDTable, gridname, &buf_siz);
 
 
 	/* Allocate space for dimension buffer and auxiliary dimension list */
@@ -4292,7 +4296,7 @@ GDsetdimscale(int32 gridID, const char *
 
 	/* Remove offset from grid ID & get gridname */
 	gID = gridID % idOffset;
-	Vgetname(GDXGrid[gID].IDTable, gridname);
+	Vgetname(GDXGrid[gID].IDTable, gridname, &buf_siz);
 
 	/* if dimname is XDim or YDim, data scale will be recalculated
 	 using xdim, ydim, upleft and lowright for the grid*/
@@ -4872,7 +4876,7 @@ GDsetdimstrs(int32 gridID, char *fieldna
 
 	/* Remove offset from grid ID & get gridname */
 	gID = gridID % idOffset;
-	Vgetname(GDXGrid[gID].IDTable, gridname);
+	Vgetname(GDXGrid[gID].IDTable, gridname, &buf_siz);
 
 	/* Loop through all SDSs in grid */
 	/* ------------------------------ */
@@ -5049,7 +5053,7 @@ GDgetdimscale(int32 gridID, char *fieldn
 
 	/* Remove offset from grid ID & get gridname */
 	gID = gridID % idOffset;
-	Vgetname(GDXGrid[gID].IDTable, gridname);
+	Vgetname(GDXGrid[gID].IDTable, gridname, &buf_siz);
 
 	/* Loop through all SDSs in grid */
 	/* ------------------------------ */
@@ -5249,7 +5253,7 @@ GDgetdimstrs(int32 gridID, char *fieldna
 
 	/* Remove offset from grid ID & get gridname */
 	gID = gridID % idOffset;
-	Vgetname(GDXGrid[gID].IDTable, gridname);
+	Vgetname(GDXGrid[gID].IDTable, gridname, &buf_siz);
 
 	/* Loop through all SDSs in grid */
 	/* ------------------------------ */
@@ -5395,7 +5399,7 @@ GDwritefieldmeta(int32 gridID, char *fie
     {
 	snprintf(utlbuf, sizeof(utlbuf), "%s%s%s", fieldname, ":", dimlist);
 
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 	status = EHinsertmeta(sdInterfaceID, gridname, "g", 4L,
 			      utlbuf, &numbertype);
     }
@@ -5631,7 +5635,7 @@ GDSDfldsrch(int32 gridID, int32 sdInterf
 	    {
 		/* Get grid name */
 		/* ------------- */
-		Vgetname(GDXGrid[gID].IDTable, gridname);
+		Vgetname(GDXGrid[gID].IDTable, gridname, &buf_siz);
 
 
 		/* Get pointers to "MergedFields" section within SM */
@@ -6742,7 +6746,7 @@ GDinqdims(int32 gridID, char *dimnames,
 	{
 	    /* Get grid name */
 	    /* ------------- */
-	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 
 	    /* Get pointers to "Dimension" section within SM */
@@ -6899,7 +6903,7 @@ GDinqfields(int32 gridID, char *fieldlis
 	{
 	    /* Get grid name */
 	    /* ------------- */
-	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	    Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 
 	    /* Get pointers to "DataField" section within SM */
@@ -7107,7 +7111,7 @@ GDnentries(int32 gridID, int32 entrycode
     if (status == 0)
     {
 	/* Get grid name */
-	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+	Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &buf_siz);
 
 	/* Zero out string buffer size */
 	*strbufsize = 0;
@@ -7559,7 +7563,7 @@ GDdetach(int32 gridID)
     if (status == 0)
     {
 	gID = gridID % idOffset;
-	Vgetname(GDXGrid[gID].IDTable, gridname);
+	Vgetname(GDXGrid[gID].IDTable, gridname, &buf_vgm);
 
 	/* SDS combined fields */
 	/* ------------------- */
@@ -10568,7 +10572,8 @@ GDdefboxregion(int32 gridID, float64 cor
         /* If SOM projection with projparm[11] non-zero ... */
         if (projcode == GCTP_SOM && projparm[11] != 0)
         {
-            Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname);
+            size_t bufsiz = sizeof( gridname );
+            Vgetname(GDXGrid[gridID % idOffset].IDTable, gridname, &bufsiz);
             snprintf(utlbuf, sizeof(utlbuf), "%s%s", "_BLKSOM:", gridname);
 	    status = GDreadattr(gridID, utlbuf, offset);
 
diff -up hdf-eos2-3.0/src/PTapi.c.orig hdf-eos2-3.0/src/PTapi.c
--- hdf-eos2-3.0/src/PTapi.c.orig	2026-10-01 13:56:14.896786263 -0400
+++ hdf-eos2-3.0/src/PTapi.c	2026-10-01 14:48:53.121744815 -0400
@@ -29,6 +29,9 @@ Nov 15, 2005 Tom Roegner  NCR 44092 - Ad
 #define	PTIDOFFSET 2097152
 #define UTLSTR_MAX_SIZE 512
 
+static size_t buf_max = UTLSTR_MAX_SIZE;
+static size_t buf_siz = 80;
+
 #define NPOINT 64
 struct pointStructure
 {
@@ -223,8 +226,8 @@ PTcreate(int32 fid, char *pointname)
 		/* Get name and class of Vgroup */
 		/* ---------------------------- */
 		vgid[0] = Vattach(HDFfid, vgRef, "r");
-		Vgetname(vgid[0], name);
-		Vgetclass(vgid[0], a_class);
+		Vgetname(vgid[0], name, &buf_max);
+		Vgetclass(vgid[0], a_class, &buf_max);
 		Vdetach(vgid[0]);
 
 
@@ -1182,8 +1185,8 @@ PTattach(int32 fid, char *pointname)
 		/* Get name and class of Vgroup */
 		/* ---------------------------- */
 		vgid[0] = Vattach(HDFfid, vgRef, acsCode);
-		Vgetname(vgid[0], name);
-		Vgetclass(vgid[0], a_class);
+		Vgetname(vgid[0], name, &buf_max);
+		Vgetclass(vgid[0], a_class, &buf_max);
 
 
 		/* If point found get vgroup & vdata ids */
@@ -1640,7 +1643,7 @@ PTdeflevel(int32 pointID, char *levelnam
 	{
 	    /* Insert Point Level metadata */
 	    /* --------------------------- */
-	    Vgetname(PTXPoint[pointID % idOffset].IDTable, pointname);
+	    Vgetname(PTXPoint[pointID % idOffset].IDTable, pointname, &buf_siz);
 	    status = EHinsertmeta(sdInterfaceID, pointname, "p", 10L,
 				  levelname, &dum);
 
@@ -1870,7 +1873,7 @@ PTdeflinkage(int32 pointID, char *parent
 	    /* ------------------------------------------ */
 	    snprintf(utlbuf, sizeof(utlbuf), "%s%s%s%s%s", parent, "/", child, ":", linkfield);
 
-	    Vgetname(PTXPoint[pointID % idOffset].IDTable, pointname);
+	    Vgetname(PTXPoint[pointID % idOffset].IDTable, pointname, &buf_siz);
 	    status = EHinsertmeta(sdInterfaceID, pointname, "p", 12L,
 				  utlbuf, &dum);
 	}
@@ -1935,7 +1938,7 @@ PTlinkinfo(int32 pointID, int32 sdInterf
 
     /* Get point name */
     /* -------------- */
-    Vgetname(PTXPoint[pID].IDTable, name1);
+    Vgetname(PTXPoint[pID].IDTable, name1, &buf_siz);
 
 
     /* Get level link structural metadata */
@@ -6169,4 +6172,4 @@ FORTRAN_API_FN(INT, PTdetach, PTDETACH,
 FORTRAN_API_FN(INT, PTclose, PTCLOSE, ptclose, INT32)
 
 
-#endif // FORTRAN_API
\ No newline at end of file
+#endif // FORTRAN_API
diff -up hdf-eos2-3.0/src/SWapi.c.orig hdf-eos2-3.0/src/SWapi.c
--- hdf-eos2-3.0/src/SWapi.c.orig	2026-10-01 13:56:08.647641736 -0400
+++ hdf-eos2-3.0/src/SWapi.c	2026-10-01 14:49:06.682144035 -0400
@@ -161,6 +161,10 @@ struct swathRegion *SWXRegion[NSWATHREGN
 
 #define UTLSTR_MAX_SIZE 512
 
+static size_t buf_max = UTLSTR_MAX_SIZE;
+static size_t buf_siz = 80;
+static size_t buf_vgm = VGNAMELENMAX + 1;
+
 /* Swath Prototypes (internal routines) */
 intn SWchkswid(int32, const char *, int32 *, int32 *, int32 *);
 int32 SWimapinfo(int32, char *, char *, int32 []);
@@ -347,8 +351,8 @@ SWcreate(int32 fid, const char *swathnam
 		/* Get name and class of Vgroup */
 		/* ---------------------------- */
 		vgid[0] = Vattach(HDFfid, vgRef, "r");
-		Vgetname(vgid[0], name);
-		Vgetclass(vgid[0], a_class);
+		Vgetname(vgid[0], name, &buf_max);
+		Vgetclass(vgid[0], a_class, &buf_max);
 		Vdetach(vgid[0]);
 
 		/* If SWATH then increment # swath counter */
@@ -586,8 +590,8 @@ SWattach(int32 fid, const char *swathnam
 		/* Get name and class of Vgroup */
 		/* ---------------------------- */
 		vgid[0] = Vattach(HDFfid, vgRef, "r");
-		Vgetname(vgid[0], name);
-		Vgetclass(vgid[0], a_class);
+		Vgetname(vgid[0], name, &buf_max);
+		Vgetclass(vgid[0], a_class, &buf_max);
 
 
 		/*
@@ -954,7 +958,7 @@ SWdefdim(int32 swathID, const char *dimn
     /* -------------------------------------- */
     if (status == 0)
     {
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 	tmpdimname = (char *)malloc(((int)strlen(dimname)+1)*sizeof(char));
 	strcpy(tmpdimname, dimname);
 	status = EHinsertmeta(sdInterfaceID, swathname, "s", 0L,
@@ -1033,7 +1037,7 @@ SWdiminfo(int32 swathID, const char *dim
     if (status == 0)
     {
 	/* Get swath name */
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	/* Get pointers to "Dimension" section within SM */
 	metabuf = (char *) EHmetagroup(sdInterfaceID, swathname, "s",
@@ -1350,7 +1354,7 @@ SWsetdimscale(int32 swathID, const char
 
 	/* Remove offset from swath ID & get swathname */
 	gID = swathID % idOffset;
-	Vgetname(SWXSwath[gID].IDTable, swathname);
+	Vgetname(SWXSwath[gID].IDTable, swathname, &buf_siz);
 
 	data_buff = data;
 
@@ -1679,7 +1683,7 @@ SWsetdimstrs(int32 swathID, const char *
 
 	/* Remove offset from swath ID & get swathname */
 	gID = swathID % idOffset;
-	Vgetname(SWXSwath[gID].IDTable, swathname);
+	Vgetname(SWXSwath[gID].IDTable, swathname, &buf_siz);
 
 	/* Loop through all SDSs in swath */
 	/* ------------------------------ */
@@ -1859,7 +1863,7 @@ SWgetdimscale(int32 swathID, const char
 
 	/* Remove offset from swath ID & get swathname */
 	gID = swathID % idOffset;
-	Vgetname(SWXSwath[gID].IDTable, swathname);
+	Vgetname(SWXSwath[gID].IDTable, swathname, &buf_siz);
 
 	/* Loop through all SDSs in swath */
 	/* ------------------------------ */
@@ -2059,7 +2063,7 @@ SWgetdimstrs(int32 swathID, const char *
 
 	/* Remove offset from swath ID & get swathname */
 	gID = swathID % idOffset;
-	Vgetname(SWXSwath[gID].IDTable, swathname);
+	Vgetname(SWXSwath[gID].IDTable, swathname, &buf_siz);
 
 	/* Loop through all SDSs in swath */
 	/* ------------------------------ */
@@ -2220,7 +2224,7 @@ SWmapinfo(int32 swathID, const char *geo
     if (status == 0)
     {
 	/* Get swath name */
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	/* Get pointers to "DimensionMap" section within SM */
 	metabuf = (char *) EHmetagroup(sdInterfaceID, swathname, "s",
@@ -2443,7 +2447,7 @@ SWcompinfo(int32 swathID, const char *fi
     if (status == 0)
     {
 	/* Get swath name */
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	/* Get pointers to "DataField" section within SM */
 	metabuf = (char *) EHmetagroup(sdInterfaceID, swathname, "s",
@@ -2792,7 +2796,7 @@ SWfinfo(int32 swathID, const char *field
       }
 
     /* Get swath name */
-    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
     /* Get pointers to appropriate "Field" section within SM */
     if (strcmp(fieldtype, "Geolocation Fields") == 0)
@@ -3323,7 +3327,7 @@ SWdefdimmap(int32 swathID, const char *g
 	  metadata[0] = offset;
 	  metadata[1] = increment;
 
-	  Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	  Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 	  status = EHinsertmeta(sdInterfaceID, swathname, "s", 1L,
 				mapname, metadata);
 	}
@@ -3457,7 +3461,7 @@ SWdefidxmap(int32 swathID, const char *g
 
 	    /* Write to Structural Metadata */
 	    snprintf(mapname, sizeof(mapname), "%s%s%s", geodim, "/", datadim);
-	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 	    status = EHinsertmeta(sdInterfaceID, swathname, "s", 2L,
 				  mapname, &dum);
 
@@ -3706,7 +3710,7 @@ SWdefinefield(int32 swathID, const char
     {
 	/* Remove offset from swath ID & get swathname */
 	sID = swathID % idOffset;
-	Vgetname(swVgrpID, swathname);
+	Vgetname(swVgrpID, swathname, &buf_siz);
 
 	/* Allocate space for dimbuf, copy dimlist into it, & append comma */
 	dimbuf = (char *) calloc(strlen(dimlist) + 64, 1);
@@ -4482,7 +4486,7 @@ SWwritegeometa(int32 swathID, const char
 	/* ------------------------------ */
 	snprintf(utlbuf, sizeof(utlbuf), "%s%s%s", fieldname, ":", dimlist);
 
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 	status = EHinsertmeta(sdInterfaceID, swathname, "s", 3L,
 			      utlbuf, &numbertype);
     }
@@ -4547,7 +4551,7 @@ SWwritedatameta(int32 swathID, const cha
 	/* ------------------------------ */
 	snprintf(utlbuf, sizeof(utlbuf), "%s%s%s", fieldname, ":", dimlist);
 
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 	status = EHinsertmeta(sdInterfaceID, swathname, "s", 4L,
 			      utlbuf, &numbertype);
     }
@@ -5164,7 +5168,7 @@ SWinqdims(int32 swathID, char *dimnames,
 	if (dimnames != NULL || dims != NULL)
 	{
 	    /* Get swath name */
-	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	    /* Get pointers to "Dimension" section within SM */
 	    metabuf = (char *) EHmetagroup(sdInterfaceID, swathname, "s",
@@ -5343,7 +5347,7 @@ SWinqmaps(int32 swathID, char *dimmaps,
 	{
 
 	    /* Get swath name */
-	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	    /* Get pointers to "DimensionMap" section within SM */
 	    metabuf = (char *) EHmetagroup(sdInterfaceID, swathname, "s",
@@ -5509,7 +5513,7 @@ SWinqidxmaps(int32 swathID, char *idxmap
 	if (idxmaps != NULL || idxsizes != NULL)
 	{
 	    /* Get swath name */
-	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	    /* Get pointers to "IndexDimensionMap" section within SM */
 	    metabuf = (char *) EHmetagroup(sdInterfaceID, swathname, "s",
@@ -5683,7 +5687,7 @@ SWinqfields(int32 swathID, const char *f
 	if (fieldlist != NULL || rank != NULL || numbertype != NULL)
 	{
 	    /* Get swath name */
-	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	    Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	    /* Get pointers to "GeoField" or "DataField" section within SM */
 	    if (strcmp(fieldtype, "Geolocation Fields") == 0)
@@ -6002,7 +6006,7 @@ SWnentries(int32 swathID, int32 entrycod
     if (status == 0)
     {
 	/* Get swath name */
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	/* Zero out string buffer size */
 	*strbufsize = 0;
@@ -6392,7 +6396,7 @@ SWSDfldsrch(int32 swathID, int32 sdInter
 	    {
 		/* Get swath name */
 		/* -------------- */
-		Vgetname(SWXSwath[sID].IDTable, swathname);
+		Vgetname(SWXSwath[sID].IDTable, swathname, &buf_siz);
 
 
 		/* Get pointers to "MergedFields" section within SM */
@@ -11894,7 +11898,7 @@ SWdefscanregion(int32 swathID, const cha
             range[1] = range[1] * detect_cnt - 1;
          }
 
-         Vgetname(SWXSwath[0].IDTable, swathname);
+         Vgetname(SWXSwath[0].IDTable, swathname, &buf_siz);
          band81 = strstr(swathname, "B81");
          if (band81 != (char *)NULL)
             band81flag = 1;
@@ -12389,7 +12393,7 @@ SWdetach(int32 swathID)
 	/* Subtract off swath ID offset and get swath name */
 	/* ----------------------------------------------- */
 	sID = swathID % idOffset;
-	Vgetname(SWXSwath[sID].IDTable, swathname);
+	Vgetname(SWXSwath[sID].IDTable, swathname, &buf_vgm);
 
 
 	/* Create 1D "orphaned" fields */
@@ -13811,7 +13815,7 @@ SWgeomapinfo(int32 swathID, const char *
     if (status == 0)
     {
 	/* Get swath name */
-	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname);
+	Vgetname(SWXSwath[swathID % idOffset].IDTable, swathname, &buf_siz);
 
 	/* Get pointers to "DimensionMap" section within SM */
 	metabufr = (char *) EHmetagroup(sdInterfaceID, swathname, "s",
