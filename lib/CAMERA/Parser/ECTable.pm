#!/usr/local/bin/perl

## Brett Whitty, JCVI, 2007

package CAMERA::Parser::ECTable;

use strict;
use warnings;

use CAMERA::Polypeptide;
use CAMERA::PolypeptideSet;
use CAMERA::AnnotationData::Polypeptide;
use Carp;

my $ec_function = {};
my $to_text;
my $text_fh;

sub new {
    my ($class, %args) = @_;

    my $self = {};

    ## initialize the ec hash
    _init_ec();   
 
    ## pass in a reference to a CAMERA::PolypeptideSet object
    ## can be null if no other annotation has been parsed yet
    if (ref($args{'polypeptides'}) eq 'CAMERA::PolypeptideSet') {
        $self->{'polypeptides'} = $args{'polypeptides'};
    } else {
        $self->{'polypeptides'} = new CAMERA::PolypeptideSet();
    }

    return bless $self, $class;
}

sub _init_ec {
    open (my $datafh, "<&DATA") || die "Failed reading EC function from DATA block: $!";

    while (<$datafh>) {
        chomp;
        my @t = split("\t");
        my ($ec1, $ec2, $ec3, $ec4) = split(/\./, $t[0]);
        $ec_function->{$ec1}->{$ec2}->{$ec3}->{$ec4} = $t[1];
    }
}

sub parse {
    my ($self, $file, $text_mode, $text_fh) = @_;

    if ($text_mode) {
        $to_text = 1;
    }

    my $infh = _open_file_read($file);
 
    my $result = '';
    my $counter = 0; 
    while (<$infh>) {
        chomp;

        my ($pep_id, $ec_num, $t, $e_value, $score, $start, $end) = split("\t", $_);
        
        unless ($pep_id) { 
            confess "failed parsing EC table file";
        }
        
        my $pep = undef;
        if ($self->{'polypeptides'}->exists($pep_id)) {
            $pep = $self->{'polypeptides'}->get($pep_id);
        } else {
            $pep = new CAMERA::Polypeptide('id' => $pep_id);
            $self->{'polypeptides'}->add($pep);
        }

        my $annotation = new CAMERA::AnnotationData::Polypeptide(
                                'id'        => $pep_id,
                                'type'      => 'PRIAM',
                                'source'    => 'PRIAM',
                                                );
        
        $annotation->add_attribute('EC' => $ec_num);
        my ($ec1, $ec2, $ec3, $ec4) = split(/\./, $ec_num);
        $annotation->add_attribute('common_name' => $ec_function->{$ec1}->{$ec2}->{$ec3}->{$ec4});
        
        if ($to_text) {
            if ($text_fh) {
                print $text_fh $annotation->to_string();
            } else {
                $result .= $annotation->to_string();
            }
        } else {
            $pep->add_annotation($annotation);
        }
    }
    return $result;
}

sub _open_file_read {
    my ($file) = @_;

    open (my $infh, $file) || die "Failed to open file '$file' for reading: $!";

    return $infh;
}

1;

## EC functional names where derived from ergatis ec.obo file
## with additional names retrieved from http://www.chem.qmul.ac.uk/iubmb/enzyme
## to provide functional names for all EC numbers present in PRIAM profiles
## release JUL06  

__DATA__
1.10.1.1	Trans-acenaphthene-1,2-diol dehydrogenase
1.10.2.1	L-ascorbate--cytochrome-b5 reductase
1.10.2.2	Ubiquinol--cytochrome c reductase
1.10.3.1	Catechol oxidase
1.10.3.2	Laccase
1.10.3.3	L-ascorbate oxidase
1.10.3.4	O-aminophenol oxidase
1.10.3.5	3-hydroxyanthranilate oxidase
1.10.3.6	Rifamycin-B-oxidase
1.10.3.7	Transferred entry: 1.21.3.4
1.10.3.8	Transferred entry: 1.21.3.5
1.10.99.1	Plastoquinol--plastocyanin reductase
1.10.99.2	ribosyldihydronicotinamide dehydrogenase (quinone)
1.1.1.100	3-oxoacyl-[acyl-carrier protein] reductase
1.1.1.101	Acylglycerone-phosphate reductase
1.1.1.102	3-dehydrosphinganine reductase
1.1.1.103	L-threonine 3-dehydrogenase
1.1.1.104	4-oxoproline reductase
1.1.1.105	Retinol dehydrogenase
1.1.1.106	Pantoate 4-dehydrogenase
1.1.1.107	Pyridoxal 4-dehydrogenase
1.1.1.108	Carnitine 3-dehydrogenase
1.1.1.109	Transferred entry: 1.3.1.28
1.1.1.10	L-xylulose reductase
1.11.1.10	Chloride peroxidase
1.1.1.110	Indole-3-lactate dehydrogenase
1.1.1.111	3-(imidazol-5-yl)lactate dehydrogenase
1.11.1.11	L-ascorbate peroxidase
1.1.1.112	Indanol dehydrogenase
1.11.1.12	Phospholipid-hydroperoxide glutathione peroxidase
1.1.1.113	L-xylose 1-dehydrogenase
1.11.1.13	Manganese peroxidase
1.1.1.114	Apiose 1-reductase
1.11.1.14	Diarylpropane peroxidase
1.11.1.15	peroxiredoxin
1.1.1.115	Ribose 1-dehydrogenase (NADP+)
1.1.1.116	D-arabinose 1-dehydrogenase
1.1.1.117	D-arabinose 1-dehydrogenase (NAD(P)+)
1.1.1.118	Glucose 1-dehydrogenase (NAD+)
1.1.1.119	Glucose 1-dehydrogenase (NADP+)
1.1.1.11	D-arabinitol 4-dehydrogenase
1.11.1.1	NADH peroxidase
1.1.1.120	Galactose 1-dehydrogenase (NADP+)
1.1.1.121	Aldose 1-dehydrogenase
1.1.1.122	D-threo-aldose 1-dehydrogenase
1.1.1.123	Sorbose 5-dehydrogenase (NADP+)
1.1.1.124	Fructose 5-dehydrogenase (NADP+)
1.1.1.125	2-deoxy-D-gluconate 3-dehydrogenase
1.1.1.126	2-dehydro-3-deoxy-D-gluconate 6-dehydrogenase
1.1.1.127	2-dehydro-3-deoxy-D-gluconate 5-dehydrogenase
1.1.1.128	L-idonate 2-dehydrogenase
1.1.1.129	L-threonate 3-dehydrogenase
1.1.1.12	L-arabinitol 4-dehydrogenase
1.11.1.2	NADPH peroxidase
1.1.1.130	3-dehydro-L-gulonate 2-dehydrogenase
1.1.1.131	Mannuronate reductase
1.1.1.132	GDP-mannose 6-dehydrogenase
1.1.1.133	dTDP-4-dehydrorhamnose reductase
1.1.1.134	dTDP-6-deoxy-L-talose 4-dehydrogenase
1.1.1.135	GDP-6-deoxy-D-talose 4-dehydrogenase
1.1.1.136	UDP-N-acetylglucosamine 6-dehydrogenase
1.1.1.137	Ribitol-5-phosphate 2-dehydrogenase
1.1.1.138	Mannitol 2-dehydrogenase (NADP+)
1.1.1.139	Transferred entry: 1.1.1.21
1.11.1.3	Fatty acid peroxidase
1.1.1.13	L-arabinitol 2-dehydrogenase (ribulose forming)
1.1.1.140	Sorbitol-6-phosphate 2-dehydrogenase
1.1.1.141	15-hydroxyprostaglandin dehydrogenase (NAD+)
1.1.1.142	D-pinitol dehydrogenase
1.1.1.143	Sequoyitol dehydrogenase
1.1.1.144	Perillyl-alcohol dehydrogenase
1.1.1.145	3-beta-hydroxy-delta(5)-steroid dehydrogenase
1.1.1.146	11-beta-hydroxysteroid dehydrogenase
1.1.1.147	16-alpha-hydroxysteroid dehydrogenase
1.1.1.148	Estradiol 17-alpha-dehydrogenase
1.1.1.149	20-alpha-hydroxysteroid dehydrogenase
1.1.1.14	L-iditol 2-dehydrogenase
1.11.1.4	Transferred entry: 1.13.11.11
1.1.1.150	21-hydroxysteroid dehydrogenase (NAD+)
1.1.1.151	21-hydroxysteroid dehydrogenase (NADP+)
1.1.1.152	3-alpha-hydroxy-5-beta-androstane-17-one 3-alpha-dehydrogenase
1.1.1.153	Sepiapterin reductase
1.1.1.154	Ureidoglycolate dehydrogenase
1.1.1.155	Homoisocitrate dehydrogenase
1.1.1.156	Glycerol 2-dehydrogenase (NADP+)
1.1.1.157	3-hydroxybutyryl-CoA dehydrogenase
1.1.1.158	UDP-N-acetylmuramate dehydrogenase
1.1.1.159	7-alpha-hydroxysteroid dehydrogenase
1.11.1.5	Cytochrome-c peroxidase
1.1.1.15	D-iditol 2-dehydrogenase
1.1.1.160	Dihydrobunolol dehydrogenase
1.1.1.161	Cholestanetetraol 26-dehydrogenase
1.1.1.162	Erythrulose reductase
1.1.1.163	Cyclopentanol dehydrogenase
1.1.1.164	Hexadecanol dehydrogenase
1.1.1.165	2-alkyn-1-ol dehydrogenase
1.1.1.166	Hydroxycyclohexanecarboxylate dehydrogenase
1.1.1.167	Hydroxymalonate dehydrogenase
1.1.1.168	2-dehydropantolactone reductase (A-specific)
1.1.1.169	2-dehydropantoate 2-reductase
1.11.1.6	Catalase
1.1.1.16	Galactitol 2-dehydrogenase
1.1.1.170	Sterol-4-alpha-carboxylate 3-dehydrogenase (decarboxylating)
1.1.1.171	Transferred entry: 1.5.1.20
1.1.1.172	2-oxoadipate reductase
1.1.1.173	L-rhamnose 1-dehydrogenase
1.1.1.174	Cyclohexane-1,2-diol dehydrogenase
1.1.1.175	D-xylose 1-dehydrogenase
1.1.1.176	12-alpha-hydroxysteroid dehydrogenase
1.1.1.177	Glycerol-3-phosphate 1-dehydrogenase (NADP+)
1.1.1.178	3-hydroxy-2-methylbutyryl-CoA dehydrogenase
1.1.1.179	D-xylose 1-dehydrogenase (NADP+)
1.1.1.17	Mannitol-1-phosphate 5-dehydrogenase
1.11.1.7	Peroxidase
1.1.1.180	Transferred entry: 1.1.1.131
1.1.1.181	Cholest-5-ene-3-beta,7-alpha-diol 3-beta-dehydrogenase
1.1.1.182	Transferred entry: 1.1.1.198, 1.1.1.227 and 1.1.1.228
1.1.1.183	Geraniol dehydrogenase
1.1.1.184	Carbonyl reductase (NADPH)
1.1.1.185	L-glycol dehydrogenase
1.1.1.186	dTDP-galactose 6-dehydrogenase
1.1.1.187	GDP-4-dehydro-D-rhamnose reductase
1.1.1.188	Prostaglandin-F synthase
1.1.1.189	Prostaglandin-E2 9-reductase
1.11.1.8	Iodide peroxidase
1.1.1.18	Myo-inositol 2-dehydrogenase
1.1.1.190	Indole-3-acetaldehyde reductase (NADH)
1.1.1.191	Indole-3-acetaldehyde reductase (NADPH)
1.1.1.192	Long-chain-alcohol dehydrogenase
1.1.1.193	5-amino-6-(5-phosphoribosylamino)uracil reductase
1.1.1.194	Coniferyl-alcohol dehydrogenase
1.1.1.195	Cinnamyl-alcohol dehydrogenase
1.1.1.196	15-hydroxyprostaglandin-D dehydrogenase (NADP+)
1.1.1.197	15-hydroxyprostaglandin dehydrogenase (NADP+)
1.1.1.198	(+)-borneol dehydrogenase
1.1.1.199	(S)-usnate reductase
1.1.1.19	Glucuronate reductase
1.11.1.9	Glutathione peroxidase
1.1.1.1	Alcohol dehydrogenase
1.1.1.200	Aldose-6-phosphate reductase (NADPH)
1.1.1.201	7-beta-hydroxysteroid dehydrogenase (NADP+)
1.1.1.202	1,3-propanediol dehydrogenase
1.1.1.203	Uronate dehydrogenase
1.1.1.204	Xanthine dehydrogenase
1.1.1.205	IMP dehydrogenase
1.1.1.206	Tropine dehydrogenase
1.1.1.207	(-)-menthol dehydrogenase
1.1.1.208	(+)-neomenthol dehydrogenase
1.1.1.209	3(or 17)-alpha-hydroxysteroid dehydrogenase
1.1.1.20	Glucuronolactone reductase
1.1.1.210	3-beta(or 20-alpha)-hydroxysteroid dehydrogenase
1.1.1.211	Long-chain-3-hydroxyacyl-CoA dehydrogenase
1.1.1.212	3-oxoacyl-[acyl-carrier protein] reductase (NADH)
1.1.1.213	3-alpha-hydroxysteroid dehydrogenase (A-specific)
1.1.1.214	2-dehydropantolactone reductase (B-specific)
1.1.1.215	Gluconate 2-dehydrogenase
1.1.1.216	Farnesol dehydrogenase
1.1.1.217	Benzyl-2-methyl-hydroxybutyrate dehydrogenase
1.1.1.218	Morphine 6-dehydrogenase
1.1.1.219	Dihydrokaempferol 4-reductase
1.1.1.21	Aldehyde reductase
1.1.1.220	6-pyruvoyltetrahydropterin 2'-reductase
1.1.1.221	Vomifoliol 4'-dehydrogenase
1.1.1.222	(R)-4-hydroxyphenyllactate dehydrogenase
1.1.1.223	Isopiperitenol dehydrogenase
1.1.1.224	Mannose-6-phosphate 6-reductase
1.1.1.225	Chlordecone reductase
1.1.1.226	4-hydroxycyclohexanecarboxylate dehydrogenase
1.1.1.227	(-)-borneol dehydrogenase
1.1.1.228	(+)-sabinol dehydrogenase
1.1.1.229	Diethyl 2-methyl-3-oxosuccinate reductase
1.1.1.22	UDP-glucose 6-dehydrogenase
1.1.1.230	3-alpha-hydroxyglycyrrhetinate dehydrogenase
1.1.1.231	15-hydroxyprostaglandin-I dehydrogenase (NADP+)
1.1.1.232	15-hydroxyicosatetraenoate dehydrogenase
1.1.1.233	N-acylmannosamine 1-dehydrogenase
1.1.1.234	Flavonone 4-reductase
1.1.1.235	8-oxocoformycin reductase
1.1.1.236	Tropinone reductase
1.1.1.237	Hydroxyphenylpyruvate reductase
1.1.1.238	12-beta-hydroxysteroid dehydrogenase
1.1.1.239	3-alpha (17-beta)-hydroxysteroid dehydrogenase (NAD+)
1.1.1.23	Histidinol dehydrogenase
1.1.1.240	N-acetylhexosamine 1-dehydrogenase
1.1.1.241	6-endo-hydroxycineole dehydrogenase
1.1.1.242	Transferred entry: 1.3.1.69
1.1.1.243	Carveol dehydrogenase
1.1.1.244	Methanol dehydrogenase
1.1.1.245	Cyclohexanol dehydrogenase
1.1.1.246	Pterocarpin synthase
1.1.1.247	Codeinone reductase (NADPH)
1.1.1.248	Salutaridine reductase (NADPH)
1.1.1.249	Transferred entry: 2.5.1.46
1.1.1.24	Quinate 5-dehydrogenase
1.1.1.250	D-arabinitol 2-dehydrogenase
1.1.1.251	Galactitol-1-phosphate 5-dehydrogenase
1.1.1.252	Tetrahydroxynaphthalene reductase
1.1.1.253	Transferred entry: 1.5.1.33
1.1.1.254	(S)-carnitine 3-dehydrogenase
1.1.1.255	Mannitol dehydrogenase
1.1.1.256	Fluoren-9-ol dehydrogenase
1.1.1.257	4-(hydroxymethyl)benzenesulfonate dehydrogenase
1.1.1.258	6-hydroxyhexanoate dehydrogenase
1.1.1.259	3-hydroxypimeloyl-CoA dehydrogenase
1.1.1.25	Shikimate 5-dehydrogenase
1.1.1.260	Sulcatone reductase
1.1.1.261	Glycerol-1-phosphate dehydrogenase [NAD(P)]
1.1.1.262	4-hydroxythreonine-4-phosphate dehydrogenase
1.1.1.263	1,5-anhydro-D-fructose reductase
1.1.1.264	L-idonate 5-dehydrogenase
1.1.1.265	3-methylbutanal reductase
1.1.1.266	dTDP-4-dehydro-6-deoxyglucose reductase
1.1.1.267	1-deoxy-D-xylulose-5-phosphate reductoisomerase
1.1.1.268	2-(R)-hydroxypropyl-CoM dehydrogenase
1.1.1.269	2-(S)-hydroxypropyl-CoM dehydrogenase
1.1.1.26	Glyoxylate reductase
1.1.1.270	3-keto-steroid reductase
1.1.1.271	GDP-L-fucose synthase
1.1.1.272	(R)-2-hydroxyacid dehydrogenase
1.1.1.273	Vellosimine dehydrogenase
1.1.1.274	2,5-didehydrogluconate reductase
1.1.1.275	(+)-trans-carveol dehydrogenase
1.1.1.276	Serine 3-dehydrogenase
1.1.1.277	3-beta-hydroxy-5-beta-steroid dehydrogenase
1.1.1.278	3-beta-hydroxy-5-alpha-steroid dehydrogenase
1.1.1.279	(R)-3-hydroxyacid-ester dehydrogenase
1.1.1.27	L-lactate dehydrogenase
1.1.1.280	(S)-3-hydroxyacid-ester dehydrogenase
1.1.1.281	GDP-4-dehydro-6-deoxy-D-mannose reductase
1.1.1.282	quinate/shikimate dehydrogenase
1.1.1.283	methylglyoxal reductase (NADPH-dependent)
1.1.1.284	S-(hydroxymethyl)glutathione dehydrogenase
1.1.1.28	D-lactate dehydrogenase
1.1.1.29	Glycerate dehydrogenase
1.1.1.2	Alcohol dehydrogenase (NADP+)
1.1.1.30	3-hydroxybutyrate dehydrogenase
1.1.1.31	3-hydroxyisobutyrate dehydrogenase
1.1.1.32	Mevaldate reductase
1.1.1.33	Mevaldate reductase (NADPH)
1.1.1.34	Hydroxymethylglutaryl-CoA reductase (NADPH)
1.1.1.35	3-hydroxyacyl-CoA dehydrogenase
1.1.1.36	Acetoacetyl-CoA reductase
1.1.1.37	Malate dehydrogenase
1.1.1.38	Malate dehydrogenase (oxaloacetate decarboxylating)
1.1.1.39	Malate dehydrogenase (decarboxylating)
1.1.1.3	Homoserine dehydrogenase
1.1.1.40	Malate dehydrogenase (oxaloacetate decarboxylating) (NADP+)
1.1.1.41	Isocitrate dehydrogenase (NAD+)
1.1.1.42	Isocitrate dehydrogenase (NADP+)
1.1.1.43	6-phosphogluconate 2-dehydrogenase
1.1.1.44	Phosphogluconate dehydrogenase (decarboxylating)
1.1.1.45	L-gulonate 3-dehydrogenase
1.1.1.46	L-arabinose 1-dehydrogenase
1.1.1.47	Glucose 1-dehydrogenase
1.1.1.48	D-galactose 1-dehydrogenase
1.1.1.49	Glucose-6-phosphate 1-dehydrogenase
1.1.1.4	(R,R)-butanediol dehydrogenase
1.1.1.50	3-alpha-hydroxysteroid dehydrogenase (B-specific)
1.1.1.51	3(or 17)beta-hydroxysteroid dehydrogenase
1.1.1.52	3-alpha-hydroxycholanate dehydrogenase
1.1.1.53	3-alpha(or 20-beta)-hydroxysteroid dehydrogenase
1.1.1.54	Allyl-alcohol dehydrogenase
1.1.1.55	Lactaldehyde reductase (NADPH)
1.1.1.56	Ribitol 2-dehydrogenase
1.1.1.57	Fructuronate reductase
1.1.1.58	Tagaturonate reductase
1.1.1.59	3-hydroxypropionate dehydrogenase
1.1.1.5	Acetoin dehydrogenase
1.1.1.60	2-hydroxy-3-oxopropionate reductase
1.1.1.61	4-hydroxybutyrate dehydrogenase
1.1.1.62	Estradiol 17 beta-dehydrogenase
1.1.1.63	Testosterone 17-beta-dehydrogenase
1.1.1.64	Testosterone 17-beta-dehydrogenase (NADP+)
1.1.1.65	Pyridoxine 4-dehydrogenase
1.1.1.66	Omega-hydroxydecanoate dehydrogenase
1.1.1.67	Mannitol 2-dehydrogenase
1.1.1.68	Transferred entry: 1.7.99.5
1.1.1.69	Gluconate 5-dehydrogenase
1.1.1.6	Glycerol dehydrogenase
1.1.1.70	Transferred entry: 1.2.1.3
1.1.1.71	Alcohol dehydrogenase (NAD(P)+)
1.1.1.72	Glycerol dehydrogenase (NADP+)
1.1.1.73	Octanol dehydrogenase
1.1.1.74	Deleted entry
1.1.1.75	(R)-aminopropanol dehydrogenase
1.1.1.76	(S,S)-butanediol dehydrogenase
1.1.1.77	Lactaldehyde reductase
1.1.1.78	D-lactaldehyde dehydrogenase
1.1.1.79	Glyoxylate reductase (NADP+)
1.1.1.7	Propanediol-phosphate dehydrogenase
1.1.1.80	Isopropanol dehydrogenase (NADP+)
1.1.1.81	Hydroxypyruvate reductase
1.1.1.82	Malate dehydrogenase (NADP+)
1.1.1.83	D-malate dehydrogenase (decarboxylating)
1.1.1.84	Dimethylmalate dehydrogenase
1.1.1.85	3-isopropylmalate dehydrogenase
1.1.1.86	Ketol-acid reductoisomerase
1.1.1.87	3-carboxy-2-hydroxyadipate dehydrogenase
1.1.1.88	Hydroxymethylglutaryl-CoA reductase
1.1.1.89	Transferred entry: 1.1.1.86
1.1.1.8	Glycerol-3-phosphate dehydrogenase (NAD+)
1.1.1.90	Aryl-alcohol dehydrogenase
1.1.1.91	Aryl-alcohol dehydrogenase (NADP+)
1.1.1.92	Oxaloglycolate reductase (decarboxylating)
1.1.1.93	Tartrate dehydrogenase
1.1.1.94	Glycerol-3-phosphate dehydrogenase (NAD(P)+)
1.1.1.95	Phosphoglycerate dehydrogenase
1.1.1.96	Diiodophenylpyruvate reductase
1.1.1.97	3-hydroxybenzyl-alcohol dehydrogenase
1.1.1.98	(R)-2-hydroxy-fatty-acid dehydrogenase
1.1.1.99	(S)-2-hydroxy-fatty-acid dehydrogenase
1.1.1.9	D-xylulose reductase
1.12.1.1	Transferred entry: 1.12.7.2
1.12.1.2	Hydrogen dehydrogenase
1.12.1.3	Hydrogen dehydrogenase (NADP)
1.1.2.1	Transferred entry: 1.1.99.5
1.12.2.1	Cytochrome-c3 hydrogenase
1.1.2.2	Mannitol dehydrogenase (cytochrome)
1.1.2.3	L-lactate dehydrogenase (cytochrome)
1.1.2.4	D-lactate dehydrogenase (cytochrome)
1.12.5.1	Hydrogen:quinone oxidoreductase
1.1.2.5	D-lactate dehydrogenase (cytochrome c-553)
1.12.7.1	Transferred entry: 1.12.7.2
1.12.7.2	Ferredoxin hydrogenase
1.12.98.1	Coenzyme F420 hydrogenase
1.12.98.2	N(5),N(10)-methenyltetrahydromethanopterin hydrogenase
1.12.98.3	Methanosarcina-phenazine hydrogenase
1.12.99.1	Transferred entry: 1.12.98.1
1.12.99.2	Deleted entry
1.12.99.3	Transferred entry: 1.12.5.1
1.12.99.4	Transferred entry: 1.12.98.2
1.12.99.5	Deleted entry
1.12.99.6	Hydrogenase (acceptor)
1.1.3.10	Pyranose oxidase
1.13.11.10	7,8-dihydroxykynurenate 8,8A-dioxygenase
1.13.11.11	Tryptophan 2,3-dioxygenase
1.13.11.12	Lipoxygenase
1.13.11.13	Ascorbate 2,3-dioxygenase
1.13.11.14	2,3-dihydroxybenzoate 3,4-dioxygenase
1.13.11.15	3,4-dihydroxyphenylacetate 2,3-dioxygenase
1.13.11.16	3-carboxyethylcatechol 2,3-dioxygenase
1.13.11.17	Indole 2,3-dioxygenase
1.13.11.18	Sulfur dioxygenase
1.13.11.19	Cysteamine dioxygenase
1.13.11.1	Catechol 1,2-dioxygenase
1.13.11.20	Cysteine dioxygenase
1.13.11.21	Transferred entry: 1.14.99.36
1.13.11.22	Caffeate 3,4-dioxygenase
1.13.11.23	2,3-dihydroxyindole 2,3-dioxygenase
1.13.11.24	Quercetin 2,3-dioxygenase
1.13.11.25	3,4-dihydroxy-9,10-secoandrosta-1,3,5(10)-triene-9,17-dione4,5-dioxygenase
1.13.11.26	Peptide-tryptophan 2,3-dioxygenase
1.13.11.27	4-hydroxyphenylpyruvate dioxygenase
1.13.11.28	2,3-dihydroxybenzoate 2,3-dioxygenase
1.13.11.29	Stizolobate synthase
1.13.11.2	Catechol 2,3-dioxygenase
1.13.11.30	Stizolobinate synthase
1.13.11.31	Arachidonate 12-lipoxygenase
1.13.11.32	2-nitropropane dioxygenase
1.13.11.33	Arachidonate 15-lipoxygenase
1.13.11.34	Arachidonate 5-lipoxygenase
1.13.11.35	Pyrogallol 1,2-oxygenase
1.13.11.36	Chloridazon-catechol dioxygenase
1.13.11.37	Hydroxyquinol 1,2-dioxygenase
1.13.11.38	1-hydroxy-2-naphthoate 1,2-dioxygenase
1.13.11.39	Biphenyl-2,3-diol 1,2-dioxygenase
1.13.11.3	Protocatechuate 3,4-dioxygenase
1.13.11.40	Arachidonate 8-lipoxygenase
1.13.11.41	2,4'-dihydroxyacetophenone dioxygenase
1.13.11.42	Indoleamine-pyrrole 2,3-dioxygenase
1.13.11.43	Lignostilbene alpha beta-dioxygenase
1.13.11.44	Linoleate diol synthase
1.13.11.45	Linoleate 11-lipoxygenase
1.13.11.46	4-hydroxymandelate synthase
1.13.11.47	3-hydroxy-4-oxoquinoline 2,4-dioxygenase
1.13.11.48	3-hydroxy-2-methyl-quinolin-4-one 2,4-dioxygenase
1.13.11.49	Chlorite O(2)-lyase
1.13.11.4	Gentisate 1,2-dioxygenase
1.13.11.50	Acetylacetone-cleaving enzyme
1.13.11.5	Homogentisate 1,2-dioxygenase
1.13.11.6	3-hydroxyanthranilate 3,4-dioxygenase
1.13.11.7	Deleted entry
1.13.11.8	Protocatechuate 4,5-dioxygenase
1.13.11.9	2,5-dihydroxypyridine 5,6-dioxygenase
1.1.3.11	L-sorbose oxidase
1.13.12.10	Deleted entry
1.13.12.11	Methylphenyltetrahydropyridine N-monooxygenase
1.13.12.12	Apo-beta-carotenoid-14',13'-dioxygenase
1.13.12.1	Arginine 2-monooxygenase
1.13.12.2	Lysine 2-monooxygenase
1.13.12.3	Tryptophan 2-monooxygenase
1.13.12.4	Lactate 2-monooxygenase
1.13.12.5	Renilla-luciferin 2-monooxygenase
1.13.12.6	Cypridina-luciferin 2-monooxygenase
1.13.12.7	Photinus-luciferin 4-monooxygenase (ATP-hydrolyzing)
1.13.12.8	Watasenia-luciferin 2-monooxygenase
1.13.12.9	Phenylalanine 2-monooxygenase
1.1.3.12	Pyridoxine 4-oxidase
1.1.3.13	Alcohol oxidase
1.1.3.14	Catechol oxidase (dimerizing)
1.1.3.15	(S)-2-hydroxy-acid oxidase
1.1.3.16	Ecdysone oxidase
1.1.3.17	Choline oxidase
1.1.3.18	Secondary-alcohol oxidase
1.1.3.19	4-hydroxymandelate oxidase
1.1.3.1	Transferred entry: 1.1.3.15
1.1.3.20	Long-chain-alcohol oxidase
1.1.3.21	Glycerol-3-phosphate oxidase
1.1.3.22	Xanthine oxidase
1.1.3.23	Thiamine oxidase
1.1.3.24	L-galactonolactone oxidase
1.1.3.25	Cellobiose oxidase
1.1.3.26	Transferred entry: 1.21.3.2
1.1.3.27	Hydroxyphytanate oxidase
1.1.3.28	Nucleoside oxidase
1.1.3.29	N-acylhexosamine oxidase
1.1.3.2	Transferred entry: 1.13.12.4
1.1.3.30	Polyvinyl-alcohol oxidase
1.1.3.31	Deleted entry
1.1.3.32	Transferred entry: 1.14.21.1
1.1.3.33	Transferred entry: 1.14.21.2
1.1.3.34	Transferred entry: 1.14.21.3
1.1.3.35	Transferred entry: 1.14.21.4
1.1.3.36	Transferred entry: 1.14.21.5
1.1.3.37	D-arabinono-1,4-lactone oxidase
1.1.3.38	Vanillyl-alcohol oxidase
1.1.3.39	Nucleoside oxidase (H(2)O(2)-forming)
1.1.3.3	Malate oxidase
1.1.3.40	D-mannitol oxidase
1.1.3.41	Xylitol oxidase
1.1.3.4	Glucose oxidase
1.1.3.5	Hexose oxidase
1.1.3.6	Cholesterol oxidase
1.1.3.7	Aryl-alcohol oxidase
1.1.3.8	L-gulonolactone oxidase
1.13.99.1	Inositol oxygenase
1.13.99.2	Transferred entry: 1.14.12.10
1.13.99.3	Tryptophan 2'-dioxygenase
1.13.99.4	Transferred entry: 1.14.12.9
1.13.99.5	Transferred entry: 1.13.11.47
1.1.3.9	Galactose oxidase
1.14.11.10	Pyrimidine-deoxynucleoside 1'-dioxygenase
1.14.11.11	Hyoscyamine (6S)-dioxygenase
1.14.11.12	Gibberellin-44 dioxygenase
1.14.11.13	Gibberellin 2-beta-dioxygenase
1.14.11.14	6-beta-hydroxyhyoscyamine epoxidase
1.14.11.15	Gibberellin 3-beta-dioxygenase
1.14.11.16	Peptide-aspartate beta-dioxygenase
1.14.11.17	Taurine dioxygenase
1.14.11.18	Phytanoyl-CoA dioxygenase
1.14.11.19	Leucocyanidin oxygenase
1.14.11.1	Gamma-butyrobetaine,2-oxoglutarate dioxygenase
1.14.11.20	Desacetoxyvindoline 4-hydroxylase
1.14.11.21	Clavaminate synthase
1.14.11.23	flavonol synthase
1.14.11.26	deacetoxycephalosporin-C hydroxylase
1.14.11.2	Procollagen-proline,2-oxoglutarate-4-dioxygenase
1.14.11.3	Pyrimidine-deoxynucleoside 2'-dioxygenase
1.14.11.4	Procollagen-lysine 5-dioxygenase
1.14.11.5	Deleted entry
1.14.11.6	Thymine dioxygenase
1.14.11.7	Procollagen-proline 3-dioxygenase
1.14.11.8	Trimethyllysine dioxygenase
1.14.11.9	Naringenin 3-dioxygenase
1.14.12.10	Benzoate 1,2-dioxygenase
1.14.12.11	Toluene dioxygenase
1.14.12.12	Naphthalene 1,2-dioxygenase
1.14.12.13	2-chlorobenzoate 1,2-dioxygenase
1.14.12.14	2-aminobenzenesulfonate 2,3-dioxygenase
1.14.12.15	Terephthalate 1,2-dioxygenase
1.14.12.16	2-hydroxyquinoline 5,6-dioxygenase
1.14.12.17	Nitric oxide dioxygenase
1.14.12.18	Biphenyl 2,3-dioxygenase
1.14.12.19	3-phenylpropanoate dioxygenase
1.14.12.1	Anthranilate 1,2-dioxygenase (deaminating, decarboxylating)
1.14.12.2	Transferred entry: 1.14.13.35
1.14.12.3	Benzene 1,2-dioxygenase
1.14.12.4	3-hydroxy-2-methylpyridinecarboxylate dioxygenase
1.14.12.5	5-pyridoxate dioxygenase
1.14.12.6	Transferred entry: 1.14.13.66
1.14.12.7	Phthalate 4,5-dioxygenase
1.14.12.8	4-sulfobenzoate 3,4-dioxygenase
1.14.12.9	4-chlorophenylacetate 3,4-dioxygenase
1.14.13.100	25-hydroxycholesterol 7-alpha-hydroxylase
1.14.13.10	2,6-dihydroxypyridine 3-monooxygenase
1.14.13.11	Trans-cinnamate 4-monooxygenase
1.14.13.12	Benzoate 4-monooxygenase
1.14.13.13	Calcidiol 1-monooxygenase
1.14.13.14	Trans-cinnamate 2-monooxygenase
1.14.13.15	Cholestanetriol 26-monooxygenase
1.14.13.16	Cyclopentanone monooxygenase
1.14.13.17	Cholesterol 7-alpha-monooxygenase
1.14.13.18	4-hydroxyphenylacetate 1-monooxygenase
1.14.13.19	Taxifolin 8-monooxygenase
1.14.13.1	Salicylate 1-monooxygenase
1.14.13.20	2,4-dichlorophenol 6-monooxygenase
1.14.13.21	Flavonoid 3'-monooxygenase
1.14.13.22	Cyclohexanone monooxygenase
1.14.13.23	3-hydroxybenzoate 4-monooxygenase
1.14.13.24	3-hydroxybenzoate 6-monooxygenase
1.14.13.2	4-hydroxybenzoate 3-monooxygenase
1.14.13.25	Methane monooxygenase
1.14.13.26	Phosphatidylcholine 12-monooxygenase
1.14.13.27	4-aminobenzoate 1-monooxygenase
1.14.13.28	3,9-dihydroxypterocarpan 6A-monooxygenase
1.14.13.29	4-nitrophenol 2-monooxygenase
1.14.13.30	Leukotriene-B4 20-monooxygenase
1.14.13.31	2-nitrophenol 2-monooxygenase
1.14.13.32	Albendazole monooxygenase
1.14.13.33	4-hydroxybenzoate 3-monooxygenase (NAD(P)H)
1.14.13.3	4-hydroxyphenylacetate 3-monooxygenase
1.14.13.34	Leukotriene-E4 20-monooxygenase
1.14.13.35	Anthranilate 3-monooxygenase (deaminating)
1.14.13.36	5-O-(4-coumaroyl)-D-quinate 3'-monooxygenase
1.14.13.37	Methyltetrahydroprotoberberine 14-monooxygenase
1.14.13.38	Anhydrotetracycline monooxygenase
1.14.13.39	Nitric-oxide synthase
1.14.13.40	Anthraniloyl-CoA monooxygenase
1.14.13.41	Tyrosine N-monooxygenase
1.14.13.42	Hydroxyphenylacetonitrile 2-monooxygenase
1.14.13.43	Questin monooxygenase
1.14.13.44	2-hydroxybiphenyl 3-monooxygenase
1.14.13.45	Transferred entry: 1.14.18.2
1.14.13.46	(-)-menthol monooxygenase
1.14.13.47	(S)-limonene 3-monooxygenase
1.14.13.48	(S)-limonene 6-monooxygenase
1.14.13.49	(S)-limonene 7-monooxygenase
1.14.13.4	Melilotate 3-monooxygenase
1.14.13.50	Pentachlorophenol monooxygenase
1.14.13.51	6-oxocineole dehydrogenase
1.14.13.52	Isoflavone 3'-hydroxylase
1.14.13.53	Isoflavone 2'-hydroxylase
1.14.13.54	Ketosteroid monooxygenase
1.14.13.55	Protopine 6-monooxygenase
1.14.13.56	Dihydrosanguinarine 10-monooxygenase
1.14.13.57	Dihydrochelirubine 12-monooxygenase
1.14.13.58	Benzoyl-CoA 3-monooxygenase
1.14.13.59	L-lysine 6-monooxygenase (NADPH)
1.14.13.5	Imidazoleacetate 4-monooxygenase
1.14.13.60	27-hydroxycholesterol 7-alpha-monooxygenase
1.14.13.61	2-hydroxyquinoline 8-monooxygenase
1.14.13.62	4-hydroxyquinoline 3-monooxygenase
1.14.13.63	3-hydroxyphenylacetate 6-hydroxylase
1.14.13.64	4-hydroxybenzoate 1-hydroxylase
1.14.13.65	2-hydroxyquinoline 8-monooxygenase
1.14.13.66	2-hydroxycyclohexanone 2-monooxygenase
1.14.13.67	Quinine 3-monooxygenase
1.14.13.68	4-hydroxyphenylacetaldehyde oxime monooxygenase
1.14.13.69	Alkene monooxygenase
1.14.13.6	Orcinol 2-monooxygenase
1.14.13.70	Sterol 14-demethylase
1.14.13.71	N-methylcoclaurine 3'-monooxygenase
1.14.13.72	Methylsterol monooxygenase
1.14.13.73	Tabersonine 16-hydroxylase
1.14.13.74	7-deoxyloganin 7-hydroxylase
1.14.13.75	Vinorine hydroxylase
1.14.13.76	Taxane 10-beta-hydroxylase
1.14.13.77	Taxane 13-alpha-hydroxylase
1.14.13.78	Ent-kaurene oxidase
1.14.13.79	Ent-kaurenoic acid oxidase
1.14.13.7	Phenol 2-monooxygenase
1.14.13.80	(R)-limonene 6-monooxygenase
1.14.13.81	Magnesium-protoporphyrin IX monomethyl ester (oxidative) cyclase
1.14.13.82	Vanillate monooxygenase
1.14.13.83	Precorrin-3B synthase
1.14.13.87	licodione synthase
1.14.13.88	flavonoid 3',5'-hydroxylase
1.14.13.89	isoflavone 2'-hydroxylase
1.14.13.8	Dimethylaniline monooxygenase (N-oxide forming)
1.14.13.90	zeaxanthin epoxidase
1.14.13.94	lithocholate 6-beta-hydroxylase
1.14.13.95	7-alpha-hydroxycholest-4-en-3-one 12-alpha-hydroxylase
1.14.13.97	taurochenodeoxycholate 6-alpha-hydroxylase
1.14.13.98	cholesterol 24-hydroxylase
1.14.13.99	24-hydroxycholesterol 7-alpha-hydroxylase
1.14.13.9	Kynurenine 3-monooxygenase
1.14.14.1	Unspecific monooxygenase
1.14.14.2	Transferred entry: 1.14.14.1
1.14.14.3	Alkanal monooxygenase (FMN-linked)
1.14.14.4	Deleted entry
1.14.14.5	Alkanesulfonate monooxygenase
1.14.15.1	Camphor 5-monooxygenase
1.14.15.2	Camphor 1,2-monooxygenase
1.14.15.3	Alkane-1 monooxygenase
1.14.15.4	Steroid 11-beta-monooxygenase
1.14.15.5	Corticosterone 18-monooxygenase
1.14.15.6	Cholesterol monooxygenase (side-chain cleaving)
1.14.15.7	Choline monooxygenase
1.14.16.1	Phenylalanine 4-monooxygenase
1.14.16.2	Tyrosine 3-monooxygenase
1.14.16.3	Anthranilate 3-monooxygenase
1.14.16.4	Tryptophan 5-monooxygenase
1.14.16.5	Glyceryl-ether monooxygenase
1.14.16.6	Mandelate 4-monooxygenase
1.14.17.1	Dopamine-beta-monooxygenase
1.14.17.2	Transferred entry: 1.14.18.1
1.14.17.3	Peptidylglycine monooxygenase
1.14.17.4	Aminocyclopropanecarboxylate oxidase
1.14.18.1	Monophenol monooxygenase
1.14.18.2	CMP-N-acetylneuraminate monooxygenase
1.14.19.1	Stearoyl-CoA 9-desaturase
1.14.19.2	Acyl-[acyl-carrier protein] desaturase
1.14.19.3	Linoleoyl-CoA desaturase
1.1.4.1	Vitamin-K-epoxide reductase (warfarin-sensitive)
1.14.20.1	Deacetoxycephalosporin-C synthase
1.14.21.1	(S)-stylopine synthase
1.14.21.2	(S)-cheilanthifoline synthase
1.14.21.3	Berbamunine synthase
1.14.21.4	Salutaridine synthase
1.14.21.5	(S)-canadine synthase
1.14.21.6	lathosterol oxidase
1.1.4.2	Vitamin-K-epoxide reductase (warfarin-insensitive)
1.14.99.10	Steroid 21-monooxygenase
1.14.99.11	Estradiol 6-beta-monooxygenase
1.14.99.12	Androst-4-ene-3,17-dione monooxygenase
1.14.99.13	Transferred entry: 1.14.13.23
1.14.99.14	Progesterone 11-alpha-monooxygenase
1.14.99.15	4-methoxybenzoate monooxygenase (O-demethylating)
1.14.99.16	Transferred entry: 1.14.13.72
1.14.99.17	Transferred entry: 1.14.16.5
1.14.99.18	Transferred entry: 1.14.18.2
1.14.99.19	Plasmenylethanolamine desaturase
1.14.99.1	Prostaglandin-endoperoxide synthase
1.14.99.20	Phylloquinone monooxygenase (2,3-epoxidizing)
1.14.99.21	Latia-luciferin monooxygenase (demethylating)
1.14.99.22	Ecdysone 20-monooxygenase
1.14.99.23	3-hydroxybenzoate 2-monooxygenase
1.14.99.24	Steroid 9-alpha-monooxygenase
1.14.99.25	Transferred entry: 1.14.19.3
1.14.99.26	2-hydroxypyridine 5-monooxygenase
1.14.99.27	Juglone 3-monooxygenase
1.14.99.28	Linalool 8-monooxygenase
1.14.99.29	Deoxyhypusine monooxygenase
1.14.99.2	Kynurenine 7,8-hydroxylase
1.14.99.30	Carotene 7,8-desaturase
1.14.99.31	Myristoyl-CoA 11-(E) desaturase
1.14.99.32	Myristoyl-CoA 11-(Z) desaturase
1.14.99.33	Delta(12)-fatty acid dehydrogenase
1.14.99.34	Monoprenyl isoflavone epoxidase
1.14.99.35	Thiophene-2-carbonyl-CoA monooxygenase
1.14.99.36	Beta-carotene 15,15'-dioxygenase
1.14.99.37	Taxadiene 5-alpha-hydroxylase
1.14.99.38	cholesterol 25-hydroxylase
1.14.99.3	Heme oxygenase (decyclizing)
1.14.99.4	Progesterone monooxygenase
1.14.99.5	Transferred entry: 1.14.19.1
1.14.99.6	Transferred entry: 1.14.19.2
1.14.99.7	Squalene monooxygenase
1.14.99.8	Transferred entry: 1.14.14.1
1.14.99.9	Steroid 17-alpha-monooxygenase
1.15.1.1	Superoxide dismutase
1.15.1.2	Superoxide reductase
1.1.5.1	Transferred entry: 1.1.99.18
1.1.5.2	Quinoprotein glucose dehydrogenase
1.16.1.1	Mercury (II) reductase
1.16.1.2	Diferric-transferrin reductase
1.16.1.3	Aquacobalamin reductase
1.16.1.4	Cob(II)alamin reductase
1.16.1.5	Aquacobalamin reductase (NADPH)
1.16.1.6	Cyanocobalamin reductase (cyanide-eliminating)
1.16.1.7	Ferric-chelate reductase
1.16.1.8	[Methionine synthase] reductase
1.16.3.1	Ferroxidase
1.16.8.1	Cob(II)yrinic acid a,c-diamide reductase
1.17.1.1	CDP-4-dehydro-6-deoxyglucose reductase
1.17.1.2	4-hydroxy-3-methylbut-2-enyl diphosphate reductase
1.17.1.3	Leucoanthocyanidin reductase
1.17.1.4	xanthine dehydrogenase
1.17.1.6	bile-acid 7-alpha-dehydroxylase
1.17.3.1	Pteridine oxidase
1.17.3.2	xanthine oxidase
1.17.4.1	Ribonucleoside-diphosphate reductase
1.17.4.2	Ribonucleoside-triphosphate reductase
1.17.4.3	4-hydroxy-3-methylbut-2-en-1-yl diphosphate synthase
1.17.99.1	4-cresol dehydrogenase (hydroxylating)
1.17.99.2	Ethylbenzene hydroxylase
1.17.99.3	3-alpha,7-alpha,12-alpha-trihydroxy-5-beta-cholestanoyl-CoA 24-hydroxylase
1.18.1.1	Rubredoxin--NAD(+) reductase
1.18.1.2	Ferredoxin--NADP(+) reductase
1.18.1.3	Ferredoxin--NAD(+) reductase
1.18.1.4	Rubredoxin--NADP(+) reductase
1.18.3.1	Transferred entry: 1.12.7.2
1.18.6.1	Nitrogenase
1.18.96.1	Transferred entry: 1.15.1.2
1.18.99.1	Transferred entry: 1.12.7.2
1.19.6.1	Nitrogenase (flavodoxin)
1.1.99.10	Glucose dehydrogenase (acceptor)
1.1.99.11	Fructose 5-dehydrogenase
1.1.99.12	Sorbose dehydrogenase
1.1.99.13	Glucoside 3-dehydrogenase
1.1.99.14	Glycolate dehydrogenase
1.1.99.15	Transferred entry: 1.7.99.5
1.1.99.16	Malate dehydrogenase (acceptor)
1.1.99.17	Transferred entry: 1.1.5.2
1.1.99.18	Cellobiose dehydrogenase (acceptor)
1.1.99.19	Uracil dehydrogenase
1.1.99.1	Choline dehydrogenase
1.1.99.20	Alkan-1-ol dehydrogenase (acceptor)
1.1.99.21	D-sorbitol dehydrogenase
1.1.99.22	Glycerol dehydrogenase (acceptor)
1.1.99.2	2-hydroxyglutarate dehydrogenase
1.1.99.23	Polyvinyl-alcohol dehydrogenase (acceptor)
1.1.99.24	Hydroxyacid--oxoacid transhydrogenase
1.1.99.25	Quinate dehydrogenase (pyrroloquinoline-quinone)
1.1.99.26	3-hydroxycyclohexanone dehydrogenase
1.1.99.27	(R)-pantolactone dehydrogenase (flavin)
1.1.99.28	Glucose--fructose oxidoreductase
1.1.99.3	Gluconate 2-dehydrogenase (acceptor)
1.1.99.4	Dehydrogluconate dehydrogenase
1.1.99.5	Glycerol-3-phosphate dehydrogenase
1.1.99.6	D-2-hydroxy-acid dehydrogenase
1.1.99.7	Lactate--malate transhydrogenase
1.1.99.8	Alcohol dehydrogenase (acceptor)
1.1.99.9	Pyridoxine 5-dehydrogenase
1.20.1.1	Phosphonate dehydrogenase
1.20.4.1	Arsenate reductase (glutaredoxin)
1.20.4.2	Methylarsonate reductase
1.20.98.1	Arsenate reductase (azurin)
1.20.99.1	Arsenate reductase (donor)
1.2.1.10	Acetaldehyde dehydrogenase (acetylating)
1.2.1.11	Aspartate-semialdehyde dehydrogenase
1.2.1.12	Glyceraldehyde 3-phosphate dehydrogenase (phosphorylating)
1.2.1.13	Glyceraldehyde 3-phosphate dehydrogenase (NADP+) (phosphorylating)
1.2.1.14	Transferred entry: 1.1.1.205
1.2.1.15	Malonate-semialdehyde dehydrogenase
1.2.1.16	Succinate-semialdehyde dehydrogenase (NAD(P)+)
1.2.1.17	Glyoxylate dehydrogenase (acylating)
1.2.1.18	Malonate-semialdehyde dehydrogenase (acetylating)
1.2.1.19	Aminobutyraldehyde dehydrogenase
1.2.1.1	Formaldehyde dehydrogenase (glutathione)
1.2.1.20	Glutarate-semialdehyde dehydrogenase
1.2.1.21	Glycolaldehyde dehydrogenase
1.2.1.22	Lactaldehyde dehydrogenase
1.2.1.23	2-oxoaldehyde dehydrogenase (NAD+)
1.2.1.24	Succinate-semialdehyde dehydrogenase
1.2.1.25	2-oxoisovalerate dehydrogenase (acylating)
1.2.1.26	2,5-dioxovalerate dehydrogenase
1.2.1.27	Methylmalonate-semialdehyde dehydrogenase (acylating)
1.2.1.28	Benzaldehyde dehydrogenase (NAD+)
1.2.1.29	Aryl-aldehyde dehydrogenase
1.2.1.2	Formate dehydrogenase
1.2.1.30	Aryl-aldehyde dehydrogenase (NADP+)
1.2.1.31	Aminoadipate-semialdehyde dehydrogenase
1.21.3.1	Isopenicillin-N synthase
1.2.1.32	Aminomuconate-semialdehyde dehydrogenase
1.21.3.2	Columbamine oxidase
1.2.1.33	(R)-dehydropantoate dehydrogenase
1.21.3.3	Reticuline oxidase
1.21.3.4	Sulochrin oxidase [(+)-bisdechlorogeodin-forming]
1.2.1.34	Transferred entry: 1.1.1.131
1.21.3.5	Sulochrin oxidase [(-)-bisdechlorogeodin-forming]
1.2.1.35	Transferred entry: 1.1.1.203
1.21.3.6	Aureusidin synthase
1.2.1.36	Retinal dehydrogenase
1.2.1.37	Transferred entry: 1.1.1.204
1.2.1.38	N-acetyl-gamma-glutamyl-phosphate reductase
1.2.1.39	Phenylacetaldehyde dehydrogenase
1.2.1.3	Aldehyde dehydrogenase (NAD+)
1.2.1.40	3-alpha,7-alpha,12-alpha-trihydroxycholestan-26-al 26-oxidoreductase
1.21.4.1	D-proline reductase (dithiol)
1.2.1.41	Glutamate-5-semialdehyde dehydrogenase
1.21.4.2	Glycine reductase
1.2.1.42	Hexadecanal dehydrogenase (acylating)
1.2.1.43	Formate dehydrogenase (NADP+)
1.21.4.3	Sarcosine reductase
1.21.4.4	Betaine reductase
1.2.1.44	Cinnamoyl-CoA reductase
1.2.1.45	4-carboxy-2-hydroxymuconate-6-semialdehyde dehydrogenase
1.2.1.46	Formaldehyde dehydrogenase
1.2.1.47	4-trimethylammoniobutyraldehyde dehydrogenase
1.2.1.48	Long-chain-aldehyde dehydrogenase
1.2.1.49	2-oxoaldehyde dehydrogenase (NADP+)
1.2.1.4	Aldehyde dehydrogenase (NADP+)
1.2.1.50	Long-chain-fatty-acyl-CoA reductase
1.2.1.51	Pyruvate dehydrogenase (NADP+)
1.2.1.52	Oxoglutarate dehydrogenase (NADP+)
1.2.1.53	4-hydroxyphenylacetaldehyde dehydrogenase
1.2.1.54	Gamma-guanidinobutyraldehyde dehydrogenase
1.2.1.55	Transferred entry: 1.1.1.279
1.2.1.56	Transferred entry: 1.1.1.280
1.2.1.57	Butanal dehydrogenase
1.2.1.58	Phenylglyoxylate dehydrogenase (acylating)
1.2.1.59	Glyceraldehyde 3-phosphate dehydrogenase (NAD(P)) (phosphorylating)
1.2.1.5	Aldehyde dehydrogenase (NAD(P)+)
1.2.1.60	5-carboxymethyl-2-hydroxymuconic-semialdehyde dehydrogenase
1.2.1.61	4-hydroxymuconic-semialdehyde dehydrogenase
1.2.1.62	4-formylbenzenesulfonate dehydrogenase
1.2.1.63	6-oxohexanoate dehydrogenase
1.2.1.64	4-hydroxybenzaldehyde dehydrogenase
1.2.1.65	Salicylaldehyde dehydrogenase
1.2.1.66	Mycothiol-dependent formaldehyde dehydrogenase
1.2.1.67	Vanillin dehydrogenase
1.2.1.68	Coniferyl-aldehyde dehydrogenase
1.2.1.69	Fluoroacetaldehyde dehydrogenase
1.2.1.6	Deleted entry
1.2.1.70	glutamyl-tRNA reductase
1.2.1.7	Benzaldehyde dehydrogenase (NADP+)
1.2.1.8	Betaine-aldehyde dehydrogenase
1.21.99.1	Beta-cyclopiazonate dehydrogenase
1.2.1.9	Glyceraldehyde-3-phosphate dehydrogenase (NADP+)
1.2.2.1	Formate dehydrogenase (cytochrome)
1.2.2.2	Pyruvate dehydrogenase (cytochrome)
1.2.2.3	Formate dehydrogenase (cytochrome c-553)
1.2.2.4	Carbon monoxide oxygenase (cytochrome b-561)
1.2.3.10	Transferred entry: 1.2.2.4
1.2.3.11	Retinal oxidase
1.2.3.12	Transferred entry: 1.14.13.82
1.2.3.13	4-hydroxyphenylpyruvate oxidase
1.2.3.14	abscisic-aldehyde oxidase
1.2.3.1	Aldehyde oxidase
1.2.3.2	Transferred entry: 1.1.3.22
1.2.3.3	Pyruvate oxidase
1.2.3.4	Oxalate oxidase
1.2.3.5	Glyoxylate oxidase
1.2.3.6	Pyruvate oxidase (CoA-acetylating)
1.2.3.7	Indole-3-acetaldehyde oxidase
1.2.3.8	Pyridoxal oxidase
1.2.3.9	Aryl-aldehyde oxidase
1.2.4.1	Pyruvate dehydrogenase (acetyl-transferring)
1.2.4.2	Oxoglutarate dehydrogenase (succinyl-transferring)
1.2.4.3	Transferred entry: 1.2.4.4
1.2.4.4	3-methyl-2-oxobutanoate dehydrogenase (2-methylpropanoyl-transferring)
1.2.7.1	Pyruvate synthase
1.2.7.2	2-oxobutyrate synthase
1.2.7.3	2-oxoglutarate synthase
1.2.7.4	Carbon-monoxide dehydrogenase (ferredoxin)
1.2.7.5	Aldehyde ferredoxin oxidoreductase
1.2.7.6	Glyceraldehyde-3-phosphate dehydrogenase (ferredoxin)
1.2.7.7	3-methyl-2-oxobutanoate dehydrogenase (ferredoxin)
1.2.7.8	Indolepyruvate ferredoxin oxidoreductase
1.2.7.9	2-oxoglutarate ferredoxin oxidoreductase
1.2.99.1	Transferred entry: 1.1.99.19
1.2.99.2	Carbon-monoxide dehydrogenase (acceptor)
1.2.99.3	Aldehyde dehydrogenase (pyrroloquinoline-quinone)
1.2.99.4	Formaldehyde dismutase
1.2.99.5	Formylmethanofuran dehydrogenase
1.2.99.6	Carboxylate reductase
1.2.99.7	aldehyde dehydrogenase (FAD-independent)
1.3.1.10	Enoyl-[acyl-carrier protein] reductase (NADPH, B-specific)
1.3.1.11	Coumarate reductase
1.3.1.12	Prephenate dehydrogenase
1.3.1.13	Prephenate dehydrogenase (NADP+)
1.3.1.14	Orotate reductase (NADH)
1.3.1.15	Orotate reductase (NADPH)
1.3.1.16	Beta-nitroacrylate reductase
1.3.1.17	3-methyleneoxindole reductase
1.3.1.18	Kynurenate-7,8-dihydrodiol dehydrogenase
1.3.1.19	Cis-1,2-dihydrobenzene-1,2-diol dehydrogenase
1.3.1.1	Dihydrouracil dehydrogenase (NAD+)
1.3.1.20	Trans-1,2-dihydrobenzene-1,2-diol dehydrogenase
1.3.1.21	7-dehydrocholesterol reductase
1.3.1.22	Cholestenone 5-alpha-reductase
1.3.1.23	Cholestenone 5-beta-reductase
1.3.1.24	Biliverdin reductase
1.3.1.25	1,6-dihydroxycyclohexa-2,4-diene-1-carboxylate dehydrogenase
1.3.1.26	Dihydrodipicolinate reductase
1.3.1.27	2-hexadecenal reductase
1.3.1.28	2,3-dihydro-2,3-dihydroxybenzoate dehydrogenase
1.3.1.29	Cis-1,2-dihydro-1,2-dihydroxynaphthalene dehydrogenase
1.3.1.2	Dihydropyrimidine dehydrogenase (NADP+)
1.3.1.30	Progesterone 5-alpha-reductase
1.3.1.31	2-enoate reductase
1.3.1.32	Maleylacetate reductase
1.3.1.33	Protochlorophyllide reductase
1.3.1.34	2,4-dienoyl-CoA reductase (NADPH)
1.3.1.35	Phosphatidylcholine desaturase
1.3.1.36	Geissoschizine dehydrogenase
1.3.1.37	Cis-2-enoyl-CoA reductase (NADPH)
1.3.1.38	Trans-2-enoyl-CoA reductase (NADPH)
1.3.1.39	Enoyl-[acyl-carrier protein] reductase (NADPH, A-specific)
1.3.1.3	Cortisone beta-reductase
1.3.1.40	2-hydroxy-6-oxo-6-phenylhexa-2,4-dienoate reductase
1.3.1.41	Xanthommatin reductase
1.3.1.42	12-oxophytodienoate reductase
1.3.1.43	Cyclohexadienyl dehydrogenase
1.3.1.44	Trans-2-enoyl-CoA reductase (NAD+)
1.3.1.45	2'-hydroxyisoflavone reductase
1.3.1.46	Biochanin-A reductase
1.3.1.47	Alpha-santonin 1,2-reductase
1.3.1.48	15-oxoprostaglandin 13-reductase
1.3.1.49	Cis-3,4-dihydrophenanthrene-3,4-diol dehydrogenase
1.3.1.4	Cortisone alpha-reductase
1.3.1.50	Transferred entry: 1.1.1.252
1.3.1.51	2'-hydroxydaidzein reductase
1.3.1.52	2-methyl-branched-chain-enoyl-CoA reductase
1.3.1.53	(3S,4R)-3,4-dihydroxycyclohexa-1,5-diene-1,4-dicarboxylate dehydrogenase
1.3.1.54	Precorrin-6A reductase
1.3.1.55	Cis-1,2-dihydroxycyclohexa-3,5-diene-1-carboxylate dehydrogenase
1.3.1.56	Cis-2,3-dihydrobiphenyl-2,3-diol dehydrogenase
1.3.1.57	Phloroglucinol reductase
1.3.1.58	2,3-dihydroxy-2,3-dihydro-p-cumate dehydrogenase
1.3.1.59	1,6-dihydroxy-5-methylcyclohexa-2,4-dienecarboxylate dehydrogenase
1.3.1.5	Cucurbitacin delta(23) reductase
1.3.1.60	Dibenzothiophene dihydrodiol dehydrogenase
1.3.1.61	Terephthalate 1,2-cis-dihydrodiol dehydrogenase
1.3.1.62	Pimeloyl-CoA dehydrogenase
1.3.1.63	2,4-dichlorobenzoyl-CoA reductase
1.3.1.64	Phthalate 4,5-cis-dihydrodiol dehydrogenase
1.3.1.65	5,6-dihydroxy-3-methyl-2-oxo-1,2,5,6-tetrahydroquinolinedehydrogenase
1.3.1.66	Cis-dihydroethylcatechol dehydrogenase
1.3.1.67	Cis-1,2-dihydroxy-4-methylcyclohexa-3,5-diene-1-carboxylatedehydrogenase
1.3.1.68	1,2-dihydroxy-6-methylcyclohexa-3,5-dienecarboxylate dehydrogenase
1.3.1.69	Zeatin reductase
1.3.1.6	Fumarate reductase (NADH)
1.3.1.70	Delta(14)-sterol reductase
1.3.1.71	Delta(24(24(1)))-sterol reductase
1.3.1.72	Delta(24)-sterol reductase
1.3.1.73	1,2-dihydrovomilenine reductase
1.3.1.74	2-alkenal reductase
1.3.1.75	Divinyl chlorophyllide a 8-vinyl-reductase
1.3.1.76	Precorrin-2 dehydrogenase
1.3.1.77	anthocyanidin reductase
1.3.1.7	Meso-tartrate dehydrogenase
1.3.1.8	Acyl-CoA dehydrogenase (NADP+)
1.3.1.9	Enoyl-[acyl-carrier protein] reductase (NADH)
1.3.2.1	Transferred entry: 1.3.99.2
1.3.2.2	Transferred entry: 1.3.99.3
1.3.2.3	Galactonolactone dehydrogenase
1.3.3.10	Tryptophan alpha,beta-oxidase
1.3.3.11	pyrroloquinoline-quinone synthase
1.3.3.1	Dihydroorotate oxidase
1.3.3.2	Lathosterol oxidase
1.3.3.3	Coproporphyrinogen oxidase
1.3.3.4	Protoporphyrinogen oxidase
1.3.3.5	Bilirubin oxidase
1.3.3.6	Acyl-CoA oxidase
1.3.3.7	Dihydrouracil oxidase
1.3.3.8	Tetrahydroberberine oxidase
1.3.3.9	Secologanin synthase
1.3.5.1	Succinate dehydrogenase (ubiquinone)
1.3.7.1	6-hydroxynicotinate reductase
1.3.7.2	15,16-dihydrobiliverdin:ferredoxin oxidoreductase
1.3.7.3	Phycoerythrobilin:ferredoxin oxidoreductase
1.3.7.4	Phytochromobilin:ferredoxin oxidoreductase
1.3.7.5	Phycocyanobilin:ferredoxin oxidoreductase
1.3.99.10	Isovaleryl-CoA dehydrogenase
1.3.99.11	Dihydroorotate dehydrogenase
1.3.99.12	2-methylacyl-CoA dehydrogenase
1.3.99.13	Long-chain acyl-CoA dehydrogenase
1.3.99.14	Cyclohexanone dehydrogenase
1.3.99.15	Benzoyl-CoA reductase
1.3.99.16	Isoquinoline 1-oxidoreductase
1.3.99.17	Quinoline 2-oxidoreductase
1.3.99.18	Quinaldate 4-oxidoreductase
1.3.99.19	Quinoline-4-carboxylate 2-oxidoreductase
1.3.99.1	Succinate dehydrogenase
1.3.99.20	4-hydroxybenzoyl-CoA reductase
1.3.99.21	(R)-benzylsuccinyl-CoA dehydrogenase
1.3.99.22	coproporphyrinogen dehydrogenase
1.3.99.23	all-trans-retinol 13,14-reductase
1.3.99.2	Butyryl-CoA dehydrogenase
1.3.99.3	Acyl-CoA dehydrogenase
1.3.99.4	3-oxosteroid 1-dehydrogenase
1.3.99.5	3-oxo-5-alpha-steroid 4-dehydrogenase
1.3.99.6	3-oxo-5-beta-steroid 4-dehydrogenase
1.3.99.7	Glutaryl-CoA dehydrogenase
1.3.99.8	2-furoyl-CoA dehydrogenase
1.3.99.9	Transferred entry: 1.21.99.1
1.4.1.10	Glycine dehydrogenase
1.4.1.11	L-erythro-3,5-diaminohexanoate dehydrogenase
1.4.1.12	2,4-diaminopentanoate dehydrogenase
1.4.1.13	Glutamate synthase (NADPH)
1.4.1.14	Glutamate synthase (NADH)
1.4.1.15	Lysine dehydrogenase
1.4.1.16	Diaminopimelate dehydrogenase
1.4.1.17	N-methylalanine dehydrogenase
1.4.1.18	Lysine 6-dehydrogenase
1.4.1.19	Tryptophan dehydrogenase
1.4.1.1	Alanine dehydrogenase
1.4.1.20	Phenylalanine dehydrogenase
1.4.1.21	aspartate dehydrogenase
1.4.1.2	Glutamate dehydrogenase
1.4.1.3	Glutamate dehydrogenase (NAD(P)+)
1.4.1.4	Glutamate dehydrogenase (NADP+)
1.4.1.5	L-amino-acid dehydrogenase
1.4.1.6	Transferred entry: 1.21.4.1
1.4.1.7	Serine 2-dehydrogenase
1.4.1.8	Valine dehydrogenase (NADP+)
1.4.1.9	Leucine dehydrogenase
1.4.2.1	Glycine dehydrogenase (cytochrome)
1.4.3.10	Putrescine oxidase
1.4.3.11	L-glutamate oxidase
1.4.3.12	Cyclohexylamine oxidase
1.4.3.13	Protein-lysine 6-oxidase
1.4.3.14	L-lysine oxidase
1.4.3.15	D-glutamate(D-aspartate) oxidase
1.4.3.16	L-aspartate oxidase
1.4.3.17	Transferred entry: 1.3.3.10
1.4.3.18	Deleted entry
1.4.3.19	Glycine oxidase
1.4.3.1	D-aspartate oxidase
1.4.3.2	L-amino acid oxidase
1.4.3.3	D-amino acid oxidase
1.4.3.4	Amine oxidase (flavin-containing)
1.4.3.5	Pyridoxamine-phosphate oxidase
1.4.3.6	Amine oxidase (copper-containing)
1.4.3.7	D-glutamate oxidase
1.4.3.8	Ethanolamine oxidase
1.4.3.9	Transferred entry: 1.4.3.4
1.4.4.1	Transferred entry: 1.21.4.1
1.4.4.2	Glycine dehydrogenase (decarboxylating)
1.4.7.1	Glutamate synthase (ferredoxin)
1.4.99.1	D-amino-acid dehydrogenase
1.4.99.2	Taurine dehydrogenase
1.4.99.3	Amine dehydrogenase
1.4.99.4	Aralkylamine dehydrogenase
1.4.99.5	Glycine dehydrogenase (cyanide-forming)
1.5.1.10	Saccharopine dehydrogenase (NADP+, L-glutamate forming)
1.5.1.11	D-octopine dehydrogenase
1.5.1.12	1-pyrroline-5-carboxylate dehydrogenase
1.5.1.13	Nicotinate dehydrogenase
1.5.1.14	Transferred entry: 1.5.1.21
1.5.1.15	Methylenetetrahydrofolate dehydrogenase (NAD+)
1.5.1.16	D-lysopine dehydrogenase
1.5.1.17	Alanopine dehydrogenase
1.5.1.18	Ephedrine dehydrogenase
1.5.1.19	D-nopaline dehydrogenase
1.5.1.1	Pyrroline-2-carboxylate reductase
1.5.1.20	Methylenetetrahydrofolate reductase (NADPH)
1.5.1.21	Delta(1)-piperideine-2-carboxylate reductase
1.5.1.22	Strombine dehydrogenase
1.5.1.23	Tauropine dehydrogenase
1.5.1.24	N(5)-(carboxyethyl)ornithine synthase
1.5.1.25	Thiomorpholine-carboxylate dehydrogenase
1.5.1.26	Beta-alanopine dehydrogenase
1.5.1.27	1,2-dehydroreticulinium reductase (NADPH)
1.5.1.28	Opine dehydrogenase
1.5.1.29	FMN reductase
1.5.1.2	Pyrroline-5-carboxylate reductase
1.5.1.30	Flavin reductase
1.5.1.31	Berberine reductase
1.5.1.32	Vomilenine reductase
1.5.1.33	Pteridine reductase
1.5.1.34	6,7-dihydropteridine reductase
1.5.1.3	Dihydrofolate reductase
1.5.1.4	Transferred entry: 1.5.1.3
1.5.1.5	Methylenetetrahydrofolate dehydrogenase (NADP+)
1.5.1.6	Formyltetrahydrofolate dehydrogenase
1.5.1.7	Saccharopine dehydrogenase (NAD+, L-lysine forming)
1.5.1.8	Saccharopine dehydrogenase (NADP+, L-lysine forming)
1.5.1.9	Saccharopine dehydrogenase (NAD+, L-glutamate forming)
1.5.3.10	Dimethylglycine oxidase
1.5.3.11	Polyamine oxidase
1.5.3.12	Dihydrobenzophenanthridine oxidase
1.5.3.1	Sarcosine oxidase
1.5.3.2	N-methyl-L-amino-acid oxidase
1.5.3.3	Deleted entry
1.5.3.4	N(6)-methyl-lysine oxidase
1.5.3.5	(S)-6-hydroxynicotine oxidase
1.5.3.6	(R)-6-hydroxynicotine oxidase
1.5.3.7	L-pipecolate oxidase
1.5.3.8	Transferred entry: 1.3.3.8
1.5.3.9	Transferred entry: 1.21.3.3
1.5.4.1	Pyrimidodiazepine synthase
1.5.5.1	Electron-transferring-flavoprotein dehydrogenase
1.5.8.1	Dimethylamine dehydrogenase
1.5.8.2	Trimethylamine dehydrogenase
1.5.99.10	Transferred entry: 1.5.8.1
1.5.99.11	Coenzyme F420-dependent N(5),N(10)-methylenetetrahydromethanopterinreductase
1.5.99.12	Cytokinin dehydrogenase
1.5.99.1	Sarcosine dehydrogenase
1.5.99.2	Dimethylglycine dehydrogenase
1.5.99.3	L-pipecolate dehydrogenase
1.5.99.4	Nicotine dehydrogenase
1.5.99.5	Methylglutamate dehydrogenase
1.5.99.6	Spermidine dehydrogenase
1.5.99.7	Transferred entry: 1.5.8.2
1.5.99.8	Proline dehydrogenase
1.5.99.9	Methylenetetrahydromethanopterin dehydrogenase
1.6.1.1	NAD(P)(+) transhydrogenase (B-specific)
1.6.1.2	NAD(P)(+) transhydrogenase (AB-specific)
1.6.2.1	Transferred entry: 1.6.99.3
1.6.2.2	Cytochrome-b5 reductase
1.6.2.3	Deleted entry
1.6.2.4	NADPH--hemoprotein reductase
1.6.2.5	NADPH--cytochrome c2 reductase
1.6.2.6	Leghemoglobin reductase
1.6.3.1	NADPH oxidase
1.6.4.10	Transferred entry: 1.8.1.14
1.6.4.1	Transferred entry: 1.8.1.6
1.6.4.2	Transferred entry: 1.8.1.7
1.6.4.3	Transferred entry: 1.8.1.4
1.6.4.4	Transferred entry: 1.8.1.8
1.6.4.5	Transferred entry: 1.8.1.9
1.6.4.6	Transferred entry: 1.8.1.10
1.6.4.7	Transferred entry: 1.8.1.11
1.6.4.8	Transferred entry: 1.8.1.12
1.6.4.9	Transferred entry: 1.8.1.13
1.6.5.1	Deleted entry
1.6.5.2	Transferred entry: 1.6.99.2
1.6.5.3	NADH dehydrogenase (ubiquinone)
1.6.5.4	Monodehydroascorbate reductase (NADH)
1.6.5.5	NADPH:quinone reductase
1.6.5.6	p-benzoquinone reductase (NADPH)
1.6.5.7	2-hydroxy-1,4-benzoquinone reductase
1.6.6.10	Transferred entry: 1.7.1.9
1.6.6.11	Transferred entry: 1.7.1.10
1.6.6.12	Transferred entry: 1.7.1.11
1.6.6.13	Transferred entry: 1.7.1.12
1.6.6.1	Transferred entry: 1.7.1.1
1.6.6.2	Transferred entry: 1.7.1.2
1.6.6.3	Transferred entry: 1.7.1.3
1.6.6.4	Transferred entry: 1.7.1.4
1.6.6.5	Transferred entry: 1.7.2.1
1.6.6.6	Transferred entry: 1.7.1.5
1.6.6.7	Transferred entry: 1.7.1.6
1.6.6.8	Transferred entry: 1.7.1.7
1.6.6.9	Trimethylamine-N-oxide reductase
1.6.7.1	Transferred entry: 1.18.1.2
1.6.7.2	Transferred entry: 1.18.1.1
1.6.8.1	Transferred entry: 1.5.1.29
1.6.8.2	Transferred entry: 1.5.1.30
1.6.99.10	Transferred entry: 1.18.1.2
1.6.99.11	Transferred entry: 1.16.1.5
1.6.99.12	Transferred entry: 1.16.1.6
1.6.99.13	Transferred entry: 1.16.1.7
1.6.99.1	NADPH dehydrogenase
1.6.99.2	NAD(P)H dehydrogenase (quinone)
1.6.99.3	NADH dehydrogenase
1.6.99.4	Transferred entry: 1.18.1.2
1.6.99.5	NADH dehydrogenase (quinone)
1.6.99.6	NADPH dehydrogenase (quinone)
1.6.99.7	Transferred entry: 1.5.1.34
1.6.99.8	Transferred entry: 1.16.1.3
1.6.99.9	Transferred entry: 1.16.1.4
1.7.1.10	Hydroxylamine reductase (NADH)
1.7.1.11	4-(dimethylamino)phenylazoxybenzene reductase
1.7.1.12	N-hydroxy-2-acetamidofluorene reductase
1.7.1.1	Nitrate reductase (NADH)
1.7.1.2	Nitrate reductase (NAD(P)H)
1.7.1.3	Nitrate reductase (NADPH)
1.7.1.4	Nitrite reductase [NAD(P)H]
1.7.1.5	Hyponitrite reductase
1.7.1.6	Azobenzene reductase
1.7.1.7	GMP reductase
1.7.1.8	Deleted entry
1.7.1.9	Nitroquinoline-N-oxide reductase
1.7.2.1	Nitrite reductase (NO-forming)
1.7.2.2	Nitrite reductase (cytochrome; ammonia-forming)
1.7.2.3	Trimethylamine-N-oxide reductase (cytochrome c)
1.7.3.1	Nitroethane oxidase
1.7.3.2	Acetylindoxyl oxidase
1.7.3.3	Urate oxidase
1.7.3.4	Hydroxylamine oxidase
1.7.3.5	3-aci-nitropropanoate oxidase
1.7.7.1	Ferredoxin--nitrite reductase
1.7.7.2	Ferredoxin--nitrate reductase
1.7.99.1	Hydroxylamine reductase
1.7.99.2	Deleted entry
1.7.99.3	Transferred entry: 1.7.2.1
1.7.99.4	Nitrate reductase
1.7.99.5	5,10-methylenetetrahydrofolate reductase (FADH)
1.7.99.6	Nitrous-oxide reductase
1.7.99.7	Nitric-oxide reductase
1.7.99.8	Hydroxylamine oxidoreductase
1.8.1.10	CoA-glutathione reductase
1.8.1.11	Asparagusate reductase
1.8.1.12	Trypanothione-disulfide reductase
1.8.1.13	Bis-gamma-glutamylcystine reductase
1.8.1.14	CoA-disulfide reductase
1.8.1.15	Mycothione reductase
1.8.1.1	Deleted entry
1.8.1.2	Sulfite reductase (NADPH)
1.8.1.3	Hypotaurine dehydrogenase
1.8.1.4	Dihydrolipoyl dehydrogenanse
1.8.1.5	2-oxopropyl-CoM reductase (carboxylating)
1.8.1.6	Cystine reductase
1.8.1.7	Glutathione-disulfide reductase
1.8.1.8	Protein-disulfide reductase
1.8.1.9	Thioredoxin-disulfide reductase
1.8.2.1	Sulfite dehydrogenase
1.8.2.2	Thiosulfate dehydrogenase
1.8.3.1	Sulfite oxidase
1.8.3.2	Thiol oxidase
1.8.3.3	Glutathione oxidase
1.8.3.4	Methanethiol oxidase
1.8.3.5	Prenylcysteine oxidase
1.8.4.10	Adenylyl sulfate reductase (thioredoxin)
1.8.4.1	Glutathione--homocystine transhydrogenase
1.8.4.2	Protein-disulfide reductase (glutathione)
1.8.4.3	Glutathione--CoA-glutathione transhydrogenase
1.8.4.4	Glutathione--cystine transhydrogenase
1.8.4.5	Methionine-S-oxide reductase
1.8.4.6	Protein-methionine-S-oxide reductase
1.8.4.7	Enzyme-thiol transhydrogenase (glutathione-disulfide)
1.8.4.8	Phosphoadenylyl-sulfate reductase (thioredoxin)
1.8.4.9	Adenylyl-sulfate reductase (glutathione)
1.8.5.1	Glutathione dehydrogenase (ascorbate)
1.8.6.1	Transferred entry: 2.5.1.18
1.8.7.1	Sulfite reductase (ferredoxin)
1.8.98.1	CoB--CoM heterodisulfide reductase
1.8.98.2	sulfiredoxin
1.8.99.1	Sulfite reductase
1.8.99.2	Adenylylsulfate reductase
1.8.99.3	Hydrogensulfite reductase
1.8.99.4	Transferred entry: 1.8.4.8
1.9.3.1	Cytochrome-c oxidase
1.9.3.2	Transferred entry: 1.7.2.1
1.9.6.1	Nitrate reductase (cytochrome)
1.97.1.10	Thyroxine 5'-deiodinase
1.97.1.11	Thyroxine 5-deiodinase
1.97.1.1	Chlorate reductase
1.97.1.2	Pyrogallol hydroxytransferase
1.97.1.3	Sulfur reductase
1.97.1.4	Formate acetyltransferase activating enzyme
1.97.1.5	Transferred entry: 1.20.4.1
1.97.1.6	Transferred entry: 1.20.99.1
1.97.1.7	Transferred entry: 1.20.4.2
1.97.1.8	Tetrachloroethene reductive dehalogenase
1.97.1.9	Selenate reductase
1.9.99.1	Iron--cytochrome-c reductase
2.1.1.100	Protein-S isoprenylcysteine O-methyltransferase
2.1.1.101	Macrocin O-methyltransferase
2.1.1.102	Demethylmacrocin O-methyltransferase
2.1.1.103	Phosphoethanolamine N-methyltransferase
2.1.1.104	Caffeoyl-CoA O-methyltransferase
2.1.1.105	N-benzoyl-4-hydroxyanthranilate 4-O-methyltransferase
2.1.1.106	Tryptophan 2-C-methyltransferase
2.1.1.107	Uroporphyrin-III C-methyltransferase
2.1.1.108	6-hydroxymellein O-methyltransferase
2.1.1.109	Demethylsterigmatocystin 6-O-methyltransferase
2.1.1.10	Homocysteine S-methyltransferase
2.1.1.110	Sterigmatocystin 7-O-methyltransferase
2.1.1.111	Anthranilate N-methyltransferase
2.1.1.112	Glucuronoxylan 4-O-methyltransferase
2.1.1.113	Site-specific DNA-methyltransferase (cytosine-N(4)-specific)
2.1.1.114	Hexaprenyldihydroxybenzoate methyltransferase
2.1.1.115	(R,S)-1-benzyl-1,2,3,4-tetrahydroisoquinoline N-methyltransferase
2.1.1.116	3'-hydroxy-N-methyl-(S)-coclaurine 4'-O-methyltransferase
2.1.1.117	(S)-scoulerine 9-O-methyltransferase
2.1.1.118	Columbamine O-methyltransferase
2.1.1.119	10-hydroxydihydrosanguinarine 10-O-methyltransferase
2.1.1.11	Magnesium protoporphyrin IX methyltransferase
2.1.1.120	12-hydroxydihydrochelirubine 12-O-methyltransferase
2.1.1.121	6-O-methylnorlaudanosoline 5'-O-methyltransferase
2.1.1.122	(S)-tetrahydroprotoberberine N-methyltransferase
2.1.1.123	[Cytochrome-c]-methionine S-methyltransferase
2.1.1.124	[Cytochrome-c]-arginine N-methyltransferase
2.1.1.125	Histone-arginine N-methyltransferase
2.1.1.126	[Myelin basic protein]-arginine N-methyltransferase
2.1.1.127	[Ribulose-bisphosphate-carboxylase]-lysine N-methyltransferase
2.1.1.128	(R,S)-norcoclaurine 6-O-methyltransferase
2.1.1.129	Inositol 4-methyltransferase
2.1.1.12	Methionine S-methyltransferase
2.1.1.130	Precorrin-2 C(20)-methyltransferase
2.1.1.131	Precorrin-3B C(17)-methyltransferase
2.1.1.132	Precorrin-6Y C(5,15)-methyltransferase (decarboxylating)
2.1.1.133	Precorrin-4 C(11)-methyltransferase
2.1.1.134	Transferred entry: 2.1.1.129
2.1.1.135	Transferred entry: 1.16.1.8
2.1.1.136	Chlorophenol O-methyltransferase
2.1.1.137	Arsenite methyltransferase
2.1.1.138	Deleted entry
2.1.1.139	3'-demethylstaurosporine O-methyltransferase
2.1.1.13	Methionine synthase
2.1.1.140	(S)-coclaurine-N-methyltransferase
2.1.1.141	Jasmonate O-methyltransferase
2.1.1.142	Cycloartenol 24-C-methyltransferase
2.1.1.143	24-methylenesterol C-methyltransferase
2.1.1.144	Trans-aconitate 2-methyltransferase
2.1.1.14	5-methyltetrahydropteroyltriglutamate--homocysteine S-methyltransferase
2.1.1.145	Trans-aconitate 3-methyltransferase
2.1.1.146	(Iso)eugenol O-methyltransferase
2.1.1.147	Corydaline synthase
2.1.1.148	Thymidylate synthase (FAD)
2.1.1.149	Myricetin O-methyltransferase
2.1.1.150	Isoflavone 7-O-methyltransferase
2.1.1.151	Cobalt-factor II C(20)-methyltransferase
2.1.1.152	Precorrin-6A synthase (deacetylating)
2.1.1.15	Fatty-acid O-methyltransferase
2.1.1.16	Methylene-fatty-acyl-phospholipid synthase
2.1.1.17	Phosphatidylethanolamine N-methyltransferase
2.1.1.18	Polysaccharide O-methyltransferase
2.1.1.19	Trimethylsulfonium--tetrahydrofolate N-methyltransferase
2.1.1.1	Nicotinamide N-methyltransferase
2.1.1.20	Glycine N-methyltransferase
2.1.1.21	Methylamine--glutamate N-methyltransferase
2.1.1.22	Carnosine N-methyltransferase
2.1.1.23	Transferred entry: 2.1.1.124, 2.1.1.125 and 2.1.1.126
2.1.1.24	Transferred entry: 2.1.1.77, 2.1.1.80 and 2.1.1.100
2.1.1.25	Phenol O-methyltransferase
2.1.1.26	Iodophenol O-methyltransferase
2.1.1.27	Tyramine N-methyltransferase
2.1.1.28	Phenylethanolamine N-methyltransferase
2.1.1.29	tRNA (cytosine-5-)-methyltransferase
2.1.1.2	Guanidinoacetate N-methyltransferase
2.1.1.30	Deleted entry
2.1.1.31	tRNA (guanine-N(1)-)-methyltransferase
2.1.1.32	tRNA (guanine-N(2)-)-methyltransferase
2.1.1.33	tRNA (guanine-N(7)-)-methyltransferase
2.1.1.34	tRNA (guanosine-2'-O-)-methyltransferase
2.1.1.35	tRNA (uracil-5-)-methyltransferase
2.1.1.36	tRNA (adenine-N(1)-)-methyltransferase
2.1.1.37	DNA (cytosine-5-)-methyltransferase
2.1.1.38	O-demethylpuromycin O-methyltransferase
2.1.1.39	Inositol 3-methyltransferase
2.1.1.3	Thetin--homocysteine S-methyltransferase
2.1.1.40	Inositol 1-methyltransferase
2.1.1.41	Sterol 24-C-methyltransferase
2.1.1.42	Luteolin O-methyltransferase
2.1.1.43	Histone-lysine N-methyltransferase
2.1.1.44	Dimethylhistidine N-methyltransferase
2.1.1.45	Thymidylate synthase
2.1.1.46	Isoflavone 4'-O-methyltransferase
2.1.1.47	Indole-3-pyruvate C-methyltransferase
2.1.1.48	rRNA (adenine-N(6)-)-methyltransferase
2.1.1.49	Amine N-methyltransferase
2.1.1.4	Acetylserotonin O-methyltransferase
2.1.1.50	Loganate O-methyltransferase
2.1.1.51	rRNA (guanine-N(1)-)-methyltransferase
2.1.1.52	rRNA (guanine-N(2)-)-methyltransferase
2.1.1.53	Putrescine N-methyltransferase
2.1.1.54	Deoxycytidylate C-methyltransferase
2.1.1.55	tRNA (adenine-N(6)-)-methyltransferase
2.1.1.56	mRNA (guanine-N(7)-)-methyltransferase
2.1.1.57	mRNA (nucleoside-2'-O-)-methyltransferase
2.1.1.58	Transferred entry: 2.1.1.57
2.1.1.59	[Cytochrome c]-lysine N-methyltransferase
2.1.1.5	Betaine--homocysteine S-methyltransferase
2.1.1.60	Calmodulin-lysine N-methyltransferase
2.1.1.61	tRNA (5-methylaminomethyl-2-thiouridylate)-methyltransferase
2.1.1.62	mRNA (2'-O-methyladenosine-N(6)-)-methyltransferase
2.1.1.63	Methylated-DNA--[protein]-cysteine S-methyltransferase
2.1.1.64	3-demethylubiquinone-9 3-O-methyltransferase
2.1.1.65	Licodione 2'-O-methyltransferase
2.1.1.66	rRNA (adenosine-2'-O-)-methyltransferase
2.1.1.67	Thiopurine S-methyltransferase
2.1.1.68	Caffeate O-methyltransferase
2.1.1.69	5-hydroxyfuranocoumarin 5-O-methyltransferase
2.1.1.6	Catechol O-methyltransferase
2.1.1.70	8-hydroxyfuranocoumarin 8-O-methyltransferase
2.1.1.71	Phosphatidyl-N-methylethanolamine N-methyltransferase
2.1.1.72	Site-specific DNA-methyltransferase (adenine-specific)
2.1.1.73	Transferred entry: 2.1.1.37
2.1.1.74	Methylenetetrahydrofolate--tRNA-(uracil-5-)-methyltransferase(FADH-oxidizing)
2.1.1.75	Apigenin 4'-O-methyltransferase
2.1.1.76	Quercetin 3-O-methyltransferase
2.1.1.77	Protein-L-isoaspartate(D-aspartate) O-methyltransferase
2.1.1.78	Isoorientin 3'-O-methyltransferase
2.1.1.79	Cyclopropane-fatty-acyl-phospholipid synthase
2.1.1.7	Nicotinate N-methyltransferase
2.1.1.80	Protein-glutamate O-methyltransferase
2.1.1.81	Transferred entry: 2.1.1.49
2.1.1.82	3-methylquercetin 7-O-methyltransferase
2.1.1.83	3,7-dimethylquercetin 4'-O-methyltransferase
2.1.1.84	Methylquercetagetin 6-O-methyltransferase
2.1.1.85	Protein-histidine N-methyltransferase
2.1.1.86	Tetrahydromethanopterin S-methyltransferase
2.1.1.87	Pyridine N-methyltransferase
2.1.1.88	8-hydroxyquercetin 8-O-methyltransferase
2.1.1.89	Tetrahydrocolumbamine 2-O-methyltransferase
2.1.1.8	Histamine N-methyltransferase
2.1.1.90	Methanol--5-hydroxybenzimidazolylcobamide Co-methyltransferase
2.1.1.91	Isobutyraldoxime O-methyltransferase
2.1.1.92	Bergaptol O-methyltransferase
2.1.1.93	Xanthotoxol O-methyltransferase
2.1.1.94	11-O-demethyl-17-O-deacetylvindoline O-methyltransferase
2.1.1.95	Tocopherol O-methyltransferase
2.1.1.96	Thioether S-methyltransferase
2.1.1.97	3-hydroxyanthranilate 4-C-methyltransferase
2.1.1.98	Diphthine synthase
2.1.1.99	16-methoxy-2,3-dihydro-3-hydroxytabersonine N-methyltransferase
2.1.1.9	Thiol S-methyltransferase
2.1.2.10	Aminomethyltransferase
2.1.2.11	3-methyl-2-oxobutanoate hydroxymethyltransferase
2.1.2.1	Glycine hydroxymethyltransferase
2.1.2.2	Phosphoribosylglycinamide formyltransferase
2.1.2.3	Phosphoribosylaminoimidazolecarboxamide formyltransferase
2.1.2.4	Glycine formimidoyltransferase
2.1.2.5	Glutamate formimidoyltransferase
2.1.2.6	Transferred entry: 2.1.2.5
2.1.2.7	D-alanine hydroxymethyltransferase
2.1.2.8	Deoxycytidylate hydroxymethyltransferase
2.1.2.9	Methionyl-tRNA formyltransferase
2.1.3.1	Methylmalonyl-CoA carboxytransferase
2.1.3.2	Aspartate carbamoyltransferase
2.1.3.3	Ornithine carbamoyltransferase
2.1.3.4	Deleted entry
2.1.3.5	Oxamate carbamoyltransferase
2.1.3.6	Putrescine carbamoyltransferase
2.1.3.7	3-hydroxymethylcephem carbamoyltransferase
2.1.3.8	Lysine carbamoyltransferase
2.1.3.9	N-acetylornithine carbamoyltransferase
2.1.4.1	Glycine amidinotransferase
2.1.4.2	Scyllo-inosamine-4-phosphate amidinotransferase
2.2.1.1	Transketolase
2.2.1.2	Transaldolase
2.2.1.3	Formaldehyde transketolase
2.2.1.4	Acetoin--ribose-5-phosphate transaldolase
2.2.1.5	2-hydroxy-3-oxoadipate synthase
2.2.1.6	Acetolactate synthase
2.2.1.7	1-deoxy-D-xylulose 5-phosphate synthase
2.2.1.8	Fluorothreonine transaldolase
2.3.1.100	Myelin-proteolipid O-palmitoyltransferase
2.3.1.101	Formylmethanofuran--tetrahydromethanopterin N-formyltransferase
2.3.1.102	N(6)-hydroxylysine O-acetyltransferase
2.3.1.103	Sinapoylglucose--sinapoylglucose O-sinapoyltransferase
2.3.1.104	1-alkenylglycerophosphocholine O-acyltransferase
2.3.1.105	Alkylglycerophosphate 2-O-acetyltransferase
2.3.1.106	Tartronate O-hydroxycinnamoyltransferase
2.3.1.107	17-O-deacetylvindoline O-acetyltransferase
2.3.1.108	Tubulin N-acetyltransferase
2.3.1.109	Arginine N-succinyltransferase
2.3.1.10	Hydrogen-sulfide S-acetyltransferase
2.3.1.110	Tyramine N-feruloyltransferase
2.3.1.111	Mycocerosate synthase
2.3.1.112	D-tryptophan N-malonyltransferase
2.3.1.113	Anthranilate N-malonyltransferase
2.3.1.114	3,4-dichloroaniline N-malonyltransferase
2.3.1.115	Isoflavone-7-O-beta-glucoside 6''-O-malonyltransferase
2.3.1.116	Flavonol-3-O-beta-glucoside O-malonyltransferase
2.3.1.117	2,3,4,5-tetrahydropyridine-2,6-dicarboxylate N-succinyltransferase
2.3.1.118	N-hydroxyarylamine O-acetyltransferase
2.3.1.119	Icosanoyl-CoA synthase
2.3.1.11	Thioethanolamine S-acetyltransferase
2.3.1.120	Deleted entry
2.3.1.121	1-alkenylglycerophosphoethanolamine O-acyltransferase
2.3.1.122	Trehalose O-mycolyltransferase
2.3.1.123	Dolichol O-acyltransferase
2.3.1.124	Deleted entry
2.3.1.125	1-alkyl-2-acetylglycerol O-acyltransferase
2.3.1.126	Isocitrate O-dihydroxycinnamoyltransferase
2.3.1.127	Ornithine N-benzoyltransferase
2.3.1.128	Ribosomal-protein-alanine N-acetyltransferase
2.3.1.129	Acyl-[acyl-carrier-protein]--UDP-N-acetylglucosamine O-acyltransferase
2.3.1.12	Dihydrolipoyllysine-residue acetyltransferase
2.3.1.130	Galactarate O-hydroxycinnamoyltransferase
2.3.1.131	Glucarate O-hydroxycinnamoyltransferase
2.3.1.132	Glucarolactone O-hydroxycinnamoyltransferase
2.3.1.133	Shikimate O-hydroxycinnamoyltransferase
2.3.1.134	Galactolipid O-acyltransferase
2.3.1.135	Phosphatidylcholine--retinol O-acyltransferase
2.3.1.136	Polysialic-acid O-acetyltransferase
2.3.1.137	Carnitine O-octanoyltransferase
2.3.1.138	Putrescine N-hydroxycinnamoyltransferase
2.3.1.139	Ecdysone O-acyltransferase
2.3.1.13	Glycine N-acyltransferase
2.3.1.140	Rosmarinate synthase
2.3.1.141	Galactosylacylglycerol O-acyltransferase
2.3.1.142	Glycoprotein O-fatty-acyltransferase
2.3.1.143	Beta-glucogallin--tetrakisgalloylglucose O-galloyltransferase
2.3.1.144	Anthranilate N-benzoyltransferase
2.3.1.145	Piperidine N-piperoyltransferase
2.3.1.146	Pinosylvin synthase
2.3.1.147	Glycerophospholipid arachidonoyl-transferase (CoA-independent)
2.3.1.148	Glycerophospholipid acyltransferase (CoA-dependent)
2.3.1.149	Platelet-activating factor acetyltransferase
2.3.1.14	Glutamine N-phenylacetyltransferase
2.3.1.150	Salutaridinol 7-O-acetyltransferase
2.3.1.151	Benzophenone synthase
2.3.1.152	Alcohol O-cinnamoyltransferase
2.3.1.153	Anthocyanin 5-aromatic acyltransferase
2.3.1.154	Propionyl-CoA C(2)-trimethyltridecanoyltransferase
2.3.1.155	Acetyl-CoA C-myristoyltransferase
2.3.1.156	Phloroisovalerophenone synthase
2.3.1.157	Glucosamine-1-phosphate N-acetyltransferase
2.3.1.158	Phospholipid:diacylglycerol acyltransferase
2.3.1.159	Acridone synthase
2.3.1.15	Glycerol-3-phosphate O-acyltransferase
2.3.1.160	Vinorine synthase
2.3.1.161	Lovastatin nonaketide synthase
2.3.1.162	Taxadien-5-alpha-ol O-acetyltransferase
2.3.1.163	10-hydroxytaxane O-acetyltransferase
2.3.1.164	Isopenicillin N N-acyltransferase
2.3.1.165	6-methylsalicylic acid synthase
2.3.1.166	2-alpha-hydroxytaxane 2-O-benzoyltransferase
2.3.1.167	10-deacetylbaccatin III 10-O-acetyltransferase
2.3.1.168	Dihydrolipoyllysine-residue (2-methylpropanoyl)transferase
2.3.1.169	CO-methylating acetyl-CoA synthase
2.3.1.16	Acetyl-CoA C-acyltransferase
2.3.1.170	6'-deoxychalcone synthase
2.3.1.175	deacetylcephalosporin-C acetyltransferase
2.3.1.176	propanoyl-CoA C-acyltransferase
2.3.1.17	Aspartate N-acetyltransferase
2.3.1.18	Galactoside O-acetyltransferase
2.3.1.19	Phosphate butyryltransferase
2.3.1.1	Amino-acid N-acetyltransferase
2.3.1.20	Diacylglycerol O-acyltransferase
2.3.1.21	Carnitine O-palmitoyltransferase
2.3.1.22	2-acylglycerol O-acyltransferase
2.3.1.23	1-acylglycerophosphocholine O-acyltransferase
2.3.1.24	Sphingosine N-acyltransferase
2.3.1.25	Plasmalogen synthase
2.3.1.26	Sterol O-acyltransferase
2.3.1.27	Cortisol O-acetyltransferase
2.3.1.28	Chloramphenicol O-acetyltransferase
2.3.1.29	Glycine C-acetyltransferase
2.3.1.2	Imidazole N-acetyltransferase
2.3.1.30	Serine O-acetyltransferase
2.3.1.31	Homoserine O-acetyltransferase
2.3.1.32	Lysine N-acetyltransferase
2.3.1.33	Histidine N-acetyltransferase
2.3.1.34	D-tryptophan N-acetyltransferase
2.3.1.35	Glutamate N-acetyltransferase
2.3.1.36	D-amino-acid N-acetyltransferase
2.3.1.37	5-aminolevulinic acid synthase
2.3.1.38	[Acyl-carrier protein] S-acetyltransferase
2.3.1.39	[Acyl-carrier protein] S-malonyltransferase
2.3.1.3	Glucosamine N-acetyltransferase
2.3.1.40	Acyl-[acyl-carrier protein]--phospholipid O-acyltransferase
2.3.1.41	3-oxoacyl-[acyl-carrier protein] synthase
2.3.1.42	Glycerone-phosphate O-acyltransferase
2.3.1.43	Phosphatidylcholine--sterol O-acyltransferase
2.3.1.44	N-acetylneuraminate 4-O-acetyltransferase
2.3.1.45	N-acetylneuraminate 7-O(or 9-O)-acetyltransferase
2.3.1.46	Homoserine O-succinyltransferase
2.3.1.47	8-amino-7-oxononanoate synthase
2.3.1.48	Histone acetyltransferase
2.3.1.49	Deacetyl-[citrate-(pro-3S)-lyase] S-acetyltransferase
2.3.1.4	Glucosamine 6-phosphate N-acetyltransferase
2.3.1.50	Serine C-palmitoyltransferase
2.3.1.51	1-acylglycerol-3-phosphate O-acyltransferase
2.3.1.52	2-acylglycerol-3-phosphate O-acyltransferase
2.3.1.53	Phenylalanine N-acetyltransferase
2.3.1.54	Formate C-acetyltransferase
2.3.1.55	Transferred entry: 2.3.1.82
2.3.1.56	Aromatic-hydroxylamine O-acetyltransferase
2.3.1.57	Diamine N-acetyltransferase
2.3.1.58	2,3-diaminopropionate N-oxalyltransferase
2.3.1.59	Gentamicin 2'-N-acetyltransferase
2.3.1.5	Arylamine N-acetyltransferase
2.3.1.60	Gentamicin 3'-N-acetyltransferase
2.3.1.61	Dihydrolipoyllysine-residue succinyltransferase
2.3.1.62	2-acylglycerophosphocholine O-acyltransferase
2.3.1.63	1-alkylglycerophosphocholine O-acyltransferase
2.3.1.64	Agmatine N(4)-coumaroyltransferase
2.3.1.65	Glycine N-choloyltransferase
2.3.1.66	Leucine N-acetyltransferase
2.3.1.67	1-alkylglycerophosphocholine O-acetyltransferase
2.3.1.68	Glutamine N-acyltransferase
2.3.1.69	Monoterpenol O-acetyltransferase
2.3.1.6	Choline O-acetyltransferase
2.3.1.70	CDP-acylglycerol O-arachidonoyltransferase
2.3.1.71	Glycine N-benzoyltransferase
2.3.1.72	Indoleacetylglucose--inositol O-acyltransferase
2.3.1.73	Diacylglycerol--sterol O-acyltransferase
2.3.1.74	Naringenin-chalcone synthase
2.3.1.75	Long-chain-alcohol O-fatty-acyltransferase
2.3.1.76	Retinol O-fatty-acyltransferase
2.3.1.77	Triacylglycerol--sterol O-acyltransferase
2.3.1.78	Heparan-alpha-glucosaminide N-acetyltransferase
2.3.1.79	Maltose O-acetyltransferase
2.3.1.7	Carnitine O-acetyltransferase
2.3.1.80	Cysteine-S-conjugate N-acetyltransferase
2.3.1.81	Aminoglycoside N(3')-acetyltransferase
2.3.1.82	Kanamycin 6'-N-acetyltransferase
2.3.1.83	Phosphatidylcholine--dolichol O-acyltransferase
2.3.1.84	Alcohol O-acetyltransferase
2.3.1.85	Fatty-acid synthase
2.3.1.86	Fatty-acyl-CoA synthase
2.3.1.87	Aralkylamine N-acetyltransferase
2.3.1.88	Peptide alpha-N-acetyltransferase
2.3.1.89	Tetrahydrodipicolinate N-acetyltransferase
2.3.1.8	Phosphate acetyltransferase
2.3.1.90	Beta-glucogallin O-galloyltransferase
2.3.1.91	Sinapoylglucose--choline O-sinapoyltransferase
2.3.1.92	Sinapoylglucose--malate O-sinapoyltransferase
2.3.1.93	13-hydroxylupinine O-tigloyltransferase
2.3.1.94	Erythronolide synthase
2.3.1.95	Trihydroxystilbene synthase
2.3.1.96	Glycoprotein N-palmitoyltransferase
2.3.1.97	Glycylpeptide N-tetradecanoyltransferase
2.3.1.98	Chlorogenate--glucarate O-hydroxycinnamoyltransferase
2.3.1.99	Quinate O-hydroxycinnamoyltransferase
2.3.1.9	Acetyl-CoA C-acetyltransferase
2.3.2.10	UDP-N-acetylmuramoylpentapeptide-lysine N(6)-alanyltransferase
2.3.2.11	Alanylphosphatidylglycerol synthase
2.3.2.12	Peptidyltransferase
2.3.2.13	Protein-glutamine gamma-glutamyltransferase
2.3.2.14	D-alanine gamma-glutamyltransferase
2.3.2.15	Glutathione gamma-glutamylcysteinyltransferase
2.3.2.1	D-glutamyltransferase
2.3.2.2	Gamma-glutamyltransferase
2.3.2.3	Lysyltransferase
2.3.2.4	Gamma-glutamylcyclotransferase
2.3.2.5	Glutaminyl-peptide cyclotransferase
2.3.2.6	Leucyltransferase
2.3.2.7	Aspartyltransferase
2.3.2.8	Arginyltransferase
2.3.2.9	Agaritine gamma-glutamyltransferase
2.3.3.10	Hydroxymethylglutaryl-CoA synthase
2.3.3.11	2-hydroxyglutarate synthase
2.3.3.12	3-propylmalate synthase
2.3.3.13	2-isopropylmalate synthase
2.3.3.14	Homocitrate synthase
2.3.3.15	Sulfoacetaldehyde acetyltransferase
2.3.3.1	Citrate (Si)-synthase
2.3.3.2	Decylcitrate synthase
2.3.3.3	Citrate (Re)-synthase
2.3.3.4	Decylhomocitrate synthase
2.3.3.5	2-methylcitrate synthase
2.3.3.6	2-ethylmalate synthase
2.3.3.7	3-ethylmalate synthase
2.3.3.8	ATP citrate synthase
2.3.3.9	Malate synthase
2.4.1.100	1,2-beta-fructan 1F-fructosyltransferase
2.4.1.101	Alpha-1,3-mannosyl-glycoprotein 2-beta-N-acetylglucosaminyltransferase
2.4.1.102	Beta-1,3-galactosyl-O-glycosyl-glycoprotein beta-1,6-N-acetylglucosaminyltransferase
2.4.1.103	Alizarin 2-beta-glucosyltransferase
2.4.1.104	O-dihydroxycoumarin 7-O-glucosyltransferase
2.4.1.105	Vitexin beta-glucosyltransferase
2.4.1.106	Isovitexin beta-glucosyltransferase
2.4.1.107	Transferred entry: 2.4.1.17
2.4.1.108	Transferred entry: 2.4.1.17
2.4.1.109	Dolichyl-phosphate-mannose--protein mannosyltransferase
2.4.1.10	Levansucrase
2.4.1.110	tRNA-queuosine beta-mannosyltransferase
2.4.1.111	Coniferyl-alcohol glucosyltransferase
2.4.1.112	Alpha-1,4-glucan-protein synthase (UDP-forming)
2.4.1.113	Alpha-1,4-glucan-protein synthase (ADP-forming)
2.4.1.114	2-coumarate O-beta-glucosyltransferase
2.4.1.115	Anthocyanidin 3-O-glucosyltransferase
2.4.1.116	Cyanidin-3-rhamnosylglucoside 5-O-glucosyltransferase
2.4.1.117	Dolichyl-phosphate beta-glucosyltransferase
2.4.1.118	Cytokinin 7-beta-glucosyltransferase
2.4.1.119	Dolichyl-diphosphooligosaccharide--protein glycosyltransferase
2.4.1.11	Glycogen (starch) synthase
2.4.1.120	Sinapate 1-glucosyltransferase
2.4.1.121	Indole-3-acetate beta-glucosyltransferase
2.4.1.122	Glycoprotein-N-acetylgalactosamine 3-beta-galactosyltransferase
2.4.1.123	Inositol 3-alpha-galactosyltransferase
2.4.1.124	Transferred entry: 2.4.1.87
2.4.1.125	Sucrose-1,6-alpha-glucan 3(6)-alpha-glucosyltransferase
2.4.1.126	Hydroxycinnamate 4-beta-glucosyltransferase
2.4.1.127	Monoterpenol beta-glucosyltransferase
2.4.1.128	Scopoletin glucosyltransferase
2.4.1.129	Peptidoglycan glycosyltransferase
2.4.1.12	Cellulose synthase (UDP-forming)
2.4.1.130	Dolichyl-phosphate-mannose-glycolipid alpha-mannosyltransferase
2.4.1.131	Glycolipid 2-alpha-mannosyltransferase
2.4.1.132	Glycolipid 3-alpha-mannosyltransferase
2.4.1.133	Xylosylprotein 4-beta-galactosyltransferase
2.4.1.134	Galactosylxylosylprotein 3-beta-galactosyltransferase
2.4.1.135	Galactosylgalactosylxylosylprotein 3-beta-glucuronosyltransferase
2.4.1.136	Gallate 1-beta-glucosyltransferase
2.4.1.137	Sn-glycerol-3-phosphate 2-alpha-galactosyltransferase
2.4.1.138	Mannotetraose 2-alpha-N-acetylglucosaminyltransferase
2.4.1.139	Maltose synthase
2.4.1.13	Sucrose synthase
2.4.1.140	Alternansucrase
2.4.1.141	N-acetylglucosaminyldiphosphodolichol N-acetylglucosaminyltransferase
2.4.1.142	Chitobiosyldiphosphodolichol beta-mannosyltransferase
2.4.1.143	Alpha-1,6-mannosyl-glycoprotein 2-beta-N-acetylglucosaminyltransferase
2.4.1.144	Beta-1,4-mannosyl-glycoprotein 4-beta-N-acetylglucosaminyltransferase
2.4.1.145	Alpha-1,3-mannosyl-glycoprotein 4-beta-N-acetylglucosaminyltransferase
2.4.1.146	Beta-1,3-galactosyl-O-glycosyl-glycoprotein beta-1,3-N-acetylglucosaminyltransferase
2.4.1.147	Acetylgalactosaminyl-O-glycosyl-glycoprotein beta-1,3-N-acetylglucosaminyltransferase
2.4.1.148	Acetylgalactosaminyl-O-glycosyl-glycoprotein beta-1,6-N-acetylglucosaminyltransferase
2.4.1.149	N-acetyllactosaminide beta-1,3-N-acetylglucosaminyltransferase
2.4.1.14	Sucrose-phosphate synthase
2.4.1.150	N-acetyllactosaminide beta-1,6-N-acetylglucosaminyltransferase
2.4.1.151	Transferred entry: 2.4.1.87
2.4.1.152	4-galactosyl-N-acetylglucosaminide 3-alpha-L-fucosyltransferase
2.4.1.153	Dolichyl-phosphate alpha-N-acetylglucosaminyltransferase
2.4.1.154	Globotriosylceramide beta-1,6-N-acetylgalactosaminyltransferase
2.4.1.155	Alpha-1,6-mannosyl-glycoprotein 6-beta-N-acetylglucosaminyltransferase
2.4.1.156	Indolylacetyl-myo-inositol galactosyltransferase
2.4.1.157	1,2-diacylglycerol 3-glucosyltransferase
2.4.1.158	13-hydroxydocosanoate 13-beta-glucosyltransferase
2.4.1.159	Flavonol-3-O-glucoside L-rhamnosyltransferase
2.4.1.15	Alpha,alpha-trehalose-phosphate synthase (UDP-forming)
2.4.1.160	Pyridoxine 5'-O-beta-D-glucosyltransferase
2.4.1.161	Oligosaccharide 4-alpha-D-glucosyltransferase
2.4.1.162	Aldose beta-D-fructosyltransferase
2.4.1.163	Beta-galactosyl-N-acetylglucosaminylgalactosyl-glucosylceramideBeta-1,3-acetylglucosaminyltransferase
2.4.1.164	Galactosyl-N-acetylglucosaminylgalactosyl-glucosylceramide beta-1,6-N-acetylglucosaminyltransferase
2.4.1.165	N-acetylneuraminylgalactosylglucosylceramide beta-1,4-N-acetylgalactosaminyltransferase
2.4.1.166	Raffinose--raffinose alpha-galactosyltransferase
2.4.1.167	Sucrose 6(F)-alpha-galactosyltransferase
2.4.1.168	Xyloglucan 4-glucosyltransferase
2.4.1.169	Transferred entry: 2.4.2.39
2.4.1.16	Chitin synthase
2.4.1.170	Isoflavone 7-O-glucosyltransferase
2.4.1.171	Methyl-ONN-azoxymethanol glucosyltransferase
2.4.1.172	Salicyl-alcohol glucosyltransferase
2.4.1.173	Sterol glucosyltransferase
2.4.1.174	Glucuronylgalactosylproteoglycan 4-beta-N-acetylgalactosaminyltransferase
2.4.1.175	Glucuronosyl-N-acetylgalactosaminyl-proteoglycan 4-beta-N-acetylgalactosaminyltransferase
2.4.1.176	Gibberellin beta-glucosyltransferase
2.4.1.177	Cinnamate glucosyltransferase
2.4.1.178	Hydroxymandelonitrile glucosyltransferase
2.4.1.179	Lactosylceramide beta-1,3-galactosyltransferase
2.4.1.17	UDP-glucuronosyltransferase
2.4.1.180	Lipopolysaccharide N-acetylmannosaminouronosyltransferase
2.4.1.18	1,4-alpha-glucan branching enzyme
2.4.1.181	Hydroxyanthraquinone glucosyltransferase
2.4.1.182	Lipid-A-disaccharide synthase
2.4.1.183	Alpha-1,3-glucan synthase
2.4.1.184	Galactolipid galactosyltransferase
2.4.1.185	Flavonone 7-O-beta-glucosyltransferase
2.4.1.186	Glycogenin glucosyltransferase
2.4.1.187	N-acetylglucosaminyldiphosphoundecaprenol N-acetyl-beta-D-mannosaminyltransferase
2.4.1.188	N-acetylglucosaminyldiphosphoundecaprenol glucosyltransferase
2.4.1.189	Luteolin 7-O-glucoronosyltransferase
2.4.1.190	Luteolin-7-O-glucuronide 7-O-glucuronosyltransferase
2.4.1.191	Luteolin-7-O-diglucuronide 4'-O-glucuronosyltransferase
2.4.1.192	Nuatigenin 3-beta-glucosyltransferase
2.4.1.193	Sarsapogenin 3-beta-glucosyltransferase
2.4.1.194	4-hydroxybenzoate 4-O-beta-D-glucosyltransferase
2.4.1.195	Thiohydroximate beta-D-glucosyltransferase
2.4.1.196	Nicotinate glucosyltransferase
2.4.1.197	High-mannose-oligosaccharide beta-1,4-N-acetyl-glucosaminyltransferase
2.4.1.198	Phosphatidylinositol N-acetylglucosaminyltransferase
2.4.1.199	Beta-mannosylphosphodecaprenol-mannooligosaccharide6-mannosyltransferase
2.4.1.19	Cyclomaltodextrin glucanotransferase
2.4.1.1	Phosphorylase
2.4.1.200	Transferred entry: 4.2.2.17
2.4.1.201	Alpha-1,6-mannosyl-glycoprotein 4-beta-N-acetylglucosaminyltransferase
2.4.1.202	2,4-dihydroxy-7-methoxy-2H-1,4-benzoxazin-3(4H)-one2-D-glucosyltransferase
2.4.1.203	Trans-zeatin O-beta-D-glucosyltransferase
2.4.1.204	Transferred entry: 2.4.2.40
2.4.1.205	Galactogen 6-beta-galactosyltransferase
2.4.1.206	Lactosylceramide 1,3-N-acetyl-beta-D-glucosaminyl-transferase
2.4.1.207	Xyloglucan:xyloglucosyl transferase
2.4.1.208	Diglucosyl diacylglycerol (DGlcDAG) synthase
2.4.1.209	Cis-p-coumarate glucosyltransferase
2.4.1.20	Cellobiose phosphorylase
2.4.1.210	Limonoid glucosyltransferase
2.4.1.211	1,3-beta-galactosyl-N-acetylhexosamine phosphorylase
2.4.1.212	Hyaluronan synthase
2.4.1.213	Glucosylglycerol-phosphate synthase
2.4.1.214	Glycoprotein 3-alpha-L-fucosyltransferase
2.4.1.215	Cis-zeatin O-beta-D-glucosyltransferase
2.4.1.216	Trehalose 6-phosphate phosphorylase
2.4.1.217	Mannosyl-3-phosphoglycerate synthase
2.4.1.218	Hydroquinone glucosyltransferase
2.4.1.219	Vomilenine glucosyltransferase
2.4.1.21	Starch (bacterial glycogen) synthase
2.4.1.220	Indoxyl-UDPG glucosyltransferase
2.4.1.221	Peptide-O-fucosyltransferase
2.4.1.222	O-fucosylpeptide 3-beta-N-acetylglucosaminyltransferase
2.4.1.223	Glucuronyl-galactosyl-proteoglycan 4-alpha-N-acetylglucosaminyltransferase
2.4.1.224	Glucuronosyl-N-acetylglucosaminyl-proteoglycan 4-alpha-N-acetylglucosaminyltransferase
2.4.1.225	N-acetylglucosaminyl-proteoglycan 4-beta-glucuronosyltransferase
2.4.1.226	N-acetylgalactosaminyl-proteoglycan 3-beta-glucuronosyltransferase
2.4.1.227	Undecaprenyldiphospho-muramoylpentapeptide beta-N-acetylglucosaminyltransferase
2.4.1.228	Lactosylceramide 4-alpha-galactosyltransferase
2.4.1.229	[Skp1-protein]-hydroxyproline N-acetylglucosaminyltransferase
2.4.1.22	Lactose synthase
2.4.1.230	Kojibiose phosphorylase
2.4.1.231	Alpha,alpha-trehalose phosphorylase (configuration-retaining)
2.4.1.232	initiation-specific alpha-1,6-mannosyltransferase
2.4.1.23	Sphingosine beta-galactosyltransferase
2.4.1.24	1,4-alpha-glucan 6-alpha-glucosyltransferase
2.4.1.242	NDP-glucose-starch glucosyltransferase
2.4.1.25	4-alpha-glucanotransferase
2.4.1.26	DNA alpha-glucosyltransferase
2.4.1.27	DNA beta-glucosyltransferase
2.4.1.28	Glucosyl-DNA beta-glucosyltransferase
2.4.1.29	Cellulose synthase (GDP-forming)
2.4.1.2	Dextrin dextranase
2.4.1.30	1,3-beta-oligoglucan phosphorylase
2.4.1.31	Laminaribiose phosphorylase
2.4.1.32	Glucomannan 4-beta-mannosyltransferase
2.4.1.33	Alginate synthase
2.4.1.34	1,3-beta-glucan synthase
2.4.1.35	Phenol beta-glucosyltransferase
2.4.1.36	Alpha,alpha-trehalose-phosphate synthase (GDP-forming)
2.4.1.37	Fucosylgalactoside 3-alpha-galactosyltransferase
2.4.1.38	Beta-N-acetylglucosaminyl-glycopeptide beta-1,4-galactosyltransferase
2.4.1.39	Steroid N-acetylglucosaminyltransferase
2.4.1.3	Transferred entry: 2.4.1.25
2.4.1.40	Glycoprotein-fucosylgalactoside alpha-N-acetylgalactosaminyltransferase
2.4.1.41	Polypeptide N-acetylgalactosaminyltransferase
2.4.1.42	Transferred entry: 2.4.1.17
2.4.1.43	Polygalacturonate 4-alpha-galacturonosyltransferase
2.4.1.44	Lipopolysaccharide 3-alpha-galactosyltransferase
2.4.1.45	2-hydroxyacylsphingosine 1-beta-galactosyltransferase
2.4.1.46	1,2-diacylglycerol 3-beta-galactosyltransferase
2.4.1.47	N-acylsphingosine galactosyltransferase
2.4.1.48	Heteroglycan alpha-mannosyltransferase
2.4.1.49	Cellodextrin phosphorylase
2.4.1.4	Amylosucrase
2.4.1.50	Procollagen galactosyltransferase
2.4.1.51	Transferred entry: 2.4.1.101, 2.4.1.143, 2.4.1.144 and 2.4.1.145
2.4.1.52	Poly(glycerol-phosphate) alpha-glucosyltransferase
2.4.1.53	Poly(ribitol-phosphate) beta-glucosyltransferase
2.4.1.54	Undecaprenyl-phosphate mannosyltransferase
2.4.1.55	Transferred entry: 2.7.8.14
2.4.1.56	Lipopolysaccharide N-acetylglucosaminyltransferase
2.4.1.57	Phosphatidylinositol alpha-mannosyltransferase
2.4.1.58	Lipopolysaccharide glucosyltransferase I
2.4.1.59	Transferred entry: 2.4.1.17
2.4.1.5	Dextransucrase
2.4.1.60	Abequosyltransferase
2.4.1.61	Transferred entry: 2.4.1.17
2.4.1.62	Ganglioside galactosyltransferase
2.4.1.63	Linamarin synthase
2.4.1.64	Alpha,alpha-trehalose phosphorylase
2.4.1.65	3-galactosyl-N-acetylglucosaminide 4-alpha-L-fucosyltransferase
2.4.1.66	Procollagen glucosyltransferase
2.4.1.67	Galactinol--raffinose galactosyltransferase
2.4.1.68	Glycoprotein 6-alpha-L-fucosyltransferase
2.4.1.69	Galactoside 2-alpha-L-fucosyltransferase
2.4.1.6	Deleted entry
2.4.1.70	Poly(ribitol-phosphate) N-acetylglucosaminyltransferase
2.4.1.71	Arylamine glucosyltransferase
2.4.1.72	Transferred entry: 2.4.2.24
2.4.1.73	Lipopolysaccharide glucosyltransferase II
2.4.1.74	Glycosaminoglycan galactosyltransferase
2.4.1.75	UDP-galacturonosyltransferase
2.4.1.76	Transferred entry: 2.4.1.17
2.4.1.77	Transferred entry: 2.4.1.17
2.4.1.78	Phosphopolyprenol glucosyltransferase
2.4.1.79	Galactosylgalactosylglucosylceramide beta-D-acetyl-galactosaminyltransferase
2.4.1.7	Sucrose phosphorylase
2.4.1.80	Ceramide glucosyltransferase
2.4.1.81	Flavone 7-O-beta-glucosyltransferase
2.4.1.82	Galactinol--sucrose galactosyltransferase
2.4.1.83	Dolichyl-phosphate beta-D-mannosyltransferase
2.4.1.84	Transferred entry: 2.4.1.17
2.4.1.85	Cyanohydrin beta-glucosyltransferase
2.4.1.86	Glucosaminylgalactosylglucosylceramide beta-galactosyltransferase
2.4.1.87	N-acetyllactosaminide 3-alpha-galactosyltransferase
2.4.1.88	Globoside alpha-N-acetylgalactosaminyltransferase
2.4.1.89	Transferred entry: 2.4.1.69
2.4.1.8	Maltose phosphorylase
2.4.1.90	N-acetyllactosamine synthase
2.4.1.91	Flavonol 3-O-glucosyltransferase
2.4.1.92	(N-acetylneuraminyl)-galactosylglucosylceramideN-acetylgalactosaminyltransferase
2.4.1.93	Transferred entry: 4.2.2.18
2.4.1.94	Protein N-acetylglucosaminyltransferase
2.4.1.95	Bilirubin-glucuronoside glucuronosyltransferase
2.4.1.96	Sn-glycerol-3-phosphate 1-galactosyltransferase
2.4.1.97	1,3-beta-glucan phosphorylase
2.4.1.98	Transferred entry: 2.4.1.90
2.4.1.99	Sucrose 1F-fructosyltransferase
2.4.1.9	Inulosucrase
2.4.2.10	Orotate phosphoribosyltransferase
2.4.2.11	Nicotinate phosphoribosyltransferase
2.4.2.12	Nicotinamide phosphoribosyltransferase
2.4.2.13	Transferred entry: 2.5.1.6
2.4.2.14	Amidophosphoribosyltransferase
2.4.2.15	Guanosine phosphorylase
2.4.2.16	Urate-ribonucleotide phosphorylase
2.4.2.17	ATP phosphoribosyltransferase
2.4.2.18	Anthranilate phosphoribosyltransferase
2.4.2.19	Nicotinate-nucleotide diphosphorylase (carboxylating)
2.4.2.1	Purine-nucleoside phosphorylase
2.4.2.20	Dioxotetrahydropyrimidine phosphoribosyltransferase
2.4.2.21	Nicotinate-nucleotide-dimethylbenzimidazole phosphoribosyltransferase
2.4.2.22	Xanthine-guanine phosphoribosyltransferase
2.4.2.23	Deoxyuridine phosphorylase
2.4.2.24	1,4-beta-D-xylan synthase
2.4.2.25	Flavone apiosyltransferase
2.4.2.26	Protein xylosyltransferase
2.4.2.27	dTDP-dihydrostreptose-streptidine-6-phosphatedihydrostreptosyltransferase
2.4.2.28	S-methyl-5-thioadenosine phosphorylase
2.4.2.29	Queuine tRNA-ribosyltransferase
2.4.2.2	Pyrimidine-nucleoside phosphorylase
2.4.2.30	NAD(+) ADP-ribosyltransferase
2.4.2.31	NAD(P)(+)--arginine ADP-ribosyltransferase
2.4.2.32	Dolichyl-phosphate D-xylosyltransferase
2.4.2.33	Dolichyl-xylosyl-phosphate--protein xylosyltransferase
2.4.2.34	Indolylacetylinositol arabinosyltransferase
2.4.2.35	Flavonol-3-O-glycoside xylosyltransferase
2.4.2.36	NAD(+)--diphthamide ADP-ribosyltransferase
2.4.2.37	NAD(+)--dinitrogen-reductase ADP-D-ribosyltransferase
2.4.2.38	Glycoprotein 2-beta-D-xylosyltransferase
2.4.2.39	Xyloglucan 6-xylosyltransferase
2.4.2.3	Uridine phosphorylase
2.4.2.40	Zeatin O-beta-D-xylosyltransferase
2.4.2.4	Thymidine phosphorylase
2.4.2.5	Nucleoside ribosyltransferase
2.4.2.6	Nucleoside deoxyribosyltransferase
2.4.2.7	Adenine phosphoribosyltransferase
2.4.2.8	Hypoxanthine phosphoribosyltransferase
2.4.2.9	Uracil phosphoribosyltransferase
2.4.99.10	Neolactotetraosylceramide alpha-2,3-sialyltransferase
2.4.99.11	Lactosylceramide alpha-2,6-N-sialyltransferase
2.4.99.1	Beta-galactosamide alpha-2,6-sialyltransferase
2.4.99.2	Monosialoganglioside sialyltransferase
2.4.99.3	Alpha-N-acetylgalactosaminide alpha-2,6-sialyltransferase
2.4.99.4	Beta-galactoside alpha-2,3-sialyltransferase
2.4.99.5	Galactosyldiacylglycerol alpha-2,3-sialyltransferase
2.4.99.6	N-acetyllactosaminide alpha-2,3-sialyltransferase
2.4.99.7	(Alpha-N-acetylneuraminyl-2,3-beta-galactosyl-1,3)-N-acetyl-galactosaminide 6-alpha-sialyltransferase
2.4.99.8	Alpha-N-acetyl-neuraminide alpha-2,8-sialyltransferase
2.4.99.9	Lactosylceramide alpha-2,3-sialyltransferase
2.5.1.10	Geranyltranstransferase
2.5.1.11	Trans-octaprenyltranstransferase
2.5.1.12	Transferred entry: 2.5.1.18
2.5.1.13	Transferred entry: 2.5.1.18
2.5.1.14	Transferred entry: 2.5.1.18
2.5.1.15	Dihydropteroate synthase
2.5.1.16	Spermidine synthase
2.5.1.17	Cob(I)yrinic acid a,c-diamide adenosyltransferase
2.5.1.18	Glutathione transferase
2.5.1.19	3-phosphoshikimate 1-carboxyvinyltransferase
2.5.1.1	Dimethylallyltransferase
2.5.1.20	Rubber cis-polyprenylcistransferase
2.5.1.21	Farnesyl-diphosphate farnesyltransferase
2.5.1.22	Spermine synthase
2.5.1.23	Sym-norspermidine synthase
2.5.1.24	Discadenine synthase
2.5.1.25	tRNA-uridine aminocarboxypropyltransferase
2.5.1.26	Alkylglycerone-phosphate synthase
2.5.1.27	Adenylate dimethylallyltransferase
2.5.1.28	Dimethylallylcistransferase
2.5.1.29	Farnesyltranstransferase
2.5.1.2	Thiamine pyridinylase
2.5.1.30	Trans-hexaprenyltranstransferase
2.5.1.31	Di-trans-poly-cis-decaprenylcistransferase
2.5.1.32	Geranylgeranyl-diphosphate geranylgeranyltransferase
2.5.1.33	Trans-pentaprenyltransferase
2.5.1.34	Tryptophan dimethylallyltransferase
2.5.1.35	Aspulvinone dimethylallyltransferase
2.5.1.36	Trihydroxypterocarpan dimethylallyltransferase
2.5.1.37	Transferred entry: 4.4.1.20
2.5.1.38	Isonocardicin synthase
2.5.1.39	4-hydroxybenzoate nonaprenyltransferase
2.5.1.3	Thiamine-phosphate diphosphorylase
2.5.1.40	Transferred entry: 4.2.3.9
2.5.1.41	Phosphoglycerol geranylgeranyltransferase
2.5.1.42	Geranylgeranylglycerol-phosphate geranylgeranyltransferase
2.5.1.43	Nicotianamine synthase
2.5.1.44	Homospermidine synthase
2.5.1.45	Homospermidine synthase (spermidine-specific)
2.5.1.46	Deoxyhypusine synthase
2.5.1.47	Cysteine synthase
2.5.1.48	Cystathionine gamma-synthase
2.5.1.49	O-acetylhomoserine aminocarboxypropyltransferase
2.5.1.4	Adenosylmethionine cyclotransferase
2.5.1.50	Zeatin 9-aminocarboxyethyltransferase
2.5.1.51	Beta-pyrazolylalanine synthase
2.5.1.52	L-mimosine synthase
2.5.1.53	Uracilylalanine synthase
2.5.1.54	3-deoxy-7-phosphoheptulonate synthase
2.5.1.55	3-deoxy-8-phosphooctulonate synthase
2.5.1.56	N-acetylneuraminate synthase
2.5.1.57	N-acylneuraminate-9-phosphate synthase
2.5.1.58	Protein farnesyltransferase
2.5.1.59	Protein geranylgeranyltransferase type I
2.5.1.5	Galactose-6-sulfurylase
2.5.1.60	Protein geranylgeranyltransferase type II
2.5.1.61	Hydroxymethylbilane synthase
2.5.1.62	Chlorophyll synthase
2.5.1.63	Adenosyl-fluoride synthase
2.5.1.64	2-succinyl-6-hydroxy-2,4-cyclohexadiene-1-carboxylate synthase
2.5.1.65	O-phosphoserine sulfhydrylase
2.5.1.6	Methionine adenosyltransferase
2.5.1.7	UDP-N-acetylglucosamine 1-carboxyvinyltransferase
2.5.1.8	tRNA isopentenyltransferase
2.5.1.9	Riboflavin synthase
2.6.1.10	Transferred entry: 2.6.1.21
2.6.1.11	Acetylornithine transaminase
2.6.1.12	Alanine--oxo-acid transaminase
2.6.1.13	Ornithine--oxo-acid transaminase
2.6.1.14	Asparagine--oxo-acid transaminase
2.6.1.15	Glutamine--pyruvate transaminase
2.6.1.16	Glutamine-fructose-6-phosphate transaminase (isomerizing)
2.6.1.17	Succinyldiaminopimelate transaminase
2.6.1.18	Beta-alanine--pyruvate transaminase
2.6.1.19	4-aminobutyrate transaminase
2.6.1.1	Aspartate transaminase
2.6.1.20	Deleted entry
2.6.1.21	D-alanine transaminase
2.6.1.22	(S)-3-amino-2-methylpropionate transaminase
2.6.1.23	4-hydroxyglutamate transaminase
2.6.1.24	Diiodotyrosine transaminase
2.6.1.25	Transferred entry: 2.6.1.24
2.6.1.26	Thyroid-hormone transaminase
2.6.1.27	Tryptophan transaminase
2.6.1.28	Tryptophan--phenylpyruvate transaminase
2.6.1.29	Diamine transaminase
2.6.1.2	Alanine transaminase
2.6.1.30	Pyridoxamine--pyruvate transaminase
2.6.1.31	Pyridoxamine--oxaloacetate transaminase
2.6.1.32	Valine--3-methyl-2-oxovalerate transaminase
2.6.1.33	dTDP-4-amino-4,6-dideoxy-D-glucose transaminase
2.6.1.34	UDP-4-amino-2-acetamido-2,4,6-trideoxyglucose transaminase
2.6.1.35	Glycine--oxaloacetate transaminase
2.6.1.36	L-lysine transaminase
2.6.1.37	2-aminoethylphosphonate--pyruvate transaminase
2.6.1.38	Histidine transaminase
2.6.1.39	2-aminoadipate transaminase
2.6.1.3	Cysteine transaminase
2.6.1.40	(R)-3-amino-2-methylpropionate--pyruvate transaminase
2.6.1.41	D-methionine--pyruvate transaminase
2.6.1.42	Branched-chain amino acid transaminase
2.6.1.43	Aminolevulinate transaminase
2.6.1.44	Alanine--glyoxylate transaminase
2.6.1.45	Serine--glyoxylate transaminase
2.6.1.46	Diaminobutyrate--pyruvate transaminase
2.6.1.47	Alanine--oxomalonate transaminase
2.6.1.48	5-aminovalerate transaminase
2.6.1.49	Dihydroxyphenylalanine transaminase
2.6.1.4	Glycine transaminase
2.6.1.50	Glutamine--scyllo-inosose transaminase
2.6.1.51	Serine--pyruvate transaminase
2.6.1.52	Phosphoserine transaminase
2.6.1.53	Transferred entry: 1.4.1.13
2.6.1.54	Pyridoxamine-phosphate transaminase
2.6.1.55	Taurine-2-oxoglutarate transaminase
2.6.1.56	1D-1-guanidino-3-amino-1,3-dideoxy-scyllo-inositol transaminase
2.6.1.57	Aromatic amino acid transferase
2.6.1.58	Phenylalanine(histidine) transaminase
2.6.1.59	dTDP-4-amino-4,6-dideoxygalactose transaminase
2.6.1.5	Tyrosine transaminase
2.6.1.60	Aromatic-amino-acid--glyoxylate transaminase
2.6.1.61	Transferred entry: 2.6.1.40
2.6.1.62	Adenosylmethionine--8-amino-7-oxononanoate transaminase
2.6.1.63	Kynurenine--glyoxylate transaminase
2.6.1.64	Glutamine--phenylpyruvate transaminase
2.6.1.65	N(6)-acetyl-beta-lysine transaminase
2.6.1.66	Valine--pyruvate transaminase
2.6.1.67	2-aminohexanoate transaminase
2.6.1.68	Ornithine(lysine) transaminase
2.6.1.69	N(2)-acetylornithine 5-transaminase
2.6.1.6	Leucine transaminase
2.6.1.70	Aspartate--phenylpyruvate transaminase
2.6.1.71	Lysine--pyruvate 6-transaminase
2.6.1.72	D-4-hydroxyphenylglycine transaminase
2.6.1.73	Methionine--glyoxylate transaminase
2.6.1.74	Cephalosporin-C transaminase
2.6.1.75	Cysteine-conjugate transaminase
2.6.1.76	Diaminobutyrate-2-oxoglutarate transaminase
2.6.1.77	Taurine--pyruvate aminotransferase
2.6.1.7	Kynurenine--oxoglutarate transaminase
2.6.1.8	2,5-diaminovalerate transaminase
2.6.1.9	Histidinol-phosphate transaminase
2.6.2.1	Transferred entry: 2.1.4.1
2.6.3.1	Oximinotransferase
2.6.99.1	dATP(dGTP)--DNA purinetransferase
2.7.10.1	receptor protein-tyrosine kinase
2.7.10.2	non-specific protein-tyrosine kinase
2.7.1.100	Methylthioribose kinase
2.7.1.101	Tagatose kinase
2.7.1.102	Hamamelose kinase
2.7.1.103	Viomycin kinase
2.7.1.104	Diphosphate-protein phosphotransferase
2.7.1.105	6-phosphofructo-2-kinase
2.7.1.106	Glucose-1,6-bisphosphate synthase
2.7.1.107	Diacylglycerol kinase
2.7.1.108	Dolichol kinase
2.7.1.109	[Hydroxymethylglutaryl-CoA reductase(NADPH)] kinase
2.7.1.10	Phosphoglucokinase
2.7.1.110	Dephospho-[reductase kinase] kinase
2.7.11.10	I-kappa-B kinase
2.7.11.11	cAMP-dependent protein kinase
2.7.1.111	Transferred entry: 2.7.1.128
2.7.11.12	cGMP-dependent protein kinase
2.7.1.112	Protein-tyrosine kinase
2.7.1.113	Deoxyguanosine kinase
2.7.11.13	protein kinase C
2.7.1.114	AMP--thymidine kinase
2.7.11.14	rhodopsin kinase
2.7.1.115	[3-methyl-2-oxobutanoate dehydrogenase (lipoamide)] kinase
2.7.11.15	beta-adrenergic-receptor kinase
2.7.11.16	G-protein-coupled receptor kinase
2.7.1.116	[Isocitrate dehydrogenase (NADP+)] kinase
2.7.1.11	6-phosphofructokinase
2.7.11.17	Ca2+/calmodulin-dependent protein kinase
2.7.1.117	[Myosin light-chain] kinase
2.7.1.118	ADP--thymidine kinase
2.7.11.18	myosin-light-chain kinase
2.7.1.119	Hygromycin-B kinase
2.7.11.19	phosphorylase kinase
2.7.11.1	non-specific serine/threonine protein kinase
2.7.1.120	Caldesmon kinase
2.7.11.20	elongation factor 2 kinase
2.7.1.121	Phosphoenolpyruvate--glycerone phosphotransferase
2.7.11.21	polo kinase
2.7.11.22	cyclin-dependent kinase
2.7.1.122	Xylitol kinase
2.7.1.123	Calcium/calmodulin-dependent protein kinase
2.7.11.23	[RNA-polymerase]-subunit kinase
2.7.11.24	mitogen-activated protein kinase
2.7.1.124	Tyrosine 3-monooxygenase kinase
2.7.11.25	mitogen-activated protein kinase kinase kinase
2.7.1.125	Rhodopsin kinase
2.7.1.126	[Beta-adrenergic-receptor] kinase
2.7.11.26	tau-protein kinase
2.7.1.127	Inositol-trisphosphate 3-kinase
2.7.1.128	[Acetyl-CoA carboxylase] kinase
2.7.1.129	[Myosin heavy-chain] kinase
2.7.1.12	Gluconokinase
2.7.11.2	[pyruvate dehydrogenase (acetyl-transferring)] kinase
2.7.11.30	receptor protein serine/threonine kinase
2.7.1.130	Tetraacyldisaccharide 4'-kinase
2.7.1.131	[Low-density lipoprotein receptor] kinase
2.7.1.132	Tropomyosin kinase
2.7.1.133	Transferred entry: 2.7.1.134
2.7.1.134	Inositol-tetrakisphosphate 1-kinase
2.7.1.135	[Tau protein] kinase
2.7.1.136	Macrolide 2'-kinase
2.7.1.137	Phosphatidylinositol 3-kinase
2.7.1.138	Ceramide kinase
2.7.1.139	Transferred entry: 2.7.1.134
2.7.1.13	Dehydogluconokinase
2.7.1.140	1D-myo-inositol-tetrakisphosphate 5-kinase
2.7.1.141	[RNA-polymerase]-subunit kinase
2.7.1.142	Glycerol-3-phosphate-glucose phosphotransferase
2.7.1.143	Diphosphate-purine nucleoside kinase
2.7.11.4	[3-methyl-2-oxobutanoate dehydrogenase (acetyl-transferring)] kinase
2.7.1.144	Tagatose-6-phosphate kinase
2.7.1.145	Deoxynucleoside kinase
2.7.1.146	ADP-specific phosphofructokinase
2.7.1.147	ADP-specific glucokinase
2.7.1.148	4-(cytidine 5'-diphospho)-2-C-methyl-D-erythritol kinase
2.7.1.149	1-phosphatidylinositol-5-phosphate 4-kinase
2.7.1.14	Sedoheptulokinase
2.7.1.150	1-phosphatidylinositol-3-phosphate 5-kinase
2.7.1.151	Inositol-polyphosphate multikinase
2.7.1.152	Transferred entry: 2.7.4.21
2.7.1.153	Phosphatidylinositol-4,5-bisphosphate 3-kinase
2.7.1.154	Phosphatidylinositol-4-phosphate 3-kinase
2.7.1.155	Diphosphoinositol-pentakisphosphate kinase
2.7.1.156	Adenosylcobinamide kinase
2.7.1.157	N-acetylgalactosamine kinase
2.7.11.5	[isocitrate dehydrogenase (NADP+)] kinase
2.7.1.15	Ribokinase
2.7.1.16	L-ribulokinase
2.7.11.7	myosin-heavy-chain kinase
2.7.1.17	Xylulokinase
2.7.11.8	Fas-activated serine/threonine kinase
2.7.1.18	Phosphoribokinase
2.7.11.9	Goodpasture-antigen-binding protein kinase
2.7.1.19	Phosphoribulokinase
2.7.1.1	Hexokinase
2.7.1.20	Adenosine kinase
2.7.12.1	dual-specificity kinase
2.7.1.21	Thymidine kinase
2.7.12.2	mitogen-activated protein kinase kinase
2.7.1.22	Ribosylnicotinamide kinase
2.7.1.23	NAD(+) kinase
2.7.1.24	Dephospho-CoA kinase
2.7.1.25	Adenylylsulfate kinase
2.7.1.26	Riboflavin kinase
2.7.1.27	Erythritol kinase
2.7.1.28	Triokinase
2.7.1.29	Glycerone kinase
2.7.1.2	Glucokinase
2.7.1.30	Glycerol kinase
2.7.1.31	Glycerate kinase
2.7.1.32	Choline kinase
2.7.13.3	histidine kinase
2.7.1.33	Pantothenate kinase
2.7.1.34	Pantetheine kinase
2.7.1.35	Pyridoxal kinase
2.7.1.36	Mevalonate kinase
2.7.1.37	Protein kinase
2.7.1.38	Phosphorylase kinase
2.7.1.39	Homoserine kinase
2.7.1.3	Ketohexokinase
2.7.1.40	Pyruvate kinase
2.7.1.41	Glucose-1-phosphate phosphodismutase
2.7.1.42	Riboflavin phosphotransferase
2.7.1.43	Glucuronokinase
2.7.1.44	Galacturonokinase
2.7.1.45	2-dehydro-3-deoxygluconokinase
2.7.1.46	L-arabinokinase
2.7.1.47	D-ribulokinase
2.7.1.48	Uridine kinase
2.7.1.49	Hydroxymethylpyrimidine kinase
2.7.1.4	Fructokinase
2.7.1.50	Hydroxyethylthiazole kinase
2.7.1.51	L-fuculokinase
2.7.1.52	Fucokinase
2.7.1.53	L-xylulokinase
2.7.1.54	D-arabinokinase
2.7.1.55	Allose kinase
2.7.1.56	1-phosphofructokinase
2.7.1.57	Deleted entry
2.7.1.58	2-dehydro-3-deoxygalactonokinase
2.7.1.59	N-acetylglucosamine kinase
2.7.1.5	Rhamnulokinase
2.7.1.60	N-acylmannosamine kinase
2.7.1.61	Acyl-phosphate-hexose phosphotransferase
2.7.1.62	Phosphoramidate-hexose phosphotransferase
2.7.1.63	Polyphosphate-glucose phosphotransferase
2.7.1.64	Inositol 3-kinase
2.7.1.65	Scyllo-inosamine kinase
2.7.1.66	Undecaprenol kinase
2.7.1.67	1-phosphatidylinositol 4-kinase
2.7.1.68	1-phosphatidylinositol-4-phosphate 5-kinase
2.7.1.69	Protein-N(pi)-phosphohistidine-sugar phosphotransferase
2.7.1.6	Galactokinase
2.7.1.70	Protamine kinase
2.7.1.71	Shikimate kinase
2.7.1.72	Streptomycin 6-kinase
2.7.1.73	Inosine kinase
2.7.1.74	Deoxycytidine kinase
2.7.1.75	Transferred entry: 2.7.1.21
2.7.1.76	Deoxyadenosine kinase
2.7.1.77	Nucleoside phosphotransferase
2.7.1.78	Polynucleotide 5'-hydroxyl-kinase
2.7.1.79	Diphosphate--glycerol phosphotransferase
2.7.1.7	Mannokinase
2.7.1.80	Diphosphate--serine phosphotransferase
2.7.1.81	Hydroxylysine kinase
2.7.1.82	Ethanolamine kinase
2.7.1.83	Pseudouridine kinase
2.7.1.84	Alkylglycerone kinase
2.7.1.85	Beta-glucoside kinase
2.7.1.86	NADH kinase
2.7.1.87	Streptomycin 3''-kinase
2.7.1.88	Dihydrostreptomycin-6-phosphate 3'-alpha-kinase
2.7.1.89	Thiamine kinase
2.7.1.8	Glucosamine kinase
2.7.1.90	Diphosphate--fructose-6-phosphate 1-phosphotransferase
2.7.1.91	Sphinganine kinase
2.7.1.92	5-dehydro-2-deoxygluconokinase
2.7.1.93	Alkylglycerol kinase
2.7.1.94	Acylglycerol kinase
2.7.1.95	Kanamycin kinase
2.7.1.96	Transferred entry: 2.7.1.86
2.7.1.97	Transferred entry: 2.7.1.125
2.7.1.98	Deleted entry
2.7.1.99	[Pyruvate dehydrogenase(lipoamide)] kinase
2.7.1.9	Deleted entry
2.7.2.10	Phosphoglycerate kinase (GTP)
2.7.2.11	Glutamate 5-kinase
2.7.2.12	Acetate kinase (diphosphate)
2.7.2.13	Glutamate 1-kinase
2.7.2.14	Branched-chain-fatty-acid kinase
2.7.2.15	propionate kinase
2.7.2.1	Acetate kinase
2.7.2.2	Carbamate kinase
2.7.2.3	Phosphoglycerate kinase
2.7.2.4	Aspartate kinase
2.7.2.5	Transferred entry: 6.3.4.16
2.7.2.6	Formate kinase
2.7.2.7	Butyrate kinase
2.7.2.8	Acetylglutamate kinase
2.7.2.9	Transferred entry: 6.3.5.5
2.7.3.10	Agmatine kinase
2.7.3.11	Protein-histidine pros-kinase
2.7.3.12	Protein-histidine tele-kinase
2.7.3.1	Guanidoacetate kinase
2.7.3.2	Creatine kinase
2.7.3.3	Arginine kinase
2.7.3.4	Taurocyamine kinase
2.7.3.5	Lombricine kinase
2.7.3.6	Hypotaurocyamine kinase
2.7.3.7	Opheline kinase
2.7.3.8	Ammonia kinase
2.7.3.9	Phosphoenolpyruvate--protein phosphatase
2.7.4.10	Nucleoside-triphosphate--adenylate kinase
2.7.4.11	(Deoxy)adenylate kinase
2.7.4.12	T2-induced deoxynucleotide kinase
2.7.4.13	(Deoxy)nucleoside-phosphate kinase
2.7.4.14	Cytidylate kinase
2.7.4.15	Thiamine-diphosphate kinase
2.7.4.16	Thiamine-phosphate kinase
2.7.4.17	3-phosphoglyceroyl-phosphate-polyphosphate phosphotransferase
2.7.4.18	Farnesyl-diphosphate kinase
2.7.4.19	5-methyldeoxycytidine-5'-phosphate kinase
2.7.4.1	Polyphosphate kinase
2.7.4.20	Dolichyl-diphosphate--polyphosphate phosphotransferase
2.7.4.21	Inositol-hexakisphosphate kinase
2.7.4.2	Phosphomevalonate kinase
2.7.4.3	Adenylate kinase
2.7.4.4	Nucleoside-phosphate kinase
2.7.4.5	Transferred entry: 2.7.4.14
2.7.4.6	Nucleoside-diphosphate kinase
2.7.4.7	Phosphomethylpyrimidine kinase
2.7.4.8	Guanylate kinase
2.7.4.9	Thymidylate kinase
2.7.5.1	Transferred entry: 5.4.2.2
2.7.5.2	Transferred entry: 5.4.2.3
2.7.5.3	Transferred entry: 5.4.2.1
2.7.5.4	Transferred entry: 5.4.2.4
2.7.5.5	Transferred entry: 5.4.2.5
2.7.5.6	Transferred entry: 5.4.2.7
2.7.5.7	Transferred entry: 5.4.2.8
2.7.6.1	Ribose-phosphate diphosphokinase
2.7.6.2	Thiamine diphosphokinase
2.7.6.3	2-amino-4-hydroxy-6-hydroxymethyldihydropteridine diphosphokinase
2.7.6.4	Nucleotide diphosphokinase
2.7.6.5	GTP diphosphokinase
2.7.7.10	UTP--hexose-1-phosphate uridylyltransferase
2.7.7.11	UTP--xylose-1-phosphate uridylyltransferase
2.7.7.12	UDP-glucose--hexose-1-phosphate uridylyltransferase
2.7.7.13	Mannose-1-phosphate guanylyltransferase
2.7.7.14	Ethanolamine-phosphate cytidylyltransferase
2.7.7.15	Cholinephosphate cytidylyltransferase
2.7.7.16	Transferred entry: 3.1.27.5
2.7.7.17	Transferred entry: 3.1.27.1
2.7.7.18	Nicotinate-nucleotide adenylyltransferase
2.7.7.19	Polynucleotide adenylyltransferase
2.7.7.1	Nicotinamide-nucleotide adenylyltransferase
2.7.7.20	Deleted entry
2.7.7.21	tRNA cytidylyltransferase
2.7.7.22	Mannose-1-phosphate guanylyltransferase [GDP]
2.7.7.23	UDP-N-acetylglucosamine diphosphorylase
2.7.7.24	Glucose-1-phosphate thymidylyltransferase
2.7.7.25	tRNA adenylyltransferase
2.7.7.26	Transferred entry: 3.1.27.3
2.7.7.27	Glucose-1-phosphate adenylyltransferase
2.7.7.28	Nucleoside-triphosphate-aldose-1-phosphate nucleotidyltransferase
2.7.7.29	Hexose-1-phosphate guanylyltransferase
2.7.7.2	FMN adenylyltransferase
2.7.7.30	Fucose-1-phosphate guanylyltransferase
2.7.7.31	DNA nucleotidylexotransferase
2.7.7.32	Galactose-1-phosphate thymidylyltransferase
2.7.7.33	Glucose-1-phosphate cytidylyltransferase
2.7.7.34	Glucose-1-phosphate guanylyltransferase
2.7.7.35	Ribose-5-phosphate adenylyltransferase
2.7.7.36	Aldose-1-phosphate adenylyltransferase
2.7.7.37	Aldose-1-phosphate nucleotidyltransferase
2.7.7.38	3-deoxy-manno-octulosonate cytidylyltransferase
2.7.7.39	Glycerol-3-phosphate cytidylyltransferase
2.7.7.3	Pantetheine-phosphate adenylyltransferase
2.7.7.40	D-ribitol-5-phosphate cytidylyltransferase
2.7.7.41	Phosphatidate cytidylyltransferase
2.7.7.42	Glutamate-ammonia-ligase adenylyltransferase
2.7.7.43	Acylneuraminate cytidylyltransferase
2.7.7.44	Glucuronate-1-phosphate uridylyltransferase
2.7.7.45	Guanosine-triphosphate guanylyltransferase
2.7.7.46	Gentamicin 2''-nucleotidyltransferase
2.7.7.47	Streptomycin 3''-adenylyltransferase
2.7.7.48	RNA-directed RNA polymerase
2.7.7.49	RNA-directed DNA polymerase
2.7.7.4	Sulfate adenylyltransferase
2.7.7.50	mRNA guanylyltransferase
2.7.7.51	Adenylylsulfate--ammonia adenylyltransferase
2.7.7.52	RNA uridylyltransferase
2.7.7.53	ATP adenylyltransferase
2.7.7.54	Phenylalanine adenylyltransferase
2.7.7.55	Anthranilate adenylyltransferase
2.7.7.56	tRNA nucleotidyltransferase
2.7.7.57	N-methylphosphoethanolamine cytidylyltransferase
2.7.7.58	(2,3-dihydroxybenzoyl)adenylate synthase
2.7.7.59	[Protein-PII] uridylyltransferase
2.7.7.5	Sulfate adenylyltransferase (ADP)
2.7.7.60	2-C-methyl-D-erythritol 4-phosphate cytidylyltransferase
2.7.7.61	Holo-citrate lyase synthase
2.7.7.62	Adenosylcobinamide-phosphate guanylyltransferase
2.7.7.6	DNA-directed RNA polymerase
2.7.7.7	DNA-directed DNA polymerase
2.7.7.8	Polyribonucleotide nucleotidyltransferase
2.7.7.9	UTP--glucose-1-phosphate uridylyltransferase
2.7.8.10	Sphingosine cholinephosphotransferase
2.7.8.11	CDP-diacylglycerol--inositol 3-phosphatidyltransferase
2.7.8.12	CDP-glycerol glycerophosphotransferase
2.7.8.13	Phospho-N-acetylmuramoyl-pentapeptide-transferase
2.7.8.14	CDP-ribitol ribitolphosphotransferase
2.7.8.15	UDP-N-acetylglucosamine--dolichyl-phosphateN-acetylglucosaminephosphotransferase
2.7.8.16	Transferred entry: 2.7.8.2
2.7.8.17	UDP-N-acetylglucosamine--lysosomal-enzymeN-acetylglucosaminephosphotransferase
2.7.8.18	UDP-galactose--UDP-N-acetylglucosamine galactosephosphotransferase
2.7.8.19	UDP-glucose--glycoprotein glucosephosphotransferase
2.7.8.1	Ethanolaminephosphotransferase
2.7.8.20	Phosphatidylglycerol--membrane-oligosaccharide glycerophosphotransferase
2.7.8.21	Membrane-oligosaccharide glycerophosphotransferase
2.7.8.22	1-alkenyl-2-acylglycerol cholinephosphotransferase
2.7.8.23	Carboxyvinyl-carboxyphosphonate phosphorylmutase
2.7.8.24	Phosphatidylcholine synthase
2.7.8.25	Triphosphoribosyl-dephospho-CoA synthase
2.7.8.26	Adenosylcobinamide-GDP ribazoletransferase
2.7.8.2	Diacylglycerol cholinephosphotransferase
2.7.8.3	Ceramide cholinephosphotransferase
2.7.8.4	Serine-phosphoethanolamine synthase
2.7.8.5	CDP-diacylglycerol--glycerol-3-phosphate 3-phosphatidyltransferase
2.7.8.6	Undecaprenyl-phosphate galactosephosphotransferase
2.7.8.7	Holo-[acyl-carrier protein] synthase
2.7.8.8	CDP-diacylglycerol--serine O-phosphatidyltransferase
2.7.8.9	Phosphomannan mannosephosphotransferase
2.7.9.1	Pyruvate,phosphate dikinase
2.7.9.2	Pyruvate,water dikinase
2.7.9.3	Selenide,water dikinase
2.7.9.4	Alpha-glucan,water dikinase
2.7.9.5	phosphoglucan, water dikinase
2.8.1.1	Thiosulfate sulfurtransferase
2.8.1.2	3-mercaptopyruvate sulfurtransferase
2.8.1.3	Thiosulfate--thiol sulfurtransferase
2.8.1.4	tRNA sulfurtransferase
2.8.1.5	Thiosulfate--dithiol sulfurtransferase
2.8.1.6	Biotin synthase
2.8.1.7	Cysteine desulfurase
2.8.2.10	Renilla-luciferin sulfotransferase
2.8.2.11	Galactosylceramide sulfotransferase
2.8.2.12	Deleted entry
2.8.2.13	Psychosine sulfotransferase
2.8.2.14	Bile-salt sulfotransferase
2.8.2.15	Steroid sulfotransferase
2.8.2.16	Thiol sulfotransferase
2.8.2.17	Chondroitin 6-sulfotransferase
2.8.2.18	Cortisol sulfotransferase
2.8.2.19	Triglucosylalkylacylglycerol sulfotransferase
2.8.2.1	Aryl sulfotransferase
2.8.2.20	Protein-tyrosine sulfotransferase
2.8.2.21	Keratan sulfotransferase
2.8.2.22	Arylsulfate sulfotransferase
2.8.2.23	[Heparan sulfate]-glucosamine 3-sulfotransferase 1
2.8.2.24	Desulfoglucosinolate sulfotransferase
2.8.2.25	Flavonol 3-sulfotransferase
2.8.2.26	Quercetin-3-sulfate 3'-sulfotransferase
2.8.2.27	Quercetin-3-sulfate 4'-sulfotransferase
2.8.2.28	Quercetin-3,3'-bissulfate 7-sulfotransferase
2.8.2.29	[Heparan sulfate]-glucosamine 3-sulfotransferase 2
2.8.2.2	Alcohol sulfotransferase
2.8.2.30	[Heparan sulfate]-glucosamine 3-sulfotransferase 3
2.8.2.33	N-acetylgalactosamine 4-sulfate 6-O-sulfotransferase
2.8.2.3	Arylamine sulfotransferase
2.8.2.4	Estrone sulfotransferase
2.8.2.5	Chondroitin 4-sulfotransferase
2.8.2.6	Choline sulfotransferase
2.8.2.7	UDP-N-acetylgalactosamine-4-sulfate sulfotransferase
2.8.2.8	[Heparan sulfate]-glucosamine N-sulfotransferase
2.8.2.9	Tyrosine-ester sulfotransferase
2.8.3.10	Citrate CoA-transferase
2.8.3.11	Citramalate CoA-transferase
2.8.3.12	Glutaconate CoA-transferase
2.8.3.13	Succinate-hydroxymethylglutarate CoA-transferase
2.8.3.14	5-hydroxypentanoate CoA-transferase
2.8.3.15	Succinyl-CoA:(R)-benzylsuccinate CoA-transferase
2.8.3.16	Formyl-CoA transferase
2.8.3.17	Cinnamoyl-CoA:phenyllactate CoA-transferase
2.8.3.1	Propionate CoA-transferase
2.8.3.2	Oxalate CoA-transferase
2.8.3.3	Malonate CoA-transferase
2.8.3.4	Deleted entry
2.8.3.5	3-oxoacid CoA-transferase
2.8.3.6	3-oxoadipate CoA-transferase
2.8.3.7	Succinate-citramalate CoA-transferase
2.8.3.8	Acetate CoA-transferase
2.8.3.9	Butyrate-acetoacetate CoA-transferase
2.8.4.1	Coenzyme-B sulfoethylthiotransferase
2.9.1.1	L-seryl-tRNA(Sec) selenium transferase
3.10.1.1	N-sulfoglucosamine sulfohydrolase
3.10.1.2	Cyclamate sulfohydrolase
3.1.1.10	Tropinesterase
3.1.11.1	Exodeoxyribonuclease I
3.1.1.11	Pectinesterase
3.11.1.1	Phosphonoacetaldehyde hydrolase
3.1.1.12	Deleted entry
3.1.11.2	Exodeoxyribonuclease III
3.11.1.2	Phosphonoacetate hydrolase
3.1.11.3	Exodeoxyribonuclease (Lambda-induced)
3.1.1.13	Sterol esterase
3.1.1.14	Chlorophyllase
3.1.11.4	Exodeoxyribonuclease (phage Sp3-induced)
3.1.11.5	Exodeoxyribonuclease V
3.1.1.15	L-arabinonolactonase
3.1.11.6	Exodeoxyribonuclease VII
3.1.1.16	Transferred entry: 5.3.3.4 and 3.1.1.24
3.1.1.17	Gluconolactonase
3.1.1.18	Transferred entry: 3.1.1.17
3.1.1.19	Uronolactonase
3.1.1.1	Carboxylesterase
3.1.1.20	Tannase
3.1.1.21	Retinyl-palmitate esterase
3.1.1.22	Hydroxybutyrate-dimer hydrolase
3.1.1.23	Acylglycerol lipase
3.1.1.24	3-oxoadipate enol-lactonase
3.1.1.25	1,4-lactonase
3.1.1.26	Galactolipase
3.1.1.27	4-pyridoxolactonase
3.1.1.28	Acylcarnitine hydrolase
3.1.1.29	Aminoacyl-tRNA hydrolase
3.1.1.2	Arylesterase
3.1.1.30	D-arabinonolactonase
3.1.1.31	6-phosphogluconolactonase
3.1.13.1	Exoribonuclease II
3.1.13.2	Exoribonuclease H
3.1.1.32	Phospholipase A1
3.1.1.33	6-acetylglucose deacetylase
3.1.13.3	Oligonucleotidase
3.1.1.34	Lipoprotein lipase
3.1.13.4	Poly(A)-specific ribonuclease
3.1.1.35	Dihydrocoumarin lipase
3.1.1.36	Limonin-D-ring-lactonase
3.1.1.37	Steroid-lactonase
3.1.1.38	Triacetate-lactonase
3.1.1.39	Actinomycin lactonase
3.1.1.3	Triacylglycerol lipase
3.1.1.40	Orsellinate-depside hydrolase
3.1.1.41	Cephalosporin-C deacetylase
3.1.14.1	Yeast ribonuclease
3.1.1.42	Chlorogenate hydrolase
3.1.1.43	Alpha-amino-acid esterase
3.1.1.44	4-methyloxaloacetate esterase
3.1.1.45	Carboxymethylenebutenolidase
3.1.1.46	Deoxylimonate A-ring-lactonase
3.1.1.47	2-acetyl-1-alkylglycerophosphocholine esterase
3.1.1.48	Fusarinine-C ornithinesterase
3.1.1.49	Sinapine esterase
3.1.1.4	Phospholipase A2
3.1.1.50	Wax-ester hydrolase
3.1.1.51	Phorbol-diester hydrolase
3.1.15.1	Venom exonuclease
3.1.1.52	Phosphatidylinositol deacylase
3.1.1.53	Sialate O-acetylesterase
3.1.1.54	Acetoxybutynylbithiophene deacetylase
3.1.1.55	Acetylsalicylate deacetylase
3.1.1.56	Methylumbelliferyl-acetate deacetylase
3.1.1.57	2-pyrone-4,6-dicarboxylate lactonase
3.1.1.58	N-acetylgalactosaminoglycan deacetylase
3.1.1.59	Juvenile-hormone esterase
3.1.1.5	Lysophospholipase
3.1.1.60	Bis(2-ethylhexyl)phthalate esterase
3.1.1.61	Protein-glutamate methylesterase
3.1.16.1	Spleen exonuclease
3.1.1.62	Transferred entry: 3.5.1.47
3.1.1.63	11-cis-retinyl-palmitate hydrolase
3.1.1.64	All-trans-retinyl-palmitate hydrolase
3.1.1.65	L-rhamnono-1,4-lactonase
3.1.1.66	5-(3,4-diacetoxybut-1-ynyl)-2,2'-bithiophene deacetylase
3.1.1.67	Fatty-acyl-ethyl-ester synthase
3.1.1.68	Xylono-1,4-lactonase
3.1.1.69	Transferred entry: 3.5.1.89
3.1.1.6	Acetylesterase
3.1.1.70	Cetraxate benzylesterase
3.1.1.71	Acetylalkylglycerol acetylhydrolase
3.1.1.72	Acetylxylan esterase
3.1.1.73	Feruloyl esterase
3.1.1.74	Cutinase
3.1.1.75	Poly(3-hydroxybutyrate) depolymerase
3.1.1.76	Poly(3-hydroxyoctanoate) depolymerase
3.1.1.77	Acyloxyacyl hydrolase
3.1.1.78	Polyneuridine-aldehyde esterase
3.1.1.79	hormone-sensitive lipase
3.1.1.7	Acetylcholinesterase
3.1.1.8	Cholinesterase
3.1.1.9	Deleted entry
3.1.2.10	Formyl-CoA hydrolase
3.1.2.11	Acetoacetyl-CoA hydrolase
3.1.21.1	Deoxyribonuclease I
3.12.1.1	Trithionate hydrolase
3.1.21.2	Deoxyribonuclease IV (phage T4-induced)
3.1.2.12	S-formylglutathione hydrolase
3.1.2.13	S-succinylglutathione hydrolase
3.1.21.3	Type I site-specific deoxyribonuclease
3.1.2.14	Oleoyl-[acyl-carrier protein] hydrolase
3.1.21.4	Type II site-specific deoxyribonuclease
3.1.21.5	Type III site-specific deoxyribonuclease
3.1.2.15	Ubiquitin thiolesterase
3.1.21.6	CC-preferring endodeoxyribonuclease
3.1.2.16	Citrate (pro-3S)-lyase thiolesterase
3.1.21.7	Deoxyribonuclease V
3.1.2.17	(S)-methylmalonyl-CoA hydrolase
3.1.2.18	ADP-dependent short-chain-acyl-CoA hydrolase
3.1.2.19	ADP-dependent medium-chain-acyl-CoA hydrolase
3.1.2.1	Acetyl-CoA hydrolase
3.1.2.20	Acyl-CoA hydrolase
3.1.22.1	Deoxyribonuclease II
3.1.2.21	Dodecanoyl-[acyl-carrier protein] hydrolase
3.1.22.2	Aspergillus deoxyribonuclease K1
3.1.2.22	Palmitoyl-protein hydrolase
3.1.2.23	4-hydroxybenzoyl-CoA thioesterase
3.1.22.3	Transferred entry: 3.1.21.7
3.1.2.24	2-(2-hydroxyphenyl)benzenesulfinate hydrolase
3.1.22.4	Crossover junction endodeoxyribonuclease
3.1.22.5	Deoxyribonuclease X
3.1.2.26	bile-acid-CoA hydrolase
3.1.2.2	Palmitoyl-CoA hydrolase
3.1.2.3	Succinyl-CoA hydrolase
3.1.2.4	3-hydroxyisobutyryl-CoA hydrolase
3.1.25.1	Deoxyribonuclease (pyrimidine dimer)
3.1.25.2	Transferred entry: 4.2.99.18
3.1.2.5	Hydroxymethylglutaryl-CoA hydrolase
3.1.26.10	Ribonuclease IX
3.1.26.11	Ribonuclease Z
3.1.26.1	Physarum polycephalum ribonuclease
3.1.26.2	Ribonuclease alpha
3.1.26.3	Ribonuclease III
3.1.26.4	Ribonuclease H
3.1.26.5	Ribonuclease P
3.1.26.6	Ribonuclease IV
3.1.26.7	Ribonuclease P4
3.1.26.8	Ribonuclease M5
3.1.26.9	Ribonuclease (poly-(U)-specific)
3.1.2.6	Hydroxyacylglutathione hydrolase
3.1.27.10	rRNA endonuclease
3.1.27.1	Ribonuclease T2
3.1.27.2	Bacillus subtilis ribonuclease
3.1.27.3	Ribonuclease T1
3.1.27.4	Ribonuclease U2
3.1.27.5	Pancreatic ribonuclease
3.1.27.6	Enterobacter ribonuclease
3.1.27.7	Ribonuclease F
3.1.27.8	Ribonuclease V
3.1.27.9	tRNA-intron endonuclease
3.1.2.7	Glutathione thioesterase
3.1.2.8	Transferred entry: 3.1.2.6
3.1.2.9	Deleted entry
3.1.30.1	Aspergillus nuclease S1
3.1.30.2	Serratia marcescens nuclease
3.1.3.10	Glucose-1-phosphatase
3.1.3.11	Fructose-bisphosphatase
3.1.31.1	Micrococcal nuclease
3.13.1.1	UDP-sulfoquinovose synthase
3.1.3.12	Trehalose-phosphatase
3.13.1.3	2'-hydroxybiphenyl-2-sulfinate desulfinase
3.1.3.13	Bisphosphoglycerate phosphatase
3.1.3.14	Methylphosphothioglycerate phosphatase
3.1.3.15	Histidinol-phosphatase
3.1.3.16	Serine/threonine specific protein phosphatase
3.1.3.17	Phosphorylase phosphatase
3.1.3.18	Phosphoglycolate phosphatase
3.1.3.19	Glycerol-2-phosphatase
3.1.3.1	Alkaline phosphatase
3.1.3.20	Phosphoglycerate phosphatase
3.1.3.21	Glycerol-1-phosphatase
3.1.3.22	Mannitol-1-phosphatase
3.1.3.23	Sugar-phosphatase
3.1.3.24	Sucrose-phosphatase
3.1.3.25	Inositol-1(or 4)-monophosphatase
3.1.3.26	4-phytase
3.1.3.27	Phosphatidylglycerophosphatase
3.1.3.28	ADP-phosphoglycerate phosphatase
3.1.3.29	N-acylneuraminate-9-phosphatase
3.1.3.2	Acid phosphatase
3.1.3.30	Transferred entry: 3.1.3.31
3.1.3.31	Nucleotidase
3.1.3.32	Polynucleotide 3'-phosphatase
3.1.3.33	Polynucleotide 5'-phosphatase
3.1.3.34	Deoxynucleotide 3'-phosphatase
3.1.3.35	Thymidylate 5'-phosphatase
3.1.3.36	Phosphoinositide 5-phosphatase
3.1.3.37	Sedoheptulose-bisphosphatase
3.1.3.38	3-phosphoglycerate phosphatase
3.1.3.39	Streptomycin-6-phosphatase
3.1.3.3	Phosphoserine phosphatase
3.1.3.40	Guanidinodeoxy-scyllo-inositol-4-phosphatase
3.1.3.41	4-nitrophenylphosphatase
3.1.3.42	[Glycogen-synthase-D]-phosphatase
3.1.3.43	[Pyruvate dehydrogenase (lipoamide)]-phosphatase
3.1.3.44	[Acetyl-CoA carboxylase]-phosphatase
3.1.3.45	3-deoxy-manno-octulosonate-8-phosphatase
3.1.3.46	Fructose-2,6-bisphosphate 2-phosphatase
3.1.3.47	[Hydroxymethylglutaryl-CoA reductase (NADPH)]-phosphatase
3.1.3.48	Protein-tyrosine-phosphatase
3.1.3.49	[Pyruvate kinase]-phosphatase
3.1.3.4	Phosphatidate phosphatase
3.1.3.50	Sorbitol-6-phosphatase
3.1.3.51	Dolichyl-phosphatase
3.1.3.52	[3-methyl-2-oxobutanoate dehydrogenase (lipoamide)]-phosphatase
3.1.3.53	[Myosin light-chain]-phosphatase
3.1.3.54	Fructose-2,6-bisphosphate 6-phosphatase
3.1.3.55	Caldesmon-phosphatase
3.1.3.5	5'-nucleotidase
3.1.3.56	Inositol-polyphosphate 5-phosphatase
3.1.3.57	Inositol-1,4-bisphosphate 1-phosphatase
3.1.3.58	Sugar-terminal-phosphatase
3.1.3.59	Alkylacetylglycerophosphatase
3.1.3.60	Phosphoenolpyruvate phosphatase
3.1.3.61	Deleted entry
3.1.3.62	Multiple inositol-polyphosphate phosphatase
3.1.3.63	2-carboxy-D-arabinitol-1-phosphatase
3.1.3.6	3'-nucleotidase
3.1.3.64	Phosphatidylinositol-3-phosphatase
3.1.3.65	Transferred entry: 3.1.3.64
3.1.3.66	Phosphatidylinositol-3,4-bisphosphate 4-phosphatase
3.1.3.67	Phosphatidylinositol-3,4,5-trisphosphate 3-phosphatase
3.1.3.68	2-deoxyglucose-6-phosphatase
3.1.3.69	Glucosylglycerol 3-phosphatase
3.1.3.70	Mannosyl-3-phosphoglycerate phosphatase
3.1.3.71	2-phosphosulfolactate phosphatase
3.1.3.72	5-phytase
3.1.3.7	3'(2'),5'-bisphosphate nucleotidase
3.1.3.73	Alpha-ribazole phosphatase
3.1.3.74	pyridoxal phosphatase
3.1.3.75	phosphoethanolamine/phosphocholine phosphatase
3.1.3.8	3-phytase
3.1.3.9	Glucose-6-phosphatase
3.1.4.10	Transferred entry: 4.6.1.13
3.1.4.11	Phosphoinositide phospholipase C
3.1.4.12	Sphingomyelin phosphodiesterase
3.1.4.13	Serine-ethanolaminephosphate phosphodiesterase
3.1.4.14	[Acyl-carrier protein] phosphodiesterase
3.1.4.15	Adenylyl-[glutamate--ammonia ligase] hydrolase
3.1.4.16	2',3'-cyclic-nucleotide 2'-phosphodiesterase
3.1.4.17	3',5'-cyclic-nucleotide phosphodiesterase
3.1.4.18	Transferred entry: 3.1.16.1
3.1.4.19	Transferred entry: 3.1.13.3
3.1.4.1	Phosphodiesterase I
3.1.4.20	Transferred entry: 3.1.13.1
3.1.4.21	Transferred entry: 3.1.30.1
3.1.4.22	Transferred entry: 3.1.27.5
3.1.4.23	Transferred entry: 3.1.27.1
3.1.4.24	Deleted entry
3.1.4.25	Transferred entry: 3.1.11.1
3.1.4.26	Deleted entry
3.1.4.27	Transferred entry: 3.1.11.2
3.1.4.28	Transferred entry: 3.1.11.3
3.1.4.29	Deleted entry
3.1.4.2	Glycerophosphocholine phosphodiesterase
3.1.4.30	Transferred entry: 3.1.21.2
3.1.4.31	Transferred entry: 3.1.11.4
3.1.4.32	Deleted entry
3.1.4.33	Deleted entry
3.1.4.34	Deleted entry
3.1.4.35	3',5'-cyclic-GMP phosphodiesterase
3.1.4.36	Transferred entry: 3.1.4.43
3.1.4.37	2',3'-cyclic nucleotide 3'-phosphodiesterase
3.1.4.38	Glycerophosphocholine cholinephosphodiesterase
3.1.4.39	Alkylglycerophosphoethanolamine phosphodiesterase
3.1.4.3	Phospholipase C
3.1.4.40	CMP-N-acylneuraminate phosphodiesterase
3.1.4.41	Sphingomyelin phosphodiesterase D
3.1.4.42	Glycerol-1,2-cyclic-phosphate 2-phosphodiesterase
3.1.4.43	Glycerophosphoinositol inositolphosphodiesterase
3.1.4.44	Glycerophosphoinositol glycerophosphodiesterase
3.1.4.45	N-acetylglucosamine-1-phosphodiester alpha-N-acetylglucosaminidase
3.1.4.46	Glycerophosphodiester phosphodiesterase
3.1.4.47	Transferred entry: 4.6.1.14
3.1.4.48	Dolichyl-phosphate-glucose phosphodiesterase
3.1.4.49	Dolichyl-phosphate-mannose phosphodiesterase
3.1.4.4	Phospholipase D
3.1.4.50	Glycosylphosphatidylinositol phospholipase D
3.1.4.51	Glucose-1-phospho-D-mannosylglycoprotein phosphodiesterase
3.1.4.5	Transferred entry: 3.1.21.1
3.1.4.6	Transferred entry: 3.1.22.1
3.1.4.7	Transferred entry: 3.1.31.1
3.1.4.8	Transferred entry: 3.1.27.3
3.1.4.9	Transferred entry: 3.1.30.2
3.1.5.1	Deoxyguanosinetriphosphate triphosphohydrolase
3.1.6.10	Chondro-6-sulfatase
3.1.6.11	Disulfoglucosamine-6-sulfatase
3.1.6.12	N-acetylgalactosamine-4-sulfatase
3.1.6.13	Iduronate-2-sulfatase
3.1.6.14	N-acetylglucosamine-6-sulfatase
3.1.6.15	N-sulfoglucosamine-3-sulfatase
3.1.6.16	Monomethyl-sulfatase
3.1.6.17	D-lactate-2-sulfatase
3.1.6.18	Glucuronate-2-sulfatase
3.1.6.1	Arylsulfatase
3.1.6.2	Steryl-sulfatase
3.1.6.3	Glycosulfatase
3.1.6.4	N-acetylgalactosamine-6-sulfatase
3.1.6.5	Deleted entry
3.1.6.6	Choline-sulfatase
3.1.6.7	Cellulose-polysulfatase
3.1.6.8	Cerebroside-sulfatase
3.1.6.9	Chondro-4-sulfatase
3.1.7.1	Prenyl-diphosphatase
3.1.7.2	Guanosine-3',5'-bis(diphosphate) 3'-pyrophosphohydrolase
3.1.7.3	Monoterpenyl-diphosphatase
3.1.8.1	Aryldialkylphosphatase
3.1.8.2	Diisopropyl-fluorophosphatase
3.2.1.100	Mannan 1,4-beta-mannobiosidase
3.2.1.101	Mannan endo-1,6-alpha-mannosidase
3.2.1.102	Blood-group-substance endo-1,4-beta-galactosidase
3.2.1.103	Keratan-sulfate endo-1,4-beta-galactosidase
3.2.1.104	Steryl-beta-glucosidase
3.2.1.105	Strictosidine beta-glucosidase
3.2.1.106	Mannosyl-oligosaccharide glucosidase
3.2.1.107	Protein-glucosylgalactosylhydroxylysine glucosidase
3.2.1.108	Lactase
3.2.1.109	Endogalactosaminidase
3.2.1.10	Oligosaccharide alpha-1,6-glucosidase
3.2.1.110	Mucinaminylserine mucinaminidase
3.2.1.111	1,3-alpha-L-fucosidase
3.2.1.112	2-deoxyglucosidase
3.2.1.113	Mannosyl-oligosaccharide 1,2-alpha-mannosidase
3.2.1.114	Mannosyl-oligosaccharide 1,3-1,6-alpha-mannosidase
3.2.1.115	Branched-dextran exo-1,2-alpha-glucosidase
3.2.1.116	Glucan 1,4-alpha-maltotriohydrolase
3.2.1.117	Amygdalin beta-glucosidase
3.2.1.118	Prunasin beta-glucosidase
3.2.1.119	Vicianin beta-glucosidase
3.2.1.11	Dextranase
3.2.1.120	Oligoxyloglucan beta-glycosidase
3.2.1.121	Polymannuronate hydrolase
3.2.1.122	Maltose-6'-phosphate glucosidase
3.2.1.123	Endoglycosylceramidase
3.2.1.124	3-deoxy-2-octulosonidase
3.2.1.125	Raucaffricine beta-glucosidase
3.2.1.126	Coniferin beta-glucosidase
3.2.1.127	1,6-alpha-L-fucosidase
3.2.1.128	Glycyrrhizinate beta-glucuronidase
3.2.1.129	Endo-alpha-sialidase
3.2.1.12	Transferred entry: 3.2.1.54
3.2.1.130	Glycoprotein endo-alpha-1,2-mannosidase
3.2.1.131	Xylan alpha-1,2-glucuronosidase
3.2.1.132	Chitosanase
3.2.1.133	Glucan 1,4-alpha-maltohydrolase
3.2.1.134	Difructose-anhydride synthase
3.2.1.135	Neopullulanase
3.2.1.136	Glucuronoarabinoxylan endo-1,4-beta-xylanase
3.2.1.137	Mannan exo-1,2-1,6-alpha-mannosidase
3.2.1.138	Transferred entry: 4.2.2.15
3.2.1.139	Alpha-glucosiduronase
3.2.1.13	Transferred entry: 3.2.1.54
3.2.1.140	Lacto-N-biosidase
3.2.1.141	4-alpha-D-{(1->4)-alpha-D-glucano}trehalose trehalohydrolase
3.2.1.142	Limit dextrinase
3.2.1.143	Poly(ADP-ribose) glycohydrolase
3.2.1.144	3-deoxyoctulosonase
3.2.1.145	Galactan 1,3-beta-galactosidase
3.2.1.146	Beta-galactofuranosidase
3.2.1.147	Thioglucosidase
3.2.1.148	Ribosylhomocysteinase
3.2.1.149	Beta-primeverosidase
3.2.1.14	Chitinase
3.2.1.150	Oligoxyloglucan reducing-end-specific cellobiohydrolase
3.2.1.151	Xyloglucan-specific endo-beta-1,4-glucanase
3.2.1.152	mannosylglycoprotein endo-beta-mannosidase
3.2.1.15	Polygalacturonase
3.2.1.16	Deleted entry
3.2.1.17	Lysozyme
3.2.1.18	Exo-alpha-sialidase
3.2.1.19	Deleted entry
3.2.1.1	Alpha-amylase
3.2.1.20	Alpha-glucosidase
3.2.1.21	Beta-glucosidase
3.2.1.22	Alpha-galactosidase
3.2.1.23	Beta-galactosidase
3.2.1.24	Alpha-mannosidase
3.2.1.25	Beta-mannosidase
3.2.1.26	Beta-fructofuranosidase
3.2.1.27	Deleted entry
3.2.1.28	Alpha,alpha-trehalase
3.2.1.29	Transferred entry: 3.2.1.52
3.2.1.2	Beta-amylase
3.2.1.30	Transferred entry: 3.2.1.52
3.2.1.31	Beta-glucuronidase
3.2.1.32	Xylan endo-1,3-beta-xylosidase
3.2.1.33	Amylo-alpha-1,6-glucosidase
3.2.1.34	Transferred entry: 3.2.1.35
3.2.1.35	Hyaluronoglucosaminidase
3.2.1.36	Hyaluronoglucuronidase
3.2.1.37	Xylan 1,4-beta-xylosidase
3.2.1.38	Beta-D-fucosidase
3.2.1.39	Glucan endo-1,3-beta-D-glucosidase
3.2.1.3	Glucan 1,4-alpha-glucosidase
3.2.1.40	Alpha-L-rhamnosidase
3.2.1.41	Pullulanase
3.2.1.42	GDP-glucosidase
3.2.1.43	Beta-L-rhamnosidase
3.2.1.44	Fucoidanase
3.2.1.45	Glucosylceramidase
3.2.1.46	Galactosylceramidase
3.2.1.47	Galactosylgalactosylglucosylceramidase
3.2.1.48	Sucrose alpha-glucosidase
3.2.1.49	Alpha-N-acetylgalactosaminidase
3.2.1.4	Cellulase
3.2.1.50	Alpha-N-acetylglucosaminidase
3.2.1.51	Alpha-L-fucosidase
3.2.1.52	Beta-N-acetylhexosaminidase
3.2.1.53	Beta-N-acetylgalactosaminidase
3.2.1.54	Cyclomaltodextrinase
3.2.1.55	Alpha-L-arabinofuranosidase
3.2.1.56	Glucuronosyl-disulfoglucosamine glucuronidase
3.2.1.57	Isopullulanase
3.2.1.58	Glucan 1,3-beta-glucosidase
3.2.1.59	Glucan endo-1,3-alpha-glucosidase
3.2.1.5	Deleted entry
3.2.1.60	Glucan 1,4-alpha-maltotetrahydrolase
3.2.1.61	Mycodextranase
3.2.1.62	Glycosylceramidase
3.2.1.63	1,2-alpha-L-fucosidase
3.2.1.64	2,6-beta-fructan 6-levanbiohydrolase
3.2.1.65	Levanase
3.2.1.66	Quercitrinase
3.2.1.67	Galacturan 1,4-alpha-galacturonidase
3.2.1.68	Isoamylase
3.2.1.69	Transferred entry: 3.2.1.41
3.2.1.6	Endo-1,3(4)-beta-glucanase
3.2.1.70	Glucan 1,6-alpha-glucosidase
3.2.1.71	Glucan endo-1,2-beta-glucosidase
3.2.1.72	Xylan 1,3-beta-xylosidase
3.2.1.73	Licheninase
3.2.1.74	Glucan 1,4-beta-glucosidase
3.2.1.75	Glucan endo-1,6-beta-glucosidase
3.2.1.76	L-iduronidase
3.2.1.77	Mannan 1,2-(1,3)-alpha-mannosidase
3.2.1.78	Mannan endo-1,4-beta-mannosidase
3.2.1.79	Transferred entry: 3.2.1.55
3.2.1.7	Inulinase
3.2.1.80	Fructan beta-fructosidase
3.2.1.81	Agarase
3.2.1.82	Exo-poly-alpha-galacturonosidase
3.2.1.83	Kappa-carrageenase
3.2.1.84	Glucan 1,3-alpha-glucosidase
3.2.1.85	6-phospho-beta-galactosidase
3.2.1.86	6-phospho-beta-glucosidase
3.2.1.87	Capsular-polysaccharide endo-1,3-alpha-galactosidase
3.2.1.88	Beta-L-arabinosidase
3.2.1.89	Arabinogalactan endo-1,4-beta-galactosidase
3.2.1.8	Endo-1,4-beta-xylanase
3.2.1.90	Deleted entry
3.2.1.91	Cellulose 1,4-beta-cellobiosidase
3.2.1.92	Peptidoglycan beta-N-acetylmuramidase
3.2.1.93	Alpha,alpha-phosphotrehalase
3.2.1.94	Glucan 1,6-alpha-isomaltosidase
3.2.1.95	Dextran 1,6-alpha-isomaltotriosidase
3.2.1.96	Mannosyl-glycoprotein endo-beta-N-acetylglucosamidase
3.2.1.97	Glycopeptide alpha-N-acetylgalactosaminidase
3.2.1.98	Glucan 1,4-alpha-maltohexaosidase
3.2.1.99	Arabinan endo-1,5-alpha-L-arabinosidase
3.2.1.9	Deleted entry
3.2.2.10	Pyrimidine-5'-nucleotide nucleosidase
3.2.2.11	Beta-aspartyl-N-acetylglucosaminidase
3.2.2.12	Inosinate nucleosidase
3.2.2.13	1-methyladenosine nucleosidase
3.2.2.14	NMN nucleosidase
3.2.2.15	DNA-deoxyinosine glycosylase
3.2.2.16	Methylthioadenosine nucleosidase
3.2.2.17	Deoxyribodipyrimidine endonucleosidase
3.2.2.18	Transferred entry: 3.5.1.52
3.2.2.19	ADP-ribosylarginine hydrolase
3.2.2.1	Purine nucleosidase
3.2.2.20	DNA-3-methyladenine glycosylase I
3.2.2.21	DNA-3-methyladenine glycosylase II
3.2.2.22	rRNA N-glycosylase
3.2.2.23	DNA-formamidopyrimidine glycosylase
3.2.2.24	ADP-ribosyl-[dinitrogen reductase] hydrolase
3.2.2.2	Inosine nucleosidase
3.2.2.3	Uridine nucleosidase
3.2.2.4	AMP nucleosidase
3.2.2.5	NAD(+) nucleosidase
3.2.2.6	NAD(P)(+) nucleosidase
3.2.2.7	Adenosine nucleosidase
3.2.2.8	Ribosylpyrimidine nucleosidase
3.2.2.9	Adenosylhomocysteine nucleosidase
3.2.3.1	Transferred entry: 3.2.1.147
3.3.1.1	Adenosylhomocysteinase
3.3.1.2	Adenosylmethionine hydrolase
3.3.1.3	Transferred entry: 3.2.1.148
3.3.2.1	Isochorismatase
3.3.2.2	Alkenylglycerophosphocholine hydrolase
3.3.2.3	Epoxide hydrolase
3.3.2.4	Trans-epoxysuccinate hydrolase
3.3.2.5	Alkenylglycerophosphoethanolamine hydrolase
3.3.2.6	Leukotriene-A4 hydrolase
3.3.2.7	Hepoxilin-epoxide hydrolase
3.3.2.8	Limonene-1,2-epoxide hydrolase
3.4.11.10	Bacterial leucyl aminopeptidase
3.4.11.11	Deleted entry
3.4.11.12	Deleted entry
3.4.11.13	Clostridial aminopeptidase
3.4.11.14	Cytosol alanyl aminopeptidase
3.4.11.15	Lysyl aminopeptidase
3.4.11.16	Xaa-Trp aminopeptidase
3.4.11.17	Tryptophanyl aminopeptidase
3.4.11.18	Methionyl aminopeptidase
3.4.11.19	D-stereospecific aminopeptidase
3.4.11.1	Leucyl aminopeptidase
3.4.11.20	Aminopeptidase Ey
3.4.11.21	Aspartyl aminopeptidase
3.4.11.22	Aminopeptidase I
3.4.11.23	PepB aminopeptidase
3.4.11.2	Membrane alanine aminopeptidase
3.4.11.3	Cystinyl aminopeptidase
3.4.11.4	Tripeptide aminopeptidase
3.4.11.5	Prolyl aminopeptidase
3.4.11.6	Aminopeptidase B
3.4.11.7	Glutamyl aminopeptidase
3.4.11.8	Transferred entry: 3.4.19.3
3.4.11.9	Xaa-Pro aminopeptidase
3.4.13.10	Transferred entry: 3.4.19.5
3.4.13.11	Transferred entry: 3.4.13.18 and 3.4.13.19
3.4.13.12	Met-Xaa dipeptidase
3.4.13.13	Transferred entry: 3.4.13.3
3.4.13.14	Deleted entry
3.4.13.15	Transferred entry: 3.4.13.18
3.4.13.16	Deleted entry
3.4.13.17	Non-stereospecific dipeptidase
3.4.13.18	Cytosol nonspecific dipeptidase
3.4.13.19	Membrane dipeptidase
3.4.13.1	Transferred entry: 3.4.13.18
3.4.13.20	Beta-Ala-His dipeptidase
3.4.13.21	Dipeptidase E
3.4.13.2	Transferred entry: 3.4.13.18
3.4.13.3	Xaa-His dipeptidase
3.4.13.4	Xaa-Arg dipeptidase
3.4.13.5	Xaa-methyl-His dipeptidase
3.4.13.6	Transferred entry: 3.4.11.2
3.4.13.7	Glu-Glu dipeptidase
3.4.13.8	Transferred entry: 3.4.13.18
3.4.13.9	Xaa-Pro dipeptidase
3.4.14.10	Tripeptidyl-peptidase II
3.4.14.11	Xaa-Pro dipeptidyl-peptidase
3.4.14.1	Dipeptidyl-peptidase I
3.4.14.2	Dipeptidyl-peptidase II
3.4.14.3	Transferred entry: 3.4.19.1
3.4.14.4	Dipeptidyl-peptidase III
3.4.14.5	Dipeptidyl-peptidase IV
3.4.14.6	Dipeptidyl-dipeptidase
3.4.14.7	Deleted entry
3.4.14.8	Transferred entry: 3.4.14.9 and 3.4.14.10
3.4.14.9	Tripeptidyl-peptidase I
3.4.15.1	Peptidyl-dipeptidase A
3.4.15.2	Transferred entry: 3.4.19.2
3.4.15.3	Transferred entry: 3.4.15.5
3.4.15.4	Peptidyl-dipeptidase B
3.4.15.5	Peptidyl-dipeptidase Dcp
3.4.16.1	Transferred entry: 3.4.16.5 and 3.4.16.6
3.4.16.2	Lysosomal Pro-X carboxypeptidase
3.4.16.3	Transferred entry: 3.4.16.5
3.4.16.4	Serine-type D-Ala-D-Ala carboxypeptidase
3.4.16.5	Carboxypeptidase C
3.4.16.6	Carboxypeptidase D
3.4.17.10	Carboxypeptidase H
3.4.17.11	Glutamate carboxypeptidase
3.4.17.12	Carboxypeptidase M
3.4.17.13	Muramoyltetrapeptide carboxypeptidase
3.4.17.14	Zinc D-Ala-D-Ala carboxypeptidase
3.4.17.15	Carboxypeptidase A2
3.4.17.16	Membrane Pro-X carboxypeptidase
3.4.17.17	Tubulinyl-Tyr carboxypeptidase
3.4.17.18	Carboxypeptidase T
3.4.17.19	Thermostable carboxypeptidase 1
3.4.17.1	Carboxypeptidase A
3.4.17.20	Carboxypeptidase U
3.4.17.21	Glutamate carboxypeptidase II
3.4.17.22	Metallocarboxypeptidase D
3.4.17.2	Carboxypeptidase B
3.4.17.3	Lysine(arginine) carboxypeptidase
3.4.17.4	Gly-X carboxypeptidase
3.4.17.5	Deleted entry
3.4.17.6	Alanine carboxypeptidase
3.4.17.7	Transferred entry: 3.5.1.28
3.4.17.8	Muramoylpentapeptide carboxypeptidase
3.4.17.9	Transferred entry: 3.4.17.4
3.4.18.1	Cysteine-type carboxypeptidase
3.4.19.10	Transferred entry: 3.5.1.28
3.4.19.11	Gamma-D-glutamyl-meso-diaminopimelate peptidase I
3.4.19.12	Ubiquitinyl hydrolase 1
3.4.19.1	Acylaminoacyl-peptidase
3.4.19.2	Peptidyl-glycinamidase
3.4.19.3	Pyroglutamyl-peptidase I
3.4.19.4	Deleted entry
3.4.19.5	Beta-aspartyl-peptidase
3.4.19.6	Pyroglutamyl-peptidase II
3.4.19.7	N-formylmethionyl-peptidase
3.4.19.8	Transferred entry: 3.4.17.21
3.4.19.9	Gamma-glutamyl hydrolase
3.4.21.100	Pseudomonalisin
3.4.21.101	Xanthomonalisin
3.4.21.102	C-terminal processing peptidase
3.4.21.103	Physarolisin
3.4.21.104	mannan-binding lectin-associated serine protease-2
3.4.21.105	rhomboid protease
3.4.21.10	Acrosin
3.4.21.11	Transferred entry: 3.4.21.36 and 3.4.21.37
3.4.21.12	Alpha-lytic endopeptidase
3.4.21.13	Transferred entry: 3.4.16.5 and 3.4.16.6
3.4.21.14	Transferred entry: 3.4.21.62, 3.4.21.65 and 3.4.21.67
3.4.21.15	Transferred entry: 3.4.21.63
3.4.21.16	Deleted entry
3.4.21.17	Deleted entry
3.4.21.18	Deleted entry
3.4.21.19	Glutamyl endopeptidase
3.4.21.1	Chymotrypsin
3.4.21.20	Cathepsin G
3.4.21.21	Coagulation factor VIIa
3.4.21.22	Coagulation factor IXa
3.4.21.23	Deleted entry
3.4.21.24	Deleted entry
3.4.21.25	Cucumisin
3.4.21.26	Prolyl oligopeptidase
3.4.21.27	Coagulation factor XIa
3.4.21.28	Transferred entry: 3.4.21.74
3.4.21.29	Transferred entry: 3.4.21.74
3.4.21.2	Chymotrypsin C
3.4.21.30	Transferred entry: 3.4.21.74
3.4.21.31	Transferred entry: 3.4.21.68 and 3.4.21.73
3.4.21.32	Brachyurin
3.4.21.33	Deleted entry
3.4.21.34	Plasma kallikrein
3.4.21.35	Tissue kallikrein
3.4.21.36	Pancreatic elastase
3.4.21.37	Leukocyte elastase
3.4.21.38	Coagulation factor XIIa
3.4.21.39	Chymase
3.4.21.3	Metridin
3.4.21.40	Deleted entry
3.4.21.41	Complement component C1r
3.4.21.42	Complement component C1s
3.4.21.43	Classical-complement pathway C3/C5 convertase
3.4.21.44	Transferred entry: 3.4.21.43
3.4.21.45	Complement factor I
3.4.21.46	Complement factor D
3.4.21.47	Alternative-complement pathway C3/C5 convertase
3.4.21.48	Cerevisin
3.4.21.49	Hypodermin C
3.4.21.4	Trypsin
3.4.21.50	Lysyl endopeptidase
3.4.21.51	Deleted entry
3.4.21.52	Deleted entry
3.4.21.53	Endopeptidase La
3.4.21.54	Gamma-renin
3.4.21.55	Venombin AB
3.4.21.56	Deleted entry
3.4.21.57	Leucyl endopeptidase
3.4.21.58	Deleted entry
3.4.21.59	Tryptase
3.4.21.5	Thrombin
3.4.21.60	Scutelarin
3.4.21.61	Kexin
3.4.21.62	Subtilisin
3.4.21.63	Oryzin
3.4.21.64	Proteinase K
3.4.21.65	Thermomycolin
3.4.21.66	Thermitase
3.4.21.67	Endopeptidase So
3.4.21.68	T-plasminogen activator
3.4.21.69	Protein C (activated)
3.4.21.6	Coagulation factor Xa
3.4.21.70	Pancreatic endopeptidase E
3.4.21.71	Pancreatic elastase II
3.4.21.72	IgA-specific serine endopeptidase
3.4.21.73	U-plasminogen activator
3.4.21.74	Venombin A
3.4.21.75	Furin
3.4.21.76	Myeloblastin
3.4.21.77	Semenogelase
3.4.21.78	Granzyme A
3.4.21.79	Granzyme B
3.4.21.7	Plasmin
3.4.21.80	Streptogrisin A
3.4.21.81	Streptogrisin B
3.4.21.82	Glutamyl endopeptidase II
3.4.21.83	Oligopeptidase B
3.4.21.84	Limulus clotting factor C
3.4.21.85	Limulus clotting factor B
3.4.21.86	Limulus clotting enzyme
3.4.21.87	Omptin
3.4.21.88	Repressor lexA
3.4.21.89	Signal peptidase I
3.4.21.8	Transferred entry: 3.4.21.34 and 3.4.21.35
3.4.21.90	Togavirin
3.4.21.91	Flavivirin
3.4.21.92	Endopeptidase Clp
3.4.21.93	Proprotein convertase 1
3.4.21.94	Proprotein convertase 2
3.4.21.95	Snake venom factor V activator
3.4.21.96	Lactocepin
3.4.21.97	Assemblin
3.4.21.98	Hepacivirin
3.4.21.99	Spermosin
3.4.21.9	Enteropeptidase
3.4.22.10	Streptopain
3.4.22.11	Transferred entry: 3.4.24.56
3.4.22.12	Transferred entry: 3.4.19.9
3.4.22.13	Deleted entry
3.4.22.14	Actinidain
3.4.22.15	Cathepsin L
3.4.22.16	Cathepsin H
3.4.22.17	Transferred entry: 3.4.22.52 and 3.4.22.53
3.4.22.18	Transferred entry: 3.4.21.26
3.4.22.19	Transferred entry: 3.4.24.15
3.4.22.1	Cathepsin B
3.4.22.20	Deleted entry
3.4.22.21	Transferred entry: 3.4.25.1
3.4.22.22	Transferred entry: 3.4.24.37
3.4.22.23	Transferred entry: 3.4.21.61
3.4.22.24	Cathepsin T
3.4.22.25	Glycyl endopeptidase
3.4.22.26	Cancer procoagulant
3.4.22.27	Cathepsin S
3.4.22.28	Picornain 3C
3.4.22.29	Picornain 2A
3.4.22.2	Papain
3.4.22.30	Caricain
3.4.22.31	Ananain
3.4.22.32	Stem bromelain
3.4.22.33	Fruit bromelain
3.4.22.34	Legumain
3.4.22.35	Histolysain
3.4.22.36	Caspase-1
3.4.22.37	Gingipain R
3.4.22.38	Cathepsin K
3.4.22.39	Adenain
3.4.22.3	Ficain
3.4.22.40	Bleomycin hydrolase
3.4.22.41	Cathepsin F
3.4.22.42	Cathepsin O
3.4.22.43	Cathepsin V
3.4.22.44	Nuclear-inclusion-a endopeptidase
3.4.22.45	Helper-component proteinase
3.4.22.46	L-peptidase
3.4.22.47	Gingipain K
3.4.22.48	Staphopain
3.4.22.49	Separase
3.4.22.4	Transferred entry: 3.4.22.32 and 3.4.22.33
3.4.22.50	V-cath endopeptidase
3.4.22.51	Cruzipain
3.4.22.52	Calpain-1
3.4.22.53	Calpain-2
3.4.22.5	Transferred entry: 3.4.22.33
3.4.22.6	Chymopapain
3.4.22.7	Asclepain
3.4.22.8	Clostripain
3.4.22.9	Transferred entry: 3.4.21.48
3.4.23.10	Transferred entry: 3.4.23.22
3.4.23.11	Deleted entry
3.4.23.12	Neopenthesin
3.4.23.13	Deleted entry
3.4.23.14	Deleted entry
3.4.23.15	Renin
3.4.23.16	HIV-1 retropepsin
3.4.23.17	Pro-opiomelanocortin converting enzyme
3.4.23.18	Aspergillopepsin I
3.4.23.19	Aspergillopepsin II
3.4.23.1	Pepsin A
3.4.23.20	Penicillopepsin
3.4.23.21	Rhizopuspepsin
3.4.23.22	Endothiapepsin
3.4.23.23	Mucoropepsin
3.4.23.24	Candidapepsin
3.4.23.25	Saccharopepsin
3.4.23.26	Rhodotorulapepsin
3.4.23.27	Transferred entry: 3.4.21.103
3.4.23.28	Acrocylindropepsin
3.4.23.29	Polyporopepsin
3.4.23.2	Pepsin B
3.4.23.30	Pycnoporopepsin
3.4.23.31	Scytalidopepsin A
3.4.23.32	Scytalidopepsin B
3.4.23.33	Transferred entry: 3.4.21.101
3.4.23.34	Cathepsin E
3.4.23.35	Barrierpepsin
3.4.23.36	Signal peptidase II
3.4.23.37	Transferred entry: 3.4.21.100
3.4.23.38	Plasmepsin I
3.4.23.39	Plasmepsin II
3.4.23.3	Gastricsin
3.4.23.40	Phytepsin
3.4.23.41	Yapsin 1
3.4.23.42	Thermopsin
3.4.23.43	Prepilin peptidase
3.4.23.44	Nodavirus endopeptidase
3.4.23.45	Memapsin 1
3.4.23.46	Memapsin 2
3.4.23.47	HIV-2 retropepsin
3.4.23.48	Plasminogen activator Pla
3.4.23.4	Chymosin
3.4.23.5	Cathepsin D
3.4.23.6	Transferred entry: 3.4.21.103, 3.4.23.18, 3.4.23.28 and 3.4.23.30
3.4.23.7	Transferred entry: 3.4.23.20
3.4.23.8	Transferred entry: 3.4.23.25
3.4.23.9	Transferred entry: 3.4.23.21
3.4.24.10	Deleted entry
3.4.24.11	Neprilysin
3.4.24.12	Envelysin
3.4.24.13	IgA-specific metalloendopeptidase
3.4.24.14	Procollagen N-endopeptidase
3.4.24.15	Thimet oligopeptidase
3.4.24.16	Neurolysin
3.4.24.17	Stromelysin 1
3.4.24.18	Meprin A
3.4.24.19	Procollagen C-endopeptidase
3.4.24.1	Atrolysin A
3.4.24.20	Peptidyl-Lys metalloendopeptidase
3.4.24.21	Astacin
3.4.24.22	Stromelysin 2
3.4.24.23	Matrilysin
3.4.24.24	Gelatinase A
3.4.24.25	Aeromonolysin
3.4.24.26	Pseudolysin
3.4.24.27	Thermolysin
3.4.24.28	Bacillolysin
3.4.24.29	Aureolysin
3.4.24.2	Deleted entry
3.4.24.30	Coccolysin
3.4.24.31	Mycolysin
3.4.24.32	Beta-lytic metalloendopeptidase
3.4.24.33	Peptidyl-Asp metalloendopeptidase
3.4.24.34	Neutrophil collagenase
3.4.24.35	Gelatinase B
3.4.24.36	Leishmanolysin
3.4.24.37	Saccharolysin
3.4.24.38	Gametolysin
3.4.24.39	Deuterolysin
3.4.24.3	Microbial collagenase
3.4.24.40	Serralysin
3.4.24.41	Atrolysin B
3.4.24.42	Atrolysin C
3.4.24.43	Atroxase
3.4.24.44	Atrolysin E
3.4.24.45	Atrolysin F
3.4.24.46	Adamalysin
3.4.24.47	Horrilysin
3.4.24.48	Ruberlysin
3.4.24.49	Bothropasin
3.4.24.4	Transferred entry: 3.4.24.25, 3.4.24.32, 3.4.24.39 and 3.4.24.40
3.4.24.50	Bothrolysin
3.4.24.51	Ophiolysin
3.4.24.52	Trimerelysin I
3.4.24.53	Trimerelysin II
3.4.24.54	Mucrolysin
3.4.24.55	Pitrilysin
3.4.24.56	Insulysin
3.4.24.57	O-sialoglycoprotein endopeptidase
3.4.24.58	Russellysin
3.4.24.59	Mitochondrial intermediate peptidase
3.4.24.5	Transferred entry: 3.4.25.1
3.4.24.60	Dactylysin
3.4.24.61	Nardilysin
3.4.24.62	Magnolysin
3.4.24.63	Meprin B
3.4.24.64	Mitochondrial processing peptidase
3.4.24.65	Macrophage elastase
3.4.24.66	Choriolysin L
3.4.24.67	Choriolysin H
3.4.24.68	Tentoxilysin
3.4.24.69	Bontoxilysin
3.4.24.6	Leucolysin
3.4.24.70	Oligopeptidase A
3.4.24.71	Endothelin-converting enzyme 1
3.4.24.72	Fibrolase
3.4.24.73	Jararhagin
3.4.24.74	Fragilysin
3.4.24.75	Lysostaphin
3.4.24.76	Flavastacin
3.4.24.77	Snapalysin
3.4.24.78	GPR endopeptidase
3.4.24.79	Pappalysin-1
3.4.24.7	Interstitial collagenase
3.4.24.80	Membrane-type matrix metalloproteinase-1
3.4.24.81	ADAM10 endopeptidase
3.4.24.82	ADAMTS-4 endopeptidase
3.4.24.83	Anthrax lethal factor endopeptidase
3.4.24.84	Ste24 endopeptidase
3.4.24.85	S2P endopeptidase
3.4.24.86	ADAM 17 endopeptidase
3.4.24.8	Transferred entry: 3.4.24.3
3.4.24.9	Deleted entry
3.4.25.1	Proteasome endopeptidase complex
3.4.99.10	Transferred entry: 3.4.24.56
3.4.99.11	Deleted entry
3.4.99.12	Deleted entry
3.4.99.13	Transferred entry: 3.4.24.32
3.4.99.14	Deleted entry
3.4.99.15	Deleted entry
3.4.99.16	Deleted entry
3.4.99.17	Deleted entry
3.4.99.18	Deleted entry
3.4.99.19	Transferred entry: 3.4.23.15
3.4.99.1	Transferred entry: 3.4.23.28
3.4.99.20	Deleted entry
3.4.99.21	Deleted entry
3.4.99.22	Transferred entry: 3.4.24.29
3.4.99.23	Deleted entry
3.4.99.24	Deleted entry
3.4.99.25	Transferred entry: 3.4.23.21
3.4.99.26	Transferred entry: 3.4.21.68 and 3.4.21.73
3.4.99.27	Deleted entry
3.4.99.28	Transferred entry: 3.4.21.60
3.4.99.29	Deleted entry
3.4.99.2	Deleted entry
3.4.99.30	Transferred entry: 3.4.24.20
3.4.99.31	Transferred entry: 3.4.24.15
3.4.99.32	Transferred entry: 3.4.24.20
3.4.99.33	Deleted entry
3.4.99.34	Deleted entry
3.4.99.35	Transferred entry: 3.4.23.36
3.4.99.36	Transferred entry: 3.4.21.89
3.4.99.37	Deleted entry
3.4.99.38	Transferred entry: 3.4.23.17
3.4.99.39	Deleted entry
3.4.99.3	Deleted entry
3.4.99.40	Deleted entry
3.4.99.41	Transferred entry: 3.4.24.64
3.4.99.42	Deleted entry
3.4.99.43	Transferred entry: 3.4.23.42
3.4.99.44	Transferred entry: 3.4.24.55
3.4.99.45	Transferred entry: 3.4.24.56
3.4.99.46	Transferred entry: 3.4.25.1
3.4.99.4	Transferred entry: 3.4.23.12
3.4.99.5	Transferred entry: 3.4.24.3
3.4.99.6	Transferred entry: 3.4.24.21
3.4.99.7	Deleted entry
3.4.99.8	Deleted entry
3.4.99.9	Deleted entry
3.5.1.10	Formyltetrahydrofolate deformylase
3.5.1.11	Penicillin amidase
3.5.1.12	Biotinidase
3.5.1.13	Aryl-acylamidase
3.5.1.14	Aminoacylase
3.5.1.15	Aspartoacylase
3.5.1.16	Acetylornithine deacetylase
3.5.1.17	Acyl-lysine deacylase
3.5.1.18	Succinyl-diaminopimelate desuccinylase
3.5.1.19	Nicotinamidase
3.5.1.1	Asparaginase
3.5.1.20	Citrullinase
3.5.1.21	N-acetyl-beta-alanine deacetylase
3.5.1.22	Pantothenase
3.5.1.23	Ceramidase
3.5.1.24	Choloylglycine hydrolase
3.5.1.25	N-acetylglucosamine-6-phosphate deacetylase
3.5.1.26	N(4)-(beta-N-acetylglucosaminyl)-L-asparaginase
3.5.1.27	N-formylmethionylaminoacyl-tRNA deformylase
3.5.1.28	N-acetylmuramoyl-L-alanine amidase
3.5.1.29	2-(acetamidomethylene)succinate hydrolase
3.5.1.2	Glutaminase
3.5.1.30	5-aminopentanamidase
3.5.1.31	Formylmethionine deformylase
3.5.1.32	Hippurate hydrolase
3.5.1.33	N-acetylglucosamine deacetylase
3.5.1.34	Transferred entry: 3.4.13.5
3.5.1.35	D-glutaminase
3.5.1.36	N-methyl-2-oxoglutaramate hydrolase
3.5.1.37	Transferred entry: 3.5.1.26
3.5.1.38	Glutaminase-(asparagin-)ase
3.5.1.39	Alkylamidase
3.5.1.3	Omega-amidase
3.5.1.40	Acylagmatine amidase
3.5.1.41	Chitin deacetylase
3.5.1.42	Nicotinamide-nucleotide amidase
3.5.1.43	Peptidyl-glutaminase
3.5.1.44	Protein-glutamine glutaminase
3.5.1.45	Transferred entry: 6.3.4.6
3.5.1.46	6-aminohexanoate-dimer hydrolase
3.5.1.47	N-acetyldiaminopimelate deacetylase
3.5.1.48	Acetylspermidine deacetylase
3.5.1.49	Formamidase
3.5.1.4	Amidase
3.5.1.50	Pentanamidase
3.5.1.51	4-acetamidobutyryl-CoA deacetylase
3.5.1.52	Peptide-N(4)-(N-acetyl-beta-glucosaminyl)asparagine amidase
3.5.1.53	N-carbamoylputrescine amidase
3.5.1.54	Allophanate hydrolase
3.5.1.55	Long-chain-fatty-acyl-glutamate deacylase
3.5.1.56	N,N-dimethylformamidase
3.5.1.57	Tryptophanamidase
3.5.1.58	N-benzyloxycarbonylglycine hydrolase
3.5.1.59	N-carbamoylsarcosine amidase
3.5.1.5	Urease
3.5.1.60	N-(long-chain-acyl)ethanolamine deacylase
3.5.1.61	Mimosinase
3.5.1.62	Acetylputrescine deacetylase
3.5.1.63	4-acetamidobutyrate deacetylase
3.5.1.64	N(alpha)-benzyloxycarbonyl-leucine hydrolase
3.5.1.65	Theanine hydrolase
3.5.1.66	2-(hydroxymethyl)-3-(acetamidomethylene)succinate hydrolase
3.5.1.67	4-methyleneglutaminase
3.5.1.68	N-formylglutamate deformylase
3.5.1.69	Glycosphingolipid deacylase
3.5.1.6	Beta-ureidopropionase
3.5.1.70	Aculeacin-A deacylase
3.5.1.71	N-feruloylglycine deacylase
3.5.1.72	D-benzoylarginine-4-nitroanilide amidase
3.5.1.73	Carnitinamidase
3.5.1.74	Chenodeoxycholoyltaurine hydrolase
3.5.1.75	Urethanase
3.5.1.76	Arylalkyl acylamidase
3.5.1.77	N-carbamoyl-D-amino acid hydrolase
3.5.1.78	Glutathionylspermidine amidase
3.5.1.79	Phthalyl amidase
3.5.1.7	Ureidosuccinase
3.5.1.80	Deleted entry
3.5.1.81	N-acyl-D-amino-acid deacylase
3.5.1.82	N-acyl-D-glutamate deacylase
3.5.1.83	N-acyl-D-aspartate deacylase
3.5.1.84	Biuret amidohydrolase
3.5.1.85	(S)-N-acetyl-1-phenylethylamine hydrolase
3.5.1.86	Mandelamide amidase
3.5.1.87	N-carbamoyl-L-amino-acid hydrolase
3.5.1.88	Peptide deformylase
3.5.1.89	N-acetylglucosaminylphosphatidylinositol deacetylase
3.5.1.8	Formylaspartate deformylase
3.5.1.90	adenosylcobinamide hydrolase
3.5.1.92	pantetheine hydrolase
3.5.1.93	glutaryl-7-aminocephalosporanic-acid acylase
3.5.1.9	Arylformamidase
3.5.2.10	Creatininase
3.5.2.11	L-lysine-lactamase
3.5.2.12	6-aminohexanoate-cyclic dimer hydrolase
3.5.2.13	2,5-dioxopiperazine hydrolase
3.5.2.14	N-methylhydantoinase (ATP-hydrolyzing)
3.5.2.15	Cyanuric acid amidohydrolase
3.5.2.16	Maleimide hydrolase
3.5.2.17	Hydroxyisourate hydrolase
3.5.2.1	Barbiturase
3.5.2.2	Dihydropyrimidinase
3.5.2.3	Dihydroorotase
3.5.2.4	Carboxymethylhydantoinase
3.5.2.5	Allantoinase
3.5.2.6	Beta-lactamase
3.5.2.7	Imidazolonepropionase
3.5.2.8	Transferred entry: 3.5.2.6
3.5.2.9	5-oxoprolinase (ATP-hydrolyzing)
3.5.3.10	D-arginase
3.5.3.11	Agmatinase
3.5.3.12	Agmatine deiminase
3.5.3.13	Formimidoylglutamate deiminase
3.5.3.14	Amidinoaspartase
3.5.3.15	Protein-arginine deiminase
3.5.3.16	Methylguanidinase
3.5.3.17	Guanidinopropionase
3.5.3.18	Dimethylargininase
3.5.3.19	Ureidoglycolate hydrolase
3.5.3.1	Arginase
3.5.3.20	Diguanidinobutanase
3.5.3.21	Methylenediurea deaminase
3.5.3.22	Proclavaminate amidinohydrolase
3.5.3.2	Guanidinoacetase
3.5.3.3	Creatinase
3.5.3.4	Allantoicase
3.5.3.5	Formimidoylaspartate deiminase
3.5.3.6	Arginine deiminase
3.5.3.7	Guanidinobutyrase
3.5.3.8	Formimidoylglutamase
3.5.3.9	Allantoate deiminase
3.5.4.10	IMP cyclohydrolase
3.5.4.11	Pterin deaminase
3.5.4.12	dCMP deaminase
3.5.4.13	dCTP deaminase
3.5.4.14	Deoxycytidine deaminase
3.5.4.15	Guanosine deaminase
3.5.4.16	GTP cyclohydrolase I
3.5.4.17	Adenosine-phosphate deaminase
3.5.4.18	ATP deaminase
3.5.4.19	Phosphoribosyl-AMP cyclohydrolase
3.5.4.1	Cytosine deaminase
3.5.4.20	Pyrithiamine deaminase
3.5.4.21	Creatinine deaminase
3.5.4.22	1-pyrroline-4-hydroxy-2-carboxylate deaminase
3.5.4.23	Blasticidin-S deaminase
3.5.4.24	Sepiapterin deaminase
3.5.4.25	GTP cyclohydrolase II
3.5.4.26	Diaminohydroxyphosphoribosylaminopyrimidine deaminase
3.5.4.27	Methenyltetrahydromethanopterin cyclohydrolase
3.5.4.28	S-adenosylhomocysteine deaminase
3.5.4.29	GTP cyclohydrolase IIa
3.5.4.2	Adenine deaminase
3.5.4.30	dCTP deaminase (dUMP-forming)
3.5.4.3	Guanine deaminase
3.5.4.4	Adenosine deaminase
3.5.4.5	Cytidine deaminase
3.5.4.6	AMP deaminase
3.5.4.7	ADP deaminase
3.5.4.8	Aminoimidazolase
3.5.4.9	Methenyltetrahydrofolate cyclohydrolase
3.5.5.1	Nitrilase
3.5.5.2	Ricinine nitrilase
3.5.5.3	Transferred entry: 4.2.1.104
3.5.5.4	Cyanoalanine nitrilase
3.5.5.5	Arylacetonitrilase
3.5.5.6	Bromoxynil nitrilase
3.5.5.7	Aliphatic nitrilase
3.5.5.8	Thiocyanate hydrolase
3.5.99.1	Riboflavinase
3.5.99.2	Thiaminase
3.5.99.3	Hydroxydechloroatrazine ethylaminohydrolase
3.5.99.4	N-isopropylammelide isopropylaminohydrolase
3.5.99.5	2-aminomuconate deaminase
3.5.99.6	Glucosamine-6-phosphate deaminase
3.5.99.7	1-aminocyclopropane-1-carboxylate deaminase
3.6.1.10	Endopolyphosphatase
3.6.1.11	Exopolyphosphatase
3.6.1.12	dCTP diphosphatase
3.6.1.13	ADP-ribose diphosphatase
3.6.1.14	Adenosine-tetraphosphatase
3.6.1.15	Nucleoside-triphosphatase
3.6.1.16	CDP-glycerol diphosphatase
3.6.1.17	Bis(5'-nucleosyl)-tetraphosphatase (asymmetrical)
3.6.1.18	FAD diphosphatase
3.6.1.19	Nucleoside-triphosphate diphosphatase
3.6.1.1	Inorganic diphosphatase
3.6.1.20	5'-acylphosphoadenosine hydrolase
3.6.1.21	ADP-sugar diphosphatase
3.6.1.22	NAD+ diphosphatase
3.6.1.23	dUTP diphosphatase
3.6.1.24	Nucleoside phosphoacylhydrolase
3.6.1.25	Triphosphatase
3.6.1.26	CDP-diacylglycerol diphosphatase
3.6.1.27	Undecaprenyl-diphosphatase
3.6.1.28	Thiamine-triphosphatase
3.6.1.29	Bis(5'-adenosyl)-triphosphatase
3.6.1.2	Trimetaphosphatase
3.6.1.30	M(7)G(5')pppN diphosphatase
3.6.1.31	Phosphoribosyl-ATP diphosphatase
3.6.1.32	Transferred entry: 3.6.4.1
3.6.1.33	Transferred entry: 3.6.4.2
3.6.1.34	Transferred entry: 3.6.3.14
3.6.1.35	Transferred entry: 3.6.3.6
3.6.1.36	Transferred entry: 3.6.3.10
3.6.1.37	Transferred entry: 3.6.3.9
3.6.1.38	Transferred entry: 3.6.3.8
3.6.1.39	Thymidine-triphosphatase
3.6.1.3	Adenosinetriphosphatase
3.6.1.40	Guanosine-5'-triphosphate,3'-diphosphate diphosphatase
3.6.1.41	Bis(5'-nucleosyl)-tetraphosphatase (symmetrical)
3.6.1.42	Guanosine-diphosphatase
3.6.1.43	Dolichyldiphosphatase
3.6.1.44	Oligosaccharide-diphosphodolichol diphosphatase
3.6.1.45	UDP-sugar diphosphatase
3.6.1.46	Transferred entry: 3.6.5.1
3.6.1.47	Transferred entry: 3.6.5.2
3.6.1.48	Transferred entry: 3.6.5.3
3.6.1.49	Transferred entry: 3.6.5.4
3.6.1.4	Transferred entry: 3.6.1.3
3.6.1.50	Transferred entry: 3.6.5.5
3.6.1.51	Transferred entry: 3.6.5.6
3.6.1.52	Diphosphoinositol-polyphosphate diphosphatase
3.6.1.5	Apyrase
3.6.1.6	Nucleoside-diphosphatase
3.6.1.7	Acylphosphatase
3.6.1.8	ATP diphosphatase
3.6.1.9	Nucleotide diphosphatase
3.6.2.1	Adenylylsulfatase
3.6.2.2	Phosphoadenylylsulfatase
3.6.3.10	Hydrogen/potassium-exchanging ATPase
3.6.3.11	Chloride-transporting ATPase
3.6.3.12	Potassium-transporting ATPase
3.6.3.13	Transferred entry: 3.6.3.1
3.6.3.14	H(+)-transporting two-sector ATPase
3.6.3.15	Sodium-transporting two-sector ATPase
3.6.3.16	Arsenite-transporting ATPase
3.6.3.17	Monosaccharide-transporting ATPase
3.6.3.18	Oligosaccharide-transporting ATPase
3.6.3.19	Maltose-transporting ATPase
3.6.3.1	Magnesium-ATPase
3.6.3.20	Glycerol-3-phosphate-transporting ATPase
3.6.3.21	Polar-amino-acid-transporting ATPase
3.6.3.22	Nonpolar-amino-acid-transporting ATPase
3.6.3.23	Oligopeptide-transporting ATPase
3.6.3.24	Nickel-transporting ATPase
3.6.3.25	Sulfate-transporting ATPase
3.6.3.26	Nitrate-transporting ATPase
3.6.3.27	Phosphate-transporting ATPase
3.6.3.28	Phosphonate-transporting ATPase
3.6.3.29	Molybdate-transporting ATPase
3.6.3.2	Magnesium-importing ATPase
3.6.3.30	Fe(3+)-transporting ATPase
3.6.3.31	Polyamine-transporting ATPase
3.6.3.32	Quaternary-amine-transporting ATPase
3.6.3.33	Vitamin B12-transporting ATPase
3.6.3.34	Iron-chelate-transporting ATPase
3.6.3.35	Manganese-transporting ATPase
3.6.3.36	Taurine-transporting ATPase
3.6.3.37	Guanine-transporting ATPase
3.6.3.38	Capsular-polysaccharide-transporting ATPase
3.6.3.39	Lipopolysaccharide-transporting ATPase
3.6.3.3	Cadmium-exporting ATPase
3.6.3.40	Teichoic-acid-transporting ATPase
3.6.3.41	Heme-transporting ATPase
3.6.3.42	Beta-glucan-transporting ATPase
3.6.3.43	Peptide-transporting ATPase
3.6.3.44	Xenobiotic-transporting ATPase
3.6.3.45	Steroid-transporting ATPase
3.6.3.46	Cadmium-transporting ATPase
3.6.3.47	Fatty-acyl-CoA-transporting ATPase
3.6.3.48	Alpha-factor-transporting ATPase
3.6.3.49	Channel-conductance-controlling ATPase
3.6.3.4	Copper-exporting ATPase
3.6.3.50	Protein-secreting ATPase
3.6.3.51	Mitochondrial protein-transporting ATPase
3.6.3.52	Chloroplast protein-transporting ATPase
3.6.3.53	Ag(+)-exporting ATPase
3.6.3.5	Zinc-exporting ATPase
3.6.3.6	Proton-exporting ATPase
3.6.3.7	Sodium-exporting ATPase
3.6.3.8	Calcium-transporting ATPase
3.6.3.9	Sodium/potassium-exchanging ATPase
3.6.4.10	Non-chaperonin molecular chaperone ATPase
3.6.4.11	Nucleoplasmin ATPase
3.6.4.1	Myosin ATPase
3.6.4.2	Dynein ATPase
3.6.4.3	Microtubule-severing ATPase
3.6.4.4	Plus-end-directed kinesin ATPase
3.6.4.5	Minus-end-directed kinesin ATPase
3.6.4.6	Vesicle-fusing ATPase
3.6.4.7	Peroxisome-assembly ATPase
3.6.4.8	Proteasome ATPase
3.6.4.9	Chaperonin ATPase
3.6.5.1	Heterotrimeric G-protein GTPase
3.6.5.2	Small monomeric GTPase
3.6.5.3	Protein-synthesizing GTPase
3.6.5.4	Signal-recognition-particle GTPase
3.6.5.5	Dynamin GTPase
3.6.5.6	Tubulin GTPase
3.7.1.10	Cyclohexane-1,3-dione hydrolase
3.7.1.1	Oxaloacetase
3.7.1.2	Fumarylacetoacetase
3.7.1.3	Kynureninase
3.7.1.4	Phloretin hydrolase
3.7.1.5	Acylpyruvate hydrolase
3.7.1.6	Acetylpyruvate hydrolase
3.7.1.7	Beta-diketone hydrolase
3.7.1.8	2,6-dioxo-6-phenylhexa-3-enoate hydrolase
3.7.1.9	2-hydroxymuconate-semialdehyde hydrolase
3.8.1.10	2-haloacid dehalogenase (configuration-inverting)
3.8.1.11	2-haloacid dehalogenase (configuration-retaining)
3.8.1.1	Alkylhalidase
3.8.1.2	(S)-2-haloacid dehalogenase
3.8.1.3	Haloacetate dehalogenase
3.8.1.4	Transferred entry: 1.97.1.10
3.8.1.5	Haloalkane dehalogenase
3.8.1.6	4-chlorobenzoate dehalogenase
3.8.1.7	4-chlorobenzoyl-CoA dehalogenase
3.8.1.8	Atrazine chlorohydrolase
3.8.1.9	(R)-2-haloacid dehalogenase
3.8.2.1	Transferred entry: 3.1.8.2
3.9.1.1	Phosphoamidase
4.1.1.10	Transferred entry: 4.1.1.12
4.1.1.11	Aspartate 1-decarboxylase
4.1.1.12	Aspartate 4-decarboxylase
4.1.1.13	Deleted entry
4.1.1.14	Valine decarboxylase
4.1.1.15	Glutamate decarboxylase
4.1.1.16	Hydroxyglutamate decarboxylase
4.1.1.17	Ornithine decarboxylase
4.1.1.18	Lysine decarboxylase
4.1.1.19	Arginine decarboxylase
4.1.1.1	Pyruvate decarboxylase
4.1.1.20	Diaminopimelate decarboxylase
4.1.1.21	Phosphoribosylaminoimidazole carboxylase
4.1.1.22	Histidine decarboxylase
4.1.1.23	Orotidine-5'-phosphate decarboxylase
4.1.1.24	Aminobenzoate decarboxylase
4.1.1.25	Tyrosine decarboxylase
4.1.1.26	Transferred entry: 4.1.1.28
4.1.1.27	Transferred entry: 4.1.1.28
4.1.1.28	Aromatic-L-amino-acid decarboxylase
4.1.1.29	Sulfinoalanine decarboxylase
4.1.1.2	Oxalate decarboxylase
4.1.1.30	Pantothenoylcysteine decarboxylase
4.1.1.31	Phosphoenolpyruvate carboxylase
4.1.1.32	Phosphoenolpyruvate carboxykinase (GTP)
4.1.1.33	Diphosphomevalonate decarboxylase
4.1.1.34	Dehydro-L-gulonate decarboxylase
4.1.1.35	UDP-glucuronate decarboxylase
4.1.1.36	Phosphopantothenoylcysteine decarboxylase
4.1.1.37	Uroporphyrinogen decarboxylase
4.1.1.38	Phosphoenolpyruvate carboxykinase (diphosphate)
4.1.1.39	Ribulose-bisphosphate carboxylase
4.1.1.3	Oxaloacetate decarboxylase
4.1.1.40	Hydroxypyruvate decarboxylase
4.1.1.41	Methylmalonyl-CoA decarboxylase
4.1.1.42	Carnitine decarboxylase
4.1.1.43	Phenylpyruvate decarboxylase
4.1.1.44	4-carboxymuconolactone decarboxylase
4.1.1.45	Aminocarboxymuconate-semialdehyde decarboxylase
4.1.1.46	O-pyrocatechuate decarboxylase
4.1.1.47	Tartronate-semialdehyde synthase
4.1.1.48	Indole-3-glycerol-phosphate synthase
4.1.1.49	Phosphoenolpyruvate carboxykinase (ATP)
4.1.1.4	Acetoacetate decarboxylase
4.1.1.50	Adenosylmethionine decarboxylase
4.1.1.51	3-hydroxy-2-methylpyridine-4,5-dicarboxylate 4-decarboxylase
4.1.1.52	6-methylsalicylate decarboxylase
4.1.1.53	Phenylalanine decarboxylase
4.1.1.54	Dihydroxyfumarate decarboxylase
4.1.1.55	4,5-dihydroxyphthalate decarboxylase
4.1.1.56	3-oxolaurate decarboxylase
4.1.1.57	Methionine decarboxylase
4.1.1.58	Orsellinate decarboxylase
4.1.1.59	Gallate decarboxylase
4.1.1.5	Acetolactate decarboxylase
4.1.1.60	Stipitatonate decarboxylase
4.1.1.61	4-hydroxybenzoate decarboxylase
4.1.1.62	Gentisate decarboxylase
4.1.1.63	Protocatechuate decarboxylase
4.1.1.64	2,2-dialkylglycine decarboxylase (pyruvate)
4.1.1.65	Phosphatidylserine decarboxylase
4.1.1.66	Uracil-5-carboxylate decarboxylase
4.1.1.67	UDP-galacturonate decarboxylase
4.1.1.68	5-oxopent-3-ene-1,2,5-tricarboxylate decarboxylase
4.1.1.69	3,4-dihydroxyphthalate decarboxylase
4.1.1.6	Aconitate decarboxylase
4.1.1.70	Glutaconyl-CoA decarboxylase
4.1.1.71	2-oxoglutarate decarboxylase
4.1.1.72	Branched-chain-2-oxoacid decarboxylase
4.1.1.73	Tartrate decarboxylase
4.1.1.74	Indolepyruvate decarboxylase
4.1.1.75	5-guanidino-2-oxopentanoate decarboxylase
4.1.1.76	Arylmalonate decarboxylase
4.1.1.77	4-oxalocrotonate decarboxylase
4.1.1.78	Acetylenedicarboxylate decarboxylase
4.1.1.79	Sulfopyruvate decarboxylase
4.1.1.7	Benzoylformate decarboxylase
4.1.1.80	4-hydroxyphenylpyruvate decarboxylase
4.1.1.81	Threonine-phosphate decarboxylase
4.1.1.82	phosphonopyruvate decarboxylase
4.1.1.84	D-dopachrome decarboxylase
4.1.1.85	3-dehydro-L-gulonate-6-phosphate decarboxylase
4.1.1.8	Oxalyl-CoA decarboxylase
4.1.1.9	Malonyl-CoA decarboxylase
4.1.2.10	Mandelonitrile lyase
4.1.2.11	Hydroxymandelonitrile lyase
4.1.2.12	2-dehydropantoate aldolase
4.1.2.13	Fructose-bisphosphate aldolase
4.1.2.14	2-dehydro-3-deoxyphosphogluconate aldolase
4.1.2.15	Transferred entry: 2.5.1.54
4.1.2.16	Transferred entry: 2.5.1.55
4.1.2.17	L-fuculose-phosphate aldolase
4.1.2.18	2-dehydro-3-deoxy-L-pentonate aldolase
4.1.2.19	Rhamnulose-1-phosphate aldolase
4.1.2.1	Transferred entry: 4.1.3.16
4.1.2.20	2-dehydro-3-deoxyglucarate aldolase
4.1.2.21	2-dehydro-3-deoxyphosphogalactonate aldolase
4.1.2.22	Fructose-6-phosphate phosphoketolase
4.1.2.23	3-deoxy-D-manno-octulosonate aldolase
4.1.2.24	Dimethylaniline-N-oxide aldolase
4.1.2.25	Dihydroneopterin aldolase
4.1.2.26	Phenylserine aldolase
4.1.2.27	Sphinganine-1-phosphate aldolase
4.1.2.28	2-dehydro-3-deoxy-D-pentonate aldolase
4.1.2.29	5-dehydro-2-deoxyphosphogluconate aldolase
4.1.2.2	Ketotetrose-phosphate aldolase
4.1.2.30	17-alpha-hydroxyprogesterone aldolase
4.1.2.31	Transferred entry: 4.1.3.16
4.1.2.32	Trimethylamine-oxide aldolase
4.1.2.33	Fucosterol-epoxide lyase
4.1.2.34	4-(2-carboxyphenyl)-2-oxobut-3-enoate aldolase
4.1.2.35	Propioin synthase
4.1.2.36	Lactate aldolase
4.1.2.37	Acetone-cyanohydrin lyase
4.1.2.38	Benzoin aldolase
4.1.2.39	Hydroxynitrilase
4.1.2.3	Deleted entry
4.1.2.40	Tagatose-bisphosphate aldolase
4.1.2.41	Vanillin synthase
4.1.2.4	Deoxyribose-phosphate aldolase
4.1.2.5	Threonine aldolase
4.1.2.6	Deleted entry
4.1.2.7	Transferred entry: 4.1.2.13
4.1.2.8	Deleted entry
4.1.2.9	Phosphoketolase
4.1.3.10	Transferred entry: 2.3.3.7
4.1.3.11	Transferred entry: 2.3.3.12
4.1.3.12	Transferred entry: 2.3.3.13
4.1.3.13	Oxalomalate lyase
4.1.3.14	3-hydroxyaspartate aldolase
4.1.3.15	Transferred entry: 2.2.1.5
4.1.3.16	4-hydroxy-2-oxoglutarate aldolase
4.1.3.17	4-hydroxy-4-methyl-2-oxoglutarate aldolase
4.1.3.18	Transferred entry: 2.2.1.6
4.1.3.19	Transferred entry: 2.5.1.56
4.1.3.1	Isocitrate lyase
4.1.3.20	Transferred entry: 2.5.1.57
4.1.3.21	Transferred entry: 2.3.3.14
4.1.3.22	Citramalate lyase
4.1.3.23	Transferred entry: 2.3.3.2
4.1.3.24	Malyl-CoA lyase
4.1.3.25	Citramalyl-CoA lyase
4.1.3.26	3-hydroxy-3-isohexenylglutaryl-CoA lyase
4.1.3.27	Anthranilate synthase
4.1.3.28	Transferred entry: 2.3.3.3
4.1.3.29	Transferred entry: 2.3.3.4
4.1.3.2	Transferred entry: 2.3.3.9
4.1.3.30	Methylisocitrate lyase
4.1.3.31	Transferred entry: 2.3.3.5
4.1.3.32	2,3-dimethylmalate lyase
4.1.3.33	Transferred entry: 2.3.3.6
4.1.3.34	Citryl-CoA lyase
4.1.3.35	(1-hydroxycyclohexan-1-yl)acetyl-CoA lyase
4.1.3.36	Naphthoate synthase
4.1.3.37	Transferred entry: 2.2.1.7
4.1.3.38	Aminodeoxychorismate lyase
4.1.3.3	N-acetylneuraminate lyase
4.1.3.4	Hydroxymethylglutaryl-CoA lyase
4.1.3.5	Transferred entry: 2.3.3.10
4.1.3.6	Citrate lyase
4.1.3.7	Transferred entry: 2.3.3.1
4.1.3.8	Transferred entry: 2.3.3.8
4.1.3.9	Transferred entry: 2.3.3.11
4.1.99.10	Transferred entry: 4.2.3.16
4.1.99.11	Benzylsuccinate synthase
4.1.99.1	Tryptophanase
4.1.99.2	Tyrosine phenol-lyase
4.1.99.3	Deoxyribodipyrimidine photolyase
4.1.99.4	Transferred entry: 3.5.99.7
4.1.99.5	Octadecanal decarbonylase
4.1.99.6	Transferred entry: 4.2.3.6
4.1.99.7	Transferred entry: 4.2.3.9
4.1.99.8	Transferred entry: 4.2.3.14
4.1.99.9	Transferred entry: 4.2.3.15
4.2.1.100	Cyclohexa-1,5-dienecarbonyl-CoA hydratase
4.2.1.101	Trans-feruloyl-CoA hydratase
4.2.1.102	Transferred entry: 4.2.1.100
4.2.1.103	Cyclohexyl-isocyanide hydratase
4.2.1.10	3-dehydroquinate dehydratase
4.2.1.104	Cyanate hydratase
4.2.1.106	bile-acid 7-alpha-dehydratase
4.2.1.107	3-alpha,7-alpha,12-alpha-trihydroxy-5-beta-cholest-24-enoyl-CoA hydratase
4.2.1.11	Phosphopyruvate hydratase
4.2.1.12	Phosphogluconate dehydratase
4.2.1.13	Transferred entry: 4.3.1.17
4.2.1.14	Transferred entry: 4.3.1.18
4.2.1.15	Transferred entry: 4.4.1.1
4.2.1.16	Transferred entry: 4.3.1.19
4.2.1.17	Enoyl-CoA hydratase
4.2.1.18	Methylglutaconyl-CoA hydratase
4.2.1.19	Imidazoleglycerol-phosphate dehydratase
4.2.1.1	Carbonate dehydratase
4.2.1.20	Tryptophan synthase
4.2.1.21	Transferred entry: 4.2.1.22
4.2.1.22	Cystathionine beta-synthase
4.2.1.23	Deleted entry
4.2.1.24	Porphobilinogen synthase
4.2.1.25	L-arabinonate dehydratase
4.2.1.26	Transferred entry: 4.3.1.9
4.2.1.27	Acetylenecarboxylate hydratase
4.2.1.28	Propanediol dehydratase
4.2.1.29	Indoleacetaldoxime dehydratase
4.2.1.2	Fumarate hydratase
4.2.1.30	Glycerol dehydratase
4.2.1.31	Maleate hydratase
4.2.1.32	L(+)-tartrate dehydratase
4.2.1.33	3-isopropylmalate dehydratase
4.2.1.34	(S)-2-methylmalate dehydratase
4.2.1.35	(R)-2-methylmalate dehydratase
4.2.1.36	Homoaconitate hydratase
4.2.1.37	Transferred entry: 3.3.2.4
4.2.1.38	Transferred entry: 4.3.1.20
4.2.1.39	Gluconate dehydratase
4.2.1.3	Aconitate hydratase
4.2.1.40	Glucarate dehydratase
4.2.1.41	5-dehydro-4-deoxyglucarate dehydratase
4.2.1.42	Galactarate dehydratase
4.2.1.43	2-dehydro-3-deoxy-L-arabinonate dehydratase
4.2.1.44	Myo-inosose-2 dehydratase
4.2.1.45	CDP-glucose 4,6-dehydratase
4.2.1.46	dTDP-glucose 4,6-dehydratase
4.2.1.47	GDP-mannose 4,6-dehydratase
4.2.1.48	D-glutamate cyclase
4.2.1.49	Urocanate hydratase
4.2.1.4	Citrate dehydratase
4.2.1.50	Pyrazolylalanine synthase
4.2.1.51	Prephenate dehydratase
4.2.1.52	Dihydrodipicolinate synthase
4.2.1.53	Oleate hydratase
4.2.1.54	Lactoyl-CoA dehydratase
4.2.1.55	3-hydroxybutyryl-CoA dehydratase
4.2.1.56	Itaconyl-CoA hydratase
4.2.1.57	Isohexenylglutaconyl-CoA hydratase
4.2.1.58	Crotonoyl-[acyl-carrier protein] hydratase
4.2.1.59	3-hydroxyoctanoyl-[acyl-carrier protein] dehydratase
4.2.1.5	Arabinonate dehydratase
4.2.1.60	3-hydroxydecanoyl-[acyl-carrier protein] dehydratase
4.2.1.61	3-hydroxypalmitoyl-[acyl-carrier protein] dehydratase
4.2.1.62	5-alpha-hydroxysteroid dehydratase
4.2.1.63	Transferred entry: 3.3.2.3
4.2.1.64	Transferred entry: 3.3.2.3
4.2.1.65	3-cyanoalanine hydratase
4.2.1.66	Cyanide hydratase
4.2.1.67	D-fuconate hydratase
4.2.1.68	L-fuconate hydratase
4.2.1.69	Cyanamide hydratase
4.2.1.6	Galactonate dehydratase
4.2.1.70	Pseudouridylate synthase
4.2.1.71	Transferred entry: 4.2.1.27
4.2.1.72	Transferred entry: 4.1.1.78
4.2.1.73	Protoaphin-aglucone dehydratase (cyclizing)
4.2.1.74	Long-chain-enoyl-CoA hydratase
4.2.1.75	Uroporphyrinogen-III synthase
4.2.1.76	UDP-glucose 4,6-dehydratase
4.2.1.77	Trans-L-3-hydroxyproline dehydratase
4.2.1.78	(S)-norcoclaurine synthase
4.2.1.79	2-methylcitrate dehydratase
4.2.1.7	Altronate dehydratase
4.2.1.80	2-oxopent-4-enoate hydratase
4.2.1.81	D(-)-tartrate dehydratase
4.2.1.82	Xylonate dehydratase
4.2.1.83	4-oxalmesaconate hydratase
4.2.1.84	Nitrile hydratase
4.2.1.85	Dimethylmaleate hydratase
4.2.1.86	16-dehydroprogesterone hydratase
4.2.1.87	Octopamine dehydratase
4.2.1.88	Synephrine dehydratase
4.2.1.89	L-carnitine dehydratase
4.2.1.8	Mannonate dehydratase
4.2.1.90	L-rhamnonate dehydratase
4.2.1.91	Carboxycyclohexadienyl dehydratase
4.2.1.92	Hydroperoxide dehydratase
4.2.1.93	ATP-dependent H(4)NAD(P)OH dehydratase
4.2.1.94	Scytalone dehydratase
4.2.1.95	Kievitone hydratase
4.2.1.96	4a-hydroxytetrahydrobiopterin dehydratase
4.2.1.97	Phaseollidin hydratase
4.2.1.98	16-alpha-hydroxyprogesterone dehydratase
4.2.1.99	2-methylisocitrate dehydratase
4.2.1.9	Dihydroxy-acid dehydratase
4.2.2.10	Pectin lyase
4.2.2.11	Poly(alpha-L-guluronate) lyase
4.2.2.12	Xanthan lyase
4.2.2.13	Exo-(1,4)-alpha-D-glucan lyase
4.2.2.14	Glucuronan lyase
4.2.2.15	Anhydrosialidase
4.2.2.16	Levan fructotransferase (DFA-IV-forming)
4.2.2.17	Inulin fructotransferase (DFA-I-forming)
4.2.2.18	Inulin fructotransferase (DFA-III-forming)
4.2.2.19	chondroitin B lyase
4.2.2.1	Hyaluronate lyase
4.2.2.2	Pectate lyase
4.2.2.3	Poly(beta-D-mannuronate) lyase
4.2.2.4	Chondroitin ABC lyase
4.2.2.5	Chondroitin AC lyase
4.2.2.6	Oligogalacturonide lyase
4.2.2.7	Heparin lyase
4.2.2.8	Heparitin-sulfate lyase
4.2.2.9	Pectate disaccharide-lyase
4.2.3.10	(-)-endo-fenchol synthase
4.2.3.11	Sabinene-hydrate synthase
4.2.3.12	6-pyruvoyltetrahydropterin synthase
4.2.3.13	(+)-delta-cadinene synthase
4.2.3.14	Pinene synthase
4.2.3.15	Myrcene synthase
4.2.3.16	(4S)-limonene synthase
4.2.3.17	Taxadiene synthase
4.2.3.18	Abietadiene synthase
4.2.3.19	Ent-kaurene synthase
4.2.3.1	Threonine synthase
4.2.3.20	(R)-limonene synthase
4.2.3.2	Ethanolamine-phosphate phospho-lyase
4.2.3.3	Methylglyoxal synthase
4.2.3.4	3-dehydroquinate synthase
4.2.3.5	Chorismate synthase
4.2.3.6	Trichodiene synthase
4.2.3.7	Pentalenene synthase
4.2.3.8	Casbene synthase
4.2.3.9	Aristolochene synthase
4.2.99.10	Transferred entry: 2.5.1.49
4.2.99.11	Transferred entry: 4.2.3.3
4.2.99.12	Carboxymethyloxysuccinate lyase
4.2.99.13	Transferred entry: 2.5.1.50
4.2.99.14	Transferred entry: 2.5.1.51
4.2.99.15	Transferred entry: 2.5.1.52
4.2.99.16	Transferred entry: 2.5.1.53
4.2.99.17	Transferred entry: 2.5.1.51
4.2.99.18	DNA-(apurinic or apyrimidinic site) lyase
4.2.99.19	2-hydroxypropyl-CoM lyase
4.2.99.1	Transferred entry: 4.2.2.1
4.2.99.2	Transferred entry: 4.2.3.1
4.2.99.3	Transferred entry: 4.2.2.2
4.2.99.4	Transferred entry: 4.2.2.3
4.2.99.5	Deleted entry
4.2.99.6	Transferred entry: 4.2.2.4 and 4.2.2.5
4.2.99.7	Transferred entry: 4.2.3.2
4.2.99.8	Transferred entry: 2.5.1.47
4.2.99.9	Transferred entry: 2.5.1.48
4.3.1.10	Serine-sulfate ammonia-lyase
4.3.1.11	Dihydroxyphenylalanine ammonia-lyase
4.3.1.12	Ornithine cyclodeaminase
4.3.1.13	Carbamoyl-serine ammonia-lyase
4.3.1.14	3-aminobutyryl-CoA ammonia-lyase
4.3.1.15	Diaminopropionate ammonia-lyase
4.3.1.16	Threo-3-hydroxyaspartate ammonia-lyase
4.3.1.17	L-serine ammonia-lyase
4.3.1.18	D-serine ammonia-lyase
4.3.1.19	Threonine ammonia-lyase
4.3.1.1	Aspartate ammonia-lyase
4.3.1.20	Erythro-3-hydroxyaspartate ammonia-lyase
4.3.1.21	Transferred entry: 4.3.1.9
4.3.1.2	Methylaspartate ammonia-lyase
4.3.1.3	Histidine ammonia-lyase
4.3.1.4	Formimidoyltetrahydrofolate cyclodeaminase
4.3.1.5	Phenylalanine ammonia-lyase
4.3.1.6	Beta-alanyl-CoA ammonia-lyase
4.3.1.7	Ethanolamine ammonia-lyase
4.3.1.8	Transferred entry: 2.5.1.61
4.3.1.9	Glucosaminate ammonia-lyase
4.3.2.1	Argininosuccinate lyase
4.3.2.2	Adenylosuccinate lyase
4.3.2.3	Ureidoglycolate lyase
4.3.2.4	Purine imidazole-ring cyclase
4.3.2.5	Peptidylamidoglycolate lyase
4.3.3.1	3-ketovalidoxylamine C-N-lyase
4.3.3.2	Strictosidine synthase
4.3.3.3	Deacetylisoipecoside synthase
4.3.3.4	Deacetylipecoside synthase
4.3.99.1	Transferred entry: 4.2.1.104
4.4.1.10	Cysteine lyase
4.4.1.11	Methionine gamma-lyase
4.4.1.12	Transferred entry: 2.3.3.15
4.4.1.13	Cysteine-S-conjugate beta-lyase
4.4.1.14	1-aminocyclopropane-1-carboxylate synthase
4.4.1.15	D-cysteine desulfhydrase
4.4.1.16	Selenocysteine lyase
4.4.1.17	Holocytochrome-c synthase
4.4.1.18	Transferred entry: 1.8.3.5
4.4.1.19	Phosphosulfolactate synthase
4.4.1.1	Cystathionine gamma-lyase
4.4.1.20	Leukotriene-C4 synthase
4.4.1.21	S-ribosylhomocysteine lyase
4.4.1.22	S-(hydroxymethyl)glutathione synthase
4.4.1.23	2-hydroxypropyl-CoM lyase
4.4.1.2	Homocysteine desulfhydrase
4.4.1.3	Dimethylpropiothetin dethiomethylase
4.4.1.4	Alliin lyase
4.4.1.5	Lactoylglutathione lyase
4.4.1.6	S-alkylcysteine lyase
4.4.1.7	Transferred entry: 2.5.1.18
4.4.1.8	Cystathionine beta-lyase
4.4.1.9	L-3-cyanoalanine synthase
4.5.1.1	DDT-dehydrochlorinase
4.5.1.2	3-chloro-D-alanine dehydrochlorinase
4.5.1.3	Dichloromethane dehalogenase
4.5.1.4	L-2-amino-4-chloropent-4-enoate dehydrochlorinase
4.5.1.5	S-carboxymethylcysteine synthase
4.6.1.10	Transferred entry: 4.2.3.12
4.6.1.11	Transferred entry: 4.2.3.13
4.6.1.12	2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase
4.6.1.13	Phosphatidylinositol diacylglycerol-lyase
4.6.1.14	Glycosylphosphatidylinositol diacylglycerol-lyase
4.6.1.15	FAD-AMP lyase (cyclizing)
4.6.1.1	Adenylate cyclase
4.6.1.2	Guanylate cyclase
4.6.1.3	Transferred entry: 4.2.3.4
4.6.1.4	Transferred entry: 4.2.3.5
4.6.1.5	Transferred entry: 4.2.3.7
4.6.1.6	Cytidylate cyclase
4.6.1.7	Transferred entry: 4.2.3.8
4.6.1.8	Transferred entry: 4.2.3.10
4.6.1.9	Transferred entry: 4.2.3.11
4.99.1.1	Ferrochelatase
4.99.1.2	Alkylmercury lyase
4.99.1.3	Sirohydrochlorin cobaltochelatase
4.99.1.4	Sirohydrochlorin ferrochelatase
4.99.1.7	phenylacetaldoxime dehydratase
5.1.1.10	Amino-acid racemase
5.1.1.11	Phenylalanine racemase (ATP-hydrolyzing)
5.1.1.12	Ornithine racemase
5.1.1.13	Aspartate racemase
5.1.1.14	Nocardicin-A epimerase
5.1.1.15	2-aminohexano-6-lactam racemase
5.1.1.16	Protein-serine epimerase
5.1.1.17	Isopenicillin-N epimerase
5.1.1.1	Alanine racemase
5.1.1.2	Methionine racemase
5.1.1.3	Glutamate racemase
5.1.1.4	Proline racemase
5.1.1.5	Lysine racemase
5.1.1.6	Threonine racemase
5.1.1.7	Diaminopimelate epimerase
5.1.1.8	4-hydroxyproline epimerase
5.1.1.9	Arginine racemase
5.1.2.1	Lactate racemase
5.1.2.2	Mandelate racemase
5.1.2.3	3-hydroxybutyryl-CoA epimerase
5.1.2.4	Acetoin racemase
5.1.2.5	Tartrate epimerase
5.1.2.6	Isocitrate epimerase
5.1.3.10	CDP-abequose epimerase
5.1.3.11	Cellobiose epimerase
5.1.3.12	UDP-glucuronate 5'-epimerase
5.1.3.13	dTDP-4-dehydrorhamnose 3,5-epimerase
5.1.3.14	UDP-N-acetylglucosamine 2-epimerase
5.1.3.15	Glucose-6 phosphate 1-epimerase
5.1.3.16	UDP-glucosamine epimerase
5.1.3.17	Heparosan-N-sulfate-glucuronate 5-epimerase
5.1.3.18	GDP-mannose 3,5-epimerase
5.1.3.19	Chondroitin-glucuronate 5-epimerase
5.1.3.1	Ribulose-phosphate 3-epimerase
5.1.3.20	ADP-glyceromanno-heptose 6-epimerase
5.1.3.21	Maltose epimerase
5.1.3.22	L-ribulose-5-phosphate 3-epimerase
5.1.3.2	UDP-glucose 4-epimerase
5.1.3.3	Aldose 1-epimerase
5.1.3.4	L-ribulose-phosphate 4-epimerase
5.1.3.5	UDP-arabinose 4-epimerase
5.1.3.6	UDP-glucuronate 4-epimerase
5.1.3.7	UDP-N-acetylglucosamine 4-epimerase
5.1.3.8	N-acylglucosamine 2-epimerase
5.1.3.9	N-acylglucosamine-6-phosphate 2-epimerase
5.1.99.1	Methylmalonyl-CoA epimerase
5.1.99.2	16-hydroxysteroid epimerase
5.1.99.3	Allantoin racemase
5.1.99.4	Alpha-methylacyl-CoA racemase
5.2.1.10	2-chloro-4-carboxymethylenebut-2-en-1,4-olide isomerase
5.2.1.11	4-hydroxyphenylacetaldehyde-oxime isomerase
5.2.1.1	Maleate isomerase
5.2.1.2	Maleylacetoacetate isomerase
5.2.1.3	Retinal isomerase
5.2.1.4	Maleylpyruvate isomerase
5.2.1.5	Linoleate isomerase
5.2.1.6	Furylfuramide isomerase
5.2.1.7	Retinol isomerase
5.2.1.8	Peptidylprolyl isomerase
5.2.1.9	Farnesol 2-isomerase
5.3.1.10	Transferred entry: 3.5.99.6
5.3.1.11	Deleted entry
5.3.1.12	Glucuronate isomerase
5.3.1.13	Arabinose-5-phosphate isomerase
5.3.1.14	L-rhamnose isomerase
5.3.1.15	D-lyxose ketol-isomerase
5.3.1.16	1-(5-phosphoribosyl)-5-[(5-phosphoribosylamino)methylideneamino]imidazole-4-carboxamide isomerase
5.3.1.17	4-deoxy-L-threo-5-hexosulose-uronate ketol-isomerase
5.3.1.18	Deleted entry
5.3.1.19	Transferred entry: 2.6.1.16
5.3.1.1	Triosephosphate isomerase
5.3.1.20	Ribose isomerase
5.3.1.21	Corticosteroid side-chain-isomerase
5.3.1.22	Hydroxypyruvate isomerase
5.3.1.23	S-methyl-5-thioribose-1-phosphate isomerase
5.3.1.24	Phosphoribosylanthranilate isomerase
5.3.1.25	L-fucose isomerase
5.3.1.26	Galactose-6-phosphate isomerase
5.3.1.2	Deleted entry
5.3.1.3	Arabinose isomerase
5.3.1.4	L-arabinose isomerase
5.3.1.5	Xylose isomerase
5.3.1.6	Ribose 5-phosphate epimerase
5.3.1.7	Mannose isomerase
5.3.1.8	Mannose-6-phosphate isomerase
5.3.1.9	Glucose-6-phosphate isomerase
5.3.2.1	Phenylpyruvate tautomerase
5.3.2.2	Oxaloacetate tautomerase
5.3.3.10	5-carboxymethyl-2-hydroxymuconate delta-isomerase
5.3.3.11	Isopiperitenone delta-isomerase
5.3.3.12	Dopachrome isomerase
5.3.3.13	Polyenoic fatty acid isomerase
5.3.3.1	Steroid delta-isomerase
5.3.3.2	Isopentenyl-diphosphate delta-isomerase
5.3.3.3	Vinylacetyl-CoA delta-isomerase
5.3.3.4	Muconolactone delta-isomerase
5.3.3.5	Cholestenol delta-isomerase
5.3.3.6	Methylitaconate delta-isomerase
5.3.3.7	Aconitate delta-isomerase
5.3.3.8	Dodecenoyl-CoA delta-isomerase
5.3.3.9	Prostaglandin-A1 delta-isomerase
5.3.4.1	Protein disulfide isomerase
5.3.99.1	Deleted entry
5.3.99.2	Prostaglandin-D synthase
5.3.99.3	Prostaglandin-E synthase
5.3.99.4	Prostaglandin-I synthase
5.3.99.5	Thromboxane-A synthase
5.3.99.6	Allene-oxide cyclase
5.3.99.7	Styrene-oxide isomerase
5.3.99.8	capsanthin/capsorubin synthase
5.4.1.1	Lysolecithin acylmutase
5.4.1.2	Precorrin-8X methylmutase
5.4.2.10	Phosphoglucosamine mutase
5.4.2.1	Phosphoglycerate mutase
5.4.2.2	Phosphoglucomutase
5.4.2.3	Phosphoacetylglucosamine mutase
5.4.2.4	Bisphosphoglycerate mutase
5.4.2.5	Phosphoglucomutase (glucose-cofactor)
5.4.2.6	Beta-phosphoglucomutase
5.4.2.7	Phosphopentomutase
5.4.2.8	Phosphomannomutase
5.4.2.9	Phosphoenolpyruvate mutase
5.4.3.1	Deleted entry
5.4.3.2	Lysine 2,3-aminomutase
5.4.3.3	Beta-lysine 5,6-aminomutase
5.4.3.4	D-lysine 5,6-aminomutase
5.4.3.5	D-ornithine 4,5-aminomutase
5.4.3.6	Tyrosine 2,3-aminomutase
5.4.3.7	Leucine 2,3-aminomutase
5.4.3.8	Glutamate-1-semialdehyde 2,1-aminomutase
5.4.4.1	(Hydroxyamino)benzene mutase
5.4.4.2	Isochorismate synthase
5.4.4.3	3-(hydroxyamino)phenol mutase
5.4.99.10	Transferred entry: 5.4.99.11
5.4.99.11	Isomaltulose synthase
5.4.99.12	tRNA-pseudouridine synthase I
5.4.99.13	Isobutyryl-CoA mutase
5.4.99.14	4-carboxymethyl-4-methylbutenolide mutase
5.4.99.15	(1->4)-alpha-D-glucan 1-alpha-D-glucosylmutase
5.4.99.16	Maltose alpha-D-glucosyltransferase
5.4.99.17	Squalene--hopene cyclase
5.4.99.1	Methylaspartate mutase
5.4.99.2	Methylmalonyl-CoA mutase
5.4.99.3	2-acetolactate mutase
5.4.99.4	2-methyleneglutarate mutase
5.4.99.5	Chorismate mutase
5.4.99.6	Transferred entry: 5.4.4.2
5.4.99.7	Lanosterol synthase
5.4.99.8	Cycloartenol synthase
5.4.99.9	UDP-galactopyranose mutase
5.5.1.10	Alpha-pinene-oxide decyclase
5.5.1.11	Dichloromuconate cycloisomerase
5.5.1.12	Copalyl diphosphate synthase
5.5.1.13	Ent-copalyl diphosphate synthase
5.5.1.1	Muconate cycloisomerase
5.5.1.2	3-carboxy-cis,cis-muconate cycloisomerase
5.5.1.3	Tetrahydroxypteridine cycloisomerase
5.5.1.4	Inositol-3-phosphate synthase
5.5.1.5	Carboxy-cis,cis-muconate cyclase
5.5.1.6	Chalcone isomerase
5.5.1.7	Chloromuconate cycloisomerase
5.5.1.8	Geranyl-diphosphate cyclase
5.5.1.9	Cycloeucalenol cycloisomerase
5.99.1.1	Thiocyanate isomerase
5.99.1.2	DNA topoisomerase
5.99.1.3	DNA topoisomerase (ATP-hydrolyzing)
6.1.1.10	Methionine--tRNA ligase
6.1.1.11	Serine--tRNA ligase
6.1.1.12	Aspartate--tRNA ligase
6.1.1.13	D-alanine--poly(phosphoribitol)ligase
6.1.1.14	Glycine--tRNA ligase
6.1.1.15	Proline--tRNA ligase
6.1.1.16	Cysteine--tRNA ligase
6.1.1.17	Glutamate--tRNA ligase
6.1.1.18	Glutamine--tRNA ligase
6.1.1.19	Arginine--tRNA ligase
6.1.1.1	Tyrosine--tRNA ligase
6.1.1.20	Phenylalanine--tRNA ligase
6.1.1.21	Histidine--tRNA ligase
6.1.1.22	Asparagine--tRNA ligase
6.1.1.23	Aspartate--tRNA(Asn) ligase
6.1.1.24	Glutamate--tRNA(Gln) ligase
6.1.1.25	Lysine--tRNA(Pyl) ligase
6.1.1.2	Tryptophan--tRNA ligase
6.1.1.3	Threonine--tRNA ligase
6.1.1.4	Leucine--tRNA ligase
6.1.1.5	Isoleucine--tRNA ligase
6.1.1.6	Lysine--tRNA ligase
6.1.1.7	Alanine--tRNA ligase
6.1.1.8	Deleted entry
6.1.1.9	Valine--tRNA ligase
6.2.1.10	Acid--CoA ligase (GDP-forming)
6.2.1.11	Biotin--CoA ligase
6.2.1.12	4-coumarate--CoA ligase
6.2.1.13	Acetate--CoA ligase (ADP-forming)
6.2.1.14	6-carboxyhexanoate--CoA ligase
6.2.1.15	Arachidonate--CoA ligase
6.2.1.16	Acetoacetate--CoA ligase
6.2.1.17	Propionate--CoA ligase
6.2.1.18	Citrate--CoA ligase
6.2.1.19	Long-chain-fatty-acid--luciferin-component ligase
6.2.1.1	Acetate--CoA ligase
6.2.1.20	Long-chain-fatty-acid--acyl-carrier protein ligase
6.2.1.21	Deleted entry
6.2.1.22	[Citrate (pro-3S)-lyase] ligase
6.2.1.23	Dicarboxylate--CoA ligase
6.2.1.24	Phytanate--CoA ligase
6.2.1.25	Benzoate--CoA ligase
6.2.1.26	O-succinylbenzoate--CoA ligase
6.2.1.27	4-hydroxybenzoate--CoA ligase
6.2.1.28	3-alpha,7-alpha-dihydroxy-5-beta-cholestanate--CoA ligase
6.2.1.29	3-alpha,7-alpha,12-alpha-trihydroxy-5-beta-cholestanate--CoA ligase
6.2.1.2	Butyrate--CoA ligase
6.2.1.30	Phenylacetate--CoA ligase
6.2.1.31	2-furoate--CoA ligase
6.2.1.32	Anthranilate--CoA ligase
6.2.1.33	4-chlorobenzoate-CoA ligase
6.2.1.34	Trans-feruloyl-CoA synthase
6.2.1.3	Long-chain-fatty-acid--CoA ligase
6.2.1.4	Succinate--CoA ligase (GDP-forming)
6.2.1.5	Succinate--CoA ligase (ADP-forming)
6.2.1.6	Glutarate--CoA ligase
6.2.1.7	Cholate--CoA ligase
6.2.1.8	Oxalate--CoA ligase
6.2.1.9	Malate--CoA ligase
6.3.1.10	Adenosylcobinamide-phosphate synthase
6.3.1.11	glutamate-putrescine ligase
6.3.1.1	Aspartate--ammonia ligase
6.3.1.2	Glutamate--ammonia ligase
6.3.1.3	Transferred entry: 6.3.4.13
6.3.1.4	Aspartate--ammonia ligase (ADP-forming)
6.3.1.5	NAD(+) synthase
6.3.1.6	Glutamate--ethylamine ligase
6.3.1.7	4-methyleneglutamate--ammonia ligase
6.3.1.8	Glutathionylspermidine synthase
6.3.1.9	Trypanothione synthase
6.3.2.10	UDP-N-acetylmuramoyl-tripeptide--D-alanyl-D-alanine ligase
6.3.2.11	Carnosine synthase
6.3.2.12	Dihydrofolate synthase
6.3.2.13	UDP-N-acetylmuramoylalanyl-D-glutamate--2,6-diaminopimelate ligase
6.3.2.14	2,3-dihydroxybenzoate--serine ligase
6.3.2.15	Transferred entry: 6.3.2.10
6.3.2.16	D-alanine--alanyl-poly(glycerolphosphate) ligase
6.3.2.17	Folylpolyglutamate synthase
6.3.2.18	Gamma-glutamylhistamine synthase
6.3.2.19	Ubiquitin--protein ligase
6.3.2.1	Pantoate--beta-alanine ligase
6.3.2.20	Indoleacetate--lysine ligase
6.3.2.21	Ubiquitin--calmodulin ligase
6.3.2.22	Diphthine--ammonia ligase
6.3.2.23	Homoglutathione synthase
6.3.2.24	Tyrosine--arginine ligase
6.3.2.25	Tubulin--tyrosine ligase
6.3.2.26	N-(5-amino-5-carboxypentanoyl)-L-cysteinyl-D-valine synthase
6.3.2.27	Aerobactin synthase
6.3.2.2	Glutamate--cysteine ligase
6.3.2.3	Glutathione synthase
6.3.2.4	D-alanine--D-alanine ligase
6.3.2.5	Phosphopantothenate--cysteine ligase
6.3.2.6	Phosphoribosylaminoimidazole-succinocarboxamide synthase
6.3.2.7	UDP-N-acetylmuramoyl-L-alanyl-D-glutamate--L-lysine ligase
6.3.2.8	UDP-N-acetylmuramate--L-alanine ligase
6.3.2.9	UDP-N-acetylmuramoylalanine--D-glutamate ligase
6.3.3.1	Phosphoribosylformylglycinamidine cyclo-ligase
6.3.3.2	5-formyltetrahydrofolate cyclo-ligase
6.3.3.3	Dethiobiotin synthase
6.3.3.4	(Carboxyethyl)arginine beta-lactam-synthase
6.3.4.10	Biotin--[propionyl-CoA-carboxylase (ATP-hydrolyzing)] ligase
6.3.4.11	Biotin--[methylcrotonoyl-CoA-carboxylase] ligase
6.3.4.12	Glutamate--methylamine ligase
6.3.4.13	Phosphoribosylamine--glycine ligase
6.3.4.14	Biotin carboxylase
6.3.4.15	Biotin--[acetyl-CoA-carboxylase] ligase
6.3.4.16	Carbamoyl-phosphate synthase (ammonia)
6.3.4.17	Formate--dihydrofolate ligase
6.3.4.1	GMP synthase
6.3.4.2	CTP synthase
6.3.4.3	Formate--tetrahydrofolate ligase
6.3.4.4	Adenylosuccinate synthase
6.3.4.5	Argininosuccinate synthase
6.3.4.6	Urea carboxylase
6.3.4.7	Ribose-5-phosphate--ammonia ligase
6.3.4.8	Imidazoleacetate--phosphoribosyldiphosphate ligase
6.3.4.9	Biotin--[methylmalonyl-CoA-carboxytransferase] ligase
6.3.5.10	Adenosylcobyric acid synthase (glutamine-hydrolyzing)
6.3.5.1	NAD(+) synthase (glutamine-hydrolyzing)
6.3.5.2	GMP synthase (glutamine-hydrolyzing)
6.3.5.3	Phosphoribosylformylglycinamidine synthase
6.3.5.4	Asparagine synthase (glutamine-hydrolyzing)
6.3.5.5	Carbamoyl-phosphate synthase (glutamine-hydrolyzing)
6.3.5.6	Asparaginyl-tRNA synthase (glutamine-hydrolyzing)
6.3.5.7	Glutaminyl-tRNA synthase (glutamine-hydrolyzing)
6.3.5.8	Aminodeoxychorismate synthase
6.3.5.9	Hydrogenobyrinic acid a,c-diamide synthase (glutamine-hydrolyzing)
6.4.1.1	Pyruvate carboxylase
6.4.1.2	Acetyl-CoA carboxylase
6.4.1.3	Propionyl-CoA carboxylase
6.4.1.4	Methylcrotonyl-CoA carboxylase
6.4.1.5	Geranoyl-CoA carboxylase
6.4.1.6	Acetone carboxylase
6.5.1.1	DNA ligase (ATP)
6.5.1.2	DNA ligase (NAD+)
6.5.1.3	RNA ligase (ATP)
6.5.1.4	RNA-3'-phosphate cyclase
6.6.1.1	Magnesium chelatase
6.6.1.2	Cobaltochelatase
