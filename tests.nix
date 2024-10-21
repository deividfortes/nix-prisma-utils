{ nixpkgs, prisma-factory }:
with nixpkgs;
let
  hashesBySystem = {
    x86_64-linux = {
      prisma-fmt-hash = "sha256-7bSbYw9QRrunI5E6Nbzp+MCh57J0HPSq8doHfjQnato=";
      query-engine-hash = "sha256-6ILWB6ZmK4ac6SgAtqCkZKHbQANmcqpWO92U8CfkFzw=";
      libquery-engine-hash = "sha256-n9IimBruqpDJStlEbCJ8nsk8L9dDW95ug+gz9DHS1Lc=";
      schema-engine-hash = "sha256-j38xSXOBwAjIdIpbSTkFJijby6OGWCoAx+xZyms/34Q=";
    };
    aarch64-linux = {
      prisma-fmt-hash = "sha256-gqbgN9pZxzZEi6cBicUfH7qqlXWM+z28sGVuW/wKHb8=";
      query-engine-hash = "sha256-q1HVbRtWhF3J5ScETrwvGisS8fXA27nryTvqFb+XIuo=";
      libquery-engine-hash = "sha256-oalG9QKuxURtdgs5DgJZZtyWMz3ZpywHlov+d1ct2vA=";
      schema-engine-hash = "sha256-5bp8iiq6kc9c37G8dNKVHKWJHvaxFaetR4DOR/0/eWs=";
    };
  };
  test-npm =
    let
      prisma =
        (prisma-factory ({ inherit nixpkgs; } // hashesBySystem.${nixpkgs.system})).fromNpmLock
          ./npm/package-lock.json;
    in
    writeShellApplication {
      name = "test-npm";
      text = ''
        echo "testing npm"
        ${prisma.shellHook}
        cd npm
        npm ci
        ./node_modules/.bin/prisma generate
      '';
    };
  test-pnpm =
    let
      prisma =
        (prisma-factory ({ inherit nixpkgs; } // hashesBySystem.${nixpkgs.system})).fromPnpmLock
          ./pnpm/pnpm-lock.yaml;
    in
    writeShellApplication {
      name = "test-pnpm";
      text = ''
        echo "testing pnpm"
        ${prisma.shellHook}
        cd pnpm
        pnpm install
        ./node_modules/.bin/prisma generate
      '';
    };
  test-all = writeShellApplication {
    name = "test";
    runtimeInputs = [
      test-pnpm
      test-npm
    ];
    text = ''
      test-npm
      test-pnpm
    '';
  };
in
{
  inherit test-npm test-pnpm test-all;
}
