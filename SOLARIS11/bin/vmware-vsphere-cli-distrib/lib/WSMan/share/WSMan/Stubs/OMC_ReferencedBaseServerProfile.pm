package OMC_ReferencedBaseServerProfile;
use WSMan::Stubs::Initializable;
use WSMan::Stubs::OMC_ReferencedProfile;
use strict;


@OMC_ReferencedBaseServerProfile::ISA = qw(_Initializable OMC_ReferencedProfile);


#===============================================================================
#			INITIALIZER
#===============================================================================

sub _init{
    my ($self, %args) = @_;
    $self->OMC_ReferencedProfile::_init();
    unless(exists $self->{invokableMethods}){
        $self->{invokableMethods} = {};
    }
    unless(exists $self->{id_keys}){
        $self->{id_keys} = ();
    }
    $self->{Antecedent} = undef;
    $self->{Dependent} = undef;
    $self->{epr_name} = undef;  
    @{$self->{id_keys}} = keys %{{ map { $_ => 1 } @{$self->{id_keys}} }};
    if(keys %args){
        $self->_subinit(%args);
    }
}


#===============================================================================


#===============================================================================
#            Antecedent accessor method.
#===============================================================================

sub Antecedent{
    my ($self, $newval) = @_;
    $self->{Antecedent} = $newval if @_ > 1;
    return $self->{Antecedent};
}
#===============================================================================


#===============================================================================
#            Dependent accessor method.
#===============================================================================

sub Dependent{
    my ($self, $newval) = @_;
    $self->{Dependent} = $newval if @_ > 1;
    return $self->{Dependent};
}
#===============================================================================


#===============================================================================
#           epr_name accessor method.
#===============================================================================

sub epr_name{
    my ($self, $newval) = @_;
    $self->{epr_name} = $newval if @_ > 1;
    return $self->{epr_name};
}
#===============================================================================


1;
