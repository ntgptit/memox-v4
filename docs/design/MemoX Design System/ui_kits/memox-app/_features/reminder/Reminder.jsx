/* MemoX — Reminders. States: on · off · time-picker */
(function () {
const NS = window.MemoXDesignSystem_2ffa54;
const { MxScaffold, MxAppBar, MxIconButton, MxCard, MxSwitch, MxChip, MxButton } = NS;

const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

function TimeCol({ values, sel }) {
  return (
    <div style={{ flex: 1, maxHeight: 'var(--memox-size-2xl)', overflowY: 'auto', textAlign: 'center' }}>
      {values.map((v) => (
        <div key={v} style={{ padding: 'var(--memox-space-2) 0', fontSize: 'var(--memox-font-size-md)', fontWeight: v === sel ? 'var(--memox-font-weight-extrabold)' : 'var(--memox-font-weight-medium)', color: v === sel ? 'var(--memox-primary)' : 'var(--memox-text-tertiary)' }}>{v}</div>
      ))}
    </div>
  );
}

function Reminder({ state = 'on' }) {
  const on = state !== 'off';
  const bar = <MxAppBar title="Reminders" node="reminder/appbar" leading={<MxIconButton icon="arrow_back" node="reminder/back" />} />;

  const base = (
    <MxScaffold node="reminder/screen" appBar={bar}>
      <MxCard padding="sm">
        <window.ListRow icon="notifications" tone="warning" title="Study reminders" sub="Remind you to review every day" last node="reminder/toggle"
          trailing={<MxSwitch checked={on} onChange={() => {}} node="reminder/toggle-switch" />} />
      </MxCard>

      <MxCard interactive node="reminder/time" style={{ opacity: on ? 1 : .5 }}>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 'var(--memox-font-weight-bold)', letterSpacing: 'var(--memox-letter-spacing-wide)' }}>REMINDER TIME</div>
            <div style={{ fontSize: 'var(--memox-font-size-3xl)', fontWeight: 'var(--memox-font-weight-extrabold)', letterSpacing: 'var(--memox-letter-spacing-tight)' }}>13:00</div>
          </div>
          <MxIconButton icon="schedule" node="reminder/time-edit" />
        </div>
      </MxCard>

      <div data-mx-node="reminder/days" style={{ opacity: on ? 1 : .5 }}>
        <div style={{ fontSize: 'var(--memox-font-size-sm)', color: 'var(--memox-text-tertiary)', fontWeight: 'var(--memox-font-weight-bold)', letterSpacing: 'var(--memox-letter-spacing-wide)', margin: '0 0 var(--memox-space-2) var(--memox-space-1)' }}>REPEAT</div>
        <div style={{ display: 'flex', gap: 'var(--memox-space-2)', flexWrap: 'wrap' }}>
          {WEEKDAYS.map((d, i) => <MxChip key={d} label={d} selected={on} node={'reminder/day-' + i} />)}
        </div>
      </div>
    </MxScaffold>
  );

  if (state === 'time-picker') {
    return (
      <React.Fragment>
        {base}
        <window.Scrim node="reminder/picker-scrim">
          <window.Sheet title="Pick reminder time" node="reminder/picker-sheet">
            <div style={{ display: 'flex', gap: 'var(--memox-space-3)', alignItems: 'center', justifyContent: 'center' }}>
              <TimeCol values={['11', '12', '13', '14', '15']} sel="13" />
              <div style={{ fontSize: 'var(--memox-font-size-xl)', fontWeight: 'var(--memox-font-weight-extrabold)' }}>:</div>
              <TimeCol values={['00', '15', '30', '45']} sel="00" />
            </div>
            <div style={{ marginTop: 'var(--memox-space-2)' }}><MxButton variant="primary" block node="reminder/picker-done">Done</MxButton></div>
          </window.Sheet>
        </window.Scrim>
      </React.Fragment>
    );
  }

  return base;
}

window.Reminder = Reminder;
})();
