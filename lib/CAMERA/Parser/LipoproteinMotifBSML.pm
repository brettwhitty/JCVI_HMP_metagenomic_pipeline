#!/usr/local/bin/perl

## Brett Whitty, JCVI, 2007

package CAMERA::Parser::LipoproteinMotifBSML;

use strict;
use warnings;
use Carp;
use FileHandle;
use XML::Twig;
use CAMERA::Polypeptide;
use CAMERA::PolypeptideSet;
use CAMERA::AnnotationData::Polypeptide;

my $annotation_type = "LipoproteinMotif";
my @parsed_data = ();
my $to_text = 0;
my $text_fh;

sub new {
    my ($class, %args) = @_;

    my $self = {};

    ## pass in a reference to a CAMERA::PolypeptideSet object
    ## can be null if no other annotation has been parsed yet
    if (ref($args{'polypeptides'}) eq 'CAMERA::PolypeptideSet') {
        $self->{'polypeptides'} = $args{'polypeptides'};
    } else {
        $self->{'polypeptides'} = new CAMERA::PolypeptideSet();
    }

    return bless $self, $class;
}

sub parse {
    my ($self, $file, $text_mode, $text_out_fh) = @_;

    my $result = '';

    $text_fh = $text_out_fh;

    if ($text_mode) {
        $to_text = 1;
    }

    my $xml_parser = new XML::Twig(
                                TwigHandlers => {
                                    'Sequence'  => \&_parse_sequence,
                                                }
                                  );
                              
    my $infh = _open_file_read($file);

    @parsed_data = ();
    
    $xml_parser->parse($infh);

    $result = $self->_annotate();
    return $result;
}

sub _parse_sequence {
    my ($twig, $sequence) = @_;

    my $pep_id = $sequence->{'att'}->{'id'};
    
    my $signal_peptide = 0;
    
    my $sp_title = '';
    
    #my @attributes = $sequence->children('Attribute');
    #foreach my $att_ref(@attributes) {
    #    if ($att_ref->{'att'}->{'name'} eq 'tmh_count') {
    #        $tm_helices = $att_ref->{'att'}->{'content'};
    #    }
    #}
    my @features = $sequence->first_child('Feature-tables')->first_child('Feature-table')->children('Feature');
    foreach my $feat_ref(@features) {
        if ($feat_ref->{'att'}->{'class'} eq 'signal_peptide') {
            $signal_peptide = 1;
            $sp_title = $feat_ref->{'att'}->{'title'};
        }
    }

    push(@parsed_data, [$pep_id, $signal_peptide, $sp_title]);
    
}

sub _annotate {
    my ($self) = @_;
    
    my $result = '';

    foreach my $result_arr_ref(@parsed_data) {
        my ($pep_id, $signal_peptide, $sp_title) = @{$result_arr_ref};
        
        my $pep = undef;
        if ($self->{'polypeptides'}->exists($pep_id)) {
            $pep = $self->{'polypeptides'}->get($pep_id);
        } else {
            $pep = new CAMERA::Polypeptide('id' => $pep_id);
            $self->{'polypeptides'}->add($pep);
        }   
        
        if ($signal_peptide) {
            $result .= _add_annotation($pep, $signal_peptide, $sp_title);
        }
    }
    return $result;
}

sub _add_annotation {
    my ($pep, $sp, $sp_title) = @_;

    my $annotation = new CAMERA::AnnotationData::Polypeptide(
                                'id'        => $pep->{'id'},
                                'type'      => $annotation_type,
                                'source'    => $annotation_type,
                                'rank'      => 1,
                                                            );
                                                           
    my $success = 0;

    $success += _set_common_name($annotation, $sp, $sp_title);
 
    if ($success) {
        if ($to_text) {
            if ($text_fh) {
                print $text_fh $annotation->to_string();
                return '';
            } else {
                return $annotation->to_string();
            }
        } else {
            $pep->add_annotation($annotation);
            return '';
        }
    } else {
        return '';
    }
}

sub _set_common_name {
    my ($annotation, $sp, $sp_title) = @_;

    my $common_name = '';
    
    if ($sp) {
        $common_name = "lipoprotein";
    } else {
        return 0;
    }
    
    $annotation->add_attribute('common_name', $common_name);

    return 1;   
}

sub _open_file_read {
    my ($infile) = @_;
    
    my $infh;
    if ($infile =~ /\.gz$/) {
        open($infh, "<:gzip", $infile)
        || confess("couldn't open gzipped input file '$infile'");
    } else {
        open($infh, $infile)
         || confess("couldn't open input file '$infile'");
    }

    return $infh;
}

1;
