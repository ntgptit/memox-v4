/* MemoX — Game picker ("Một trò chơi") screen. States: default · scope-dropdown · not-enough */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxIconTile } = NS;

const GAMES = [
  { icon: 'join_inner', name: 'Ghép đôi', desc: 'Nối term với nghĩa', id: 'matching' },
  { icon: 'quiz', name: 'Đoán', desc: 'Chọn nghĩa đúng trong nhiều lựa chọn', id: 'mc' },
  { icon: 'psychology', name: 'Nhớ lại', desc: 'Tự nhớ rồi tự chấm', id: 'recall' },
  { icon: 'keyboard', name: 'Điền', desc: 'Gõ lại term từ nghĩa', id: 'typing' },
];

function GameOption({ g, disabled }) {
  return (
    <MxCard interactive padding="sm" node={'game-picker/game-' + g.id} style={{ opacity: disabled ? .5 : 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
        <MxIconTile icon={g.icon} tone="accent" />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>{g.name}</div>
          <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2 }}>{g.desc}</div>
        </div>
        <span className="material-symbols-rounded" style={{ color: 'var(--memox-text-tertiary)' }}>chevron_right</span>
      </div>
    </MxCard>
  );
}

function GamePicker({ state = 'default' }) {
  const notEnough = state === 'not-enough';
  const bar = <MxAppBar title="Một trò chơi" node="game-picker/appbar" leading={<MxIconButton icon="arrow_back" node="game-picker/back" />} />;

  const base = (
    <MxScaffold node="game-picker/screen" appBar={bar}>
      {notEnough ? (
        <div data-mx-node="game-picker/not-enough" style={{ background: 'var(--memox-warning-soft)', color: 'var(--memox-on-warning-soft)', borderRadius: 'var(--memox-radius-control)', padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10 }}>
          <span className="material-symbols-rounded">info</span>
          <span style={{ flex: 1, fontSize: 'var(--memox-font-size-sm)' }}>Bộ thẻ cần tối thiểu 4 từ để chơi.</span>
          <MxButton variant="primary" size="sm" node="game-picker/add-cards">Thêm từ</MxButton>
        </div>
      ) : null}

      <MxCard interactive padding="sm" node="game-picker/scope">
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-4)' }}>
          <MxIconTile icon="tune" tone="success" />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>Chế độ lấy từ</div>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-secondary)', marginTop: 2 }}>Theo giãn cách</div>
          </div>
          <span className="material-symbols-rounded" style={{ color: 'var(--memox-text-tertiary)' }}>expand_more</span>
        </div>
      </MxCard>

      {GAMES.map((g) => <GameOption key={g.id} g={g} disabled={notEnough} />)}

      <div style={{ textAlign: 'center', fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', padding: '4px 0' }}>5 từ mỗi ván · đổi trong Cài đặt</div>
    </MxScaffold>
  );

  if (state === 'scope-dropdown') {
    const opts = [
      { icon: 'schedule', label: 'Theo giãn cách', sel: true, id: 'srs' },
      { icon: 'apps', label: 'Tất cả', sel: false, id: 'all' },
      { icon: 'hourglass_empty', label: 'Chỉ thẻ chưa thuộc', sel: false, id: 'unlearned' },
    ];
    return (
      <React.Fragment>
        {base}
        <window.Scrim node="game-picker/scope-scrim">
          <window.Sheet title="Chế độ lấy từ" node="game-picker/scope-sheet">
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
