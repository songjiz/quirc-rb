require "mkmf"
require "fileutils"

src_dir = File.expand_path(File.join(__dir__, "../src"))
lib_dir = "#{src_dir}/lib"
inc_dir = "#{src_dir}/lib"

Dir.chdir(src_dir) do
  system("make clean")
  system("make libquirc.a")
  FileUtils.mv(Dir.glob("*.a"), "lib")
end

$libs     << " -lquirc"
$CPPFLAGS << " -I#{inc_dir}"
$LDFLAGS  << " -L#{lib_dir}"

have_header("quirc.h")
have_library("quirc")
have_func("quirc_version")
have_func("quirc_new")
have_func("quirc_begin")
have_func("quirc_end")
have_func("quirc_destroy")
have_func("quirc_resize")
have_func("quirc_count")

create_makefile("quirc/quirc")
