{ stdenv, fetchFromGitHub, pkgconfig, cmake, libusb1 } :
let
  version = "20190212";

in stdenv.mkDerivation {
  name = "rtl-sdr-kerberos-${version}";

  src = fetchFromGitHub {
    owner = "rtlsdrblog";
    repo = "rtl-sdr-kerberos";
    rev = "89767a644904f90342a67b0efb913660f79e90b1";
    sha256 = "1vw553gnc6afvdy4p19ja4kw0lgzjmpmr7vhwycvryzxavkn9klb";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ cmake libusb1 ];

  # TODO: get these fixes upstream:
  # * Building with -DINSTALL_UDEV_RULES=ON tries to install udev rules to
  #   /etc/udev/rules.d/, and there is no option to install elsewhere. So install
  #   rules manually.
  # * Propagate libusb-1.0 dependency in pkg-config file.
  postInstall = stdenv.lib.optionalString stdenv.isLinux ''
    mkdir -p "$out/etc/udev/rules.d/"
    cp ../rtl-sdr.rules "$out/etc/udev/rules.d/99-rtl-sdr.rules"

    pcfile="$out"/lib/pkgconfig/librtlsdr.pc
    grep -q "Requires:" "$pcfile" && { echo "Upstream has added 'Requires:' in $(basename "$pcfile"); update nix expression."; exit 1; }
    echo "Requires: libusb-1.0" >> "$pcfile"
  '';

  meta = with stdenv.lib; {
    description = "Drivers to the RTL-SDR based kerberos SDR";
    homepage = https://www.rtl-sdr.com/ksdr/;
    license = licenses.gpl2;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

