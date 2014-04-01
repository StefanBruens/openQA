[
  Jobs => {
    id => 99927,
    priority => 45,
    result => { name => "none"},
    state => { name => "scheduled"},
    t_finished => undef,
    t_started => undef,
    test => "RAID0",
    test_branch => undef,
    worker_id => 0,
    settings => [
        { key => 'FLAVOR', value => 'DVD'},
        { key => 'QEMUCPU', value => 'qemu32'},
        { key => 'ARCH', value => 'i586'},
        { key => 'DISTRI', value => 'opensuse'},
        { key => 'INSTALLONLY', value => '1'},
        { key => 'BUILD', value => '0091'},
        { key => 'VERSION', value => '13.1'},
        { key => 'RAIDLEVEL', value => '0'},
        { key => 'DVD', value => '1'},
        { key => 'ISO', value => 'openSUSE-13.1-DVD-i586-Build0091-Media.iso'},
        { key => 'TEST', value => 'RAID0'},
        { key => 'DESKTOP', value => 'kde'},
        { key => 'ISO_MAXSIZE', value => '4700372992'}
    ]
  },
  Jobs => {
    id => 99928,
    priority => 46,
    result => { name => "none"},
    state => { name => "scheduled"},
    t_finished => undef,
    t_started => undef,
    test => "RAID1",
    test_branch => undef,
    worker_id => 0,
    settings => [
        { key => 'QEMUCPU', value => 'qemu32'},
        { key => 'FLAVOR', value => 'DVD'},
        { key => 'INSTALLONLY', value => '1'},
        { key => 'BUILD', value => '0091'},
        { key => 'DISTRI', value => 'opensuse'},
        { key => 'ARCH', value => 'i586'},
        { key => 'RAIDLEVEL', value => '1'},
        { key => 'DVD', value => '1'},
        { key => 'VERSION', value => '13.1'},
        { key => 'DESKTOP', value => 'kde'},
        { key => 'ISO_MAXSIZE', value => '4700372992'},
        { key => 'TEST', value => 'RAID1'},
        { key => 'ISO', value => 'openSUSE-13.1-DVD-i586-Build0091-Media.iso'},
    ]
  },
  Jobs => {
    id => 99937,
    priority => 35,
    result => { name => "passed"},
    state => { name => "done"},
    t_finished => time2str('%Y-%m-%d %H:%M:%S', time-536400, 'UTC'), # 149 hours ago
    t_started => time2str('%Y-%m-%d %H:%M:%S', time-540000, 'UTC'),  # 150 hours ago
    test => "kde",
    test_branch => undef,
    worker_id => 0,
    settings => [
        { key => 'DVD', value => '1'},
        { key => 'VERSION', value => '13.1'},
        { key => 'DESKTOP', value => 'kde'},
        { key => 'ISO_MAXSIZE', value => '4700372992'},
        { key => 'TEST', value => 'kde'},
        { key => 'ISO', value => 'openSUSE-13.1-DVD-i586-Build0091-Media.iso'},
        { key => 'QEMUCPU', value => 'qemu32'},
        { key => 'FLAVOR', value => 'DVD'},
        { key => 'BUILD', value => '0091'},
        { key => 'DISTRI', value => 'opensuse'},
        { key => 'ARCH', value => 'i586'},
    ]
  },
  Jobs => {
    id => 99938,
    priority => 36,
    result => { name => "failed"},
    state => { name => "done"},
    t_finished => time2str('%Y-%m-%d %H:%M:%S', time-3600, 'UTC'), # One hour ago
    t_started => time2str('%Y-%m-%d %H:%M:%S', time-7200, 'UTC'),  # Two hours ago
    test => "doc",
    test_branch => undef,
    worker_id => 0,
    settings => [
        { key => 'DVD', value => '1'},
        { key => 'VERSION', value => 'Factory'},
        { key => 'DESKTOP', value => 'kde'},
        { key => 'ISO_MAXSIZE', value => '4700372992'},
        { key => 'TEST', value => 'doc'},
        { key => 'ISO', value => 'openSUSE-Factory-DVD-x86_64-Build0048-Media.iso'},
        { key => 'QEMUCPU', value => 'qemu64'},
        { key => 'FLAVOR', value => 'DVD'},
        { key => 'BUILD', value => '0048'},
        { key => 'DISTRI', value => 'opensuse'},
        { key => 'ARCH', value => 'x86_64'},
    ]
  },
  Jobs => {
    id => 99946,
    priority => 35,
    result => { name => "passed"},
    state => { name => "done"},
    t_finished => time2str('%Y-%m-%d %H:%M:%S', time-10800, 'UTC'), # Three hour ago
    t_started => time2str('%Y-%m-%d %H:%M:%S', time-14400, 'UTC'),  # Four hours ago
    test => "textmode",
    test_branch => undef,
    worker_id => 0,
    settings => [
        { key => 'FLAVOR', value => 'DVD'},
        { key => 'QEMUCPU', value => 'qemu32'},
        { key => 'ARCH', value => 'i586'},
        { key => 'DISTRI', value => 'opensuse'},
        { key => 'BUILD', value => '0091'},
        { key => 'VERSION', value => '13.1'},
        { key => 'DVD', value => '1'},
        { key => 'VIDEOMODE', value => 'text'},
        { key => 'ISO', value => 'openSUSE-13.1-DVD-i586-Build0091-Media.iso'},
        { key => 'TEST', value => 'textmode'},
        { key => 'DESKTOP', value => 'textmode'},
        { key => 'ISO_MAXSIZE', value => '4700372992'},
    ]
  },
  Jobs => {
    id => 99963,
    priority => 35,
    result => { name => "none"},
    state => { name => "running"},
    t_finished => undef,
    t_started => time2str('%Y-%m-%d %H:%M:%S', time-600, 'UTC'), # 10 minutes ago
    test => "kde",
    test_branch => undef,
    worker_id => 1,
    settings => [
        { key => 'DESKTOP', value => 'kde'},
        { key => 'ISO_MAXSIZE', value => '4700372992'},
        { key => 'ISO', value => 'openSUSE-13.1-DVD-x86_64-Build0091-Media.iso'},
        { key => 'TEST', value => 'kde'},
        { key => 'VERSION', value => '13.1'},
        { key => 'DVD', value => '1'},
        { key => 'BUILD', value => '0091'},
        { key => 'ARCH', value => 'x86_64'},
        { key => 'DISTRI', value => 'opensuse'},
        { key => 'FLAVOR', value => 'DVD'},
    ]
  },
  Jobs => {
    id => 99981,
    priority => 50,
    result => { name => "none"},
    state => { name => "cancelled"},
    t_finished => undef,
    t_started => undef,
    test => "RAID0",
    test_branch => undef,
    worker_id => 0,
    settings => [
        { key => 'DESKTOP', value => 'gnome'},
        { key => 'ISO_MAXSIZE', value => '999999999'},
        { key => 'LIVECD', value => '1'},
        { key => 'ISO', value => 'openSUSE-13.1-GNOME-Live-i686-Build0091-Media.iso'},
        { key => 'TEST', value => 'RAID0'},
        { key => 'VERSION', value => '13.1'},
        { key => 'RAIDLEVEL', value => '0'},
        { key => 'INSTALLONLY', value => '1'},
        { key => 'BUILD', value => '0091'},
        { key => 'ARCH', value => 'i686'},
        { key => 'DISTRI', value => 'opensuse'},
        { key => 'GNOME', value => '1'},
        { key => 'QEMUCPU', value => 'qemu32'},
        { key => 'FLAVOR', value => 'GNOME-Live'},
    ]
  }
]
# Local Variables:
# mode: cperl
# cperl-close-paren-offset: -4
# cperl-continued-statement-offset: 4
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# cperl-tab-always-indent: t
# indent-tabs-mode: nil
# End:
# vim: set ts=4 sw=4 sts=4 et:
