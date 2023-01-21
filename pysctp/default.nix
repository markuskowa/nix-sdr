{ lib, buildPythonPackage, fetchPypi
, lksctp-tools }:

buildPythonPackage rec {
  pname = "pysctp";
  version = "0.7.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-3DnOcZiKJk9U2d4RSpx8w3MwCt4i03OpDJ8Jw4xqf0A=";
  };

  buildInputs = [ lksctp-tools ];

  # attempts to setup a network connection
  doCheck = false;

  meta = with lib; {
    description = "SCTP bindings for Python";
    homepage = "https://github.com/p1sec/pysctp";
    license = licenses.lgpl21Plus;
  };
}
