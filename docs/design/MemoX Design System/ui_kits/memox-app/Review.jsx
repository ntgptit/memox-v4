/* MemoX — Review. States: browsing · editing · audio · end */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxCard, MxIconButton, MxButton } = NS;

function Review({ state = 'browsing' }) {
  const editing = state === 'editing';
  const bar = (
    <MxAppBar node="review/appbar" title="Review"
      leading={<MxIconButton icon="arrow_back" node="review/back" />}
      trailing={<React.Fragment>
        <MxIconButton icon="format_size" node="review/text-size" />
        <MxIconButton icon="more_vert" node="review/options" />
      </React.Fragment>} />
  );

  if (state === 'end') {
    return (
      <MxScaffold node="review/screen" appBar={bar}>
        <window.EmptyState node="review/end" icon="done_all" tone="success" title="All reviewed"
          text="You've gone through every card in this deck."
          action={<div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)', width: 'var(--memox-size-3xl)' }}>
            <MxButton variant="primary" icon="school" block node="review/study-now">Study now</MxButton>
            <MxButton variant="ghost" icon="arrow_back" block node="review/back-deck">Back to deck</MxButton>
          </div>} />
      </MxScaffold>
    );
  }

  return (
    <MxScaffold node="review/screen" appBar={bar}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--memox-space-3)' }}>
        <div style={{ flex: 1 }}><window.ProgressBar value={35} height={6} node="review/progress" /></div>
        <span style={{ fontSize: 'var(--memox-font-size-sm)', fontWeight: 'var(--memox-font-weight-bold)', color: 'var(--memox-text-secondary)' }}>7/20</span>
      </div>

      <MxCard node="review/meaning" style={{ gap: 'var(--memox-space-3)' }}>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <span style={{ flex: 1, fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 'var(--memox-font-weight-bold)', letterSpacing: 'var(--memox-letter-spacing-wide)' }}>MEANING</span>
          <MxIconButton icon={editing ? 'close' : 'edit'} size="sm" node="review/edit" />
        </div>
        {editing ? (
          <React.Fragment>
            <div style={{ border: 'var(--memox-stroke-emphasis) solid var(--memox-primary)', borderRadius: 'var(--memox-radius-control)', padding: 'var(--memox-space-3) var(--memox-space-4)', fontSize: 'var(--memox-font-size-md)', fontWeight: 'var(--memox-font-weight-bold)' }}>school<span style={{ color: 'var(--memox-primary)' }}>|</span></div>
            <div style={{ display: 'flex', gap: 'var(--memox-space-2)', justifyContent: 'flex-end' }}>
              <MxButton variant="ghost" size="sm" node="review/edit-cancel">Cancel</MxButton>
              <MxButton variant="primary" size="sm" node="review/edit-save">Save</MxButton>
            </div>
          </React.Fragment>
        ) : (
          <div style={{ fontSize: 'var(--memox-font-size-2xl)', fontWeight: 'var(--memox-font-weight-bold)' }}>school</div>
        )}
      </MxCard>

      <MxCard node="review/term" style={{ alignItems: 'center', textAlign: 'center', gap: 'var(--memox-space-3)', padding: 'var(--memox-space-6)' }}>
        <div style={{ fontSize: 'var(--memox-font-size-4xl)', fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>학교</div>
        <MxIconButton icon={state === 'audio' ? 'graphic_eq' : 'volume_up'} node="review/audio" />
        {state === 'audio' ? <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-primary)', fontWeight: 'var(--memox-font-weight-semibold)' }}>Playing…</div> : null}
      </MxCard>

      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 'var(--memox-space-4)', color: 'var(--memox-text-tertiary)' }}>
        <MxIconButton icon="chevron_left" node="review/prev" />
        <span style={{ fontSize: 'var(--memox-font-size-sm)' }}>Swipe to continue</span>
        <MxIconButton icon="chevron_right" node="review/next" />
      </div>
    </MxScaffold>
  );
}

window.Review = Review;
})();
