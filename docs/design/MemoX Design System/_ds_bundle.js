/* @ds-bundle: {"format":3,"namespace":"MemoXDesignSystem_2ffa54","components":[{"name":"MxAvatar","sourcePath":"components/core/MxAvatar.jsx"},{"name":"MxBadge","sourcePath":"components/core/MxBadge.jsx"},{"name":"MxButton","sourcePath":"components/core/MxButton.jsx"},{"name":"MxChip","sourcePath":"components/core/MxChip.jsx"},{"name":"MxSegmentedControl","sourcePath":"components/core/MxSegmentedControl.jsx"},{"name":"MxSwitch","sourcePath":"components/core/MxSwitch.jsx"},{"name":"MxBottomNav","sourcePath":"components/navigation/MxBottomNav.jsx"},{"name":"MxFab","sourcePath":"components/navigation/MxFab.jsx"},{"name":"MxIconButton","sourcePath":"components/navigation/MxIconButton.jsx"},{"name":"MxSearchDock","sourcePath":"components/navigation/MxSearchDock.jsx"},{"name":"MxAppBar","sourcePath":"components/surfaces/MxAppBar.jsx"},{"name":"MxCard","sourcePath":"components/surfaces/MxCard.jsx"},{"name":"MxIconTile","sourcePath":"components/surfaces/MxIconTile.jsx"},{"name":"MxScaffold","sourcePath":"components/surfaces/MxScaffold.jsx"},{"name":"MxSectionHeader","sourcePath":"components/surfaces/MxSectionHeader.jsx"}],"sourceHashes":{"components/core/MxAvatar.jsx":"7317a36b6229","components/core/MxBadge.jsx":"07bf386675b0","components/core/MxButton.jsx":"e7df637928c8","components/core/MxChip.jsx":"94c968ebe110","components/core/MxSegmentedControl.jsx":"c31a80156edc","components/core/MxSwitch.jsx":"961a8aa03df7","components/navigation/MxBottomNav.jsx":"45cf8267b4c2","components/navigation/MxFab.jsx":"e9bdd32a0d56","components/navigation/MxIconButton.jsx":"287ab5465892","components/navigation/MxSearchDock.jsx":"12744af28c7d","components/surfaces/MxAppBar.jsx":"536c62bb1ad5","components/surfaces/MxCard.jsx":"a1a45a8ad9c4","components/surfaces/MxIconTile.jsx":"4ce6994a06ec","components/surfaces/MxScaffold.jsx":"82f9aec7366b","components/surfaces/MxSectionHeader.jsx":"405ffc6fd4d9","ui_kits/memox-app/Dashboard.jsx":"3a13dc65670c","ui_kits/memox-app/Library.jsx":"0873f8676427","ui_kits/memox-app/Settings.jsx":"b818c18bd028","ui_kits/memox-app/StudySession.jsx":"520115786bdc","ui_kits/memox-app/kit-helpers.jsx":"de13ea25cdb5"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.MemoXDesignSystem_2ffa54 = window.MemoXDesignSystem_2ffa54 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/MxAvatar.jsx
try { (() => {
/* MxAvatar — user / entity avatar. Base class: avatar */
function MxAvatar({
  name,
  src,
  size,
  variant,
  ring = false,
  node
}) {
  const cls = ['avatar'];
  if (size) cls.push('avatar--' + size);
  if (variant) cls.push('avatar--' + variant);
  if (ring) cls.push('avatar--ring');
  const initials = name ? name.split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase() : '';
  return /*#__PURE__*/React.createElement("span", {
    className: cls.join(' '),
    "data-mx-node": node
  }, src ? /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: name || ''
  }) : initials);
}
Object.assign(__ds_scope, { MxAvatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/MxAvatar.jsx", error: String((e && e.message) || e) }); }

// components/core/MxBadge.jsx
try { (() => {
/* MxBadge — count / status badge. Base class: badge */
function MxBadge({
  children,
  tone,
  soft = false,
  dot = false,
  node
}) {
  const cls = ['badge'];
  if (tone) cls.push('badge--' + tone);
  if (soft) cls.push('badge--soft');
  if (dot) cls.push('badge--dot');
  return /*#__PURE__*/React.createElement("span", {
    className: cls.join(' '),
    "data-mx-node": node
  }, dot ? null : children);
}
Object.assign(__ds_scope, { MxBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/MxBadge.jsx", error: String((e && e.message) || e) }); }

// components/core/MxButton.jsx
try { (() => {
/* MxButton — text button. Base class: btn (modifiers primary/secondary/outline/ghost) */
function MxButton({
  variant = 'primary',
  size,
  icon,
  trailingIcon,
  block = false,
  danger = false,
  disabled = false,
  node,
  className = '',
  children,
  onClick,
  type = 'button'
}) {
  const cls = ['btn', variant];
  if (size) cls.push('btn--' + size);
  if (block) cls.push('btn--block');
  if (danger) cls.push('danger');
  if (className) cls.push(className);
  return /*#__PURE__*/React.createElement("button", {
    type: type,
    className: cls.join(' '),
    "data-mx-node": node,
    disabled: disabled,
    onClick: onClick
  }, icon ? /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded"
  }, icon) : null, children ? /*#__PURE__*/React.createElement("span", null, children) : null, trailingIcon ? /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded"
  }, trailingIcon) : null);
}
Object.assign(__ds_scope, { MxButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/MxButton.jsx", error: String((e && e.message) || e) }); }

// components/core/MxChip.jsx
try { (() => {
/* MxChip — filter / choice chip. Base class: chip */
function MxChip({
  label,
  icon,
  selected = false,
  variant,
  node,
  onClick,
  children
}) {
  const cls = ['chip'];
  if (selected) cls.push('chip--selected');
  if (variant) cls.push('chip--' + variant);
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    className: cls.join(' '),
    "data-mx-node": node,
    onClick: onClick
  }, icon ? /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded"
  }, icon) : null, label || children);
}
Object.assign(__ds_scope, { MxChip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/MxChip.jsx", error: String((e && e.message) || e) }); }

// components/core/MxSegmentedControl.jsx
try { (() => {
/* MxSegmentedControl — segmented toggle. Base class: segmented */
function MxSegmentedControl({
  segments = [],
  value,
  onChange,
  block = false,
  node
}) {
  const cls = ['segmented'];
  if (block) cls.push('segmented--block');
  return /*#__PURE__*/React.createElement("div", {
    className: cls.join(' '),
    "data-mx-node": node
  }, segments.map(s => {
    const v = typeof s === 'string' ? s : s.value;
    const label = typeof s === 'string' ? s : s.label;
    const icon = typeof s === 'object' ? s.icon : null;
    const active = v === value;
    return /*#__PURE__*/React.createElement("button", {
      key: v,
      type: "button",
      className: ['segmented__seg', active ? 'segmented__seg--active' : ''].filter(Boolean).join(' '),
      onClick: () => onChange && onChange(v)
    }, icon ? /*#__PURE__*/React.createElement("span", {
      className: "material-symbols-rounded"
    }, icon) : null, label);
  }));
}
Object.assign(__ds_scope, { MxSegmentedControl });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/MxSegmentedControl.jsx", error: String((e && e.message) || e) }); }

// components/core/MxSwitch.jsx
try { (() => {
/* MxSwitch — on/off toggle. Base class: switch */
function MxSwitch({
  checked = false,
  disabled = false,
  onChange,
  node
}) {
  const cls = ['switch'];
  if (checked) cls.push('switch--on');
  if (disabled) cls.push('switch--disabled');
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    role: "switch",
    "aria-checked": checked,
    className: cls.join(' '),
    "data-mx-node": node,
    onClick: () => onChange && onChange(!checked)
  }, /*#__PURE__*/React.createElement("span", {
    className: "switch__thumb"
  }));
}
Object.assign(__ds_scope, { MxSwitch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/MxSwitch.jsx", error: String((e && e.message) || e) }); }

// components/navigation/MxBottomNav.jsx
try { (() => {
/* MxBottomNav — bottom tab bar. Base class: bottom-nav */
function MxBottomNav({
  items = [],
  value,
  onChange,
  node
}) {
  return /*#__PURE__*/React.createElement("nav", {
    className: "bottom-nav",
    "data-mx-node": node
  }, items.map(it => {
    const active = it.id === value;
    return /*#__PURE__*/React.createElement("button", {
      key: it.id,
      type: "button",
      className: ['bottom-nav__item', active ? 'bottom-nav__item--active' : ''].filter(Boolean).join(' '),
      onClick: () => onChange && onChange(it.id)
    }, /*#__PURE__*/React.createElement("span", {
      className: "bottom-nav__icon"
    }, /*#__PURE__*/React.createElement("span", {
      className: "material-symbols-rounded"
    }, it.icon)), /*#__PURE__*/React.createElement("span", null, it.label));
  }));
}
Object.assign(__ds_scope, { MxBottomNav });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/MxBottomNav.jsx", error: String((e && e.message) || e) }); }

// components/navigation/MxFab.jsx
try { (() => {
/* MxFab — floating action button. Base class: fab */
function MxFab({
  icon,
  label,
  variant,
  round = false,
  node,
  onClick
}) {
  const cls = ['fab'];
  if (variant) cls.push('fab--' + variant);
  if (round || !label) cls.push('fab--round');
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    className: cls.join(' '),
    "data-mx-node": node,
    onClick: onClick
  }, icon ? /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded"
  }, icon) : null, label ? /*#__PURE__*/React.createElement("span", null, label) : null);
}
Object.assign(__ds_scope, { MxFab });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/MxFab.jsx", error: String((e && e.message) || e) }); }

// components/navigation/MxIconButton.jsx
try { (() => {
/* MxIconButton — icon-only button. Base class: icon-btn */
function MxIconButton({
  icon,
  variant,
  size,
  node,
  className = '',
  onClick,
  ariaLabel
}) {
  const cls = ['icon-btn'];
  if (variant) cls.push('icon-btn--' + variant);
  if (size === 'sm') cls.push('icon-btn--sm');
  if (className) cls.push(className);
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    className: cls.join(' '),
    "data-mx-node": node,
    onClick: onClick,
    "aria-label": ariaLabel || icon
  }, /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded"
  }, icon));
}
Object.assign(__ds_scope, { MxIconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/MxIconButton.jsx", error: String((e && e.message) || e) }); }

// components/navigation/MxSearchDock.jsx
try { (() => {
/* MxSearchDock — pill search field. Base class: search-dock */
function MxSearchDock({
  placeholder = 'Search',
  value,
  onChange,
  focused = false,
  flat = false,
  trailing,
  node
}) {
  const cls = ['search-dock'];
  if (focused) cls.push('search-dock--focused');
  if (flat) cls.push('search-dock--flat');
  return /*#__PURE__*/React.createElement("div", {
    className: cls.join(' '),
    "data-mx-node": node
  }, /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded"
  }, "search"), /*#__PURE__*/React.createElement("input", {
    className: "search-dock__input",
    placeholder: placeholder,
    value: value,
    onChange: onChange
  }), trailing);
}
Object.assign(__ds_scope, { MxSearchDock });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/MxSearchDock.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/MxAppBar.jsx
try { (() => {
/* MxAppBar — top app bar. Base class: appbar (modifier appbar-lg) */
function MxAppBar({
  title,
  eyebrow,
  large = false,
  leading,
  trailing,
  node,
  className = ''
}) {
  if (large) {
    return /*#__PURE__*/React.createElement("header", {
      className: ['appbar-lg', className].filter(Boolean).join(' '),
      "data-mx-node": node
    }, leading || trailing ? /*#__PURE__*/React.createElement("div", {
      className: "appbar-lg__row"
    }, leading, /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1
      }
    }), trailing) : null, eyebrow ? /*#__PURE__*/React.createElement("div", {
      className: "appbar-lg__eyebrow"
    }, eyebrow) : null, /*#__PURE__*/React.createElement("div", {
      className: "appbar-lg__title"
    }, title));
  }
  return /*#__PURE__*/React.createElement("header", {
    className: ['appbar', className].filter(Boolean).join(' '),
    "data-mx-node": node
  }, /*#__PURE__*/React.createElement("div", {
    className: "appbar__lead"
  }, leading), /*#__PURE__*/React.createElement("div", {
    className: "appbar__title"
  }, title), /*#__PURE__*/React.createElement("div", {
    className: "appbar__trail"
  }, trailing));
}
Object.assign(__ds_scope, { MxAppBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/MxAppBar.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/MxCard.jsx
try { (() => {
/* MxCard — surface container. Base class: card */
function MxCard({
  variant,
  interactive = false,
  padding,
  node,
  className = '',
  children,
  onClick,
  style
}) {
  const cls = ['card'];
  if (variant) cls.push('card--' + variant);
  if (interactive) cls.push('card--interactive');
  if (padding) cls.push('card--pad-' + padding);
  if (className) cls.push(className);
  return /*#__PURE__*/React.createElement("div", {
    className: cls.join(' '),
    "data-mx-node": node,
    onClick: onClick,
    style: style
  }, children);
}
Object.assign(__ds_scope, { MxCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/MxCard.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/MxIconTile.jsx
try { (() => {
/* MxIconTile — rounded color tile holding a glyph. Base class: icon-tile */
function MxIconTile({
  icon,
  tone,
  size,
  solid = false,
  node,
  className = ''
}) {
  const cls = ['icon-tile'];
  if (tone) cls.push('icon-tile--' + tone);
  if (size === 'lg') cls.push('icon-tile--lg');
  if (solid) cls.push('icon-tile--solid');
  if (className) cls.push(className);
  return /*#__PURE__*/React.createElement("span", {
    className: cls.join(' '),
    "data-mx-node": node
  }, /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded"
  }, icon));
}
Object.assign(__ds_scope, { MxIconTile });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/MxIconTile.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/MxScaffold.jsx
try { (() => {
/* MxScaffold — phone app shell. Base class: app */
function MxScaffold({
  appBar,
  bottomNav,
  fab,
  children,
  flush = false,
  node,
  className = '',
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: ['app', className].filter(Boolean).join(' '),
    "data-mx-node": node,
    style: style
  }, appBar, /*#__PURE__*/React.createElement("div", {
    className: ['app__body', flush ? 'app__body--flush' : ''].filter(Boolean).join(' ')
  }, children), fab ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      right: 'var(--memox-gutter)',
      bottom: 'calc(var(--memox-bottom-nav-height) + var(--memox-space-4))',
      zIndex: 11
    }
  }, fab) : null, bottomNav);
}
Object.assign(__ds_scope, { MxScaffold });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/MxScaffold.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/MxSectionHeader.jsx
try { (() => {
/* MxSectionHeader — list/section label row. Base class: section-head */
function MxSectionHeader({
  title,
  caption,
  action,
  onAction,
  node
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "section-head",
    "data-mx-node": node
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-head__text"
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-head__title"
  }, title), caption ? /*#__PURE__*/React.createElement("div", {
    className: "section-head__caption"
  }, caption) : null), action ? /*#__PURE__*/React.createElement("span", {
    className: "section-head__action",
    onClick: onAction,
    role: "button",
    tabIndex: 0
  }, action) : null);
}
Object.assign(__ds_scope, { MxSectionHeader });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/MxSectionHeader.jsx", error: String((e && e.message) || e) }); }

// ui_kits/memox-app/Dashboard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* MemoX — Dashboard (Today) screen. States: loaded · empty · loading */
(function () {
  const NS = window.MemoXDesignSystem_2ffa54;
  const {
    MxScaffold,
    MxAppBar,
    MxBottomNav,
    MxCard,
    MxSectionHeader,
    MxButton,
    MxIconButton,
    MxAvatar,
    MxFab,
    MxBadge,
    MxIconTile
  } = NS;
  const NAV = [{
    id: 'home',
    label: 'Today',
    icon: 'today'
  }, {
    id: 'library',
    label: 'Library',
    icon: 'style'
  }, {
    id: 'add',
    label: 'Add',
    icon: 'add_circle'
  }, {
    id: 'stats',
    label: 'Stats',
    icon: 'insights'
  }, {
    id: 'me',
    label: 'Profile',
    icon: 'person'
  }];
  const DECKS = [{
    icon: 'translate',
    tone: 'accent',
    name: 'Japanese N5',
    meta: 'Kanji · 320 cards',
    due: 48,
    progress: 72
  }, {
    icon: 'functions',
    tone: 'success',
    name: 'Calculus II',
    meta: 'Derivatives · 140 cards',
    due: 12,
    progress: 54
  }, {
    icon: 'biotech',
    tone: 'warning',
    name: 'Cell Biology',
    meta: 'Midterm prep · 86 cards',
    due: 23,
    progress: 38
  }];
  function Bar() {
    return /*#__PURE__*/React.createElement(MxAppBar, {
      large: true,
      eyebrow: "Tuesday \xB7 27 June",
      title: "Good evening, Linh",
      trailing: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "notifications",
        node: "dashboard/notifications"
      }), /*#__PURE__*/React.createElement(MxAvatar, {
        name: "Linh Tran",
        size: "sm"
      })),
      node: "dashboard/appbar"
    });
  }
  function Dashboard({
    state = 'loaded'
  }) {
    const nav = /*#__PURE__*/React.createElement(MxBottomNav, {
      items: NAV,
      value: "home",
      node: "shell/bottom-nav"
    });
    if (state === 'empty') {
      return /*#__PURE__*/React.createElement(MxScaffold, {
        node: "dashboard/screen",
        appBar: /*#__PURE__*/React.createElement(MxAppBar, {
          large: true,
          eyebrow: "Welcome to MemoX",
          title: "Let's get started",
          node: "dashboard/appbar"
        }),
        bottomNav: nav
      }, /*#__PURE__*/React.createElement(window.EmptyState, {
        node: "dashboard/empty",
        icon: "auto_stories",
        title: "No decks yet",
        text: "Create a deck and add a few cards \u2014 your daily reviews show up here.",
        action: /*#__PURE__*/React.createElement(MxButton, {
          variant: "primary",
          icon: "add",
          node: "dashboard/create-first"
        }, "Create your first deck")
      }));
    }
    if (state === 'loading') {
      const S = window.Skeleton;
      return /*#__PURE__*/React.createElement(MxScaffold, {
        node: "dashboard/screen",
        appBar: /*#__PURE__*/React.createElement(Bar, null),
        bottomNav: nav
      }, /*#__PURE__*/React.createElement(MxCard, null, /*#__PURE__*/React.createElement(S, {
        w: "40%",
        h: 12
      }), /*#__PURE__*/React.createElement(S, {
        w: "55%",
        h: 34,
        style: {
          marginTop: 6
        }
      }), /*#__PURE__*/React.createElement(S, {
        w: "70%",
        h: 12,
        style: {
          marginTop: 10
        }
      })), /*#__PURE__*/React.createElement(S, {
        w: "45%",
        h: 16
      }), /*#__PURE__*/React.createElement(MxCard, null, [0, 1, 2].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          gap: 14,
          alignItems: 'center',
          marginBottom: i < 2 ? 18 : 0
        }
      }, /*#__PURE__*/React.createElement(S, {
        w: 48,
        h: 48,
        r: 16
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1
        }
      }, /*#__PURE__*/React.createElement(S, {
        w: "60%",
        h: 14
      }), /*#__PURE__*/React.createElement(S, {
        w: "40%",
        h: 10,
        style: {
          marginTop: 8
        }
      }))))));
    }

    // loaded
    return /*#__PURE__*/React.createElement(MxScaffold, {
      node: "dashboard/screen",
      appBar: /*#__PURE__*/React.createElement(Bar, null),
      bottomNav: nav,
      fab: /*#__PURE__*/React.createElement(MxFab, {
        icon: "bolt",
        label: "Review",
        node: "dashboard/quick-review"
      })
    }, /*#__PURE__*/React.createElement(MxCard, {
      variant: "primary",
      node: "dashboard/due-summary"
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'flex-start'
      }
    }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-sm)',
        fontWeight: 700,
        opacity: .9,
        letterSpacing: '.06em'
      }
    }, "DUE NOW"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 38,
        fontWeight: 800,
        lineHeight: 1,
        margin: '6px 0'
      }
    }, "83"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-sm)',
        opacity: .9
      }
    }, "cards across 3 decks")), /*#__PURE__*/React.createElement("span", {
      className: "material-symbols-rounded",
      style: {
        fontSize: 30,
        opacity: .9
      }
    }, "schedule")), /*#__PURE__*/React.createElement(MxButton, {
      variant: "contrast",
      icon: "play_arrow",
      block: true,
      node: "dashboard/start-review"
    }, "Start review")), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'grid',
        gridTemplateColumns: '1fr 1fr',
        gap: 'var(--memox-space-3)'
      }
    }, /*#__PURE__*/React.createElement(MxCard, {
      variant: "primary-soft",
      padding: "sm",
      node: "dashboard/streak"
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 10
      }
    }, /*#__PURE__*/React.createElement("span", {
      className: "material-symbols-rounded",
      style: {
        fontSize: 26
      }
    }, "local_fire_department"), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 22,
        fontWeight: 800,
        lineHeight: 1
      }
    }, "12"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 12,
        opacity: .85
      }
    }, "day streak")))), /*#__PURE__*/React.createElement(MxCard, {
      variant: "muted",
      padding: "sm",
      node: "dashboard/accuracy"
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 10
      }
    }, /*#__PURE__*/React.createElement("span", {
      className: "material-symbols-rounded",
      style: {
        fontSize: 26,
        color: 'var(--memox-success)'
      }
    }, "check_circle"), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 22,
        fontWeight: 800,
        lineHeight: 1
      }
    }, "94%"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 12,
        color: 'var(--memox-text-secondary)'
      }
    }, "accuracy"))))), /*#__PURE__*/React.createElement(MxSectionHeader, {
      title: "Continue studying",
      caption: "3 decks due today",
      action: "See all",
      node: "dashboard/decks-head"
    }), /*#__PURE__*/React.createElement(MxCard, {
      node: "dashboard/deck-list",
      style: {
        gap: 'var(--memox-space-5)'
      }
    }, DECKS.map((d, i) => /*#__PURE__*/React.createElement(window.DeckRow, _extends({
      key: i
    }, d, {
      node: 'dashboard/deck-' + i
    })))));
  }
  window.Dashboard = Dashboard;
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/memox-app/Dashboard.jsx", error: String((e && e.message) || e) }); }

// ui_kits/memox-app/Library.jsx
try { (() => {
/* MemoX — Library screen. States: loaded · no-results · empty · loading */
(function () {
  const NS = window.MemoXDesignSystem_2ffa54;
  const {
    MxScaffold,
    MxAppBar,
    MxBottomNav,
    MxCard,
    MxButton,
    MxIconButton,
    MxSearchDock,
    MxChip,
    MxFab,
    MxIconTile
  } = NS;
  const NAV = [{
    id: 'home',
    label: 'Today',
    icon: 'today'
  }, {
    id: 'library',
    label: 'Library',
    icon: 'style'
  }, {
    id: 'add',
    label: 'Add',
    icon: 'add_circle'
  }, {
    id: 'stats',
    label: 'Stats',
    icon: 'insights'
  }, {
    id: 'me',
    label: 'Profile',
    icon: 'person'
  }];
  const FILTERS = ['All', 'Due', 'Learning', 'Mastered'];
  const DECKS = [{
    icon: 'translate',
    tone: 'accent',
    name: 'Japanese N5',
    meta: '320 cards · 48 due',
    due: 48,
    progress: 72
  }, {
    icon: 'functions',
    tone: 'success',
    name: 'Calculus II',
    meta: '140 cards · 12 due',
    due: 12,
    progress: 54
  }, {
    icon: 'biotech',
    tone: 'warning',
    name: 'Cell Biology',
    meta: '86 cards · 23 due',
    due: 23,
    progress: 38
  }, {
    icon: 'gavel',
    tone: 'error',
    name: 'Legal Latin',
    meta: '64 cards · all done',
    due: 0,
    progress: 100
  }, {
    icon: 'public',
    tone: null,
    name: 'World Capitals',
    meta: '195 cards · 6 due',
    due: 6,
    progress: 88
  }];
  function Bar() {
    return /*#__PURE__*/React.createElement(MxAppBar, {
      title: "Library",
      trailing: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "swap_vert",
        node: "library/sort"
      }), /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "more_vert",
        node: "library/menu"
      })),
      node: "library/appbar"
    });
  }
  function Filters({
    active
  }) {
    return /*#__PURE__*/React.createElement("div", {
      "data-mx-node": "library/filters",
      style: {
        display: 'flex',
        gap: 'var(--memox-space-2)',
        overflowX: 'auto',
        paddingBottom: 2
      }
    }, FILTERS.map(f => /*#__PURE__*/React.createElement(MxChip, {
      key: f,
      label: f,
      selected: f === active,
      node: 'library/filter-' + f.toLowerCase()
    })));
  }
  function Library({
    state = 'loaded'
  }) {
    const nav = /*#__PURE__*/React.createElement(MxBottomNav, {
      items: NAV,
      value: "library",
      node: "shell/bottom-nav"
    });
    const fab = /*#__PURE__*/React.createElement(MxFab, {
      icon: "add",
      label: "New deck",
      node: "library/new-deck"
    });
    if (state === 'empty') {
      return /*#__PURE__*/React.createElement(MxScaffold, {
        node: "library/screen",
        appBar: /*#__PURE__*/React.createElement(Bar, null),
        bottomNav: nav
      }, /*#__PURE__*/React.createElement(window.EmptyState, {
        node: "library/empty",
        icon: "style",
        title: "Your library is empty",
        text: "Decks you create or import will live here. Start with a blank deck or import a CSV.",
        action: /*#__PURE__*/React.createElement(MxButton, {
          variant: "primary",
          icon: "add",
          node: "library/empty-create"
        }, "New deck")
      }));
    }
    if (state === 'no-results') {
      return /*#__PURE__*/React.createElement(MxScaffold, {
        node: "library/screen",
        appBar: /*#__PURE__*/React.createElement(Bar, null),
        bottomNav: nav
      }, /*#__PURE__*/React.createElement(MxSearchDock, {
        value: "kanjii",
        focused: true,
        node: "library/search-dock",
        trailing: /*#__PURE__*/React.createElement(MxIconButton, {
          icon: "close",
          size: "sm",
          node: "library/search-clear"
        })
      }), /*#__PURE__*/React.createElement(Filters, {
        active: "All"
      }), /*#__PURE__*/React.createElement(window.EmptyState, {
        node: "library/no-results",
        icon: "search_off",
        tone: "warning",
        title: "No matches",
        text: 'Nothing matched "kanjii". Check the spelling or try a different term.',
        action: /*#__PURE__*/React.createElement(MxButton, {
          variant: "outline",
          icon: "restart_alt",
          node: "library/clear-search"
        }, "Clear search")
      }));
    }
    if (state === 'loading') {
      const S = window.Skeleton;
      return /*#__PURE__*/React.createElement(MxScaffold, {
        node: "library/screen",
        appBar: /*#__PURE__*/React.createElement(Bar, null),
        bottomNav: nav
      }, /*#__PURE__*/React.createElement(S, {
        h: 52,
        r: 999
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          gap: 8
        }
      }, [44, 38, 60, 56].map((w, i) => /*#__PURE__*/React.createElement(S, {
        key: i,
        w: w,
        h: 34,
        r: 999
      }))), [0, 1, 2, 3].map(i => /*#__PURE__*/React.createElement(MxCard, {
        key: i,
        padding: "sm"
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          gap: 14,
          alignItems: 'center'
        }
      }, /*#__PURE__*/React.createElement(S, {
        w: 48,
        h: 48,
        r: 16
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1
        }
      }, /*#__PURE__*/React.createElement(S, {
        w: "55%",
        h: 14
      }), /*#__PURE__*/React.createElement(S, {
        w: "35%",
        h: 10,
        style: {
          marginTop: 8
        }
      }))))));
    }

    // loaded
    return /*#__PURE__*/React.createElement(MxScaffold, {
      node: "library/screen",
      appBar: /*#__PURE__*/React.createElement(Bar, null),
      bottomNav: nav,
      fab: fab
    }, /*#__PURE__*/React.createElement(MxSearchDock, {
      placeholder: "Search decks & cards",
      node: "library/search-dock",
      trailing: /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "tune",
        size: "sm",
        node: "library/filter-btn"
      })
    }), /*#__PURE__*/React.createElement(Filters, {
      active: "All"
    }), DECKS.map((d, i) => /*#__PURE__*/React.createElement(MxCard, {
      key: i,
      padding: "sm",
      interactive: true,
      node: 'library/deck-' + i
    }, /*#__PURE__*/React.createElement(window.DeckRow, d))));
  }
  window.Library = Library;
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/memox-app/Library.jsx", error: String((e && e.message) || e) }); }

// ui_kits/memox-app/Settings.jsx
try { (() => {
/* MemoX — Settings screen. State: loaded */
(function () {
  const NS = window.MemoXDesignSystem_2ffa54;
  const {
    MxScaffold,
    MxAppBar,
    MxBottomNav,
    MxCard,
    MxIconButton,
    MxAvatar,
    MxSwitch,
    MxSegmentedControl,
    MxIconTile,
    MxBadge,
    MxButton
  } = NS;
  const NAV = [{
    id: 'home',
    label: 'Today',
    icon: 'today'
  }, {
    id: 'library',
    label: 'Library',
    icon: 'style'
  }, {
    id: 'add',
    label: 'Add',
    icon: 'add_circle'
  }, {
    id: 'stats',
    label: 'Stats',
    icon: 'insights'
  }, {
    id: 'me',
    label: 'Profile',
    icon: 'person'
  }];
  function Row({
    icon,
    tone,
    title,
    sub,
    trailing,
    node,
    last
  }) {
    const {
      MxIconTile
    } = NS;
    return /*#__PURE__*/React.createElement("div", {
      "data-mx-node": node,
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 'var(--memox-space-4)',
        paddingBottom: last ? 0 : 'var(--memox-space-4)',
        marginBottom: last ? 0 : 'var(--memox-space-4)',
        borderBottom: last ? 'none' : '1px solid var(--memox-divider)'
      }
    }, /*#__PURE__*/React.createElement(MxIconTile, {
      icon: icon,
      tone: tone
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        minWidth: 0
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        fontWeight: 700,
        fontSize: 'var(--memox-font-size-base)'
      }
    }, title), sub ? /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-sm)',
        color: 'var(--memox-text-secondary)',
        marginTop: 2
      }
    }, sub) : null), trailing);
  }
  function Settings({
    state = 'loaded'
  }) {
    const [dark, setDark] = React.useState(false);
    const [remind, setRemind] = React.useState(true);
    const [sound, setSound] = React.useState(false);
    const [pace, setPace] = React.useState('20');
    return /*#__PURE__*/React.createElement(MxScaffold, {
      node: "settings/screen",
      appBar: /*#__PURE__*/React.createElement(MxAppBar, {
        large: true,
        title: "Settings",
        node: "settings/appbar"
      }),
      bottomNav: /*#__PURE__*/React.createElement(MxBottomNav, {
        items: NAV,
        value: "me",
        node: "shell/bottom-nav"
      })
    }, /*#__PURE__*/React.createElement(MxCard, {
      node: "settings/profile",
      style: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 'var(--memox-space-4)'
      }
    }, /*#__PURE__*/React.createElement(MxAvatar, {
      name: "Linh Tran",
      size: "lg",
      ring: true
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        minWidth: 0
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        fontWeight: 800,
        fontSize: 'var(--memox-font-size-md)'
      }
    }, "Linh Tran"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-sm)',
        color: 'var(--memox-text-secondary)'
      }
    }, "linh@memox.app")), /*#__PURE__*/React.createElement(MxBadge, {
      tone: "success",
      soft: true
    }, "PRO")), /*#__PURE__*/React.createElement("div", {
      "data-mx-node": "settings/group-prefs"
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-sm)',
        fontWeight: 700,
        color: 'var(--memox-text-tertiary)',
        letterSpacing: '.04em',
        margin: '0 0 8px 4px',
        textTransform: 'uppercase'
      }
    }, "Preferences"), /*#__PURE__*/React.createElement(MxCard, null, /*#__PURE__*/React.createElement(Row, {
      icon: "dark_mode",
      title: "Dark mode",
      sub: "Match study time of day",
      node: "settings/dark-mode",
      trailing: /*#__PURE__*/React.createElement(MxSwitch, {
        checked: dark,
        onChange: setDark,
        node: "settings/dark-mode-switch"
      })
    }), /*#__PURE__*/React.createElement(Row, {
      icon: "notifications",
      tone: "warning",
      title: "Daily reminder",
      sub: "Every day at 8:00 PM",
      node: "settings/reminder",
      trailing: /*#__PURE__*/React.createElement(MxSwitch, {
        checked: remind,
        onChange: setRemind,
        node: "settings/reminder-switch"
      })
    }), /*#__PURE__*/React.createElement(Row, {
      icon: "volume_up",
      tone: "accent",
      title: "Sound effects",
      node: "settings/sound",
      last: true,
      trailing: /*#__PURE__*/React.createElement(MxSwitch, {
        checked: sound,
        onChange: setSound,
        node: "settings/sound-switch"
      })
    }))), /*#__PURE__*/React.createElement("div", {
      "data-mx-node": "settings/group-study"
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-sm)',
        fontWeight: 700,
        color: 'var(--memox-text-tertiary)',
        letterSpacing: '.04em',
        margin: '0 0 8px 4px',
        textTransform: 'uppercase'
      }
    }, "Study"), /*#__PURE__*/React.createElement(MxCard, {
      style: {
        gap: 'var(--memox-space-4)'
      }
    }, /*#__PURE__*/React.createElement(Row, {
      icon: "bolt",
      tone: "success",
      title: "New cards / day",
      sub: "Across all decks",
      node: "settings/pace",
      last: true,
      trailing: null
    }), /*#__PURE__*/React.createElement(MxSegmentedControl, {
      value: pace,
      onChange: setPace,
      block: true,
      node: "settings/pace-control",
      segments: [{
        value: '10',
        label: '10'
      }, {
        value: '20',
        label: '20'
      }, {
        value: '40',
        label: '40'
      }]
    }))), /*#__PURE__*/React.createElement("div", {
      "data-mx-node": "settings/group-about"
    }, /*#__PURE__*/React.createElement(MxCard, {
      padding: "sm"
    }, /*#__PURE__*/React.createElement(Row, {
      icon: "help",
      title: "Help & feedback",
      node: "settings/help",
      trailing: /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "chevron_right",
        node: "settings/help-go"
      })
    }), /*#__PURE__*/React.createElement(Row, {
      icon: "logout",
      tone: "error",
      title: "Sign out",
      node: "settings/signout",
      last: true,
      trailing: /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "chevron_right",
        node: "settings/signout-go"
      })
    }))));
  }
  window.Settings = Settings;
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/memox-app/Settings.jsx", error: String((e && e.message) || e) }); }

// ui_kits/memox-app/StudySession.jsx
try { (() => {
/* MemoX — Study Session screen. States: front · back · done */
(function () {
  const NS = window.MemoXDesignSystem_2ffa54;
  const {
    MxScaffold,
    MxAppBar,
    MxCard,
    MxButton,
    MxIconButton,
    MxIconTile,
    MxChip
  } = NS;
  function Bar({
    index,
    total
  }) {
    return /*#__PURE__*/React.createElement(MxAppBar, {
      node: "study-session/appbar",
      leading: /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "close",
        node: "study-session/close"
      }),
      title: /*#__PURE__*/React.createElement("div", {
        "data-mx-node": "study-session/progress",
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: 12
        }
      }, /*#__PURE__*/React.createElement(window.ProgressBar, {
        value: total ? index / total * 100 : 0,
        height: 8
      }), /*#__PURE__*/React.createElement("span", {
        style: {
          fontSize: 'var(--memox-font-size-sm)',
          fontWeight: 700,
          color: 'var(--memox-text-secondary)',
          whiteSpace: 'nowrap'
        }
      }, index, "/", total)),
      trailing: /*#__PURE__*/React.createElement(MxIconButton, {
        icon: "more_horiz",
        node: "study-session/options"
      })
    });
  }
  const RATINGS = [{
    id: 'again',
    label: 'Again',
    sub: '<1m',
    bg: 'var(--memox-error-soft)',
    fg: 'var(--memox-on-error-soft)'
  }, {
    id: 'hard',
    label: 'Hard',
    sub: '8m',
    bg: 'var(--memox-warning-soft)',
    fg: 'var(--memox-on-warning-soft)'
  }, {
    id: 'good',
    label: 'Good',
    sub: '1d',
    bg: 'var(--memox-success-soft)',
    fg: 'var(--memox-on-success-soft)'
  }, {
    id: 'easy',
    label: 'Easy',
    sub: '4d',
    bg: 'var(--memox-primary-soft)',
    fg: 'var(--memox-on-primary-soft)'
  }];
  function Flashcard({
    revealed
  }) {
    return /*#__PURE__*/React.createElement(MxCard, {
      node: "study-session/card",
      style: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        textAlign: 'center',
        gap: 'var(--memox-space-5)',
        minHeight: 320
      }
    }, /*#__PURE__*/React.createElement(MxChip, {
      label: "Japanese N5",
      variant: "ghost",
      node: "study-session/deck-tag"
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 52,
        fontWeight: 800,
        letterSpacing: '-.02em'
      }
    }, "\u52C9\u5F37"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-md)',
        color: 'var(--memox-text-secondary)'
      }
    }, "\u3079\u3093\u304D\u3087\u3046"), revealed ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
      style: {
        width: 56,
        height: 2,
        background: 'var(--memox-divider)',
        borderRadius: 2
      }
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-2xl)',
        fontWeight: 700
      }
    }, "study"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-font-size-base)',
        color: 'var(--memox-text-secondary)',
        maxWidth: 220
      }
    }, "to study; diligence (suru-verb)")) : /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 6,
        color: 'var(--memox-text-tertiary)',
        fontSize: 'var(--memox-font-size-sm)',
        fontWeight: 600
      }
    }, /*#__PURE__*/React.createElement("span", {
      className: "material-symbols-rounded",
      style: {
        fontSize: 18
      }
    }, "touch_app"), " Tap to reveal answer"));
  }
  function StudySession({
    state = 'front'
  }) {
    if (state === 'done') {
      return /*#__PURE__*/React.createElement(MxScaffold, {
        node: "study-session/screen",
        appBar: /*#__PURE__*/React.createElement(Bar, {
          index: 40,
          total: 40
        })
      }, /*#__PURE__*/React.createElement(window.EmptyState, {
        node: "study-session/complete",
        icon: "celebration",
        tone: "success",
        title: "Session complete!",
        text: "You reviewed 40 cards in 9 minutes. Nice focus \u2014 come back tomorrow to keep your streak.",
        action: /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 10,
            width: 220
          }
        }, /*#__PURE__*/React.createElement(MxButton, {
          variant: "primary",
          icon: "done",
          block: true,
          node: "study-session/finish"
        }, "Finish"), /*#__PURE__*/React.createElement(MxButton, {
          variant: "ghost",
          icon: "replay",
          block: true,
          node: "study-session/again"
        }, "Study again"))
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'grid',
          gridTemplateColumns: '1fr 1fr 1fr',
          gap: 'var(--memox-space-3)'
        }
      }, [['40', 'reviewed'], ['94%', 'correct'], ['9m', 'time']].map(([n, l], i) => /*#__PURE__*/React.createElement(MxCard, {
        key: i,
        variant: "muted",
        padding: "sm",
        node: 'study-session/stat-' + i,
        style: {
          alignItems: 'center',
          gap: 2
        }
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          fontSize: 22,
          fontWeight: 800
        }
      }, n), /*#__PURE__*/React.createElement("div", {
        style: {
          fontSize: 12,
          color: 'var(--memox-text-secondary)'
        }
      }, l)))));
    }
    const revealed = state === 'back';
    return /*#__PURE__*/React.createElement(MxScaffold, {
      node: "study-session/screen",
      appBar: /*#__PURE__*/React.createElement(Bar, {
        index: 12,
        total: 40
      })
    }, /*#__PURE__*/React.createElement(Flashcard, {
      revealed: revealed
    }), revealed ? /*#__PURE__*/React.createElement("div", {
      "data-mx-node": "study-session/ratings",
      style: {
        display: 'grid',
        gridTemplateColumns: '1fr 1fr 1fr 1fr',
        gap: 'var(--memox-space-2)'
      }
    }, RATINGS.map(r => /*#__PURE__*/React.createElement("button", {
      key: r.id,
      "data-mx-node": 'study-session/rate-' + r.id,
      style: {
        border: 'none',
        cursor: 'pointer',
        borderRadius: 'var(--memox-radius-control)',
        padding: '12px 4px',
        background: r.bg,
        color: r.fg,
        fontFamily: 'inherit',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 2
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        fontWeight: 700,
        fontSize: 'var(--memox-font-size-base)'
      }
    }, r.label), /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 11,
        opacity: .8
      }
    }, r.sub)))) : /*#__PURE__*/React.createElement(MxButton, {
      variant: "primary",
      icon: "visibility",
      block: true,
      size: "lg",
      node: "study-session/reveal"
    }, "Show answer"));
  }
  window.StudySession = StudySession;
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/memox-app/StudySession.jsx", error: String((e && e.message) || e) }); }

// ui_kits/memox-app/kit-helpers.jsx
try { (() => {
/* MemoX UI-kit shared helpers — exported to window for screen modules. */
const NS = window.MemoXDesignSystem_2ffa54;
function ProgressBar({
  value = 0,
  tone,
  height = 8,
  node
}) {
  return /*#__PURE__*/React.createElement("div", {
    "data-mx-node": node,
    style: {
      height,
      borderRadius: 999,
      background: 'var(--memox-surface-sunken)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: '100%',
      width: value + '%',
      borderRadius: 999,
      background: tone || 'var(--memox-primary)',
      transition: 'width .3s ease'
    }
  }));
}
function Skeleton({
  w = '100%',
  h = 16,
  r = 8,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "mxg-skel",
    style: {
      width: w,
      height: h,
      borderRadius: r,
      ...style
    }
  });
}
function EmptyState({
  icon,
  tone,
  title,
  text,
  action,
  node
}) {
  const {
    MxIconTile
  } = NS;
  return /*#__PURE__*/React.createElement("div", {
    "data-mx-node": node,
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      textAlign: 'center',
      gap: 'var(--memox-space-4)',
      padding: 'var(--memox-space-8) var(--memox-space-4)'
    }
  }, /*#__PURE__*/React.createElement(MxIconTile, {
    icon: icon,
    tone: tone,
    size: "lg"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: '6px',
      maxWidth: 240
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-font-size-lg)',
      fontWeight: 800,
      letterSpacing: '-.02em'
    }
  }, title), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-font-size-base)',
      color: 'var(--memox-text-secondary)',
      lineHeight: 1.5
    }
  }, text)), action);
}

/* A deck list-row built only from Mx primitives + tokens. */
function DeckRow({
  icon,
  tone,
  name,
  meta,
  due,
  progress,
  node,
  onClick
}) {
  const {
    MxIconTile,
    MxBadge
  } = NS;
  return /*#__PURE__*/React.createElement("div", {
    "data-mx-node": node,
    onClick: onClick,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--memox-space-4)'
    }
  }, /*#__PURE__*/React.createElement(MxIconTile, {
    icon: icon,
    tone: tone
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 700,
      fontSize: 'var(--memox-font-size-base)',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-font-size-sm)',
      color: 'var(--memox-text-secondary)',
      marginTop: 2
    }
  }, meta), progress != null ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement(ProgressBar, {
    value: progress,
    height: 6
  })) : null), due != null ? /*#__PURE__*/React.createElement(MxBadge, {
    tone: due > 0 ? undefined : 'success',
    soft: true
  }, due > 0 ? due : '✓') : null);
}
Object.assign(window, {
  ProgressBar,
  Skeleton,
  EmptyState,
  DeckRow
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/memox-app/kit-helpers.jsx", error: String((e && e.message) || e) }); }

__ds_ns.MxAvatar = __ds_scope.MxAvatar;

__ds_ns.MxBadge = __ds_scope.MxBadge;

__ds_ns.MxButton = __ds_scope.MxButton;

__ds_ns.MxChip = __ds_scope.MxChip;

__ds_ns.MxSegmentedControl = __ds_scope.MxSegmentedControl;

__ds_ns.MxSwitch = __ds_scope.MxSwitch;

__ds_ns.MxBottomNav = __ds_scope.MxBottomNav;

__ds_ns.MxFab = __ds_scope.MxFab;

__ds_ns.MxIconButton = __ds_scope.MxIconButton;

__ds_ns.MxSearchDock = __ds_scope.MxSearchDock;

__ds_ns.MxAppBar = __ds_scope.MxAppBar;

__ds_ns.MxCard = __ds_scope.MxCard;

__ds_ns.MxIconTile = __ds_scope.MxIconTile;

__ds_ns.MxScaffold = __ds_scope.MxScaffold;

__ds_ns.MxSectionHeader = __ds_scope.MxSectionHeader;

})();
