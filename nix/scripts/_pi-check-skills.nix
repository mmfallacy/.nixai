{
  writeShellApplication,
  jq,
  pi-coding-agent,
}:
writeShellApplication {
  name = "pi-check-skills";
  runtimeInputs = [
    jq
    pi-coding-agent
  ];
  text = ''
    if [ "$#" -ne 1 ]; then
      echo "usage: $0 <coding-agent-dir>" >&2
      exit 1
    fi

    export PI_CODING_AGENT_DIR="$1"

    printf '%s\n' '{"type":"get_commands"}' |
      pi --mode rpc --no-session --offline \
         --no-tools --no-extensions --no-themes \
         --no-context-files --no-prompt-templates |
      jq -r '
        .data.commands[]
        | select(.source == "skill")
        | .name
        | sub("^skill:"; "")
      '
  '';
}
