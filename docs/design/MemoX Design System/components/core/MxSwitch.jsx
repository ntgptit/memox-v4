import React from 'react';

/* MxSwitch — on/off toggle. Base class: switch */
export function MxSwitch({ checked = false, disabled = false, onChange, node }) {
  const cls = ['switch'];
  if (checked) cls.push('switch--on');
  if (disabled) cls.push('switch--disabled');
  return (
    <button type="button" role="switch" aria-checked={checked} className={cls.join(' ')} data-mx-node={node} onClick={() => onChange && onChange(!checked)}>
      <span className="switch__thumb" />
    </button>
  );
}
