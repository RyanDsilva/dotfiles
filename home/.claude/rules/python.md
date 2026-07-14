# Python conventions

- Use `uv` for envs/deps (`uv add`, `uv run`) - not pip/poetry/pyenv directly.
- Format and lint with Ruff (`ruff format`, `ruff check --fix`). Line length 88.
- Full type hints on public functions; check with basedpyright. Prefer `X | None` over `Optional[X]`.
- Tests with pytest; parametrize edge cases; use fixtures over setup boilerplate.
- Prefer dataclasses/pydantic over dicts for structured data. Prefer pathlib over os.path.
- Raise specific exceptions; never bare `except:`. Use context managers for resources.
