# Copyright (C) 2019 SUSE Linux GmbH
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

package OpenQA::WebAPI::Plugin::ObsRsync::Controller;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::File;
use IPC::System::Simple qw(system $EXITVAL);

sub _home {
    my $self = shift;
    $self->app->config->{obs_rsync}->{home};
}

sub index {
    my $self   = shift;
    my $folder = $self->param('folder');
    return undef if $self->_check_and_render_error($folder);
    my $files
      = Mojo::File->new($self->_home)->list({dir => 1})->grep(sub { -d $_ })->map('basename')
      ->grep(qr/^(?!test|WebAPIPlugin|__pycache__)/)->to_array;

    $self->render('ObsRsync_index', folders => $files);
}

sub folder {
    my $self   = shift;
    my $folder = $self->param('folder');
    return undef if $self->_check_and_render_error($folder);

    my $full        = $self->_home;
    my $obs_project = $folder;
    my $files       = Mojo::File->new($full, $obs_project, '.run_last')->list({dir => 1})->map('basename');

    $self->render(
        'ObsRsync_folder',
        obs_project     => $obs_project,
        lst_files       => $files->grep(qr/files_.*\.lst/)->to_array,
        read_files_sh   => $files->grep(qr/read_files\.sh/)->join(),
        rsync_commands  => $files->grep(qr/rsync_.*\.cmd/)->to_array,
        rsync_sh        => $files->grep(qr/print_rsync.*\.sh/)->to_array,
        openqa_commands => $files->grep(qr/openqa\.cmd/)->to_array,
        openqa_sh       => $files->grep(qr/print_openqa\.sh/)->join());
}

sub logs {
    my $self   = shift;
    my $folder = $self->param('folder');
    return undef if $self->_check_and_render_error($folder);

    my $full = Mojo::File->new($self->_home, $folder);
    my $files
      = $full->list({dir => 1, hidden => 1})->map('basename')->grep(qr/\.run_.*/)->sort(sub { $b cmp $a })->to_array;
    $self->render('ObsRsync_logs', folder => $folder, full => $full->to_string, subfolders => $files);
}

sub logfiles {
    my $self      = shift;
    my $folder    = $self->param('folder');
    my $subfolder = $self->param('subfolder');
    return undef if $self->_check_and_render_error($folder, $subfolder);

    my $full  = Mojo::File->new($self->_home, $folder, $subfolder);
    my $files = $full->list({dir => 1})->map('basename')->sort->to_array;
    $self->render(
        'ObsRsync_logfiles',
        folder    => $folder,
        subfolder => $subfolder,
        full      => $full->to_string,
        files     => $files
    );
}

sub download_file {
    my $self      = shift;
    my $folder    = $self->param('folder');
    my $subfolder = $self->param('subfolder');
    my $filename  = $self->param('filename');
    return undef if $self->_check_and_render_error($folder, $subfolder, $filename);

    my $full = Mojo::File->new($self->_home, $folder, $subfolder);
    $self->reply->file($full->child($filename));
}

sub run {
    my $self   = shift;
    my $folder = $self->param('folder');
    return undef if $self->_check_and_render_error($folder);

    my @args = ($self->_home . "/rsync.sh", $folder);

    my $out;
    eval { $out = system([0], "bash", @args); 1 }
      or return $self->render(json => {output => $@, code => $EXITVAL}, status => 500);

    return $self->render(json => {output => $out, code => $EXITVAL}, status => 201);
}

sub _check_and_render_error {
    my $self = $_[0];
    my ($code, $message) = _check_error(@_);
    $self->render(json => {error => $message}, status => $code) if $code;
    return $code;
}

sub _check_error {
    my ($self, $project, $subfolder, $filename) = @_;
    my $home = $self->_home;
    return (405, "Home directory is not set") unless $home;
    return (405, "Home directory not found")  unless -d $home;
    return (400, "Project has invalid characters")   if $project   && $project =~ m!/!;
    return (400, "Subfolder has invalid characters") if $subfolder && $subfolder =~ m!/!;
    return (400, "Filename has invalid characters")  if $filename  && $filename =~ m!/!;

    return (404, "Invalid Project") if $project && !-d Mojo::File->new($home, $project);
    return 0;
}

1;
