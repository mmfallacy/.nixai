# Skill Modules

Shared skill repos live here. Agents load only the skills symlinked into their own `skills/` directory.

```text
pi/default/skill_modules/<module>/     # repo/submodule, optionally sparse
pi/<agent>/skills/<skill>/             # symlink to one skill directory
```

Do this instead of adding a whole module path to `settings.json`. If a module later becomes a full checkout, agents still load only the symlinked skills.

## Add a module

```bash
git submodule add <repo-url> pi/default/skill_modules/<module>
```

Sparse checkout only the selected skills and their dependencies:

```bash
git -C pi/default/skill_modules/<module> sparse-checkout init --no-cone
git -C pi/default/skill_modules/<module> sparse-checkout set \
  path/to/skill \
  path/to/dependency-skill
```

## Expose a skill to an agent

```bash
mkdir -p pi/<agent>/skills
ln -s ../../default/skill_modules/<module>/<path-to-skill> \
  pi/<agent>/skills/<skill-name>
```

The target must resolve to a directory containing `SKILL.md`.

Verify Pi sees the skills:

```bash
pi-check-skills pi/<agent>
```

## Current setup

`mattpocock` is sparse-checked out with:

```text
skills/engineering/grill-with-docs
skills/engineering/domain-modeling
skills/productivity/grilling
```

Caelion exposes:

```text
pi/caelion/skills/grill-with-docs -> ../../default/skill_modules/mattpocock/skills/engineering/grill-with-docs
pi/caelion/skills/domain-modeling -> ../../default/skill_modules/mattpocock/skills/engineering/domain-modeling
pi/caelion/skills/grilling -> ../../default/skill_modules/mattpocock/skills/productivity/grilling
```
