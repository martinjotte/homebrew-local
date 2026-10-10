class NetcdfFortranMpi < Formula
  desc "Fortran libraries and utilities for NetCDF"
  homepage "https://www.unidata.ucar.edu/software/netcdf/"
  url "https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.4.tar.gz"
  sha256 "fc8df99e78cd2aa5ea7b312bce5307b1bea73a118d4860b3b4358971ec376c54"
  license "NetCDF"

  depends_on "cmake" => :build
  depends_on "hdf5-mpi" => build
  depends_on "gcc" # for gfortran
  depends_on "netcdf-mpi"
  depends_on "open-mpi"

  keg_only "conflicts with netcdf"

  def install
    ENV["CC"]  = formula_opt_bin("open-mpi")/"mpicc"
    ENV["FC"]  = formula_opt_bin("open-mpi")/"mpif90"
    ENV["FFLAGS"] = "-O3 -march=native"

    args = std_cmake_args + %w[DENABLE_TESTS=OFF -DENABLE_DOXYGEN=OFF]

    system "cmake", "-S", ".", "-B", "build_shared", *args, "-DBUILD_SHARED_LIBS=ON"
    system "cmake", "--build", "build_shared"
    system "cmake", "--install", "build_shared"
  end

  test do
    (testpath/"test.f90").write <<~FORTRAN
      program test
        use netcdf
        integer :: ncid, varid, dimids(2)
        integer :: dat(2,2) = reshape([1, 2, 3, 4], [2, 2])
        call check( nf90_create("test.nc", NF90_CLOBBER, ncid) )
        call check( nf90_def_dim(ncid, "x", 2, dimids(2)) )
        call check( nf90_def_dim(ncid, "y", 2, dimids(1)) )
        call check( nf90_def_var(ncid, "data", NF90_INT, dimids, varid) )
        call check( nf90_enddef(ncid) )
        call check( nf90_put_var(ncid, varid, dat) )
        call check( nf90_close(ncid) )
      contains
        subroutine check(status)
          integer, intent(in) :: status
          if (status /= nf90_noerr) call abort
        end subroutine check
      end program test
    FORTRAN
    system "gfortran", "test.f90", "-L#{lib}", "-I#{include}", "-lnetcdff",
                       "-o", "testf"
    system "./testf"
  end
end
