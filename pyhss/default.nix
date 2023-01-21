{ lib, buildPythonPackage, fetchFromGitHub
, redis, construct, pycryptodome, pycryptodomex
, pyyaml, pysctp, jinja2, sqlalchemy, flask
, grequests, mysqlclient, prometheus-client
, systemd, sqlalchemy-utils }:


buildPythonPackage rec {
  pname = "pyhss";
  version = "unstable-2023-01-17";

  src = fetchFromGitHub {
    owner = "nickvsnetworking";
    repo = "pyhss";
    rev = "ae2f264c515a5dd4dfcd4dbae58a46f6fa3c9ac0";
    sha256 = "sha256-O4FrZdWT1Pr5RqRbChb+jHkA45xXpwnihFpgP2+VL+c=";
  };

  postPatch = ''
    cat > setup.py <<EOF
    setuptools.setup(
        name = "${pname}",
        version = "${version}",
        packages = setuptools.find_packages(),
        scripts = [ 'hss.py' ]
    )
    EOF
  '';

  propagatedBuildInputs = [
    systemd
    redis
    construct
    pycryptodome
    pycryptodomex
    pyyaml
    pysctp
    jinja2
    sqlalchemy
    sqlalchemy-utils
    flask
    grequests
    mysqlclient
    prometheus-client
  ];

  doCheck = false;

  postInstall = ''
    mkdir -p $out/bin

    sed -i '1s:^:#!/usr/bin/env nix-shell\n:' $out/bin/hss.py
    sed -i "2s:^:#!nix-shell -i python -p $out\n:" $out/bin/hss.py
  '';

  meta = with lib; {
    description = "Diameter Home Subscriber Server";
    homepage = "https://github.com/nickvsnetworking/pyhss";
  };
}


