function crython() {
  if [ -f requirements.txt ]; then
    test -d .venv || uv venv
    source .venv/bin/activate
    test -f requirements.txt && uv pip install -r requirements.txt
  fi
  uv run python "$@"
}