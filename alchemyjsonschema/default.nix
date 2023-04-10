{ lib, buildPythonPackage, fetchFromGitHub
, sqlalchemy
, jsonschema
, strict-rfc3339
, isodate
, pytz
, magicalimport
, dictknife
, webob
}:

buildPythonPackage rec {
  pname = "alchemyjsonschema";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "podhmo";
    repo = "alchemyjsonschema";
    rev = version;
    sha256 = "sha256-KawbjC4CsNmPLWzATHh+3LAR/Y7O3wBo01N8dsXm474=";
  };

  # doCheck = false;
  propagatedBuildInputs = [
    sqlalchemy
    jsonschema
    strict-rfc3339
    isodate
    pytz
    magicalimport
    dictknife
    webob
  ];

  doCheck = false;
}
