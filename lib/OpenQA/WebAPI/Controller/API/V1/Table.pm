# Copyright (C) 2014 SUSE Linux Products GmbH
#           (C) 2015 SUSE LLC
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

package OpenQA::WebAPI::Controller::API::V1::Table;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Util 'trim';
use Try::Tiny;

=pod

=head1 NAME

OpenQA::WebAPI::Controller::API::V1::Table

=head1 SYNOPSIS

  use OpenQA::WebAPI::Controller::API::V1::Table;

=head1 DESCRIPTION

OpenQA API implementation for table handling.

Within this package, three types of tables are handled:

=over 4

=item Machines

Machines are defined by id, name, a backend and a description. Only the id and the backend are
always required.

=item Test Suites

Test Suites are defined by id, name and description. Only the name is always required.

=item Products

Products are defined by id, distri, version, arch, flavor and description. The distri,
version, arch and flavor parameters are always required.

=back

=head1 METHODS

=cut

my %tables = (
    Machines => {
        keys     => [['id'], ['name'],],
        cols     => ['id', 'name', 'backend', 'description'],
        required => ['name', 'backend'],
        defaults => {description => undef},
    },
    TestSuites => {
        keys     => [['id'], ['name'],],
        cols     => ['id', 'name', 'description'],
        required => ['name'],
        defaults => {description => undef},
    },
    Products => {
        keys     => [['id'], ['distri', 'version', 'arch', 'flavor'],],
        cols     => ['id', 'distri', 'version', 'arch', 'flavor', 'description'],
        required => ['distri', 'version', 'arch', 'flavor'],
        defaults => {description => "", name => ""},
    },
);

=over 4

=item list()

List the parameters of tables given its type (machine, test suite or product). If an
id is passed as an argument to the method, only information for the passed id is
returned, otherwise all structures of the same type defined in the system are
returned. For further information on the type of parameters associated to each
of the type of tables, check the OpenQA::WebAPI::Controller::API::V1::Table package
documentation.

=back

=cut

sub list {
    my ($self) = @_;

    my $table = $self->param("table");
    my %search;

    for my $key (@{$tables{$table}->{keys}}) {
        my $have = 1;
        for my $par (@$key) {
            $have &&= $self->param($par);
        }
        if ($have) {
            for my $par (@$key) {
                $search{$par} = $self->param($par);
            }
        }
    }

    my @result;
    eval {
        my $rs = $self->schema->resultset($table);
        @result = %search ? $rs->search(\%search) : $rs->all;
    };
    my $error = $@;
    if ($error) {
        return $self->render(json => {error => $error}, status => 404);
    }

    $self->render(
        json => {
            $table => [
                map {
                    my $row      = $_;
                    my @settings = sort { $a->key cmp $b->key } $row->settings;
                    my %hash     = (
                        (
                            map {
                                my $val = $row->get_column($_);
                                $val ? ($_ => $val) : ()
                            } @{$tables{$table}->{cols}}
                        ),
                        settings => [map { {key => $_->key, value => $_->value} } @settings]);
                    \%hash;
                } @result
            ]});
}

=over 4

=item create()

Creates a new table given its type (machine, test suite or product). Returns the
table id in a JSON block on success or a 400 code on error. For information on the
type of parameters associated to each of the type of tables, as well as which of those
parameters are required and validated when calling this method, check the
OpenQA::WebAPI::Controller::API::V1::Table package documentation.

=back

=cut

sub create {
    my ($self) = @_;
    my $table  = $self->param("table");
    my %entry  = %{$tables{$table}->{defaults}};

    my ($error_message, $settings, $keys) = $self->_prepare_settings($table, \%entry);
    return $self->render(json => {error => $error_message}, status => 400) if defined $error_message;

    $entry{settings} = $settings;

    my $error;
    my $id;

    try { $id = $self->schema->resultset($table)->create(\%entry)->id; } catch { $error = shift; };

    if ($error) {
        return $self->render(json => {error => $error}, status => 400);
    }
    $self->emit_event('openqa_table_create', {table => $table, %entry});
    $self->render(json => {id => $id});
}

=over 4

=item update()

Updates the parameters of a table given its type (machine, test suite or product). This
method will check the required parameters for the type of structure before updating. 
For information on the type of parameters associated to each of the type of tables, as
well as which of those parameters are required and validated when calling this method, check
the OpenQA::WebAPI::Controller::API::V1::Table package documentation. Returns a 404 error
code if the table is not found, 400 on other errors or a JSON block containing the number
of tables updated by the method on success.

=back

=cut

sub update {
    my ($self) = @_;
    my $table = $self->param("table");

    my $entry = {};
    my ($error_message, $settings, $keys) = $self->_prepare_settings($table, $entry);
    return $self->render(json => {error => $error_message}, status => 400) if defined $error_message;

    my $schema = $self->schema;

    my $error;
    my $ret;
    my $update = sub {
        my $rc = $schema->resultset($table)->find({id => $self->param('id')});
        if ($rc) {
            $rc->update($entry);
            for my $var (@$settings) {
                $rc->update_or_create_related('settings', $var);
            }
            $rc->delete_related('settings', {key => {'not in' => [@$keys]}});
            $ret = 1;
        }
        else {
            $ret = 0;
        }
    };

    try {
        $schema->txn_do($update);
    }
    catch {
        $error = shift;
        OpenQA::Utils::log_debug("Table update error: $error");
    };

    if ($ret && $ret == 0) {
        return $self->render(json => {error => 'Not found'}, status => 404);
    }
    if (!$ret) {
        return $self->render(json => {error => $error}, status => 400);
    }
    $self->emit_event('openqa_table_update', {table => $table, name => $entry->{name}, settings => $settings});
    $self->render(json => {result => int($ret)});
}

=over 4

=item destroy()

Deletes a table given its type (machine, test suite or product) and its id. Returns
a 404 error code when the table is not found, 400 on other errors or a JSON block
with the number of deleted tables on success.

=back

=cut

sub destroy {
    my ($self) = @_;

    my $table    = $self->param("table");
    my $schema   = $self->schema;
    my $machines = $schema->resultset('Machines');
    my $ret;
    my $error;
    my $res;
    my $entry_name;

    try {
        my $rs = $schema->resultset($table);
        $res = $rs->search({id => $self->param('id')});
        if ($res && $res->single) {
            $entry_name = $res->single->name;
        }
        $ret = $res->delete;
    }
    catch {
        $error = shift;
    };

    if ($ret && $ret == 0) {
        return $self->render(json => {error => 'Not found'}, status => 404);
    }
    if (!$ret) {
        return $self->render(json => {error => $error}, status => 400);
    }
    $self->emit_event('openqa_table_delete', {table => $table, name => $entry_name});
    $self->render(json => {result => int($ret)});
}

=over 4

=item _prepare_settings()

Internal method to prepare settings when add or update admin table.
Use by both B<create()> and B<update()> method.

=back

=cut

sub _prepare_settings {
    my ($self, $table, $entry) = @_;
    my $validation = $self->validation;

    for my $par (@{$tables{$table}->{required}}) {
        $validation->required($par);
        if (!defined $validation->param($par)) {
            next;
        }
        $entry->{$par} = trim $validation->param($par);
    }

    if ($validation->has_error) {
        return "Missing parameter: " . join(', ', @{$validation->failed});
    }

    $entry->{description} = $self->param('description');
    my $hp = $self->hparams();
    my @settings;
    my @keys;
    if ($hp->{settings}) {
        for my $k (keys %{$hp->{settings}}) {
            $k = trim $k;
            my $value = trim $hp->{settings}->{$k};
            push @settings, {key => $k, value => $value};
            push @keys, $k;
        }
    }
    return (undef, \@settings, \@keys);
}

1;
