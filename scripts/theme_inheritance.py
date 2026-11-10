from __future__ import annotations


def effective_theme_properties(
    variants: dict[str, dict[str, str]],
) -> dict[str, dict[str, str]]:
    """Resolve inherited Theme properties, omitting each variant's ``base_type``."""
    memo: dict[str, dict[str, str]] = {}
    visiting: set[str] = set()

    def resolve(name: str) -> dict[str, str]:
        if name in memo:
            return memo[name]
        if name in visiting:
            return {}
        visiting.add(name)
        props = variants.get(name, {})
        base = props.get("base_type", "").strip('&"')
        effective = dict(resolve(base)) if base in variants else {}
        effective.update({key: value for key, value in props.items() if key != "base_type"})
        visiting.discard(name)
        memo[name] = effective
        return effective

    return {name: resolve(name) for name in variants}
