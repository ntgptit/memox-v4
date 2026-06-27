/* MemoX — Player (auto-play). States: playing · paused · speed · end */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxIconButton, MxFab, MxButton, MxSegmentedControl } = NS;

function Dots() {
  return (
    <div data-mx-node="player/progress" style={{ display: 'flex', gap: 6, justifyContent: 'center' }}>
      {Array.from({ length: 8 }).map((_, i) => (
        <div key={i} style={{ width: i === 3 ? 22 : 8, height: 8, borderRadius: 999, background: i <= 3 ? 'var(--memox-primary)' : 'var(--memox-surface-sunken)' }} />
      ))}
    </div>
  );
}

function Player({ state = 'playing' }) {
  const playing = state !== 'paused';
  const bar = (
    <MxAppBar node="player/appbar" title="TOPIK I — Vocabulary"
      leading={<MxIconButton icon="arrow_back" node="player/back" />}
      trailing={<React.Fragment>
        <MxIconButton icon="format_size" node="player/text-size" />
        <MxIconButton icon="more_vert" node="player/options" />
      </React.Fragment>} />
  );

  if (state === 'end') {
    return (
      <MxScaffold node="player/screen" appBar={bar}>
        <window.EmptyState node="player/end" icon="library_music" tone="accent" title="All played"
          text="The player has read through every card in this deck."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 220 }}>
            <MxButton variant="primary" icon="replay" block node="player/replay">Replay</MxButton>
            <MxButton variant="ghost" icon="close" block node="player/close">Close</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="player/screen" appBar={bar}>
      <Dots />
      <MxCard node="player/card" style={{ flex: 1, alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 'var(--memox-space-4)', minHeight: 280 }}>
        <div style={{ fontSize: 52, fontWeight: 800, letterSpacing: '-.02em' }}>학교</div>
        <div style={{ width: 56, height: 2, background: 'var(--memox-divider)', borderRadius: 2 }} />
        <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 700 }}>school</div>
      </MxCard>

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 'var(--memox-space-6)' }}>
        <MxIconButton icon="skip_previous" node="player/prev" />
        <MxFab icon={playing ? 'pause' : 'play_arrow'} node="player/playpause" />
        <MxIconButton icon="skip_next" node="player/next" />
      </div>

      {state === 'speed' ? (
        <MxSegmentedControl value="1" onChange={() => {}} block node="player/speed-control"
          segments={[{ value: '0.75', label: '×0.75' }, { value: '1', label: '×1' }, { value: '1.5', label: '×1.5' }]} />
      ) : (
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <MxButton variant="ghost" size="sm" icon="speed" node="player/speed">×1</MxButton>
        </div>
      )}
    </MxScaffold>
  );
}

window.Player = Player;
})();
