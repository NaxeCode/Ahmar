# AGENTS.md

Ahmar is a paused top-down action combat prototype (Hyper Light Drifter style) in Haxe + HaxeFlixel + `flixel-addons`.
- Entry: `source/Main.hx` boots `PrototypeState` (one 5760x3240 arena). Combat lives in `Player.hx`, `Enemy.hx`, `Entity.hx`. Shared references live in the static `Reg` class.
- Build/run: `lime test html5` (or `linux` / `windows` / `mac` / `hl`). Builds go to `export/`. No automated tests; verify by playing the arena.
- Assets are referenced through the `AssetPaths` build macro (`FlxAssets.buildFileReferences("assets", true)`), so `AssetPaths.floor__png` maps to `assets/images/DinnerRoom/floor.png`.

## Code Review Rules

### Always flag (P0/P1)
- Combat state flags that can stick. For example, `Player.goDash()` sets `playerDashing = true` before the stamina/no-direction early return, and `PrototypeState.handleCollisions()` skips player/enemy collision while it is true. Flag any new flag (`playerDashing`, `inAttackState`, `knockedBack`, `attackInProgress`, `comboFirstTime`) that is set on a path with no guaranteed reset. Safe path: set the flag only after the early-return checks pass, and clear it in the same timer/callback that ends the action.
- `new FlxTimer()` or other allocations created every frame from `update()` code. `Enemy.telegraphAttack()` runs every frame in the Attack state, and `attackInProgress` only turns true inside the 0.5 s timer callback, so a guard that is set late stacks many timers. Safe path: set the guard before starting the timer, or reuse one stored `FlxTimer` with `reset()` the way `attackStateTimer` does.
- Timer/tween callbacks that touch an entity after it may have been `kill()`ed or the state switched (`enemy.knockedBack = false` closures in `PrototypeState`, dash hitbox timers). Safe path: check `alive`/`exists` in the callback, or cancel timers in `destroy()`.
- Static state that outlives a state instance: `Reg.player`, `Reg.playerDashHitbox`, `Reg.playerAtkHitbox`, `Reg.playerPos`, `PrototypeState.comboFirstTime`, and especially the static `Player.actions` (`FlxActionManager`). Each new `Player` calls `actions.addActions(...)` on the same manager, so restarting the state piles up duplicate actions. Safe path: reset or reassign these in `create()`, and remove the player's actions in `destroy()`.
- Hitbox objects (`Reg.playerAtkHitbox`, `Reg.playerDashHitbox`) that are resized or `reset()` without a matching `kill()` timer, or that are added to a state other than the current one (`FlxG.state.add` inside `Player`). A hitbox left alive deals damage every frame through `FlxG.overlap`.

### Flag when relevant
- HUD elements (stamina `FlxBar` and any new UI) not assigned to `uiCamera`. `handleCamera()` zooms `FlxG.camera` during combat, and `Bugs.md` records UI zooming with it as a fixed bug.
- Changes to `level_w`/`level_h`, `FlxG.worldBounds` or `setScrollBounds` that disagree with each other or with the arena art in `assets/images/DinnerRoom/`. Collisions stop outside `worldBounds`.
- References to `AssetPaths.*` fields for files that were renamed, moved, or differ only in case. The build macro generates field names from filenames, so a rename breaks compilation, and two files with the same name in different folders collide. Linux targets are case-sensitive.
- Stamina/health arithmetic that can go past its bounds (`staminaMP` regen adds a fixed amount without clamping to `maxStaminaMP`; costs are subtracted after only a `<= 0` check).
- New per-frame `trace(...)` calls in `update()` paths (as in `Enemy.debugEnemy()`) outside a `#if debug` guard. They flood the html5 console and slow native builds.
- `#if mobile` code (`_virtualPad`) that is used without the same guard. `_virtualPad` is null on desktop.

### Don't flag
- Coloured `makeGraphic` placeholder boxes, unused prototype states (`Town`, `DinnerRoom`), commented-out experiments, and `FlxG.debugger.drawDebug = true`. The README says the prototype is paused, with art not wired in.
- Ideas listed in `workingBrain.txt` that aren't built yet (RPS types, post-hit invincibility).
- Formatting (`hxformat.json`), naming, or missing tests.
