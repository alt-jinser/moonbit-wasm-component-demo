{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  openssl,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "wac";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "wac";
    rev = "v${version}";
    hash = "sha256-noBVAhoHXl3FI6ZlnmCwpnqu7pub6FCtuY+026vdlYo=";
  };

  cargoHash = "sha256-ERS9i0S7uJ/Ul2218bPAw6GdDZNoBKiRIvZ+dVNkuE4=";

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  meta = {
    description = "WebAssembly Composition (WAC) tooling";
    homepage = "https://github.com/bytecodealliance/wac";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wac";
  };
}
