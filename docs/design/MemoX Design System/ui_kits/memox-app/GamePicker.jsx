/* MemoX — Game picker ("Single game"). States: default · scope-dropdown · not-enough */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxIconTile } = NS;

const GAMES = [
  { icon: 'join_inner', name: 'Matching', desc: 'Match terms to meanings', id: 'matching' },
  { icon: 'quiz', name: 'Multiple choice', desc: 'Pick the right meaning', id: 'mc' },
  { icon: 'psychology', name: 'Recall', desc: 'Recall, then self-grade', id: 'recall' },
  { icon: 'keyboard', name: 'Typing', desc: 'Type the term from its meaning', id: 'typing' },
];

function GameOption({ g, disabled }) {
  return (
    <MxCard interactive padding="sm" node={'game-picker/game-' + g.id} style={{ opacity: disabled ? .5 : 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
        <MxIconTile icon={g.icon} tone="accent" />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 'var(--memox-font-weight-bold)', fontSize: 'var(--memox-font-size-base)' }}>{g.name}</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)' }}>{g.desc}</div>
        </div>
        <span className="material-symbols-rounded" style={{ color: 'var(--memox-text-tertiary)' }}>chevron_right</span>
      </div>
    </MxCard>
  );
}

function GamePicker({ state = 'default' }) {
  const notEnough = state === 'not-enough';
  const bar = <MxAppBar title="Single game" node="game-picker/appbar" leading={<MxIconButton icon="arrow_back" node="game-picker/back" />} />;

  const base = (
    <MxScaffold node="game-picker/screen" appBar={bar}>
      {notEnough ? (
        <div data-mx-node="game-picker/not-enough" style={{ background: 'var(--memox-warning-soft)', color: 'var(--memox-on-warning-soft)', borderRadius: 'var(--memox-radius-control)', padding: 'var(--memox-space-3) var(--memox-space-4)', display: 'flex', alignItems: 'center', gap: 'var(--memox-space-3)' }}>
          <span className="material-symbols-rounded">info</span>
          <span style={{ flex: 1, fontSize: 'var(--memox-font-size-sm)' }}>This deck needs at least 4 words to play.</span>
          <MxButton variant="primary" size="sm" node="game-picker/add-cards">Add words</MxButton>
        </div>
      ) : null}

      <MxCard interactive padding="sm" node="game-picker/scope">
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
          <MxIconTile icon="tune" tone="success" />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontWeight: 'var(--memox-font-weight-bold)', fontSize: 'var(--memox-font-size-base)' }}>Card source</div>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 'var(--memox-space-1)' }}>By schedule</div>
          </div>
          <span className="material-symbols-rounded" style={{ color: 'var(--memox-text-tertiary)' }}>expand_more</span>
        </div>
      </MxCard>

      {GAMES.map((g) => <GameOption key={g.id} g={g} disabled={notEnough} />)}

      <div style={{ textAlign: 'center', fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', padding: 'var(--memox-space-1) 0' }}>5 words per round · change in Settings</div>
    </MxScaffold>
  );

  if (state === 'scope-dropdown') {
    const opts = [
      { icon: 'schedule', label: 'By schedule', sel: true, id: 'srs' },
      { icon: 'apps', label: 'All cards', sel: false, id: 'all' },
      { icon: 'hourglass_empty', label: 'Unlearned only', sel: false, id: 'unlearned' },
    ];
    return (
      <React.Fragment>
        {base}
        <window.Scrim node="game-picker/scope-scrim">
          <window.Sheet title="Card source" node="game-picker/scope-sheet">
            {opts.map((o) => (
              <window.MenuItem key={o.id} icon={o.icon} label={o.label} node={'game-picker/scope-' + o.id}
                trailing={o.sel ? <span className="material-symbols-rounded" style={{ color: 'var(--memox-primary)' }}>check</span> : null} />
            ))}
          </window.Sheet>
        </window.Scrim>
      </React.Fragment>
    );
  }

  return base;
}

window.GamePicker = GamePicker;
})();
