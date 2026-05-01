{
  buildPythonPackage,
  setuptools,
  lib
}:

buildPythonPackage {
  pname = "usertest";
  version = "0.1.0";
  pyproject = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./pyproject.toml
      ./src
    ];
  };

  build-system = [
    setuptools
  ];

  doCheck = false;
}
