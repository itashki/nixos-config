# PrismML llama.cpp fork (PTQ1_0 support) built with CUDA on top of nixpkgs' llama-cpp.
{ pkgs }:
(pkgs.llama-cpp.override { cudaSupport = true; }).overrideAttrs (old: {
  pname = "llama-cpp-prism";
  doCheck = false; # fork's test-dfly-fusion does not link with GGML_BACKEND_DL
  version = "prism-b12178-03ec600";
  npmDepsHash = "sha256-XLtEZsSFdk+2SyfXzBp8HQ2e27PQPpDCn1YjePU1/9w=";
  src = pkgs.fetchFromGitHub {
    owner = "PrismML-Eng";
    repo = "llama.cpp";
    tag = "prism-b12178-03ec600";
    hash = "sha256-cozf+UWmDlTosv49+94VJoDQDaZwC3ci8CklVMdLTiU=";
  };
})
