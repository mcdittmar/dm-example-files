#!/usr/bin/env perl
#
use File::Compare;

print "Welcome to the 'pyvodm' based - DM example file generator.\n";

# Parameters
my $doCoords   = 0;
my $doMeas     = 1;
my $doValidate = 1;
my @doFormats  = ("xxx", "vot", "avot", "xml");

# Check Dependencies
print "  o Checking setup.. \n";
$anyprobs = 0;
$check = `python -c "from pyvodm import *" `;
print "      * pyvodm: ";
if ($check ne "" ){
    print "ERROR: Can not find pyvodm module, check PYTHONPATH. \n";
    ${anyprobs}++;
}
else {
    print "OK\n";
}
$check = qx( which voefg );
print "      * voefg: ";
if ($check eq "" ){
    print "ERROR: Can not find voefg utility, check PATH. \n";
    ${anyprobs}++;
}
else {
    print "OK\n";
}
if ( $doValidate )
{
    my %formats = map { $_ => 1 } @doFormats;
    if ( exists( $formats{'xml'} ) || exists( $format{'avot'} ) )
    {
        $check = qx( which xmllint );
        print "      * xmllint: ";
        if ($check eq "" ){
            print "ERROR: Can not find xmllint utility, can not perform validation. \n";
            ${anyprobs}++;
        }
        else {
            print "OK\n";
        }
    }
    if ( exists( $formats{'vot'} ) )
    {
        $check = qx( java -jar stilts.jar -version );
        print "      * stilts: ";
        if ($check eq "" ){
            print "ERROR: Can not find stilts jar in classpath, can not perform validation. \n";
            ${anyprobs}++;
        }
        else {
            print "OK\n";
        }
    }
}
if ($anyprobs){ exit; }
    
#
# Set model suite
#   - ultimately should be URL in IVOA repository (it is reflected in the files)
print "  o Setting model suite.. TEMPORARY - needs to relocate into Templates.\n";
my $ds     = "file:///Users/sao/Documents/IVOA/GitHub/models/vodml/DatasetMetadata-1.0.vo-dml.xml";
my $cube   = "file:///Users/sao/Documents/IVOA/GitHub/models/vodml/Cube-1.0.vo-dml.xml";
my $coords = "file:///Users/sao/Documents/IVOA/GitHub/models/vodml/Coords-v1.0.20210924.vo-dml.xml";
my $meas   = "file:///Users/sao/Documents/IVOA/GitHub/models/vodml/Meas-v1.0.20211019.vo-dml.xml";
my $trans  = "file:///Users/sao/Documents/IVOA/GitHub/TransformDM/vo-dml/Trans-v1.0.vo-dml.xml";
my $ivoa   = "file:///Users/sao/Documents/IVOA/GitHub/models/vodml/IVOA-v1.vo-dml.xml";

#
# Set Schema files
my %schemata = ( "Coords" => "/Users/sao/Documents/IVOA/GitHub/models/schema/CoordsWrap-v1.0.xsd",
                 "Meas"   => "/Users/sao/Documents/IVOA/GitHub/models/schema/MeasWrap-v1.0.xsd",
                 "AVOT"   => "/Users/sao/Documents/IVOA/GitHub/models/schema/VOTable-1.4_vodml.xsd",
    );

# Set locations
print "  o Setting up important locations.\n";

my $base   = "$ENV{'PWD'}";
my $indir  = "${base}/data";
my $outdir = "${base}/temp";
my $resdir = "${base}/templates/pyvodm";

$command = "mkdir -p ${outdir}";
system( $command );

print "     INDIR     = ${indir}\n";
print "     OUTDIR    = ${outdir}\n";
print "     TEMPLATES = ${resdir}\n";

print "  Good to go!\n\n";


# Define file suites for each model
#                        infile                         template                            outroot
my @coords_suite = ( [ "${indir}/sample.fits", "${resdir}/physicalcoord_map.db",         "physicalcoord"           ],
                     [ "${indir}/sample.fits", "${resdir}/lonlatpoint_icrs_map.db",      "lonlatpoint_icrs"        ],
                     [ "${indir}/sample.fits", "${resdir}/lonlatpoint_fk4_map.db",       "lonlatpoint_fk4"         ],
                     [ "${indir}/sample.fits", "${resdir}/cartesianpoint_custom_map.db", "cartesianpoint_custom"   ],
                     [ "${indir}/sample.fits", "${resdir}/timestamp_iso_map.db",         "timestamp_iso"           ],
                     [ "${indir}/sample.fits", "${resdir}/timestamp_jd_map.db",          "timestamp_jd"            ],
                     [ "${indir}/sample.fits", "${resdir}/timestamp_mjd_map.db",         "timestamp_mjd"           ],
                     [ "${indir}/sample.fits", "${resdir}/timestamp_offset_map.db",      "timestamp_offset"        ],
                     [ "${indir}/sample.fits", "${resdir}/pixelcoords_map.db",           "pixelcoords"             ],
                     [ "${indir}/sample.fits", "${resdir}/physicalcoord_full_map.db",    "physicalcoord_full"      ],
                     [ "${indir}/sample.fits", "${resdir}/binnedcoord_map.db",           "binnedcoord"             ],
                     [ "${indir}/sample.fits", "${resdir}/polcoord_map.db",              "polcoord"                ],
                     [ "${indir}/sample.fits", "${resdir}/astrocoordsys_map.db",         "astrocoordsys"           ]  );

my @meas_suite   = ( [ "${indir}/sample.fits", "${resdir}/genericmeasure_map.db",        "genericmeasure"          ],
                     [ "${indir}/sample.fits", "${resdir}/position_equatorial_map.db",   "position_equatorial"     ],
                     [ "${indir}/sample.fits", "${resdir}/position_galactic_map.db",     "position_galactic"       ],
                     [ "${indir}/sample.fits", "${resdir}/position_ecliptic_map.db",     "position_ecliptic"       ],
                     [ "${indir}/sample.fits", "${resdir}/position_cartesian_map.db",    "position_cartesian"      ],
                     [ "${indir}/sample.fits", "${resdir}/position_custom1D_map.db",     "position_custom1D"       ],
                     [ "${indir}/sample.fits", "${resdir}/position_custom2D_map.db",     "position_custom2D"       ],
                     [ "${indir}/sample.fits", "${resdir}/position_custom3D_map.db",     "position_custom3D"       ],
                     [ "${indir}/sample.fits", "${resdir}/polarization_map.db",          "polarization"            ],
                     [ "${indir}/sample.fits", "${resdir}/proper_motion_map.db",         "proper_motion"           ],
                     [ "${indir}/sample.fits", "${resdir}/time_map.db",                  "time"                    ],
                     [ "${indir}/sample.fits", "${resdir}/velocity_custom1D_map.db",     "velocity_custom1D"       ],
                     [ "${indir}/sample.fits", "${resdir}/velocity_custom2D_map.db",     "velocity_custom2D"       ],
                     [ "${indir}/sample.fits", "${resdir}/velocity_custom3D_map.db",     "velocity_custom3D"       ]  );


# Build file list from input
print "  o Creating File list.. \n";
my @full_suite;

#  MCD NOTE: This can loop over input model and format arguments to generate full list
#    o for now, do all formats
for $format  ( @doFormats )
{
    $ext = $format;
    if ($doCoords)
    {
        for my $ii ( 0 .. $#coords_suite )
        {
            push( @full_suite, [ $coords_suite[ii][0], $coords_suite[$ii][1], "${coords_suite[$ii][2]}.${ext}", $format, $schemata{'Coords'} ] );
        }
    }
    if ($doMeas)
    {
        for my $ii ( 0 .. $#meas_suite )
        {
            push( @full_suite, [ $meas_suite[ii][0], $meas_suite[$ii][1], "${meas_suite[$ii][2]}.${ext}", $format, $schemata{'Meas'} ] );
        }
    }
}
    
print "  o Executing File list.. \n";
for my $ii ( 0 .. $#full_suite )
{
    my $infile   = $full_suite[$ii][0];
    my $template = $full_suite[$ii][1];
    my $outfile  = $full_suite[$ii][2];
    my $method   = $full_suite[$ii][3];
    my $schema   = $full_suite[$ii][4];

    print "      example $ii: $outfile ";

    # Create
    $command = "voefg infile=${infile} outdir=${outdir} outfile=${outfile} template=${template} meas=${meas} coords=${coords} ivoa=${ivoa} format=${method} clobber+ verbose=0";
    $rc = system( $command );
    if ( $rc == 0 && -f "${outdir}/${outfile}" && -s "${outdir}/${outfile}" )
    {
        print "OK\n";
    }
    else
    {
        print "Problem ($rc)\n";
        print "    $command\n";
    }

    # Validate
    if ($doValidate)
    {
        print "        + validating..  ";
        if ( ${method} eq "xml" )
        {
            my $isValid = validate_xml( "${outdir}/${outfile}", $schema );
        }
        elsif ( ${method} eq "avot" )
        {
            $schema = $schemata{'AVOT'};
            my $isValid = validate_avot( "${outdir}/${outfile}", $schema );
        }
        elsif ( ${method} eq "vot" )
        {
            my $isValid = validate_vot( "${outdir}/${outfile}", "${outdir}/${outfile}.validate" );
            if ( $isValid )
            {
                print "${outfile} validates\n";
            }
            else
            {
                print "Problem: validating ${outfile}.\n";
            }
        }
        elsif ( ${method} eq "xxx" )
        {
            print "No validation applicable.\n";
        }        
    }
    
}    

# =============================================================================
# validate_xml()
# =============================================================================
sub validate_xml{
    my ( $file, $schema ) = (@_);
    my $result = 0;

    $command = "xmllint --schema ${schema} --noout ${file}";
    $rc = system( $command );
    if ( $rc == 0 )
    {
        $result = 1;
    }

    return $result;
}
# =============================================================================
# validate_avot()
# =============================================================================
sub validate_avot{
    my ( $file, $schema ) = (@_);
    my $result = 0;

    $command = "xmllint --schema ${schema} --noout ${file}";
    $rc = system( $command );
    if ( $rc == 0 )
    {
        $result = 1;
    }

    return $result;
}
# =============================================================================
# validate_vot()
# =============================================================================
sub validate_vot{
    my ( $file, $report) = (@_);
    my $result = 0;

    $command = "java -jar /Users/sao/Documents/IVOA/GitHub/dm-example-files/stilts.jar votlint validate=true version=1.3 out=${report} votable=${file}";
    $rc = system( $command );
    $filter_command = "grep -iv Warning ${report} > ${report}_filt";
    system( $filter_command );
    if ( $rc == 0 && -f "${report}" && -z "${report}_filt" )
    {
        $result = 1;
    }

    return $result;
}

# ================================================================================
##             infile                                                   template                                outfile                                 annotation
#my @files =(
#            ##
#            ## Transform
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookup1d_map.db",        "atomic_lookup1d.vot",                        "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookup1d_map.db",        "atomic_lookup1d.avot",                       "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookup1d_map.db",        "atomic_lookup1d.xml",                        "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookup2d_map.db",        "atomic_lookup2d.vot",                        "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookup2d_map.db",        "atomic_lookup2d.avot",                       "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookup2d_map.db",        "atomic_lookup2d.xml",                        "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookupStr_map.db",       "atomic_lookupStr.vot",                       "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookupStr_map.db",       "atomic_lookupStr.avot",                      "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_lookupStr_map.db",       "atomic_lookupStr.xml",                       "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_poly1d_map.db",          "atomic_poly1d.vot",                          "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_poly1d_map.db",          "atomic_poly1d.avot",                         "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_poly1d_map.db",          "atomic_poly1d.xml",                          "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_poly2d_map.db",          "atomic_poly2d.vot",                          "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_poly2d_map.db",          "atomic_poly2d.avot",                         "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_poly2d_map.db",          "atomic_poly2d.xml",                          "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_skyproj_map.db",         "atomic_skyproj.vot",                         "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_skyproj_map.db",         "atomic_skyproj.avot",                        "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_skyproj_map.db",         "atomic_skyproj.xml",                         "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_skyprojrotate_map.db",   "atomic_skyprojrotate.vot",                   "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_skyprojrotate_map.db",   "atomic_skyprojrotate.avot",                  "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_skyprojrotate_map.db",   "atomic_skyprojrotate.xml",                   "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_specproj_map.db",        "atomic_specproj.vot",                        "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_specproj_map.db",        "atomic_specproj.avot",                       "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_specproj_map.db",        "atomic_specproj.xml",                        "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_matrix_map.db",          "atomic_matrix.vot",                          "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_matrix_map.db",          "atomic_matrix.avot",                         "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_matrix_map.db",          "atomic_matrix.xml",                          "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_euler_map.db",           "atomic_euler.vot",                           "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_euler_map.db",           "atomic_euler.avot",                          "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/atomic_euler_map.db",           "atomic_euler.xml",                           "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/bidirectional_map.db",          "bidirectional.vot",                          "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/bidirectional_map.db",          "bidirectional.avot",                         "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/bidirectional_map.db",          "bidirectional.xml",                          "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/workflow_compound_map.db",      "workflow_compound.vot",                      "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/workflow_compound_map.db",      "workflow_compound.avot",                     "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/workflow_compound_map.db",      "workflow_compound.xml",                      "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/workflow_permute_map.db",      "workflow_permute.vot",                        "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/workflow_permute_map.db",      "workflow_permute.avot",                       "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/workflow_permute_map.db",      "workflow_permute.xml",                        "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/transformset_map.db",           "transformset.vot",                           "vot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/transformset_map.db",           "transformset.avot",                          "avot" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/transformset_map.db",           "transformset.xml",                           "xml" ],
#	    # ["${base}/STC/Trans/examples/sample.fits",         "${resdir}/trans_test01_map.db",          "trans_test01.xml",                            "xml" ],
#            ##
#            ## Dataset Metadata
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/obsdataset_full_map.db",   "obsdataset_full.xxx",                      "xxx" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/obsdataset_full_map.db",   "obsdataset_full.xml",                      "xml" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/obsdataset_full_map.db",   "obsdataset_full.vot",                      "vot" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/obsdataset_full_map.db",   "obsdataset_full.avot",                     "avot" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/obsdataset_mini_map.db",   "obsdataset_mini.xml",                      "xml" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/obsdataset_mini_map.db",   "obsdataset_mini.vot",                      "vot" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/obsdataset_mini_map.db",   "obsdataset_mini.avot",                     "avot" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/observation_full_map.db",  "observation_full.xml",                     "xml" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/observation_full_map.db",  "observation_full.vot",                     "vot" ],
#	    # ["${base}/DatasetMetadata/examples/chandra_events.fits",   "${resdir}/observation_full_map.db",  "observation_full.avot",                    "avot" ],
#            #
#            ## ND Cube
#	    # ["${base}/Cube/examples/src/chandra_events.fits",           "${resdir}/sparse_cube_map.db",       "sparse_cube.xxx",                         "xxx" ],
#	    # ["${base}/Cube/examples/src/chandra_events.fits",           "${resdir}/sparse_cube_map.db",       "sparse_cube.vot",                         "vot" ],
#	    # ["${base}/Cube/examples/src/chandra_events.fits",           "${resdir}/sparse_cube_map.db",       "sparse_cube.avot",                        "avot" ],
#	    # ["${base}/Cube/examples/src/chandra_events.fits",           "${resdir}/sparse_cube_xml_map.db",   "sparse_cube.xml",                         "xml" ],
#            #
#	    # ["${base}/Cube/examples/src/chandra_2Dsky_image.fits[0]",    "${resdir}/image_2d_map.db",          "image_2D.xxx",                            "xxx" ],
#	    # ["${base}/Cube/examples/src/chandra_2Dsky_image.fits[0]",    "${resdir}/image_2d_map.db",          "image_2D.vot",                            "vot" ],
#	    # ["${base}/Cube/examples/src/chandra_2Dsky_image.fits[0]",    "${resdir}/image_2d_map.db",          "image_2D.avot",                           "avot" ],
#	    # ["${base}/Cube/examples/src/chandra_2Dsky_image.fits[0]",    "${resdir}/image_2d_xml_map.db",      "image_2D.xml",                            "xml" ],
#            #
#	    # ["${base}/Cube/examples/src/VLA_4D_image.fits[0]",            "${resdir}/image_4d_map.db",          "image_4D.xxx",                            "xxx" ],
#	    # ["${base}/Cube/examples/src/VLA_4D_image.fits[0]",            "${resdir}/image_4d_map.db",          "image_4D.vot",                            "vot" ],
#	    # ["${base}/Cube/examples/src/VLA_4D_image.fits[0]",            "${resdir}/image_4d_map.db",          "image_4D.avot",                            "avot" ],
#	    # ["${base}/Cube/examples/src/VLA_4D_image.fits[0]",            "${resdir}/image_4d_xml_map.db",      "image_4D.xml",                            "xml" ],
#            #
#	    # TODO ================================================================================
#	    # ["${base}/Cube/examples/src/timeseries_example1.fits", "${resdir}/timeseries_example1_map.db",  "timeseries_1.vot",                       "none" ],
#	    # ["${base}/Cube/examples/src/timeseries_example1.fits", "${resdir}/timeseries_example1_map.db",  "timeseries_1a.vot",                      "byRef" ],
#	    # ["${base}/Cube/examples/src/VLA_4D_image.fits",    "${resdir}/vla_image_modelmap.db",       "image_4D_1a.vot",                             "byRef" ],
#	    # ["${base}/Cube/examples/src/VLA_4D_image.fits",    "${resdir}/vla_image_modelmap.db",       "image_4D_1b.vot",                             "byCopy" ],
#            );
#


# Compare against existing file? No real reason to do this.. 
#    if ($infile =~ /STC/ )
#    {
#	if ($infile =~ /Coords/ )
#	{
#	    $testsav = "${basedir}/STC/Coords/examples";
#	}
#	elsif ($infile =~ /Meas/ )
#	{
#	    $testsav = "${basedir}/STC/Meas/examples";
#	}
#	elsif ($infile =~ /Trans/ )
#	{
#	    $testsav = "${basedir}/STC/Trans/examples";
#	}
#    }
#    elsif ($infile =~ /Dataset/ )
#    {
#	$testsav = "${basedir}/DatasetMetadata/examples";
#    }
#    elsif ($infile =~ /Cube/ )
#    {
#	$testsav = "${basedir}/Cube/examples";
#    }
#
#
#    # Compare with current version
#    print "  COMPARE:";
#    if ( $method eq "xml" )
#    {
#	$rc = compare( "${testout}/${outfile}", "${testsav}/${outfile}_raw" )
#    }
#    else
#    {
#	$rc = compare( "${testout}/${outfile}", "${testsav}/${outfile}" )
#    }
#    if ( $rc == 0 )
#    {
#	print "OK\n";
#    }
#    else
#    {
#	print "Problem\n";
#	print "    diff ${testout}/${outfile} ${testsav}/${outfile}\n";
#    }
#}


