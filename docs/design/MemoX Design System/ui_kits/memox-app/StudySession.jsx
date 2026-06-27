/* MemoX — Study Session screen. States: front · back · done */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxButton, MxIconButton, MxIconTile, MxChip } = NS;

function Bar({ index, total }) {
  return (
    <MxAppBar node="study-session/appbar"
      leading={<MxIconButton icon="close" node="study-session/close" />}
      title={<div data-mx-node="study-session/progress" style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <window.ProgressBar value={total ? (index / total) * 100 : 0} height={8} />
        <span style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 700, color: 'var(--memox-text-secondary)', whiteSpace: 'nowrap' }}>{index}/{total}</span>
      </div>}
      trailing={<MxIconButton icon="more_horiz" node="study-session/options" />} />
  );
}

const RATINGS = [
  { id: 'again', label: 'Again', sub: '<1m', bg: 'var(--memox-error-soft)', fg: 'var(--memox-on-error-soft)' },
  { id: 'hard', label: 'Hard', sub: '8m', bg: 'var(--memox-warning-soft)', fg: 'var(--memox-on-warning-soft)' },
  { id: 'good', label: 'Good', sub: '1d', bg: 'var(--memox-success-soft)', fg: 'var(--memox-on-success-soft)' },
  { id: 'easy', label: 'Easy', sub: '4d', bg: 'var(--memox-primary-soft)', fg: 'var(--memox-on-primary-soft)' },
];

function Flashcard({ revealed }) {
  return (
    <MxCard node="study-session/card" style={{ flex: 1, justifyContent: 'center', alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-5)', minHeight: 320 }}>
      <MxChip label="Japanese N5" variant="ghost" node="study-session/deck-tag" />
      <div style={{ fontSize: 52, fontWeight: 800, letterSpacing: '-.02em' }}>勉強</div>
      <div style={{ fontSize: 'var(--memox-font-size-md)', color: 'var(--memox-text-secondary)' }}>べんきょう</div>
      {revealed ? (
        <React.Fragment>
          <div style={{ width: 56, height: 2, background: 'var(--memox-divider)', borderRadius: 2 }} />
          <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 700 }}>study</div>
          <div style={{ fontSize: 'var(--memox-font-size-base)', color: 'var(--memox-text-secondary)', maxWidth: 220 }}>to study; diligence (suru-verb)</div>
        </React.Fragment>
      ) : (
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--memox-text-tertiary)', fontSize: 'var(--memox-font-size-sm)', fontWeight: 600 }}>
          <span className="material-symbols-rounded" style={{ fontSize: 18 }}>touch_app</span> Tap to reveal answer
        </div>
      )}
    </MxCard>
  );
}

function StudySession({ state = 'front' }) {
  if (state === 'done') {
    return (
      <MxScaffold node="study-session/screen" appBar={<Bar index={40} total={40} />}>
        <window.EmptyState node="study-session/complete" icon="celebration" tone="success" title="Session complete!"
          text="You reviewed 40 cards in 9 minutes. Nice focus — come back tomorrow to keep your streak."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 220 }}>
            <MxButton variant="primary" icon="done" block node="study-session/finish">Finish</MxButton>
            <MxButton variant="ghost" icon="replay" block node="study-session/again">Study again</MxButton>
          </div>} />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 'var(--memox-space-3)' }}>
          {[['40', 'reviewed'], ['94%', 'correct'], ['9m', 'time']].map(([n, l], i) => (
            <MxCard key={i} variant="muted" padding="sm" node={'study-session/stat-' + i} style={{ alignItems: 'center', gap: 2 }}>
              <div style={{ fontSize: 22, fontWeight: 800 }}>{n}</div>
              <div style={{ fontSize: 12, color: 'var(--memox-text-secondary)' }}>{l}</div>
            </MxCard>
          ))}
        </div>
      </MxScaffold>
    );
  }

  const revealed = state === 'back';
  return (
    <MxScaffold node="study-session/screen" appBar={<Bar index={12} total={40} />}>
      <Flashcard revealed={revealed} />
      {revealed ? (
        <div data-mx-node="study-session/ratings" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: 'var(--memox-space-2)' }}>
          {RATINGS.map((r) => (
            <button key={r.id} data-mx-node={'study-session/rate-' + r.id} style={{ border: 'none', cursor: 'pointer', borderRadius: 'var(--memox-radius-control)', padding: '12px 4px', background: r.bg, color: r.fg, fontFamily: 'inherit', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
              <span style={{ fontWeight: 700, fontSize: 'var(--memox-font-size-base)' }}>{r.label}</span>
              <span style={{ fontSize: 11, opacity: .8 }}>{r.sub}</span>
            </button>
          ))}
        </div>
      ) : (
        <MxButton variant="primary" icon="visibility" block size="lg" node="study-session/reveal">Show answer</MxButton>
      )}
    </MxScaffold>
  );
}

window.StudySession = StudySession;
})();
