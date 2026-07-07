# Flutter golden gallery — every state (Windows render)

> Ảnh **do Flutter build** cho từng state (light + dark), so cạnh **kit shot**. Số = % matching hiện tại (threshold 0.2, local Windows). Sắp xếp screen **thấp→cao**. Nguồn: regen goldens @ main.

> Kit = trình duyệt (Blink), Flutter = Skia → phần lệch còn lại phần lớn là AA cross-renderer.


## Mục lục

- [`dashboard` — 89.4%](#dashboard)
- [`game-recall` — 90.9%](#game-recall)
- [`import` — 91.2%](#import)
- [`theme` — 91.4%](#theme)
- [`study-session` — 91.7%](#study-session)
- [`drawer` — 91.9%](#drawer)
- [`game-mc` — 92.5%](#game-mc)
- [`export` — 93.1%](#export)
- [`deck-detail` — 93.2%](#deck-detail)
- [`statistics` — 93.2%](#statistics)
- [`library` — 93.8%](#library)
- [`player` — 94.0%](#player)
- [`settings` — 94.4%](#settings)
- [`flashcard-editor` — 94.6%](#flashcard-editor)
- [`study-result` — 94.8%](#study-result)
- [`game-picker` — 95.1%](#game-picker)
- [`review` — 95.4%](#review)
- [`game-typing` — 95.4%](#game-typing)
- [`game-matching` — 96.4%](#game-matching)
- [`reminder` — 96.6%](#reminder)
- [`search` — 97.4%](#search)

---


<a id="dashboard"></a>
## `dashboard` — avg 89.4%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `empty` | 83.3 / 83.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/dashboard--empty--light.png" width="190"> | <img src="flutter-shots/dashboard--empty--light.png" width="190"> | <img src="flutter-shots/dashboard--empty--dark.png" width="190"> |
| `loaded` | 88.0 / 89.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/dashboard--loaded--light.png" width="190"> | <img src="flutter-shots/dashboard--loaded--light.png" width="190"> | <img src="flutter-shots/dashboard--loaded--dark.png" width="190"> |
| `goal-met` | 88.5 / 89.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/dashboard--goal-met--light.png" width="190"> | <img src="flutter-shots/dashboard--goal-met--light.png" width="190"> | <img src="flutter-shots/dashboard--goal-met--dark.png" width="190"> |
| `streak-reset` | 88.9 / 89.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/dashboard--streak-reset--light.png" width="190"> | <img src="flutter-shots/dashboard--streak-reset--light.png" width="190"> | <img src="flutter-shots/dashboard--streak-reset--dark.png" width="190"> |
| `loading` | 96.4 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/dashboard--loading--light.png" width="190"> | <img src="flutter-shots/dashboard--loading--light.png" width="190"> | <img src="flutter-shots/dashboard--loading--dark.png" width="190"> |

<a id="game-recall"></a>
## `game-recall` — avg 90.9%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `before-reveal` | 88.3 / 88.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-recall--before-reveal--light.png" width="190"> | <img src="flutter-shots/game-recall--before-reveal--light.png" width="190"> | <img src="flutter-shots/game-recall--before-reveal--dark.png" width="190"> |
| `forgot` | 89.1 / 89.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-recall--forgot--light.png" width="190"> | <img src="flutter-shots/game-recall--forgot--light.png" width="190"> | <img src="flutter-shots/game-recall--forgot--dark.png" width="190"> |
| `remembered` | 90.3 / 90.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-recall--remembered--light.png" width="190"> | <img src="flutter-shots/game-recall--remembered--light.png" width="190"> | <img src="flutter-shots/game-recall--remembered--dark.png" width="190"> |
| `complete` | 92.4 / 92.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-recall--complete--light.png" width="190"> | <img src="flutter-shots/game-recall--complete--light.png" width="190"> | <img src="flutter-shots/game-recall--complete--dark.png" width="190"> |
| `revealed` | 94.1 / 94.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-recall--revealed--light.png" width="190"> | <img src="flutter-shots/game-recall--revealed--light.png" width="190"> | <img src="flutter-shots/game-recall--revealed--dark.png" width="190"> |

<a id="import"></a>
## `import` — avg 91.2%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `dup-warning` | 87.3 / 86.9 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/import--dup-warning--light.png" width="190"> | <img src="flutter-shots/import--dup-warning--light.png" width="190"> | <img src="flutter-shots/import--dup-warning--dark.png" width="190"> |
| `preview` | 87.7 / 87.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/import--preview--light.png" width="190"> | <img src="flutter-shots/import--preview--light.png" width="190"> | <img src="flutter-shots/import--preview--dark.png" width="190"> |
| `source` | 90.9 / 96.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/import--source--light.png" width="190"> | <img src="flutter-shots/import--source--light.png" width="190"> | <img src="flutter-shots/import--source--dark.png" width="190"> |
| `done` | 92.8 / 92.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/import--done--light.png" width="190"> | <img src="flutter-shots/import--done--light.png" width="190"> | <img src="flutter-shots/import--done--dark.png" width="190"> |
| `mapping` | 95.0 / 94.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/import--mapping--light.png" width="190"> | <img src="flutter-shots/import--mapping--light.png" width="190"> | <img src="flutter-shots/import--mapping--dark.png" width="190"> |

<a id="theme"></a>
## `theme` — avg 91.4%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `accent-size` | 90.5 / 90.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/theme--accent-size--light.png" width="190"> | <img src="flutter-shots/theme--accent-size--light.png" width="190"> | <img src="flutter-shots/theme--accent-size--dark.png" width="190"> |
| `dark` | 91.5 / 92.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/theme--dark--light.png" width="190"> | <img src="flutter-shots/theme--dark--light.png" width="190"> | <img src="flutter-shots/theme--dark--dark.png" width="190"> |
| `light` | 91.5 / 92.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/theme--light--light.png" width="190"> | <img src="flutter-shots/theme--light--light.png" width="190"> | <img src="flutter-shots/theme--light--dark.png" width="190"> |

<a id="study-session"></a>
## `study-session` — avg 91.7%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `exit` | 81.1 / 95.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--exit--light.png" width="190"> | <img src="flutter-shots/study-session--exit--light.png" width="190"> | <img src="flutter-shots/study-session--exit--dark.png" width="190"> |
| `stage4-recall` | 84.7 / 85.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--stage4-recall--light.png" width="190"> | <img src="flutter-shots/study-session--stage4-recall--light.png" width="190"> | <img src="flutter-shots/study-session--stage4-recall--dark.png" width="190"> |
| `stage1-review` | 84.8 / 85.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--stage1-review--light.png" width="190"> | <img src="flutter-shots/study-session--stage1-review--light.png" width="190"> | <img src="flutter-shots/study-session--stage1-review--dark.png" width="190"> |
| `answer-save-error` | 84.8 / 94.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--answer-save-error--light.png" width="190"> | <img src="flutter-shots/study-session--answer-save-error--light.png" width="190"> | <img src="flutter-shots/study-session--answer-save-error--dark.png" width="190"> |
| `due-review` | 91.2 / 91.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--due-review--light.png" width="190"> | <img src="flutter-shots/study-session--due-review--light.png" width="190"> | <img src="flutter-shots/study-session--due-review--dark.png" width="190"> |
| `stage5-typing` | 91.8 / 92.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--stage5-typing--light.png" width="190"> | <img src="flutter-shots/study-session--stage5-typing--light.png" width="190"> | <img src="flutter-shots/study-session--stage5-typing--dark.png" width="190"> |
| `resume-error` | 94.7 / 94.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--resume-error--light.png" width="190"> | <img src="flutter-shots/study-session--resume-error--light.png" width="190"> | <img src="flutter-shots/study-session--resume-error--dark.png" width="190"> |
| `relearn` | 95.7 / 96.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--relearn--light.png" width="190"> | <img src="flutter-shots/study-session--relearn--light.png" width="190"> | <img src="flutter-shots/study-session--relearn--dark.png" width="190"> |
| `stage3-choice` | 97.0 / 97.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--stage3-choice--light.png" width="190"> | <img src="flutter-shots/study-session--stage3-choice--light.png" width="190"> | <img src="flutter-shots/study-session--stage3-choice--dark.png" width="190"> |
| `stage2-matching` | 98.4 / 98.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-session--stage2-matching--light.png" width="190"> | <img src="flutter-shots/study-session--stage2-matching--light.png" width="190"> | <img src="flutter-shots/study-session--stage2-matching--dark.png" width="190"> |

<a id="drawer"></a>
## `drawer` — avg 91.9%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `open` | 86.4 / 95.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/drawer--open--light.png" width="190"> | <img src="flutter-shots/drawer--open--light.png" width="190"> | <img src="flutter-shots/drawer--open--dark.png" width="190"> |
| `remove-language` | 87.2 / 95.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/drawer--remove-language--light.png" width="190"> | <img src="flutter-shots/drawer--remove-language--light.png" width="190"> | <img src="flutter-shots/drawer--remove-language--dark.png" width="190"> |
| `add-language` | 90.9 / 96.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/drawer--add-language--light.png" width="190"> | <img src="flutter-shots/drawer--add-language--light.png" width="190"> | <img src="flutter-shots/drawer--add-language--dark.png" width="190"> |

<a id="game-mc"></a>
## `game-mc` — avg 92.5%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `wrong` | 89.8 / 89.9 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-mc--wrong--light.png" width="190"> | <img src="flutter-shots/game-mc--wrong--light.png" width="190"> | <img src="flutter-shots/game-mc--wrong--dark.png" width="190"> |
| `correct` | 91.0 / 91.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-mc--correct--light.png" width="190"> | <img src="flutter-shots/game-mc--correct--light.png" width="190"> | <img src="flutter-shots/game-mc--correct--dark.png" width="190"> |
| `complete` | 92.2 / 92.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-mc--complete--light.png" width="190"> | <img src="flutter-shots/game-mc--complete--light.png" width="190"> | <img src="flutter-shots/game-mc--complete--dark.png" width="190"> |
| `waiting` | 96.9 / 97.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-mc--waiting--light.png" width="190"> | <img src="flutter-shots/game-mc--waiting--light.png" width="190"> | <img src="flutter-shots/game-mc--waiting--dark.png" width="190"> |

<a id="export"></a>
## `export` — avg 93.1%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `config` | 89.8 / 89.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/export--config--light.png" width="190"> | <img src="flutter-shots/export--config--light.png" width="190"> | <img src="flutter-shots/export--config--dark.png" width="190"> |
| `done` | 91.1 / 91.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/export--done--light.png" width="190"> | <img src="flutter-shots/export--done--light.png" width="190"> | <img src="flutter-shots/export--done--dark.png" width="190"> |
| `exporting` | 98.2 / 98.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/export--exporting--light.png" width="190"> | <img src="flutter-shots/export--exporting--light.png" width="190"> | <img src="flutter-shots/export--exporting--dark.png" width="190"> |

<a id="deck-detail"></a>
## `deck-detail` — avg 93.2%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `reset-confirm` | 82.9 / 92.9 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--reset-confirm--light.png" width="190"> | <img src="flutter-shots/deck-detail--reset-confirm--light.png" width="190"> | <img src="flutter-shots/deck-detail--reset-confirm--dark.png" width="190"> |
| `delete-confirm` | 83.0 / 95.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--delete-confirm--light.png" width="190"> | <img src="flutter-shots/deck-detail--delete-confirm--light.png" width="190"> | <img src="flutter-shots/deck-detail--delete-confirm--dark.png" width="190"> |
| `deck-delete-confirm` | 84.5 / 94.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--deck-delete-confirm--light.png" width="190"> | <img src="flutter-shots/deck-detail--deck-delete-confirm--light.png" width="190"> | <img src="flutter-shots/deck-detail--deck-delete-confirm--dark.png" width="190"> |
| `deck-menu` | 87.6 / 97.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--deck-menu--light.png" width="190"> | <img src="flutter-shots/deck-detail--deck-menu--light.png" width="190"> | <img src="flutter-shots/deck-detail--deck-menu--dark.png" width="190"> |
| `move` | 88.2 / 95.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--move--light.png" width="190"> | <img src="flutter-shots/deck-detail--move--light.png" width="190"> | <img src="flutter-shots/deck-detail--move--dark.png" width="190"> |
| `loaded` | 88.7 / 89.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--loaded--light.png" width="190"> | <img src="flutter-shots/deck-detail--loaded--light.png" width="190"> | <img src="flutter-shots/deck-detail--loaded--dark.png" width="190"> |
| `empty` | 90.8 / 90.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--empty--light.png" width="190"> | <img src="flutter-shots/deck-detail--empty--light.png" width="190"> | <img src="flutter-shots/deck-detail--empty--dark.png" width="190"> |
| `card-actions` | 93.3 / 97.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--card-actions--light.png" width="190"> | <img src="flutter-shots/deck-detail--card-actions--light.png" width="190"> | <img src="flutter-shots/deck-detail--card-actions--dark.png" width="190"> |
| `add-menu` | 93.4 / 97.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--add-menu--light.png" width="190"> | <img src="flutter-shots/deck-detail--add-menu--light.png" width="190"> | <img src="flutter-shots/deck-detail--add-menu--dark.png" width="190"> |
| `error` | 96.2 / 96.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--error--light.png" width="190"> | <img src="flutter-shots/deck-detail--error--light.png" width="190"> | <img src="flutter-shots/deck-detail--error--dark.png" width="190"> |
| `no-results` | 97.2 / 97.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--no-results--light.png" width="190"> | <img src="flutter-shots/deck-detail--no-results--light.png" width="190"> | <img src="flutter-shots/deck-detail--no-results--dark.png" width="190"> |
| `search` | 97.5 / 97.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--search--light.png" width="190"> | <img src="flutter-shots/deck-detail--search--light.png" width="190"> | <img src="flutter-shots/deck-detail--search--dark.png" width="190"> |
| `loading` | 99.1 / 99.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/deck-detail--loading--light.png" width="190"> | <img src="flutter-shots/deck-detail--loading--light.png" width="190"> | <img src="flutter-shots/deck-detail--loading--dark.png" width="190"> |

<a id="statistics"></a>
## `statistics` — avg 93.2%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `loaded` | 85.8 / 92.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/statistics--loaded--light.png" width="190"> | <img src="flutter-shots/statistics--loaded--light.png" width="190"> | <img src="flutter-shots/statistics--loaded--dark.png" width="190"> |
| `scope-switch` | 85.8 / 92.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/statistics--scope-switch--light.png" width="190"> | <img src="flutter-shots/statistics--scope-switch--light.png" width="190"> | <img src="flutter-shots/statistics--scope-switch--dark.png" width="190"> |
| `insufficient` | 96.2 / 95.9 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/statistics--insufficient--light.png" width="190"> | <img src="flutter-shots/statistics--insufficient--light.png" width="190"> | <img src="flutter-shots/statistics--insufficient--dark.png" width="190"> |
| `loading` | 97.9 / 98.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/statistics--loading--light.png" width="190"> | <img src="flutter-shots/statistics--loading--light.png" width="190"> | <img src="flutter-shots/statistics--loading--dark.png" width="190"> |

<a id="library"></a>
## `library` — avg 93.8%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `sort-menu` | 82.6 / 97.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--sort-menu--light.png" width="190"> | <img src="flutter-shots/library--sort-menu--light.png" width="190"> | <img src="flutter-shots/library--sort-menu--dark.png" width="190"> |
| `drawer` | 85.9 / 94.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--drawer--light.png" width="190"> | <img src="flutter-shots/library--drawer--light.png" width="190"> | <img src="flutter-shots/library--drawer--dark.png" width="190"> |
| `overflow-menu` | 88.9 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--overflow-menu--light.png" width="190"> | <img src="flutter-shots/library--overflow-menu--light.png" width="190"> | <img src="flutter-shots/library--overflow-menu--dark.png" width="190"> |
| `empty` | 90.6 / 90.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--empty--light.png" width="190"> | <img src="flutter-shots/library--empty--light.png" width="190"> | <img src="flutter-shots/library--empty--dark.png" width="190"> |
| `loaded` | 93.7 / 93.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--loaded--light.png" width="190"> | <img src="flutter-shots/library--loaded--light.png" width="190"> | <img src="flutter-shots/library--loaded--dark.png" width="190"> |
| `play-sheet` | 94.2 / 96.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--play-sheet--light.png" width="190"> | <img src="flutter-shots/library--play-sheet--light.png" width="190"> | <img src="flutter-shots/library--play-sheet--dark.png" width="190"> |
| `pair-picker` | 94.8 / 97.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--pair-picker--light.png" width="190"> | <img src="flutter-shots/library--pair-picker--light.png" width="190"> | <img src="flutter-shots/library--pair-picker--dark.png" width="190"> |
| `error` | 95.4 / 95.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--error--light.png" width="190"> | <img src="flutter-shots/library--error--light.png" width="190"> | <img src="flutter-shots/library--error--dark.png" width="190"> |
| `search-active` | 95.5 / 95.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--search-active--light.png" width="190"> | <img src="flutter-shots/library--search-active--light.png" width="190"> | <img src="flutter-shots/library--search-active--dark.png" width="190"> |
| `loading` | 98.4 / 98.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/library--loading--light.png" width="190"> | <img src="flutter-shots/library--loading--light.png" width="190"> | <img src="flutter-shots/library--loading--dark.png" width="190"> |

<a id="player"></a>
## `player` — avg 94.0%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `end` | 91.3 / 91.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/player--end--light.png" width="190"> | <img src="flutter-shots/player--end--light.png" width="190"> | <img src="flutter-shots/player--end--dark.png" width="190"> |
| `speed` | 94.5 / 95.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/player--speed--light.png" width="190"> | <img src="flutter-shots/player--speed--light.png" width="190"> | <img src="flutter-shots/player--speed--dark.png" width="190"> |
| `paused` | 94.6 / 95.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/player--paused--light.png" width="190"> | <img src="flutter-shots/player--paused--light.png" width="190"> | <img src="flutter-shots/player--paused--dark.png" width="190"> |
| `playing` | 94.6 / 95.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/player--playing--light.png" width="190"> | <img src="flutter-shots/player--playing--light.png" width="190"> | <img src="flutter-shots/player--playing--dark.png" width="190"> |

<a id="settings"></a>
## `settings` — avg 94.4%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `group-expanded` | 93.8 / 93.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/settings--group-expanded--light.png" width="190"> | <img src="flutter-shots/settings--group-expanded--light.png" width="190"> | <img src="flutter-shots/settings--group-expanded--dark.png" width="190"> |
| `loaded` | 94.2 / 93.9 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/settings--loaded--light.png" width="190"> | <img src="flutter-shots/settings--loaded--light.png" width="190"> | <img src="flutter-shots/settings--loaded--dark.png" width="190"> |
| `value-picker` | 94.6 / 96.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/settings--value-picker--light.png" width="190"> | <img src="flutter-shots/settings--value-picker--light.png" width="190"> | <img src="flutter-shots/settings--value-picker--dark.png" width="190"> |

<a id="flashcard-editor"></a>
## `flashcard-editor` — avg 94.6%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `duplicate` | 93.3 / 92.9 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/flashcard-editor--duplicate--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--duplicate--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--duplicate--dark.png" width="190"> |
| `validation` | 93.8 / 94.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/flashcard-editor--validation--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--validation--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--validation--dark.png" width="190"> |
| `audio` | 95.1 / 94.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/flashcard-editor--audio--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--audio--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--audio--dark.png" width="190"> |
| `edit` | 95.1 / 94.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/flashcard-editor--edit--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--edit--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--edit--dark.png" width="190"> |
| `create` | 95.3 / 95.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/flashcard-editor--create--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--create--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--create--dark.png" width="190"> |
| `multi-meaning` | 95.3 / 94.9 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/flashcard-editor--multi-meaning--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--multi-meaning--light.png" width="190"> | <img src="flutter-shots/flashcard-editor--multi-meaning--dark.png" width="190"> |

<a id="study-result"></a>
## `study-result` — avg 94.8%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `goal-met` | 90.5 / 90.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-result--goal-met--light.png" width="190"> | <img src="flutter-shots/study-result--goal-met--light.png" width="190"> | <img src="flutter-shots/study-result--goal-met--dark.png" width="190"> |
| `goal-missed` | 91.8 / 91.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-result--goal-missed--light.png" width="190"> | <img src="flutter-shots/study-result--goal-missed--light.png" width="190"> | <img src="flutter-shots/study-result--goal-missed--dark.png" width="190"> |
| `finalize-error` | 93.8 / 93.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-result--finalize-error--light.png" width="190"> | <img src="flutter-shots/study-result--finalize-error--light.png" width="190"> | <img src="flutter-shots/study-result--finalize-error--dark.png" width="190"> |
| `many-wrong` | 94.7 / 94.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-result--many-wrong--light.png" width="190"> | <img src="flutter-shots/study-result--many-wrong--light.png" width="190"> | <img src="flutter-shots/study-result--many-wrong--dark.png" width="190"> |
| `standard` | 95.7 / 95.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-result--standard--light.png" width="190"> | <img src="flutter-shots/study-result--standard--light.png" width="190"> | <img src="flutter-shots/study-result--standard--dark.png" width="190"> |
| `finalizing` | 98.6 / 98.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-result--finalizing--light.png" width="190"> | <img src="flutter-shots/study-result--finalizing--light.png" width="190"> | <img src="flutter-shots/study-result--finalizing--dark.png" width="190"> |
| `retry-finalize` | 98.6 / 98.7 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/study-result--retry-finalize--light.png" width="190"> | <img src="flutter-shots/study-result--retry-finalize--light.png" width="190"> | <img src="flutter-shots/study-result--retry-finalize--dark.png" width="190"> |

<a id="game-picker"></a>
## `game-picker` — avg 95.1%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `scope-dropdown` | 93.7 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-picker--scope-dropdown--light.png" width="190"> | <img src="flutter-shots/game-picker--scope-dropdown--light.png" width="190"> | <img src="flutter-shots/game-picker--scope-dropdown--dark.png" width="190"> |
| `default` | 94.4 / 94.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-picker--default--light.png" width="190"> | <img src="flutter-shots/game-picker--default--light.png" width="190"> | <img src="flutter-shots/game-picker--default--dark.png" width="190"> |
| `not-enough` | 95.7 / 95.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-picker--not-enough--light.png" width="190"> | <img src="flutter-shots/game-picker--not-enough--light.png" width="190"> | <img src="flutter-shots/game-picker--not-enough--dark.png" width="190"> |

<a id="review"></a>
## `review` — avg 95.4%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `end` | 91.6 / 91.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/review--end--light.png" width="190"> | <img src="flutter-shots/review--end--light.png" width="190"> | <img src="flutter-shots/review--end--dark.png" width="190"> |
| `editing` | 95.2 / 96.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/review--editing--light.png" width="190"> | <img src="flutter-shots/review--editing--light.png" width="190"> | <img src="flutter-shots/review--editing--dark.png" width="190"> |
| `audio` | 96.8 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/review--audio--light.png" width="190"> | <img src="flutter-shots/review--audio--light.png" width="190"> | <img src="flutter-shots/review--audio--dark.png" width="190"> |
| `browsing` | 96.9 / 97.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/review--browsing--light.png" width="190"> | <img src="flutter-shots/review--browsing--light.png" width="190"> | <img src="flutter-shots/review--browsing--dark.png" width="190"> |

<a id="game-typing"></a>
## `game-typing` — avg 95.4%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `complete` | 92.6 / 92.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-typing--complete--light.png" width="190"> | <img src="flutter-shots/game-typing--complete--light.png" width="190"> | <img src="flutter-shots/game-typing--complete--dark.png" width="190"> |
| `hint` | 94.3 / 96.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-typing--hint--light.png" width="190"> | <img src="flutter-shots/game-typing--hint--light.png" width="190"> | <img src="flutter-shots/game-typing--hint--dark.png" width="190"> |
| `waiting` | 94.7 / 97.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-typing--waiting--light.png" width="190"> | <img src="flutter-shots/game-typing--waiting--light.png" width="190"> | <img src="flutter-shots/game-typing--waiting--dark.png" width="190"> |
| `wrong` | 95.6 / 95.5 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-typing--wrong--light.png" width="190"> | <img src="flutter-shots/game-typing--wrong--light.png" width="190"> | <img src="flutter-shots/game-typing--wrong--dark.png" width="190"> |
| `correct` | 95.8 / 96.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-typing--correct--light.png" width="190"> | <img src="flutter-shots/game-typing--correct--light.png" width="190"> | <img src="flutter-shots/game-typing--correct--dark.png" width="190"> |
| `typing` | 97.1 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-typing--typing--light.png" width="190"> | <img src="flutter-shots/game-typing--typing--light.png" width="190"> | <img src="flutter-shots/game-typing--typing--dark.png" width="190"> |

<a id="game-matching"></a>
## `game-matching` — avg 96.4%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `complete` | 91.9 / 92.0 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-matching--complete--light.png" width="190"> | <img src="flutter-shots/game-matching--complete--light.png" width="190"> | <img src="flutter-shots/game-matching--complete--dark.png" width="190"> |
| `wrong` | 96.6 / 96.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-matching--wrong--light.png" width="190"> | <img src="flutter-shots/game-matching--wrong--light.png" width="190"> | <img src="flutter-shots/game-matching--wrong--dark.png" width="190"> |
| `correct` | 97.0 / 97.1 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-matching--correct--light.png" width="190"> | <img src="flutter-shots/game-matching--correct--light.png" width="190"> | <img src="flutter-shots/game-matching--correct--dark.png" width="190"> |
| `selected` | 97.2 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-matching--selected--light.png" width="190"> | <img src="flutter-shots/game-matching--selected--light.png" width="190"> | <img src="flutter-shots/game-matching--selected--dark.png" width="190"> |
| `playing` | 97.7 / 97.6 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-matching--playing--light.png" width="190"> | <img src="flutter-shots/game-matching--playing--light.png" width="190"> | <img src="flutter-shots/game-matching--playing--dark.png" width="190"> |
| `almost` | 97.8 / 98.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/game-matching--almost--light.png" width="190"> | <img src="flutter-shots/game-matching--almost--light.png" width="190"> | <img src="flutter-shots/game-matching--almost--dark.png" width="190"> |

<a id="reminder"></a>
## `reminder` — avg 96.6%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `time-picker` | 95.7 / 97.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/reminder--time-picker--light.png" width="190"> | <img src="flutter-shots/reminder--time-picker--light.png" width="190"> | <img src="flutter-shots/reminder--time-picker--dark.png" width="190"> |
| `on` | 96.0 / 96.4 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/reminder--on--light.png" width="190"> | <img src="flutter-shots/reminder--on--light.png" width="190"> | <img src="flutter-shots/reminder--on--dark.png" width="190"> |
| `off` | 97.2 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/reminder--off--light.png" width="190"> | <img src="flutter-shots/reminder--off--light.png" width="190"> | <img src="flutter-shots/reminder--off--dark.png" width="190"> |

<a id="search"></a>
## `search` — avg 97.4%

| state | L / D % | kit (light) | flutter (light) | flutter (dark) |
|---|---|---|---|---|
| `no-results` | 97.0 / 96.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/search--no-results--light.png" width="190"> | <img src="flutter-shots/search--no-results--light.png" width="190"> | <img src="flutter-shots/search--no-results--dark.png" width="190"> |
| `results` | 97.2 / 97.3 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/search--results--light.png" width="190"> | <img src="flutter-shots/search--results--light.png" width="190"> | <img src="flutter-shots/search--results--dark.png" width="190"> |
| `empty-recent` | 97.2 / 97.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/search--empty-recent--light.png" width="190"> | <img src="flutter-shots/search--empty-recent--light.png" width="190"> | <img src="flutter-shots/search--empty-recent--dark.png" width="190"> |
| `loading` | 97.8 / 97.8 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/search--loading--light.png" width="190"> | <img src="flutter-shots/search--loading--light.png" width="190"> | <img src="flutter-shots/search--loading--dark.png" width="190"> |
| `filtered` | 97.9 / 98.2 | <img src="../../design/MemoX%20Design%20System/ui_kits/memox-app/shots/search--filtered--light.png" width="190"> | <img src="flutter-shots/search--filtered--light.png" width="190"> | <img src="flutter-shots/search--filtered--dark.png" width="190"> |
