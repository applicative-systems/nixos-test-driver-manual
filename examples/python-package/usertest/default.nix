{
  buildPythonPackage,
  setuptools,
  lib,
  nixos-test-driver,
  ty,
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

  # `nixos-test-driver` is declared as a runtime dep in pyproject.toml so
  # IDEs and developers can resolve `from test_driver.machine import …`.
  # At nix-build time we expose it only via `nativeCheckInputs` (NOT
  # `dependencies`) so it isn't propagated into consumers' closures —
  # otherwise the wrapped test driver, which embeds usertest via
  # `extraPythonPackages`, would see two different `nixos-test-driver`
  # instances and fail `pythonCatchConflictsPhase`. At test runtime the
  # wrapped driver env supplies `test_driver` directly.
  nativeCheckInputs = [
    ty
    nixos-test-driver
  ];

  dontCheckRuntimeDeps = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ty check --error-on-warning
    runHook postCheck
  '';
}
