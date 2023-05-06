{ lib, buildPythonPackage, fetchFromGitHub
, redis, construct, pycryptodome, pycryptodomex
, pyyaml, pysctp, jinja2, sqlalchemy, flask
, grequests, mysqlclient, prometheus-client
, systemd, sqlalchemy-utils, flask-restx
, alchemyjsonschema }:


buildPythonPackage rec {
  pname = "pyhss";
  version = "2023.04.27";

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
        package_dir = { "": "lib" },
        scripts = [ 'hss.py' ]
    )
    EOF

    # need to be in the same package
    mv diameter.py lib/
    mv database.py lib/
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
    alchemyjsonschema
    flask
    flask-restx
    grequests
    mysqlclient
    prometheus-client
  ];

  doCheck = false;

  postInstall = ''
    mkdir -p $out/bin $out/share/pyhss

    sed -i '1s:^:#!/usr/bin/python3\n:' $out/bin/hss.py

    cp PyHSS_API.py $out/bin
    cat > $out/bin/PyHSS_API <<EOF
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p $out
    ${flask}/bin/flask -A $out/bin/PyHSS_API.py run --host=127.0.0.1 --port 8080
    EOF
    chmod +x $out/bin/PyHSS_API

    cp default_ifc.xml $out/share/pyhss
    cp default_sh_user_data.xml $out/share/pyhss
  '';

  meta = with lib; {
    description = "Diameter Home Subscriber Server";
    homepage = "https://github.com/nickvsnetworking/pyhss";
  };
}


