export interface MxIconButtonProps {
  /** Material Symbols Rounded ligature name. */
  icon: string;
  /** Emphasis. `plain` is the base (omit the prop). @default 'plain' */
  variant?: 'plain' | 'filled' | 'primary';
  size?: 'sm';
  node?: string;
  className?: string;
  onClick?: () => void;
  ariaLabel?: string;
}

/** Icon-only round button for app-bar & toolbar actions. Base class `icon-btn`. */
export function MxIconButton(props: MxIconButtonProps): JSX.Element;
