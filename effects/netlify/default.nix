{ lib
, mkEffect
, netlify-cli
}:

args@{ content
, secretName ? throw ''effects.netlify: You must provide `secretName`, the name of the secret which holds the "${secretField}" field.''
, secretField ? "token"
, siteId
, productionDeployment ? false
, secretsMap ? {}
, ...
}:
let
  deployArgs = [
    "--dir=${content}"
    "--site=${siteId}"
  ] ++ lib.optionals productionDeployment [ "--prod" ];
in
mkEffect (args // {
  inputs = [ netlify-cli ];
  secretsMap = { "netlify" = secretName; } // secretsMap;
  effectScript = ''
    netlify deploy \
      --auth=$(readSecretString netlify .${secretField}) \
      ${lib.escapeShellArgs deployArgs}
  '';
})
